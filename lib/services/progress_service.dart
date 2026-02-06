import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/curriculum_models.dart';
import '../models/progress_models.dart';
import 'encrypted_storage_service.dart';

/// Progress tracking service with persistence + Firestore sync
class ProgressService extends ChangeNotifier {
  static ProgressService? _instance;
  static ProgressService get instance => _instance ??= ProgressService._();

  ProgressService._();

  late EncryptedStorageService _storage;
  UserProgress _progress = UserProgress();

  static const String _progressKey = 'user_progress';
  static const String _activityMigratedKey = 'activity_log_migrated';

  // Firestore reference
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserProgress get progress => _progress;
  NCOLevel get currentLevel => _progress.currentLevel;
  int get totalXP => _progress.totalXP;
  int get level => _progress.level;
  int get currentStreak => _progress.currentStreak;
  DailyGoals get dailyGoals => _progress.dailyGoals;

  /// Initialize the service
  static Future<void> init() async {
    instance._storage = EncryptedStorageService.instance;

    // Migrate legacy plaintext data to encrypted format
    await instance._storage.migrateToEncrypted(_progressKey);

    await instance._loadProgress();
  }

  /// Load progress from storage
  Future<void> _loadProgress() async {
    final json = _storage.readEncrypted(_progressKey);
    if (json != null) {
      try {
        final data = jsonDecode(json) as Map<String, dynamic>;
        _progress = _parseProgress(data);
      } catch (e) {
        debugPrint('Error loading progress: $e');
        _progress = UserProgress();
      }
    }

    // Reset daily goals if needed
    _progress.dailyGoals.resetIfNeeded();
    await _saveProgress();

    // Backfill activity_log from existing progress (one-time)
    await _migrateExistingActivityLog();

    notifyListeners();
  }

  UserProgress _parseProgress(Map<String, dynamic> data) {
    return UserProgress(
      currentLevel: NCOLevel.values[data['currentLevel'] ?? 0],
      totalXP: data['totalXP'] ?? 0,
      currentStreak: data['currentStreak'] ?? 0,
      lastStudyDate: data['lastStudyDate'] != null
          ? DateTime.parse(data['lastStudyDate'])
          : null,
      unlockedAchievements: Set<String>.from(
        data['unlockedAchievements'] ?? [],
      ),
      dailyGoals: data['dailyGoals'] != null
          ? DailyGoals.fromJson(data['dailyGoals'])
          : DailyGoals(),
      moduleProgress:
          (data['moduleProgress'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, ModuleProgress.fromJson(value)),
          ) ??
          {},
      flashcardProgress:
          (data['flashcardProgress'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, SpacedRepetitionCard.fromJson(value)),
          ) ??
          {},
    );
  }

  /// Save progress to local storage + sync to Firestore
  Future<void> _saveProgress() async {
    final data = {
      'currentLevel': _progress.currentLevel.index,
      'totalXP': _progress.totalXP,
      'currentStreak': _progress.currentStreak,
      'lastStudyDate': _progress.lastStudyDate?.toIso8601String(),
      'unlockedAchievements': _progress.unlockedAchievements.toList(),
      'dailyGoals': _progress.dailyGoals.toJson(),
      'moduleProgress': _progress.moduleProgress.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'flashcardProgress': _progress.flashcardProgress.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
    await _storage.writeEncrypted(_progressKey, jsonEncode(data));

    // Sync to Firestore
    await _syncToFirestore();
  }

  /// Sync progress data to Firestore for teacher dashboard
  Future<void> _syncToFirestore() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final completedLessonsList = <String>[];
      final completedModulesList = <String>[];
      final quizScoresMap = <String, int>{};

      for (final entry in _progress.moduleProgress.entries) {
        final moduleId = entry.key;
        final mp = entry.value;

        for (final lessonId in mp.completedLessons) {
          completedLessonsList.add('$moduleId/$lessonId');
        }

        if (mp.isCompleted) {
          completedModulesList.add(moduleId);
        }

        quizScoresMap.addAll(mp.quizScores);
      }

      // Count stats for top-level fields (student_detail_screen reads these)
      final quizPassedCount = quizScoresMap.values.where((s) => s >= 70).length;
      final flashcardsCount = _progress.flashcardProgress.length;
      final achievementsCount = _progress.unlockedAchievements.length;

      // Use set with merge to avoid errors when document/field doesn't exist
      await _firestore.collection('users').doc(user.uid).set({
        // Nested progress (teacher_dashboard reads this)
        'progress': {
          'totalXP': _progress.totalXP,
          'currentStreak': _progress.currentStreak,
          'lastActiveDate': FieldValue.serverTimestamp(),
          'completedLessons': completedLessonsList,
          'completedModules': completedModulesList,
          'quizScores': quizScoresMap,
        },
        // Top-level fields (student_detail_screen reads these)
        'uid': user.uid,
        'totalXP': _progress.totalXP,
        'xp': _progress.totalXP,
        'currentStreak': _progress.currentStreak,
        'lessonsCompleted': completedLessonsList.length,
        'quizzesPassed': quizPassedCount,
        'flashcardsStudied': flashcardsCount,
        'achievementsUnlocked': achievementsCount,
        'lastActiveDate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('Progress synced to Firestore: ${_progress.totalXP} XP');
    } catch (e) {
      debugPrint('Failed to sync progress to Firestore: $e');
    }
  }

  /// Migrate existing progress data to activity_log (one-time)
  Future<void> _migrateExistingActivityLog() async {
    // Check if already migrated
    final migrated = _storage.readEncrypted(_activityMigratedKey);
    if (migrated == 'true') return;

    final user = _auth.currentUser;
    if (user == null) return;

    final displayName = user.displayName ?? user.email ?? 'ไม่ระบุ';
    final batch = _firestore.batch();
    int count = 0;

    try {
      for (final entry in _progress.moduleProgress.entries) {
        final moduleId = entry.key;
        final mp = entry.value;

        // Log each completed lesson
        for (final lessonId in mp.completedLessons) {
          final ref = _firestore.collection('activity_log').doc();
          batch.set(ref, {
            'userId': user.uid,
            'userName': displayName,
            'type': 'lesson_completed',
            'details': 'เรียนจบบทเรียน $lessonId (ข้อมูลย้อนหลัง)',
            'timestamp': mp.completedAt ?? FieldValue.serverTimestamp(),
            'migrated': true,
          });
          count++;
        }

        // Log each quiz score
        for (final quizEntry in mp.quizScores.entries) {
          final quizId = quizEntry.key;
          final score = quizEntry.value;
          final passed = score >= 70;
          final ref = _firestore.collection('activity_log').doc();
          batch.set(ref, {
            'userId': user.uid,
            'userName': displayName,
            'type': passed ? 'quiz_passed' : 'lesson_completed',
            'details': 'ทำแบบทดสอบ $quizId ได้ $score% ${passed ? "(ผ่าน)" : "(ไม่ผ่าน)"} (ข้อมูลย้อนหลัง)',
            'timestamp': mp.completedAt ?? FieldValue.serverTimestamp(),
            'migrated': true,
          });
          count++;
        }

        // Log module completion
        if (mp.isCompleted) {
          final ref = _firestore.collection('activity_log').doc();
          batch.set(ref, {
            'userId': user.uid,
            'userName': displayName,
            'type': 'lesson_completed',
            'details': 'เรียนจบโมดูล $moduleId ครบทุกบทเรียนแล้ว (ข้อมูลย้อนหลัง)',
            'timestamp': mp.completedAt ?? FieldValue.serverTimestamp(),
            'migrated': true,
          });
          count++;
        }
      }

      if (count > 0) {
        await batch.commit();
        debugPrint('Migrated $count activity log entries to Firestore');
      }

      // Mark as migrated
      await _storage.writeEncrypted(_activityMigratedKey, 'true');
    } catch (e) {
      debugPrint('Failed to migrate activity log: $e');
    }
  }

  /// Log activity to Firestore for teacher dashboard
  Future<void> _logActivity({
    required String type,
    required String details,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final displayName = user.displayName ?? user.email ?? 'ไม่ระบุ';

      await _firestore.collection('activity_log').add({
        'userId': user.uid,
        'userName': displayName,
        'type': type,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Failed to log activity: $e');
    }
  }

  /// Set NCO level
  Future<void> setNCOLevel(NCOLevel level) async {
    _progress = UserProgress(
      currentLevel: level,
      totalXP: _progress.totalXP,
      currentStreak: _progress.currentStreak,
      lastStudyDate: _progress.lastStudyDate,
      unlockedAchievements: _progress.unlockedAchievements,
      dailyGoals: _progress.dailyGoals,
      moduleProgress: _progress.moduleProgress,
      flashcardProgress: _progress.flashcardProgress,
    );
    await _saveProgress();
    notifyListeners();
  }

  /// Add XP
  Future<void> addXP(int points) async {
    _progress = UserProgress(
      currentLevel: _progress.currentLevel,
      totalXP: _progress.totalXP + points,
      currentStreak: _progress.currentStreak,
      lastStudyDate: DateTime.now(),
      unlockedAchievements: _progress.unlockedAchievements,
      dailyGoals: _progress.dailyGoals,
      moduleProgress: _progress.moduleProgress,
      flashcardProgress: _progress.flashcardProgress,
    );
    await _saveProgress();
    notifyListeners();
  }

  /// Complete a lesson
  Future<void> completeLesson(String moduleId, String lessonId, {int totalLessonsInModule = 0}) async {
    final moduleProgress =
        _progress.moduleProgress[moduleId] ??
        ModuleProgress(moduleId: moduleId);

    // Avoid duplicate completion
    if (moduleProgress.completedLessons.contains(lessonId)) return;

    moduleProgress.completedLessons.add(lessonId);

    // Check if all lessons in module are completed
    if (totalLessonsInModule > 0 &&
        moduleProgress.completedLessons.length >= totalLessonsInModule &&
        !moduleProgress.isCompleted) {
      moduleProgress.markCompleted();
      await _logActivity(
        type: 'lesson_completed',
        details: 'เรียนจบโมดูล $moduleId ครบทุกบทเรียนแล้ว',
      );
    }

    _progress.moduleProgress[moduleId] = moduleProgress;
    _progress.dailyGoals.lessonsCompleted++;

    await _logActivity(
      type: 'lesson_completed',
      details: 'เรียนจบบทเรียน $lessonId',
    );

    await addXP(50); // 50 XP per lesson
  }

  /// Save quiz score
  Future<void> saveQuizScore(String quizId, int score) async {
    // Find module for this quiz
    final moduleId = quizId.split('_').take(2).join('_');
    final moduleProgress =
        _progress.moduleProgress[moduleId] ??
        ModuleProgress(moduleId: moduleId);
    moduleProgress.quizScores[quizId] = score;

    _progress.moduleProgress[moduleId] = moduleProgress;
    _progress.dailyGoals.quizzesTaken++;

    final passed = score >= 70;
    await _logActivity(
      type: passed ? 'quiz_passed' : 'lesson_completed',
      details: 'ทำแบบทดสอบ $quizId ได้ $score% ${passed ? "(ผ่าน)" : "(ไม่ผ่าน)"}',
    );

    // XP based on score
    final xp = (score / 10).round() * 10;
    await addXP(xp);
  }

  /// Update flashcard with spaced repetition
  Future<void> updateFlashcard(String cardId, int quality) async {
    final card =
        _progress.flashcardProgress[cardId] ??
        SpacedRepetitionCard(cardId: cardId);
    card.updateWithQuality(quality);

    _progress.flashcardProgress[cardId] = card;
    _progress.dailyGoals.flashcardsStudied++;

    await _saveProgress();
    notifyListeners();
  }

  /// Get due flashcards
  List<String> getDueFlashcards() {
    return _progress.flashcardProgress.entries
        .where((e) => e.value.isDue)
        .map((e) => e.key)
        .toList();
  }

  /// Update streak
  Future<void> updateStreak() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastStudy = _progress.lastStudyDate;

    int newStreak = _progress.currentStreak;

    if (lastStudy == null) {
      newStreak = 1;
    } else {
      final lastStudyDay = DateTime(
        lastStudy.year,
        lastStudy.month,
        lastStudy.day,
      );
      final dayDiff = today.difference(lastStudyDay).inDays;

      if (dayDiff == 0) {
        // Same day, no change
      } else if (dayDiff == 1) {
        newStreak++;
      } else {
        newStreak = 1; // Streak broken
      }
    }

    _progress = UserProgress(
      currentLevel: _progress.currentLevel,
      totalXP: _progress.totalXP,
      currentStreak: newStreak,
      lastStudyDate: now,
      unlockedAchievements: _progress.unlockedAchievements,
      dailyGoals: _progress.dailyGoals,
      moduleProgress: _progress.moduleProgress,
      flashcardProgress: _progress.flashcardProgress,
    );

    await _saveProgress();
    notifyListeners();
  }

  /// Check if module is completed
  bool isModuleCompleted(String moduleId) {
    final progress = _progress.moduleProgress[moduleId];
    return progress?.isCompleted ?? false;
  }

  /// Get module progress
  ModuleProgress? getModuleProgress(String moduleId) {
    return _progress.moduleProgress[moduleId];
  }

  /// Unlock achievement
  Future<void> unlockAchievement(String achievementId) async {
    if (!_progress.unlockedAchievements.contains(achievementId)) {
      _progress.unlockedAchievements.add(achievementId);
      await _saveProgress();
      notifyListeners();
    }
  }

  /// Reset all progress (for testing)
  Future<void> resetProgress() async {
    _progress = UserProgress();
    await _storage.remove(_progressKey);

    // Also reset Firestore
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'progress': {
            'totalXP': 0,
            'currentStreak': 0,
            'lastActiveDate': null,
            'completedLessons': [],
            'completedModules': [],
            'quizScores': {},
          },
        });
      }
    } catch (e) {
      debugPrint('Failed to reset Firestore progress: $e');
    }

    notifyListeners();
  }
}

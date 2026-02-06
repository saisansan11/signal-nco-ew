import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/curriculum_models.dart';
import '../models/progress_models.dart';
import 'encrypted_storage_service.dart';

/// Progress tracking service with persistence
class ProgressService extends ChangeNotifier {
  static ProgressService? _instance;
  static ProgressService get instance => _instance ??= ProgressService._();

  ProgressService._();

  late EncryptedStorageService _storage;
  UserProgress _progress = UserProgress();

  static const String _progressKey = 'user_progress';

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
      unlockedAchievements:
          Set<String>.from(data['unlockedAchievements'] ?? []),
      dailyGoals: data['dailyGoals'] != null
          ? DailyGoals.fromJson(data['dailyGoals'])
          : DailyGoals(),
      moduleProgress: (data['moduleProgress'] as Map<String, dynamic>?)?.map(
            (key, value) =>
                MapEntry(key, ModuleProgress.fromJson(value)),
          ) ??
          {},
      flashcardProgress:
          (data['flashcardProgress'] as Map<String, dynamic>?)?.map(
                (key, value) =>
                    MapEntry(key, SpacedRepetitionCard.fromJson(value)),
              ) ??
              {},
    );
  }

  /// Save progress to storage
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
  Future<void> completeLesson(String moduleId, String lessonId) async {
    final moduleProgress =
        _progress.moduleProgress[moduleId] ?? ModuleProgress(moduleId: moduleId);
    moduleProgress.completedLessons.add(lessonId);

    _progress.moduleProgress[moduleId] = moduleProgress;
    _progress.dailyGoals.lessonsCompleted++;

    await addXP(50); // 50 XP per lesson
  }

  /// Save quiz score
  Future<void> saveQuizScore(String quizId, int score) async {
    // Find module for this quiz
    final moduleId = quizId.split('_').take(2).join('_');
    final moduleProgress =
        _progress.moduleProgress[moduleId] ?? ModuleProgress(moduleId: moduleId);
    moduleProgress.quizScores[quizId] = score;

    _progress.moduleProgress[moduleId] = moduleProgress;
    _progress.dailyGoals.quizzesTaken++;

    // XP based on score
    final xp = (score / 10).round() * 10;
    await addXP(xp);
  }

  /// Update flashcard with spaced repetition
  Future<void> updateFlashcard(String cardId, int quality) async {
    final card = _progress.flashcardProgress[cardId] ??
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
      final lastStudyDay =
          DateTime(lastStudy.year, lastStudy.month, lastStudy.day);
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
    notifyListeners();
  }
}

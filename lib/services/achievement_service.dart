import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement_model.dart';
import '../data/achievement_data.dart';
import 'feedback_service.dart';

/// Achievement Service - จัดการรางวัลและการปลดล็อค
class AchievementService extends ChangeNotifier {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  final FeedbackService _feedback = FeedbackService();
  final Map<String, UserAchievementProgress> _progress = {};
  final List<Achievement> _recentlyUnlocked = [];

  /// Get all achievements with progress
  List<Achievement> get allAchievements => AchievementData.allAchievements;

  /// Get unlocked achievements
  List<Achievement> get unlockedAchievements {
    return allAchievements
        .where((a) => _progress[a.id]?.isUnlocked ?? false)
        .toList();
  }

  /// Get locked achievements
  List<Achievement> get lockedAchievements {
    return allAchievements
        .where((a) => !(_progress[a.id]?.isUnlocked ?? false))
        .toList();
  }

  /// Get recently unlocked (for notification)
  List<Achievement> get recentlyUnlocked => List.unmodifiable(_recentlyUnlocked);

  /// Get progress for specific achievement
  UserAchievementProgress? getProgress(String achievementId) {
    return _progress[achievementId];
  }

  /// Get total XP earned from achievements
  int get totalXpEarned {
    int total = 0;
    for (var achievement in unlockedAchievements) {
      total += achievement.totalXp;
    }
    return total;
  }

  /// Get completion percentage
  double get completionPercentage {
    if (allAchievements.isEmpty) return 0.0;
    return unlockedAchievements.length / allAchievements.length;
  }

  /// Initialize service
  Future<void> init() async {
    await _loadProgress();
  }

  /// Load progress from storage
  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('achievement_progress');

    if (data != null) {
      final json = jsonDecode(data) as Map<String, dynamic>;
      json.forEach((key, value) {
        _progress[key] = UserAchievementProgress.fromJson(value);
      });
    }

    notifyListeners();
  }

  /// Save progress to storage
  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final json = <String, dynamic>{};
    _progress.forEach((key, value) {
      json[key] = value.toJson();
    });
    await prefs.setString('achievement_progress', jsonEncode(json));
  }

  /// Increment progress for an achievement
  Future<bool> incrementProgress(String achievementId, {int amount = 1}) async {
    final achievement = AchievementData.getById(achievementId);
    if (achievement == null) return false;

    var progress = _progress[achievementId];
    if (progress == null) {
      progress = UserAchievementProgress(achievementId: achievementId);
      _progress[achievementId] = progress;
    }

    // Already unlocked
    if (progress.isUnlocked) return false;

    // Update progress
    progress.currentValue += amount;

    // Check if achievement is now unlocked
    if (progress.currentValue >= achievement.targetValue) {
      return await _unlockAchievement(achievementId);
    }

    await _saveProgress();
    notifyListeners();
    return false;
  }

  /// Unlock an achievement directly
  Future<bool> _unlockAchievement(String achievementId) async {
    final achievement = AchievementData.getById(achievementId);
    if (achievement == null) return false;

    var progress = _progress[achievementId];
    if (progress == null) {
      progress = UserAchievementProgress(achievementId: achievementId);
      _progress[achievementId] = progress;
    }

    // Already unlocked
    if (progress.isUnlocked) return false;

    // Unlock
    progress.isUnlocked = true;
    progress.unlockedAt = DateTime.now();

    // Add to recently unlocked
    _recentlyUnlocked.add(achievement);

    // Play feedback
    await _feedback.achievementUnlocked();

    await _saveProgress();
    notifyListeners();

    // Check for achievement collection milestones
    await _checkAchievementCount();

    debugPrint('🏆 Achievement unlocked: ${achievement.titleTh}');
    return true;
  }

  /// Clear recently unlocked (after showing notification)
  void clearRecentlyUnlocked() {
    _recentlyUnlocked.clear();
    notifyListeners();
  }

  // ==================== Event Tracking Methods ====================

  /// Track lesson completion
  Future<void> trackLessonComplete() async {
    await incrementProgress('first_lesson');
    await incrementProgress('lesson_5');
    await incrementProgress('lesson_15');
  }

  /// Track radar detection
  Future<void> trackRadarDetection() async {
    await incrementProgress('first_detection');
    await incrementProgress('radar_ace');
  }

  /// Track spectrum analysis
  Future<void> trackSpectrumAnalysis() async {
    await incrementProgress('spectrum_analyst');
  }

  /// Track jamming
  Future<void> trackJamming() async {
    await incrementProgress('jammer_expert');
  }

  /// Track DF triangulation
  Future<void> trackDFTriangulation({required double accuracy}) async {
    if (accuracy >= 0.8) {
      await incrementProgress('df_master');
    }
  }

  /// Track quiz completion
  Future<void> trackQuizComplete({required double score}) async {
    await incrementProgress('first_quiz');
    if (score >= 1.0) {
      await incrementProgress('quiz_perfect');
    }
    if (score >= 0.8) {
      await incrementProgress('quiz_streak_5');
    }
  }

  /// Track flashcard review
  Future<void> trackFlashcardReview() async {
    await incrementProgress('flashcard_master');
  }

  /// Track streak
  Future<void> trackStreak(int days) async {
    if (days >= 3) await incrementProgress('streak_3', amount: days);
    if (days >= 7) await incrementProgress('streak_7', amount: days);
    if (days >= 30) await incrementProgress('streak_30', amount: days);
    if (days >= 100) await incrementProgress('streak_100', amount: days);
  }

  /// Track time of study
  Future<void> trackStudyTime() async {
    final hour = DateTime.now().hour;
    if (hour < 6) {
      await incrementProgress('early_bird');
    }
    if (hour >= 0 && hour < 5) {
      await incrementProgress('night_owl');
    }
  }

  /// Track campaign progress
  Future<void> trackCampaignStart() async {
    await incrementProgress('campaign_start');
  }

  Future<void> trackCampaignComplete({required double score}) async {
    await incrementProgress('campaign_complete');
    await incrementProgress('campaign_5');
    if (score >= 1.0) {
      await incrementProgress('campaign_perfect');
    }
  }

  /// Track level up
  Future<void> trackLevelUp(int level) async {
    if (level >= 5) await incrementProgress('ew_novice', amount: level);
    if (level >= 15) await incrementProgress('ew_specialist', amount: level);
    if (level >= 30) await incrementProgress('ew_expert', amount: level);
    if (level >= 50) await incrementProgress('ew_master', amount: level);
    if (level >= 100) await incrementProgress('ew_legend', amount: level);
  }

  /// Track first login
  Future<void> trackFirstLogin() async {
    await incrementProgress('first_login');
  }

  /// Track section visits
  final Set<String> _visitedSections = {};

  Future<void> trackSectionVisit(String section) async {
    _visitedSections.add(section);
    // If all sections visited
    if (_visitedSections.length >= 8) {
      await incrementProgress('explorer');
    }
  }

  /// Track achievement count
  Future<void> _checkAchievementCount() async {
    final count = unlockedAchievements.length;
    if (count >= 10) await incrementProgress('collector', amount: count);
    if (count >= 25) await incrementProgress('achievement_hunter', amount: count);
    if (count >= allAchievements.length) {
      await incrementProgress('completionist');
    }
  }

  /// Track perfect radar sweep
  Future<void> trackPerfectSweep() async {
    await incrementProgress('perfect_sweep');
  }

  /// Track speed completion
  Future<void> trackSpeedCompletion(Duration time) async {
    if (time.inSeconds < 30) {
      await incrementProgress('speed_demon');
    }
  }

  /// Track ESM/ECM/ECCM mastery
  Future<void> trackESMMastery() async {
    await incrementProgress('esm_master');
  }

  Future<void> trackECMMastery() async {
    await incrementProgress('ecm_master');
  }

  Future<void> trackECCMMastery() async {
    await incrementProgress('eccm_master');
  }
}

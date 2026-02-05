import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/campaign_model.dart';
import '../data/campaign_data.dart';
import 'feedback_service.dart';
import 'achievement_service.dart';

/// Campaign Service - จัดการ Campaign และ Mission Progress
class CampaignService extends ChangeNotifier {
  static final CampaignService _instance = CampaignService._internal();
  factory CampaignService() => _instance;
  CampaignService._internal();

  final FeedbackService _feedback = FeedbackService();
  final AchievementService _achievement = AchievementService();
  final Map<String, UserCampaignProgress> _progress = {};

  /// Get all campaigns
  List<Campaign> get allCampaigns => CampaignData.allCampaigns;

  /// Get campaign progress
  UserCampaignProgress? getProgress(String campaignId) {
    return _progress[campaignId];
  }

  /// Get total stars earned
  int get totalStars {
    return _progress.values.fold(0, (sum, p) => sum + p.totalStars);
  }

  /// Get total completed missions
  int get totalCompletedMissions {
    return _progress.values.fold(0, (sum, p) => sum + p.completedMissions);
  }

  /// Get completion percentage
  double get completionPercentage {
    final total = CampaignData.totalMissions;
    if (total == 0) return 0.0;
    return totalCompletedMissions / total;
  }

  /// Check if campaign is unlocked
  bool isCampaignUnlocked(Campaign campaign) {
    return totalStars >= campaign.difficulty.starsRequired;
  }

  /// Check if mission is unlocked
  bool isMissionUnlocked(Campaign campaign, int missionIndex) {
    if (missionIndex == 0) return isCampaignUnlocked(campaign);

    // Previous mission must be completed
    final progress = _progress[campaign.id];
    if (progress == null) return false;

    final prevMissionId = campaign.missions[missionIndex - 1].id;
    final prevResult = progress.missionResults[prevMissionId];
    return prevResult?.isCompleted ?? false;
  }

  /// Initialize service
  Future<void> init() async {
    await _loadProgress();
  }

  /// Load progress from storage
  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('campaign_progress');

    if (data != null) {
      final json = jsonDecode(data) as Map<String, dynamic>;
      json.forEach((key, value) {
        _progress[key] = UserCampaignProgress.fromJson(value);
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
    await prefs.setString('campaign_progress', jsonEncode(json));
  }

  /// Start a mission
  Future<void> startMission(String campaignId, String missionId) async {
    final campaign = CampaignData.getById(campaignId);
    if (campaign == null) return;

    // Track campaign start achievement
    await _achievement.trackCampaignStart();

    notifyListeners();
  }

  /// Complete a mission
  Future<MissionResult> completeMission({
    required String campaignId,
    required String missionId,
    required int score,
    required int timeSpent,
    required Map<String, int> objectiveProgress,
  }) async {
    final campaign = CampaignData.getById(campaignId);
    if (campaign == null) {
      return MissionResult(missionId: missionId);
    }

    // Verify mission exists
    final missionExists = campaign.missions.any((m) => m.id == missionId);
    if (!missionExists) {
      return MissionResult(missionId: missionId);
    }

    // Calculate stars based on score
    int stars = 0;
    if (score >= 60) stars = 1;
    if (score >= 80) stars = 2;
    if (score >= 95) stars = 3;

    // Create result
    final result = MissionResult(
      missionId: missionId,
      stars: stars,
      score: score,
      timeSpent: timeSpent,
      isCompleted: score >= 60,
      completedAt: DateTime.now(),
      objectiveProgress: objectiveProgress,
    );

    // Update progress
    var campaignProgress = _progress[campaignId];
    if (campaignProgress == null) {
      campaignProgress = UserCampaignProgress(campaignId: campaignId);
      _progress[campaignId] = campaignProgress;
    }

    // Only update if better result
    final existingResult = campaignProgress.missionResults[missionId];
    if (existingResult == null || result.stars > existingResult.stars) {
      campaignProgress.missionResults[missionId] = result;
    }

    // Check if campaign is now completed
    final allMissionsCompleted = campaign.missions.every((m) {
      final r = campaignProgress!.missionResults[m.id];
      return r?.isCompleted ?? false;
    });

    if (allMissionsCompleted && !campaignProgress.isCompleted) {
      campaignProgress.isCompleted = true;
      campaignProgress.completedAt = DateTime.now();

      // Play completion feedback
      await _feedback.missionComplete();

      // Track achievement
      await _achievement.trackCampaignComplete(
        score: campaignProgress.totalStars / campaign.maxStars,
      );
    } else if (result.isCompleted) {
      // Play success feedback
      await _feedback.success();
    }

    await _saveProgress();
    notifyListeners();

    return result;
  }

  /// Get next unlocked mission
  CampaignMission? getNextMission() {
    for (final campaign in allCampaigns) {
      if (!isCampaignUnlocked(campaign)) continue;

      for (int i = 0; i < campaign.missions.length; i++) {
        final mission = campaign.missions[i];
        final progress = _progress[campaign.id];
        final result = progress?.missionResults[mission.id];

        if (result == null || !result.isCompleted) {
          if (isMissionUnlocked(campaign, i)) {
            return mission;
          }
        }
      }
    }
    return null;
  }

  /// Reset all progress
  Future<void> resetProgress() async {
    _progress.clear();
    await _saveProgress();
    notifyListeners();
  }
}

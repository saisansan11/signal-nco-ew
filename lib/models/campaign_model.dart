import 'package:flutter/material.dart';
import '../app/constants.dart';

/// Campaign Difficulty - ระดับความยากของ Campaign
enum CampaignDifficulty {
  recruit,    // ทหารใหม่
  soldier,    // พลทหาร
  sergeant,   // จ่า
  officer,    // นายทหาร
  commander,  // ผู้บัญชาการ
}

extension CampaignDifficultyExtension on CampaignDifficulty {
  String get nameTh {
    switch (this) {
      case CampaignDifficulty.recruit:
        return 'ทหารใหม่';
      case CampaignDifficulty.soldier:
        return 'พลทหาร';
      case CampaignDifficulty.sergeant:
        return 'จ่า';
      case CampaignDifficulty.officer:
        return 'นายทหาร';
      case CampaignDifficulty.commander:
        return 'ผู้บัญชาการ';
    }
  }

  Color get color {
    switch (this) {
      case CampaignDifficulty.recruit:
        return AppColors.success;
      case CampaignDifficulty.soldier:
        return AppColors.info;
      case CampaignDifficulty.sergeant:
        return AppColors.warning;
      case CampaignDifficulty.officer:
        return AppColors.eaColor;
      case CampaignDifficulty.commander:
        return AppColors.epColor;
    }
  }

  int get starsRequired {
    switch (this) {
      case CampaignDifficulty.recruit:
        return 0;
      case CampaignDifficulty.soldier:
        return 3;
      case CampaignDifficulty.sergeant:
        return 9;
      case CampaignDifficulty.officer:
        return 18;
      case CampaignDifficulty.commander:
        return 30;
    }
  }
}

/// Mission Type - ประเภทภารกิจ
enum MissionType {
  esm,        // Electronic Support Measures
  ecm,        // Electronic Counter Measures
  eccm,       // Electronic Counter-Counter Measures
  radar,      // Radar Operations
  df,         // Direction Finding
  antiDrone,  // Counter-UAS Operations
  combined,   // Combined Operations
}

extension MissionTypeExtension on MissionType {
  String get nameTh {
    switch (this) {
      case MissionType.esm:
        return 'ESM';
      case MissionType.ecm:
        return 'ECM';
      case MissionType.eccm:
        return 'ECCM';
      case MissionType.radar:
        return 'เรดาร์';
      case MissionType.df:
        return 'หาทิศทาง';
      case MissionType.antiDrone:
        return 'ต่อต้านโดรน';
      case MissionType.combined:
        return 'ผสม';
    }
  }

  Color get color {
    switch (this) {
      case MissionType.esm:
        return AppColors.esColor;
      case MissionType.ecm:
        return AppColors.eaColor;
      case MissionType.eccm:
        return AppColors.epColor;
      case MissionType.radar:
        return AppColors.radarColor;
      case MissionType.df:
        return AppColors.info;
      case MissionType.antiDrone:
        return AppColors.droneColor;
      case MissionType.combined:
        return AppColors.primary;
    }
  }

  IconData get icon {
    switch (this) {
      case MissionType.esm:
        return Icons.search;
      case MissionType.ecm:
        return Icons.flash_on;
      case MissionType.eccm:
        return Icons.shield;
      case MissionType.radar:
        return Icons.radar;
      case MissionType.df:
        return Icons.location_searching;
      case MissionType.antiDrone:
        return Icons.flight_takeoff;
      case MissionType.combined:
        return Icons.military_tech;
    }
  }
}

/// Mission Objective - วัตถุประสงค์ภารกิจ
class MissionObjective {
  final String id;
  final String description;
  final String descriptionTh;
  final int targetValue;
  final String type; // 'detect', 'jam', 'locate', 'identify', 'survive'

  const MissionObjective({
    required this.id,
    required this.description,
    required this.descriptionTh,
    required this.targetValue,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'descriptionTh': descriptionTh,
        'targetValue': targetValue,
        'type': type,
      };

  factory MissionObjective.fromJson(Map<String, dynamic> json) =>
      MissionObjective(
        id: json['id'],
        description: json['description'],
        descriptionTh: json['descriptionTh'],
        targetValue: json['targetValue'],
        type: json['type'],
      );
}

/// Campaign Mission - ภารกิจในแคมเปญ
class CampaignMission {
  final String id;
  final String name;
  final String nameTh;
  final String description;
  final String descriptionTh;
  final String briefing;
  final MissionType type;
  final CampaignDifficulty difficulty;
  final int timeLimit; // seconds, 0 = no limit
  final int xpReward;
  final List<MissionObjective> objectives;
  final Map<String, dynamic>? simulationConfig;

  const CampaignMission({
    required this.id,
    required this.name,
    required this.nameTh,
    required this.description,
    required this.descriptionTh,
    required this.briefing,
    required this.type,
    required this.difficulty,
    this.timeLimit = 0,
    required this.xpReward,
    required this.objectives,
    this.simulationConfig,
  });

  int get maxStars => 3;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameTh': nameTh,
        'description': description,
        'descriptionTh': descriptionTh,
        'briefing': briefing,
        'type': type.index,
        'difficulty': difficulty.index,
        'timeLimit': timeLimit,
        'xpReward': xpReward,
        'objectives': objectives.map((o) => o.toJson()).toList(),
        'simulationConfig': simulationConfig,
      };

  factory CampaignMission.fromJson(Map<String, dynamic> json) =>
      CampaignMission(
        id: json['id'],
        name: json['name'],
        nameTh: json['nameTh'],
        description: json['description'],
        descriptionTh: json['descriptionTh'],
        briefing: json['briefing'],
        type: MissionType.values[json['type']],
        difficulty: CampaignDifficulty.values[json['difficulty']],
        timeLimit: json['timeLimit'] ?? 0,
        xpReward: json['xpReward'],
        objectives: (json['objectives'] as List)
            .map((o) => MissionObjective.fromJson(o))
            .toList(),
        simulationConfig: json['simulationConfig'],
      );
}

/// Campaign - แคมเปญ
class Campaign {
  final String id;
  final String name;
  final String nameTh;
  final String description;
  final String descriptionTh;
  final String storyIntro;
  final CampaignDifficulty difficulty;
  final List<CampaignMission> missions;
  final int totalXp;
  final String? imageAsset;

  const Campaign({
    required this.id,
    required this.name,
    required this.nameTh,
    required this.description,
    required this.descriptionTh,
    required this.storyIntro,
    required this.difficulty,
    required this.missions,
    required this.totalXp,
    this.imageAsset,
  });

  int get totalMissions => missions.length;
  int get maxStars => totalMissions * 3;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameTh': nameTh,
        'description': description,
        'descriptionTh': descriptionTh,
        'storyIntro': storyIntro,
        'difficulty': difficulty.index,
        'missions': missions.map((m) => m.toJson()).toList(),
        'totalXp': totalXp,
        'imageAsset': imageAsset,
      };

  factory Campaign.fromJson(Map<String, dynamic> json) => Campaign(
        id: json['id'],
        name: json['name'],
        nameTh: json['nameTh'],
        description: json['description'],
        descriptionTh: json['descriptionTh'],
        storyIntro: json['storyIntro'],
        difficulty: CampaignDifficulty.values[json['difficulty']],
        missions: (json['missions'] as List)
            .map((m) => CampaignMission.fromJson(m))
            .toList(),
        totalXp: json['totalXp'],
        imageAsset: json['imageAsset'],
      );
}

/// User Campaign Progress - ความก้าวหน้าของผู้ใช้
class UserCampaignProgress {
  final String campaignId;
  final Map<String, MissionResult> missionResults;
  bool isCompleted;
  DateTime? completedAt;

  UserCampaignProgress({
    required this.campaignId,
    Map<String, MissionResult>? missionResults,
    this.isCompleted = false,
    this.completedAt,
  }) : missionResults = missionResults ?? {};

  int get totalStars {
    return missionResults.values.fold(0, (sum, r) => sum + r.stars);
  }

  int get completedMissions {
    return missionResults.values.where((r) => r.isCompleted).length;
  }

  Map<String, dynamic> toJson() => {
        'campaignId': campaignId,
        'missionResults': missionResults
            .map((key, value) => MapEntry(key, value.toJson())),
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory UserCampaignProgress.fromJson(Map<String, dynamic> json) =>
      UserCampaignProgress(
        campaignId: json['campaignId'],
        missionResults: (json['missionResults'] as Map<String, dynamic>?)?.map(
              (key, value) =>
                  MapEntry(key, MissionResult.fromJson(value)),
            ) ??
            {},
        isCompleted: json['isCompleted'] ?? false,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
      );
}

/// Mission Result - ผลลัพธ์ภารกิจ
class MissionResult {
  final String missionId;
  int stars;
  int score;
  int timeSpent; // seconds
  bool isCompleted;
  DateTime? completedAt;
  Map<String, int> objectiveProgress;

  MissionResult({
    required this.missionId,
    this.stars = 0,
    this.score = 0,
    this.timeSpent = 0,
    this.isCompleted = false,
    this.completedAt,
    Map<String, int>? objectiveProgress,
  }) : objectiveProgress = objectiveProgress ?? {};

  Map<String, dynamic> toJson() => {
        'missionId': missionId,
        'stars': stars,
        'score': score,
        'timeSpent': timeSpent,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
        'objectiveProgress': objectiveProgress,
      };

  factory MissionResult.fromJson(Map<String, dynamic> json) => MissionResult(
        missionId: json['missionId'],
        stars: json['stars'] ?? 0,
        score: json['score'] ?? 0,
        timeSpent: json['timeSpent'] ?? 0,
        isCompleted: json['isCompleted'] ?? false,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
        objectiveProgress:
            Map<String, int>.from(json['objectiveProgress'] ?? {}),
      );
}

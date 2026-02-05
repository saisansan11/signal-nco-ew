import 'package:flutter/material.dart';

/// Achievement Tier - ระดับความยากของรางวัล
enum AchievementTier {
  bronze,   // ง่าย
  silver,   // ปานกลาง
  gold,     // ยาก
  platinum, // ยากมาก
  diamond,  // พิเศษ
}

extension AchievementTierExtension on AchievementTier {
  String get nameTh {
    switch (this) {
      case AchievementTier.bronze:
        return 'ทองแดง';
      case AchievementTier.silver:
        return 'เงิน';
      case AchievementTier.gold:
        return 'ทอง';
      case AchievementTier.platinum:
        return 'แพลตินัม';
      case AchievementTier.diamond:
        return 'เพชร';
    }
  }

  Color get color {
    switch (this) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.platinum:
        return const Color(0xFF7FDBFF);
      case AchievementTier.diamond:
        return const Color(0xFFB9F2FF);
    }
  }

  int get xpMultiplier {
    switch (this) {
      case AchievementTier.bronze:
        return 1;
      case AchievementTier.silver:
        return 2;
      case AchievementTier.gold:
        return 3;
      case AchievementTier.platinum:
        return 5;
      case AchievementTier.diamond:
        return 10;
    }
  }
}

/// Achievement Category - หมวดหมู่รางวัล
enum AchievementCategory {
  learning,     // การเรียนรู้
  simulation,   // การจำลอง
  quiz,         // แบบทดสอบ
  streak,       // ความต่อเนื่อง
  mastery,      // ความเชี่ยวชาญ
  campaign,     // ภารกิจ
  special,      // พิเศษ
}

extension AchievementCategoryExtension on AchievementCategory {
  String get nameTh {
    switch (this) {
      case AchievementCategory.learning:
        return 'การเรียนรู้';
      case AchievementCategory.simulation:
        return 'การจำลอง';
      case AchievementCategory.quiz:
        return 'แบบทดสอบ';
      case AchievementCategory.streak:
        return 'ความต่อเนื่อง';
      case AchievementCategory.mastery:
        return 'ความเชี่ยวชาญ';
      case AchievementCategory.campaign:
        return 'ภารกิจ';
      case AchievementCategory.special:
        return 'พิเศษ';
    }
  }

  IconData get icon {
    switch (this) {
      case AchievementCategory.learning:
        return Icons.school;
      case AchievementCategory.simulation:
        return Icons.radar;
      case AchievementCategory.quiz:
        return Icons.quiz;
      case AchievementCategory.streak:
        return Icons.local_fire_department;
      case AchievementCategory.mastery:
        return Icons.military_tech;
      case AchievementCategory.campaign:
        return Icons.flag;
      case AchievementCategory.special:
        return Icons.star;
    }
  }
}

/// Achievement Model - โมเดลรางวัล
class Achievement {
  final String id;
  final String title;
  final String titleTh;
  final String description;
  final String descriptionTh;
  final String icon; // emoji หรือ icon name
  final AchievementTier tier;
  final AchievementCategory category;
  final int xpReward;
  final int targetValue; // เป้าหมายที่ต้องทำ
  final String? imagePath; // path to badge image

  const Achievement({
    required this.id,
    required this.title,
    required this.titleTh,
    required this.description,
    required this.descriptionTh,
    required this.icon,
    required this.tier,
    required this.category,
    required this.xpReward,
    this.targetValue = 1,
    this.imagePath,
  });

  int get totalXp => xpReward * tier.xpMultiplier;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'titleTh': titleTh,
        'description': description,
        'descriptionTh': descriptionTh,
        'icon': icon,
        'tier': tier.index,
        'category': category.index,
        'xpReward': xpReward,
        'targetValue': targetValue,
        'imagePath': imagePath,
      };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'],
        title: json['title'],
        titleTh: json['titleTh'],
        description: json['description'],
        descriptionTh: json['descriptionTh'],
        icon: json['icon'],
        tier: AchievementTier.values[json['tier']],
        category: AchievementCategory.values[json['category']],
        xpReward: json['xpReward'],
        targetValue: json['targetValue'] ?? 1,
        imagePath: json['imagePath'],
      );
}

/// User Achievement Progress - ความก้าวหน้าของผู้ใช้ในแต่ละรางวัล
class UserAchievementProgress {
  final String achievementId;
  int currentValue;
  bool isUnlocked;
  DateTime? unlockedAt;

  UserAchievementProgress({
    required this.achievementId,
    this.currentValue = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  double get progress => currentValue / 1; // Will be calculated with achievement targetValue

  Map<String, dynamic> toJson() => {
        'achievementId': achievementId,
        'currentValue': currentValue,
        'isUnlocked': isUnlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  factory UserAchievementProgress.fromJson(Map<String, dynamic> json) =>
      UserAchievementProgress(
        achievementId: json['achievementId'],
        currentValue: json['currentValue'] ?? 0,
        isUnlocked: json['isUnlocked'] ?? false,
        unlockedAt: json['unlockedAt'] != null
            ? DateTime.parse(json['unlockedAt'])
            : null,
      );
}

// Class Statistics Screen
// Shows overall class statistics and analytics for teachers

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../app/constants.dart';

class ClassStatsScreen extends StatelessWidget {
  const ClassStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'สถิติภาพรวมชั้นเรียน',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'student')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text(
                    'ยังไม่มีข้อมูลนักเรียน',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          final students = snapshot.data!.docs;
          return _StatsContent(students: students);
        },
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  final List<QueryDocumentSnapshot> students;

  const _StatsContent({required this.students});

  @override
  Widget build(BuildContext context) {
    // Calculate statistics
    final totalStudents = students.length;
    int totalXP = 0;
    int totalLessons = 0;
    int totalQuizzes = 0;
    int activeToday = 0;
    int activeThisWeek = 0;
    int totalAchievements = 0;
    int maxStreak = 0;
    double totalAvgScore = 0;
    int scoreCount = 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));

    final xpDistribution = <int, int>{};
    final levelDistribution = <int, int>{};

    for (final doc in students) {
      final data = doc.data() as Map<String, dynamic>;

      final xp = (data['totalXP'] as int?) ?? 0;
      totalXP += xp;

      final level = (xp / 100).floor() + 1;
      levelDistribution[level] = (levelDistribution[level] ?? 0) + 1;

      // XP distribution by ranges
      final xpRange = (xp / 500).floor() * 500;
      xpDistribution[xpRange] = (xpDistribution[xpRange] ?? 0) + 1;

      totalLessons += (data['lessonsCompleted'] as int?) ?? 0;
      totalQuizzes += (data['quizzesPassed'] as int?) ?? 0;
      totalAchievements += (data['achievementsUnlocked'] as int?) ?? 0;

      final streak = (data['longestStreak'] as int?) ?? 0;
      if (streak > maxStreak) maxStreak = streak;

      final avgScore = (data['averageQuizScore'] as num?)?.toDouble() ?? 0;
      if (avgScore > 0) {
        totalAvgScore += avgScore;
        scoreCount++;
      }

      final lastActive = data['lastActiveDate'] as Timestamp?;
      if (lastActive != null) {
        final lastDate = lastActive.toDate();
        if (lastDate.isAfter(today) ||
            (lastDate.year == today.year &&
                lastDate.month == today.month &&
                lastDate.day == today.day)) {
          activeToday++;
        }
        if (lastDate.isAfter(weekAgo)) {
          activeThisWeek++;
        }
      }
    }

    final avgXP = totalStudents > 0 ? (totalXP / totalStudents).round() : 0;
    final avgLessons = totalStudents > 0 ? (totalLessons / totalStudents).round() : 0;
    final avgQuizzes = totalStudents > 0 ? (totalQuizzes / totalStudents).round() : 0;
    final classAvgScore = scoreCount > 0 ? (totalAvgScore / scoreCount).round() : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Cards
          Text(
            'ภาพรวม',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _OverviewCard(
                  icon: Icons.people,
                  label: 'นักเรียนทั้งหมด',
                  value: '$totalStudents',
                  color: AppColors.primary,
                ).animate(delay: 50.ms).fadeIn().slideY(begin: 0.1),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OverviewCard(
                  icon: Icons.today,
                  label: 'ใช้งานวันนี้',
                  value: '$activeToday',
                  color: AppColors.success,
                ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _OverviewCard(
                  icon: Icons.date_range,
                  label: 'ใช้งานสัปดาห์นี้',
                  value: '$activeThisWeek',
                  color: AppColors.info,
                ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.1),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OverviewCard(
                  icon: Icons.bolt,
                  label: 'XP รวม',
                  value: _formatNumber(totalXP),
                  color: AppColors.warning,
                ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Average Stats
          Text(
            'ค่าเฉลี่ย',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ).animate(delay: 250.ms).fadeIn(),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _AverageRow(
                  icon: Icons.bolt,
                  label: 'XP เฉลี่ย/คน',
                  value: '$avgXP XP',
                  color: AppColors.warning,
                ),
                const Divider(color: AppColors.border),
                _AverageRow(
                  icon: Icons.school,
                  label: 'บทเรียนเฉลี่ย/คน',
                  value: '$avgLessons บท',
                  color: AppColors.primary,
                ),
                const Divider(color: AppColors.border),
                _AverageRow(
                  icon: Icons.quiz,
                  label: 'แบบทดสอบเฉลี่ย/คน',
                  value: '$avgQuizzes ข้อ',
                  color: AppColors.success,
                ),
                const Divider(color: AppColors.border),
                _AverageRow(
                  icon: Icons.score,
                  label: 'คะแนนเฉลี่ยชั้นเรียน',
                  value: '$classAvgScore%',
                  color: AppColors.info,
                ),
              ],
            ),
          ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1),

          const SizedBox(height: 24),

          // Totals
          Text(
            'สรุปรวม',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ).animate(delay: 350.ms).fadeIn(),
          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _TotalChip(
                icon: Icons.school,
                label: 'บทเรียนที่เรียน',
                value: '$totalLessons',
                color: AppColors.primary,
              ).animate(delay: 400.ms).fadeIn().scale(begin: const Offset(0.9, 0.9)),
              _TotalChip(
                icon: Icons.quiz,
                label: 'แบบทดสอบที่ผ่าน',
                value: '$totalQuizzes',
                color: AppColors.success,
              ).animate(delay: 450.ms).fadeIn().scale(begin: const Offset(0.9, 0.9)),
              _TotalChip(
                icon: Icons.emoji_events,
                label: 'เหรียญที่ได้',
                value: '$totalAchievements',
                color: AppColors.warning,
              ).animate(delay: 500.ms).fadeIn().scale(begin: const Offset(0.9, 0.9)),
              _TotalChip(
                icon: Icons.local_fire_department,
                label: 'Streak สูงสุด',
                value: '$maxStreak วัน',
                color: AppColors.error,
              ).animate(delay: 550.ms).fadeIn().scale(begin: const Offset(0.9, 0.9)),
            ],
          ),

          const SizedBox(height: 24),

          // Level Distribution
          Text(
            'การกระจายตามเลเวล',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ).animate(delay: 600.ms).fadeIn(),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: _buildLevelDistribution(levelDistribution, totalStudents),
            ),
          ).animate(delay: 650.ms).fadeIn().slideY(begin: 0.1),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<Widget> _buildLevelDistribution(
    Map<int, int> distribution,
    int total,
  ) {
    final sortedKeys = distribution.keys.toList()..sort();
    final widgets = <Widget>[];

    for (int i = 0; i < sortedKeys.length; i++) {
      final level = sortedKeys[i];
      final count = distribution[level] ?? 0;
      final percentage = total > 0 ? (count / total * 100) : 0.0;

      widgets.add(_LevelBar(
        level: level,
        count: count,
        percentage: percentage,
      ));

      if (i < sortedKeys.length - 1) {
        widgets.add(const SizedBox(height: 8));
      }
    }

    if (widgets.isEmpty) {
      widgets.add(
        Center(
          child: Text(
            'ยังไม่มีข้อมูล',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return '$number';
  }
}

class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _OverviewCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AverageRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _AverageRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _TotalChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.titleSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: color.withAlpha(180),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelBar extends StatelessWidget {
  final int level;
  final int count;
  final double percentage;

  const _LevelBar({
    required this.level,
    required this.count,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            'Lv.$level',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (percentage / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withAlpha(180),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 60,
          child: Text(
            '$count คน',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

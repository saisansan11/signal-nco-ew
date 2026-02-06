// Student Detail Screen
// Shows detailed information about a specific student for teachers

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../app/constants.dart';

class StudentDetailScreen extends StatelessWidget {
  final String studentUid;
  final String studentName;

  const StudentDetailScreen({
    super.key,
    required this.studentUid,
    required this.studentName,
  });

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
        title: Text(
          studentName,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(studentUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text(
                    'ไม่พบข้อมูลนักเรียน',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          return _StudentDetailContent(data: data);
        },
      ),
    );
  }
}

class _StudentDetailContent extends StatelessWidget {
  final Map<String, dynamic> data;

  const _StudentDetailContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final displayName = data['displayName'] ?? 'ไม่ระบุชื่อ';
    final email = data['email'] ?? '';
    final totalXP = (data['totalXP'] as int?) ?? 0;
    final level = (totalXP / 100).floor() + 1;
    final currentStreak = (data['currentStreak'] as int?) ?? 0;
    final longestStreak = (data['longestStreak'] as int?) ?? 0;
    final lessonsCompleted = (data['lessonsCompleted'] as int?) ?? 0;
    final quizzesPassed = (data['quizzesPassed'] as int?) ?? 0;
    final flashcardsStudied = (data['flashcardsStudied'] as int?) ?? 0;
    final achievementsUnlocked = (data['achievementsUnlocked'] as int?) ?? 0;
    final lastActiveDate = data['lastActiveDate'] as Timestamp?;
    final createdAt = data['createdAt'] as Timestamp?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.seniorNco.withAlpha(30),
                  AppColors.juniorNco.withAlpha(20),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              border: Border.all(color: AppColors.seniorNco.withAlpha(50)),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: AppColors.seniorNcoGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _MiniStatBadge(
                            icon: Icons.star,
                            value: 'Lv.$level',
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 8),
                          _MiniStatBadge(
                            icon: Icons.bolt,
                            value: '$totalXP XP',
                            color: AppColors.primary,
                          ),
                          if (currentStreak > 0) ...[
                            const SizedBox(width: 8),
                            _MiniStatBadge(
                              icon: Icons.local_fire_department,
                              value: '$currentStreak',
                              color: AppColors.error,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1),

          const SizedBox(height: 24),

          // Stats Grid
          Text(
            'สถิติการเรียน',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 12),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _StatCard(
                icon: Icons.school,
                label: 'บทเรียนที่เรียนจบ',
                value: '$lessonsCompleted',
                color: AppColors.primary,
              ).animate(delay: 150.ms).fadeIn().scale(begin: const Offset(0.9, 0.9)),
              _StatCard(
                icon: Icons.quiz,
                label: 'แบบทดสอบที่ผ่าน',
                value: '$quizzesPassed',
                color: AppColors.success,
              ).animate(delay: 200.ms).fadeIn().scale(begin: const Offset(0.9, 0.9)),
              _StatCard(
                icon: Icons.style,
                label: 'บัตรคำที่ศึกษา',
                value: '$flashcardsStudied',
                color: AppColors.esColor,
              ).animate(delay: 250.ms).fadeIn().scale(begin: const Offset(0.9, 0.9)),
              _StatCard(
                icon: Icons.emoji_events,
                label: 'เหรียญที่ได้รับ',
                value: '$achievementsUnlocked',
                color: AppColors.warning,
              ).animate(delay: 300.ms).fadeIn().scale(begin: const Offset(0.9, 0.9)),
            ],
          ),

          const SizedBox(height: 24),

          // Streak Info
          Text(
            'Streak',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ).animate(delay: 350.ms).fadeIn(),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _StreakItem(
                    icon: Icons.local_fire_department,
                    label: 'Streak ปัจจุบัน',
                    value: '$currentStreak วัน',
                    color: AppColors.error,
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: AppColors.border,
                ),
                Expanded(
                  child: _StreakItem(
                    icon: Icons.emoji_events,
                    label: 'Streak สูงสุด',
                    value: '$longestStreak วัน',
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1),

          const SizedBox(height: 24),

          // Activity Info
          Text(
            'ข้อมูลการใช้งาน',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ).animate(delay: 450.ms).fadeIn(),
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
                _InfoRow(
                  icon: Icons.access_time,
                  label: 'ใช้งานล่าสุด',
                  value: lastActiveDate != null
                      ? _formatDate(lastActiveDate.toDate())
                      : 'ไม่ทราบ',
                ),
                const Divider(color: AppColors.border),
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'วันที่สมัคร',
                  value: createdAt != null
                      ? _formatDate(createdAt.toDate())
                      : 'ไม่ทราบ',
                ),
              ],
            ),
          ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.1),

          const SizedBox(height: 24),

          // Recent Activity
          Text(
            'กิจกรรมล่าสุด',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ).animate(delay: 550.ms).fadeIn(),
          const SizedBox(height: 12),

          _RecentActivityList(studentUid: data['uid'] ?? ''),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'วันนี้';
    } else if (diff.inDays == 1) {
      return 'เมื่อวาน';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} วันที่แล้ว';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _MiniStatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _MiniStatBadge({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
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
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Text(
                value,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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

class _StreakItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StreakItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  final String studentUid;

  const _RecentActivityList({required this.studentUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('activity_log')
          .where('userId', isEqualTo: studentUid)
          .orderBy('timestamp', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.history, size: 40, color: AppColors.textMuted),
                  const SizedBox(height: 8),
                  Text(
                    'ยังไม่มีกิจกรรม',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final activities = snapshot.data!.docs;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (_, index) => const Divider(
              color: AppColors.border,
              height: 1,
            ),
            itemBuilder: (context, index) {
              final activity = activities[index].data() as Map<String, dynamic>;
              return _ActivityTile(activity: activity);
            },
          ),
        );
      },
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final Map<String, dynamic> activity;

  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final type = activity['type'] ?? activity['activityType'] ?? '';
    final timestamp = activity['timestamp'] as Timestamp?;
    final detail = activity['details'] ?? activity['detail'] ?? '';

    IconData icon;
    Color color;
    String title;

    switch (type) {
      case 'lesson_completed':
        icon = Icons.check_circle;
        color = AppColors.success;
        title = 'เรียนจบบทเรียน';
        break;
      case 'quiz_passed':
        icon = Icons.quiz;
        color = AppColors.info;
        title = 'ผ่านแบบทดสอบ';
        break;
      case 'achievement_unlocked':
        icon = Icons.emoji_events;
        color = AppColors.warning;
        title = 'ปลดล็อกเหรียญ';
        break;
      case 'level_up':
        icon = Icons.arrow_upward;
        color = AppColors.seniorNco;
        title = 'เลเวลอัพ';
        break;
      case 'flashcard_studied':
        icon = Icons.style;
        color = AppColors.esColor;
        title = 'ศึกษาบัตรคำ';
        break;
      default:
        icon = Icons.circle;
        color = AppColors.textMuted;
        title = type;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (detail.isNotEmpty)
                  Text(
                    detail,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (timestamp != null)
            Text(
              _formatTime(timestamp.toDate()),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'เมื่อกี้';
    if (diff.inMinutes < 60) return '${diff.inMinutes} นาที';
    if (diff.inHours < 24) return '${diff.inHours} ชม.';
    if (diff.inDays < 7) return '${diff.inDays} วัน';
    return '${time.day}/${time.month}';
  }
}

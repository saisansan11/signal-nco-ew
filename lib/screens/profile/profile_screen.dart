import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../app/constants.dart';
import '../../models/curriculum_models.dart';
import '../../models/progress_models.dart';
import '../../services/auth_service.dart';
import '../../services/progress_service.dart';
import '../progress/progress_dashboard_screen.dart';
import '../teacher/teacher_dashboard_screen.dart';

/// Profile Screen - User-friendly for all ages
/// Features: Greeting, Daily Goals, Achievements, Quick Actions, Settings
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _motivationController;

  @override
  void initState() {
    super.initState();
    _motivationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _motivationController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'สวัสดีตอนเช้า';
    } else if (hour < 17) {
      return 'สวัสดีตอนบ่าย';
    } else {
      return 'สวัสดีตอนเย็น';
    }
  }

  String _getMotivationalMessage() {
    final messages = [
      'ความรู้คือพลัง!',
      'ฝึกฝนทุกวัน ก้าวหน้าทุกวัน',
      'การเรียนรู้ไม่มีวันสิ้นสุด',
      'เก่งขึ้นได้ทุกวัน!',
      'สู้ๆ นะครับ!',
    ];
    return messages[DateTime.now().day % messages.length];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressService>(
      builder: (context, progressService, child) {
        final progress = progressService.progress;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting Section
                  _buildGreetingSection(progress),

                  const SizedBox(height: 24),

                  // Daily Goals Section
                  _DailyGoalCard(
                    dailyGoals: progress.dailyGoals,
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),

                  const SizedBox(height: 24),

                  // Achievement Showcase
                  _AchievementShowcase(
                    level: progress.level,
                    totalXp: progress.totalXP,
                    streak: progress.currentStreak,
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions(context),

                  const SizedBox(height: 24),

                  // Settings Section
                  _buildSettingsSection(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGreetingSection(UserProgress progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with animation
          AnimatedBuilder(
            animation: _motivationController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_motivationController.value * 0.05),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ระดับ ${progress.level} • ${progress.totalXP} XP',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getMotivationalMessage(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'การดำเนินการด่วน',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.school,
                label: 'เรียนต่อ',
                color: AppColors.esColor,
                onTap: () {
                  // Navigate to lessons
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.quiz,
                label: 'ทำแบบทดสอบ',
                color: AppColors.eaColor,
                onTap: () {
                  // Navigate to quiz
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.style,
                label: 'Flashcards',
                color: AppColors.epColor,
                onTap: () {
                  // Navigate to flashcards
                },
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ตั้งค่า',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            children: [
              // สถิติการเรียนละเอียด
              _SettingsTile(
                icon: Icons.bar_chart,
                title: 'สถิติการเรียนละเอียด',
                subtitle: 'ดูความก้าวหน้าทั้งหมด',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProgressDashboardScreen(),
                  ),
                ),
              ),
              const Divider(height: 1, indent: 56),

              // Dashboard ครู - แสดงเฉพาะครูเท่านั้น
              FutureBuilder<bool>(
                future: AuthService().isCurrentUserTeacher(),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.dashboard,
                          title: 'Dashboard ครู',
                          subtitle: 'ดูข้อมูลนักเรียนทั้งหมด',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TeacherDashboardScreen(),
                            ),
                          ),
                        ),
                        const Divider(height: 1, indent: 56),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // เปลี่ยนระดับ
              _SettingsTile(
                icon: Icons.swap_horiz,
                title: 'เปลี่ยนระดับ',
                subtitle: 'สลับระหว่างนายสิบชั้นต้น/อาวุโส',
                onTap: () => _showLevelChangeDialog(context),
              ),
              const Divider(height: 1, indent: 56),

              // รีเซ็ตความก้าวหน้า
              _SettingsTile(
                icon: Icons.refresh,
                title: 'รีเซ็ตความก้าวหน้า',
                subtitle: 'เริ่มต้นใหม่ทั้งหมด',
                onTap: () => _showResetDialog(context),
              ),
              const Divider(height: 1, indent: 56),

              _SettingsTile(
                icon: Icons.info_outline,
                title: 'เกี่ยวกับแอป',
                subtitle: 'เวอร์ชัน 1.0.0',
                onTap: () => _showAboutDialog(context),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  void _showLevelChangeDialog(BuildContext context) {
    final progressService = Provider.of<ProgressService>(context, listen: false);
    final currentLevel = progressService.currentLevel;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Text(
          'เปลี่ยนระดับ',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'เลือกระดับที่ต้องการศึกษา',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _LevelOption(
              title: 'นายสิบชั้นต้น',
              subtitle: 'พื้นฐาน EW สำหรับผู้เริ่มต้น',
              isSelected: currentLevel == NCOLevel.junior,
              color: AppColors.juniorNco,
              onTap: () {
                progressService.setNCOLevel(NCOLevel.junior);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _LevelOption(
              title: 'นายสิบอาวุโส',
              subtitle: 'เนื้อหาขั้นสูงสำหรับผู้มีประสบการณ์',
              isSelected: currentLevel == NCOLevel.senior,
              color: AppColors.seniorNco,
              onTap: () {
                progressService.setNCOLevel(NCOLevel.senior);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ยกเลิก',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: AppColors.warning),
            const SizedBox(width: 8),
            Text(
              'รีเซ็ตความก้าวหน้า',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'การดำเนินการนี้จะลบข้อมูลความก้าวหน้าทั้งหมด รวมถึง:\n\n'
          '• บทเรียนที่เรียนไปแล้ว\n'
          '• คะแนนแบบทดสอบ\n'
          '• XP และ Streak\n'
          '• ความสำเร็จที่ได้รับ\n\n'
          'คุณแน่ใจหรือไม่?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ยกเลิก',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<ProgressService>(context, listen: false).resetProgress();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('รีเซ็ตความก้าวหน้าเรียบร้อยแล้ว'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('รีเซ็ต', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.radar, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Signal NCO EW',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'แอปพลิเคชันฝึกอบรมสงครามอิเล็กทรอนิกส์\nสำหรับนายสิบเหล่าทหารสื่อสาร',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _AboutItem(label: 'เวอร์ชัน', value: '1.0.0'),
            _AboutItem(label: 'พัฒนาโดย', value: 'ร.ต. วสันต์ ทัศนามล'),
            _AboutItem(label: 'หน่วย', value: 'โรงเรียนทหารสื่อสาร'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ปิด',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _LevelOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.2) : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.military_tech,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: isSelected ? color : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: color, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutItem extends StatelessWidget {
  final String label;
  final String value;

  const _AboutItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Daily Goal Card - Shows progress on lessons, quizzes, flashcards
class _DailyGoalCard extends StatelessWidget {
  final DailyGoals dailyGoals;

  const _DailyGoalCard({required this.dailyGoals});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'เป้าหมายวันนี้',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: dailyGoals.isCompleted
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  dailyGoals.isCompleted ? 'สำเร็จแล้ว!' : 'กำลังดำเนินการ',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: dailyGoals.isCompleted
                        ? AppColors.success
                        : AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: dailyGoals.progress,
              minHeight: 12,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                dailyGoals.isCompleted ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(dailyGoals.progress * 100).toInt()}% เสร็จสิ้น',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 20),

          // Individual goals
          _GoalItem(
            icon: Icons.menu_book,
            label: 'บทเรียน',
            completed: dailyGoals.lessonsCompleted,
            target: dailyGoals.lessonsTarget,
            color: AppColors.esColor,
          ),
          const SizedBox(height: 12),
          _GoalItem(
            icon: Icons.quiz,
            label: 'แบบทดสอบ',
            completed: dailyGoals.quizzesTaken,
            target: dailyGoals.quizzesTarget,
            color: AppColors.eaColor,
          ),
          const SizedBox(height: 12),
          _GoalItem(
            icon: Icons.style,
            label: 'Flashcards',
            completed: dailyGoals.flashcardsStudied,
            target: dailyGoals.flashcardsTarget,
            color: AppColors.epColor,
          ),
        ],
      ),
    );
  }
}

class _GoalItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int completed;
  final int target;
  final Color color;

  const _GoalItem({
    required this.icon,
    required this.label,
    required this.completed,
    required this.target,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = completed >= target;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          '$completed / $target',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isCompleted ? AppColors.success : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? AppColors.success : AppColors.textSecondary,
          size: 20,
        ),
      ],
    );
  }
}

/// Achievement Showcase - Shows level, XP, streak
class _AchievementShowcase extends StatelessWidget {
  final int level;
  final int totalXp;
  final int streak;

  const _AchievementShowcase({
    required this.level,
    required this.totalXp,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ความสำเร็จ',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _AchievementCard(
                icon: Icons.military_tech,
                label: 'ระดับ',
                value: level.toString(),
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AchievementCard(
                icon: Icons.star,
                label: 'XP รวม',
                value: _formatXp(totalXp),
                color: AppColors.esColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AchievementCard(
                icon: Icons.local_fire_department,
                label: 'Streak',
                value: '$streak วัน',
                color: AppColors.eaColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatXp(int xp) {
    if (xp >= 1000) {
      return '${(xp / 1000).toStringAsFixed(1)}K';
    }
    return xp.toString();
  }
}

class _AchievementCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _AchievementCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick Action Button
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Settings Tile
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}

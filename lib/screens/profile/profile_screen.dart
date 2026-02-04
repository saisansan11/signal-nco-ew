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

/// หน้า Profile ที่เป็นมิตรกับผู้ใช้ทุกช่วงอายุ
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
      duration: const Duration(seconds: 3),
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

  String _getMotivationalMessage(int streak, int level) {
    if (streak >= 7) {
      return 'ยอดเยี่ยม! เรียนต่อเนื่อง $streak วันแล้ว';
    } else if (streak >= 3) {
      return 'เก่งมาก! รักษา streak ไว้นะ';
    } else if (level >= 5) {
      return 'คุณกำลังก้าวหน้าอย่างดี!';
    } else {
      return 'เรียนรู้ทุกวัน พัฒนาทุกวัน';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressService>(
      builder: (context, progressService, child) {
        final level = progressService.currentLevel;
        final xp = progressService.totalXP;
        final userLevel = progressService.level;
        final streak = progressService.currentStreak;
        final progress = progressService.progress;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              children: [
                // Welcome Header with greeting
                _buildWelcomeHeader(level, userLevel, streak),

                const SizedBox(height: AppSizes.paddingL),

                // Stats Overview with animations
                _buildStatsOverview(xp, userLevel, streak, progressService),

                const SizedBox(height: AppSizes.paddingL),

                // Daily Goal Progress
                _DailyGoalCard(progressService: progressService)
                    .animate(delay: 300.ms)
                    .fadeIn()
                    .slideY(begin: 0.2),

                const SizedBox(height: AppSizes.paddingL),

                // Quick Actions
                _buildQuickActions(context),

                const SizedBox(height: AppSizes.paddingL),

                // Achievement Showcase
                _AchievementShowcase(progress: progress)
                    .animate(delay: 500.ms)
                    .fadeIn()
                    .slideY(begin: 0.2),

                const SizedBox(height: AppSizes.paddingL),

                // Settings & Options
                _buildSettingsSection(context, level),

                const SizedBox(height: AppSizes.paddingXL),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeHeader(NCOLevel level, int userLevel, int streak) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: level == NCOLevel.junior
            ? AppColors.juniorNcoGradient
            : AppColors.seniorNcoGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: (level == NCOLevel.junior
                    ? AppColors.juniorNco
                    : AppColors.seniorNco)
                .withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with rank badge
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withAlpha(100),
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  )
                      .animate(
                        onPlay: (c) => c.repeat(reverse: true),
                      )
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.05, 1.05),
                        duration: 2.seconds,
                      ),
                  // Level badge
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.warning.withAlpha(100),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        'Lv.$userLevel',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSizes.paddingL),

              // Greeting and name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white.withAlpha(200),
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: 4),
                    Text(
                      level.titleTh,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.1),
                    const SizedBox(height: 2),
                    Text(
                      'เหล่าทหารสื่อสาร',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withAlpha(180),
                      ),
                    ).animate(delay: 200.ms).fadeIn(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),

          // Motivational message
          AnimatedBuilder(
            animation: _motivationController,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                  vertical: AppSizes.paddingS,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(
                      (20 + (_motivationController.value * 15)).toInt()),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      streak >= 7
                          ? Icons.local_fire_department
                          : Icons.emoji_emotions,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _getMotivationalMessage(streak, userLevel),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }

  Widget _buildStatsOverview(
      int xp, int userLevel, int streak, ProgressService service) {
    final xpToNextLevel = 500 - (xp % 500);

    return Row(
      children: [
        Expanded(
          child: _AnimatedStatCard(
            icon: Icons.bolt_rounded,
            value: '$xp',
            label: 'XP สะสม',
            color: AppColors.primary,
            subtitle: 'อีก $xpToNextLevel ถึง Lv.${userLevel + 1}',
            delay: 100.ms,
          ),
        ),
        const SizedBox(width: AppSizes.paddingM),
        Expanded(
          child: _AnimatedStatCard(
            icon: Icons.local_fire_department_rounded,
            value: '$streak',
            label: 'วันติดต่อกัน',
            color: AppColors.error,
            subtitle: streak > 0 ? 'รักษา streak ไว้!' : 'เริ่มต้นวันนี้!',
            delay: 200.ms,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ทางลัด',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ).animate(delay: 400.ms).fadeIn(),
        const SizedBox(height: AppSizes.paddingM),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.bar_chart_rounded,
                label: 'สถิติละเอียด',
                color: AppColors.success,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProgressDashboardScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.quiz_rounded,
                label: 'ทดสอบตัวเอง',
                color: AppColors.primary,
                onTap: () {
                  // Go to quiz tab
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ),
          ],
        ).animate(delay: 450.ms).fadeIn().slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, NCOLevel currentLevel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: CardDecoration.standard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_rounded, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Text(
                'ตั้งค่า',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          // Teacher dashboard (conditional)
          FutureBuilder<bool>(
            future: AuthService().isCurrentUserTeacher(),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return _SettingsTile(
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard ครู',
                  subtitle: 'จัดการนักเรียนและดูสถิติ',
                  color: AppColors.primary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TeacherDashboardScreen(),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          _SettingsTile(
            icon: Icons.swap_horiz_rounded,
            title: 'เปลี่ยนระดับ',
            subtitle: currentLevel == NCOLevel.junior
                ? 'ปัจจุบัน: นายสิบชั้นต้น'
                : 'ปัจจุบัน: นายสิบอาวุโส',
            color: AppColors.warning,
            onTap: () => _showLevelChangeDialog(context),
          ),
          _SettingsTile(
            icon: Icons.text_fields_rounded,
            title: 'ขนาดตัวอักษร',
            subtitle: 'ปรับให้อ่านง่ายขึ้น',
            color: AppColors.accentBlue,
            onTap: () => _showFontSizeDialog(context),
          ),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            title: 'วิธีใช้งาน',
            subtitle: 'ดูคำแนะนำการใช้แอพ',
            color: AppColors.success,
            onTap: () => _showHelpDialog(context),
          ),
          _SettingsTile(
            icon: Icons.refresh_rounded,
            title: 'รีเซ็ตความก้าวหน้า',
            subtitle: 'เริ่มต้นใหม่ทั้งหมด',
            color: AppColors.error,
            onTap: () => _showResetDialog(context),
          ),
        ],
      ),
    ).animate(delay: 600.ms).fadeIn(duration: 300.ms);
  }

  void _showLevelChangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Row(
          children: [
            const Icon(Icons.swap_horiz, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'เปลี่ยนระดับ',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LevelOptionCard(
              level: NCOLevel.junior,
              description: 'บทที่ 0-7 พื้นฐาน',
              onTap: () {
                context.read<ProgressService>().setNCOLevel(NCOLevel.junior);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: AppSizes.paddingM),
            _LevelOptionCard(
              level: NCOLevel.senior,
              description: 'บทที่ 8-18 ขั้นสูง',
              onTap: () {
                context.read<ProgressService>().setNCOLevel(NCOLevel.senior);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Row(
          children: [
            const Icon(Icons.text_fields, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'ขนาดตัวอักษร',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ฟีเจอร์นี้กำลังพัฒนา',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'คุณสามารถปรับขนาดตัวอักษรผ่านการตั้งค่าระบบของอุปกรณ์ได้',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Row(
          children: [
            const Icon(Icons.help_outline, color: AppColors.success),
            const SizedBox(width: 8),
            Text(
              'วิธีใช้งาน',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HelpItem(
              icon: Icons.school,
              title: 'บทเรียน',
              description: 'เรียนรู้ทฤษฎีและดู animation ประกอบ',
            ),
            _HelpItem(
              icon: Icons.radar,
              title: 'จำลอง',
              description: 'ฝึกปฏิบัติกับการจำลองแบบโต้ตอบ',
            ),
            _HelpItem(
              icon: Icons.quiz,
              title: 'แบบทดสอบ',
              description: 'ทดสอบความรู้ด้วยคำถามหลากหลาย',
            ),
            _HelpItem(
              icon: Icons.local_fire_department,
              title: 'Streak',
              description: 'เรียนทุกวันเพื่อรักษา streak',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('เข้าใจแล้ว'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            Text(
              'รีเซ็ตความก้าวหน้า?',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(20),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ข้อมูลต่อไปนี้จะถูกลบ:\n• XP และ Level\n• Streak\n• ผลการเรียนทั้งหมด',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              context.read<ProgressService>().resetProgress();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('รีเซ็ตเรียบร้อยแล้ว'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('รีเซ็ต'),
          ),
        ],
      ),
    );
  }
}

// Animated stat card with pulse effect
class _AnimatedStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final String subtitle;
  final Duration delay;

  const _AnimatedStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.subtitle,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32)
              .animate(
                onPlay: (c) => c.repeat(reverse: true),
              )
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 1500.ms,
              ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.labelSmall.copyWith(
              color: color.withAlpha(180),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate(delay: delay).fadeIn(duration: 300.ms).slideY(begin: 0.2);
  }
}

// Daily goal card - shows daily learning goals progress
class _DailyGoalCard extends StatelessWidget {
  final ProgressService progressService;

  const _DailyGoalCard({required this.progressService});

  @override
  Widget build(BuildContext context) {
    final dailyGoals = progressService.progress.dailyGoals;
    final progress = dailyGoals.progress.clamp(0.0, 1.0);
    final isCompleted = dailyGoals.isCompleted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: isCompleted
            ? LinearGradient(
                colors: [
                  AppColors.success.withAlpha(40),
                  AppColors.success.withAlpha(20),
                ],
              )
            : null,
        color: isCompleted ? null : AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: isCompleted
              ? AppColors.success.withAlpha(60)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success.withAlpha(40)
                      : AppColors.primary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.flag_rounded,
                  color: isCompleted ? AppColors.success : AppColors.primary,
                  size: 24,
                ),
              )
                  .animate(
                    onPlay: (c) => isCompleted ? c.repeat(reverse: true) : null,
                  )
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.15, 1.15),
                    duration: 1.seconds,
                  ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCompleted ? 'เป้าหมายวันนี้สำเร็จ!' : 'เป้าหมายวันนี้',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isCompleted
                            ? AppColors.success
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}% เสร็จสิ้น',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'เยี่ยม!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ).animate().scale(delay: 200.ms),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor:
                  isCompleted ? Colors.white.withAlpha(50) : AppColors.border,
              valueColor: AlwaysStoppedAnimation(
                isCompleted ? AppColors.success : AppColors.primary,
              ),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          // Goal details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _GoalItem(
                icon: Icons.school,
                label: 'บทเรียน',
                current: dailyGoals.lessonsCompleted,
                target: dailyGoals.lessonsTarget,
                color: AppColors.primary,
              ),
              _GoalItem(
                icon: Icons.quiz,
                label: 'แบบทดสอบ',
                current: dailyGoals.quizzesTaken,
                target: dailyGoals.quizzesTarget,
                color: AppColors.warning,
              ),
              _GoalItem(
                icon: Icons.style,
                label: 'Flashcard',
                current: dailyGoals.flashcardsStudied,
                target: dailyGoals.flashcardsTarget,
                color: AppColors.accentBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int current;
  final int target;
  final Color color;

  const _GoalItem({
    required this.icon,
    required this.label,
    required this.current,
    required this.target,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = current >= target;
    return Column(
      children: [
        Icon(
          icon,
          color: isComplete ? AppColors.success : color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          '$current/$target',
          style: AppTextStyles.labelMedium.copyWith(
            color: isComplete ? AppColors.success : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

// Quick action button
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
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: color.withAlpha(15),
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(color: color.withAlpha(40)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Achievement showcase
class _AchievementShowcase extends StatelessWidget {
  final UserProgress progress;

  const _AchievementShowcase({required this.progress});

  @override
  Widget build(BuildContext context) {
    final achievements = progress.unlockedAchievements;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: CardDecoration.standard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: AppColors.warning),
              const SizedBox(width: 8),
              Text(
                'เกียรติบัตร',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${achievements.length}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          if (achievements.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingL),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.military_tech_outlined,
                    size: 48,
                    color: AppColors.textMuted,
                  )
                      .animate(
                        onPlay: (c) => c.repeat(reverse: true),
                      )
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1.1, 1.1),
                        duration: 2.seconds,
                      ),
                  const SizedBox(height: 8),
                  Text(
                    'ยังไม่มีเกียรติบัตร',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    'ทำแบบทดสอบและเรียนรู้เพื่อรับรางวัล!',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: achievements.take(6).map((achievement) {
                return _AchievementBadge(achievement: achievement);
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final String achievement;

  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withAlpha(40),
            AppColors.warning.withAlpha(20),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warning.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: AppColors.warning, size: 16),
          const SizedBox(width: 6),
          Text(
            achievement,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Settings tile
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

// Level option card
class _LevelOptionCard extends StatelessWidget {
  final NCOLevel level;
  final String description;
  final VoidCallback onTap;

  const _LevelOptionCard({
    required this.level,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentLevel = context.read<ProgressService>().currentLevel;
    final isSelected = currentLevel == level;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            gradient: isSelected
                ? (level == NCOLevel.junior
                    ? AppColors.juniorNcoGradient
                    : AppColors.seniorNcoGradient)
                : null,
            color: isSelected ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : AppColors.border,
              width: isSelected ? 0 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withAlpha(40)
                      : (level == NCOLevel.junior
                          ? AppColors.juniorNco
                          : AppColors.seniorNco)
                              .withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  level == NCOLevel.junior ? Icons.school : Icons.military_tech,
                  color: isSelected
                      ? Colors.white
                      : (level == NCOLevel.junior
                          ? AppColors.juniorNco
                          : AppColors.seniorNco),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.titleTh,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      description,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isSelected
                            ? Colors.white.withAlpha(200)
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

// Help item
class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _HelpItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

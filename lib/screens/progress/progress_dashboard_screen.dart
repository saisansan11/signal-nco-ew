import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../app/constants.dart';
import '../../data/curriculum_data.dart';
import '../../models/curriculum_models.dart';
import '../../services/progress_service.dart';

/// Progress Dashboard Screen - แสดงสถิติการเรียนละเอียด
class ProgressDashboardScreen extends StatelessWidget {
  const ProgressDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('สถิติการเรียน'),
        backgroundColor: AppColors.surface,
      ),
      body: Consumer<ProgressService>(
        builder: (context, progressService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall Progress Card
                _OverallProgressCard(progressService: progressService)
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 24),

                // Learning Stats Grid
                _LearningStatsGrid(progressService: progressService)
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 100.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 24),

                // Module Progress List
                Text(
                  'ความก้าวหน้าแต่ละบท',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _ModuleProgressList(progressService: progressService)
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 200.ms),

                const SizedBox(height: 24),

                // Category Breakdown
                _CategoryBreakdown(progressService: progressService)
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 300.ms),

                const SizedBox(height: 24),

                // Daily Goals
                _DailyGoalsCard(progressService: progressService)
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 400.ms),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OverallProgressCard extends StatelessWidget {
  final ProgressService progressService;

  const _OverallProgressCard({required this.progressService});

  @override
  Widget build(BuildContext context) {
    final progress = progressService.progress;
    final level = progressService.level;
    final totalXP = progressService.totalXP;
    final xpProgress = totalXP % 500;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.8),
            AppColors.primary.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'Lv.$level',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ระดับ ${progress.currentLevel.titleTh}',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalXP XP',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: xpProgress / 500,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$xpProgress / 500 XP ถึงเลเวลถัดไป',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: Icons.local_fire_department,
                value: '${progressService.currentStreak}',
                label: 'Streak',
                color: Colors.orange,
              ),
              _StatItem(
                icon: Icons.emoji_events,
                value: '${progress.unlockedAchievements.length}',
                label: 'เกียรติบัตร',
                color: Colors.amber,
              ),
              _StatItem(
                icon: Icons.school,
                value: '${_getCompletedModules(progressService)}',
                label: 'บทที่จบ',
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getCompletedModules(ProgressService service) {
    return service.progress.moduleProgress.values
        .where((m) => m.isCompleted)
        .length;
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _LearningStatsGrid extends StatelessWidget {
  final ProgressService progressService;

  const _LearningStatsGrid({required this.progressService});

  @override
  Widget build(BuildContext context) {
    final dailyGoals = progressService.dailyGoals;
    final completedLessons = _getTotalCompletedLessons(progressService);
    final quizzesTaken = _getTotalQuizzesTaken(progressService);
    final flashcardsStudied = progressService.progress.flashcardProgress.length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          title: 'บทเรียนวันนี้',
          value: '${dailyGoals.lessonsCompleted}',
          icon: Icons.menu_book,
          color: AppColors.esColor,
        ),
        _StatCard(
          title: 'แบบทดสอบวันนี้',
          value: '${dailyGoals.quizzesTaken}',
          icon: Icons.quiz,
          color: AppColors.eaColor,
        ),
        _StatCard(
          title: 'บทเรียนทั้งหมด',
          value: '$completedLessons',
          icon: Icons.check_circle,
          color: AppColors.epColor,
        ),
        _StatCard(
          title: 'Flashcards',
          value: '$flashcardsStudied',
          icon: Icons.style,
          color: AppColors.primary,
        ),
      ],
    );
  }

  int _getTotalCompletedLessons(ProgressService service) {
    int total = 0;
    for (var module in service.progress.moduleProgress.values) {
      total += module.completedLessons.length;
    }
    return total;
  }

  int _getTotalQuizzesTaken(ProgressService service) {
    int total = 0;
    for (var module in service.progress.moduleProgress.values) {
      total += module.quizScores.length;
    }
    return total;
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleProgressList extends StatelessWidget {
  final ProgressService progressService;

  const _ModuleProgressList({required this.progressService});

  @override
  Widget build(BuildContext context) {
    final level = progressService.currentLevel;
    final modules = CurriculumData.getModulesForLevel(level);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modules.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final module = modules[index];
        final moduleProgress = progressService.getModuleProgress(module.id);
        final lessonsCompleted = moduleProgress?.completedLessons.length ?? 0;
        final totalLessons = module.lessons.length;
        final progress = totalLessons > 0 ? lessonsCompleted / totalLessons : 0.0;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: module.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: module.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.titleTh,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppColors.textMuted.withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation(module.color),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$lessonsCompleted/$totalLessons',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (moduleProgress?.isCompleted ?? false)
                const Icon(Icons.check_circle, color: Colors.green, size: 24),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final ProgressService progressService;

  const _CategoryBreakdown({required this.progressService});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'หมวดหมู่ EW',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _CategoryRow(
            label: 'ES - Electronic Support',
            color: AppColors.esColor,
            progress: 0.6,
          ),
          const SizedBox(height: 12),
          _CategoryRow(
            label: 'EA - Electronic Attack',
            color: AppColors.eaColor,
            progress: 0.4,
          ),
          const SizedBox(height: 12),
          _CategoryRow(
            label: 'EP - Electronic Protection',
            color: AppColors.epColor,
            progress: 0.5,
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String label;
  final Color color;
  final double progress;

  const _CategoryRow({
    required this.label,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: AppTextStyles.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class _DailyGoalsCard extends StatelessWidget {
  final ProgressService progressService;

  const _DailyGoalsCard({required this.progressService});

  @override
  Widget build(BuildContext context) {
    final goals = progressService.dailyGoals;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
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
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${goals.lessonsCompleted + goals.quizzesTaken + goals.flashcardsStudied} / ${goals.lessonsTarget + goals.quizzesTarget + goals.flashcardsTarget}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _GoalItem(
            icon: Icons.menu_book,
            label: 'บทเรียน',
            current: goals.lessonsCompleted,
            goal: goals.lessonsTarget,
            color: AppColors.esColor,
          ),
          const SizedBox(height: 12),
          _GoalItem(
            icon: Icons.quiz,
            label: 'แบบทดสอบ',
            current: goals.quizzesTaken,
            goal: goals.quizzesTarget,
            color: AppColors.eaColor,
          ),
          const SizedBox(height: 12),
          _GoalItem(
            icon: Icons.style,
            label: 'Flashcards',
            current: goals.flashcardsStudied,
            goal: goals.flashcardsTarget,
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
  final int current;
  final int goal;
  final Color color;

  const _GoalItem({
    required this.icon,
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? current / goal : 0.0;
    final isComplete = current >= goal;

    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '$current / $goal',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isComplete ? Colors.green : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: color.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation(
                    isComplete ? Colors.green : color,
                  ),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
        if (isComplete)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(Icons.check_circle, color: Colors.green, size: 20),
          ),
      ],
    );
  }
}

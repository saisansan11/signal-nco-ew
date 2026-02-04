import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/constants.dart';
import '../../models/curriculum_models.dart';
import '../quiz/quiz_screen.dart';
import 'lesson_screen.dart';

/// หน้าจอแสดงรายการบทเรียนในโมดูล
class ModuleLessonsScreen extends StatelessWidget {
  final EWModule module;

  const ModuleLessonsScreen({
    super.key,
    required this.module,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                module.titleTh,
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16, right: 16),
              centerTitle: false,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      module.category.color,
                      module.category.color.withValues(alpha: 0.7),
                      AppColors.surface,
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.paddingL,
                      kToolbarHeight + 24,
                      AppSizes.paddingL,
                      0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppSizes.radiusS),
                          ),
                          child: Icon(
                            module.category.icon,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Row(
                          children: [
                            _InfoChip(
                              icon: Icons.timer_outlined,
                              label: '${module.estimatedMinutes} นาที',
                            ),
                            const SizedBox(width: 8),
                            _InfoChip(
                              icon: Icons.school_outlined,
                              label: '${module.lessons.length} บทเรียน',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Learning Objectives
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'วัตถุประสงค์การเรียนรู้',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  ...module.learningObjectives.asMap().entries.map((entry) {
                    final index = entry.key;
                    final objective = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: module.category.color.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: module.category.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              objective,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: Duration(milliseconds: 100 * index))
                        .fadeIn()
                        .slideX(begin: 0.1, end: 0);
                  }),
                ],
              ),
            ),
          ),

          // Lessons list
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
              child: Text(
                'เนื้อหาบทเรียน',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final lesson = module.lessons[index];
                  return _LessonCard(
                    lesson: lesson,
                    module: module,
                    index: index,
                    isLast: index == module.lessons.length - 1,
                  ).animate(delay: Duration(milliseconds: 150 * index))
                      .fadeIn(duration: 300.ms)
                      .slideX(begin: 0.1, end: 0);
                },
                childCount: module.lessons.length,
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingS,
        vertical: AppSizes.paddingXXS,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final EWModule module;
  final int index;
  final bool isLast;

  const _LessonCard({
    required this.lesson,
    required this.module,
    required this.index,
    required this.isLast,
  });

  IconData get _lessonIcon {
    switch (lesson.type) {
      case LessonType.reading:
        return Icons.menu_book;
      case LessonType.flashcard:
        return Icons.style;
      case LessonType.interactive:
        return Icons.touch_app;
      case LessonType.quiz:
        return Icons.quiz;
      case LessonType.scenario:
        return Icons.radar;
    }
  }

  String get _lessonTypeLabel {
    switch (lesson.type) {
      case LessonType.reading:
        return 'อ่าน';
      case LessonType.flashcard:
        return 'บัตรคำ';
      case LessonType.interactive:
        return 'โต้ตอบ';
      case LessonType.quiz:
        return 'ทดสอบ';
      case LessonType.scenario:
        return 'สถานการณ์';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : AppSizes.paddingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: module.category.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: module.category.color,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    _lessonIcon,
                    color: module.category.color,
                    size: 20,
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color: module.category.color.withValues(alpha: 0.3),
                ),
            ],
          ),
          const SizedBox(width: AppSizes.paddingM),
          // Card content
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToLesson(context),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(
                    color: module.category.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lesson.titleTh,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: module.category.color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppSizes.radiusS),
                          ),
                          child: Text(
                            _lessonTypeLabel,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: module.category.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (lesson.descriptionTh != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        lesson.descriptionTh!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${lesson.estimatedMinutes} นาที',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right,
                          color: module.category.color,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLesson(BuildContext context) {
    if (lesson.type == LessonType.quiz) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(category: module.category),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LessonScreen(
            module: module,
            lesson: lesson,
          ),
        ),
      );
    }
  }
}

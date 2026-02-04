import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../app/constants.dart';
import '../../models/curriculum_models.dart';
import '../../services/progress_service.dart';
import '../home/home_screen.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  NCOLevel? _selectedLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSizes.paddingXL),

              // Header
              Text(
                'ยินดีต้อนรับ',
                style: AppTextStyles.displayLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),

              const SizedBox(height: AppSizes.paddingS),

              Text(
                'เลือกหลักสูตรของคุณ',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 200.ms).fadeIn(duration: 500.ms),

              const SizedBox(height: AppSizes.paddingXXL),

              // Level cards
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Junior NCO
                    _LevelCard(
                      level: NCOLevel.junior,
                      isSelected: _selectedLevel == NCOLevel.junior,
                      onTap: () => setState(() => _selectedLevel = NCOLevel.junior),
                    )
                        .animate(delay: 400.ms)
                        .fadeIn(duration: 500.ms)
                        .slideX(begin: -0.2, end: 0),

                    const SizedBox(height: AppSizes.paddingL),

                    // Senior NCO
                    _LevelCard(
                      level: NCOLevel.senior,
                      isSelected: _selectedLevel == NCOLevel.senior,
                      onTap: () => setState(() => _selectedLevel = NCOLevel.senior),
                    )
                        .animate(delay: 600.ms)
                        .fadeIn(duration: 500.ms)
                        .slideX(begin: 0.2, end: 0),
                  ],
                ),
              ),

              // Continue button
              SizedBox(
                height: AppSizes.buttonHeightL,
                child: ElevatedButton(
                  onPressed: _selectedLevel != null ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.surfaceLight,
                  ),
                  child: Text(
                    AppStrings.start,
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: _selectedLevel != null
                          ? Colors.white
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ).animate(delay: 800.ms).fadeIn(duration: 500.ms),

              const SizedBox(height: AppSizes.paddingL),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onContinue() async {
    if (_selectedLevel == null) return;

    final progressService = context.read<ProgressService>();
    await progressService.setNCOLevel(_selectedLevel!);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: AppDurations.pageTransition,
        ),
      );
    }
  }
}

class _LevelCard extends StatelessWidget {
  final NCOLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = level == NCOLevel.junior
        ? AppColors.juniorNcoGradient
        : AppColors.seniorNcoGradient;

    final iconColor =
        level == NCOLevel.junior ? AppColors.juniorNco : AppColors.seniorNco;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AppCurves.defaultCurve,
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          border: Border.all(
            color: isSelected ? iconColor : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppColors.glowShadow(iconColor) : null,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
              child: Icon(
                level == NCOLevel.junior
                    ? Icons.military_tech
                    : Icons.workspace_premium,
                size: 36,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: AppSizes.paddingL),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.titleTh,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingXS),
                  Text(
                    level.descriptionTh,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  Row(
                    children: [
                      const Icon(
                        Icons.school,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: AppSizes.paddingXS),
                      Text(
                        level == NCOLevel.junior ? '8 โมดูล' : '19 โมดูล',
                        style: AppTextStyles.labelMedium,
                      ),
                      const SizedBox(width: AppSizes.paddingM),
                      const Icon(
                        Icons.timer,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: AppSizes.paddingXS),
                      Text(
                        level == NCOLevel.junior ? '~3 ชม.' : '~7 ชม.',
                        style: AppTextStyles.labelMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Check indicator
            if (isSelected)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

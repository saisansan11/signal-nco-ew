import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app/constants.dart';
import '../models/achievement_model.dart';

/// Achievement Badge Widget - แสดง badge รางวัล
class AchievementBadgeWidget extends StatelessWidget {
  final Achievement achievement;
  final UserAchievementProgress? progress;
  final bool showProgress;
  final VoidCallback? onTap;

  const AchievementBadgeWidget({
    super.key,
    required this.achievement,
    this.progress,
    this.showProgress = true,
    this.onTap,
  });

  bool get isUnlocked => progress?.isUnlocked ?? false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnlocked
              ? achievement.tier.color.withValues(alpha: 0.1)
              : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? achievement.tier.color.withValues(alpha: 0.5)
                : AppColors.border,
            width: isUnlocked ? 2 : 1,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: achievement.tier.color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge icon
            _buildBadgeIcon(),
            const SizedBox(height: 8),

            // Title
            Text(
              achievement.titleTh,
              style: AppTextStyles.labelMedium.copyWith(
                color: isUnlocked
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Progress bar
            if (showProgress && !isUnlocked && achievement.targetValue > 1) ...[
              const SizedBox(height: 6),
              _buildProgressBar(),
            ],

            // Tier label
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? achievement.tier.color.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                achievement.tier.nameTh,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isUnlocked
                      ? achievement.tier.color
                      : AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect for unlocked
        if (isUnlocked)
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  achievement.tier.color.withValues(alpha: 0.4),
                  achievement.tier.color.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),

        // Badge container
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isUnlocked
                ? achievement.tier.color.withValues(alpha: 0.2)
                : AppColors.surface,
            border: Border.all(
              color: isUnlocked ? achievement.tier.color : AppColors.border,
              width: 2,
            ),
          ),
          child: Center(
            child: isUnlocked
                ? Text(
                    achievement.icon,
                    style: const TextStyle(fontSize: 24),
                  )
                : Icon(
                    Icons.lock_outline,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
          ),
        ),

        // XP badge
        if (isUnlocked)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '+${achievement.totalXp}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final currentValue = progress?.currentValue ?? 0;
    final targetValue = achievement.targetValue;
    final progressValue = (currentValue / targetValue).clamp(0.0, 1.0);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progressValue,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(
              achievement.tier.color.withValues(alpha: 0.7),
            ),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$currentValue / $targetValue',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

/// Achievement Unlock Notification Widget - แสดงเมื่อปลดล็อครางวัล
class AchievementUnlockNotification extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onDismiss;

  const AchievementUnlockNotification({
    super.key,
    required this.achievement,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            achievement.tier.color.withValues(alpha: 0.2),
            AppColors.card,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: achievement.tier.color,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: achievement.tier.color.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                color: achievement.tier.color,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'รางวัลใหม่!',
                style: AppTextStyles.titleMedium.copyWith(
                  color: achievement.tier.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Badge icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  achievement.tier.color,
                  achievement.tier.color.withValues(alpha: 0.5),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: achievement.tier.color.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(
                achievement.icon,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                duration: 2.seconds,
                color: Colors.white.withValues(alpha: 0.3),
              ),
          const SizedBox(height: 16),

          // Title
          Text(
            achievement.titleTh,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Description
          Text(
            achievement.descriptionTh,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // XP reward
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: AppColors.warning, size: 20),
                const SizedBox(width: 4),
                Text(
                  '+${achievement.totalXp} XP',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Dismiss button
          TextButton(
            onPressed: onDismiss,
            child: const Text('ปิด'),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }
}

/// Achievement Mini Badge - แสดงในรูปแบบเล็ก
class AchievementMiniBadge extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;

  const AchievementMiniBadge({
    super.key,
    required this.achievement,
    this.isUnlocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${achievement.titleTh}\n${achievement.descriptionTh}',
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isUnlocked
              ? achievement.tier.color.withValues(alpha: 0.2)
              : AppColors.surface,
          border: Border.all(
            color: isUnlocked ? achievement.tier.color : AppColors.border,
          ),
        ),
        child: Center(
          child: isUnlocked
              ? Text(
                  achievement.icon,
                  style: const TextStyle(fontSize: 16),
                )
              : Icon(
                  Icons.lock_outline,
                  color: AppColors.textSecondary,
                  size: 14,
                ),
        ),
      ),
    );
  }
}

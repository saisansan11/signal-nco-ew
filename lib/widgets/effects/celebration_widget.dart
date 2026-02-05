import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/constants.dart';

/// Celebration Widget - แสดง confetti effect เมื่อสำเร็จ
class CelebrationWidget extends StatefulWidget {
  final Widget child;
  final bool showConfetti;
  final VoidCallback? onComplete;

  const CelebrationWidget({
    super.key,
    required this.child,
    this.showConfetti = false,
    this.onComplete,
  });

  @override
  State<CelebrationWidget> createState() => _CelebrationWidgetState();
}

class _CelebrationWidgetState extends State<CelebrationWidget> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void didUpdateWidget(CelebrationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showConfetti && !oldWidget.showConfetti) {
      _confettiController.play();
      Future.delayed(const Duration(seconds: 3), () {
        widget.onComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Center confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppColors.primary,
              AppColors.success,
              AppColors.warning,
              AppColors.info,
              AppColors.esColor,
              AppColors.eaColor,
              AppColors.epColor,
            ],
            numberOfParticles: 30,
            maxBlastForce: 20,
            minBlastForce: 5,
            emissionFrequency: 0.05,
            gravity: 0.2,
          ),
        ),
      ],
    );
  }
}

/// Success Celebration Dialog - แสดง dialog เมื่อสำเร็จพร้อม confetti
class SuccessCelebrationDialog extends StatefulWidget {
  final String title;
  final String message;
  final int? score;
  final int? stars;
  final int? xpEarned;
  final VoidCallback? onDismiss;

  const SuccessCelebrationDialog({
    super.key,
    required this.title,
    required this.message,
    this.score,
    this.stars,
    this.xpEarned,
    this.onDismiss,
  });

  @override
  State<SuccessCelebrationDialog> createState() =>
      _SuccessCelebrationDialogState();
}

class _SuccessCelebrationDialogState extends State<SuccessCelebrationDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    // Start confetti immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dialog
        Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 350),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withValues(alpha: 0.9),
                  AppColors.success.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trophy icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 48,
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    )
                    .then()
                    .shimmer(duration: 1.seconds),

                const SizedBox(height: 16),

                // Title
                Text(
                  widget.title,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 8),

                // Message
                Text(
                  widget.message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 20),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Score
                    if (widget.score != null)
                      _StatItem(
                        icon: Icons.speed,
                        value: '${widget.score}%',
                        label: 'คะแนน',
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

                    // Stars
                    if (widget.stars != null)
                      _StatItem(
                        icon: Icons.star,
                        value: '${widget.stars}',
                        label: 'ดาว',
                        iconColor: AppColors.warning,
                      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),

                    // XP
                    if (widget.xpEarned != null)
                      _StatItem(
                        icon: Icons.bolt,
                        value: '+${widget.xpEarned}',
                        label: 'XP',
                        iconColor: AppColors.primary,
                      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
                  ],
                ),

                const SizedBox(height: 24),

                // Dismiss button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onDismiss?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'ยอดเยี่ยม!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 700.ms),
              ],
            ),
          ),
        ),

        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.white,
              AppColors.warning,
              AppColors.primary,
              Colors.green,
              Colors.yellow,
            ],
            numberOfParticles: 50,
            maxBlastForce: 30,
            minBlastForce: 10,
            emissionFrequency: 0.03,
            gravity: 0.15,
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? iconColor;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: iconColor ?? Colors.white,
            size: 24,
          ),
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
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Level Up Celebration - แสดงเมื่อเลื่อนระดับ
class LevelUpCelebration extends StatefulWidget {
  final int newLevel;
  final VoidCallback? onDismiss;

  const LevelUpCelebration({
    super.key,
    required this.newLevel,
    this.onDismiss,
  });

  @override
  State<LevelUpCelebration> createState() => _LevelUpCelebrationState();
}

class _LevelUpCelebrationState extends State<LevelUpCelebration>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background overlay
        Container(
          color: Colors.black.withValues(alpha: 0.7),
        ),

        // Content
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Glow effect around level
              AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.warning
                              .withValues(alpha: 0.3 + (_glowController.value * 0.4)),
                          blurRadius: 30 + (_glowController.value * 20),
                          spreadRadius: 10 + (_glowController.value * 10),
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.warning,
                        AppColors.warning.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'LV',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        Text(
                          '${widget.newLevel}',
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 48,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    ),
              ),

              const SizedBox(height: 32),

              // Level up text
              Text(
                'LEVEL UP!',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms)
                  .shimmer(duration: 2.seconds, color: Colors.white),

              const SizedBox(height: 8),

              Text(
                'ยินดีด้วย! คุณเลื่อนระดับเป็น ${widget.newLevel}',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 32),

              // Continue button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onDismiss?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'ดำเนินการต่อ',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3),
            ],
          ),
        ),

        // Confetti from both sides
        Align(
          alignment: Alignment.topLeft,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: -0.5,
            shouldLoop: false,
            colors: const [
              AppColors.warning,
              Colors.white,
              AppColors.primary,
            ],
            numberOfParticles: 20,
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 3.14 + 0.5,
            shouldLoop: false,
            colors: const [
              AppColors.warning,
              Colors.white,
              AppColors.primary,
            ],
            numberOfParticles: 20,
          ),
        ),
      ],
    );
  }
}

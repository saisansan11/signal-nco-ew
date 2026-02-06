import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/constants.dart';

/// Model for tutorial step
class TutorialStep {
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;
  final String? imagePath;
  final List<String>? tips;

  const TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor,
    this.imagePath,
    this.tips,
  });
}

/// Tutorial overlay widget - shows on first launch
class TutorialOverlay extends StatefulWidget {
  final String tutorialKey; // Unique key for SharedPreferences
  final List<TutorialStep> steps;
  final VoidCallback? onComplete;
  final Widget child;
  final Color primaryColor;

  const TutorialOverlay({
    super.key,
    required this.tutorialKey,
    required this.steps,
    required this.child,
    this.onComplete,
    this.primaryColor = AppColors.primary,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  bool _showTutorial = false;
  bool _isLoading = true;
  int _currentStep = 0;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _checkFirstLaunch();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TutorialOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-check when parent widget rebuilds (e.g., when help button is pressed)
    _recheckTutorial();
  }

  Future<void> _recheckTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial = prefs.getBool('tutorial_${widget.tutorialKey}') ?? false;

    if (!hasSeenTutorial && !_showTutorial) {
      setState(() {
        _showTutorial = true;
        _currentStep = 0;
      });
    }
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial = prefs.getBool('tutorial_${widget.tutorialKey}') ?? false;

    setState(() {
      _showTutorial = !hasSeenTutorial;
      _isLoading = false;
    });
  }

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_${widget.tutorialKey}', true);

    setState(() {
      _showTutorial = false;
    });

    widget.onComplete?.call();
  }

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _completeTutorial();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _skipTutorial() {
    _completeTutorial();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        if (_showTutorial) _buildTutorialOverlay(),
      ],
    );
  }

  Widget _buildTutorialOverlay() {
    final step = widget.steps[_currentStep];

    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            children: [
              // Header with skip button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Step indicator
                  Row(
                    children: List.generate(widget.steps.length, (index) {
                      return Container(
                        width: index == _currentStep ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: index == _currentStep
                              ? widget.primaryColor
                              : widget.primaryColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  // Skip button
                  TextButton(
                    onPressed: _skipTutorial,
                    child: Text(
                      'ข้าม',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Main content
              _buildStepContent(step),

              const Spacer(),

              // Navigation buttons
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildStepContent(TutorialStep step) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated icon
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_pulseController.value * 0.1),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: (step.iconColor ?? widget.primaryColor).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (step.iconColor ?? widget.primaryColor).withValues(alpha: 0.3),
                      blurRadius: 30 + (_pulseController.value * 20),
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  step.icon,
                  size: 60,
                  color: step.iconColor ?? widget.primaryColor,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 32),

        // Title
        Text(
          step.title,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ).animate(key: ValueKey('title_$_currentStep'))
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.2),

        const SizedBox(height: 16),

        // Description
        Text(
          step.description,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ).animate(key: ValueKey('desc_$_currentStep'))
            .fadeIn(duration: 300.ms, delay: 100.ms)
            .slideY(begin: 0.2),

        // Tips
        if (step.tips != null && step.tips!.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: widget.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(
                color: widget.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: widget.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'เคล็ดลับ',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: widget.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...step.tips!.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.key + 1}. ',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: widget.primaryColor,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ).animate(key: ValueKey('tips_$_currentStep'))
              .fadeIn(duration: 300.ms, delay: 200.ms)
              .slideY(begin: 0.2),
        ],
      ],
    );
  }

  Widget _buildNavigationButtons() {
    final isFirstStep = _currentStep == 0;
    final isLastStep = _currentStep == widget.steps.length - 1;

    return Row(
      children: [
        // Previous button
        if (!isFirstStep)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back),
              label: const Text('ก่อนหน้า'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          )
        else
          const Expanded(child: SizedBox()),

        const SizedBox(width: 16),

        // Next/Complete button
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _nextStep,
            icon: Icon(isLastStep ? Icons.check : Icons.arrow_forward),
            label: Text(isLastStep ? 'เริ่มเล่นเลย!' : 'ถัดไป'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Extension to easily wrap any screen with tutorial
extension TutorialExtension on Widget {
  Widget withTutorial({
    required String tutorialKey,
    required List<TutorialStep> steps,
    Color primaryColor = AppColors.primary,
    VoidCallback? onComplete,
  }) {
    return TutorialOverlay(
      tutorialKey: tutorialKey,
      steps: steps,
      primaryColor: primaryColor,
      onComplete: onComplete,
      child: this,
    );
  }
}

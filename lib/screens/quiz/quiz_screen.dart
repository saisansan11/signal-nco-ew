import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../app/constants.dart';
import '../../data/quiz_data.dart';
import '../../models/curriculum_models.dart';
import '../../models/quiz_models.dart';
import '../../services/progress_service.dart';

class QuizScreen extends StatefulWidget {
  final EWCategory? category;
  final QuizConfig config;

  const QuizScreen({
    super.key,
    this.category,
    this.config = const QuizConfig(),
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late List<QuizQuestion> _questions;
  late AdaptiveQuizState _quizState;
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _hasAnswered = false;
  bool _showExplanation = false;
  Timer? _timer;
  int _secondsRemaining = 0;
  int _totalTimeSpent = 0;

  late AnimationController _progressController;
  late AnimationController _feedbackController;

  @override
  void initState() {
    super.initState();
    _initQuiz();
    _setupAnimations();
    if (widget.config.timeLimitSeconds > 0) {
      _startTimer();
    }
  }

  void _initQuiz() {
    if (widget.category != null) {
      _questions = QuizData.getByCategory(widget.category!);
    } else {
      _questions = List.from(QuizData.allQuestions);
    }

    if (widget.config.shuffleQuestions) {
      _questions.shuffle();
    }

    _questions = _questions.take(widget.config.totalQuestions).toList();

    _quizState = AdaptiveQuizState(
      currentDifficulty: DifficultyLevel.beginner,
    );

    _secondsRemaining = widget.config.timeLimitSeconds;
  }

  void _setupAnimations() {
    _progressController = AnimationController(
      duration: AppDurations.normal,
      vsync: this,
    );

    _feedbackController = AnimationController(
      duration: AppDurations.fast,
      vsync: this,
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
          _totalTimeSpent++;
        } else {
          _endQuiz();
        }
      });
    });
  }

  void _selectAnswer(int index) {
    if (_hasAnswered) return;

    setState(() {
      _selectedAnswer = index;
      _hasAnswered = true;
      _showExplanation = widget.config.showExplanation;

      final isCorrect = _questions[_currentIndex].isCorrect(index);
      _quizState.recordAnswer(isCorrect);

      _feedbackController.forward(from: 0);
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _hasAnswered = false;
        _showExplanation = false;
        _progressController.forward(from: 0);
      });
    } else {
      _endQuiz();
    }
  }

  void _endQuiz() {
    _timer?.cancel();

    final result = QuizResult(
      quizId: widget.category?.name ?? 'general',
      totalQuestions: _questions.length,
      correctAnswers: _quizState.correctAnswers,
      timeSpentSeconds: _totalTimeSpent,
      completedAt: DateTime.now(),
      questionResults: [],
    );

    // Save result to progress
    final progressService = context.read<ProgressService>();
    progressService.saveQuizScore(
      widget.category?.name ?? 'general',
      result.scorePercent,
    );

    _showResultDialog(result);
  }

  void _showResultDialog(QuizResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Row(
          children: [
            Icon(
              result.isPassing ? Icons.emoji_events : Icons.school,
              color: result.isPassing ? AppColors.seniorNco : AppColors.primary,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              result.isPassing ? 'ยอดเยี่ยม!' : 'สู้ต่อไป!',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Score circle
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: result.isPassing
                      ? [AppColors.success, AppColors.epColor]
                      : [AppColors.warning, AppColors.primary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (result.isPassing ? AppColors.success : AppColors.warning)
                        .withAlpha(80),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${result.scorePercent}%',
                      style: AppTextStyles.displayLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'คะแนน',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  icon: Icons.check_circle,
                  value: '${result.correctAnswers}',
                  label: 'ถูก',
                  color: AppColors.success,
                ),
                _StatItem(
                  icon: Icons.cancel,
                  value: '${result.totalQuestions - result.correctAnswers}',
                  label: 'ผิด',
                  color: AppColors.error,
                ),
                _StatItem(
                  icon: Icons.timer,
                  value: _formatTime(result.timeSpentSeconds),
                  label: 'เวลา',
                  color: AppColors.info,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pass/Fail message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: result.isPassing
                    ? AppColors.successLight
                    : AppColors.warningLight,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Row(
                children: [
                  Icon(
                    result.isPassing ? Icons.verified : Icons.info_outline,
                    color: result.isPassing ? AppColors.success : AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.isPassing
                          ? 'คุณผ่านเกณฑ์ 70% แล้ว!'
                          : 'ต้องได้ 70% ขึ้นไปจึงจะผ่าน ลองอีกครั้ง!',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: result.isPassing
                            ? AppColors.success
                            : AppColors.warning,
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
            onPressed: () {
              Navigator.pop(context);
              _restartQuiz();
            },
            child: const Text('ทำใหม่'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('เสร็จสิ้น'),
          ),
        ],
      ),
    );
  }

  void _restartQuiz() {
    setState(() {
      _initQuiz();
      _currentIndex = 0;
      _selectedAnswer = null;
      _hasAnswered = false;
      _showExplanation = false;
      _totalTimeSpent = 0;
      if (widget.config.timeLimitSeconds > 0) {
        _startTimer();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('แบบทดสอบ'),
          backgroundColor: AppColors.surface,
        ),
        body: const Center(
          child: Text(
            'ไม่มีคำถามในหมวดนี้',
            style: AppTextStyles.bodyLarge,
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.category?.titleTh ?? 'แบบทดสอบ EW'),
        backgroundColor: AppColors.surface,
        actions: [
          if (widget.config.timeLimitSeconds > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _secondsRemaining < 30
                        ? AppColors.errorLight
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 16,
                        color: _secondsRemaining < 30
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(_secondsRemaining),
                        style: AppTextStyles.titleMedium.copyWith(
                          color: _secondsRemaining < 30
                              ? AppColors.error
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ข้อ ${_currentIndex + 1} / ${_questions.length}',
                        style: AppTextStyles.labelMedium,
                      ),
                      Row(
                        children: [
                          _DifficultyBadge(
                              difficulty: currentQuestion.difficulty),
                          const SizedBox(width: 8),
                          Text(
                            '${_quizState.correctAnswers}/${_quizState.totalQuestions}',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: AppDurations.normal,
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          currentQuestion.category.color,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      );
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            // Question card
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Question
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingL),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppSizes.radiusL),
                        border: Border.all(
                          color: currentQuestion.category.color.withAlpha(100),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  currentQuestion.category.color.withAlpha(40),
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusS),
                            ),
                            child: Text(
                              currentQuestion.category.titleTh,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: currentQuestion.category.color,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            currentQuestion.questionTh,
                            style: AppTextStyles.titleLarge.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: 0.05, end: 0),

                    const SizedBox(height: 16),

                    // Options
                    ...List.generate(currentQuestion.optionsTh.length, (index) {
                      final isSelected = _selectedAnswer == index;
                      final isCorrect = currentQuestion.correctIndex == index;
                      final showResult = _hasAnswered;

                      Color borderColor = AppColors.border;
                      Color bgColor = AppColors.surfaceLight;

                      if (showResult) {
                        if (isCorrect) {
                          borderColor = AppColors.success;
                          bgColor = AppColors.successLight;
                        } else if (isSelected && !isCorrect) {
                          borderColor = AppColors.error;
                          bgColor = AppColors.errorLight;
                        }
                      } else if (isSelected) {
                        borderColor = currentQuestion.category.color;
                        bgColor =
                            currentQuestion.category.color.withAlpha(20);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap:
                                _hasAnswered ? null : () => _selectAnswer(index),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusM),
                            child: AnimatedContainer(
                              duration: AppDurations.fast,
                              padding: const EdgeInsets.all(AppSizes.paddingM),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusM),
                                border: Border.all(
                                  color: borderColor,
                                  width: isSelected || (showResult && isCorrect)
                                      ? 2
                                      : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: showResult && isCorrect
                                          ? AppColors.success
                                          : showResult && isSelected && !isCorrect
                                              ? AppColors.error
                                              : isSelected
                                                  ? currentQuestion
                                                      .category.color
                                                  : AppColors.border,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: showResult && isCorrect
                                          ? const Icon(Icons.check,
                                              size: 16, color: Colors.white)
                                          : showResult &&
                                                  isSelected &&
                                                  !isCorrect
                                              ? const Icon(Icons.close,
                                                  size: 16, color: Colors.white)
                                              : Text(
                                                  String.fromCharCode(
                                                      65 + index),
                                                  style: AppTextStyles
                                                      .labelMedium
                                                      .copyWith(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : AppColors
                                                            .textSecondary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      currentQuestion.optionsTh[index],
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                          .animate(delay: Duration(milliseconds: 100 * index))
                          .fadeIn(duration: 200.ms)
                          .slideX(begin: 0.1, end: 0);
                    }),

                    // Explanation
                    if (_showExplanation &&
                        currentQuestion.explanationTh != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.infoLight,
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          border: Border.all(
                            color: AppColors.info.withAlpha(50),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb,
                                  color: AppColors.info,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'คำอธิบาย',
                                  style: AppTextStyles.titleSmall.copyWith(
                                    color: AppColors.info,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentQuestion.explanationTh!,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                    ],
                  ],
                ),
              ),
            ),

            // Next button
            if (_hasAnswered)
              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                child: SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeightL,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentQuestion.category.color,
                    ),
                    child: Text(
                      _currentIndex < _questions.length - 1
                          ? 'ข้อถัดไป'
                          : 'ดูผลลัพธ์',
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
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
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: color,
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

class _DifficultyBadge extends StatelessWidget {
  final DifficultyLevel difficulty;

  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (difficulty) {
      case DifficultyLevel.beginner:
        color = AppColors.success;
        text = 'ง่าย';
        break;
      case DifficultyLevel.intermediate:
        color = AppColors.warning;
        text = 'ปานกลาง';
        break;
      case DifficultyLevel.advanced:
        color = AppColors.error;
        text = 'ยาก';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(AppSizes.radiusXS),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

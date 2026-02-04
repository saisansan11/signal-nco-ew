import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../app/constants.dart';
import '../../data/glossary_data.dart';
import '../../models/curriculum_models.dart';
import '../../services/progress_service.dart';

class FlashcardScreen extends StatefulWidget {
  final EWCategory? filterCategory;

  const FlashcardScreen({
    super.key,
    this.filterCategory,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with TickerProviderStateMixin {
  late List<GlossaryTerm> _cards;
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _knownCount = 0;
  int _learningCount = 0;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late AnimationController _swipeController;
  late Animation<Offset> _swipeAnimation;

  Offset _dragStart = Offset.zero;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _loadCards();
    _setupAnimations();
  }

  void _loadCards() {
    if (widget.filterCategory != null) {
      _cards = GlossaryData.getByCategory(widget.filterCategory!);
    } else {
      _cards = List.from(GlossaryData.terms);
    }
    _cards.shuffle();
  }

  void _setupAnimations() {
    _flipController = AnimationController(
      duration: AppDurations.cardFlip,
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );

    _swipeController = AnimationController(
      duration: AppDurations.normal,
      vsync: this,
    );
    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _flipCard() {
    if (_flipController.isAnimating) return;

    setState(() => _isFlipped = !_isFlipped);
    if (_isFlipped) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  void _onPanStart(DragStartDetails details) {
    _dragStart = details.globalPosition;
    _isDragging = true;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    setState(() {
      _dragOffset = details.globalPosition - _dragStart;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
    final velocity = details.velocity.pixelsPerSecond.dx;
    final distance = _dragOffset.dx;

    if (distance.abs() > 100 || velocity.abs() > 500) {
      final direction = distance > 0 ? 1 : -1;
      _animateSwipe(direction);
    } else {
      setState(() => _dragOffset = Offset.zero);
    }
  }

  void _animateSwipe(int direction) {
    final screenWidth = MediaQuery.of(context).size.width;

    _swipeAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset(screenWidth * direction * 1.5, 0),
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOutCubic,
    ));

    _swipeController.forward().then((_) {
      // Record result: right = known, left = learning
      if (direction > 0) {
        _knownCount++;
        _recordFlashcardResult(5); // Good recall
      } else {
        _learningCount++;
        _recordFlashcardResult(2); // Needs work
      }

      _nextCard();
      _swipeController.reset();
      setState(() => _dragOffset = Offset.zero);
    });
  }

  void _recordFlashcardResult(int quality) {
    final term = _cards[_currentIndex];
    final progressService = context.read<ProgressService>();
    progressService.updateFlashcard(term.term, quality);
  }

  void _nextCard() {
    if (_currentIndex < _cards.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
        _flipController.reset();
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final total = _knownCount + _learningCount;
    final percentage = total > 0 ? (_knownCount / total * 100).round() : 0;

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
              percentage >= 70 ? Icons.emoji_events : Icons.school,
              color: percentage >= 70 ? AppColors.success : AppColors.esColor,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'เรียนจบชุด!',
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
              'คุณได้ทบทวน ${_cards.length} คำศัพท์',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ResultBadge(
                  icon: Icons.check_circle,
                  color: AppColors.success,
                  count: _knownCount,
                  label: 'รู้แล้ว',
                ),
                _ResultBadge(
                  icon: Icons.replay,
                  color: AppColors.warning,
                  count: _learningCount,
                  label: 'ทบทวน',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: percentage >= 70
                    ? AppColors.success.withAlpha(30)
                    : AppColors.warning.withAlpha(30),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$percentage%',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: percentage >= 70
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'จำได้',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
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
              _restartDeck();
            },
            child: const Text('เริ่มใหม่'),
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

  void _restartDeck() {
    setState(() {
      _currentIndex = 0;
      _knownCount = 0;
      _learningCount = 0;
      _isFlipped = false;
      _flipController.reset();
      _cards.shuffle();
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    _swipeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Flashcards'),
          backgroundColor: AppColors.surface,
        ),
        body: const Center(
          child: Text(
            'ไม่มีคำศัพท์ในหมวดนี้',
            style: AppTextStyles.bodyLarge,
          ),
        ),
      );
    }

    final currentTerm = _cards[_currentIndex];
    final progress = (_currentIndex + 1) / _cards.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.filterCategory?.titleTh ?? 'Flashcards'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: _restartDeck,
            tooltip: 'สุ่มใหม่',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_currentIndex + 1} / ${_cards.length}',
                        style: AppTextStyles.labelMedium,
                      ),
                      Row(
                        children: [
                          Icon(Icons.check_circle,
                              size: 16, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text('$_knownCount',
                              style: AppTextStyles.labelMedium),
                          const SizedBox(width: 12),
                          Icon(Icons.replay, size: 16, color: AppColors.warning),
                          const SizedBox(width: 4),
                          Text('$_learningCount',
                              style: AppTextStyles.labelMedium),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.border,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            // Flashcard
            Expanded(
              child: GestureDetector(
                onTap: _flipCard,
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _flipAnimation,
                    _swipeAnimation,
                  ]),
                  builder: (context, child) {
                    final swipeOffset = _swipeController.isAnimating
                        ? _swipeAnimation.value
                        : _dragOffset;

                    return Transform.translate(
                      offset: swipeOffset,
                      child: Transform.rotate(
                        angle: swipeOffset.dx / 1000,
                        child: _buildFlipCard(currentTerm),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Instructions
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SwipeHint(
                        icon: Icons.arrow_back,
                        label: 'ทบทวนอีก',
                        color: AppColors.warning,
                      ),
                      Text(
                        'แตะเพื่อพลิก',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      _SwipeHint(
                        icon: Icons.arrow_forward,
                        label: 'รู้แล้ว',
                        color: AppColors.success,
                      ),
                    ],
                  ),
                ],
              ),
            ).animate(delay: 300.ms).fadeIn(),
          ],
        ),
      ),
    );
  }

  Widget _buildFlipCard(GlossaryTerm term) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: AspectRatio(
          aspectRatio: 0.7,
          child: AnimatedBuilder(
            animation: _flipAnimation,
            builder: (context, child) {
              final angle = _flipAnimation.value * math.pi;
              final isFront = angle < math.pi / 2;

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: isFront
                    ? _buildFrontCard(term)
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(math.pi),
                        child: _buildBackCard(term),
                      ),
              );
            },
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 300.ms,
        );
  }

  Widget _buildFrontCard(GlossaryTerm term) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            term.category.color.withAlpha(40),
            AppColors.card,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(
          color: term.category.color.withAlpha(100),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: term.category.color.withAlpha(30),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Category badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: term.category.color.withAlpha(50),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Text(
              term.category.titleTh,
              style: AppTextStyles.labelSmall.copyWith(
                color: term.category.color,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Term
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
            child: Text(
              term.term,
              style: AppTextStyles.displayLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          if (term.fullForm != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
              child: Text(
                term.fullForm!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Tap to flip hint
          Icon(
            Icons.touch_app,
            color: AppColors.textMuted,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'แตะเพื่อดูคำตอบ',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(GlossaryTerm term) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            term.category.color.withAlpha(60),
            AppColors.surfaceLight,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(
          color: term.category.color,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: term.category.color.withAlpha(40),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Term header
            Text(
              term.term,
              style: AppTextStyles.titleLarge.copyWith(
                color: term.category.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Divider
            Container(
              width: 60,
              height: 3,
              decoration: BoxDecoration(
                color: term.category.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Definition
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      term.definitionTh,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (term.relatedTerms.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'คำที่เกี่ยวข้อง',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: term.relatedTerms.map((related) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusS),
                            ),
                            child: Text(
                              related,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Swipe instruction
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swipe, color: AppColors.textMuted, size: 20),
                const SizedBox(width: 8),
                Text(
                  'ปัดซ้าย/ขวา',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int count;
  final String label;

  const _ResultBadge({
    required this.icon,
    required this.color,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: AppTextStyles.titleLarge.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SwipeHint extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SwipeHint({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }
}

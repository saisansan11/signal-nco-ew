import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../app/constants.dart';

/// ECCM Shield Defense Widget - จำลองการป้องกันการรบกวน
/// Animation ว้าว: โล่พลังงาน, Frequency Hopping, การป้องกัน
class ECCMShieldDefenseWidget extends StatefulWidget {
  final VoidCallback? onComplete;

  const ECCMShieldDefenseWidget({super.key, this.onComplete});

  @override
  State<ECCMShieldDefenseWidget> createState() => _ECCMShieldDefenseWidgetState();
}

class _ECCMShieldDefenseWidgetState extends State<ECCMShieldDefenseWidget>
    with TickerProviderStateMixin {
  late AnimationController _shieldController;
  late AnimationController _attackController;
  late AnimationController _hopController;
  late AnimationController _pulseController;

  bool _isDefenseActive = false;
  ECCMTechnique _selectedTechnique = ECCMTechnique.none;
  int _blockedAttacks = 0;
  int _totalAttacks = 0;
  double _currentFrequency = 150.0;
  final List<double> _frequencyHistory = [];

  final List<JammingAttack> _attacks = [];
  bool _underAttack = false;

  @override
  void initState() {
    super.initState();

    _shieldController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _attackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _hopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  void _activateDefense() {
    setState(() {
      _isDefenseActive = true;
    });

    _shieldController.repeat();

    // Start frequency hopping if FHSS selected
    if (_selectedTechnique == ECCMTechnique.fhss) {
      _startFrequencyHopping();
    }

    // Simulate attacks
    _simulateAttacks();
  }

  void _deactivateDefense() {
    setState(() {
      _isDefenseActive = false;
      _underAttack = false;
    });

    _shieldController.stop();
  }

  void _startFrequencyHopping() {
    Future.doWhile(() async {
      if (!_isDefenseActive) return false;

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return false;

      final random = math.Random();
      final newFrequency = 50.0 + random.nextDouble() * 300;

      setState(() {
        _frequencyHistory.add(_currentFrequency);
        if (_frequencyHistory.length > 10) {
          _frequencyHistory.removeAt(0);
        }
        _currentFrequency = newFrequency;
      });

      _hopController.forward(from: 0);

      return _isDefenseActive;
    });
  }

  void _simulateAttacks() {
    Future.doWhile(() async {
      if (!_isDefenseActive) return false;

      await Future.delayed(Duration(milliseconds: 1000 + math.Random().nextInt(1500)));

      if (!mounted || !_isDefenseActive) return false;

      final random = math.Random();
      final attack = JammingAttack(
        frequency: 50.0 + random.nextDouble() * 300,
        power: 0.5 + random.nextDouble() * 0.5,
        type: JammingAttackType.values[random.nextInt(JammingAttackType.values.length)],
      );

      setState(() {
        _underAttack = true;
        _attacks.add(attack);
        _totalAttacks++;
      });

      _attackController.forward(from: 0);

      // Check if defense blocks the attack
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return false;

      final isBlocked = _checkDefenseEffectiveness(attack);

      setState(() {
        attack.isBlocked = isBlocked;
        if (isBlocked) _blockedAttacks++;
        _underAttack = false;
      });

      // Remove old attacks
      if (_attacks.length > 5) {
        setState(() {
          _attacks.removeAt(0);
        });
      }

      // Check completion
      if (_totalAttacks >= 10) {
        widget.onComplete?.call();
        _deactivateDefense();
        return false;
      }

      return _isDefenseActive;
    });
  }

  bool _checkDefenseEffectiveness(JammingAttack attack) {
    switch (_selectedTechnique) {
      case ECCMTechnique.fhss:
        // FHSS is effective if frequency differs from attack
        return (attack.frequency - _currentFrequency).abs() > 30;
      case ECCMTechnique.spreadSpectrum:
        // Spread spectrum is generally effective
        return attack.power < 0.8;
      case ECCMTechnique.adaptiveFiltering:
        // Adaptive filtering blocks specific attack types
        return attack.type == JammingAttackType.spot;
      case ECCMTechnique.powerControl:
        // Power control effective against weaker attacks
        return attack.power < 0.7;
      case ECCMTechnique.none:
        return false;
    }
  }

  @override
  void dispose() {
    _shieldController.dispose();
    _attackController.dispose();
    _hopController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.epColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.epColor.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 16),

          // Shield Visualization
          _buildShieldVisualization(),
          const SizedBox(height: 16),

          // ECCM Technique Selector
          _buildTechniqueSelector(),
          const SizedBox(height: 16),

          // Frequency Display (for FHSS)
          if (_selectedTechnique == ECCMTechnique.fhss)
            _buildFrequencyDisplay(),

          // Control Button
          _buildControlButton(),

          // Attack History
          if (_attacks.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildAttackHistory(),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildHeader() {
    final effectiveness = _totalAttacks > 0
        ? (_blockedAttacks / _totalAttacks * 100).toInt()
        : 0;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.epColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.shield,
            color: AppColors.epColor,
            size: 28,
          ),
        )
            .animate(
              onPlay: (controller) => controller.repeat(reverse: true),
            )
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.1, 1.1),
              duration: 1000.ms,
            ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ECCM Shield Defense',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.epColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'ป้องกันการรบกวนข้าศึก',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Effectiveness
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppColors.epGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified_user, color: Colors.white, size: 18),
              const SizedBox(width: 4),
              Text(
                '$effectiveness%',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShieldVisualization() {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shield rings
          AnimatedBuilder(
            animation: Listenable.merge([_shieldController, _pulseController]),
            builder: (context, child) {
              return CustomPaint(
                size: const Size(200, 200),
                painter: _ShieldPainter(
                  shieldProgress: _isDefenseActive ? _shieldController.value : 0,
                  pulseProgress: _pulseController.value,
                  isActive: _isDefenseActive,
                  underAttack: _underAttack,
                  technique: _selectedTechnique,
                ),
              );
            },
          ),

          // Attack indicators
          ..._attacks.asMap().entries.map((entry) {
            final index = entry.key;
            final attack = entry.value;
            final angle = (index / 5) * 2 * math.pi - math.pi / 2;
            final distance = 80.0;

            return Positioned(
              left: 100 + math.cos(angle) * distance - 15,
              top: 100 + math.sin(angle) * distance - 15,
              child: _buildAttackIndicator(attack),
            );
          }),

          // Center icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _isDefenseActive
                  ? AppColors.epColor.withValues(alpha: 0.2)
                  : AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(
                color: _isDefenseActive ? AppColors.epColor : AppColors.border,
                width: 2,
              ),
              boxShadow: _isDefenseActive
                  ? [
                      BoxShadow(
                        color: AppColors.epColor.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              _selectedTechnique.icon,
              color: _isDefenseActive ? AppColors.epColor : AppColors.textSecondary,
              size: 32,
            ),
          )
              .animate(target: _isDefenseActive ? 1 : 0)
              .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),

          // Status text
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _underAttack
                    ? AppColors.error.withValues(alpha: 0.2)
                    : _isDefenseActive
                        ? AppColors.epColor.withValues(alpha: 0.2)
                        : AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _underAttack
                      ? AppColors.error
                      : _isDefenseActive
                          ? AppColors.epColor
                          : AppColors.border,
                ),
              ),
              child: Text(
                _underAttack
                    ? '⚠️ กำลังถูกโจมตี!'
                    : _isDefenseActive
                        ? '🛡️ ป้องกันอยู่'
                        : '⏸️ รอเปิดใช้งาน',
                style: AppTextStyles.labelMedium.copyWith(
                  color: _underAttack
                      ? AppColors.error
                      : _isDefenseActive
                          ? AppColors.epColor
                          : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttackIndicator(JammingAttack attack) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: attack.isBlocked
            ? AppColors.success.withValues(alpha: 0.8)
            : AppColors.error.withValues(alpha: 0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (attack.isBlocked ? AppColors.success : AppColors.error)
                .withValues(alpha: 0.5),
            blurRadius: 8,
          ),
        ],
      ),
      child: Icon(
        attack.isBlocked ? Icons.check : Icons.flash_on,
        color: Colors.white,
        size: 16,
      ),
    ).animate().scale().fadeIn();
  }

  Widget _buildTechniqueSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'เทคนิค ECCM',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ECCMTechnique.values.where((t) => t != ECCMTechnique.none).map((technique) {
            final isSelected = _selectedTechnique == technique;
            return GestureDetector(
              onTap: () {
                if (!_isDefenseActive) {
                  setState(() {
                    _selectedTechnique = technique;
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.epColor.withValues(alpha: 0.2)
                      : AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.epColor : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.epColor.withValues(alpha: 0.2),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      technique.icon,
                      color: isSelected ? AppColors.epColor : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      technique.nameTh,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isSelected ? AppColors.epColor : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        // Description
        if (_selectedTechnique != ECCMTechnique.none) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.epColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.epColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedTechnique.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1),
        ],
      ],
    );
  }

  Widget _buildFrequencyDisplay() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.epColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.swap_horiz, color: AppColors.epColor, size: 18),
              const SizedBox(width: 8),
              Text(
                'Frequency Hopping',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.epColor,
                ),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _hopController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.epColor.withValues(alpha: 0.2 + _hopController.value * 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentFrequency.toInt()} MHz',
                      style: AppTextStyles.codeMedium.copyWith(
                        color: AppColors.epColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Frequency history visualization
          SizedBox(
            height: 40,
            child: Row(
              children: List.generate(10, (index) {
                final hasHistory = index < _frequencyHistory.length;
                final freq = hasHistory ? _frequencyHistory[index] : 0.0;
                final heightRatio = hasHistory ? freq / 350 : 0.0;

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    height: 40 * heightRatio,
                    decoration: BoxDecoration(
                      color: AppColors.epColor.withValues(
                        alpha: hasHistory ? 0.3 + (index / 10) * 0.5 : 0.1,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildControlButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _selectedTechnique == ECCMTechnique.none
                ? null
                : (_isDefenseActive ? _deactivateDefense : _activateDefense),
            icon: Icon(_isDefenseActive ? Icons.shield : Icons.security),
            label: Text(_isDefenseActive ? 'ปิดการป้องกัน' : 'เปิดการป้องกัน'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isDefenseActive ? AppColors.textSecondary : AppColors.epColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttackHistory() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 8),
              Text(
                'ประวัติการโจมตี',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '$_blockedAttacks/$_totalAttacks บล็อก',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: _attacks.asMap().entries.map((entry) {
              final attack = entry.value;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: attack.isBlocked
                        ? AppColors.success.withValues(alpha: 0.2)
                        : AppColors.error.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        attack.type.icon,
                        color: attack.isBlocked ? AppColors.success : AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        attack.isBlocked ? '✓' : '✗',
                        style: TextStyle(
                          color: attack.isBlocked ? AppColors.success : AppColors.error,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Shield Painter
class _ShieldPainter extends CustomPainter {
  final double shieldProgress;
  final double pulseProgress;
  final bool isActive;
  final bool underAttack;
  final ECCMTechnique technique;

  _ShieldPainter({
    required this.shieldProgress,
    required this.pulseProgress,
    required this.isActive,
    required this.underAttack,
    required this.technique,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 - 20;

    // Background circle
    final bgPaint = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, maxRadius, bgPaint);

    if (!isActive) {
      // Inactive state - simple border
      final borderPaint = Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(center, maxRadius, borderPaint);
      return;
    }

    // Shield rings
    for (int i = 1; i <= 3; i++) {
      final radius = maxRadius * (i / 3);
      final alpha = 0.1 + (i / 3) * 0.2 + pulseProgress * 0.1;

      final ringPaint = Paint()
        ..color = (underAttack ? AppColors.error : AppColors.epColor).withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawCircle(center, radius, ringPaint);
    }

    // Rotating shield segments
    final segmentPaint = Paint()
      ..color = AppColors.epColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      final startAngle = shieldProgress * 2 * math.pi + (i * math.pi / 2);
      final sweepAngle = math.pi / 4;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: maxRadius - 10),
        startAngle,
        sweepAngle,
        false,
        segmentPaint,
      );
    }

    // Outer glow
    if (isActive) {
      final glowPaint = Paint()
        ..color = (underAttack ? AppColors.error : AppColors.epColor).withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      canvas.drawCircle(center, maxRadius, glowPaint);
    }

    // Border
    final borderPaint = Paint()
      ..color = underAttack ? AppColors.error : AppColors.epColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, maxRadius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _ShieldPainter oldDelegate) {
    return true;
  }
}

/// Models
class JammingAttack {
  final double frequency;
  final double power;
  final JammingAttackType type;
  bool isBlocked;

  JammingAttack({
    required this.frequency,
    required this.power,
    required this.type,
    this.isBlocked = false,
  });
}

enum JammingAttackType {
  spot,
  barrage,
  sweep;

  IconData get icon {
    switch (this) {
      case JammingAttackType.spot:
        return Icons.gps_fixed;
      case JammingAttackType.barrage:
        return Icons.waves;
      case JammingAttackType.sweep:
        return Icons.sync;
    }
  }
}

enum ECCMTechnique {
  none,
  fhss,
  spreadSpectrum,
  adaptiveFiltering,
  powerControl;

  String get nameTh {
    switch (this) {
      case ECCMTechnique.none:
        return 'ไม่เลือก';
      case ECCMTechnique.fhss:
        return 'FHSS';
      case ECCMTechnique.spreadSpectrum:
        return 'Spread Spectrum';
      case ECCMTechnique.adaptiveFiltering:
        return 'Adaptive Filter';
      case ECCMTechnique.powerControl:
        return 'Power Control';
    }
  }

  String get description {
    switch (this) {
      case ECCMTechnique.none:
        return '';
      case ECCMTechnique.fhss:
        return 'กระโดดความถี่อย่างรวดเร็ว ทำให้ข้าศึกตามรบกวนไม่ทัน';
      case ECCMTechnique.spreadSpectrum:
        return 'กระจายสัญญาณในแถบกว้าง ลดผลกระทบจากการรบกวน';
      case ECCMTechnique.adaptiveFiltering:
        return 'กรองสัญญาณรบกวนออกโดยอัตโนมัติ';
      case ECCMTechnique.powerControl:
        return 'ปรับกำลังส่งเพื่อเอาชนะการรบกวน';
    }
  }

  IconData get icon {
    switch (this) {
      case ECCMTechnique.none:
        return Icons.block;
      case ECCMTechnique.fhss:
        return Icons.swap_horiz;
      case ECCMTechnique.spreadSpectrum:
        return Icons.unfold_more;
      case ECCMTechnique.adaptiveFiltering:
        return Icons.filter_alt;
      case ECCMTechnique.powerControl:
        return Icons.power;
    }
  }
}

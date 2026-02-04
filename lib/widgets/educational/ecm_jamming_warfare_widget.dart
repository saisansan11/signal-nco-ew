import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../app/constants.dart';

/// ECM Jamming Warfare Widget - จำลองการรบกวนสัญญาณ
/// Animation ว้าว: คลื่นสัญญาณ, การรบกวน, Visual interference
class ECMJammingWarfareWidget extends StatefulWidget {
  final VoidCallback? onComplete;

  const ECMJammingWarfareWidget({super.key, this.onComplete});

  @override
  State<ECMJammingWarfareWidget> createState() => _ECMJammingWarfareWidgetState();
}

class _ECMJammingWarfareWidgetState extends State<ECMJammingWarfareWidget>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _jammingController;
  late AnimationController _interferenceController;

  JammingType _selectedJamming = JammingType.none;
  double _jammingPower = 0.5;
  double _targetFrequency = 150.0;
  bool _isJamming = false;
  int _successCount = 0;

  final List<EnemySignal> _enemySignals = [
    EnemySignal(frequency: 100, name: 'เรดาร์ข้าศึก A', type: 'Pulse'),
    EnemySignal(frequency: 200, name: 'วิทยุข้าศึก B', type: 'FM'),
    EnemySignal(frequency: 300, name: 'ดาต้าลิงค์ C', type: 'OFDM'),
  ];

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _jammingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _interferenceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  void _startJamming() {
    if (_selectedJamming == JammingType.none) return;

    setState(() {
      _isJamming = true;
    });

    _jammingController.repeat(reverse: true);
    _interferenceController.repeat();

    // Check if jamming is effective
    Future.delayed(const Duration(seconds: 2), () {
      _checkJammingEffectiveness();
    });
  }

  void _stopJamming() {
    setState(() {
      _isJamming = false;
    });
    _jammingController.stop();
    _interferenceController.stop();
  }

  void _checkJammingEffectiveness() {
    for (final signal in _enemySignals) {
      final isInRange = _isFrequencyInRange(signal.frequency);
      if (isInRange && !signal.isJammed) {
        setState(() {
          signal.isJammed = true;
          _successCount++;
        });
      }
    }

    if (_enemySignals.every((s) => s.isJammed)) {
      widget.onComplete?.call();
    }
  }

  bool _isFrequencyInRange(double frequency) {
    switch (_selectedJamming) {
      case JammingType.spot:
        return (frequency - _targetFrequency).abs() < 20;
      case JammingType.barrage:
        return true; // Covers all frequencies
      case JammingType.sweep:
        return true; // Sweeps across all
      case JammingType.none:
        return false;
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _jammingController.dispose();
    _interferenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.eaColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.eaColor.withValues(alpha: 0.1),
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

          // Spectrum Display
          _buildSpectrumDisplay(),
          const SizedBox(height: 16),

          // Jamming Type Selector
          _buildJammingTypeSelector(),
          const SizedBox(height: 12),

          // Power Control
          _buildPowerControl(),
          const SizedBox(height: 16),

          // Control Button
          _buildControlButton(),

          // Enemy Signals Status
          const SizedBox(height: 16),
          _buildEnemySignalsStatus(),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.eaColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.flash_on,
            color: AppColors.eaColor,
            size: 28,
          ),
        )
            .animate(
              onPlay: (controller) => controller.repeat(reverse: true),
            )
            .shake(duration: 500.ms, hz: 3),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ECM Jamming Warfare',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.eaColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'รบกวนการสื่อสารข้าศึก',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Success Counter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppColors.eaGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.block, color: Colors.white, size: 18),
              const SizedBox(width: 4),
              Text(
                '$_successCount/${_enemySignals.length}',
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

  Widget _buildSpectrumDisplay() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AnimatedBuilder(
          animation: Listenable.merge([_waveController, _jammingController]),
          builder: (context, child) {
            return CustomPaint(
              size: const Size(double.infinity, 150),
              painter: _SpectrumPainter(
                waveProgress: _waveController.value,
                jammingProgress: _isJamming ? _jammingController.value : 0,
                jammingType: _selectedJamming,
                targetFrequency: _targetFrequency,
                jammingPower: _jammingPower,
                enemySignals: _enemySignals,
                isJamming: _isJamming,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildJammingTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ประเภทการรบกวน',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: JammingType.values.where((t) => t != JammingType.none).map((type) {
            final isSelected = _selectedJamming == type;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    if (!_isJamming) {
                      setState(() {
                        _selectedJamming = type;
                      });
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.eaColor.withValues(alpha: 0.2)
                          : AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.eaColor : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.eaColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          type.icon,
                          color: isSelected ? AppColors.eaColor : AppColors.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          type.nameTh,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isSelected ? AppColors.eaColor : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        // Jamming Type Description
        if (_selectedJamming != JammingType.none) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.eaColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.eaColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedJamming.description,
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

  Widget _buildPowerControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'กำลังส่ง (Power)',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.eaColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${(_jammingPower * 100).toInt()}%',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.eaColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.eaColor,
            inactiveTrackColor: AppColors.eaColor.withValues(alpha: 0.2),
            thumbColor: AppColors.eaColor,
            overlayColor: AppColors.eaColor.withValues(alpha: 0.2),
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: _jammingPower,
            onChanged: _isJamming
                ? null
                : (value) {
                    setState(() {
                      _jammingPower = value;
                    });
                  },
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _selectedJamming == JammingType.none
                ? null
                : (_isJamming ? _stopJamming : _startJamming),
            icon: Icon(_isJamming ? Icons.stop : Icons.flash_on),
            label: Text(_isJamming ? 'หยุดรบกวน' : 'เริ่มรบกวน'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isJamming ? AppColors.error : AppColors.eaColor,
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

  Widget _buildEnemySignalsStatus() {
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
              Icon(Icons.warning_amber, color: AppColors.warning, size: 18),
              const SizedBox(width: 8),
              Text(
                'สัญญาณข้าศึก',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(_enemySignals.length, (index) {
            final signal = _enemySignals[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: signal.isJammed ? AppColors.success : AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(
                        onPlay: signal.isJammed
                            ? null
                            : (controller) => controller.repeat(reverse: true),
                      )
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.5, 1.5),
                        duration: 500.ms,
                      ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          signal.name,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textPrimary,
                            decoration:
                                signal.isJammed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        Text(
                          '${signal.frequency.toInt()} MHz - ${signal.type}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: signal.isJammed
                          ? AppColors.success.withValues(alpha: 0.2)
                          : AppColors.error.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      signal.isJammed ? 'รบกวนแล้ว' : 'ใช้งานอยู่',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: signal.isJammed ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate(delay: (index * 100).ms).fadeIn().slideX(begin: 0.1);
          }),
        ],
      ),
    );
  }
}

/// Spectrum Painter
class _SpectrumPainter extends CustomPainter {
  final double waveProgress;
  final double jammingProgress;
  final JammingType jammingType;
  final double targetFrequency;
  final double jammingPower;
  final List<EnemySignal> enemySignals;
  final bool isJamming;

  _SpectrumPainter({
    required this.waveProgress,
    required this.jammingProgress,
    required this.jammingType,
    required this.targetFrequency,
    required this.jammingPower,
    required this.enemySignals,
    required this.isJamming,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    for (int i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(0, size.height * i / 4),
        Offset(size.width, size.height * i / 4),
        gridPaint,
      );
    }

    for (int i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(size.width * i / 4, 0),
        Offset(size.width * i / 4, size.height),
        gridPaint,
      );
    }

    // Enemy signals
    for (final signal in enemySignals) {
      final x = (signal.frequency / 400) * size.width;
      final signalColor = signal.isJammed
          ? AppColors.textSecondary.withValues(alpha: 0.3)
          : AppColors.accentBlue;

      // Signal peak
      final signalPaint = Paint()
        ..color = signalColor
        ..style = PaintingStyle.fill;

      final signalPath = Path();
      final peakHeight = signal.isJammed
          ? size.height * 0.2
          : size.height * 0.6 + math.sin(waveProgress * math.pi * 2) * 10;

      signalPath.moveTo(x - 15, size.height);
      signalPath.lineTo(x, size.height - peakHeight);
      signalPath.lineTo(x + 15, size.height);
      signalPath.close();

      canvas.drawPath(signalPath, signalPaint);

      // Signal glow
      if (!signal.isJammed) {
        final glowPaint = Paint()
          ..color = signalColor.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawPath(signalPath, glowPaint);
      }
    }

    // Jamming visualization
    if (isJamming) {
      switch (jammingType) {
        case JammingType.spot:
          _drawSpotJamming(canvas, size);
          break;
        case JammingType.barrage:
          _drawBarrageJamming(canvas, size);
          break;
        case JammingType.sweep:
          _drawSweepJamming(canvas, size);
          break;
        case JammingType.none:
          break;
      }
    }

    // Frequency labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int f = 0; f <= 400; f += 100) {
      textPainter.text = TextSpan(
        text: '${f}MHz',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset((f / 400) * size.width - textPainter.width / 2, size.height - 15),
      );
    }
  }

  void _drawSpotJamming(Canvas canvas, Size size) {
    final x = (targetFrequency / 400) * size.width;
    final jammingPaint = Paint()
      ..color = AppColors.eaColor.withValues(alpha: jammingPower * 0.6)
      ..style = PaintingStyle.fill;

    // Spot jamming cone
    final path = Path();
    path.moveTo(x - 30, size.height);
    path.lineTo(x, size.height * 0.3 * (1 + jammingProgress * 0.2));
    path.lineTo(x + 30, size.height);
    path.close();

    canvas.drawPath(path, jammingPaint);

    // Glow effect
    final glowPaint = Paint()
      ..color = AppColors.eaColor.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawPath(path, glowPaint);
  }

  void _drawBarrageJamming(Canvas canvas, Size size) {
    final jammingPaint = Paint()
      ..color = AppColors.eaColor.withValues(alpha: jammingPower * 0.4)
      ..style = PaintingStyle.fill;

    // Full spectrum noise
    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x < size.width; x += 5) {
      final noiseHeight = size.height * 0.5 * jammingPower *
          (0.5 + 0.5 * math.sin(x * 0.1 + waveProgress * math.pi * 4));
      path.lineTo(x, size.height - noiseHeight * (0.8 + jammingProgress * 0.2));
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, jammingPaint);
  }

  void _drawSweepJamming(Canvas canvas, Size size) {
    final sweepX = waveProgress * size.width;
    final jammingPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.eaColor.withValues(alpha: jammingPower * 0.6),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(sweepX - 50, 0, 100, size.height));

    canvas.drawRect(
      Rect.fromLTWH(sweepX - 50, 0, 100, size.height),
      jammingPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SpectrumPainter oldDelegate) {
    return true;
  }
}

/// Models
class EnemySignal {
  final double frequency;
  final String name;
  final String type;
  bool isJammed;

  EnemySignal({
    required this.frequency,
    required this.name,
    required this.type,
    this.isJammed = false,
  });
}

enum JammingType {
  none,
  spot,
  barrage,
  sweep;

  String get nameTh {
    switch (this) {
      case JammingType.none:
        return 'ไม่เลือก';
      case JammingType.spot:
        return 'Spot';
      case JammingType.barrage:
        return 'Barrage';
      case JammingType.sweep:
        return 'Sweep';
    }
  }

  String get description {
    switch (this) {
      case JammingType.none:
        return '';
      case JammingType.spot:
        return 'รบกวนความถี่เดียวด้วยกำลังสูง - เหมาะกับเป้าหมายเฉพาะ';
      case JammingType.barrage:
        return 'รบกวนแถบกว้าง - ครอบคลุมหลายความถี่พร้อมกัน';
      case JammingType.sweep:
        return 'กวาดรบกวนต่อเนื่อง - ค้นหาและรบกวนอัตโนมัติ';
    }
  }

  IconData get icon {
    switch (this) {
      case JammingType.none:
        return Icons.block;
      case JammingType.spot:
        return Icons.gps_fixed;
      case JammingType.barrage:
        return Icons.waves;
      case JammingType.sweep:
        return Icons.sync;
    }
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/constants.dart';
import '../../widgets/tutorial/tutorial_overlay.dart';
import '../../widgets/tutorial/simulation_tutorials.dart';

class JammingSimScreen extends StatefulWidget {
  const JammingSimScreen({super.key});

  @override
  State<JammingSimScreen> createState() => _JammingSimScreenState();
}

class _JammingSimScreenState extends State<JammingSimScreen>
    with TickerProviderStateMixin {
  late AnimationController _jammingController;
  late AnimationController _signalController;

  JammingType _jammingType = JammingType.spot;
  double _jammingPower = 50.0; // 0-100
  double _targetFrequency = 150.0; // MHz
  double _jammingBandwidth = 10.0; // MHz
  bool _isJamming = false;
  double _jsRatio = 0; // dB

  final double _signalPower = -60.0; // dBm (fixed target signal)
  final double _signalFrequency = 150.0; // MHz

  @override
  void initState() {
    super.initState();
    _jammingController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..repeat();

    _signalController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _calculateJSRatio();
  }

  void _calculateJSRatio() {
    // Calculate J/S ratio based on jamming parameters
    if (!_isJamming) {
      setState(() => _jsRatio = -999);
      return;
    }

    // Distance factor (simplified - assume constant distance)
    final distanceFactor = 1.0;

    // Power factor
    final jammingPowerDb = -80 + _jammingPower * 0.8; // -80 to 0 dBm

    // Frequency match factor (how well jamming frequency matches signal)
    final freqDiff = (_targetFrequency - _signalFrequency).abs();
    double freqFactor;

    switch (_jammingType) {
      case JammingType.spot:
        freqFactor = freqDiff < 2 ? 1.0 : (freqDiff < 5 ? 0.5 : 0.1);
        break;
      case JammingType.barrage:
        // Barrage covers wide bandwidth
        freqFactor = freqDiff < _jammingBandwidth / 2 ? 0.6 : 0.2;
        break;
      case JammingType.sweep:
        // Sweep hits intermittently
        freqFactor = freqDiff < 20 ? 0.4 : 0.1;
        break;
    }

    // Calculate J/S ratio
    final jsDb = (jammingPowerDb - _signalPower) * distanceFactor * freqFactor;
    setState(() => _jsRatio = jsDb);
  }

  void _toggleJamming() {
    setState(() {
      _isJamming = !_isJamming;
    });
    _calculateJSRatio();
  }

  String _getEffectivenessText() {
    if (!_isJamming) return 'ไม่ได้รบกวน';
    if (_jsRatio > 10) return 'รบกวนได้ผลดีมาก';
    if (_jsRatio > 3) return 'รบกวนได้ผล';
    if (_jsRatio > 0) return 'รบกวนได้บางส่วน';
    if (_jsRatio > -10) return 'รบกวนได้น้อย';
    return 'ไม่มีผล';
  }

  Color _getEffectivenessColor() {
    if (!_isJamming) return AppColors.textMuted;
    if (_jsRatio > 10) return AppColors.success;
    if (_jsRatio > 3) return AppColors.accentGreen;
    if (_jsRatio > 0) return AppColors.warning;
    if (_jsRatio > -10) return AppColors.primary;
    return AppColors.error;
  }

  @override
  void dispose() {
    _jammingController.dispose();
    _signalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TutorialOverlay(
      tutorialKey: 'jamming_sim',
      steps: SimulationTutorials.jammingTutorial,
      primaryColor: AppColors.eaColor,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('จำลองการรบกวน'),
          backgroundColor: AppColors.surface,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('tutorial_jamming_sim', false);
                if (mounted) setState(() {});
              },
              tooltip: 'ดูคำแนะนำ',
            ),
          ],
        ),
        body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Signal visualization
              Container(
                margin: const EdgeInsets.all(AppSizes.paddingM),
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0A),
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  border: Border.all(
                    color: AppColors.eaColor.withAlpha(100),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL - 2),
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _jammingController,
                      _signalController,
                    ]),
                    builder: (context, child) {
                      return CustomPaint(
                        painter: JammingVisualizationPainter(
                          jammingType: _jammingType,
                          isJamming: _isJamming,
                          jammingPower: _jammingPower,
                          targetFrequency: _targetFrequency,
                          signalFrequency: _signalFrequency,
                          jammingBandwidth: _jammingBandwidth,
                          animationValue: _jammingController.value,
                          signalAnimValue: _signalController.value,
                        ),
                        size: Size.infinite,
                      );
                    },
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms),

              // J/S Ratio display
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                ),
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: _getEffectivenessColor().withAlpha(30),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(
                    color: _getEffectivenessColor().withAlpha(100),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'J/S Ratio',
                          style: AppTextStyles.labelMedium,
                        ),
                        Text(
                          _isJamming && _jsRatio > -100
                              ? '${_jsRatio.toStringAsFixed(1)} dB'
                              : '-- dB',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: _getEffectivenessColor(),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getEffectivenessColor(),
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      ),
                      child: Text(
                        _getEffectivenessText(),
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

              const SizedBox(height: 16),

              // Jamming type selector
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ประเภทการรบกวน',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: JammingType.values.map((type) {
                        final isSelected = _jammingType == type;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() => _jammingType = type);
                                  _calculateJSRatio();
                                },
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusM,
                                ),
                                child: AnimatedContainer(
                                  duration: AppDurations.fast,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? type.color.withAlpha(40)
                                        : AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusM,
                                    ),
                                    border: Border.all(
                                      color: isSelected
                                          ? type.color
                                          : AppColors.border,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        type.icon,
                                        color: isSelected
                                            ? type.color
                                            : AppColors.textMuted,
                                        size: 28,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        type.titleTh,
                                        style: AppTextStyles.labelSmall.copyWith(
                                          color: isSelected
                                              ? type.color
                                              : AppColors.textSecondary,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 300.ms),

              const SizedBox(height: 16),

              // Jamming type description
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                ),
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(
                    color: _jammingType.color.withAlpha(50),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: _jammingType.color,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _jammingType.titleTh,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: _jammingType.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _jammingType.descriptionTh,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Controls
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                ),
                child: Column(
                  children: [
                    // Jamming power
                    _ControlSlider(
                      label: 'กำลังส่งรบกวน',
                      value: _jammingPower,
                      min: 0,
                      max: 100,
                      unit: '%',
                      color: AppColors.eaColor,
                      onChanged: (value) {
                        setState(() => _jammingPower = value);
                        _calculateJSRatio();
                      },
                    ),

                    // Target frequency
                    _ControlSlider(
                      label: 'ความถี่เป้าหมาย',
                      value: _targetFrequency,
                      min: 100,
                      max: 200,
                      unit: 'MHz',
                      color: AppColors.spectrumColor,
                      onChanged: (value) {
                        setState(() => _targetFrequency = value);
                        _calculateJSRatio();
                      },
                    ),

                    // Bandwidth (for barrage/sweep)
                    if (_jammingType != JammingType.spot)
                      _ControlSlider(
                        label: 'แบนด์วิดท์รบกวน',
                        value: _jammingBandwidth,
                        min: 5,
                        max: 50,
                        unit: 'MHz',
                        color: AppColors.warning,
                        onChanged: (value) {
                          setState(() => _jammingBandwidth = value);
                          _calculateJSRatio();
                        },
                      ),
                  ],
                ),
              ).animate(delay: 300.ms).fadeIn(duration: 300.ms),

              // Signal info
              Container(
                margin: const EdgeInsets.all(AppSizes.paddingM),
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'สัญญาณเป้าหมาย',
                          style: AppTextStyles.labelSmall,
                        ),
                        Text(
                          '${_signalFrequency.toInt()} MHz @ ${_signalPower.toInt()} dBm',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Jamming button
              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeightL,
                  child: ElevatedButton.icon(
                    onPressed: _toggleJamming,
                    icon: Icon(_isJamming ? Icons.stop : Icons.flash_on),
                    label: Text(_isJamming ? 'หยุดรบกวน' : 'เริ่มรบกวน'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isJamming ? AppColors.error : AppColors.eaColor,
                    ),
                  ),
                ),
              ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class _ControlSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final Color color;
  final ValueChanged<double> onChanged;

  const _ControlSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppTextStyles.labelMedium),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              activeColor: color,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              '${value.toInt()} $unit',
              style: AppTextStyles.labelMedium.copyWith(
                color: color,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

/// Jamming visualization painter
class JammingVisualizationPainter extends CustomPainter {
  final JammingType jammingType;
  final bool isJamming;
  final double jammingPower;
  final double targetFrequency;
  final double signalFrequency;
  final double jammingBandwidth;
  final double animationValue;
  final double signalAnimValue;

  final math.Random _random = math.Random();

  JammingVisualizationPainter({
    required this.jammingType,
    required this.isJamming,
    required this.jammingPower,
    required this.targetFrequency,
    required this.signalFrequency,
    required this.jammingBandwidth,
    required this.animationValue,
    required this.signalAnimValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid
    _drawGrid(canvas, size);

    // Draw original signal
    _drawSignal(canvas, size);

    // Draw jamming effect
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
      }
    }

    // Draw frequency scale
    _drawFrequencyScale(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.green.withAlpha(30)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 10; i++) {
      final x = size.width * i / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (int i = 0; i <= 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawSignal(Canvas canvas, Size size) {
    final signalX = ((signalFrequency - 100) / 100) * size.width;
    final signalHeight = size.height * 0.5; // -60 dBm

    // Signal glow
    final glowPaint = Paint()
      ..color = Colors.green.withAlpha(50)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(
      Offset(signalX, size.height - signalHeight),
      20,
      glowPaint,
    );

    // Signal peak
    final signalPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(signalX - 20, size.height * 0.9);
    path.quadraticBezierTo(
      signalX - 5,
      size.height - signalHeight + 20,
      signalX,
      size.height - signalHeight,
    );
    path.quadraticBezierTo(
      signalX + 5,
      size.height - signalHeight + 20,
      signalX + 20,
      size.height * 0.9,
    );

    canvas.drawPath(path, signalPaint);

    // Fill
    final fillPath = Path.from(path);
    fillPath.lineTo(signalX + 20, size.height);
    fillPath.lineTo(signalX - 20, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.green.withAlpha(100),
          Colors.green.withAlpha(20),
        ],
      ).createShader(Rect.fromLTWH(signalX - 20, 0, 40, size.height));

    canvas.drawPath(fillPath, fillPaint);
  }

  void _drawSpotJamming(Canvas canvas, Size size) {
    final jammingX = ((targetFrequency - 100) / 100) * size.width;
    final jammingHeight = size.height * (jammingPower / 100) * 0.8;

    // Jamming noise
    final noisePaint = Paint()
      ..color = Colors.red.withAlpha(150)
      ..strokeWidth = 1.5;

    for (int i = -10; i <= 10; i++) {
      final x = jammingX + i * 2;
      final noise = _random.nextDouble() * jammingHeight;
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x, size.height - noise),
        noisePaint,
      );
    }

    // Center spike
    final spikePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3;

    canvas.drawLine(
      Offset(jammingX, size.height),
      Offset(jammingX, size.height - jammingHeight),
      spikePaint,
    );
  }

  void _drawBarrageJamming(Canvas canvas, Size size) {
    final centerX = ((targetFrequency - 100) / 100) * size.width;
    final halfBandwidth = (jammingBandwidth / 100) * size.width / 2;
    final jammingHeight = size.height * (jammingPower / 100) * 0.6;

    // Barrage noise across bandwidth
    final noisePaint = Paint()
      ..color = Colors.red.withAlpha(100)
      ..strokeWidth = 2;

    for (double x = centerX - halfBandwidth;
        x <= centerX + halfBandwidth;
        x += 3) {
      final noise = _random.nextDouble() * jammingHeight;
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x, size.height - noise),
        noisePaint,
      );
    }

    // Border indicators
    final borderPaint = Paint()
      ..color = Colors.red.withAlpha(100)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(centerX - halfBandwidth, 0),
      Offset(centerX - halfBandwidth, size.height),
      borderPaint,
    );
    canvas.drawLine(
      Offset(centerX + halfBandwidth, 0),
      Offset(centerX + halfBandwidth, size.height),
      borderPaint,
    );
  }

  void _drawSweepJamming(Canvas canvas, Size size) {
    final centerX = ((targetFrequency - 100) / 100) * size.width;
    final halfBandwidth = (jammingBandwidth / 100) * size.width / 2;
    final jammingHeight = size.height * (jammingPower / 100) * 0.7;

    // Sweep position
    final sweepPhase = animationValue * 2 * math.pi;
    final sweepOffset = math.sin(sweepPhase) * halfBandwidth;
    final sweepX = centerX + sweepOffset;

    // Trail
    final trailPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.red.withAlpha(0),
          Colors.red.withAlpha(100),
        ],
        begin: sweepOffset > 0 ? Alignment.centerLeft : Alignment.centerRight,
        end: sweepOffset > 0 ? Alignment.centerRight : Alignment.centerLeft,
      ).createShader(
        Rect.fromLTWH(
          sweepOffset > 0 ? sweepX - 30 : sweepX,
          0,
          30,
          size.height,
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(
        sweepOffset > 0 ? sweepX - 30 : sweepX,
        size.height - jammingHeight,
        30,
        jammingHeight,
      ),
      trailPaint,
    );

    // Sweep line
    final sweepPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3;

    for (int i = -3; i <= 3; i++) {
      final noise = _random.nextDouble() * 20;
      canvas.drawLine(
        Offset(sweepX + i * 2, size.height),
        Offset(sweepX + i * 2, size.height - jammingHeight - noise),
        sweepPaint..color = Colors.red.withAlpha(200 - (i.abs() * 50)),
      );
    }

    // Sweep range indicator
    final rangePaint = Paint()
      ..color = Colors.red.withAlpha(50)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(centerX - halfBandwidth, size.height * 0.1),
      Offset(centerX + halfBandwidth, size.height * 0.1),
      rangePaint,
    );
  }

  void _drawFrequencyScale(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int freq = 100; freq <= 200; freq += 20) {
      final x = ((freq - 100) / 100) * size.width;
      textPainter.text = TextSpan(
        text: '$freq',
        style: TextStyle(
          color: Colors.green.withAlpha(150),
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - 15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant JammingVisualizationPainter oldDelegate) {
    return oldDelegate.isJamming != isJamming ||
        oldDelegate.jammingType != jammingType ||
        oldDelegate.jammingPower != jammingPower ||
        oldDelegate.targetFrequency != targetFrequency ||
        oldDelegate.animationValue != animationValue;
  }
}

/// Jamming type
enum JammingType {
  spot,
  barrage,
  sweep,
}

extension JammingTypeExtension on JammingType {
  String get titleTh {
    switch (this) {
      case JammingType.spot:
        return 'Spot';
      case JammingType.barrage:
        return 'Barrage';
      case JammingType.sweep:
        return 'Sweep';
    }
  }

  String get descriptionTh {
    switch (this) {
      case JammingType.spot:
        return 'การรบกวนจุด - รบกวนความถี่เดียวด้วยกำลังส่งสูง เหมาะกับเป้าหมายที่ใช้ความถี่คงที่';
      case JammingType.barrage:
        return 'การรบกวนกว้าง - รบกวนช่วงความถี่กว้างพร้อมกัน กำลังกระจายตัว เหมาะกับหลายเป้าหมาย';
      case JammingType.sweep:
        return 'การรบกวนกวาด - เลื่อนความถี่รบกวนไปมา เหมาะกับเป้าหมายที่กระโดดความถี่';
    }
  }

  IconData get icon {
    switch (this) {
      case JammingType.spot:
        return Icons.gps_fixed;
      case JammingType.barrage:
        return Icons.view_week;
      case JammingType.sweep:
        return Icons.swap_horiz;
    }
  }

  Color get color {
    switch (this) {
      case JammingType.spot:
        return AppColors.error;
      case JammingType.barrage:
        return AppColors.warning;
      case JammingType.sweep:
        return AppColors.primary;
    }
  }
}

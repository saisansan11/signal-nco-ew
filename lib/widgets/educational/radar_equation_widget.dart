import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/constants.dart';

/// Radar Range Equation Calculator Widget
/// Helps students understand how radar detection range is calculated
class RadarEquationWidget extends StatefulWidget {
  const RadarEquationWidget({super.key});

  @override
  State<RadarEquationWidget> createState() => _RadarEquationWidgetState();
}

class _RadarEquationWidgetState extends State<RadarEquationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;

  // Adjustable parameters
  double _transmitPower = 1000; // Watts (100 - 10000)
  double _antennaGain = 30; // dBi (10 - 50)
  double _targetRCS = 1; // m² (0.1 - 100)
  double _frequency = 10; // GHz (1 - 40)

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  // Calculate radar detection range using simplified radar equation
  double _calculateRange() {
    // Simplified radar range equation:
    // R = (Pt * G² * λ² * σ / (4π)³ * Smin)^(1/4)
    // Simplified version: R ∝ (Pt * G² * σ)^(1/4)

    final gainLinear = math.pow(10, _antennaGain / 10);
    final wavelength = 0.3 / _frequency; // λ = c/f (in meters)

    // Simplified calculation for demonstration
    final numerator = _transmitPower *
        math.pow(gainLinear, 2) *
        math.pow(wavelength, 2) *
        _targetRCS;
    final denominator = math.pow(4 * math.pi, 3) * 1e-12; // Smin approximation

    final range = math.pow(numerator / denominator, 0.25) / 1000; // km
    return range.clamp(1, 500);
  }

  @override
  Widget build(BuildContext context) {
    final range = _calculateRange();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.radarColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Icon(Icons.radar, color: AppColors.radarColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'คำนวณระยะเรดาร์',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Radar visualization
          SizedBox(
            height: 150,
            child: AnimatedBuilder(
              animation: _radarController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 150),
                  painter: _RadarSweepPainter(
                    progress: _radarController.value,
                    range: range,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Result display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.radarColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(
                color: AppColors.radarColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ระยะตรวจจับ: ',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${range.toStringAsFixed(1)} km',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.radarColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
          const SizedBox(height: 20),

          // Parameter sliders
          _buildSlider(
            label: 'กำลังส่ง (Pt)',
            value: _transmitPower,
            min: 100,
            max: 10000,
            unit: 'W',
            color: AppColors.eaColor,
            onChanged: (v) => setState(() => _transmitPower = v),
          ),
          _buildSlider(
            label: 'อัตราขยายเสาอากาศ (G)',
            value: _antennaGain,
            min: 10,
            max: 50,
            unit: 'dBi',
            color: AppColors.esColor,
            onChanged: (v) => setState(() => _antennaGain = v),
          ),
          _buildSlider(
            label: 'พื้นที่หน้าตัดเรดาร์ (σ)',
            value: _targetRCS,
            min: 0.1,
            max: 100,
            unit: 'm²',
            color: AppColors.epColor,
            onChanged: (v) => setState(() => _targetRCS = v),
          ),
          _buildSlider(
            label: 'ความถี่ (f)',
            value: _frequency,
            min: 1,
            max: 40,
            unit: 'GHz',
            color: AppColors.spectrumColor,
            onChanged: (v) => setState(() => _frequency = v),
          ),

          const SizedBox(height: 12),

          // Tips
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.info, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'เพิ่มกำลังส่งและอัตราขยาย = ระยะไกลขึ้น\nเป้าหมายเล็ก (RCS ต่ำ) = ตรวจจับยากขึ้น',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${value.toStringAsFixed(value < 10 ? 1 : 0)} $unit',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.2),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.1),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarSweepPainter extends CustomPainter {
  final double progress;
  final double range;

  _RadarSweepPainter({
    required this.progress,
    required this.range,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final maxRadius = size.height * 0.9;

    // Draw range rings
    final ringPaint = Paint()
      ..color = AppColors.radarColor.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 1; i <= 4; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: maxRadius * i / 4),
        math.pi,
        math.pi,
        false,
        ringPaint,
      );
    }

    // Draw sweep
    final sweepAngle = progress * math.pi;
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.bottomCenter,
        startAngle: math.pi + sweepAngle - 0.3,
        endAngle: math.pi + sweepAngle,
        colors: [
          AppColors.radarColor.withValues(alpha: 0),
          AppColors.radarColor.withValues(alpha: 0.5),
          AppColors.radarColor,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: maxRadius),
      math.pi,
      math.pi,
      true,
      sweepPaint,
    );

    // Draw target blip based on range
    final normalizedRange = (range / 500).clamp(0.1, 1.0);
    final targetRadius = maxRadius * normalizedRange;
    final targetAngle = math.pi + math.pi * 0.3; // Fixed position

    final targetX = center.dx + targetRadius * math.cos(targetAngle);
    final targetY = center.dy + targetRadius * math.sin(targetAngle);

    // Blip glow effect
    if ((progress * math.pi - (targetAngle - math.pi)).abs() < 0.5) {
      final glowPaint = Paint()
        ..color = AppColors.success.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(Offset(targetX, targetY), 8, glowPaint);
    }

    // Target blip
    final blipPaint = Paint()..color = AppColors.success;
    canvas.drawCircle(Offset(targetX, targetY), 4, blipPaint);

    // Range labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 1; i <= 4; i++) {
      final labelRange = (range * i / 4).toStringAsFixed(0);
      textPainter.text = TextSpan(
        text: '$labelRange km',
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(center.dx + 4, center.dy - maxRadius * i / 4 - 12),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarSweepPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.range != range;
  }
}

/// J/S Ratio Calculator Widget
/// Helps students understand jamming effectiveness
class JSRatioWidget extends StatefulWidget {
  const JSRatioWidget({super.key});

  @override
  State<JSRatioWidget> createState() => _JSRatioWidgetState();
}

class _JSRatioWidgetState extends State<JSRatioWidget> {
  double _jammerPower = 100; // Watts
  double _jammerDistance = 10; // km
  double _signalPower = 1000; // Watts
  double _signalDistance = 50; // km

  double _calculateJSRatio() {
    // J/S = (Pj / Ps) * (Rs / Rj)²
    // Simplified: ratio of received powers considering distance
    final jammerReceived =
        _jammerPower / math.pow(_jammerDistance * 1000, 2);
    final signalReceived =
        _signalPower / math.pow(_signalDistance * 1000, 2);

    if (signalReceived == 0) return 0;
    return jammerReceived / signalReceived;
  }

  String _getEffectiveness(double jsRatio) {
    if (jsRatio >= 10) return 'รบกวนได้ผลดีมาก';
    if (jsRatio >= 1) return 'รบกวนได้ผล';
    if (jsRatio >= 0.1) return 'รบกวนได้บ้าง';
    return 'ไม่มีผล';
  }

  Color _getEffectivenessColor(double jsRatio) {
    if (jsRatio >= 10) return AppColors.success;
    if (jsRatio >= 1) return AppColors.esColor;
    if (jsRatio >= 0.1) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final jsRatio = _calculateJSRatio();
    final effectiveness = _getEffectiveness(jsRatio);
    final effectivenessColor = _getEffectivenessColor(jsRatio);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.eaColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, color: AppColors.eaColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'คำนวณ J/S Ratio',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Visual representation
          SizedBox(
            height: 100,
            child: CustomPaint(
              size: const Size(double.infinity, 100),
              painter: _JSRatioPainter(
                jammerDistance: _jammerDistance,
                signalDistance: _signalDistance,
                jsRatio: jsRatio,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Result
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: effectivenessColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(
                color: effectivenessColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'J/S = ${jsRatio.toStringAsFixed(2)}',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: effectivenessColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  effectiveness,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: effectivenessColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sliders
          Text(
            '📻 เครื่องรบกวน (Jammer)',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.bold,
            ),
          ),
          _buildSlider(
            label: 'กำลังส่ง',
            value: _jammerPower,
            min: 10,
            max: 1000,
            unit: 'W',
            color: AppColors.warning,
            onChanged: (v) => setState(() => _jammerPower = v),
          ),
          _buildSlider(
            label: 'ระยะห่างจากเป้า',
            value: _jammerDistance,
            min: 1,
            max: 100,
            unit: 'km',
            color: AppColors.warning,
            onChanged: (v) => setState(() => _jammerDistance = v),
          ),

          const SizedBox(height: 8),

          Text(
            '📡 สัญญาณข้าศึก (Signal)',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          _buildSlider(
            label: 'กำลังส่ง',
            value: _signalPower,
            min: 10,
            max: 10000,
            unit: 'W',
            color: AppColors.error,
            onChanged: (v) => setState(() => _signalPower = v),
          ),
          _buildSlider(
            label: 'ระยะห่างจากเป้า',
            value: _signalDistance,
            min: 1,
            max: 200,
            unit: 'km',
            color: AppColors.error,
            onChanged: (v) => setState(() => _signalDistance = v),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.info, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'J/S > 1 = รบกวนได้ผล\nระยะใกล้ + กำลังสูง = J/S สูงขึ้น',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: color,
                inactiveTrackColor: color.withValues(alpha: 0.2),
                thumbColor: color,
                overlayColor: color.withValues(alpha: 0.1),
                trackHeight: 3,
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              '${value.toStringAsFixed(0)} $unit',
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _JSRatioPainter extends CustomPainter {
  final double jammerDistance;
  final double signalDistance;
  final double jsRatio;

  _JSRatioPainter({
    required this.jammerDistance,
    required this.signalDistance,
    required this.jsRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final targetX = size.width / 2;
    final targetY = size.height / 2;

    // Draw target (receiver)
    final targetPaint = Paint()..color = AppColors.textPrimary;
    canvas.drawCircle(Offset(targetX, targetY), 12, targetPaint);

    // Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'เป้า',
        style: TextStyle(color: AppColors.textMuted, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(targetX - 10, targetY + 16));

    // Draw jammer (left side)
    final jammerX = targetX - (jammerDistance / 200) * (size.width / 2 - 30);
    final jammerPaint = Paint()..color = AppColors.warning;
    canvas.drawCircle(Offset(jammerX, targetY), 8, jammerPaint);

    // Jammer waves
    final wavePaint = Paint()
      ..color = AppColors.warning.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (int i = 1; i <= 3; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(jammerX, targetY), radius: 12.0 + i * 8),
        -0.5,
        1,
        false,
        wavePaint,
      );
    }

    // Draw signal source (right side)
    final signalX = targetX + (signalDistance / 200) * (size.width / 2 - 30);
    final signalPaint = Paint()..color = AppColors.error;
    canvas.drawCircle(Offset(signalX, targetY), 8, signalPaint);

    // Signal waves
    final signalWavePaint = Paint()
      ..color = AppColors.error.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (int i = 1; i <= 3; i++) {
      canvas.drawArc(
        Rect.fromCircle(
            center: Offset(signalX, targetY), radius: 12.0 + i * 8),
        math.pi - 0.5,
        1,
        false,
        signalWavePaint,
      );
    }

    // Labels
    textPainter.text = TextSpan(
      text: 'Jammer',
      style: TextStyle(color: AppColors.warning, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(jammerX - 20, targetY - 24));

    textPainter.text = TextSpan(
      text: 'Signal',
      style: TextStyle(color: AppColors.error, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(signalX - 15, targetY - 24));
  }

  @override
  bool shouldRepaint(covariant _JSRatioPainter oldDelegate) {
    return oldDelegate.jammerDistance != jammerDistance ||
        oldDelegate.signalDistance != signalDistance;
  }
}

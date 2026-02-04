import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/constants.dart';

class RadarSimScreen extends StatefulWidget {
  const RadarSimScreen({super.key});

  @override
  State<RadarSimScreen> createState() => _RadarSimScreenState();
}

class _RadarSimScreenState extends State<RadarSimScreen>
    with TickerProviderStateMixin {
  late AnimationController _sweepController;
  final List<RadarTarget> _targets = [];
  final math.Random _random = math.Random();
  int _detectedTargets = 0;
  int _totalTargets = 0;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      duration: AppDurations.radarSweep,
      vsync: this,
    );

    _sweepController.addListener(() {
      _checkTargetDetection();
    });
  }

  void _startSimulation() {
    setState(() {
      _isRunning = true;
      _detectedTargets = 0;
      _totalTargets = 5 + _random.nextInt(5); // 5-9 targets
      _targets.clear();
      _generateTargets();
    });
    _sweepController.repeat();
  }

  void _stopSimulation() {
    setState(() {
      _isRunning = false;
    });
    _sweepController.stop();
  }

  void _generateTargets() {
    for (int i = 0; i < _totalTargets; i++) {
      _targets.add(RadarTarget(
        id: i,
        angle: _random.nextDouble() * 2 * math.pi,
        distance: 0.2 + _random.nextDouble() * 0.7, // 20-90% of radius
        type: TargetType.values[_random.nextInt(TargetType.values.length)],
      ));
    }
  }

  void _checkTargetDetection() {
    if (!_isRunning) return;

    final sweepAngle = _sweepController.value * 2 * math.pi;
    const sweepWidth = 0.15; // ~8.5 degrees

    for (final target in _targets) {
      if (!target.detected) {
        final angleDiff = (target.angle - sweepAngle).abs();
        if (angleDiff < sweepWidth || (2 * math.pi - angleDiff) < sweepWidth) {
          setState(() {
            target.detected = true;
            target.detectedAt = DateTime.now();
            _detectedTargets++;
          });
        }
      }
    }

    // Check completion
    if (_detectedTargets >= _totalTargets) {
      _stopSimulation();
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 28),
            const SizedBox(width: 8),
            Text(
              'การตรวจจับเสร็จสิ้น!',
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
              'ตรวจจับเป้าหมายได้ $_detectedTargets จาก $_totalTargets',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _buildTargetSummary(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startSimulation();
            },
            child: const Text('เริ่มใหม่'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetSummary() {
    final typeCounts = <TargetType, int>{};
    for (final target in _targets) {
      typeCounts[target.type] = (typeCounts[target.type] ?? 0) + 1;
    }

    return Column(
      children: typeCounts.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: entry.key.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${entry.key.titleTh}: ${entry.value}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('จำลองเรดาร์'),
        backgroundColor: AppColors.surface,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Info bar
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              color: AppColors.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _InfoItem(
                    icon: Icons.radar,
                    label: 'เป้าหมาย',
                    value: '$_detectedTargets / $_totalTargets',
                  ),
                  _InfoItem(
                    icon: Icons.speed,
                    label: 'รอบ',
                    value: '3 วินาที',
                  ),
                  _InfoItem(
                    icon: Icons.gps_fixed,
                    label: 'ระยะ',
                    value: '100 km',
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms),

            // Radar display
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: AnimatedBuilder(
                      animation: _sweepController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: RadarDisplayPainter(
                            sweepAngle: _sweepController.value * 2 * math.pi,
                            targets: _targets,
                            radarColor: AppColors.radarColor,
                          ),
                          child: child,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 500.ms).scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1, 1),
                ),

            // Legend
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: TargetType.values.map((type) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: type.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          type.titleTh,
                          style: AppTextStyles.labelSmall,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ).animate(delay: 400.ms).fadeIn(),

            // Control button
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeightL,
                child: ElevatedButton.icon(
                  onPressed: _isRunning ? _stopSimulation : _startSimulation,
                  icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
                  label: Text(_isRunning ? 'หยุด' : 'เริ่มตรวจจับ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isRunning ? AppColors.error : AppColors.radarColor,
                  ),
                ),
              ),
            ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.radarColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall,
        ),
      ],
    );
  }
}

/// Radar display painter
class RadarDisplayPainter extends CustomPainter {
  final double sweepAngle;
  final List<RadarTarget> targets;
  final Color radarColor;

  RadarDisplayPainter({
    required this.sweepAngle,
    required this.targets,
    required this.radarColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Draw background
    final bgPaint = Paint()
      ..color = const Color(0xFF0A1A0A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw range rings
    final ringPaint = Paint()
      ..color = radarColor.withAlpha(40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * i / 4, ringPaint);
    }

    // Draw cross lines
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      ringPaint,
    );
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      ringPaint,
    );

    // Draw cardinal directions
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    void drawDirection(String text, Offset offset) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          color: radarColor.withAlpha(150),
          fontSize: 12,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        offset - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    drawDirection('N', Offset(center.dx, center.dy - radius + 15));
    drawDirection('S', Offset(center.dx, center.dy + radius - 15));
    drawDirection('E', Offset(center.dx + radius - 15, center.dy));
    drawDirection('W', Offset(center.dx - radius + 15, center.dy));

    // Draw sweep
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: sweepAngle - 0.3,
        endAngle: sweepAngle,
        colors: [
          Colors.transparent,
          radarColor.withAlpha(60),
          radarColor.withAlpha(120),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, sweepPaint);

    // Draw sweep line
    final linePaint = Paint()
      ..color = radarColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final lineEnd = Offset(
      center.dx + radius * math.cos(sweepAngle - math.pi / 2),
      center.dy + radius * math.sin(sweepAngle - math.pi / 2),
    );
    canvas.drawLine(center, lineEnd, linePaint);

    // Draw targets
    for (final target in targets) {
      if (target.detected) {
        final targetX =
            center.dx + radius * target.distance * math.cos(target.angle - math.pi / 2);
        final targetY =
            center.dy + radius * target.distance * math.sin(target.angle - math.pi / 2);

        // Calculate fade based on time since detection
        final timeSinceDetection =
            DateTime.now().difference(target.detectedAt!).inMilliseconds;
        final fade = (1.0 - (timeSinceDetection / 6000)).clamp(0.3, 1.0);

        final targetPaint = Paint()
          ..color = target.type.color.withAlpha((fade * 255).toInt())
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(targetX, targetY), 6, targetPaint);

        // Draw blip ring
        if (timeSinceDetection < 1000) {
          final ringPaint = Paint()
            ..color = target.type.color.withAlpha(((1.0 - timeSinceDetection / 1000) * 255).toInt())
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;

          final ringRadius = 6 + (timeSinceDetection / 1000) * 15;
          canvas.drawCircle(Offset(targetX, targetY), ringRadius, ringPaint);
        }
      }
    }

    // Draw center dot
    final centerPaint = Paint()
      ..color = radarColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, centerPaint);

    // Draw outer ring
    final outerRingPaint = Paint()
      ..color = radarColor.withAlpha(100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, outerRingPaint);
  }

  @override
  bool shouldRepaint(covariant RadarDisplayPainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.targets != targets;
  }
}

/// Radar target
class RadarTarget {
  final int id;
  final double angle; // radians
  final double distance; // 0-1 normalized
  final TargetType type;
  bool detected = false;
  DateTime? detectedAt;

  RadarTarget({
    required this.id,
    required this.angle,
    required this.distance,
    required this.type,
  });
}

/// Target type
enum TargetType {
  aircraft,
  vessel,
  drone,
}

extension TargetTypeExtension on TargetType {
  String get titleTh {
    switch (this) {
      case TargetType.aircraft:
        return 'อากาศยาน';
      case TargetType.vessel:
        return 'เรือ';
      case TargetType.drone:
        return 'โดรน';
    }
  }

  Color get color {
    switch (this) {
      case TargetType.aircraft:
        return AppColors.accentBlue;
      case TargetType.vessel:
        return AppColors.accentGreen;
      case TargetType.drone:
        return AppColors.warning;
    }
  }
}

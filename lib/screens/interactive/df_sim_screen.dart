import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/constants.dart';
import '../../widgets/tutorial/tutorial_overlay.dart';
import '../../widgets/tutorial/simulation_tutorials.dart';

/// Direction Finding (DF) Simulation Screen
/// จำลองการหาทิศทางแหล่งกำเนิดสัญญาณด้วย Triangulation
class DFSimScreen extends StatefulWidget {
  const DFSimScreen({super.key});

  @override
  State<DFSimScreen> createState() => _DFSimScreenState();
}

class _DFSimScreenState extends State<DFSimScreen> {
  // DF Station positions (normalized 0-1)
  final List<Offset> _stations = [
    const Offset(0.2, 0.3), // Station Alpha
    const Offset(0.8, 0.25), // Station Bravo
    const Offset(0.5, 0.8), // Station Charlie
  ];

  // Target position (hidden from user, normalized 0-1)
  Offset _targetPosition = const Offset(0.5, 0.5);

  // User's estimated position
  Offset? _estimatedPosition;

  // Bearing lines from each station
  List<double> _bearings = [0, 0, 0];

  // Game state
  int _round = 1;
  int _score = 0;
  bool _showResult = false;
  double _lastAccuracy = 0;

  @override
  void initState() {
    super.initState();
    _generateNewTarget();
  }

  void _generateNewTarget() {
    final random = math.Random();
    // Generate target in the center area (avoid edges)
    _targetPosition = Offset(
      0.25 + random.nextDouble() * 0.5,
      0.25 + random.nextDouble() * 0.5,
    );

    // Calculate actual bearings from each station to target
    for (int i = 0; i < _stations.length; i++) {
      final dx = _targetPosition.dx - _stations[i].dx;
      final dy = _targetPosition.dy - _stations[i].dy;
      // Bearing in degrees (0 = North, 90 = East)
      double bearing = math.atan2(dx, -dy) * 180 / math.pi;
      if (bearing < 0) bearing += 360;
      _bearings[i] = bearing;
    }

    _estimatedPosition = null;
    _showResult = false;
  }

  void _onMapTap(TapDownDetails details, Size size) {
    if (_showResult) return;

    setState(() {
      _estimatedPosition = Offset(
        details.localPosition.dx / size.width,
        details.localPosition.dy / size.height,
      );
    });
  }

  void _checkAnswer() {
    if (_estimatedPosition == null) return;

    // Calculate distance error (in percentage of map)
    final dx = _estimatedPosition!.dx - _targetPosition.dx;
    final dy = _estimatedPosition!.dy - _targetPosition.dy;
    final distanceError = math.sqrt(dx * dx + dy * dy);

    // Convert to accuracy percentage (closer = higher)
    // 0% error = 100 points, 50% error = 0 points
    final accuracy = math.max(0.0, (1 - distanceError * 2) * 100);
    final points = accuracy.round();

    setState(() {
      _showResult = true;
      _lastAccuracy = accuracy;
      _score += points;
    });
  }

  void _nextRound() {
    if (_round >= 5) {
      // Game over
      _showGameOverDialog();
      return;
    }

    setState(() {
      _round++;
      _generateNewTarget();
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'จบการฝึก',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _score >= 400 ? Icons.emoji_events : Icons.military_tech,
              size: 64,
              color: _score >= 400 ? Colors.amber : AppColors.esColor,
            ),
            const SizedBox(height: 16),
            Text(
              'คะแนนรวม: $_score/500',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _score >= 400
                  ? 'ยอดเยี่ยม! ทักษะ DF ระดับผู้เชี่ยวชาญ'
                  : _score >= 300
                      ? 'ดีมาก! ฝึกฝนต่อไป'
                      : 'ลองใหม่อีกครั้ง',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _round = 1;
                _score = 0;
                _generateNewTarget();
              });
            },
            child: const Text('เล่นใหม่'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('ออก'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TutorialOverlay(
      tutorialKey: 'df_sim',
      steps: SimulationTutorials.dfTutorial,
      primaryColor: AppColors.warning,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Direction Finding Simulation'),
          backgroundColor: AppColors.surface,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  'รอบ $_round/5 | คะแนน: $_score',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.esColor,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('tutorial_df_sim', false);
                if (mounted) setState(() {});
              },
              tooltip: 'ดูคำแนะนำ',
            ),
          ],
        ),
      body: Column(
        children: [
          // Instructions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Column(
              children: [
                Text(
                  'หาตำแหน่งเป้าหมายจาก Bearing ที่ได้รับ',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _BearingInfo(
                        station: 'Alpha', bearing: _bearings[0], color: Colors.red),
                    _BearingInfo(
                        station: 'Bravo', bearing: _bearings[1], color: Colors.blue),
                    _BearingInfo(
                        station: 'Charlie',
                        bearing: _bearings[2],
                        color: Colors.green),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          // Map area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(constraints.maxWidth, constraints.maxHeight);
                  return GestureDetector(
                    onTapDown: (details) => _onMapTap(details, size),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.esColor.withValues(alpha: 0.3)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CustomPaint(
                          size: size,
                          painter: DFMapPainter(
                            stations: _stations,
                            bearings: _bearings,
                            targetPosition: _showResult ? _targetPosition : null,
                            estimatedPosition: _estimatedPosition,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Result and action buttons
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Column(
              children: [
                if (_showResult) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _lastAccuracy >= 80
                            ? Icons.check_circle
                            : _lastAccuracy >= 50
                                ? Icons.warning
                                : Icons.cancel,
                        color: _lastAccuracy >= 80
                            ? Colors.green
                            : _lastAccuracy >= 50
                                ? Colors.orange
                                : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ความแม่นยำ: ${_lastAccuracy.toStringAsFixed(1)}%',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: _lastAccuracy >= 80
                              ? Colors.green
                              : _lastAccuracy >= 50
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                    ],
                  ).animate().scale(duration: 300.ms),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _estimatedPosition == null || _showResult
                            ? null
                            : _checkAnswer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.esColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'ยืนยันตำแหน่ง',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (_showResult) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _nextRound,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            _round >= 5 ? 'ดูผลรวม' : 'รอบถัดไป',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _BearingInfo extends StatelessWidget {
  final String station;
  final double bearing;
  final Color color;

  const _BearingInfo({
    required this.station,
    required this.bearing,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          station,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          '${bearing.toStringAsFixed(1)}°',
          style: AppTextStyles.titleSmall.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class DFMapPainter extends CustomPainter {
  final List<Offset> stations;
  final List<double> bearings;
  final Offset? targetPosition;
  final Offset? estimatedPosition;

  DFMapPainter({
    required this.stations,
    required this.bearings,
    this.targetPosition,
    this.estimatedPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid
    final gridPaint = Paint()
      ..color = AppColors.textMuted.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    for (int i = 0; i <= 10; i++) {
      final x = size.width * i / 10;
      final y = size.height * i / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw bearing lines from each station
    final lineColors = [Colors.red, Colors.blue, Colors.green];
    for (int i = 0; i < stations.length; i++) {
      final stationPos = Offset(
        stations[i].dx * size.width,
        stations[i].dy * size.height,
      );

      // Convert bearing to direction vector
      final bearingRad = bearings[i] * math.pi / 180;
      final lineLength = size.width * 1.5;
      final endX = stationPos.dx + math.sin(bearingRad) * lineLength;
      final endY = stationPos.dy - math.cos(bearingRad) * lineLength;

      final linePaint = Paint()
        ..color = lineColors[i].withValues(alpha: 0.5)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(stationPos, Offset(endX, endY), linePaint);
    }

    // Draw stations
    for (int i = 0; i < stations.length; i++) {
      final stationPos = Offset(
        stations[i].dx * size.width,
        stations[i].dy * size.height,
      );

      // Station circle
      final stationPaint = Paint()
        ..color = lineColors[i]
        ..style = PaintingStyle.fill;

      canvas.drawCircle(stationPos, 12, stationPaint);

      // Station label
      final textPainter = TextPainter(
        text: TextSpan(
          text: ['A', 'B', 'C'][i],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          stationPos.dx - textPainter.width / 2,
          stationPos.dy - textPainter.height / 2,
        ),
      );
    }

    // Draw estimated position (user's guess)
    if (estimatedPosition != null) {
      final estPos = Offset(
        estimatedPosition!.dx * size.width,
        estimatedPosition!.dy * size.height,
      );

      final crossPaint = Paint()
        ..color = Colors.orange
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(estPos.dx - 15, estPos.dy),
        Offset(estPos.dx + 15, estPos.dy),
        crossPaint,
      );
      canvas.drawLine(
        Offset(estPos.dx, estPos.dy - 15),
        Offset(estPos.dx, estPos.dy + 15),
        crossPaint,
      );
      canvas.drawCircle(estPos, 10, crossPaint);
    }

    // Draw actual target position (after reveal)
    if (targetPosition != null) {
      final targetPos = Offset(
        targetPosition!.dx * size.width,
        targetPosition!.dy * size.height,
      );

      final targetPaint = Paint()
        ..color = AppColors.eaColor
        ..style = PaintingStyle.fill;

      // Draw target marker (star shape)
      final path = Path();
      for (int i = 0; i < 5; i++) {
        final angle = (i * 72 - 90) * math.pi / 180;
        final x = targetPos.dx + 12 * math.cos(angle);
        final y = targetPos.dy + 12 * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
        final innerAngle = ((i * 72 + 36) - 90) * math.pi / 180;
        final innerX = targetPos.dx + 5 * math.cos(innerAngle);
        final innerY = targetPos.dy + 5 * math.sin(innerAngle);
        path.lineTo(innerX, innerY);
      }
      path.close();
      canvas.drawPath(path, targetPaint);
    }

    // Draw compass rose
    _drawCompassRose(canvas, Offset(size.width - 40, 40));
  }

  void _drawCompassRose(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = AppColors.textMuted
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, 25, paint);

    // N, E, S, W labels
    final directions = ['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2 - math.pi / 2;
      final x = center.dx + 18 * math.cos(angle);
      final y = center.dy + 18 * math.sin(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: i == 0 ? Colors.red : AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant DFMapPainter oldDelegate) {
    return oldDelegate.targetPosition != targetPosition ||
        oldDelegate.estimatedPosition != estimatedPosition;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../app/constants.dart';

/// Direction Finding Triangulation Widget
/// จำลองการหาตำแหน่งด้วยวิธี Triangulation
/// แสดง: สถานี DF, เส้น Bearing, จุดตัด, Error Ellipse
class DFTriangulationWidget extends StatefulWidget {
  final VoidCallback? onComplete;

  const DFTriangulationWidget({super.key, this.onComplete});

  @override
  State<DFTriangulationWidget> createState() => _DFTriangulationWidgetState();
}

class _DFTriangulationWidgetState extends State<DFTriangulationWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scanController;

  // DF Stations (normalized 0-1 coordinates)
  final List<DFStation> _stations = [
    DFStation(
      id: 'DF-1',
      position: const Offset(0.2, 0.7),
      color: AppColors.esColor,
      bearing: 45.0,
    ),
    DFStation(
      id: 'DF-2',
      position: const Offset(0.8, 0.7),
      color: AppColors.accentBlue,
      bearing: 135.0,
    ),
    DFStation(
      id: 'DF-3',
      position: const Offset(0.5, 0.9),
      color: AppColors.epColor,
      bearing: 90.0,
    ),
  ];

  // Target emitter (actual position)
  Offset _targetPosition = const Offset(0.5, 0.3);

  // Calculated position from triangulation
  Offset? _calculatedPosition;

  // Error in meters
  double _errorRadius = 0;

  // Mode
  DFMode _mode = DFMode.tutorial;

  // Practice mode
  bool _showTarget = true;
  int _score = 0;
  int _attempts = 0;

  // Signal properties
  SignalType _signalType = SignalType.radar;
  double _signalStrength = 0.8;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _calculateTriangulation();
  }

  void _calculateTriangulation() {
    // Update bearings to point to target
    for (var station in _stations) {
      final dx = _targetPosition.dx - station.position.dx;
      final dy = _targetPosition.dy - station.position.dy;
      // Add some random error for realism
      final error = (_mode == DFMode.realistic)
          ? (math.Random().nextDouble() - 0.5) * 10
          : 0.0;
      station.bearing = (math.atan2(dx, -dy) * 180 / math.pi + 360) % 360 + error;
    }

    // Calculate intersection (simplified 2-station triangulation)
    if (_stations.length >= 2) {
      final pos = _calculateIntersection(
        _stations[0].position,
        _stations[0].bearing,
        _stations[1].position,
        _stations[1].bearing,
      );

      if (pos != null) {
        // Average with third station for better accuracy
        if (_stations.length >= 3) {
          final pos2 = _calculateIntersection(
            _stations[0].position,
            _stations[0].bearing,
            _stations[2].position,
            _stations[2].bearing,
          );
          final pos3 = _calculateIntersection(
            _stations[1].position,
            _stations[1].bearing,
            _stations[2].position,
            _stations[2].bearing,
          );

          if (pos2 != null && pos3 != null) {
            _calculatedPosition = Offset(
              (pos.dx + pos2.dx + pos3.dx) / 3,
              (pos.dy + pos2.dy + pos3.dy) / 3,
            );
          } else {
            _calculatedPosition = pos;
          }
        } else {
          _calculatedPosition = pos;
        }

        // Calculate error
        if (_calculatedPosition != null) {
          final dx = (_calculatedPosition!.dx - _targetPosition.dx) * 1000; // km
          final dy = (_calculatedPosition!.dy - _targetPosition.dy) * 1000;
          _errorRadius = math.sqrt(dx * dx + dy * dy);
        }
      }
    }

    setState(() {});
  }

  Offset? _calculateIntersection(
    Offset p1, double bearing1,
    Offset p2, double bearing2,
  ) {
    // Convert bearings to radians (from north, clockwise)
    final r1 = bearing1 * math.pi / 180;
    final r2 = bearing2 * math.pi / 180;

    // Direction vectors
    final dx1 = math.sin(r1);
    final dy1 = -math.cos(r1);
    final dx2 = math.sin(r2);
    final dy2 = -math.cos(r2);

    // Solve for intersection
    final denom = dx1 * dy2 - dy1 * dx2;
    if (denom.abs() < 0.001) return null; // Parallel lines

    final t = ((p2.dx - p1.dx) * dy2 - (p2.dy - p1.dy) * dx2) / denom;

    return Offset(
      (p1.dx + t * dx1).clamp(0.0, 1.0),
      (p1.dy + t * dy1).clamp(0.0, 1.0),
    );
  }

  void _generateNewTarget() {
    setState(() {
      _targetPosition = Offset(
        0.2 + math.Random().nextDouble() * 0.6,
        0.15 + math.Random().nextDouble() * 0.4,
      );
      _showTarget = _mode == DFMode.tutorial;
      _signalType = SignalType.values[math.Random().nextInt(SignalType.values.length)];
      _signalStrength = 0.5 + math.Random().nextDouble() * 0.5;
    });
    _calculateTriangulation();
  }

  void _checkAnswer() {
    if (_calculatedPosition == null) return;

    final dx = (_calculatedPosition!.dx - _targetPosition.dx) * 100;
    final dy = (_calculatedPosition!.dy - _targetPosition.dy) * 100;
    final distance = math.sqrt(dx * dx + dy * dy);

    setState(() {
      _attempts++;
      if (distance < 5) {
        _score += 10;
      } else if (distance < 10) {
        _score += 5;
      }
      _showTarget = true;
    });

    // Show result dialog
    _showResultDialog(distance);
  }

  void _showResultDialog(double distance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Icon(
              distance < 5 ? Icons.check_circle :
              distance < 10 ? Icons.info : Icons.cancel,
              color: distance < 5 ? AppColors.success :
                     distance < 10 ? AppColors.warning : AppColors.error,
            ),
            const SizedBox(width: 8),
            Text(
              distance < 5 ? 'ยอดเยี่ยม!' :
              distance < 10 ? 'ใกล้แล้ว!' : 'ลองอีกครั้ง',
              style: AppTextStyles.titleMedium,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ความคลาดเคลื่อน: ${_errorRadius.toStringAsFixed(1)} m',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'คะแนน: $_score / ${_attempts * 10}',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _generateNewTarget();
            },
            child: const Text('ลองใหม่'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.esColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.esColor.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 12),

          // Mode Selector
          _buildModeSelector(),
          const SizedBox(height: 12),

          // DF Visualization
          AspectRatio(
            aspectRatio: 1.2,
            child: _buildDFVisualization(),
          ),
          const SizedBox(height: 12),

          // Station Info
          _buildStationInfo(),
          const SizedBox(height: 12),

          // Controls
          _buildControls(),

          // Result/Tutorial
          if (_mode == DFMode.tutorial) _buildTutorialInfo(),
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
            color: AppColors.esColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.explore,
            color: AppColors.esColor,
            size: 28,
          ),
        )
            .animate(
              onPlay: (controller) => controller.repeat(reverse: true),
            )
            .rotate(
              begin: -0.05,
              end: 0.05,
              duration: 2000.ms,
            ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DF Triangulation',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.esColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'หาตำแหน่งด้วยเส้นแบริ่ง',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Score display
        if (_mode == DFMode.practice)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppColors.success, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$_score',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildModeSelector() {
    return Row(
      children: DFMode.values.map((mode) {
        final isSelected = _mode == mode;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _mode = mode;
                  _showTarget = mode != DFMode.practice;
                });
                if (mode == DFMode.practice) {
                  _generateNewTarget();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? mode.color.withValues(alpha: 0.2)
                      : AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? mode.color : AppColors.border,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      mode.icon,
                      color: isSelected ? mode.color : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mode.nameTh,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isSelected ? mode.color : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDFVisualization() {
    return GestureDetector(
      onTapDown: (details) {
        if (_mode == DFMode.practice) return;

        final RenderBox box = context.findRenderObject() as RenderBox;
        final localPos = box.globalToLocal(details.globalPosition);
        final size = box.size;

        // Adjust for the aspect ratio container
        final containerHeight = size.width / 1.2;
        final offsetY = (size.height - containerHeight) / 2;

        if (localPos.dy >= offsetY && localPos.dy <= offsetY + containerHeight) {
          setState(() {
            _targetPosition = Offset(
              (localPos.dx / size.width).clamp(0.1, 0.9),
              ((localPos.dy - offsetY) / containerHeight).clamp(0.1, 0.9),
            );
          });
          _calculateTriangulation();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AnimatedBuilder(
            animation: Listenable.merge([_pulseController, _scanController]),
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _DFVisualizationPainter(
                  stations: _stations,
                  targetPosition: _showTarget ? _targetPosition : null,
                  calculatedPosition: _calculatedPosition,
                  errorRadius: _errorRadius,
                  pulseProgress: _pulseController.value,
                  scanProgress: _scanController.value,
                  signalType: _signalType,
                  signalStrength: _signalStrength,
                  showBearings: true,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStationInfo() {
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
              const Icon(Icons.cell_tower, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'สถานี DF',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: _stations.map((station) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: station.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: station.color.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: station.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            station.id,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: station.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${station.bearing.toStringAsFixed(0)}°',
                        style: AppTextStyles.codeMedium.copyWith(
                          color: AppColors.textPrimary,
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

  Widget _buildControls() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _generateNewTarget,
            icon: const Icon(Icons.refresh),
            label: const Text('เป้าหมายใหม่'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.card,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        if (_mode == DFMode.practice) ...[
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _checkAnswer,
              icon: const Icon(Icons.check),
              label: const Text('ตรวจคำตอบ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTutorialInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: AppColors.info, size: 18),
              const SizedBox(width: 8),
              Text(
                'วิธีการหาตำแหน่ง (Triangulation)',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTutorialStep('1', 'สถานี DF แต่ละแห่งวัดทิศทาง (Bearing) ของสัญญาณ'),
          _buildTutorialStep('2', 'ลากเส้นจากแต่ละสถานีตามทิศที่วัดได้'),
          _buildTutorialStep('3', 'จุดตัดของเส้นคือตำแหน่งเป้าหมาย'),
          _buildTutorialStep('4', 'ยิ่งมีหลายสถานี ยิ่งแม่นยำ'),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.touch_app, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'แตะบนแผนที่เพื่อย้ายเป้าหมาย',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          if (_calculatedPosition != null) ...[
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ความคลาดเคลื่อน:',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getErrorColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_errorRadius.toStringAsFixed(1)} m',
                    style: AppTextStyles.codeMedium.copyWith(
                      color: _getErrorColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTutorialStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getErrorColor() {
    if (_errorRadius < 50) return AppColors.success;
    if (_errorRadius < 100) return AppColors.warning;
    return AppColors.error;
  }
}

/// DF Visualization Painter
class _DFVisualizationPainter extends CustomPainter {
  final List<DFStation> stations;
  final Offset? targetPosition;
  final Offset? calculatedPosition;
  final double errorRadius;
  final double pulseProgress;
  final double scanProgress;
  final SignalType signalType;
  final double signalStrength;
  final bool showBearings;

  _DFVisualizationPainter({
    required this.stations,
    this.targetPosition,
    this.calculatedPosition,
    required this.errorRadius,
    required this.pulseProgress,
    required this.scanProgress,
    required this.signalType,
    required this.signalStrength,
    required this.showBearings,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw map background
    _drawMapBackground(canvas, size);

    // Draw bearing lines
    if (showBearings) {
      _drawBearingLines(canvas, size);
    }

    // Draw error ellipse
    if (calculatedPosition != null) {
      _drawErrorEllipse(canvas, size);
    }

    // Draw calculated position
    if (calculatedPosition != null) {
      _drawCalculatedPosition(canvas, size);
    }

    // Draw target
    if (targetPosition != null) {
      _drawTarget(canvas, size);
    }

    // Draw stations
    _drawStations(canvas, size);
  }

  void _drawMapBackground(Canvas canvas, Size size) {
    // Background gradient
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.background,
          AppColors.card.withValues(alpha: 0.5),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    for (int i = 1; i < 5; i++) {
      canvas.drawLine(
        Offset(size.width * i / 5, 0),
        Offset(size.width * i / 5, size.height),
        gridPaint,
      );
      canvas.drawLine(
        Offset(0, size.height * i / 5),
        Offset(size.width, size.height * i / 5),
        gridPaint,
      );
    }

    // Compass rose
    _drawCompassRose(canvas, Offset(size.width - 30, 30), 20);
  }

  void _drawCompassRose(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, radius, paint);

    // N indicator
    final northPaint = Paint()
      ..color = AppColors.eaColor
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx - 5, center.dy - radius + 10)
      ..lineTo(center.dx + 5, center.dy - radius + 10)
      ..close();

    canvas.drawPath(path, northPaint);

    // N label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'N',
        style: TextStyle(
          color: AppColors.eaColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - radius - 15),
    );
  }

  void _drawBearingLines(Canvas canvas, Size size) {
    for (var station in stations) {
      final stationPos = Offset(
        station.position.dx * size.width,
        station.position.dy * size.height,
      );

      // Calculate bearing line endpoint (extend to edge of canvas)
      final bearing = station.bearing * math.pi / 180;
      final dx = math.sin(bearing);
      final dy = -math.cos(bearing);

      // Find intersection with canvas edge
      double t = double.infinity;
      if (dx > 0) t = math.min(t, (size.width - stationPos.dx) / dx);
      if (dx < 0) t = math.min(t, -stationPos.dx / dx);
      if (dy > 0) t = math.min(t, (size.height - stationPos.dy) / dy);
      if (dy < 0) t = math.min(t, -stationPos.dy / dy);

      final endPoint = Offset(
        stationPos.dx + dx * t,
        stationPos.dy + dy * t,
      );

      // Draw bearing line with gradient
      final linePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            station.color,
            station.color.withValues(alpha: 0.1),
          ],
        ).createShader(Rect.fromPoints(stationPos, endPoint))
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(stationPos, endPoint, linePaint);

      // Animated pulse along line
      final pulsePos = Offset(
        stationPos.dx + (endPoint.dx - stationPos.dx) * pulseProgress,
        stationPos.dy + (endPoint.dy - stationPos.dy) * pulseProgress,
      );

      final pulsePaint = Paint()
        ..color = station.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(pulsePos, 4, pulsePaint);

      // Bearing label
      final labelPos = Offset(
        stationPos.dx + dx * 50,
        stationPos.dy + dy * 50,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${station.bearing.toStringAsFixed(0)}°',
          style: TextStyle(
            color: station.color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Background for readability
      final bgRect = Rect.fromCenter(
        center: labelPos,
        width: textPainter.width + 8,
        height: textPainter.height + 4,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
        Paint()..color = AppColors.background.withValues(alpha: 0.8),
      );

      textPainter.paint(
        canvas,
        Offset(labelPos.dx - textPainter.width / 2, labelPos.dy - textPainter.height / 2),
      );
    }
  }

  void _drawErrorEllipse(Canvas canvas, Size size) {
    if (calculatedPosition == null) return;

    final center = Offset(
      calculatedPosition!.dx * size.width,
      calculatedPosition!.dy * size.height,
    );

    // Error ellipse (scaled)
    final errorScale = errorRadius / 10; // Adjust scale
    final ellipsePaint = Paint()
      ..color = AppColors.warning.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: errorScale * 2,
        height: errorScale * 2.5,
      ),
      ellipsePaint,
    );

    // Ellipse border
    final borderPaint = Paint()
      ..color = AppColors.warning.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: errorScale * 2,
        height: errorScale * 2.5,
      ),
      borderPaint,
    );
  }

  void _drawCalculatedPosition(Canvas canvas, Size size) {
    if (calculatedPosition == null) return;

    final pos = Offset(
      calculatedPosition!.dx * size.width,
      calculatedPosition!.dy * size.height,
    );

    // Crosshair
    final crossPaint = Paint()
      ..color = AppColors.success
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(pos.dx - 15, pos.dy),
      Offset(pos.dx + 15, pos.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(pos.dx, pos.dy - 15),
      Offset(pos.dx, pos.dy + 15),
      crossPaint,
    );

    // Circle
    canvas.drawCircle(pos, 8, crossPaint);

    // Label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'FIX',
        style: TextStyle(
          color: AppColors.success,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(pos.dx + 12, pos.dy - 6));
  }

  void _drawTarget(Canvas canvas, Size size) {
    if (targetPosition == null) return;

    final pos = Offset(
      targetPosition!.dx * size.width,
      targetPosition!.dy * size.height,
    );

    // Signal waves
    for (int i = 0; i < 3; i++) {
      final waveRadius = 15 + i * 12 + pulseProgress * 15;
      final wavePaint = Paint()
        ..color = signalType.color.withValues(alpha: (1 - pulseProgress) * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(pos, waveRadius, wavePaint);
    }

    // Target icon
    final targetPaint = Paint()
      ..color = signalType.color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(pos, 12, targetPaint);

    // Glow
    final glowPaint = Paint()
      ..color = signalType.color.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(pos, 15, glowPaint);

    // Signal type icon
    final iconPainter = TextPainter(
      text: TextSpan(
        text: signalType.symbol,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(pos.dx - iconPainter.width / 2, pos.dy - iconPainter.height / 2),
    );

    // Label
    final labelPainter = TextPainter(
      text: TextSpan(
        text: signalType.name,
        style: TextStyle(
          color: signalType.color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();
    labelPainter.paint(
      canvas,
      Offset(pos.dx - labelPainter.width / 2, pos.dy + 18),
    );
  }

  void _drawStations(Canvas canvas, Size size) {
    for (var station in stations) {
      final pos = Offset(
        station.position.dx * size.width,
        station.position.dy * size.height,
      );

      // Scan arc
      final scanAngle = station.bearing * math.pi / 180;
      final arcPaint = Paint()
        ..color = station.color.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;

      final arcPath = Path()
        ..moveTo(pos.dx, pos.dy)
        ..arcTo(
          Rect.fromCircle(center: pos, radius: 40),
          scanAngle - 0.3 + scanProgress * 0.6 - 0.3,
          0.6,
          false,
        )
        ..close();

      canvas.drawPath(arcPath, arcPaint);

      // Station base
      final basePaint = Paint()
        ..color = station.color
        ..style = PaintingStyle.fill;

      // Triangle shape for station
      final trianglePath = Path()
        ..moveTo(pos.dx, pos.dy - 15)
        ..lineTo(pos.dx - 12, pos.dy + 8)
        ..lineTo(pos.dx + 12, pos.dy + 8)
        ..close();

      canvas.drawPath(trianglePath, basePaint);

      // Antenna
      canvas.drawLine(
        Offset(pos.dx, pos.dy - 15),
        Offset(pos.dx, pos.dy - 25),
        Paint()
          ..color = station.color
          ..strokeWidth = 3,
      );

      // Station label
      final textPainter = TextPainter(
        text: TextSpan(
          text: station.id,
          style: TextStyle(
            color: station.color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy + 12),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DFVisualizationPainter oldDelegate) => true;
}

/// DF Station Model
class DFStation {
  final String id;
  final Offset position;
  final Color color;
  double bearing;

  DFStation({
    required this.id,
    required this.position,
    required this.color,
    required this.bearing,
  });
}

/// DF Modes
enum DFMode {
  tutorial,
  realistic,
  practice;

  String get nameTh {
    switch (this) {
      case DFMode.tutorial:
        return 'สอน';
      case DFMode.realistic:
        return 'สมจริง';
      case DFMode.practice:
        return 'ฝึกหัด';
    }
  }

  IconData get icon {
    switch (this) {
      case DFMode.tutorial:
        return Icons.school;
      case DFMode.realistic:
        return Icons.precision_manufacturing;
      case DFMode.practice:
        return Icons.quiz;
    }
  }

  Color get color {
    switch (this) {
      case DFMode.tutorial:
        return AppColors.info;
      case DFMode.realistic:
        return AppColors.warning;
      case DFMode.practice:
        return AppColors.success;
    }
  }
}

/// Signal Types for targets
enum SignalType {
  radar,
  radio,
  jammer,
  drone;

  String get name {
    switch (this) {
      case SignalType.radar:
        return 'RADAR';
      case SignalType.radio:
        return 'RADIO';
      case SignalType.jammer:
        return 'JAMMER';
      case SignalType.drone:
        return 'DRONE';
    }
  }

  String get symbol {
    switch (this) {
      case SignalType.radar:
        return '📡';
      case SignalType.radio:
        return '📻';
      case SignalType.jammer:
        return '⚡';
      case SignalType.drone:
        return '🛸';
    }
  }

  Color get color {
    switch (this) {
      case SignalType.radar:
        return AppColors.radarColor;
      case SignalType.radio:
        return AppColors.radioColor;
      case SignalType.jammer:
        return AppColors.eaColor;
      case SignalType.drone:
        return AppColors.droneColor;
    }
  }
}

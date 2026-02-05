import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/constants.dart';
import '../../widgets/tutorial/tutorial_overlay.dart';
import '../../widgets/tutorial/simulation_tutorials.dart';

/// Direction Finding (DF) Simulation Screen
/// จำลองการหาทิศทางแหล่งกำเนิดสัญญาณด้วย Triangulation
/// Enhanced with uncertainty ellipse, animations, and realistic effects
class DFSimScreen extends StatefulWidget {
  const DFSimScreen({super.key});

  @override
  State<DFSimScreen> createState() => _DFSimScreenState();
}

class _DFSimScreenState extends State<DFSimScreen>
    with TickerProviderStateMixin {
  // DF Station positions (normalized 0-1)
  final List<DFStation> _stations = [
    DFStation(
      id: 'Alpha',
      position: const Offset(0.2, 0.3),
      color: Colors.red,
      signalStrength: 0,
    ),
    DFStation(
      id: 'Bravo',
      position: const Offset(0.8, 0.25),
      color: Colors.blue,
      signalStrength: 0,
    ),
    DFStation(
      id: 'Charlie',
      position: const Offset(0.5, 0.8),
      color: Colors.green,
      signalStrength: 0,
    ),
  ];

  // Target position (hidden from user, normalized 0-1)
  Offset _targetPosition = const Offset(0.5, 0.5);

  // User's estimated position
  Offset? _estimatedPosition;

  // Bearing lines from each station
  final List<double> _bearings = [0, 0, 0];
  final List<double> _bearingErrors = [0, 0, 0]; // Simulated measurement error

  // User-adjusted bearings for manual triangulation
  final List<double> _userBearings = [0, 0, 0];
  int? _selectedStationIndex; // Currently selected station for adjustment

  // Intersection point calculation
  Offset? _intersectionPoint;
  double _gdop = 0; // Geometric Dilution of Precision
  double _cep = 0; // Circular Error Probable

  // Animation controllers
  late AnimationController _scanController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _revealController;

  // Game state
  int _round = 1;
  int _score = 0;
  bool _showResult = false;
  double _lastAccuracy = 0;
  bool _isScanning = true;

  // Difficulty settings
  DFDifficulty _difficulty = DFDifficulty.normal;

  @override
  void initState() {
    super.initState();

    // Scan animation (bearing line sweep effect)
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Pulse animation for stations
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Glow animation for intersection
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // Reveal animation for target
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _generateNewTarget();
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _generateNewTarget() {
    final random = math.Random();

    // Generate target in the center area (avoid edges)
    _targetPosition = Offset(
      0.2 + random.nextDouble() * 0.6,
      0.2 + random.nextDouble() * 0.6,
    );

    // Calculate actual bearings from each station to target
    for (int i = 0; i < _stations.length; i++) {
      final dx = _targetPosition.dx - _stations[i].position.dx;
      final dy = _targetPosition.dy - _stations[i].position.dy;

      // Bearing in degrees (0 = North, 90 = East)
      double bearing = math.atan2(dx, -dy) * 180 / math.pi;
      if (bearing < 0) bearing += 360;

      // Add measurement error based on difficulty
      final errorRange = _difficulty.bearingError;
      _bearingErrors[i] = (random.nextDouble() - 0.5) * 2 * errorRange;
      _bearings[i] = (bearing + _bearingErrors[i]) % 360;

      // Calculate signal strength (inverse of distance)
      final distance = math.sqrt(dx * dx + dy * dy);
      _stations[i].signalStrength = math.max(0.2, 1.0 - distance);
    }

    // Initialize user bearings (start with random offset for challenge)
    for (int i = 0; i < _stations.length; i++) {
      // Start user bearings with some offset from true bearing
      _userBearings[i] = (_bearings[i] + (random.nextDouble() - 0.5) * 60 + 360) % 360;
    }

    // Calculate intersection point and quality metrics
    _calculateIntersection();

    _estimatedPosition = null;
    _showResult = false;
    _isScanning = true;
    _selectedStationIndex = null;
    _revealController.reset();
  }

  void _updateUserBearing(int stationIndex, double newBearing) {
    setState(() {
      _userBearings[stationIndex] = newBearing % 360;
      _selectedStationIndex = stationIndex;
      _calculateUserIntersection();
    });
  }

  void _calculateUserIntersection() {
    // Calculate intersection using user-adjusted bearings
    final points = <Offset>[];
    final weights = <double>[];

    for (int i = 0; i < _stations.length; i++) {
      for (int j = i + 1; j < _stations.length; j++) {
        final intersection = _lineIntersection(
          _stations[i].position,
          _userBearings[i],
          _stations[j].position,
          _userBearings[j],
        );
        if (intersection != null &&
            intersection.dx >= 0 &&
            intersection.dx <= 1 &&
            intersection.dy >= 0 &&
            intersection.dy <= 1) {
          points.add(intersection);
          weights.add(_stations[i].signalStrength * _stations[j].signalStrength);
        }
      }
    }

    if (points.isNotEmpty) {
      double sumX = 0, sumY = 0, sumW = 0;
      for (int i = 0; i < points.length; i++) {
        sumX += points[i].dx * weights[i];
        sumY += points[i].dy * weights[i];
        sumW += weights[i];
      }
      _intersectionPoint = Offset(sumX / sumW, sumY / sumW);
      _gdop = _calculateGDOP();
      _cep = _calculateCEP(points);
    }
  }

  void _calculateIntersection() {
    // Calculate bearing lines intersection using least squares
    // This gives us the "best guess" point from the three LOBs

    final points = <Offset>[];
    final weights = <double>[];

    for (int i = 0; i < _stations.length; i++) {
      for (int j = i + 1; j < _stations.length; j++) {
        final intersection = _lineIntersection(
          _stations[i].position,
          _bearings[i],
          _stations[j].position,
          _bearings[j],
        );
        if (intersection != null) {
          points.add(intersection);
          // Weight by signal strength
          weights.add(_stations[i].signalStrength * _stations[j].signalStrength);
        }
      }
    }

    if (points.isNotEmpty) {
      // Weighted average of intersection points
      double sumX = 0, sumY = 0, sumW = 0;
      for (int i = 0; i < points.length; i++) {
        sumX += points[i].dx * weights[i];
        sumY += points[i].dy * weights[i];
        sumW += weights[i];
      }
      _intersectionPoint = Offset(sumX / sumW, sumY / sumW);

      // Calculate GDOP (geometry quality)
      _gdop = _calculateGDOP();

      // Calculate CEP (error probable radius)
      _cep = _calculateCEP(points);
    }
  }

  Offset? _lineIntersection(
    Offset p1,
    double bearing1,
    Offset p2,
    double bearing2,
  ) {
    // Convert bearings to direction vectors
    final rad1 = bearing1 * math.pi / 180;
    final rad2 = bearing2 * math.pi / 180;

    final dx1 = math.sin(rad1);
    final dy1 = -math.cos(rad1);
    final dx2 = math.sin(rad2);
    final dy2 = -math.cos(rad2);

    // Line intersection using determinants
    final det = dx1 * dy2 - dy1 * dx2;
    if (det.abs() < 0.001) return null; // Parallel lines

    final t = ((p2.dx - p1.dx) * dy2 - (p2.dy - p1.dy) * dx2) / det;

    return Offset(p1.dx + t * dx1, p1.dy + t * dy1);
  }

  double _calculateGDOP() {
    // Simplified GDOP calculation based on station geometry
    // Lower GDOP = better geometry = more accurate fix

    // Calculate angles between stations relative to intersection
    if (_intersectionPoint == null) return 10.0;

    final angles = <double>[];
    for (final station in _stations) {
      final dx = station.position.dx - _intersectionPoint!.dx;
      final dy = station.position.dy - _intersectionPoint!.dy;
      angles.add(math.atan2(dy, dx));
    }

    // Check angular separation
    double minSeparation = double.infinity;
    for (int i = 0; i < angles.length; i++) {
      for (int j = i + 1; j < angles.length; j++) {
        var diff = (angles[i] - angles[j]).abs();
        if (diff > math.pi) diff = 2 * math.pi - diff;
        if (diff < minSeparation) minSeparation = diff;
      }
    }

    // GDOP is higher when stations are clustered together
    final idealSeparation = math.pi / 2; // 90 degrees is ideal
    final separationFactor = (idealSeparation - minSeparation).abs() /
        idealSeparation;

    return 1.0 + separationFactor * 4.0;
  }

  double _calculateCEP(List<Offset> intersections) {
    // CEP = Circular Error Probable (50% probability radius)
    if (_intersectionPoint == null || intersections.isEmpty) return 0.1;

    // Calculate spread of intersection points
    double sumDistSq = 0;
    for (final point in intersections) {
      final dx = point.dx - _intersectionPoint!.dx;
      final dy = point.dy - _intersectionPoint!.dy;
      sumDistSq += dx * dx + dy * dy;
    }

    // CEP is approximately 0.5 * standard deviation
    final variance = sumDistSq / intersections.length;
    return math.sqrt(variance) * 0.5 + _difficulty.bearingError / 100;
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
    // Adjusted for difficulty
    final maxError = 0.5 / _difficulty.scoringMultiplier;
    final accuracy = math.max(0.0, (1 - distanceError / maxError) * 100);
    final points = (accuracy * _difficulty.scoringMultiplier).round();

    setState(() {
      _showResult = true;
      _lastAccuracy = accuracy;
      _score += points;
      _isScanning = false;
      _revealController.forward();
    });
  }

  void _nextRound() {
    if (_round >= 5) {
      _showGameOverDialog();
      return;
    }

    setState(() {
      _round++;
      _generateNewTarget();
    });
  }

  void _showGameOverDialog() {
    final maxScore = (500 * _difficulty.scoringMultiplier).round();
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
              _score >= maxScore * 0.8
                  ? Icons.emoji_events
                  : Icons.military_tech,
              size: 64,
              color: _score >= maxScore * 0.8 ? Colors.amber : AppColors.esColor,
            ),
            const SizedBox(height: 16),
            Text(
              'คะแนนรวม: $_score/$maxScore',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _score >= maxScore * 0.8
                  ? 'ยอดเยี่ยม! ทักษะ DF ระดับผู้เชี่ยวชาญ'
                  : _score >= maxScore * 0.6
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
            // Difficulty selector
            PopupMenuButton<DFDifficulty>(
              icon: Icon(
                Icons.tune,
                color: _difficulty.color,
              ),
              tooltip: 'ความยาก',
              color: AppColors.surface,
              onSelected: (value) {
                setState(() {
                  _difficulty = value;
                  _round = 1;
                  _score = 0;
                  _generateNewTarget();
                });
              },
              itemBuilder: (context) => DFDifficulty.values.map((d) {
                return PopupMenuItem(
                  value: d,
                  child: Row(
                    children: [
                      Icon(d.icon, color: d.color, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        d.nameTh,
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  'รอบ $_round/5 | $_score',
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
            // Enhanced info panel
            _buildInfoPanel(),

            // Map area with enhanced visualization
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedBuilder(
                            animation: Listenable.merge([
                              _scanController,
                              _pulseController,
                              _glowController,
                              _revealController,
                            ]),
                            builder: (context, child) {
                              return CustomPaint(
                                size: size,
                                painter: EnhancedDFMapPainter(
                                  stations: _stations,
                                  bearings: _userBearings,
                                  targetPosition: _showResult ? _targetPosition : null,
                                  estimatedPosition: _estimatedPosition,
                                  intersectionPoint: _intersectionPoint,
                                  cep: _cep,
                                  scanProgress: _scanController.value,
                                  pulseValue: _pulseController.value,
                                  glowValue: _glowController.value,
                                  revealProgress: _revealController.value,
                                  isScanning: _isScanning,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Enhanced result and action buttons
            _buildActionPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'หมุนปรับทิศทางแต่ละสถานี',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // GDOP indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _gdop < 2
                      ? Colors.green.withValues(alpha: 0.2)
                      : _gdop < 4
                          ? Colors.orange.withValues(alpha: 0.2)
                          : Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _gdop < 2
                        ? Colors.green
                        : _gdop < 4
                            ? Colors.orange
                            : Colors.red,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _gdop < 2
                          ? Icons.check_circle
                          : _gdop < 4
                              ? Icons.warning
                              : Icons.error,
                      size: 14,
                      color: _gdop < 2
                          ? Colors.green
                          : _gdop < 4
                              ? Colors.orange
                              : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'GDOP: ${_gdop.toStringAsFixed(1)}',
                      style: TextStyle(
                        color: _gdop < 2
                            ? Colors.green
                            : _gdop < 4
                                ? Colors.orange
                                : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _stations.asMap().entries.map((entry) {
              final index = entry.key;
              final station = entry.value;
              return _InteractiveBearingDial(
                station: station,
                bearing: _userBearings[index],
                trueBearing: _showResult ? _bearings[index] : null,
                pulseValue: _pulseController.value,
                isSelected: _selectedStationIndex == index,
                onBearingChanged: (newBearing) => _updateUserBearing(index, newBearing),
                enabled: !_showResult,
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildActionPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
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
                  size: 28,
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+${(_lastAccuracy * _difficulty.scoringMultiplier).round()}',
                    style: const TextStyle(
                      color: Colors.cyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ).animate().scale(duration: 300.ms),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _estimatedPosition == null || _showResult
                      ? null
                      : _checkAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.esColor,
                    disabledBackgroundColor: AppColors.esColor.withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text(
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
                  child: ElevatedButton.icon(
                    onPressed: _nextRound,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: Icon(_round >= 5 ? Icons.flag : Icons.arrow_forward),
                    label: Text(
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
    );
  }
}

// ============= Data Models =============

class DFStation {
  final String id;
  final Offset position;
  final Color color;
  double signalStrength;

  DFStation({
    required this.id,
    required this.position,
    required this.color,
    required this.signalStrength,
  });
}

enum DFDifficulty {
  easy(
    nameTh: 'ง่าย',
    bearingError: 2.0,
    scoringMultiplier: 0.8,
    icon: Icons.sentiment_satisfied,
    color: Colors.green,
  ),
  normal(
    nameTh: 'ปกติ',
    bearingError: 5.0,
    scoringMultiplier: 1.0,
    icon: Icons.sentiment_neutral,
    color: Colors.orange,
  ),
  hard(
    nameTh: 'ยาก',
    bearingError: 10.0,
    scoringMultiplier: 1.5,
    icon: Icons.sentiment_very_dissatisfied,
    color: Colors.red,
  ),
  expert(
    nameTh: 'ผู้เชี่ยวชาญ',
    bearingError: 15.0,
    scoringMultiplier: 2.0,
    icon: Icons.whatshot,
    color: Colors.purple,
  );

  final String nameTh;
  final double bearingError;
  final double scoringMultiplier;
  final IconData icon;
  final Color color;

  const DFDifficulty({
    required this.nameTh,
    required this.bearingError,
    required this.scoringMultiplier,
    required this.icon,
    required this.color,
  });
}

// ============= Widgets =============

/// Interactive bearing dial with drag-to-rotate functionality
class _InteractiveBearingDial extends StatefulWidget {
  final DFStation station;
  final double bearing;
  final double? trueBearing; // Show true bearing after result
  final double pulseValue;
  final bool isSelected;
  final Function(double) onBearingChanged;
  final bool enabled;

  const _InteractiveBearingDial({
    required this.station,
    required this.bearing,
    this.trueBearing,
    required this.pulseValue,
    required this.isSelected,
    required this.onBearingChanged,
    this.enabled = true,
  });

  @override
  State<_InteractiveBearingDial> createState() => _InteractiveBearingDialState();
}

class _InteractiveBearingDialState extends State<_InteractiveBearingDial> {
  Offset? _lastPanPosition;
  double _currentBearing = 0;

  @override
  void initState() {
    super.initState();
    _currentBearing = widget.bearing;
  }

  @override
  void didUpdateWidget(_InteractiveBearingDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bearing != widget.bearing) {
      _currentBearing = widget.bearing;
    }
  }

  void _handlePanStart(DragStartDetails details) {
    if (!widget.enabled) return;
    _lastPanPosition = details.localPosition;
  }

  void _handlePanUpdate(DragUpdateDetails details, Size dialSize) {
    if (!widget.enabled || _lastPanPosition == null) return;

    final center = Offset(dialSize.width / 2, dialSize.height / 2);
    final currentPos = details.localPosition;

    // Calculate angle change based on drag around center
    final lastAngle = math.atan2(
      _lastPanPosition!.dy - center.dy,
      _lastPanPosition!.dx - center.dx,
    );
    final currentAngle = math.atan2(
      currentPos.dy - center.dy,
      currentPos.dx - center.dx,
    );

    var angleDelta = (currentAngle - lastAngle) * 180 / math.pi;

    setState(() {
      _currentBearing = (_currentBearing + angleDelta + 360) % 360;
    });

    widget.onBearingChanged(_currentBearing);
    _lastPanPosition = currentPos;
  }

  void _handlePanEnd(DragEndDetails details) {
    _lastPanPosition = null;
  }

  @override
  Widget build(BuildContext context) {
    final signalBars = (widget.station.signalStrength * 5).round();
    final dialSize = 90.0;

    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: (details) => _handlePanUpdate(details, Size(dialSize, dialSize)),
      onPanEnd: _handlePanEnd,
      child: Container(
        width: dialSize + 24,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.station.color.withValues(alpha: widget.isSelected ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.station.color.withValues(
              alpha: widget.isSelected ? 0.8 : 0.3 + widget.pulseValue * 0.2,
            ),
            width: widget.isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.station.color.withValues(
                alpha: widget.isSelected ? 0.5 : widget.pulseValue * 0.3,
              ),
              blurRadius: widget.isSelected ? 15 : 10,
              spreadRadius: widget.isSelected ? 3 : 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Station name
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: widget.station.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.station.id,
                  style: TextStyle(
                    color: widget.station.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Dial with bearing indicator
            SizedBox(
              width: dialSize,
              height: dialSize,
              child: CustomPaint(
                painter: _BearingDialPainter(
                  bearing: _currentBearing,
                  trueBearing: widget.trueBearing,
                  color: widget.station.color,
                  isSelected: widget.isSelected,
                ),
              ),
            ),

            const SizedBox(height: 4),
            // Bearing value
            Text(
              '${_currentBearing.toStringAsFixed(1)}°',
              style: TextStyle(
                color: widget.station.color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'monospace',
              ),
            ),

            // Show error from true bearing if revealed
            if (widget.trueBearing != null) ...[
              const SizedBox(height: 2),
              Text(
                'ผิด ${_calculateError().toStringAsFixed(1)}°',
                style: TextStyle(
                  color: _calculateError().abs() < 5
                      ? Colors.green
                      : _calculateError().abs() < 15
                          ? Colors.orange
                          : Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            const SizedBox(height: 4),
            // Signal strength indicator
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                return Container(
                  width: 4,
                  height: 6 + i * 2.0,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: i < signalBars
                        ? widget.station.color
                        : widget.station.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateError() {
    if (widget.trueBearing == null) return 0;
    var diff = _currentBearing - widget.trueBearing!;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return diff;
  }
}

/// Custom painter for the bearing dial
class _BearingDialPainter extends CustomPainter {
  final double bearing;
  final double? trueBearing;
  final Color color;
  final bool isSelected;

  _BearingDialPainter({
    required this.bearing,
    this.trueBearing,
    required this.color,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Draw outer ring
    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, ringPaint);

    // Draw tick marks
    for (int i = 0; i < 36; i++) {
      final angle = i * 10 * math.pi / 180 - math.pi / 2;
      final isCardinal = i % 9 == 0;
      final isMajor = i % 3 == 0;
      final length = isCardinal ? 8 : (isMajor ? 5 : 3);

      final start = Offset(
        center.dx + (radius - length) * math.cos(angle),
        center.dy + (radius - length) * math.sin(angle),
      );
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      final tickPaint = Paint()
        ..color = color.withValues(alpha: isCardinal ? 0.8 : 0.4)
        ..strokeWidth = isCardinal ? 2 : 1;

      canvas.drawLine(start, end, tickPaint);
    }

    // Draw cardinal labels
    final labels = ['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2 - math.pi / 2;
      final labelRadius = radius - 16;

      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: i == 0 ? Colors.red : color,
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
          center.dx + labelRadius * math.cos(angle) - textPainter.width / 2,
          center.dy + labelRadius * math.sin(angle) - textPainter.height / 2,
        ),
      );
    }

    // Draw true bearing indicator (if revealed)
    if (trueBearing != null) {
      final trueBearingRad = trueBearing! * math.pi / 180 - math.pi / 2;
      final trueEndX = center.dx + (radius - 8) * math.cos(trueBearingRad);
      final trueEndY = center.dy + (radius - 8) * math.sin(trueBearingRad);

      final truePaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(center, Offset(trueEndX, trueEndY), truePaint);

      // Draw true bearing marker
      canvas.drawCircle(Offset(trueEndX, trueEndY), 4, Paint()..color = Colors.green);
    }

    // Draw current bearing arrow (user adjusted)
    final bearingRad = bearing * math.pi / 180 - math.pi / 2;
    final arrowLength = radius - 8;
    final endX = center.dx + arrowLength * math.cos(bearingRad);
    final endY = center.dy + arrowLength * math.sin(bearingRad);

    // Arrow glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawLine(center, Offset(endX, endY), glowPaint);

    // Arrow line
    final arrowPaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, Offset(endX, endY), arrowPaint);

    // Arrow head
    final headAngle = 25 * math.pi / 180;
    final headLength = 10.0;

    final headPath = Path();
    headPath.moveTo(endX, endY);
    headPath.lineTo(
      endX - headLength * math.cos(bearingRad - headAngle),
      endY - headLength * math.sin(bearingRad - headAngle),
    );
    headPath.moveTo(endX, endY);
    headPath.lineTo(
      endX - headLength * math.cos(bearingRad + headAngle),
      endY - headLength * math.sin(bearingRad + headAngle),
    );

    canvas.drawPath(headPath, arrowPaint);

    // Center dot
    canvas.drawCircle(center, 4, Paint()..color = color);

    // Drag hint (if selected)
    if (isSelected) {
      final hintPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      // Draw circular arrow hint
      final hintPath = Path();
      hintPath.addArc(
        Rect.fromCircle(center: center, radius: radius + 6),
        -math.pi / 4,
        math.pi / 2,
      );
      canvas.drawPath(hintPath, hintPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BearingDialPainter oldDelegate) {
    return bearing != oldDelegate.bearing ||
        trueBearing != oldDelegate.trueBearing ||
        isSelected != oldDelegate.isSelected;
  }
}

// ============= Enhanced Map Painter =============

class EnhancedDFMapPainter extends CustomPainter {
  final List<DFStation> stations;
  final List<double> bearings;
  final Offset? targetPosition;
  final Offset? estimatedPosition;
  final Offset? intersectionPoint;
  final double cep;
  final double scanProgress;
  final double pulseValue;
  final double glowValue;
  final double revealProgress;
  final bool isScanning;

  EnhancedDFMapPainter({
    required this.stations,
    required this.bearings,
    this.targetPosition,
    this.estimatedPosition,
    this.intersectionPoint,
    required this.cep,
    required this.scanProgress,
    required this.pulseValue,
    required this.glowValue,
    required this.revealProgress,
    required this.isScanning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw terrain-like background
    _drawTerrain(canvas, size);

    // Draw enhanced grid
    _drawGrid(canvas, size);

    // Draw uncertainty ellipse (CEP)
    if (intersectionPoint != null && isScanning) {
      _drawUncertaintyEllipse(canvas, size);
    }

    // Draw bearing lines with scan effect
    _drawBearingLines(canvas, size);

    // Draw bearing line intersections
    _drawIntersections(canvas, size);

    // Draw stations with effects
    _drawStations(canvas, size);

    // Draw estimated position (user's guess)
    if (estimatedPosition != null) {
      _drawEstimatedPosition(canvas, size);
    }

    // Draw actual target position (after reveal)
    if (targetPosition != null) {
      _drawTargetReveal(canvas, size);
    }

    // Draw compass rose
    _drawCompassRose(canvas, Offset(size.width - 50, 50));

    // Draw scale bar
    _drawScaleBar(canvas, size);
  }

  void _drawTerrain(Canvas canvas, Size size) {
    // Simulated terrain texture
    final random = math.Random(42); // Fixed seed for consistent terrain

    for (int x = 0; x < size.width; x += 20) {
      for (int y = 0; y < size.height; y += 20) {
        final noise = random.nextDouble() * 0.05;
        final paint = Paint()
          ..color = Color.lerp(
            const Color(0xFF1a2a1a),
            const Color(0xFF0d1a0d),
            noise,
          )!;

        canvas.drawRect(
          Rect.fromLTWH(x.toDouble(), y.toDouble(), 20, 20),
          paint,
        );
      }
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    // Major grid lines
    for (int i = 0; i <= 10; i++) {
      final x = size.width * i / 10;
      final y = size.height * i / 10;

      gridPaint.strokeWidth = i % 5 == 0 ? 1.5 : 0.5;
      gridPaint.color = i % 5 == 0
          ? Colors.green.withValues(alpha: 0.2)
          : Colors.green.withValues(alpha: 0.08);

      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawUncertaintyEllipse(Canvas canvas, Size size) {
    final center = Offset(
      intersectionPoint!.dx * size.width,
      intersectionPoint!.dy * size.height,
    );

    final radius = cep * size.width;

    // Draw multiple rings for CEP visualization
    for (int i = 3; i >= 1; i--) {
      final r = radius * i / 2;
      final alpha = 0.1 + glowValue * 0.1;

      final paint = Paint()
        ..color = Colors.yellow.withValues(alpha: alpha / i)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, r, paint);
    }

    // Fill uncertainty area
    final fillPaint = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.05 + glowValue * 0.03)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, fillPaint);

    // Animated scanning ring
    final scanRingPaint = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final scanRadius = radius * scanProgress;
    canvas.drawCircle(center, scanRadius, scanRingPaint);
  }

  void _drawBearingLines(Canvas canvas, Size size) {
    for (int i = 0; i < stations.length; i++) {
      final station = stations[i];
      final stationPos = Offset(
        station.position.dx * size.width,
        station.position.dy * size.height,
      );

      // Convert bearing to direction vector
      final bearingRad = bearings[i] * math.pi / 180;
      final lineLength = size.width * 1.5;
      final endX = stationPos.dx + math.sin(bearingRad) * lineLength;
      final endY = stationPos.dy - math.cos(bearingRad) * lineLength;

      // Draw main bearing line
      final linePaint = Paint()
        ..color = station.color.withValues(alpha: 0.6)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(stationPos, Offset(endX, endY), linePaint);

      // Draw animated dashes along the line
      if (isScanning) {
        _drawAnimatedDashes(
          canvas,
          stationPos,
          Offset(endX, endY),
          station.color,
          scanProgress + i * 0.33,
        );
      }

      // Draw bearing cone (uncertainty)
      final uncertainty = 5.0 * math.pi / 180; // 5 degree uncertainty
      _drawBearingCone(
        canvas,
        stationPos,
        bearingRad,
        uncertainty,
        lineLength,
        station.color,
      );
    }
  }

  void _drawAnimatedDashes(
    Canvas canvas,
    Offset start,
    Offset end,
    Color color,
    double progress,
  ) {
    final dashPaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = math.sqrt(dx * dx + dy * dy);

    final dashLength = 10.0;
    final gapLength = 15.0;
    final dashCount = (length / (dashLength + gapLength)).ceil();

    for (int i = 0; i < dashCount; i++) {
      final t = (i + progress) % dashCount;
      final alpha = (1.0 - t / dashCount) * 0.8;

      dashPaint.color = color.withValues(alpha: alpha);

      final startT = (i * (dashLength + gapLength)) / length;
      final endT = (i * (dashLength + gapLength) + dashLength) / length;

      if (startT < 1.0 && endT > 0) {
        final dashStart = Offset(
          start.dx + dx * startT.clamp(0.0, 1.0),
          start.dy + dy * startT.clamp(0.0, 1.0),
        );
        final dashEnd = Offset(
          start.dx + dx * endT.clamp(0.0, 1.0),
          start.dy + dy * endT.clamp(0.0, 1.0),
        );

        canvas.drawLine(dashStart, dashEnd, dashPaint);
      }
    }
  }

  void _drawBearingCone(
    Canvas canvas,
    Offset origin,
    double bearing,
    double uncertainty,
    double length,
    Color color,
  ) {
    final path = Path();
    path.moveTo(origin.dx, origin.dy);

    final angle1 = bearing - uncertainty;
    final angle2 = bearing + uncertainty;

    path.lineTo(
      origin.dx + math.sin(angle1) * length,
      origin.dy - math.cos(angle1) * length,
    );
    path.lineTo(
      origin.dx + math.sin(angle2) * length,
      origin.dy - math.cos(angle2) * length,
    );
    path.close();

    final paint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  void _drawIntersections(Canvas canvas, Size size) {
    if (!isScanning) return;

    // Draw intersection points between bearing lines
    for (int i = 0; i < stations.length; i++) {
      for (int j = i + 1; j < stations.length; j++) {
        final p1 = stations[i].position;
        final p2 = stations[j].position;
        final b1 = bearings[i] * math.pi / 180;
        final b2 = bearings[j] * math.pi / 180;

        // Calculate intersection
        final dx1 = math.sin(b1);
        final dy1 = -math.cos(b1);
        final dx2 = math.sin(b2);
        final dy2 = -math.cos(b2);

        final det = dx1 * dy2 - dy1 * dx2;
        if (det.abs() < 0.001) continue;

        final t = ((p2.dx - p1.dx) * dy2 - (p2.dy - p1.dy) * dx2) / det;
        final intersection = Offset(p1.dx + t * dx1, p1.dy + t * dy1);

        // Only draw if intersection is in visible area
        if (intersection.dx >= 0 &&
            intersection.dx <= 1 &&
            intersection.dy >= 0 &&
            intersection.dy <= 1) {
          final pos = Offset(
            intersection.dx * size.width,
            intersection.dy * size.height,
          );

          // Draw intersection point with glow
          final glowPaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.3 + glowValue * 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

          canvas.drawCircle(pos, 8, glowPaint);

          final dotPaint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;

          canvas.drawCircle(pos, 4, dotPaint);
        }
      }
    }
  }

  void _drawStations(Canvas canvas, Size size) {
    for (int i = 0; i < stations.length; i++) {
      final station = stations[i];
      final pos = Offset(
        station.position.dx * size.width,
        station.position.dy * size.height,
      );

      // Draw pulse effect
      final pulseRadius = 20 + pulseValue * 15;
      final pulsePaint = Paint()
        ..color = station.color.withValues(alpha: 0.3 * (1 - pulseValue))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(pos, pulseRadius, pulsePaint);

      // Draw station glow
      final glowPaint = Paint()
        ..color = station.color.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(pos, 16, glowPaint);

      // Draw station icon (antenna symbol)
      final stationPaint = Paint()
        ..color = station.color
        ..style = PaintingStyle.fill;

      // Base
      canvas.drawCircle(pos, 12, stationPaint);

      // Antenna tower
      final towerPaint = Paint()
        ..color = station.color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(pos.dx, pos.dy - 12),
        Offset(pos.dx, pos.dy - 25),
        towerPaint,
      );

      // Antenna wings
      canvas.drawLine(
        Offset(pos.dx - 8, pos.dy - 20),
        Offset(pos.dx + 8, pos.dy - 20),
        towerPaint,
      );

      // Station label
      final textPainter = TextPainter(
        text: TextSpan(
          text: station.id[0],
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
        Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
      );
    }
  }

  void _drawEstimatedPosition(Canvas canvas, Size size) {
    final pos = Offset(
      estimatedPosition!.dx * size.width,
      estimatedPosition!.dy * size.height,
    );

    // Draw crosshair with glow
    final glowPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(pos, 15, glowPaint);

    final crossPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Crosshair lines
    canvas.drawLine(
      Offset(pos.dx - 20, pos.dy),
      Offset(pos.dx - 8, pos.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(pos.dx + 8, pos.dy),
      Offset(pos.dx + 20, pos.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(pos.dx, pos.dy - 20),
      Offset(pos.dx, pos.dy - 8),
      crossPaint,
    );
    canvas.drawLine(
      Offset(pos.dx, pos.dy + 8),
      Offset(pos.dx, pos.dy + 20),
      crossPaint,
    );

    // Center circle
    canvas.drawCircle(pos, 8, crossPaint);

    // Inner dot
    final dotPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    canvas.drawCircle(pos, 4, dotPaint);
  }

  void _drawTargetReveal(Canvas canvas, Size size) {
    final pos = Offset(
      targetPosition!.dx * size.width,
      targetPosition!.dy * size.height,
    );

    // Reveal animation (expanding ring)
    final revealRadius = 50 * revealProgress;
    final revealPaint = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.5 * (1 - revealProgress))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(pos, revealRadius, revealPaint);

    // Draw target with scale animation
    final scale = revealProgress;
    if (scale > 0) {
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.scale(scale);
      canvas.translate(-pos.dx, -pos.dy);

      // Glow
      final glowPaint = Paint()
        ..color = Colors.cyan.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawCircle(pos, 18, glowPaint);

      // Target symbol (concentric circles with crosshair)
      final targetPaint = Paint()
        ..color = Colors.cyan
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(pos, 15, targetPaint);
      canvas.drawCircle(pos, 10, targetPaint);
      canvas.drawCircle(pos, 5, targetPaint);

      // Crosshair
      canvas.drawLine(
        Offset(pos.dx - 20, pos.dy),
        Offset(pos.dx + 20, pos.dy),
        targetPaint,
      );
      canvas.drawLine(
        Offset(pos.dx, pos.dy - 20),
        Offset(pos.dx, pos.dy + 20),
        targetPaint,
      );

      // Center dot
      final dotPaint = Paint()
        ..color = Colors.cyan
        ..style = PaintingStyle.fill;

      canvas.drawCircle(pos, 3, dotPaint);

      canvas.restore();
    }

    // Draw line from estimate to target (accuracy indicator)
    if (estimatedPosition != null && revealProgress > 0.5) {
      final estPos = Offset(
        estimatedPosition!.dx * size.width,
        estimatedPosition!.dy * size.height,
      );

      final linePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      // Dashed line
      final path = Path();
      path.moveTo(estPos.dx, estPos.dy);
      path.lineTo(pos.dx, pos.dy);

      final dashPath = Path();
      final distance = (pos - estPos).distance;
      final dashCount = (distance / 8).ceil();

      for (int i = 0; i < dashCount; i++) {
        if (i % 2 == 0) {
          final t1 = i / dashCount;
          final t2 = (i + 1) / dashCount;
          dashPath.moveTo(
            lerpDouble(estPos.dx, pos.dx, t1)!,
            lerpDouble(estPos.dy, pos.dy, t1)!,
          );
          dashPath.lineTo(
            lerpDouble(estPos.dx, pos.dx, t2)!,
            lerpDouble(estPos.dy, pos.dy, t2)!,
          );
        }
      }

      canvas.drawPath(dashPath, linePaint);
    }
  }

  void _drawCompassRose(Canvas canvas, Offset center) {
    // Outer ring
    final ringPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, 35, ringPaint);

    // Cardinal direction marks
    for (int i = 0; i < 36; i++) {
      final angle = i * 10 * math.pi / 180 - math.pi / 2;
      final isCardinal = i % 9 == 0;
      final length = isCardinal ? 8 : (i % 3 == 0 ? 5 : 3);

      final start = Offset(
        center.dx + 28 * math.cos(angle),
        center.dy + 28 * math.sin(angle),
      );
      final end = Offset(
        center.dx + (28 + length) * math.cos(angle),
        center.dy + (28 + length) * math.sin(angle),
      );

      final markPaint = Paint()
        ..color = Colors.green.withValues(alpha: isCardinal ? 0.8 : 0.4)
        ..strokeWidth = isCardinal ? 2 : 1;

      canvas.drawLine(start, end, markPaint);
    }

    // Direction labels
    final directions = ['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2 - math.pi / 2;
      final x = center.dx + 18 * math.cos(angle);
      final y = center.dy + 18 * math.sin(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: i == 0 ? Colors.red : Colors.green,
            fontSize: 11,
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

    // North arrow
    final arrowPath = Path();
    arrowPath.moveTo(center.dx, center.dy - 25);
    arrowPath.lineTo(center.dx - 4, center.dy - 18);
    arrowPath.lineTo(center.dx + 4, center.dy - 18);
    arrowPath.close();

    final arrowPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawPath(arrowPath, arrowPaint);
  }

  void _drawScaleBar(Canvas canvas, Size size) {
    final barWidth = 60.0;
    final startX = 20.0;
    final startY = size.height - 30;

    // Scale bar outline
    final barPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawRect(
      Rect.fromLTWH(startX, startY, barWidth, 6),
      barPaint,
    );

    // Alternating fills
    final fillPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(startX, startY, barWidth / 2, 6),
      fillPaint,
    );

    // Scale label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '10 km',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 10,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(startX + barWidth / 2 - textPainter.width / 2, startY - 14),
    );
  }

  @override
  bool shouldRepaint(covariant EnhancedDFMapPainter oldDelegate) {
    return true; // Always repaint for animations
  }
}

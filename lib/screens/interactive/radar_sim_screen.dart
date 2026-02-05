import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/constants.dart';
import '../../widgets/tutorial/tutorial_overlay.dart';
import '../../widgets/tutorial/simulation_tutorials.dart';

class RadarSimScreen extends StatefulWidget {
  const RadarSimScreen({super.key});

  @override
  State<RadarSimScreen> createState() => _RadarSimScreenState();
}

class _RadarSimScreenState extends State<RadarSimScreen>
    with TickerProviderStateMixin {
  late AnimationController _sweepController;
  late AnimationController _glowController;
  final List<RadarTarget> _targets = [];
  final List<RadarBlip> _blipHistory = [];
  final math.Random _random = math.Random();
  int _detectedTargets = 0;
  int _totalTargets = 0;
  bool _isRunning = false;

  // Radar parameters
  final double _radarRange = 100; // km
  double _sweepSpeed = 3; // seconds per rotation
  bool _showClutter = true;
  bool _showTrails = true;
  int _rotationCount = 0;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      duration: Duration(milliseconds: (_sweepSpeed * 1000).toInt()),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _sweepController.addListener(() {
      _checkTargetDetection();
      _updateMovingTargets();
      _cleanOldBlips();
    });

    _sweepController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _rotationCount++;
        if (_isRunning) {
          _sweepController.forward(from: 0);
        }
      }
    });
  }

  void _startSimulation() {
    setState(() {
      _isRunning = true;
      _detectedTargets = 0;
      _totalTargets = 5 + _random.nextInt(5);
      _targets.clear();
      _blipHistory.clear();
      _rotationCount = 0;
      _generateTargets();
    });
    _sweepController.forward(from: 0);
  }

  void _stopSimulation() {
    setState(() {
      _isRunning = false;
    });
    _sweepController.stop();
  }

  void _resetSimulation() {
    _stopSimulation();
    setState(() {
      _targets.clear();
      _blipHistory.clear();
      _detectedTargets = 0;
      _totalTargets = 0;
      _rotationCount = 0;
    });
  }

  void _generateTargets() {
    for (int i = 0; i < _totalTargets; i++) {
      final isMoving = _random.nextBool();
      final speed = isMoving ? 0.001 + _random.nextDouble() * 0.003 : 0.0;
      final moveAngle = _random.nextDouble() * 2 * math.pi;

      _targets.add(RadarTarget(
        id: i,
        angle: _random.nextDouble() * 2 * math.pi,
        distance: 0.15 + _random.nextDouble() * 0.75,
        type: TargetType.values[_random.nextInt(TargetType.values.length)],
        speed: speed,
        moveDirection: moveAngle,
        rcs: 0.5 + _random.nextDouble() * 1.5, // Radar cross-section
      ));
    }
  }

  void _updateMovingTargets() {
    if (!_isRunning) return;

    for (final target in _targets) {
      if (target.speed > 0) {
        // Update position
        target.angle += target.speed * math.cos(target.moveDirection);
        target.distance += target.speed * math.sin(target.moveDirection) * 0.1;

        // Keep within bounds
        if (target.distance < 0.1) {
          target.distance = 0.1;
          target.moveDirection = -target.moveDirection;
        }
        if (target.distance > 0.9) {
          target.distance = 0.9;
          target.moveDirection = -target.moveDirection;
        }

        // Wrap angle
        if (target.angle > 2 * math.pi) target.angle -= 2 * math.pi;
        if (target.angle < 0) target.angle += 2 * math.pi;
      }
    }
  }

  void _checkTargetDetection() {
    if (!_isRunning) return;

    final sweepAngle = _sweepController.value * 2 * math.pi;
    const sweepWidth = 0.12;

    for (final target in _targets) {
      final angleDiff = (target.angle - sweepAngle).abs();
      final isInSweep = angleDiff < sweepWidth || (2 * math.pi - angleDiff) < sweepWidth;

      if (isInSweep) {
        // Add blip to history
        _blipHistory.add(RadarBlip(
          x: target.distance * math.cos(target.angle - math.pi / 2),
          y: target.distance * math.sin(target.angle - math.pi / 2),
          color: target.type.color,
          intensity: target.rcs,
          createdAt: DateTime.now(),
          targetId: target.id,
        ));

        if (!target.detected) {
          setState(() {
            target.detected = true;
            target.detectedAt = DateTime.now();
            _detectedTargets++;
          });
        }
        target.lastSeenAt = DateTime.now();

        // Add to track history
        target.trackHistory.add(TrackPoint(
          x: target.distance * math.cos(target.angle - math.pi / 2),
          y: target.distance * math.sin(target.angle - math.pi / 2),
          time: DateTime.now(),
        ));

        // Limit track history
        if (target.trackHistory.length > 20) {
          target.trackHistory.removeAt(0);
        }
      }
    }

    if (_detectedTargets >= _totalTargets && _rotationCount >= 1) {
      _showCompletionDialog();
    }
  }

  void _cleanOldBlips() {
    final now = DateTime.now();
    _blipHistory.removeWhere(
      (blip) => now.difference(blip.createdAt).inMilliseconds > 8000,
    );
  }

  void _showCompletionDialog() {
    if (!_isRunning) return;
    _stopSimulation();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.radar, color: AppColors.success, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'การตรวจจับสำเร็จ!',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'ใช้เวลา $_rotationCount รอบ',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.radarColor.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.radarColor.withAlpha(50)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatColumn(
                    icon: Icons.gps_fixed,
                    value: '$_detectedTargets',
                    label: 'เป้าหมาย',
                  ),
                  _StatColumn(
                    icon: Icons.refresh,
                    value: '$_rotationCount',
                    label: 'รอบ',
                  ),
                  _StatColumn(
                    icon: Icons.speed,
                    value: '${(_sweepSpeed * _rotationCount).toStringAsFixed(1)}s',
                    label: 'เวลา',
                  ),
                ],
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
              _resetSimulation();
            },
            child: const Text('ปิด'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _startSimulation();
            },
            icon: const Icon(Icons.replay, size: 18),
            label: const Text('เริ่มใหม่'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.radarColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetSummary() {
    final typeCounts = <TargetType, int>{};
    final movingCounts = <TargetType, int>{};

    for (final target in _targets) {
      typeCounts[target.type] = (typeCounts[target.type] ?? 0) + 1;
      if (target.speed > 0) {
        movingCounts[target.type] = (movingCounts[target.type] ?? 0) + 1;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'สรุปเป้าหมาย',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        ...typeCounts.entries.map((entry) {
          final moving = movingCounts[entry.key] ?? 0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: entry.key.color.withAlpha(30),
                    shape: BoxShape.circle,
                    border: Border.all(color: entry.key.color, width: 2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.key.titleTh,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${entry.value}',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: entry.key.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (moving > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.moving, size: 12, color: AppColors.warning),
                        const SizedBox(width: 2),
                        Text(
                          '$moving',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  @override
  void dispose() {
    _sweepController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TutorialOverlay(
      tutorialKey: 'radar_sim',
      steps: SimulationTutorials.radarTutorial,
      primaryColor: AppColors.radarColor,
      child: Scaffold(
        backgroundColor: const Color(0xFF050A05),
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.radar, color: AppColors.radarColor, size: 24),
              const SizedBox(width: 8),
              const Text('RADAR SCOPE'),
            ],
          ),
          backgroundColor: const Color(0xFF0A150A),
          actions: [
            IconButton(
              icon: Icon(
                _showTrails ? Icons.timeline : Icons.timeline_outlined,
                color: _showTrails ? AppColors.radarColor : AppColors.textMuted,
              ),
              onPressed: () => setState(() => _showTrails = !_showTrails),
              tooltip: 'แสดงเส้นทาง',
            ),
            IconButton(
              icon: Icon(
                _showClutter ? Icons.grain : Icons.grain_outlined,
                color: _showClutter ? AppColors.warning : AppColors.textMuted,
              ),
              onPressed: () => setState(() => _showClutter = !_showClutter),
              tooltip: 'แสดง Clutter',
            ),
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('tutorial_radar_sim', false);
                if (mounted) setState(() {});
              },
              tooltip: 'คำแนะนำ',
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Status bar with radar info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A150A),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.radarColor.withAlpha(50),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    _RadarInfoChip(
                      icon: Icons.radar,
                      label: 'TGT',
                      value: '$_detectedTargets/$_totalTargets',
                      color: _detectedTargets == _totalTargets && _totalTargets > 0
                          ? AppColors.success
                          : AppColors.radarColor,
                    ),
                    const SizedBox(width: 12),
                    _RadarInfoChip(
                      icon: Icons.speed,
                      label: 'RPM',
                      value: (60 / _sweepSpeed).toStringAsFixed(0),
                      color: AppColors.radarColor,
                    ),
                    const SizedBox(width: 12),
                    _RadarInfoChip(
                      icon: Icons.gps_fixed,
                      label: 'RNG',
                      value: '${_radarRange.toInt()}km',
                      color: AppColors.radarColor,
                    ),
                    const Spacer(),
                    if (_isRunning)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.success.withAlpha(100)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.success.withAlpha(150),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'SCANNING',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              // Main radar display
              Expanded(
                child: Stack(
                  children: [
                    // Background grid effect
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _BackgroundGridPainter(),
                      ),
                    ),

                    // Main radar scope
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: AnimatedBuilder(
                            animation: Listenable.merge([_sweepController, _glowController]),
                            builder: (context, child) {
                              return CustomPaint(
                                painter: EnhancedRadarPainter(
                                  sweepAngle: _sweepController.value * 2 * math.pi,
                                  targets: _targets,
                                  blipHistory: _blipHistory,
                                  radarColor: AppColors.radarColor,
                                  glowIntensity: _glowController.value,
                                  showClutter: _showClutter,
                                  showTrails: _showTrails,
                                  radarRange: _radarRange,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // Corner info overlays
                    Positioned(
                      top: 24,
                      left: 24,
                      child: _CornerInfo(
                        title: 'ROTATION',
                        value: '$_rotationCount',
                        color: AppColors.radarColor,
                      ),
                    ),

                    Positioned(
                      top: 24,
                      right: 24,
                      child: _CornerInfo(
                        title: 'BEARING',
                        value: '${(_sweepController.value * 360).toStringAsFixed(0)}°',
                        color: AppColors.radarColor,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 500.ms),

              // Target type legend
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: TargetType.values.map((type) {
                      final count = _targets.where((t) => t.type == type && t.detected).length;
                      final total = _targets.where((t) => t.type == type).length;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: type.color.withAlpha(20),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: type.color.withAlpha(80)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: type.color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: type.color.withAlpha(150),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              type.titleTh,
                              style: TextStyle(
                                color: type.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_isRunning || _totalTargets > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: type.color.withAlpha(40),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$count/$total',
                                  style: TextStyle(
                                    color: type.color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ).animate(delay: 400.ms).fadeIn(),

              // Control buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A150A),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.radarColor.withAlpha(30),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Speed control
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'SWEEP: ${_sweepSpeed.toStringAsFixed(1)}s',
                                style: TextStyle(
                                  color: AppColors.radarColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const Spacer(),
                              Tooltip(
                                message: 'ความเร็วกวาด: ยิ่งช้า ตรวจจับแม่นยำขึ้น',
                                child: Icon(
                                  Icons.info_outline,
                                  color: AppColors.radarColor.withAlpha(150),
                                  size: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.radarColor,
                              inactiveTrackColor: AppColors.radarColor.withAlpha(50),
                              thumbColor: AppColors.radarColor,
                              overlayColor: AppColors.radarColor.withAlpha(30),
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            ),
                            child: Slider(
                              value: _sweepSpeed,
                              min: 1,
                              max: 6,
                              onChanged: _isRunning ? null : (value) {
                                setState(() {
                                  _sweepSpeed = value;
                                  _sweepController.duration = Duration(
                                    milliseconds: (_sweepSpeed * 1000).toInt(),
                                  );
                                });
                              },
                            ),
                          ),
                          // Thai help text
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.radarColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ความเร็วกวาด: ${_sweepSpeed < 2 ? "เร็ว" : _sweepSpeed < 4 ? "ปานกลาง" : "ช้า"} (${_sweepSpeed < 2 ? "อาจพลาดเป้าเล็ก" : _sweepSpeed < 4 ? "สมดุล" : "แม่นยำสูง"})',
                              style: TextStyle(
                                color: AppColors.radarColor.withAlpha(180),
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Main control buttons
                    if (_isRunning)
                      ElevatedButton.icon(
                        onPressed: _stopSimulation,
                        icon: const Icon(Icons.stop, size: 20),
                        label: const Text('STOP'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: _startSimulation,
                        icon: const Icon(Icons.play_arrow, size: 20),
                        label: const Text('START'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.radarColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                  ],
                ),
              ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}

// Enhanced radar painter with professional effects
class EnhancedRadarPainter extends CustomPainter {
  final double sweepAngle;
  final List<RadarTarget> targets;
  final List<RadarBlip> blipHistory;
  final Color radarColor;
  final double glowIntensity;
  final bool showClutter;
  final bool showTrails;
  final double radarRange;

  EnhancedRadarPainter({
    required this.sweepAngle,
    required this.targets,
    required this.blipHistory,
    required this.radarColor,
    required this.glowIntensity,
    required this.showClutter,
    required this.showTrails,
    required this.radarRange,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Draw scope background with gradient
    _drawBackground(canvas, center, radius);

    // Draw range rings with labels
    _drawRangeRings(canvas, center, radius);

    // Draw cross hairs
    _drawCrossHairs(canvas, center, radius);

    // Draw cardinal directions
    _drawCardinalDirections(canvas, center, radius);

    // Draw clutter/noise
    if (showClutter) {
      _drawClutter(canvas, center, radius);
    }

    // Draw target trails
    if (showTrails) {
      _drawTargetTrails(canvas, center, radius);
    }

    // Draw blip history (afterglow)
    _drawBlipHistory(canvas, center, radius);

    // Draw sweep with glow effect
    _drawSweep(canvas, center, radius);

    // Draw targets
    _drawTargets(canvas, center, radius);

    // Draw center point
    _drawCenter(canvas, center);

    // Draw outer ring with glow
    _drawOuterRing(canvas, center, radius);

    // Draw bearing markers
    _drawBearingMarkers(canvas, center, radius);
  }

  void _drawBackground(Canvas canvas, Offset center, double radius) {
    final bgGradient = RadialGradient(
      colors: [
        const Color(0xFF0A1F0A),
        const Color(0xFF051005),
        const Color(0xFF020802),
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    final bgPaint = Paint()
      ..shader = bgGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, bgPaint);
  }

  void _drawRangeRings(Canvas canvas, Offset center, double radius) {
    final ringPaint = Paint()
      ..color = radarColor.withAlpha(35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 1; i <= 4; i++) {
      final ringRadius = radius * i / 4;
      canvas.drawCircle(center, ringRadius, ringPaint);

      // Range labels
      final rangeValue = (radarRange * i / 4).toInt();
      textPainter.text = TextSpan(
        text: '$rangeValue',
        style: TextStyle(
          color: radarColor.withAlpha(100),
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(center.dx + 4, center.dy - ringRadius - 3),
      );
    }
  }

  void _drawCrossHairs(Canvas canvas, Offset center, double radius) {
    final crossPaint = Paint()
      ..color = radarColor.withAlpha(25)
      ..strokeWidth = 0.5;

    // Main cross
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      crossPaint,
    );

    // Diagonal cross
    final diagOffset = radius * 0.707;
    canvas.drawLine(
      Offset(center.dx - diagOffset, center.dy - diagOffset),
      Offset(center.dx + diagOffset, center.dy + diagOffset),
      crossPaint..color = radarColor.withAlpha(15),
    );
    canvas.drawLine(
      Offset(center.dx + diagOffset, center.dy - diagOffset),
      Offset(center.dx - diagOffset, center.dy + diagOffset),
      crossPaint,
    );
  }

  void _drawCardinalDirections(Canvas canvas, Offset center, double radius) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final directions = [
      ('N', Offset(center.dx, center.dy - radius + 18), true),
      ('S', Offset(center.dx, center.dy + radius - 18), false),
      ('E', Offset(center.dx + radius - 18, center.dy), false),
      ('W', Offset(center.dx - radius + 18, center.dy), false),
    ];

    for (final (text, offset, isNorth) in directions) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          color: isNorth ? radarColor : radarColor.withAlpha(120),
          fontSize: isNorth ? 14 : 11,
          fontWeight: isNorth ? FontWeight.bold : FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        offset - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  void _drawClutter(Canvas canvas, Offset center, double radius) {
    final clutterPaint = Paint()
      ..color = radarColor.withAlpha(15)
      ..style = PaintingStyle.fill;

    final random = math.Random(42); // Fixed seed for consistent clutter

    for (int i = 0; i < 100; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final dist = random.nextDouble() * radius;
      final size = 1.0 + random.nextDouble() * 2;

      final x = center.dx + dist * math.cos(angle);
      final y = center.dy + dist * math.sin(angle);

      canvas.drawCircle(Offset(x, y), size, clutterPaint);
    }
  }

  void _drawTargetTrails(Canvas canvas, Offset center, double radius) {
    for (final target in targets) {
      if (target.trackHistory.length < 2) continue;

      final path = Path();
      var first = true;

      for (final point in target.trackHistory) {
        final x = center.dx + radius * point.x;
        final y = center.dy + radius * point.y;

        if (first) {
          path.moveTo(x, y);
          first = false;
        } else {
          path.lineTo(x, y);
        }
      }

      final trailPaint = Paint()
        ..color = target.type.color.withAlpha(60)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path, trailPaint);
    }
  }

  void _drawBlipHistory(Canvas canvas, Offset center, double radius) {
    final now = DateTime.now();

    for (final blip in blipHistory) {
      final age = now.difference(blip.createdAt).inMilliseconds;
      final fade = (1.0 - age / 8000).clamp(0.0, 1.0);

      if (fade <= 0) continue;

      final x = center.dx + radius * blip.x;
      final y = center.dy + radius * blip.y;

      // Glow effect
      final glowPaint = Paint()
        ..color = blip.color.withAlpha((fade * 40 * blip.intensity).toInt())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(Offset(x, y), 8 * blip.intensity, glowPaint);

      // Main blip
      final blipPaint = Paint()
        ..color = blip.color.withAlpha((fade * 200).toInt())
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 3 * blip.intensity, blipPaint);
    }
  }

  void _drawSweep(Canvas canvas, Offset center, double radius) {
    // Multi-layer sweep effect for more realistic look

    // Outer glow
    final sweepGlowPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: sweepAngle - 0.5,
        endAngle: sweepAngle,
        colors: [
          Colors.transparent,
          radarColor.withAlpha(10),
          radarColor.withAlpha(25),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, sweepGlowPaint);

    // Main sweep gradient
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: sweepAngle - 0.25,
        endAngle: sweepAngle,
        colors: [
          Colors.transparent,
          radarColor.withAlpha(40),
          radarColor.withAlpha(100),
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, sweepPaint);

    // Bright sweep line with glow
    final lineEnd = Offset(
      center.dx + radius * math.cos(sweepAngle - math.pi / 2),
      center.dy + radius * math.sin(sweepAngle - math.pi / 2),
    );

    // Line glow
    final lineGlowPaint = Paint()
      ..color = radarColor.withAlpha(80)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawLine(center, lineEnd, lineGlowPaint);

    // Main line
    final linePaint = Paint()
      ..color = radarColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(center, lineEnd, linePaint);

    // Line tip glow
    final tipGlowPaint = Paint()
      ..color = radarColor.withAlpha(150)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(lineEnd, 4, tipGlowPaint);
  }

  void _drawTargets(Canvas canvas, Offset center, double radius) {
    final now = DateTime.now();

    for (final target in targets) {
      if (!target.detected) continue;

      final x = center.dx + radius * target.distance *
          math.cos(target.angle - math.pi / 2);
      final y = center.dy + radius * target.distance *
          math.sin(target.angle - math.pi / 2);

      final timeSinceLastSeen = target.lastSeenAt != null
          ? now.difference(target.lastSeenAt!).inMilliseconds
          : 10000;

      final brightness = (1.0 - timeSinceLastSeen / 6000).clamp(0.3, 1.0);

      // Target glow
      final glowPaint = Paint()
        ..color = target.type.color.withAlpha((brightness * 80).toInt())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(x, y), 10 * target.rcs, glowPaint);

      // Target fill
      final targetPaint = Paint()
        ..color = target.type.color.withAlpha((brightness * 255).toInt())
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 5 * target.rcs, targetPaint);

      // Target ring
      final ringPaint = Paint()
        ..color = target.type.color.withAlpha((brightness * 180).toInt())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(x, y), 8 * target.rcs, ringPaint);

      // Moving target indicator
      if (target.speed > 0) {
        final arrowLength = 15.0;
        final arrowEnd = Offset(
          x + arrowLength * math.cos(target.moveDirection),
          y + arrowLength * math.sin(target.moveDirection),
        );

        final arrowPaint = Paint()
          ..color = AppColors.warning.withAlpha((brightness * 200).toInt())
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        canvas.drawLine(Offset(x, y), arrowEnd, arrowPaint);

        // Arrow head
        final headPaint = Paint()
          ..color = AppColors.warning.withAlpha((brightness * 200).toInt())
          ..style = PaintingStyle.fill;

        final headPath = Path();
        final headAngle = target.moveDirection;
        headPath.moveTo(arrowEnd.dx, arrowEnd.dy);
        headPath.lineTo(
          arrowEnd.dx - 6 * math.cos(headAngle - 0.5),
          arrowEnd.dy - 6 * math.sin(headAngle - 0.5),
        );
        headPath.lineTo(
          arrowEnd.dx - 6 * math.cos(headAngle + 0.5),
          arrowEnd.dy - 6 * math.sin(headAngle + 0.5),
        );
        headPath.close();
        canvas.drawPath(headPath, headPaint);
      }

      // Detection ring animation (when freshly detected)
      final timeSinceDetection = now.difference(target.detectedAt!).inMilliseconds;
      if (timeSinceDetection < 1500) {
        final ringProgress = timeSinceDetection / 1500;
        final ringRadius = 8 + ringProgress * 25;
        final ringOpacity = (1.0 - ringProgress) * 255;

        final detectionRingPaint = Paint()
          ..color = target.type.color.withAlpha(ringOpacity.toInt())
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * (1 - ringProgress);

        canvas.drawCircle(Offset(x, y), ringRadius, detectionRingPaint);
      }
    }
  }

  void _drawCenter(Canvas canvas, Offset center) {
    // Center glow
    final centerGlowPaint = Paint()
      ..color = radarColor.withAlpha(60)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, 8, centerGlowPaint);

    // Center dot
    final centerPaint = Paint()
      ..color = radarColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, centerPaint);

    // Center ring
    final centerRingPaint = Paint()
      ..color = radarColor.withAlpha(150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, 6, centerRingPaint);
  }

  void _drawOuterRing(Canvas canvas, Offset center, double radius) {
    // Outer glow
    final outerGlowPaint = Paint()
      ..color = radarColor.withAlpha(30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center, radius, outerGlowPaint);

    // Main outer ring
    final outerRingPaint = Paint()
      ..color = radarColor.withAlpha(150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, outerRingPaint);
  }

  void _drawBearingMarkers(Canvas canvas, Offset center, double radius) {
    final markerPaint = Paint()
      ..color = radarColor.withAlpha(80)
      ..strokeWidth = 1;

    for (int i = 0; i < 36; i++) {
      final angle = i * math.pi / 18 - math.pi / 2;
      final isCardinal = i % 9 == 0;
      final isMajor = i % 3 == 0;

      final outerRadius = radius;
      final innerRadius = radius - (isCardinal ? 12 : (isMajor ? 8 : 4));

      final outer = Offset(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );
      final inner = Offset(
        center.dx + innerRadius * math.cos(angle),
        center.dy + innerRadius * math.sin(angle),
      );

      canvas.drawLine(inner, outer, markerPaint..strokeWidth = isMajor ? 1.5 : 0.8);
    }
  }

  @override
  bool shouldRepaint(covariant EnhancedRadarPainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.glowIntensity != glowIntensity ||
        oldDelegate.showClutter != showClutter ||
        oldDelegate.showTrails != showTrails;
  }
}

// Background grid painter
class _BackgroundGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0A150A)
      ..strokeWidth = 0.5;

    const spacing = 30.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint..color = const Color(0xFF0A150A),
      );
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// UI Components
class _RadarInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _RadarInfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color.withAlpha(150),
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CornerInfo extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _CornerInfo({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color.withAlpha(150),
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatColumn({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.radarColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
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

// Data models
class RadarTarget {
  final int id;
  double angle;
  double distance;
  final TargetType type;
  bool detected = false;
  DateTime? detectedAt;
  DateTime? lastSeenAt;
  double speed;
  double moveDirection;
  double rcs;
  final List<TrackPoint> trackHistory = [];

  RadarTarget({
    required this.id,
    required this.angle,
    required this.distance,
    required this.type,
    this.speed = 0,
    this.moveDirection = 0,
    this.rcs = 1.0,
  });
}

class RadarBlip {
  final double x;
  final double y;
  final Color color;
  final double intensity;
  final DateTime createdAt;
  final int targetId;

  RadarBlip({
    required this.x,
    required this.y,
    required this.color,
    required this.intensity,
    required this.createdAt,
    required this.targetId,
  });
}

class TrackPoint {
  final double x;
  final double y;
  final DateTime time;

  TrackPoint({
    required this.x,
    required this.y,
    required this.time,
  });
}

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

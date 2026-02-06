import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/constants.dart';
import '../../widgets/tutorial/tutorial_overlay.dart';
import '../../widgets/tutorial/simulation_tutorials.dart';

// ─────────────────────────────────────────────────────────────
// Data Models
// ─────────────────────────────────────────────────────────────

enum DroneType {
  recon, // โดรนลาดตระเวน - ช้า บินสูง
  fpv, // โดรน FPV - เร็ว บินต่ำ
  swarm, // ฝูงโดรน - กลุ่มเล็กๆ
  heavy, // โดรนขนส่ง/โจมตี - ใหญ่ ช้า
}

extension DroneTypeExtension on DroneType {
  String get nameTh {
    switch (this) {
      case DroneType.recon:
        return 'ลาดตระเวน';
      case DroneType.fpv:
        return 'FPV';
      case DroneType.swarm:
        return 'ฝูงโดรน';
      case DroneType.heavy:
        return 'โจมตี/ขนส่ง';
    }
  }

  String get descTh {
    switch (this) {
      case DroneType.recon:
        return 'บินสูง ช้า สัญญาณอ่อน';
      case DroneType.fpv:
        return 'บินต่ำ เร็ว สัญญาณวิดีโอ';
      case DroneType.swarm:
        return 'กลุ่มเล็ก สัญญาณหลายช่อง';
      case DroneType.heavy:
        return 'ขนาดใหญ่ สัญญาณ GPS แรง';
    }
  }

  Color get color {
    switch (this) {
      case DroneType.recon:
        return const Color(0xFF64B5F6); // blue
      case DroneType.fpv:
        return const Color(0xFFFF7043); // deep orange
      case DroneType.swarm:
        return const Color(0xFFFFD54F); // amber
      case DroneType.heavy:
        return const Color(0xFFE57373); // red
    }
  }

  IconData get icon {
    switch (this) {
      case DroneType.recon:
        return Icons.flight;
      case DroneType.fpv:
        return Icons.speed;
      case DroneType.swarm:
        return Icons.blur_on;
      case DroneType.heavy:
        return Icons.airplanemode_active;
    }
  }

  /// RF fingerprint frequencies (MHz) for identification phase
  List<double> get rfSignature {
    switch (this) {
      case DroneType.recon:
        return [2400, 2450]; // Wi-Fi band only
      case DroneType.fpv:
        return [5800, 5850]; // 5.8 GHz video
      case DroneType.swarm:
        return [900, 915, 2400]; // multi-band mesh
      case DroneType.heavy:
        return [1575, 2400]; // GPS L1 + control
    }
  }
}

enum CountermeasureType {
  rfJam, // รบกวน RF
  gpsSpoof, // หลอก GPS
  wideband, // รบกวนกว้าง
  kinetic, // ทำลายกายภาพ
}

extension CountermeasureExtension on CountermeasureType {
  String get nameTh {
    switch (this) {
      case CountermeasureType.rfJam:
        return 'รบกวน RF';
      case CountermeasureType.gpsSpoof:
        return 'หลอก GPS';
      case CountermeasureType.wideband:
        return 'รบกวนกว้าง';
      case CountermeasureType.kinetic:
        return 'สกัดกั้น';
    }
  }

  String get descTh {
    switch (this) {
      case CountermeasureType.rfJam:
        return 'ตัดสัญญาณควบคุม';
      case CountermeasureType.gpsSpoof:
        return 'หลอกพิกัด ให้บินผิดทาง';
      case CountermeasureType.wideband:
        return 'รบกวนทุกย่านความถี่';
      case CountermeasureType.kinetic:
        return 'ใช้อาวุธทำลายกายภาพ';
    }
  }

  IconData get icon {
    switch (this) {
      case CountermeasureType.rfJam:
        return Icons.wifi_off;
      case CountermeasureType.gpsSpoof:
        return Icons.gps_off;
      case CountermeasureType.wideband:
        return Icons.settings_input_antenna;
      case CountermeasureType.kinetic:
        return Icons.gps_fixed;
    }
  }

  Color get color {
    switch (this) {
      case CountermeasureType.rfJam:
        return const Color(0xFFFF9800);
      case CountermeasureType.gpsSpoof:
        return const Color(0xFF9C27B0);
      case CountermeasureType.wideband:
        return const Color(0xFFF44336);
      case CountermeasureType.kinetic:
        return const Color(0xFF607D8B);
    }
  }

  /// Best countermeasure for each drone type
  static CountermeasureType bestFor(DroneType type) {
    switch (type) {
      case DroneType.recon:
        return CountermeasureType.rfJam;
      case DroneType.fpv:
        return CountermeasureType.gpsSpoof;
      case DroneType.swarm:
        return CountermeasureType.wideband;
      case DroneType.heavy:
        return CountermeasureType.kinetic;
    }
  }
}

enum GamePhase {
  idle,
  scanning,
  identifying,
  neutralizing,
  complete,
}

class SimDrone {
  final int id;
  final DroneType type;
  double x; // -1 to 1 relative to center
  double y; // -1 to 1 relative to center
  double speed;
  double heading; // radians
  bool detected;
  bool identified;
  bool neutralized;
  DroneType? playerGuess;
  CountermeasureType? appliedCountermeasure;
  double signalStrength; // 0.0 - 1.0
  DateTime? detectedAt;

  SimDrone({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.speed,
    required this.heading,
    this.detected = false,
    this.identified = false,
    this.neutralized = false,
    this.playerGuess,
    this.appliedCountermeasure,
    this.signalStrength = 0.5,
    this.detectedAt,
  });

  double get distanceFromCenter => math.sqrt(x * x + y * y);

  void move(double dt) {
    x += math.cos(heading) * speed * dt;
    y += math.sin(heading) * speed * dt;

    // Bounce off boundaries
    if (x.abs() > 0.9) {
      heading = math.pi - heading;
      x = x.clamp(-0.9, 0.9);
    }
    if (y.abs() > 0.9) {
      heading = -heading;
      y = y.clamp(-0.9, 0.9);
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────────────────────────

class DroneSimScreen extends StatefulWidget {
  const DroneSimScreen({super.key});

  @override
  State<DroneSimScreen> createState() => _DroneSimScreenState();
}

class _DroneSimScreenState extends State<DroneSimScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _sweepController;
  late AnimationController _pulseController;
  late AnimationController _gameTickController;

  // Game state
  final math.Random _random = math.Random();
  GamePhase _phase = GamePhase.idle;
  final List<SimDrone> _drones = [];
  int _wave = 0;
  final int _maxWaves = 3;
  int _score = 0;
  int _detectionsCorrect = 0;
  int _identificationsCorrect = 0;
  int _neutralizationsCorrect = 0;
  int _totalDronesSpawned = 0;

  // Scanning phase
  double _scanProgress = 0;
  static const double _scanDuration = 25.0; // seconds

  // Identification phase
  SimDrone? _selectedDroneForId;

  // Neutralization phase
  SimDrone? _selectedDroneForNeutralize;
  CountermeasureType? _selectedCountermeasure;

  // Timer
  double _timeRemaining = 0;
  static const double _phaseTimeLimit = 30.0;

  @override
  void initState() {
    super.initState();

    _sweepController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _gameTickController = AnimationController(
      duration: const Duration(milliseconds: 16), // ~60fps
      vsync: this,
    );

    _gameTickController.addListener(_gameTick);
    _gameTickController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _phase != GamePhase.idle && _phase != GamePhase.complete) {
        _gameTickController.forward(from: 0);
      }
    });

    _sweepController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _phase == GamePhase.scanning) {
        _sweepController.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _sweepController.dispose();
    _pulseController.dispose();
    _gameTickController.dispose();
    super.dispose();
  }

  // ─── Game Logic ─────────────────────────────────────

  DateTime _lastTick = DateTime.now();

  void _gameTick() {
    final now = DateTime.now();
    final dt = now.difference(_lastTick).inMilliseconds / 1000.0;
    _lastTick = now;

    if (_phase == GamePhase.scanning) {
      _scanProgress += dt / _scanDuration;

      // Move drones
      for (final d in _drones) {
        d.move(dt);
      }

      // Auto-detect drones within sweep area
      final sweepAngle = _sweepController.value * 2 * math.pi;
      const sweepWidth = 0.15;
      for (final d in _drones) {
        if (d.detected) continue;
        final droneAngle = math.atan2(d.y, d.x) + math.pi;
        var angleDiff = (droneAngle - sweepAngle).abs();
        if (angleDiff > math.pi) angleDiff = 2 * math.pi - angleDiff;
        if (angleDiff < sweepWidth) {
          d.detected = true;
          d.detectedAt = DateTime.now();
          _detectionsCorrect++;
        }
      }

      if (_scanProgress >= 1.0) {
        // Mark all remaining as detected anyway
        for (final d in _drones) {
          if (!d.detected) {
            d.detected = true;
            d.detectedAt = DateTime.now();
          }
        }
        _transitionToIdentification();
      }

      setState(() {});
    } else if (_phase == GamePhase.neutralizing) {
      _timeRemaining -= dt;
      // Move surviving drones
      for (final d in _drones) {
        if (!d.neutralized) d.move(dt);
      }
      if (_timeRemaining <= 0 || _drones.every((d) => d.neutralized)) {
        _finishWave();
      }
      setState(() {});
    }
  }

  void _startGame() {
    setState(() {
      _wave = 0;
      _score = 0;
      _detectionsCorrect = 0;
      _identificationsCorrect = 0;
      _neutralizationsCorrect = 0;
      _totalDronesSpawned = 0;
      _drones.clear();
    });
    _startNextWave();
  }

  void _startNextWave() {
    _wave++;
    final droneCount = 2 + _wave; // 3, 4, 5 drones per wave
    _drones.clear();
    _selectedDroneForId = null;
    _selectedDroneForNeutralize = null;
    _selectedCountermeasure = null;
    _scanProgress = 0;

    // Generate drones
    final types = DroneType.values;
    for (int i = 0; i < droneCount; i++) {
      final type = types[_random.nextInt(types.length)];
      final angle = _random.nextDouble() * 2 * math.pi;
      final dist = 0.3 + _random.nextDouble() * 0.5;
      final speed = _droneSpeed(type);

      _drones.add(SimDrone(
        id: _totalDronesSpawned + i,
        type: type,
        x: dist * math.cos(angle),
        y: dist * math.sin(angle),
        speed: speed,
        heading: _random.nextDouble() * 2 * math.pi,
        signalStrength: 0.3 + _random.nextDouble() * 0.7,
      ));
    }
    _totalDronesSpawned += droneCount;

    // Start scanning phase
    _phase = GamePhase.scanning;
    _lastTick = DateTime.now();
    _sweepController.forward(from: 0);
    _gameTickController.forward(from: 0);
    setState(() {});
  }

  double _droneSpeed(DroneType type) {
    switch (type) {
      case DroneType.recon:
        return 0.02 + _random.nextDouble() * 0.02;
      case DroneType.fpv:
        return 0.05 + _random.nextDouble() * 0.04;
      case DroneType.swarm:
        return 0.03 + _random.nextDouble() * 0.03;
      case DroneType.heavy:
        return 0.01 + _random.nextDouble() * 0.02;
    }
  }

  void _transitionToIdentification() {
    _sweepController.stop();
    _gameTickController.stop();
    setState(() {
      _phase = GamePhase.identifying;
      _selectedDroneForId = _drones.firstWhere(
        (d) => !d.identified,
        orElse: () => _drones.first,
      );
    });
  }

  void _submitIdentification(DroneType guess) {
    if (_selectedDroneForId == null) return;

    final drone = _selectedDroneForId!;
    drone.playerGuess = guess;
    drone.identified = true;

    if (guess == drone.type) {
      _identificationsCorrect++;
      _score += 20;
    }

    // Find next unidentified drone
    final nextUnidentified = _drones.where((d) => !d.identified).toList();
    if (nextUnidentified.isEmpty) {
      _transitionToNeutralization();
    } else {
      setState(() {
        _selectedDroneForId = nextUnidentified.first;
      });
    }
  }

  void _transitionToNeutralization() {
    _timeRemaining = _phaseTimeLimit;
    _lastTick = DateTime.now();
    setState(() {
      _phase = GamePhase.neutralizing;
      _selectedDroneForNeutralize = null;
      _selectedCountermeasure = null;
    });
    _gameTickController.forward(from: 0);
  }

  void _applyCountermeasure() {
    if (_selectedDroneForNeutralize == null || _selectedCountermeasure == null) return;

    final drone = _selectedDroneForNeutralize!;
    final cm = _selectedCountermeasure!;
    drone.appliedCountermeasure = cm;

    final best = CountermeasureExtension.bestFor(drone.type);
    if (cm == best) {
      drone.neutralized = true;
      _neutralizationsCorrect++;
      _score += 30;
    } else {
      // Wrong countermeasure - partial effect
      drone.neutralized = true; // still neutralized but less points
      _score += 10;
    }

    setState(() {
      _selectedDroneForNeutralize = null;
      _selectedCountermeasure = null;
    });

    // Check if all neutralized
    if (_drones.every((d) => d.neutralized)) {
      _finishWave();
    }
  }

  void _finishWave() {
    _gameTickController.stop();
    _sweepController.stop();

    if (_wave >= _maxWaves) {
      setState(() => _phase = GamePhase.complete);
      _showCompletionDialog();
    } else {
      // Brief pause then next wave
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _startNextWave();
      });
    }
  }

  void _showCompletionDialog() {
    final maxScore = _totalDronesSpawned * 50; // 20 identify + 30 neutralize
    final pct = maxScore > 0 ? (_score / maxScore * 100).round() : 0;
    final stars = pct >= 90 ? 3 : (pct >= 70 ? 2 : (pct >= 50 ? 1 : 0));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.droneColor.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield, color: AppColors.droneColor, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ภารกิจสำเร็จ!',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'คะแนน $pct%',
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
            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    i < stars ? Icons.star : Icons.star_border,
                    color: AppColors.warning,
                    size: 36,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            // Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.droneColor.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.droneColor.withAlpha(50)),
              ),
              child: Column(
                children: [
                  _buildStatRow(Icons.radar, 'ตรวจจับ', '$_detectionsCorrect/$_totalDronesSpawned'),
                  const SizedBox(height: 8),
                  _buildStatRow(Icons.category, 'จำแนก', '$_identificationsCorrect/$_totalDronesSpawned'),
                  const SizedBox(height: 8),
                  _buildStatRow(Icons.wifi_off, 'ทำลาย', '$_neutralizationsCorrect/$_totalDronesSpawned'),
                  const Divider(color: AppColors.border, height: 20),
                  _buildStatRow(Icons.score, 'คะแนนรวม', '$_score'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _phase = GamePhase.idle);
            },
            child: const Text('ปิด'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _startGame();
            },
            icon: const Icon(Icons.replay, size: 18),
            label: const Text('เล่นใหม่'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.droneColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: AppTextStyles.titleSmall.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        )),
      ],
    );
  }

  // ─── Build UI ───────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('จำลอง Counter-UAS'),
        backgroundColor: AppColors.surface,
        actions: [
          if (_phase != GamePhase.idle && _phase != GamePhase.complete)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.droneColor.withAlpha(40),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.waves, color: AppColors.droneColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Wave $_wave/$_maxWaves',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.droneColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(40),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.score, color: AppColors.primary, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$_score',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: TutorialOverlay(
        tutorialKey: 'drone_sim',
        steps: SimulationTutorials.droneTutorial,
        primaryColor: AppColors.droneColor,
        child: SafeArea(
          child: Column(
            children: [
              // Phase indicator
              _buildPhaseIndicator(),
              // Main content area
              Expanded(child: _buildMainContent()),
              // Controls
              _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseIndicator() {
    final phases = [
      ('สแกน', GamePhase.scanning, Icons.radar),
      ('จำแนก', GamePhase.identifying, Icons.category),
      ('ทำลาย', GamePhase.neutralizing, Icons.wifi_off),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface,
      child: Row(
        children: phases.asMap().entries.map((entry) {
          final idx = entry.key;
          final (label, phase, icon) = entry.value;
          final isActive = _phase == phase;
          final isDone = _phase.index > phase.index && _phase != GamePhase.idle;

          return Expanded(
            child: Row(
              children: [
                if (idx > 0)
                  Expanded(
                    flex: 0,
                    child: Container(
                      width: 20,
                      height: 2,
                      color: isDone ? AppColors.success : AppColors.border,
                    ),
                  ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.droneColor.withAlpha(30)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          isDone ? Icons.check_circle : icon,
                          size: 20,
                          color: isActive
                              ? AppColors.droneColor
                              : isDone
                                  ? AppColors.success
                                  : AppColors.textMuted,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isActive
                                ? AppColors.droneColor
                                : isDone
                                    ? AppColors.success
                                    : AppColors.textMuted,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_phase) {
      case GamePhase.idle:
        return _buildIdleView();
      case GamePhase.scanning:
        return _buildScanningView();
      case GamePhase.identifying:
        return _buildIdentifyingView();
      case GamePhase.neutralizing:
        return _buildNeutralizingView();
      case GamePhase.complete:
        return _buildIdleView();
    }
  }

  // ─── Idle View ──────────────────────────────────────

  Widget _buildIdleView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.droneColor.withAlpha(30),
              border: Border.all(color: AppColors.droneColor.withAlpha(80), width: 2),
            ),
            child: const Icon(Icons.shield, size: 48, color: AppColors.droneColor),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.08, duration: 1500.ms),
          const SizedBox(height: 24),
          Text(
            'ระบบต่อต้านโดรน',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ตรวจจับ • จำแนก • ทำลาย',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _startGame,
            icon: const Icon(Icons.play_arrow),
            label: const Text('เริ่มภารกิจ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.droneColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              textStyle: AppTextStyles.titleSmall,
            ),
          ),
          const SizedBox(height: 16),
          // Drone type legend
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ประเภทโดรน:', style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                )),
                const SizedBox(height: 8),
                ...DroneType.values.map((t) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Icon(t.icon, size: 16, color: t.color),
                      const SizedBox(width: 8),
                      Text(t.nameTh, style: AppTextStyles.bodySmall.copyWith(
                        color: t.color,
                        fontWeight: FontWeight.bold,
                      )),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(t.descTh, style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        )),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Scanning View ──────────────────────────────────

  Widget _buildScanningView() {
    return Column(
      children: [
        // Scan progress
        Container(
          margin: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('กำลังสแกน...', style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.droneColor,
                    fontWeight: FontWeight.bold,
                  )),
                  Text(
                    'ตรวจจับ ${_drones.where((d) => d.detected).length}/${_drones.length}',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _scanProgress.clamp(0.0, 1.0),
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.droneColor),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        // Tactical map
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: AnimatedBuilder(
              animation: _sweepController,
              builder: (context, child) {
                return CustomPaint(
                  painter: TacticalMapPainter(
                    drones: _drones,
                    sweepAngle: _sweepController.value * 2 * math.pi,
                    phase: _phase,
                    pulseValue: _pulseController.value,
                    selectedDrone: null,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ─── Identifying View ───────────────────────────────

  Widget _buildIdentifyingView() {
    final drone = _selectedDroneForId;
    if (drone == null) return const SizedBox();

    final unidentifiedCount = _drones.where((d) => !d.identified).length;

    return Column(
      children: [
        // Progress info
        Container(
          margin: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('จำแนกโดรน', style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.droneColor,
                fontWeight: FontWeight.bold,
              )),
              Text('เหลือ $unidentifiedCount ลำ', style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              )),
            ],
          ),
        ),
        // Tactical map (static)
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: CustomPaint(
              painter: TacticalMapPainter(
                drones: _drones,
                sweepAngle: 0,
                phase: _phase,
                pulseValue: _pulseController.value,
                selectedDrone: drone,
              ),
              size: Size.infinite,
            ),
          ),
        ),
        // RF Signature display
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.droneColor.withAlpha(50)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('สัญญาณ RF ที่ตรวจจับ:', style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              )),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: CustomPaint(
                  painter: RFSignaturePainter(
                    frequencies: drone.type.rfSignature,
                    signalStrength: drone.signalStrength,
                  ),
                  size: Size.infinite,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0 MHz', style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textMuted, fontSize: 10,
                  )),
                  Text('ความแรง: ${(drone.signalStrength * 100).toInt()}%',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.droneColor, fontSize: 10,
                    ),
                  ),
                  Text('6000 MHz', style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textMuted, fontSize: 10,
                  )),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Drone type selection buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('เลือกประเภทโดรน:', style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          )),
        ),
        const SizedBox(height: 8),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.8,
              children: DroneType.values.map((type) {
                return Material(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _submitIdentification(type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: type.color.withAlpha(80)),
                      ),
                      child: Row(
                        children: [
                          Icon(type.icon, color: type.color, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              type.nameTh,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: type.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ─── Neutralizing View ──────────────────────────────

  Widget _buildNeutralizingView() {
    final survivingDrones = _drones.where((d) => !d.neutralized).toList();
    final neutralizedCount = _drones.where((d) => d.neutralized).length;

    return Column(
      children: [
        // Timer + progress
        Container(
          margin: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: _timeRemaining < 10 ? AppColors.error : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_timeRemaining.toInt()}s',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _timeRemaining < 10 ? AppColors.error : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                'ทำลาย $neutralizedCount/${_drones.length}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Tactical map
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: GestureDetector(
              onTapDown: (details) {
                _handleNeutralizeMapTap(details);
              },
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: TacticalMapPainter(
                      drones: _drones,
                      sweepAngle: 0,
                      phase: _phase,
                      pulseValue: _pulseController.value,
                      selectedDrone: _selectedDroneForNeutralize,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ),
        ),
        // Selected drone info + countermeasure buttons
        if (_selectedDroneForNeutralize != null) _buildCountermeasurePanel(),
        if (_selectedDroneForNeutralize == null && survivingDrones.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'แตะโดรนบนแผนที่เพื่อเลือกเป้าหมาย',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _handleNeutralizeMapTap(TapDownDetails details) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    // Approximate map area (center portion of screen)
    final size = box.size;
    final mapSize = math.min(size.width - 16, size.height * 0.5);
    final centerX = size.width / 2;
    final centerY = size.height * 0.35;

    final tapX = (details.localPosition.dx - centerX) / (mapSize / 2);
    final tapY = (details.localPosition.dy - centerY) / (mapSize / 2);

    // Find closest drone
    SimDrone? closest;
    double closestDist = double.infinity;
    for (final d in _drones) {
      if (d.neutralized) continue;
      final dist = math.sqrt(math.pow(d.x - tapX, 2) + math.pow(d.y - tapY, 2));
      if (dist < closestDist && dist < 0.2) {
        closestDist = dist;
        closest = d;
      }
    }

    if (closest != null) {
      setState(() {
        _selectedDroneForNeutralize = closest;
        _selectedCountermeasure = null;
      });
    }
  }

  Widget _buildCountermeasurePanel() {
    final drone = _selectedDroneForNeutralize!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.droneColor.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(drone.type.icon, color: drone.type.color, size: 20),
              const SizedBox(width: 8),
              Text(
                'เป้าหมาย #${drone.id + 1}',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (drone.identified && drone.playerGuess != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: drone.playerGuess == drone.type
                        ? AppColors.success.withAlpha(30)
                        : AppColors.warning.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    drone.playerGuess!.nameTh,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: drone.playerGuess == drone.type
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text('เลือกมาตรการตอบโต้:', style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          )),
          const SizedBox(height: 8),
          Row(
            children: CountermeasureType.values.map((cm) {
              final isSelected = _selectedCountermeasure == cm;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCountermeasure = cm),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? cm.color.withAlpha(40) : AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? cm.color : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(cm.icon, color: isSelected ? cm.color : AppColors.textMuted, size: 20),
                        const SizedBox(height: 2),
                        Text(
                          cm.nameTh,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isSelected ? cm.color : AppColors.textMuted,
                            fontSize: 9,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _selectedCountermeasure != null ? _applyCountermeasure : null,
              icon: const Icon(Icons.flash_on, size: 18),
              label: const Text('ปฏิบัติการ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.droneColor,
                disabledBackgroundColor: AppColors.border,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    if (_phase == GamePhase.idle || _phase == GamePhase.complete) {
      return const SizedBox(height: 8);
    }
    return const SizedBox(height: 8);
  }
}

// ─────────────────────────────────────────────────────────────
// Tactical Map Painter
// ─────────────────────────────────────────────────────────────

class TacticalMapPainter extends CustomPainter {
  final List<SimDrone> drones;
  final double sweepAngle;
  final GamePhase phase;
  final double pulseValue;
  final SimDrone? selectedDrone;

  TacticalMapPainter({
    required this.drones,
    required this.sweepAngle,
    required this.phase,
    required this.pulseValue,
    this.selectedDrone,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    // Draw background circle
    final bgPaint = Paint()
      ..color = const Color(0xFF0A1628)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw range rings
    final ringPaint = Paint()
      ..color = AppColors.droneColor.withAlpha(30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * i / 4, ringPaint);
    }

    // Draw crosshairs
    final crossPaint = Paint()
      ..color = AppColors.droneColor.withAlpha(20)
      ..strokeWidth = 0.5;
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      crossPaint,
    );

    // Draw sweep line (scanning phase)
    if (phase == GamePhase.scanning) {
      final sweepPaint = Paint()
        ..shader = SweepGradient(
          startAngle: sweepAngle - 0.5,
          endAngle: sweepAngle,
          colors: [
            Colors.transparent,
            AppColors.droneColor.withAlpha(60),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, sweepPaint);

      // Sweep line
      final linePaint = Paint()
        ..color = AppColors.droneColor.withAlpha(150)
        ..strokeWidth = 2;
      final lineEnd = Offset(
        center.dx + radius * math.cos(sweepAngle - math.pi / 2),
        center.dy + radius * math.sin(sweepAngle - math.pi / 2),
      );
      canvas.drawLine(center, lineEnd, linePaint);
    }

    // Draw drones
    for (final drone in drones) {
      if (!drone.detected && phase == GamePhase.scanning) continue;

      final dx = center.dx + drone.x * radius;
      final dy = center.dy + drone.y * radius;
      final pos = Offset(dx, dy);

      if (drone.neutralized) {
        // Neutralized - dim X mark
        final xPaint = Paint()
          ..color = AppColors.textMuted.withAlpha(80)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        canvas.drawLine(pos + const Offset(-6, -6), pos + const Offset(6, 6), xPaint);
        canvas.drawLine(pos + const Offset(6, -6), pos + const Offset(-6, 6), xPaint);
        continue;
      }

      // Selected highlight
      if (selectedDrone == drone) {
        final highlightPaint = Paint()
          ..color = AppColors.droneColor.withAlpha((40 + pulseValue * 40).toInt())
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 18, highlightPaint);

        final ringSelPaint = Paint()
          ..color = AppColors.droneColor.withAlpha(150)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(pos, 18, ringSelPaint);
      }

      // Drone blip
      final blipColor = drone.identified
          ? (drone.playerGuess == drone.type ? AppColors.success : AppColors.warning)
          : drone.type.color;

      final blipPaint = Paint()
        ..color = blipColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, 6, blipPaint);

      // Glow effect
      final glowPaint = Paint()
        ..color = blipColor.withAlpha((30 + pulseValue * 30).toInt())
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, 10, glowPaint);

      // Label
      if (drone.detected) {
        final textSpan = TextSpan(
          text: '#${drone.id + 1}',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, pos + const Offset(8, -6));
      }
    }

    // Draw center point (base)
    final centerPaint = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5, centerPaint);

    final centerRingPaint = Paint()
      ..color = AppColors.success.withAlpha(60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, 10, centerRingPaint);

    // Border
    final borderPaint = Paint()
      ..color = AppColors.droneColor.withAlpha(60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant TacticalMapPainter oldDelegate) => true;
}

// ─────────────────────────────────────────────────────────────
// RF Signature Painter (for identification phase)
// ─────────────────────────────────────────────────────────────

class RFSignaturePainter extends CustomPainter {
  final List<double> frequencies; // MHz values
  final double signalStrength;

  RFSignaturePainter({
    required this.frequencies,
    required this.signalStrength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background noise
    final noisePaint = Paint()
      ..color = AppColors.droneColor.withAlpha(15)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), noisePaint);

    // Noise floor
    final noiseFloorPaint = Paint()
      ..color = AppColors.droneColor.withAlpha(40)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final noisePath = Path();
    final random = math.Random(42);
    noisePath.moveTo(0, size.height * 0.8);
    for (double x = 0; x <= size.width; x += 2) {
      final noise = random.nextDouble() * size.height * 0.15;
      noisePath.lineTo(x, size.height * 0.75 + noise);
    }
    canvas.drawPath(noisePath, noiseFloorPaint);

    // Signal peaks
    final maxFreq = 6000.0; // MHz
    for (final freq in frequencies) {
      final xPos = (freq / maxFreq) * size.width;
      final peakHeight = signalStrength * size.height * 0.7;

      // Peak shape (gaussian-like)
      final peakPaint = Paint()
        ..color = AppColors.droneColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final peakPath = Path();
      const width = 20.0;
      peakPath.moveTo(xPos - width, size.height * 0.8);
      peakPath.quadraticBezierTo(
        xPos, size.height * 0.8 - peakHeight,
        xPos + width, size.height * 0.8,
      );
      canvas.drawPath(peakPath, peakPaint);

      // Fill under peak
      final fillPaint = Paint()
        ..color = AppColors.droneColor.withAlpha(30)
        ..style = PaintingStyle.fill;
      final fillPath = Path.from(peakPath);
      fillPath.lineTo(xPos + width, size.height);
      fillPath.lineTo(xPos - width, size.height);
      fillPath.close();
      canvas.drawPath(fillPath, fillPaint);

      // Frequency label
      final textSpan = TextSpan(
        text: '${freq.toInt()}',
        style: const TextStyle(
          color: AppColors.droneColor,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(xPos - textPainter.width / 2, 2));
    }
  }

  @override
  bool shouldRepaint(covariant RFSignaturePainter oldDelegate) => true;
}

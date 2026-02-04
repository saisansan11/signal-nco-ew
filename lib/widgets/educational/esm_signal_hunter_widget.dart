import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../app/constants.dart';

/// ESM Signal Hunter Widget - จำลองการค้นหาและระบุสัญญาณ
/// Animation ว้าว: เรดาร์สแกน, สัญญาณกระพริบ, Particle effects
class ESMSignalHunterWidget extends StatefulWidget {
  final VoidCallback? onComplete;

  const ESMSignalHunterWidget({super.key, this.onComplete});

  @override
  State<ESMSignalHunterWidget> createState() => _ESMSignalHunterWidgetState();
}

class _ESMSignalHunterWidgetState extends State<ESMSignalHunterWidget>
    with TickerProviderStateMixin {
  late AnimationController _radarController;
  late AnimationController _pulseController;
  late AnimationController _scanLineController;

  final List<DetectedSignal> _signals = [];
  final List<DetectedSignal> _foundSignals = [];
  int _score = 0;
  bool _isScanning = false;
  bool _gameComplete = false;

  @override
  void initState() {
    super.initState();

    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _generateSignals();
  }

  void _generateSignals() {
    final random = math.Random();
    final signalTypes = [
      SignalType.radar,
      SignalType.communication,
      SignalType.jammer,
      SignalType.unknown,
    ];

    for (int i = 0; i < 5; i++) {
      _signals.add(DetectedSignal(
        id: i,
        angle: random.nextDouble() * 2 * math.pi,
        distance: 0.3 + random.nextDouble() * 0.5,
        type: signalTypes[random.nextInt(signalTypes.length)],
        frequency: 100 + random.nextInt(900),
        strength: -80 + random.nextInt(50),
      ));
    }
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
      _foundSignals.clear();
    });

    _radarController.repeat();

    _radarController.addListener(_checkSignalDetection);
  }

  void _checkSignalDetection() {
    final currentAngle = _radarController.value * 2 * math.pi;

    for (final signal in _signals) {
      if (!_foundSignals.contains(signal)) {
        final angleDiff = (signal.angle - currentAngle).abs();
        if (angleDiff < 0.15 || angleDiff > (2 * math.pi - 0.15)) {
          setState(() {
            _foundSignals.add(signal);
          });
        }
      }
    }

    if (_foundSignals.length == _signals.length) {
      _radarController.stop();
      _radarController.removeListener(_checkSignalDetection);
      setState(() {
        _gameComplete = true;
      });
    }
  }

  void _onSignalTap(DetectedSignal signal) {
    if (!_foundSignals.contains(signal)) return;

    setState(() {
      signal.isIdentified = true;
      _score += signal.type == SignalType.unknown ? 50 : 100;
    });

    if (_foundSignals.every((s) => s.isIdentified)) {
      widget.onComplete?.call();
    }
  }

  @override
  void dispose() {
    _radarController.dispose();
    _pulseController.dispose();
    _scanLineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.esColor.withValues(alpha: 0.3)),
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
          const SizedBox(height: 16),

          // Radar Display
          AspectRatio(
            aspectRatio: 1,
            child: _buildRadarDisplay(),
          ),
          const SizedBox(height: 16),

          // Signal List
          if (_foundSignals.isNotEmpty) _buildSignalList(),

          // Start Button
          if (!_isScanning) _buildStartButton(),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(
          begin: const Offset(0.95, 0.95),
          curve: Curves.easeOutBack,
        );
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
            Icons.radar,
            color: AppColors.esColor,
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
                'ESM Signal Hunter',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.esColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'ค้นหาและระบุสัญญาณข้าศึก',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Score
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppColors.esGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.stars, color: Colors.white, size: 18),
              const SizedBox(width: 4),
              Text(
                '$_score',
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

  Widget _buildRadarDisplay() {
    return Stack(
      children: [
        // Radar background
        AnimatedBuilder(
          animation: _radarController,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: _RadarPainter(
                sweepAngle: _radarController.value * 2 * math.pi,
                isScanning: _isScanning,
              ),
            );
          },
        ),

        // Signals
        ..._signals.map((signal) => _buildSignalMarker(signal)),

        // Center point
        Center(
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.esColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.esColor.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          )
              .animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              )
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.3, 1.3),
                duration: 800.ms,
              ),
        ),

        // Status overlay
        if (_gameComplete)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'สแกนเสร็จสิ้น!',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'พบ ${_foundSignals.length} สัญญาณ',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().scale(),
          ),
      ],
    );
  }

  Widget _buildSignalMarker(DetectedSignal signal) {
    final isFound = _foundSignals.contains(signal);
    if (!isFound && !signal.isIdentified) return const SizedBox();

    return LayoutBuilder(
      builder: (context, constraints) {
        final center = Offset(
          constraints.maxWidth / 2,
          constraints.maxHeight / 2,
        );
        final maxRadius = constraints.maxWidth / 2 - 20;
        final signalPosition = Offset(
          center.dx + math.cos(signal.angle) * signal.distance * maxRadius,
          center.dy + math.sin(signal.angle) * signal.distance * maxRadius,
        );

        return Positioned(
          left: signalPosition.dx - 15,
          top: signalPosition.dy - 15,
          child: GestureDetector(
            onTap: () => _onSignalTap(signal),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: signal.isIdentified
                    ? signal.type.color.withValues(alpha: 0.8)
                    : AppColors.warning.withValues(alpha: 0.8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: signal.isIdentified ? signal.type.color : AppColors.warning,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (signal.isIdentified ? signal.type.color : AppColors.warning)
                        .withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                signal.isIdentified ? signal.type.icon : Icons.help_outline,
                color: Colors.white,
                size: 16,
              ),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.2, 1.2),
                  duration: 500.ms,
                ),
          ),
        );
      },
    );
  }

  Widget _buildSignalList() {
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
          Text(
            'สัญญาณที่ตรวจพบ (แตะเพื่อระบุ)',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.esColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _foundSignals.map((signal) {
              return GestureDetector(
                onTap: () => _onSignalTap(signal),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: signal.isIdentified
                        ? signal.type.color.withValues(alpha: 0.2)
                        : AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: signal.isIdentified
                          ? signal.type.color
                          : AppColors.warning,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        signal.isIdentified
                            ? signal.type.icon
                            : Icons.help_outline,
                        color: signal.isIdentified
                            ? signal.type.color
                            : AppColors.warning,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        signal.isIdentified
                            ? '${signal.type.nameTh} ${signal.frequency}MHz'
                            : 'ไม่ทราบ #${signal.id + 1}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: signal.isIdentified
                              ? signal.type.color
                              : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (100 * signal.id).ms).slideX(begin: 0.2);
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildStartButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: ElevatedButton.icon(
        onPressed: _startScan,
        icon: const Icon(Icons.play_arrow),
        label: const Text('เริ่มสแกน'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.esColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      )
          .animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          )
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 1000.ms,
          ),
    );
  }
}

/// Radar Painter
class _RadarPainter extends CustomPainter {
  final double sweepAngle;
  final bool isScanning;

  _RadarPainter({required this.sweepAngle, required this.isScanning});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background circle
    final bgPaint = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Concentric circles (range rings)
    final ringPaint = Paint()
      ..color = AppColors.esColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * i / 4, ringPaint);
    }

    // Cross lines
    final linePaint = Paint()
      ..color = AppColors.esColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      linePaint,
    );
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      linePaint,
    );

    // Sweep effect
    if (isScanning) {
      final sweepPaint = Paint()
        ..shader = SweepGradient(
          center: Alignment.center,
          startAngle: sweepAngle - 0.5,
          endAngle: sweepAngle,
          colors: [
            Colors.transparent,
            AppColors.esColor.withValues(alpha: 0.0),
            AppColors.esColor.withValues(alpha: 0.3),
            AppColors.esColor.withValues(alpha: 0.6),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawCircle(center, radius, sweepPaint);

      // Sweep line
      final sweepLinePaint = Paint()
        ..color = AppColors.esColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawLine(
        center,
        Offset(
          center.dx + math.cos(sweepAngle) * radius,
          center.dy + math.sin(sweepAngle) * radius,
        ),
        sweepLinePaint,
      );
    }

    // Border
    final borderPaint = Paint()
      ..color = AppColors.esColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.isScanning != isScanning;
  }
}

/// Signal Model
class DetectedSignal {
  final int id;
  final double angle;
  final double distance;
  final SignalType type;
  final int frequency;
  final int strength;
  bool isIdentified;

  DetectedSignal({
    required this.id,
    required this.angle,
    required this.distance,
    required this.type,
    required this.frequency,
    required this.strength,
    this.isIdentified = false,
  });
}

enum SignalType {
  radar,
  communication,
  jammer,
  unknown;

  String get nameTh {
    switch (this) {
      case SignalType.radar:
        return 'เรดาร์';
      case SignalType.communication:
        return 'สื่อสาร';
      case SignalType.jammer:
        return 'รบกวน';
      case SignalType.unknown:
        return 'ไม่ทราบ';
    }
  }

  Color get color {
    switch (this) {
      case SignalType.radar:
        return AppColors.radarColor;
      case SignalType.communication:
        return AppColors.accentBlue;
      case SignalType.jammer:
        return AppColors.eaColor;
      case SignalType.unknown:
        return AppColors.textSecondary;
    }
  }

  IconData get icon {
    switch (this) {
      case SignalType.radar:
        return Icons.radar;
      case SignalType.communication:
        return Icons.wifi;
      case SignalType.jammer:
        return Icons.flash_on;
      case SignalType.unknown:
        return Icons.help_outline;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../app/constants.dart';

/// Antenna Pattern Widget - แสดงรูปแบบการแผ่คลื่นของเสาอากาศ
/// Animation: คลื่นแผ่ออกจากเสาอากาศ, การหมุน, การเปรียบเทียบ
class AntennaPatternWidget extends StatefulWidget {
  final VoidCallback? onComplete;

  const AntennaPatternWidget({super.key, this.onComplete});

  @override
  State<AntennaPatternWidget> createState() => _AntennaPatternWidgetState();
}

class _AntennaPatternWidgetState extends State<AntennaPatternWidget>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _rotateController;
  late AnimationController _pulseController;

  AntennaType _selectedAntenna = AntennaType.omnidirectional;
  double _antennaGain = 6.0;
  double _beamwidth = 60.0;
  bool _showComparison = false;
  bool _isRotating = false;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  void _toggleRotation() {
    setState(() {
      _isRotating = !_isRotating;
    });

    if (_isRotating) {
      _rotateController.repeat();
    } else {
      _rotateController.stop();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.radarColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.radarColor.withValues(alpha: 0.1),
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

          // Antenna Pattern Display
          AspectRatio(
            aspectRatio: 1,
            child: _buildPatternDisplay(),
          ),
          const SizedBox(height: 16),

          // Antenna Type Selector
          _buildAntennaTypeSelector(),
          const SizedBox(height: 12),

          // Gain Control
          _buildGainControl(),
          const SizedBox(height: 12),

          // Beamwidth Control (for directional)
          if (_selectedAntenna != AntennaType.omnidirectional)
            _buildBeamwidthControl(),

          // Controls
          const SizedBox(height: 12),
          _buildControls(),

          // Stats
          const SizedBox(height: 12),
          _buildStats(),
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
            color: AppColors.radarColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.cell_tower,
            color: AppColors.radarColor,
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
                'Antenna Radiation Pattern',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.radarColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'รูปแบบการแผ่คลื่นเสาอากาศ',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Current Gain
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.radarColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${_antennaGain.toStringAsFixed(1)} dBi',
            style: AppTextStyles.codeMedium.copyWith(
              color: AppColors.radarColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatternDisplay() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pattern visualization
        AnimatedBuilder(
          animation: Listenable.merge([_waveController, _rotateController, _pulseController]),
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: _AntennaPatternPainter(
                waveProgress: _waveController.value,
                rotateProgress: _isRotating ? _rotateController.value : 0,
                pulseProgress: _pulseController.value,
                antennaType: _selectedAntenna,
                gain: _antennaGain,
                beamwidth: _beamwidth,
                showComparison: _showComparison,
              ),
            );
          },
        ),

        // Antenna icon at center
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.radarColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.radarColor.withValues(alpha: 0.5),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Icon(
            _selectedAntenna.icon,
            color: Colors.white,
            size: 24,
          ),
        )
            .animate(
              onPlay: (controller) => controller.repeat(reverse: true),
            )
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.15, 1.15),
              duration: 800.ms,
            ),

        // Direction labels
        ..._buildDirectionLabels(),

        // Gain rings labels
        Positioned(
          right: 10,
          top: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildGainLabel('0 dBi', 0.9),
              _buildGainLabel('-3 dBi', 0.7),
              _buildGainLabel('-6 dBi', 0.5),
              _buildGainLabel('-10 dBi', 0.3),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGainLabel(String label, double opacity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary.withValues(alpha: opacity),
          fontSize: 10,
        ),
      ),
    );
  }

  List<Widget> _buildDirectionLabels() {
    final labels = ['N', 'E', 'S', 'W'];
    final angles = [0.0, 90.0, 180.0, 270.0];

    return List.generate(4, (index) {
      final angle = angles[index] * math.pi / 180;
      final distance = 85.0;

      return Positioned(
        left: 85 + math.cos(angle - math.pi / 2) * distance,
        top: 85 + math.sin(angle - math.pi / 2) * distance,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
          child: Text(
            labels[index],
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAntennaTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ประเภทเสาอากาศ',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: AntennaType.values.map((type) {
              final isSelected = _selectedAntenna == type;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAntenna = type;
                      _antennaGain = type.defaultGain;
                      _beamwidth = type.defaultBeamwidth;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.radarColor.withValues(alpha: 0.2)
                          : AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.radarColor : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          type.icon,
                          color: isSelected ? AppColors.radarColor : AppColors.textSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          type.nameTh,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isSelected ? AppColors.radarColor : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
        // Description
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.radarColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.radarColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedAntenna.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGainControl() {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            'Gain',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.radarColor,
              inactiveTrackColor: AppColors.radarColor.withValues(alpha: 0.2),
              thumbColor: AppColors.radarColor,
              trackHeight: 4,
            ),
            child: Slider(
              value: _antennaGain,
              min: 0,
              max: 30,
              onChanged: (value) {
                setState(() {
                  _antennaGain = value;
                });
              },
            ),
          ),
        ),
        SizedBox(
          width: 60,
          child: Text(
            '${_antennaGain.toStringAsFixed(1)} dBi',
            style: AppTextStyles.codeMedium.copyWith(
              color: AppColors.radarColor,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildBeamwidthControl() {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            'Beamwidth',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.accentGreen,
              inactiveTrackColor: AppColors.accentGreen.withValues(alpha: 0.2),
              thumbColor: AppColors.accentGreen,
              trackHeight: 4,
            ),
            child: Slider(
              value: _beamwidth,
              min: 5,
              max: 120,
              onChanged: (value) {
                setState(() {
                  _beamwidth = value;
                });
              },
            ),
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            '${_beamwidth.toInt()}°',
            style: AppTextStyles.codeMedium.copyWith(
              color: AppColors.accentGreen,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      children: [
        Expanded(
          child: _buildControlButton(
            icon: _isRotating ? Icons.stop : Icons.rotate_right,
            label: _isRotating ? 'หยุดหมุน' : 'หมุนเสาอากาศ',
            color: AppColors.warning,
            onTap: _toggleRotation,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildControlButton(
            icon: _showComparison ? Icons.visibility_off : Icons.compare,
            label: _showComparison ? 'ซ่อนเปรียบเทียบ' : 'เปรียบเทียบ',
            color: AppColors.accentBlue,
            onTap: () {
              setState(() {
                _showComparison = !_showComparison;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Gain', '${_antennaGain.toStringAsFixed(1)} dBi', AppColors.radarColor),
          _buildStatItem('EIRP', '${(_antennaGain + 10).toStringAsFixed(1)} dBW', AppColors.accentGreen),
          _buildStatItem('Beamwidth', '${_beamwidth.toInt()}°', AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Antenna Pattern Painter
class _AntennaPatternPainter extends CustomPainter {
  final double waveProgress;
  final double rotateProgress;
  final double pulseProgress;
  final AntennaType antennaType;
  final double gain;
  final double beamwidth;
  final bool showComparison;

  _AntennaPatternPainter({
    required this.waveProgress,
    required this.rotateProgress,
    required this.pulseProgress,
    required this.antennaType,
    required this.gain,
    required this.beamwidth,
    required this.showComparison,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 - 20;

    // Background
    final bgPaint = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, maxRadius, bgPaint);

    // Grid circles
    _drawGrid(canvas, center, maxRadius);

    // Comparison pattern (omnidirectional)
    if (showComparison && antennaType != AntennaType.omnidirectional) {
      _drawPattern(
        canvas,
        center,
        maxRadius,
        AntennaType.omnidirectional,
        6.0,
        360.0,
        0,
        AppColors.textSecondary.withValues(alpha: 0.3),
      );
    }

    // Main pattern
    final rotation = rotateProgress * 2 * math.pi;
    _drawPattern(
      canvas,
      center,
      maxRadius,
      antennaType,
      gain,
      beamwidth,
      rotation,
      AppColors.radarColor,
    );

    // Radiation waves
    _drawRadiationWaves(canvas, center, maxRadius, rotation);

    // Border
    final borderPaint = Paint()
      ..color = AppColors.radarColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, maxRadius, borderPaint);
  }

  void _drawGrid(Canvas canvas, Offset center, double maxRadius) {
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Concentric circles
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, maxRadius * i / 4, gridPaint);
    }

    // Cross lines
    canvas.drawLine(
      Offset(center.dx, center.dy - maxRadius),
      Offset(center.dx, center.dy + maxRadius),
      gridPaint,
    );
    canvas.drawLine(
      Offset(center.dx - maxRadius, center.dy),
      Offset(center.dx + maxRadius, center.dy),
      gridPaint,
    );

    // Diagonal lines
    for (int i = 1; i < 4; i++) {
      final angle = i * math.pi / 4;
      canvas.drawLine(
        Offset(center.dx + math.cos(angle) * maxRadius, center.dy + math.sin(angle) * maxRadius),
        Offset(center.dx - math.cos(angle) * maxRadius, center.dy - math.sin(angle) * maxRadius),
        gridPaint..color = AppColors.border.withValues(alpha: 0.1),
      );
    }
  }

  void _drawPattern(
    Canvas canvas,
    Offset center,
    double maxRadius,
    AntennaType type,
    double gain,
    double beamwidth,
    double rotation,
    Color color,
  ) {
    final path = Path();
    final normalizedGain = (gain / 30).clamp(0.0, 1.0);
    final baseRadius = maxRadius * 0.3 + maxRadius * 0.6 * normalizedGain;

    for (double angle = 0; angle <= 360; angle += 1) {
      final rad = (angle - 90) * math.pi / 180 + rotation;
      double patternValue;

      switch (type) {
        case AntennaType.omnidirectional:
          patternValue = 1.0;
          break;
        case AntennaType.directional:
          final mainLobeAngle = (angle - rotation * 180 / math.pi) % 360;
          patternValue = _directionalPattern(mainLobeAngle, beamwidth);
          break;
        case AntennaType.parabolic:
          final mainLobeAngle = (angle - rotation * 180 / math.pi) % 360;
          patternValue = _parabolicPattern(mainLobeAngle, beamwidth);
          break;
        case AntennaType.yagi:
          final mainLobeAngle = (angle - rotation * 180 / math.pi) % 360;
          patternValue = _yagiPattern(mainLobeAngle, beamwidth);
          break;
        case AntennaType.phased:
          final mainLobeAngle = (angle - rotation * 180 / math.pi) % 360;
          patternValue = _phasedArrayPattern(mainLobeAngle, beamwidth);
          break;
      }

      final r = baseRadius * patternValue;
      final x = center.dx + r * math.cos(rad);
      final y = center.dy + r * math.sin(rad);

      if (angle == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Fill
    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.2 + pulseProgress * 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(path, glowPaint);

    // Stroke
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, strokePaint);
  }

  double _directionalPattern(double angle, double beamwidth) {
    final halfBW = beamwidth / 2;
    if (angle > 180) angle = 360 - angle;

    if (angle <= halfBW) {
      return math.cos(angle * math.pi / beamwidth);
    } else {
      return 0.15 + 0.1 * math.sin(angle * math.pi / 30);
    }
  }

  double _parabolicPattern(double angle, double beamwidth) {
    final halfBW = beamwidth / 2;
    if (angle > 180) angle = 360 - angle;

    if (angle <= halfBW) {
      return math.pow(math.cos(angle * math.pi / beamwidth), 2).toDouble();
    } else {
      return 0.05;
    }
  }

  double _yagiPattern(double angle, double beamwidth) {
    final halfBW = beamwidth / 2;
    if (angle > 180) angle = 360 - angle;

    if (angle <= halfBW) {
      return math.cos(angle * math.pi / beamwidth);
    } else if (angle > 180 - halfBW / 2) {
      // Back lobe
      return 0.2 * math.cos((360 - angle) * math.pi / beamwidth);
    } else {
      return 0.1 + 0.05 * math.sin(angle * math.pi / 20);
    }
  }

  double _phasedArrayPattern(double angle, double beamwidth) {
    final halfBW = beamwidth / 2;
    if (angle > 180) angle = 360 - angle;

    if (angle <= halfBW) {
      return math.pow(math.cos(angle * math.pi / beamwidth), 1.5).toDouble();
    } else {
      // Side lobes
      final sideLobeAngle = (angle - halfBW) % (beamwidth / 2);
      return 0.1 + 0.08 * math.cos(sideLobeAngle * math.pi / (beamwidth / 4));
    }
  }

  void _drawRadiationWaves(Canvas canvas, Offset center, double maxRadius, double rotation) {
    for (int i = 0; i < 3; i++) {
      final waveRadius = maxRadius * 0.3 + maxRadius * 0.6 * ((waveProgress + i / 3) % 1);
      final alpha = (1 - ((waveProgress + i / 3) % 1)) * 0.5;

      final wavePaint = Paint()
        ..color = AppColors.radarColor.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      if (antennaType == AntennaType.omnidirectional) {
        canvas.drawCircle(center, waveRadius, wavePaint);
      } else {
        // Draw arc in main beam direction
        final halfBW = beamwidth / 2 * math.pi / 180;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: waveRadius),
          -math.pi / 2 - halfBW + rotation,
          halfBW * 2,
          false,
          wavePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AntennaPatternPainter oldDelegate) => true;
}

/// Antenna Types
enum AntennaType {
  omnidirectional,
  directional,
  parabolic,
  yagi,
  phased;

  String get nameTh {
    switch (this) {
      case AntennaType.omnidirectional:
        return 'รอบทิศ';
      case AntennaType.directional:
        return 'ทิศทาง';
      case AntennaType.parabolic:
        return 'จานพาราโบลา';
      case AntennaType.yagi:
        return 'Yagi-Uda';
      case AntennaType.phased:
        return 'Phased Array';
    }
  }

  String get description {
    switch (this) {
      case AntennaType.omnidirectional:
        return 'แผ่คลื่นรอบทิศทาง 360° เหมาะสำหรับการสื่อสารทั่วไป';
      case AntennaType.directional:
        return 'แผ่คลื่นในทิศทางเดียว เพิ่ม Gain และระยะทาง';
      case AntennaType.parabolic:
        return 'มี Gain สูงมาก ใช้กับดาวเทียมและเรดาร์';
      case AntennaType.yagi:
        return 'เสาอากาศทิศทางยอดนิยม มี Front-to-Back ratio ดี';
      case AntennaType.phased:
        return 'หันลำคลื่นได้อิเล็กทรอนิกส์ ใช้ในเรดาร์สมัยใหม่';
    }
  }

  IconData get icon {
    switch (this) {
      case AntennaType.omnidirectional:
        return Icons.circle_outlined;
      case AntennaType.directional:
        return Icons.wifi;
      case AntennaType.parabolic:
        return Icons.satellite_alt;
      case AntennaType.yagi:
        return Icons.settings_input_antenna;
      case AntennaType.phased:
        return Icons.grid_4x4;
    }
  }

  double get defaultGain {
    switch (this) {
      case AntennaType.omnidirectional:
        return 2.0;
      case AntennaType.directional:
        return 10.0;
      case AntennaType.parabolic:
        return 25.0;
      case AntennaType.yagi:
        return 12.0;
      case AntennaType.phased:
        return 20.0;
    }
  }

  double get defaultBeamwidth {
    switch (this) {
      case AntennaType.omnidirectional:
        return 360.0;
      case AntennaType.directional:
        return 60.0;
      case AntennaType.parabolic:
        return 10.0;
      case AntennaType.yagi:
        return 45.0;
      case AntennaType.phased:
        return 30.0;
    }
  }
}

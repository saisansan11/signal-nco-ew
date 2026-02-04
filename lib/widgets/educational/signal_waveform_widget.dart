import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../app/constants.dart';

/// Signal Waveform Widget - แสดงรูปคลื่นสัญญาณแบบ Real-time
/// Animation ว้าว: คลื่นเคลื่อนไหว, การเปรียบเทียบสัญญาณ
class SignalWaveformWidget extends StatefulWidget {
  final SignalDisplayMode mode;
  final VoidCallback? onComplete;

  const SignalWaveformWidget({
    super.key,
    this.mode = SignalDisplayMode.single,
    this.onComplete,
  });

  @override
  State<SignalWaveformWidget> createState() => _SignalWaveformWidgetState();
}

class _SignalWaveformWidgetState extends State<SignalWaveformWidget>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _pulseController;

  WaveformType _selectedWaveform = WaveformType.sine;
  double _frequency = 1.0;
  double _amplitude = 1.0;
  bool _showNoise = false;
  bool _showJamming = false;
  double _noiseLevel = 0.2;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
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
        border: Border.all(color: AppColors.spectrumColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 16),

          // Waveform Display
          _buildWaveformDisplay(),
          const SizedBox(height: 16),

          // Waveform Type Selector
          _buildWaveformSelector(),
          const SizedBox(height: 12),

          // Controls
          _buildControls(),

          // Jamming Toggle
          const SizedBox(height: 12),
          _buildJammingToggle(),
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
            color: AppColors.spectrumColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Icon(
                Icons.show_chart,
                color: AppColors.spectrumColor,
                size: 28,
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Signal Waveform Analyzer',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.spectrumColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'วิเคราะห์รูปคลื่นสัญญาณ',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Signal Info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.spectrumColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${(_frequency * 100).toInt()} Hz',
            style: AppTextStyles.codeMedium.copyWith(
              color: AppColors.spectrumColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaveformDisplay() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Grid
            CustomPaint(
              size: const Size(double.infinity, 180),
              painter: _GridPainter(),
            ),

            // Waveform
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 180),
                  painter: _WaveformPainter(
                    progress: _waveController.value,
                    waveformType: _selectedWaveform,
                    frequency: _frequency,
                    amplitude: _amplitude,
                    showNoise: _showNoise,
                    noiseLevel: _noiseLevel,
                    showJamming: _showJamming,
                  ),
                );
              },
            ),

            // Labels
            Positioned(
              left: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _selectedWaveform.nameTh,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.accentGreen,
                  ),
                ),
              ),
            ),

            // Time domain label
            Positioned(
              right: 8,
              bottom: 8,
              child: Text(
                'Time →',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            // Status indicators
            if (_showJamming)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.eaColor.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flash_on, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'JAMMED',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(
                      begin: 0.7,
                      end: 1.0,
                      duration: 500.ms,
                    ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveformSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ประเภทสัญญาณ',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: WaveformType.values.map((type) {
              final isSelected = _selectedWaveform == type;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedWaveform = type;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? type.color.withValues(alpha: 0.2)
                          : AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? type.color : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          type.icon,
                          color: isSelected ? type.color : AppColors.textSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          type.nameTh,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isSelected ? type.color : AppColors.textSecondary,
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
      ],
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        // Frequency Control
        Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(
                'ความถี่',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColors.spectrumColor,
                  inactiveTrackColor: AppColors.spectrumColor.withValues(alpha: 0.2),
                  thumbColor: AppColors.spectrumColor,
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _frequency,
                  min: 0.2,
                  max: 3.0,
                  onChanged: (value) {
                    setState(() {
                      _frequency = value;
                    });
                  },
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                '${(_frequency * 100).toInt()} Hz',
                style: AppTextStyles.codeMedium.copyWith(
                  color: AppColors.spectrumColor,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),

        // Amplitude Control
        Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(
                'แอมพลิจูด',
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
                  value: _amplitude,
                  min: 0.1,
                  max: 1.0,
                  onChanged: (value) {
                    setState(() {
                      _amplitude = value;
                    });
                  },
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                '${(_amplitude * 100).toInt()}%',
                style: AppTextStyles.codeMedium.copyWith(
                  color: AppColors.accentGreen,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJammingToggle() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildToggleOption(
                  title: 'Noise',
                  subtitle: 'สัญญาณรบกวน',
                  icon: Icons.graphic_eq,
                  color: AppColors.warning,
                  isActive: _showNoise,
                  onTap: () {
                    setState(() {
                      _showNoise = !_showNoise;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildToggleOption(
                  title: 'Jamming',
                  subtitle: 'การรบกวน ECM',
                  icon: Icons.flash_on,
                  color: AppColors.eaColor,
                  isActive: _showJamming,
                  onTap: () {
                    setState(() {
                      _showJamming = !_showJamming;
                    });
                  },
                ),
              ),
            ],
          ),
          if (_showNoise) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'ระดับ Noise:',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.warning,
                      inactiveTrackColor: AppColors.warning.withValues(alpha: 0.2),
                      thumbColor: AppColors.warning,
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _noiseLevel,
                      min: 0.0,
                      max: 0.5,
                      onChanged: (value) {
                        setState(() {
                          _noiseLevel = value;
                        });
                      },
                    ),
                  ),
                ),
                Text(
                  '${(_noiseLevel * 100).toInt()}%',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color : AppColors.border,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? color : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isActive ? color : AppColors.textPrimary,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isActive,
              onChanged: (_) => onTap(),
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid Painter
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    // Horizontal lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical lines
    for (int i = 0; i <= 8; i++) {
      final x = size.width * i / 8;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Center line (zero line)
    final centerPaint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Waveform Painter
class _WaveformPainter extends CustomPainter {
  final double progress;
  final WaveformType waveformType;
  final double frequency;
  final double amplitude;
  final bool showNoise;
  final double noiseLevel;
  final bool showJamming;

  _WaveformPainter({
    required this.progress,
    required this.waveformType,
    required this.frequency,
    required this.amplitude,
    required this.showNoise,
    required this.noiseLevel,
    required this.showJamming,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.height / 2;
    final maxAmplitude = size.height / 2 - 20;
    final random = math.Random(42);

    // Main signal
    final signalPath = Path();
    final signalPaint = Paint()
      ..color = showJamming
          ? AppColors.eaColor.withValues(alpha: 0.5)
          : waveformType.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (double x = 0; x < size.width; x += 1) {
      final normalizedX = x / size.width;
      final phase = (normalizedX + progress) * frequency * 2 * math.pi * 4;

      double y = _getWaveformValue(phase, waveformType) * amplitude * maxAmplitude;

      // Add noise
      if (showNoise) {
        y += (random.nextDouble() - 0.5) * 2 * noiseLevel * maxAmplitude;
      }

      // Add jamming distortion
      if (showJamming) {
        final jammingNoise = math.sin(phase * 5 + progress * math.pi * 10) * 0.3;
        final burstNoise = random.nextDouble() > 0.9 ? (random.nextDouble() - 0.5) * 0.5 : 0;
        y = y * (0.3 + random.nextDouble() * 0.3) + (jammingNoise + burstNoise) * maxAmplitude;
      }

      if (x == 0) {
        signalPath.moveTo(x, center - y);
      } else {
        signalPath.lineTo(x, center - y);
      }
    }

    // Glow effect
    final glowPaint = Paint()
      ..color = (showJamming ? AppColors.eaColor : waveformType.color).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(signalPath, glowPaint);

    canvas.drawPath(signalPath, signalPaint);

    // Jamming overlay effect
    if (showJamming) {
      final jammingPaint = Paint()
        ..color = AppColors.eaColor.withValues(alpha: 0.1)
        ..style = PaintingStyle.fill;

      for (int i = 0; i < 5; i++) {
        final x = random.nextDouble() * size.width;
        final width = 20 + random.nextDouble() * 40;
        canvas.drawRect(
          Rect.fromLTWH(x, 0, width, size.height),
          jammingPaint,
        );
      }
    }
  }

  double _getWaveformValue(double phase, WaveformType type) {
    switch (type) {
      case WaveformType.sine:
        return math.sin(phase);
      case WaveformType.square:
        return math.sin(phase) > 0 ? 1.0 : -1.0;
      case WaveformType.triangle:
        final normalized = (phase / (2 * math.pi)) % 1;
        return normalized < 0.5
            ? 4 * normalized - 1
            : -4 * normalized + 3;
      case WaveformType.sawtooth:
        return 2 * ((phase / (2 * math.pi)) % 1) - 1;
      case WaveformType.pulse:
        final normalized = (phase / (2 * math.pi)) % 1;
        return normalized < 0.2 ? 1.0 : 0.0;
      case WaveformType.noise:
        return (math.Random().nextDouble() - 0.5) * 2;
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) => true;
}

/// Models
enum WaveformType {
  sine,
  square,
  triangle,
  sawtooth,
  pulse,
  noise;

  String get nameTh {
    switch (this) {
      case WaveformType.sine:
        return 'Sine';
      case WaveformType.square:
        return 'Square';
      case WaveformType.triangle:
        return 'Triangle';
      case WaveformType.sawtooth:
        return 'Sawtooth';
      case WaveformType.pulse:
        return 'Pulse';
      case WaveformType.noise:
        return 'Noise';
    }
  }

  Color get color {
    switch (this) {
      case WaveformType.sine:
        return AppColors.accentGreen;
      case WaveformType.square:
        return AppColors.accentBlue;
      case WaveformType.triangle:
        return AppColors.spectrumColor;
      case WaveformType.sawtooth:
        return AppColors.warning;
      case WaveformType.pulse:
        return AppColors.radarColor;
      case WaveformType.noise:
        return AppColors.textSecondary;
    }
  }

  IconData get icon {
    switch (this) {
      case WaveformType.sine:
        return Icons.waves;
      case WaveformType.square:
        return Icons.square_outlined;
      case WaveformType.triangle:
        return Icons.change_history;
      case WaveformType.sawtooth:
        return Icons.show_chart;
      case WaveformType.pulse:
        return Icons.flash_on;
      case WaveformType.noise:
        return Icons.graphic_eq;
    }
  }
}

enum SignalDisplayMode {
  single,
  comparison,
  spectrum;
}

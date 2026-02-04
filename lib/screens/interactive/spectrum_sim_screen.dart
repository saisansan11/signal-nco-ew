import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/constants.dart';
import '../../widgets/tutorial/tutorial_overlay.dart';
import '../../widgets/tutorial/simulation_tutorials.dart';

class SpectrumSimScreen extends StatefulWidget {
  const SpectrumSimScreen({super.key});

  @override
  State<SpectrumSimScreen> createState() => _SpectrumSimScreenState();
}

class _SpectrumSimScreenState extends State<SpectrumSimScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  final List<SimSignal> _signals = [];
  final math.Random _random = math.Random();
  bool _isScanning = false;
  int _detectedCount = 0;
  int _identifiedCount = 0;
  SimSignal? _selectedSignal;
  double _centerFrequency = 150.0; // MHz
  double _span = 100.0; // MHz

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: AppDurations.spectrumScan,
      vsync: this,
    );

    _scanController.addListener(() {
      if (_isScanning && _scanController.value > 0.95) {
        _checkSignalDetection();
      }
    });

    _generateSignals();
  }

  void _generateSignals() {
    _signals.clear();
    final signalCount = 4 + _random.nextInt(4); // 4-7 signals

    for (int i = 0; i < signalCount; i++) {
      _signals.add(SimSignal(
        id: i,
        frequency: 100 + _random.nextDouble() * 200, // 100-300 MHz
        bandwidth: 2 + _random.nextDouble() * 10, // 2-12 MHz bandwidth
        power: -40 - _random.nextDouble() * 50, // -40 to -90 dBm
        type: SignalType.values[_random.nextInt(SignalType.values.length)],
      ));
    }
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _detectedCount = 0;
      _identifiedCount = 0;
      _selectedSignal = null;
      for (final signal in _signals) {
        signal.detected = false;
        signal.identified = false;
      }
    });
    _scanController.repeat();
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
    _scanController.stop();
  }

  void _checkSignalDetection() {
    for (final signal in _signals) {
      if (!signal.detected) {
        // Check if signal is in visible range
        final minFreq = _centerFrequency - _span / 2;
        final maxFreq = _centerFrequency + _span / 2;
        if (signal.frequency >= minFreq && signal.frequency <= maxFreq) {
          // Random detection based on signal strength
          final detectionProb = (signal.power + 90) / 50; // Higher power = higher prob
          if (_random.nextDouble() < detectionProb) {
            setState(() {
              signal.detected = true;
              signal.detectedAt = DateTime.now();
              _detectedCount++;
            });
          }
        }
      }
    }
  }

  void _selectSignal(SimSignal signal) {
    if (!signal.detected) return;
    setState(() {
      _selectedSignal = signal;
    });
  }

  void _identifySignal(SignalType guessedType) {
    if (_selectedSignal == null || _selectedSignal!.identified) return;

    final isCorrect = _selectedSignal!.type == guessedType;
    setState(() {
      _selectedSignal!.identified = true;
      _selectedSignal!.correctlyIdentified = isCorrect;
      if (isCorrect) {
        _identifiedCount++;
      }
    });

    _showIdentificationFeedback(isCorrect);
  }

  void _showIdentificationFeedback(bool isCorrect) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(isCorrect
                ? 'ถูกต้อง! ระบุสัญญาณได้สำเร็จ'
                : 'ไม่ถูกต้อง - สัญญาณนี้คือ ${_selectedSignal!.type.titleTh}'),
          ],
        ),
        backgroundColor: isCorrect ? AppColors.success : AppColors.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _resetSimulation() {
    setState(() {
      _isScanning = false;
      _detectedCount = 0;
      _identifiedCount = 0;
      _selectedSignal = null;
      _generateSignals();
    });
    _scanController.stop();
    _scanController.reset();
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TutorialOverlay(
      tutorialKey: 'spectrum_sim',
      steps: SimulationTutorials.spectrumTutorial,
      primaryColor: AppColors.esColor,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('วิเคราะห์สเปกตรัม'),
          backgroundColor: AppColors.surface,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('tutorial_spectrum_sim', false);
                if (mounted) setState(() {});
              },
              tooltip: 'ดูคำแนะนำ',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetSimulation,
              tooltip: 'รีเซ็ต',
            ),
          ],
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
                    icon: Icons.wifi_tethering,
                    label: 'ตรวจจับ',
                    value: '$_detectedCount/${_signals.length}',
                    color: AppColors.esColor,
                  ),
                  _InfoItem(
                    icon: Icons.verified,
                    label: 'ระบุได้',
                    value: '$_identifiedCount',
                    color: AppColors.success,
                  ),
                  _InfoItem(
                    icon: Icons.center_focus_strong,
                    label: 'ความถี่กลาง',
                    value: '${_centerFrequency.toInt()} MHz',
                    color: AppColors.spectrumColor,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            // Spectrum display
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A),
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    border: Border.all(
                      color: AppColors.spectrumColor.withAlpha(100),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusL - 2),
                    child: AnimatedBuilder(
                      animation: _scanController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: SpectrumDisplayPainter(
                            signals: _signals,
                            centerFrequency: _centerFrequency,
                            span: _span,
                            scanProgress: _isScanning ? _scanController.value : 0,
                            selectedSignal: _selectedSignal,
                          ),
                          child: GestureDetector(
                            onTapDown: (details) {
                              _handleSpectrumTap(details.localPosition);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

            // Frequency controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('ความถี่กลาง', style: AppTextStyles.labelMedium),
                      Expanded(
                        child: Slider(
                          value: _centerFrequency,
                          min: 50,
                          max: 350,
                          divisions: 60,
                          activeColor: AppColors.spectrumColor,
                          onChanged: (value) {
                            setState(() => _centerFrequency = value);
                          },
                        ),
                      ),
                      Text('${_centerFrequency.toInt()} MHz',
                          style: AppTextStyles.labelMedium),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Span', style: AppTextStyles.labelMedium),
                      Expanded(
                        child: Slider(
                          value: _span,
                          min: 20,
                          max: 200,
                          divisions: 18,
                          activeColor: AppColors.spectrumColor,
                          onChanged: (value) {
                            setState(() => _span = value);
                          },
                        ),
                      ),
                      Text('${_span.toInt()} MHz',
                          style: AppTextStyles.labelMedium),
                    ],
                  ),
                ],
              ),
            ),

            // Signal identification panel
            if (_selectedSignal != null)
              Container(
                margin: const EdgeInsets.all(AppSizes.paddingM),
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(
                    color: _selectedSignal!.identified
                        ? (_selectedSignal!.correctlyIdentified
                            ? AppColors.success
                            : AppColors.error)
                        : AppColors.esColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.signal_cellular_alt,
                            color: AppColors.esColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'สัญญาณที่เลือก',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.esColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _SignalInfo(
                          label: 'ความถี่',
                          value: '${_selectedSignal!.frequency.toStringAsFixed(1)} MHz',
                        ),
                        _SignalInfo(
                          label: 'กำลังส่ง',
                          value: '${_selectedSignal!.power.toStringAsFixed(0)} dBm',
                        ),
                        _SignalInfo(
                          label: 'แบนด์วิดท์',
                          value: '${_selectedSignal!.bandwidth.toStringAsFixed(1)} MHz',
                        ),
                      ],
                    ),
                    if (!_selectedSignal!.identified) ...[
                      const SizedBox(height: 12),
                      Text(
                        'ระบุประเภทสัญญาณ:',
                        style: AppTextStyles.labelMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: SignalType.values.map((type) {
                          return _IdentifyButton(
                            type: type,
                            onTap: () => _identifySignal(type),
                          );
                        }).toList(),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _selectedSignal!.correctlyIdentified
                              ? AppColors.successLight
                              : AppColors.errorLight,
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _selectedSignal!.correctlyIdentified
                                  ? Icons.check_circle
                                  : Icons.info,
                              color: _selectedSignal!.correctlyIdentified
                                  ? AppColors.success
                                  : AppColors.error,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'สัญญาณนี้คือ: ${_selectedSignal!.type.titleTh}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: _selectedSignal!.correctlyIdentified
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1),

            // Control button
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeightL,
                child: ElevatedButton.icon(
                  onPressed: _isScanning ? _stopScanning : _startScanning,
                  icon: Icon(_isScanning ? Icons.stop : Icons.play_arrow),
                  label: Text(_isScanning ? 'หยุดสแกน' : 'เริ่มสแกน'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isScanning ? AppColors.error : AppColors.spectrumColor,
                  ),
                ),
              ),
            ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),
          ],
        ),
      ),
    ),
    );
  }

  void _handleSpectrumTap(Offset position) {
    if (_signals.isEmpty) return;

    // Convert tap position to frequency
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // Find closest detected signal to tap
    SimSignal? closest;
    double minDistance = double.infinity;

    for (final signal in _signals) {
      if (!signal.detected) continue;

      // Calculate signal position
      final minFreq = _centerFrequency - _span / 2;
      final maxFreq = _centerFrequency + _span / 2;
      if (signal.frequency < minFreq || signal.frequency > maxFreq) continue;

      final normalizedFreq = (signal.frequency - minFreq) / _span;
      final signalX = normalizedFreq * renderBox.size.width;
      final distance = (signalX - position.dx).abs();

      if (distance < minDistance && distance < 30) {
        minDistance = distance;
        closest = signal;
      }
    }

    if (closest != null) {
      _selectSignal(closest);
    }
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
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

class _SignalInfo extends StatelessWidget {
  final String label;
  final String value;

  const _SignalInfo({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }
}

class _IdentifyButton extends StatelessWidget {
  final SignalType type;
  final VoidCallback onTap;

  const _IdentifyButton({
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: type.color.withAlpha(30),
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            border: Border.all(color: type.color.withAlpha(100)),
          ),
          child: Text(
            type.titleTh,
            style: AppTextStyles.labelSmall.copyWith(
              color: type.color,
            ),
          ),
        ),
      ),
    );
  }
}

/// Spectrum display painter
class SpectrumDisplayPainter extends CustomPainter {
  final List<SimSignal> signals;
  final double centerFrequency;
  final double span;
  final double scanProgress;
  final SimSignal? selectedSignal;

  SpectrumDisplayPainter({
    required this.signals,
    required this.centerFrequency,
    required this.span,
    required this.scanProgress,
    this.selectedSignal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final minFreq = centerFrequency - span / 2;
    final maxFreq = centerFrequency + span / 2;

    // Draw grid
    _drawGrid(canvas, size, minFreq, maxFreq);

    // Draw noise floor
    _drawNoiseFloor(canvas, size);

    // Draw signals
    for (final signal in signals) {
      if (signal.detected &&
          signal.frequency >= minFreq &&
          signal.frequency <= maxFreq) {
        _drawSignal(canvas, size, signal, minFreq, maxFreq);
      }
    }

    // Draw scan line
    if (scanProgress > 0) {
      _drawScanLine(canvas, size);
    }

    // Draw frequency labels
    _drawFrequencyLabels(canvas, size, minFreq, maxFreq);

    // Draw power labels
    _drawPowerLabels(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size, double minFreq, double maxFreq) {
    final gridPaint = Paint()
      ..color = Colors.green.withAlpha(30)
      ..strokeWidth = 0.5;

    // Vertical lines (frequency)
    for (int i = 0; i <= 10; i++) {
      final x = size.width * i / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Horizontal lines (power)
    for (int i = 0; i <= 6; i++) {
      final y = size.height * i / 6;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawNoiseFloor(Canvas canvas, Size size) {
    final random = math.Random(42); // Fixed seed for consistent noise
    final noisePaint = Paint()
      ..color = Colors.green.withAlpha(60)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path();
    final noiseLevel = size.height * 0.85; // -90 dBm baseline

    path.moveTo(0, noiseLevel + random.nextDouble() * 10 - 5);

    for (int i = 1; i <= size.width.toInt(); i++) {
      final noise = random.nextDouble() * 15 - 7.5;
      path.lineTo(i.toDouble(), noiseLevel + noise);
    }

    canvas.drawPath(path, noisePaint);
  }

  void _drawSignal(Canvas canvas, Size size, SimSignal signal,
      double minFreq, double maxFreq) {
    final normalizedFreq = (signal.frequency - minFreq) / (maxFreq - minFreq);
    final x = normalizedFreq * size.width;

    // Power level: -40 dBm at top, -100 dBm at bottom
    final normalizedPower = (signal.power + 100) / 60;
    final peakY = size.height * (1 - normalizedPower.clamp(0.0, 1.0));

    // Signal width based on bandwidth
    final bandwidthPixels = (signal.bandwidth / span) * size.width;

    // Create gradient for signal
    final isSelected = selectedSignal == signal;
    final signalPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          isSelected
              ? Colors.yellow.withAlpha(200)
              : signal.type.color.withAlpha(200),
          isSelected
              ? Colors.yellow.withAlpha(50)
              : signal.type.color.withAlpha(50),
        ],
      ).createShader(Rect.fromLTWH(
        x - bandwidthPixels / 2,
        peakY,
        bandwidthPixels,
        size.height - peakY,
      ));

    // Draw signal peak
    final path = Path();
    path.moveTo(x - bandwidthPixels / 2, size.height);
    path.quadraticBezierTo(
      x - bandwidthPixels / 4,
      peakY + (size.height - peakY) * 0.3,
      x,
      peakY,
    );
    path.quadraticBezierTo(
      x + bandwidthPixels / 4,
      peakY + (size.height - peakY) * 0.3,
      x + bandwidthPixels / 2,
      size.height,
    );
    path.close();

    canvas.drawPath(path, signalPaint);

    // Draw peak line
    final peakLinePaint = Paint()
      ..color = isSelected ? Colors.yellow : signal.type.color
      ..strokeWidth = isSelected ? 2 : 1.5
      ..style = PaintingStyle.stroke;

    final peakPath = Path();
    peakPath.moveTo(x - bandwidthPixels / 2, size.height * 0.9);
    peakPath.quadraticBezierTo(
      x - bandwidthPixels / 4,
      peakY + (size.height - peakY) * 0.2,
      x,
      peakY,
    );
    peakPath.quadraticBezierTo(
      x + bandwidthPixels / 4,
      peakY + (size.height - peakY) * 0.2,
      x + bandwidthPixels / 2,
      size.height * 0.9,
    );

    canvas.drawPath(peakPath, peakLinePaint);

    // Draw selection indicator
    if (isSelected) {
      final markerPaint = Paint()
        ..color = Colors.yellow
        ..strokeWidth = 2;

      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        markerPaint..color = Colors.yellow.withAlpha(100),
      );

      canvas.drawCircle(Offset(x, peakY), 5, markerPaint);
    }

    // Draw identification marker
    if (signal.identified) {
      final iconPaint = Paint()
        ..color = signal.correctlyIdentified ? Colors.green : Colors.red;

      canvas.drawCircle(
        Offset(x, peakY - 15),
        8,
        iconPaint,
      );
    }
  }

  void _drawScanLine(Canvas canvas, Size size) {
    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.green.withAlpha(150),
          Colors.green,
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(
        scanProgress * size.width - 30,
        0,
        30,
        size.height,
      ));

    canvas.drawRect(
      Rect.fromLTWH(
        scanProgress * size.width - 30,
        0,
        30,
        size.height,
      ),
      scanPaint,
    );

    // Scan line
    final linePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(scanProgress * size.width, 0),
      Offset(scanProgress * size.width, size.height),
      linePaint,
    );
  }

  void _drawFrequencyLabels(
      Canvas canvas, Size size, double minFreq, double maxFreq) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i <= 4; i++) {
      final freq = minFreq + (maxFreq - minFreq) * i / 4;
      textPainter.text = TextSpan(
        text: '${freq.toInt()}',
        style: TextStyle(
          color: Colors.green.withAlpha(180),
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          size.width * i / 4 - textPainter.width / 2,
          size.height - textPainter.height - 2,
        ),
      );
    }
  }

  void _drawPowerLabels(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final powers = [-40, -60, -80, -100];
    for (int i = 0; i < powers.length; i++) {
      final y = size.height * i / (powers.length - 1);
      textPainter.text = TextSpan(
        text: '${powers[i]}',
        style: TextStyle(
          color: Colors.green.withAlpha(180),
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant SpectrumDisplayPainter oldDelegate) {
    return oldDelegate.scanProgress != scanProgress ||
        oldDelegate.selectedSignal != selectedSignal ||
        oldDelegate.centerFrequency != centerFrequency ||
        oldDelegate.span != span;
  }
}

/// Simulated signal
class SimSignal {
  final int id;
  final double frequency; // MHz
  final double bandwidth; // MHz
  final double power; // dBm
  final SignalType type;
  bool detected = false;
  bool identified = false;
  bool correctlyIdentified = false;
  DateTime? detectedAt;

  SimSignal({
    required this.id,
    required this.frequency,
    required this.bandwidth,
    required this.power,
    required this.type,
  });
}

/// Signal type
enum SignalType {
  communication,
  radar,
  navigation,
  unknown,
}

extension SignalTypeExtension on SignalType {
  String get titleTh {
    switch (this) {
      case SignalType.communication:
        return 'สื่อสาร';
      case SignalType.radar:
        return 'เรดาร์';
      case SignalType.navigation:
        return 'นำทาง';
      case SignalType.unknown:
        return 'ไม่ทราบ';
    }
  }

  Color get color {
    switch (this) {
      case SignalType.communication:
        return AppColors.accentBlue;
      case SignalType.radar:
        return AppColors.radarColor;
      case SignalType.navigation:
        return AppColors.gpsColor;
      case SignalType.unknown:
        return AppColors.warning;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../app/constants.dart';

/// GPS Warfare Widget - จำลองการรบกวนและหลอก GPS
/// แสดง: GPS Jamming, GPS Spoofing, การป้องกัน
class GPSWarfareWidget extends StatefulWidget {
  final VoidCallback? onComplete;

  const GPSWarfareWidget({super.key, this.onComplete});

  @override
  State<GPSWarfareWidget> createState() => _GPSWarfareWidgetState();
}

class _GPSWarfareWidgetState extends State<GPSWarfareWidget>
    with TickerProviderStateMixin {
  late AnimationController _satelliteController;
  late AnimationController _signalController;
  late AnimationController _jammingController;

  GPSMode _currentMode = GPSMode.normal;
  double _jammingPower = 0.5;
  double _spoofOffset = 0.0; // km offset from real position
  bool _antiJamEnabled = false;

  // Simulated positions
  final Offset _realPosition = const Offset(0.5, 0.5);
  Offset _displayedPosition = const Offset(0.5, 0.5);
  double _signalStrength = 1.0;
  int _satellitesInView = 8;

  @override
  void initState() {
    super.initState();

    _satelliteController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _signalController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _jammingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _setMode(GPSMode mode) {
    setState(() {
      _currentMode = mode;
    });

    switch (mode) {
      case GPSMode.normal:
        _jammingController.stop();
        _displayedPosition = _realPosition;
        _signalStrength = 1.0;
        _satellitesInView = 8;
        break;
      case GPSMode.jamming:
        _jammingController.repeat(reverse: true);
        _applyJamming();
        break;
      case GPSMode.spoofing:
        _jammingController.stop();
        _applySpoofing();
        break;
    }
  }

  void _applyJamming() {
    setState(() {
      if (_antiJamEnabled) {
        // Anti-jam reduces effect
        _signalStrength = 0.3 + (1 - _jammingPower) * 0.5;
        _satellitesInView = (4 + (1 - _jammingPower) * 4).toInt();
        _displayedPosition = _realPosition;
      } else {
        _signalStrength = (1 - _jammingPower).clamp(0.0, 1.0);
        _satellitesInView = ((1 - _jammingPower) * 8).toInt();
        // Position becomes unreliable
        if (_signalStrength < 0.3) {
          _displayedPosition = const Offset(-1, -1); // Lost
        } else {
          _displayedPosition = _realPosition;
        }
      }
    });
  }

  void _applySpoofing() {
    setState(() {
      _signalStrength = 1.0; // Spoofed signal appears strong
      _satellitesInView = 8;
      // Position is offset
      final spoofDirection = math.Random().nextDouble() * 2 * math.pi;
      final offsetAmount = _spoofOffset / 100; // Normalize
      _displayedPosition = Offset(
        (_realPosition.dx + math.cos(spoofDirection) * offsetAmount).clamp(0.1, 0.9),
        (_realPosition.dy + math.sin(spoofDirection) * offsetAmount).clamp(0.1, 0.9),
      );
    });
  }

  @override
  void dispose() {
    _satelliteController.dispose();
    _signalController.dispose();
    _jammingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getModeColor().withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: _getModeColor().withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: isWideScreen ? _buildWideLayout() : _buildCompactLayout(),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
      },
    );
  }

  /// Wide screen layout - side by side
  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Visualization
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              AspectRatio(
                aspectRatio: 1.2,
                child: _buildGPSVisualization(),
              ),
              const SizedBox(height: 12),
              _buildStatusDisplay(),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Right: Controls
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModeSelector(),
              const SizedBox(height: 12),
              if (_currentMode == GPSMode.jamming) _buildJammingControls(),
              if (_currentMode == GPSMode.spoofing) _buildSpoofingControls(),
              const SizedBox(height: 12),
              _buildAntiJamToggle(),
            ],
          ),
        ),
      ],
    );
  }

  /// Compact mobile layout
  Widget _buildCompactLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        _buildHeader(),
        const SizedBox(height: 12),

        // GPS Visualization - more compact
        AspectRatio(
          aspectRatio: 1.6, // Wider = shorter height
          child: _buildGPSVisualization(),
        ),
        const SizedBox(height: 12),

        // Mode Selector
        _buildModeSelector(),
        const SizedBox(height: 10),

        // Controls based on mode
        if (_currentMode == GPSMode.jamming) _buildJammingControls(),
        if (_currentMode == GPSMode.spoofing) _buildSpoofingControls(),

        // Anti-Jam Toggle
        const SizedBox(height: 10),
        _buildAntiJamToggle(),

        // Status Display
        const SizedBox(height: 10),
        _buildStatusDisplay(),
      ],
    );
  }

  Color _getModeColor() {
    switch (_currentMode) {
      case GPSMode.normal:
        return AppColors.success;
      case GPSMode.jamming:
        return AppColors.eaColor;
      case GPSMode.spoofing:
        return AppColors.warning;
    }
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getModeColor().withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.satellite_alt,
            color: _getModeColor(),
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
                'GPS Warfare Simulator',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: _getModeColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _currentMode.description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Signal strength indicator
        _buildSignalIndicator(),
      ],
    );
  }

  Widget _buildSignalIndicator() {
    final bars = 4;
    final activeBars = (_signalStrength * bars).ceil();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            _signalStrength > 0.3 ? Icons.gps_fixed : Icons.gps_off,
            color: _signalStrength > 0.3 ? _getModeColor() : AppColors.error,
            size: 18,
          ),
          const SizedBox(width: 8),
          Row(
            children: List.generate(bars, (index) {
              final isActive = index < activeBars;
              return Container(
                width: 4,
                height: 8 + index * 4.0,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: isActive ? _getModeColor() : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGPSVisualization() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AnimatedBuilder(
          animation: Listenable.merge([_satelliteController, _signalController, _jammingController]),
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: _GPSVisualizationPainter(
                satelliteProgress: _satelliteController.value,
                signalProgress: _signalController.value,
                jammingProgress: _currentMode == GPSMode.jamming ? _jammingController.value : 0,
                mode: _currentMode,
                realPosition: _realPosition,
                displayedPosition: _displayedPosition,
                signalStrength: _signalStrength,
                satellitesInView: _satellitesInView,
                jammingPower: _jammingPower,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'โหมดการทำงาน',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: GPSMode.values.map((mode) {
            final isSelected = _currentMode == mode;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => _setMode(mode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? mode.color.withValues(alpha: 0.2)
                          : AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? mode.color : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          mode.icon,
                          color: isSelected ? mode.color : AppColors.textSecondary,
                          size: 24,
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
        ),
      ],
    );
  }

  Widget _buildJammingControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.eaColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.eaColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, color: AppColors.eaColor, size: 18),
              const SizedBox(width: 8),
              Text(
                'กำลังรบกวน GPS',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.eaColor,
                ),
              ),
              const Spacer(),
              Text(
                '${(_jammingPower * 100).toInt()}%',
                style: AppTextStyles.codeMedium.copyWith(
                  color: AppColors.eaColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.eaColor,
              inactiveTrackColor: AppColors.eaColor.withValues(alpha: 0.2),
              thumbColor: AppColors.eaColor,
              trackHeight: 6,
            ),
            child: Slider(
              value: _jammingPower,
              onChanged: (value) {
                setState(() {
                  _jammingPower = value;
                });
                _applyJamming();
              },
            ),
          ),
          Text(
            'การรบกวน GPS จะทำให้เครื่องรับไม่สามารถระบุตำแหน่งได้',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildSpoofingControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wrong_location, color: AppColors.warning, size: 18),
              const SizedBox(width: 8),
              Text(
                'ระยะเบี่ยงเบนตำแหน่ง',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.warning,
                ),
              ),
              const Spacer(),
              Text(
                '${_spoofOffset.toStringAsFixed(1)} km',
                style: AppTextStyles.codeMedium.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.warning,
              inactiveTrackColor: AppColors.warning.withValues(alpha: 0.2),
              thumbColor: AppColors.warning,
              trackHeight: 6,
            ),
            child: Slider(
              value: _spoofOffset,
              min: 0,
              max: 10,
              onChanged: (value) {
                setState(() {
                  _spoofOffset = value;
                });
                _applySpoofing();
              },
            ),
          ),
          Text(
            'Spoofing ส่งสัญญาณปลอมทำให้ตำแหน่งเบี่ยงเบน โดยที่ผู้ใช้ไม่รู้ตัว',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildAntiJamToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _antiJamEnabled = !_antiJamEnabled;
        });
        if (_currentMode == GPSMode.jamming) {
          _applyJamming();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _antiJamEnabled
              ? AppColors.epColor.withValues(alpha: 0.2)
              : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _antiJamEnabled ? AppColors.epColor : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.shield,
              color: _antiJamEnabled ? AppColors.epColor : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Anti-Jam GPS',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: _antiJamEnabled ? AppColors.epColor : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'เครื่องรับป้องกันการรบกวน',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _antiJamEnabled,
              onChanged: (value) {
                setState(() {
                  _antiJamEnabled = value;
                });
                if (_currentMode == GPSMode.jamming) {
                  _applyJamming();
                }
              },
              activeColor: AppColors.epColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDisplay() {
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
          _buildStatusItem(
            'ดาวเทียม',
            '$_satellitesInView',
            Icons.satellite,
            _satellitesInView >= 4 ? AppColors.success : AppColors.error,
          ),
          _buildStatusItem(
            'สัญญาณ',
            '${(_signalStrength * 100).toInt()}%',
            Icons.signal_cellular_alt,
            _signalStrength > 0.5 ? AppColors.success : _signalStrength > 0.2 ? AppColors.warning : AppColors.error,
          ),
          _buildStatusItem(
            'ตำแหน่ง',
            _displayedPosition.dx < 0 ? 'LOST' : 'OK',
            _displayedPosition.dx < 0 ? Icons.location_off : Icons.location_on,
            _displayedPosition.dx >= 0 ? AppColors.success : AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: color,
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

/// GPS Visualization Painter
class _GPSVisualizationPainter extends CustomPainter {
  final double satelliteProgress;
  final double signalProgress;
  final double jammingProgress;
  final GPSMode mode;
  final Offset realPosition;
  final Offset displayedPosition;
  final double signalStrength;
  final int satellitesInView;
  final double jammingPower;

  _GPSVisualizationPainter({
    required this.satelliteProgress,
    required this.signalProgress,
    required this.jammingProgress,
    required this.mode,
    required this.realPosition,
    required this.displayedPosition,
    required this.signalStrength,
    required this.satellitesInView,
    required this.jammingPower,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw Earth (simple representation)
    _drawEarth(canvas, size);

    // Draw satellites
    _drawSatellites(canvas, center, math.min(size.width, size.height) / 2 - 30);

    // Draw signal lines
    _drawSignalLines(canvas, center, size);

    // Draw positions
    _drawPositions(canvas, size);

    // Draw jamming effect
    if (mode == GPSMode.jamming) {
      _drawJammingEffect(canvas, size);
    }
  }

  void _drawEarth(Canvas canvas, Size size) {
    final earthPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.accentBlue.withValues(alpha: 0.3),
          AppColors.accentBlue.withValues(alpha: 0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), earthPaint);

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    for (int i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(size.width * i / 4, 0),
        Offset(size.width * i / 4, size.height),
        gridPaint,
      );
      canvas.drawLine(
        Offset(0, size.height * i / 4),
        Offset(size.width, size.height * i / 4),
        gridPaint,
      );
    }
  }

  void _drawSatellites(Canvas canvas, Offset center, double orbitRadius) {
    final satelliteCount = 8;

    for (int i = 0; i < satelliteCount; i++) {
      final isVisible = i < satellitesInView;
      final angle = (i / satelliteCount) * 2 * math.pi + satelliteProgress * 2 * math.pi;
      final x = center.dx + math.cos(angle) * orbitRadius * 0.8;
      final y = center.dy * 0.3 + math.sin(angle) * orbitRadius * 0.3;

      // Only draw if "above" the earth horizon
      if (y < center.dy + 20) {
        final satColor = isVisible ? AppColors.radarColor : AppColors.textSecondary.withValues(alpha: 0.3);

        // Satellite body
        final satPaint = Paint()
          ..color = satColor
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(x, y), 8, satPaint);

        // Glow for visible satellites
        if (isVisible) {
          final glowPaint = Paint()
            ..color = satColor.withValues(alpha: 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
          canvas.drawCircle(Offset(x, y), 12, glowPaint);
        }
      }
    }
  }

  void _drawSignalLines(Canvas canvas, Offset center, Size size) {
    if (signalStrength < 0.1) return;

    final receiverPos = Offset(
      size.width * realPosition.dx,
      size.height * 0.7,
    );

    for (int i = 0; i < satellitesInView; i++) {
      final angle = (i / 8) * 2 * math.pi + satelliteProgress * 2 * math.pi;
      final satX = center.dx + math.cos(angle) * (size.width * 0.35);
      final satY = center.dy * 0.3 + math.sin(angle) * (size.height * 0.15);

      if (satY < center.dy + 20) {
        // Animate signal pulse
        final pulseProgress = (signalProgress + i / 8) % 1;
        final lineX = satX + (receiverPos.dx - satX) * pulseProgress;
        final lineY = satY + (receiverPos.dy - satY) * pulseProgress;

        // Signal line
        final linePaint = Paint()
          ..color = AppColors.success.withValues(alpha: 0.3 * signalStrength)
          ..strokeWidth = 1;

        canvas.drawLine(Offset(satX, satY), receiverPos, linePaint);

        // Moving pulse
        final pulsePaint = Paint()
          ..color = AppColors.success.withValues(alpha: signalStrength)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(lineX, lineY), 3, pulsePaint);
      }
    }
  }

  void _drawPositions(Canvas canvas, Size size) {
    // Real position
    final realPos = Offset(
      size.width * realPosition.dx,
      size.height * 0.7,
    );

    // GPS receiver
    final receiverPaint = Paint()
      ..color = AppColors.accentBlue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(realPos, 12, receiverPaint);

    final glowPaint = Paint()
      ..color = AppColors.accentBlue.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(realPos, 16, glowPaint);

    // Displayed/Spoofed position (if different)
    if (displayedPosition.dx >= 0 && mode == GPSMode.spoofing) {
      final spoofPos = Offset(
        size.width * displayedPosition.dx,
        size.height * (0.5 + displayedPosition.dy * 0.3),
      );

      final spoofPaint = Paint()
        ..color = AppColors.warning
        ..style = PaintingStyle.fill;

      canvas.drawCircle(spoofPos, 10, spoofPaint);

      // Line connecting real to spoofed
      final connectPaint = Paint()
        ..color = AppColors.warning.withValues(alpha: 0.5)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final path = Path()
        ..moveTo(realPos.dx, realPos.dy)
        ..lineTo(spoofPos.dx, spoofPos.dy);

      // Dashed line
      final dashPath = _createDashedPath(path, 5, 5);
      canvas.drawPath(dashPath, connectPaint);

      // Label
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'ตำแหน่งปลอม',
          style: TextStyle(
            color: AppColors.warning,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(spoofPos.dx - textPainter.width / 2, spoofPos.dy - 25));
    }

    // Label for receiver
    final textPainter = TextPainter(
      text: TextSpan(
        text: mode == GPSMode.spoofing ? 'ตำแหน่งจริง' : 'GPS Receiver',
        style: TextStyle(
          color: AppColors.accentBlue,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(realPos.dx - textPainter.width / 2, realPos.dy + 18));
  }

  Path _createDashedPath(Path source, double dashLength, double gapLength) {
    final result = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final start = distance;
        final end = math.min(distance + dashLength, metric.length);
        result.addPath(
          metric.extractPath(start, end),
          Offset.zero,
        );
        distance += dashLength + gapLength;
      }
    }
    return result;
  }

  void _drawJammingEffect(Canvas canvas, Size size) {
    final jammingPaint = Paint()
      ..color = AppColors.eaColor.withValues(alpha: jammingProgress * jammingPower * 0.3)
      ..style = PaintingStyle.fill;

    // Random jamming interference patterns
    final random = math.Random(42);
    for (int i = 0; i < (jammingPower * 20).toInt(); i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 5 + random.nextDouble() * 15;

      canvas.drawCircle(Offset(x, y), radius * jammingProgress, jammingPaint);
    }

    // Jamming source
    final jammerPos = Offset(size.width * 0.8, size.height * 0.5);
    final jammerPaint = Paint()
      ..color = AppColors.eaColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(jammerPos, 15, jammerPaint);

    // Jamming waves
    for (int i = 0; i < 3; i++) {
      final waveRadius = 30 + i * 20 + signalProgress * 30;
      final wavePaint = Paint()
        ..color = AppColors.eaColor.withValues(alpha: (1 - signalProgress) * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(jammerPos, waveRadius, wavePaint);
    }

    // Label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'JAMMER',
        style: TextStyle(
          color: AppColors.eaColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(jammerPos.dx - textPainter.width / 2, jammerPos.dy + 20));
  }

  @override
  bool shouldRepaint(covariant _GPSVisualizationPainter oldDelegate) => true;
}

/// GPS Modes
enum GPSMode {
  normal,
  jamming,
  spoofing;

  String get nameTh {
    switch (this) {
      case GPSMode.normal:
        return 'ปกติ';
      case GPSMode.jamming:
        return 'Jamming';
      case GPSMode.spoofing:
        return 'Spoofing';
    }
  }

  String get description {
    switch (this) {
      case GPSMode.normal:
        return 'การรับสัญญาณ GPS ปกติ';
      case GPSMode.jamming:
        return 'รบกวนสัญญาณ GPS ทำให้ไม่สามารถระบุตำแหน่งได้';
      case GPSMode.spoofing:
        return 'หลอกสัญญาณ GPS ทำให้ตำแหน่งเบี่ยงเบน';
    }
  }

  IconData get icon {
    switch (this) {
      case GPSMode.normal:
        return Icons.gps_fixed;
      case GPSMode.jamming:
        return Icons.gps_off;
      case GPSMode.spoofing:
        return Icons.wrong_location;
    }
  }

  Color get color {
    switch (this) {
      case GPSMode.normal:
        return AppColors.success;
      case GPSMode.jamming:
        return AppColors.eaColor;
      case GPSMode.spoofing:
        return AppColors.warning;
    }
  }
}

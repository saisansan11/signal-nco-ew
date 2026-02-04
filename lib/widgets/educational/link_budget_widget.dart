import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../app/constants.dart';

/// Link Budget Widget - คำนวณและแสดง Link Budget สำหรับการสื่อสาร
/// ช่วยให้เข้าใจว่าสัญญาณจะไปถึงปลายทางได้หรือไม่
class LinkBudgetWidget extends StatefulWidget {
  final VoidCallback? onComplete;

  const LinkBudgetWidget({super.key, this.onComplete});

  @override
  State<LinkBudgetWidget> createState() => _LinkBudgetWidgetState();
}

class _LinkBudgetWidgetState extends State<LinkBudgetWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  // Transmitter parameters
  double _txPower = 10.0; // dBW
  double _txGain = 10.0; // dBi
  double _txLoss = 2.0; // dB (cable loss)

  // Path parameters
  double _distance = 10.0; // km
  double _frequency = 2400.0; // MHz
  double _additionalLoss = 0.0; // dB (rain, obstacles, etc.)

  // Receiver parameters
  double _rxGain = 10.0; // dBi
  double _rxLoss = 2.0; // dB
  double _rxSensitivity = -90.0; // dBm

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // Calculate Free Space Path Loss (FSPL)
  double get _fspl {
    // FSPL = 20*log10(d) + 20*log10(f) + 32.44 (d in km, f in MHz)
    return 20 * (math.log(_distance) / math.ln10) +
        20 * (math.log(_frequency) / math.ln10) +
        32.44;
  }

  // Calculate EIRP (Effective Isotropic Radiated Power)
  double get _eirp {
    return _txPower + _txGain - _txLoss;
  }

  // Calculate received power
  double get _receivedPower {
    return _eirp - _fspl - _additionalLoss + _rxGain - _rxLoss;
  }

  // Calculate link margin
  double get _linkMargin {
    return _receivedPower - _rxSensitivity;
  }

  // Check if link is viable
  bool get _isLinkViable => _linkMargin > 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isLinkViable
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: (_isLinkViable ? AppColors.success : AppColors.error)
                .withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 16),

            // Link Visualization
            _buildLinkVisualization(),
            const SizedBox(height: 16),

            // Transmitter Section
            _buildSection(
              title: 'ภาคส่ง (Transmitter)',
              icon: Icons.cell_tower,
              color: AppColors.accentBlue,
              children: [
                _buildSlider(
                  label: 'กำลังส่ง',
                  value: _txPower,
                  min: 0,
                  max: 30,
                  unit: 'dBW',
                  color: AppColors.accentBlue,
                  onChanged: (v) => setState(() => _txPower = v),
                ),
                _buildSlider(
                  label: 'Antenna Gain',
                  value: _txGain,
                  min: 0,
                  max: 30,
                  unit: 'dBi',
                  color: AppColors.accentBlue,
                  onChanged: (v) => setState(() => _txGain = v),
                ),
                _buildSlider(
                  label: 'Cable Loss',
                  value: _txLoss,
                  min: 0,
                  max: 10,
                  unit: 'dB',
                  color: AppColors.warning,
                  onChanged: (v) => setState(() => _txLoss = v),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Path Section
            _buildSection(
              title: 'เส้นทางสัญญาณ (Path)',
              icon: Icons.route,
              color: AppColors.warning,
              children: [
                _buildSlider(
                  label: 'ระยะทาง',
                  value: _distance,
                  min: 0.1,
                  max: 100,
                  unit: 'km',
                  color: AppColors.warning,
                  onChanged: (v) => setState(() => _distance = v),
                ),
                _buildSlider(
                  label: 'ความถี่',
                  value: _frequency,
                  min: 100,
                  max: 10000,
                  unit: 'MHz',
                  color: AppColors.spectrumColor,
                  onChanged: (v) => setState(() => _frequency = v),
                ),
                _buildSlider(
                  label: 'Loss เพิ่มเติม',
                  value: _additionalLoss,
                  min: 0,
                  max: 30,
                  unit: 'dB',
                  color: AppColors.error,
                  onChanged: (v) => setState(() => _additionalLoss = v),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Receiver Section
            _buildSection(
              title: 'ภาครับ (Receiver)',
              icon: Icons.settings_input_antenna,
              color: AppColors.epColor,
              children: [
                _buildSlider(
                  label: 'Antenna Gain',
                  value: _rxGain,
                  min: 0,
                  max: 30,
                  unit: 'dBi',
                  color: AppColors.epColor,
                  onChanged: (v) => setState(() => _rxGain = v),
                ),
                _buildSlider(
                  label: 'Cable Loss',
                  value: _rxLoss,
                  min: 0,
                  max: 10,
                  unit: 'dB',
                  color: AppColors.warning,
                  onChanged: (v) => setState(() => _rxLoss = v),
                ),
                _buildSlider(
                  label: 'Sensitivity',
                  value: _rxSensitivity,
                  min: -120,
                  max: -50,
                  unit: 'dBm',
                  color: AppColors.epColor,
                  onChanged: (v) => setState(() => _rxSensitivity = v),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Results
            _buildResults(),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (_isLinkViable ? AppColors.success : AppColors.error)
                .withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _isLinkViable ? Icons.check_circle : Icons.error,
            color: _isLinkViable ? AppColors.success : AppColors.error,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Link Budget Calculator',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: _isLinkViable ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'คำนวณความเป็นไปได้ของการเชื่อมต่อ',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Link status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: (_isLinkViable ? AppColors.success : AppColors.error)
                .withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isLinkViable ? AppColors.success : AppColors.error,
            ),
          ),
          child: Text(
            _isLinkViable ? 'LINK OK' : 'NO LINK',
            style: AppTextStyles.labelSmall.copyWith(
              color: _isLinkViable ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkVisualization() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(double.infinity, 100),
            painter: _LinkVisualizationPainter(
              progress: _animController.value,
              isLinkViable: _isLinkViable,
              linkMargin: _linkMargin,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: color,
                inactiveTrackColor: color.withValues(alpha: 0.2),
                thumbColor: color,
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              '${value.toStringAsFixed(1)} $unit',
              style: AppTextStyles.codeMedium.copyWith(
                color: color,
                fontSize: 11,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (_isLinkViable ? AppColors.success : AppColors.error)
                .withValues(alpha: 0.1),
            AppColors.card,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (_isLinkViable ? AppColors.success : AppColors.error)
              .withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Link Budget Summary',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Budget breakdown
          _buildBudgetRow('EIRP', _eirp, 'dBW', AppColors.accentBlue, true),
          _buildBudgetRow('- FSPL', _fspl, 'dB', AppColors.warning, false),
          _buildBudgetRow(
              '- Additional Loss', _additionalLoss, 'dB', AppColors.error, false),
          _buildBudgetRow('+ Rx Gain', _rxGain, 'dBi', AppColors.epColor, true),
          _buildBudgetRow('- Rx Loss', _rxLoss, 'dB', AppColors.warning, false),

          const Divider(color: AppColors.border, height: 24),

          // Received power
          _buildBudgetRow(
            'Received Power',
            _receivedPower,
            'dBm',
            AppColors.spectrumColor,
            true,
            isBold: true,
          ),
          _buildBudgetRow(
            'Rx Sensitivity',
            _rxSensitivity,
            'dBm',
            AppColors.textSecondary,
            true,
          ),

          const SizedBox(height: 12),

          // Link margin
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (_isLinkViable ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Link Margin',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_linkMargin > 0 ? '+' : ''}${_linkMargin.toStringAsFixed(1)} dB',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: _isLinkViable ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isLinkViable
                      ? 'การเชื่อมต่อมีเสถียรภาพ'
                      : 'สัญญาณไม่แรงพอ กรุณาปรับค่า',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _isLinkViable ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetRow(
    String label,
    double value,
    String unit,
    Color color,
    bool isPositive, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${isPositive && value > 0 ? '+' : ''}${value.toStringAsFixed(1)} $unit',
              style: AppTextStyles.codeMedium.copyWith(
                color: color,
                fontSize: 12,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Link Visualization Painter
class _LinkVisualizationPainter extends CustomPainter {
  final double progress;
  final bool isLinkViable;
  final double linkMargin;

  _LinkVisualizationPainter({
    required this.progress,
    required this.isLinkViable,
    required this.linkMargin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final txCenter = Offset(40, size.height / 2);
    final rxCenter = Offset(size.width - 40, size.height / 2);

    // Draw towers
    _drawTower(canvas, txCenter, AppColors.accentBlue, 'TX');
    _drawTower(canvas, rxCenter, AppColors.epColor, 'RX');

    // Draw signal path
    final pathColor = isLinkViable ? AppColors.success : AppColors.error;
    final pathPaint = Paint()
      ..color = pathColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final dashPath = Path()
      ..moveTo(txCenter.dx + 20, txCenter.dy)
      ..lineTo(rxCenter.dx - 20, rxCenter.dy);

    canvas.drawPath(dashPath, pathPaint);

    // Draw signal packets
    if (isLinkViable) {
      for (int i = 0; i < 3; i++) {
        final packetProgress = (progress + i / 3) % 1;
        final packetX = txCenter.dx + 20 + (rxCenter.dx - txCenter.dx - 40) * packetProgress;

        final packetPaint = Paint()
          ..color = pathColor.withValues(alpha: 1 - packetProgress * 0.5)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(packetX, txCenter.dy), 5, packetPaint);

        // Glow
        final glowPaint = Paint()
          ..color = pathColor.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawCircle(Offset(packetX, txCenter.dy), 8, glowPaint);
      }
    } else {
      // Draw X mark in the middle
      final midX = (txCenter.dx + rxCenter.dx) / 2;
      final xPaint = Paint()
        ..color = AppColors.error
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(midX - 10, txCenter.dy - 10),
        Offset(midX + 10, txCenter.dy + 10),
        xPaint,
      );
      canvas.drawLine(
        Offset(midX + 10, txCenter.dy - 10),
        Offset(midX - 10, txCenter.dy + 10),
        xPaint,
      );
    }

    // Draw labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Distance label
    textPainter.text = TextSpan(
      text: '${linkMargin.toStringAsFixed(1)} dB margin',
      style: TextStyle(
        color: isLinkViable ? AppColors.success : AppColors.error,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, size.height - 20),
    );
  }

  void _drawTower(Canvas canvas, Offset center, Color color, String label) {
    // Tower body
    final towerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final towerPath = Path()
      ..moveTo(center.dx - 8, center.dy + 20)
      ..lineTo(center.dx - 2, center.dy - 15)
      ..lineTo(center.dx + 2, center.dy - 15)
      ..lineTo(center.dx + 8, center.dy + 20)
      ..close();

    canvas.drawPath(towerPath, towerPaint);

    // Antenna
    canvas.drawCircle(Offset(center.dx, center.dy - 20), 6, towerPaint);

    // Glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(center.dx, center.dy - 20), 10, glowPaint);

    // Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy + 25),
    );
  }

  @override
  bool shouldRepaint(covariant _LinkVisualizationPainter oldDelegate) => true;
}

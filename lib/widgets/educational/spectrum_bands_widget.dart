import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/constants.dart';

/// Widget แสดงย่านความถี่สเปกตรัมพร้อมอนิเมชั่นคลื่น
class SpectrumBandsWidget extends StatefulWidget {
  const SpectrumBandsWidget({super.key});

  @override
  State<SpectrumBandsWidget> createState() => _SpectrumBandsWidgetState();
}

class _SpectrumBandsWidgetState extends State<SpectrumBandsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _selectedBand = -1;

  final List<_FrequencyBand> _bands = [
    _FrequencyBand(
      name: 'HF',
      fullName: 'High Frequency',
      range: '3-30 MHz',
      color: Colors.purple,
      wavelength: 40.0,
      amplitude: 20.0,
      uses: ['สื่อสารระยะไกล', 'สะท้อนชั้นบรรยากาศ', 'ข้ามทวีปได้'],
      militaryUse: 'สื่อสารกับหน่วยที่อยู่ไกล',
    ),
    _FrequencyBand(
      name: 'VHF',
      fullName: 'Very High Frequency',
      range: '30-300 MHz',
      color: Colors.blue,
      wavelength: 25.0,
      amplitude: 18.0,
      uses: ['วิทยุยุทธวิธี', 'Line-of-Sight', 'คุณภาพดี'],
      militaryUse: 'สื่อสารระหว่างหน่วยใกล้',
    ),
    _FrequencyBand(
      name: 'UHF',
      fullName: 'Ultra High Frequency',
      range: '300 MHz - 3 GHz',
      color: Colors.teal,
      wavelength: 15.0,
      amplitude: 15.0,
      uses: ['Data Link', 'ดาวเทียม', 'อากาศยาน'],
      militaryUse: 'สื่อสารกับอากาศยาน',
    ),
    _FrequencyBand(
      name: 'SHF',
      fullName: 'Super High Frequency',
      range: '3-30 GHz',
      color: Colors.cyan,
      wavelength: 8.0,
      amplitude: 12.0,
      uses: ['เรดาร์', 'ไมโครเวฟ', 'ดาวเทียม'],
      militaryUse: 'ระบบเรดาร์',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // แถบความถี่
          SizedBox(
            height: 80,
            child: Row(
              children: _bands.asMap().entries.map((entry) {
                final index = entry.key;
                final band = entry.value;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedBand = _selectedBand == index ? -1 : index;
                      });
                    },
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                band.color.withValues(alpha: 0.3),
                                band.color.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: _selectedBand == index
                                ? Border.all(color: band.color, width: 2)
                                : null,
                          ),
                          child: Stack(
                            children: [
                              // คลื่นอนิเมชั่น
                              CustomPaint(
                                size: const Size(double.infinity, 80),
                                painter: _WavePainter(
                                  progress: _controller.value,
                                  color: band.color,
                                  wavelength: band.wavelength,
                                  amplitude: band.amplitude,
                                ),
                              ),
                              // ชื่อย่าน
                              Center(
                                child: Text(
                                  band.name,
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ).animate(delay: Duration(milliseconds: index * 100))
                      .fadeIn()
                      .slideX(begin: 0.1),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // แถบแสดงช่วงความถี่
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '3 MHz',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'ความถี่ต่ำ ← → ความถี่สูง',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '30 GHz',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          // รายละเอียดเมื่อเลือก
          if (_selectedBand >= 0) ...[
            const SizedBox(height: 16),
            _buildBandDetail(_bands[_selectedBand]),
          ],
        ],
      ),
    );
  }

  Widget _buildBandDetail(_FrequencyBand band) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: band.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: band.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: band.color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  band.name,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                band.fullName,
                style: AppTextStyles.labelMedium.copyWith(
                  color: band.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'ความถี่: ${band.range}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'คุณสมบัติ:',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          ...band.uses.map((use) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child: Row(
                  children: [
                    Icon(Icons.check, color: band.color, size: 14),
                    const SizedBox(width: 4),
                    Text(use, style: AppTextStyles.bodySmall),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: band.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.military_tech, color: band.color, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'การใช้ทางทหาร: ${band.militaryUse}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: band.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}

class _FrequencyBand {
  final String name;
  final String fullName;
  final String range;
  final Color color;
  final double wavelength;
  final double amplitude;
  final List<String> uses;
  final String militaryUse;

  _FrequencyBand({
    required this.name,
    required this.fullName,
    required this.range,
    required this.color,
    required this.wavelength,
    required this.amplitude,
    required this.uses,
    required this.militaryUse,
  });
}

/// Custom Painter สำหรับคลื่น
class _WavePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double wavelength;
  final double amplitude;

  _WavePainter({
    required this.progress,
    required this.color,
    required this.wavelength,
    required this.amplitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    final centerY = size.height / 2;

    path.moveTo(0, centerY);

    for (double x = 0; x <= size.width; x++) {
      final y = centerY +
          amplitude *
              _sin((x / wavelength + progress * 2) * 3.14159 * 2);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  double _sin(double x) {
    // Simple sine approximation
    x = x % (2 * 3.14159);
    if (x > 3.14159) x -= 2 * 3.14159;
    return x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

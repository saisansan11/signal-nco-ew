import 'package:flutter/material.dart';
import '../../app/constants.dart';

/// Widget แสดง FHSS (Frequency Hopping) พร้อมอนิเมชั่น
class FHSSWidget extends StatefulWidget {
  const FHSSWidget({super.key});

  @override
  State<FHSSWidget> createState() => _FHSSWidgetState();
}

class _FHSSWidgetState extends State<FHSSWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<int> _hopPattern = [2, 5, 1, 4, 0, 3, 6, 2, 4, 1]; // ลำดับการกระโดด
  bool _isHopping = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
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
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FHSS - การกระโดดความถี่',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.epColor,
                ),
              ),
              // Toggle button
              GestureDetector(
                onTap: () {
                  setState(() => _isHopping = !_isHopping);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isHopping
                        ? AppColors.epColor.withValues(alpha: 0.2)
                        : AppColors.eaColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isHopping ? AppColors.epColor : AppColors.eaColor,
                    ),
                  ),
                  child: Text(
                    _isHopping ? 'FHSS เปิด' : 'FHSS ปิด',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: _isHopping ? AppColors.epColor : AppColors.eaColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Frequency display
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 120),
                  painter: _FHSSPainter(
                    progress: _controller.value,
                    hopPattern: _hopPattern,
                    isHopping: _isHopping,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Frequency labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              return Text(
                'F${i + 1}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          // Comparison
          Row(
            children: [
              Expanded(
                child: _buildComparison(
                  'ไม่มี FHSS',
                  'อยู่ความถี่เดียว\nถูกรบกวนง่าย',
                  AppColors.eaColor,
                  Icons.gps_fixed,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildComparison(
                  'มี FHSS',
                  'กระโดดความถี่\nหนีการรบกวน',
                  AppColors.epColor,
                  Icons.shuffle,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Status
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (_isHopping ? AppColors.epColor : AppColors.eaColor)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _isHopping ? Icons.check_circle : Icons.warning,
                  color: _isHopping ? AppColors.epColor : AppColors.eaColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isHopping
                        ? 'สัญญาณกระโดดความถี่ หลีกเลี่ยงการรบกวนได้'
                        : 'สัญญาณอยู่ที่เดิม ถูกรบกวนได้ง่าย',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _isHopping ? AppColors.epColor : AppColors.eaColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparison(String title, String desc, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(color: color),
          ),
          Text(
            desc,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Custom Painter สำหรับ FHSS
class _FHSSPainter extends CustomPainter {
  final double progress;
  final List<int> hopPattern;
  final bool isHopping;

  _FHSSPainter({
    required this.progress,
    required this.hopPattern,
    required this.isHopping,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // วาดกริดความถี่
    final gridPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    for (int i = 0; i < 7; i++) {
      final y = size.height * (i + 0.5) / 7;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

      // Label
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'F${7 - i}',
          style: TextStyle(color: Colors.green.withValues(alpha: 0.5), fontSize: 8),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(2, y - 5));
    }

    // วาดสัญญาณรบกวน (จำลอง)
    final jamPaint = Paint()
      ..color = AppColors.eaColor.withValues(alpha: 0.3)
      ..strokeWidth = 2;

    final jamY = size.height * 3.5 / 7; // รบกวนที่ F4
    canvas.drawLine(
      Offset(0, jamY),
      Offset(size.width, jamY),
      jamPaint,
    );

    // Label การรบกวน
    final jamTextPainter = TextPainter(
      text: const TextSpan(
        text: '← การรบกวน',
        style: TextStyle(color: AppColors.eaColor, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    jamTextPainter.layout();
    jamTextPainter.paint(canvas, Offset(size.width - 70, jamY - 12));

    // วาดสัญญาณ
    final signalPaint = Paint()
      ..color = AppColors.epColor
      ..strokeWidth = 4
      ..style = PaintingStyle.fill;

    if (isHopping) {
      // FHSS mode - กระโดดความถี่
      final hopIndex = (progress * hopPattern.length).floor() % hopPattern.length;
      final currentFreq = hopPattern[hopIndex];
      final signalY = size.height * (6 - currentFreq + 0.5) / 7;

      // วาดเส้นทางการกระโดด
      final trailPaint = Paint()
        ..color = AppColors.epColor.withValues(alpha: 0.3)
        ..strokeWidth = 2;

      for (int i = 0; i < hopIndex; i++) {
        final freq = hopPattern[i];
        final y = size.height * (6 - freq + 0.5) / 7;
        final x = size.width * (i + 0.5) / hopPattern.length;
        canvas.drawCircle(Offset(x, y), 3, trailPaint);
      }

      // สัญญาณปัจจุบัน
      canvas.drawCircle(
        Offset(size.width * (hopIndex + 0.5) / hopPattern.length, signalY),
        8,
        signalPaint,
      );

      // ลูกศรแสดงทิศทาง
      if (hopIndex < hopPattern.length - 1) {
        final nextFreq = hopPattern[hopIndex + 1];
        final nextY = size.height * (6 - nextFreq + 0.5) / 7;
        final arrowPaint = Paint()
          ..color = AppColors.epColor.withValues(alpha: 0.5)
          ..strokeWidth = 1;
        canvas.drawLine(
          Offset(size.width * (hopIndex + 0.5) / hopPattern.length, signalY),
          Offset(size.width * (hopIndex + 1.5) / hopPattern.length, nextY),
          arrowPaint,
        );
      }
    } else {
      // Fixed frequency mode - อยู่ที่เดิม
      final fixedY = size.height * 3.5 / 7; // ตรงกับการรบกวน!
      canvas.drawCircle(
        Offset(size.width / 2, fixedY),
        8,
        signalPaint,
      );

      // แสดงว่าถูกรบกวน
      final blockedPaint = Paint()
        ..color = AppColors.eaColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(
        Offset(size.width / 2, fixedY),
        15,
        blockedPaint,
      );
      canvas.drawLine(
        Offset(size.width / 2 - 10, fixedY - 10),
        Offset(size.width / 2 + 10, fixedY + 10),
        blockedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FHSSPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isHopping != isHopping;
  }
}

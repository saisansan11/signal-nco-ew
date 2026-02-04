import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../app/constants.dart';

/// Widget แสดงประเภทการรบกวนพร้อมอนิเมชั่น
class JammingTypesWidget extends StatefulWidget {
  const JammingTypesWidget({super.key});

  @override
  State<JammingTypesWidget> createState() => _JammingTypesWidgetState();
}

class _JammingTypesWidgetState extends State<JammingTypesWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _selectedType = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
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
          // Spectrum display
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 100),
                  painter: _JammingPainter(
                    type: _selectedType,
                    progress: _controller.value,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // แถบความถี่
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('100 MHz', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              Text('สัญญาณข้าศึก', style: AppTextStyles.bodySmall.copyWith(color: Colors.cyan)),
              Text('200 MHz', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),

          // ปุ่มเลือกประเภท
          Row(
            children: [
              _buildTypeButton(0, 'Spot', 'รบกวนจุด'),
              const SizedBox(width: 8),
              _buildTypeButton(1, 'Barrage', 'รบกวนกว้าง'),
              const SizedBox(width: 8),
              _buildTypeButton(2, 'Sweep', 'รบกวนกวาด'),
            ],
          ),
          const SizedBox(height: 16),

          // คำอธิบาย
          _buildDescription(),
        ],
      ),
    );
  }

  Widget _buildTypeButton(int index, String title, String subtitle) {
    final isSelected = _selectedType == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedType = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.eaColor.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.eaColor : AppColors.textSecondary.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(
                  color: isSelected ? AppColors.eaColor : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    final descriptions = [
      {
        'title': 'Spot Jamming (รบกวนจุด)',
        'desc': 'รบกวนความถี่เดียวหรือช่วงแคบ',
        'pros': ['ใช้กำลังน้อย', 'มีประสิทธิภาพสูง'],
        'cons': ['ต้องรู้ความถี่', 'รบกวนได้ทีละเป้า'],
        'icon': Icons.gps_fixed,
      },
      {
        'title': 'Barrage Jamming (รบกวนกว้าง)',
        'desc': 'รบกวนช่วงความถี่กว้างพร้อมกัน',
        'pros': ['ไม่ต้องรู้ความถี่แน่นอน', 'รบกวนได้หลายเป้า'],
        'cons': ['ใช้กำลังมาก', 'ประสิทธิภาพต่อเป้าน้อย'],
        'icon': Icons.waves,
      },
      {
        'title': 'Sweep Jamming (รบกวนกวาด)',
        'desc': 'เลื่อนความถี่รบกวนไปมา',
        'pros': ['ใช้กำลังปานกลาง', 'ครอบคลุมหลายความถี่'],
        'cons': ['มีช่วงว่างระหว่างกวาด', 'ประสิทธิภาพปานกลาง'],
        'icon': Icons.swap_horiz,
      },
    ];

    final desc = descriptions[_selectedType];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.eaColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(desc['icon'] as IconData, color: AppColors.eaColor, size: 20),
              const SizedBox(width: 8),
              Text(
                desc['title'] as String,
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.eaColor),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            desc['desc'] as String,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✓ ข้อดี',
                      style: AppTextStyles.labelSmall.copyWith(color: Colors.green),
                    ),
                    ...(desc['pros'] as List<String>).map((p) => Text(
                          '  • $p',
                          style: AppTextStyles.bodySmall,
                        )),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✗ ข้อเสีย',
                      style: AppTextStyles.labelSmall.copyWith(color: Colors.orange),
                    ),
                    ...(desc['cons'] as List<String>).map((c) => Text(
                          '  • $c',
                          style: AppTextStyles.bodySmall,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}

/// Custom Painter สำหรับแสดงการรบกวน
class _JammingPainter extends CustomPainter {
  final int type;
  final double progress;

  _JammingPainter({required this.type, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // วาดกริด
    final gridPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    for (int i = 0; i < 5; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // สัญญาณข้าศึก (เป้าหมาย)
    final targetPaint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final targetX = size.width * 0.5;
    final path = Path();
    path.moveTo(targetX - 5, size.height * 0.9);
    path.lineTo(targetX, size.height * 0.2);
    path.lineTo(targetX + 5, size.height * 0.9);
    canvas.drawPath(path, targetPaint);

    // สัญญาณรบกวน
    final jamPaint = Paint()
      ..color = AppColors.eaColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    switch (type) {
      case 0: // Spot
        _drawSpotJamming(canvas, size, jamPaint, targetX);
        break;
      case 1: // Barrage
        _drawBarrageJamming(canvas, size, jamPaint);
        break;
      case 2: // Sweep
        _drawSweepJamming(canvas, size, jamPaint);
        break;
    }

    // Label
    final labels = ['Spot', 'Barrage', 'Sweep'];
    final textPainter = TextPainter(
      text: TextSpan(
        text: labels[type],
        style: const TextStyle(color: AppColors.eaColor, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(10, 10));
  }

  void _drawSpotJamming(Canvas canvas, Size size, Paint paint, double targetX) {
    // รบกวนที่ความถี่เดียว (ตรงเป้า)
    final jamHeight = size.height * 0.3 + (size.height * 0.2 * _sin(progress * 2 * 3.14159));

    final path = Path();
    path.moveTo(targetX - 8, size.height * 0.9);
    path.lineTo(targetX, size.height * 0.9 - jamHeight);
    path.lineTo(targetX + 8, size.height * 0.9);
    canvas.drawPath(path, paint);
  }

  void _drawBarrageJamming(Canvas canvas, Size size, Paint paint) {
    // รบกวนช่วงกว้าง
    final jamPath = Path();
    jamPath.moveTo(size.width * 0.2, size.height * 0.9);

    for (double x = size.width * 0.2; x <= size.width * 0.8; x += 2) {
      final noise = 0.3 + 0.2 * _sin((x + progress * size.width) * 0.1);
      final y = size.height * (0.9 - noise * _sin(x * 0.2 + progress * 20));
      jamPath.lineTo(x, y);
    }

    canvas.drawPath(jamPath, paint);
  }

  void _drawSweepJamming(Canvas canvas, Size size, Paint paint) {
    // รบกวนแบบกวาด
    final sweepX = size.width * 0.2 + (size.width * 0.6) * progress;

    final path = Path();
    path.moveTo(sweepX - 10, size.height * 0.9);
    path.lineTo(sweepX, size.height * 0.2);
    path.lineTo(sweepX + 10, size.height * 0.9);
    canvas.drawPath(path, paint);

    // Trail
    final trailPaint = Paint()
      ..color = AppColors.eaColor.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 1; i <= 3; i++) {
      final trailX = sweepX - i * 20;
      if (trailX > size.width * 0.2) {
        final trailPath = Path();
        trailPath.moveTo(trailX - 5, size.height * 0.9);
        trailPath.lineTo(trailX, size.height * 0.5);
        trailPath.lineTo(trailX + 5, size.height * 0.9);
        canvas.drawPath(trailPath, trailPaint);
      }
    }
  }

  double _sin(double x) {
    x = x % (2 * math.pi);
    return math.sin(x);
  }

  @override
  bool shouldRepaint(covariant _JammingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.type != type;
  }
}

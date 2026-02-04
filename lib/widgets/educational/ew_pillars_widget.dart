import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../app/constants.dart';

/// Widget แสดง 3 เสาหลักของ EW พร้อมอนิเมชั่น
class EWPillarsWidget extends StatefulWidget {
  const EWPillarsWidget({super.key});

  @override
  State<EWPillarsWidget> createState() => _EWPillarsWidgetState();
}

class _EWPillarsWidgetState extends State<EWPillarsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _selectedPillar = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
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
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // วงกลมกลางแสดง EW
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(200, 200),
                painter: _EWCyclePainter(
                  progress: _controller.value,
                  selectedPillar: _selectedPillar,
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // 3 เสาหลัก
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPillar(
                index: 0,
                title: 'ESM',
                subtitle: 'สนับสนุน',
                color: AppColors.esColor,
                icon: Icons.hearing,
                description: 'ค้นหา ดักรับ ระบุ',
              ),
              _buildPillar(
                index: 1,
                title: 'ECM',
                subtitle: 'ตอบโต้',
                color: AppColors.eaColor,
                icon: Icons.flash_on,
                description: 'รบกวน หลอกลวง',
              ),
              _buildPillar(
                index: 2,
                title: 'ECCM',
                subtitle: 'ต่อต้าน',
                color: AppColors.epColor,
                icon: Icons.shield,
                description: 'ป้องกันการรบกวน',
              ),
            ],
          ),

          // รายละเอียดเมื่อเลือก
          if (_selectedPillar >= 0) ...[
            const SizedBox(height: 16),
            _buildSelectedDetail(),
          ],
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildPillar({
    required int index,
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required String description,
  }) {
    final isSelected = _selectedPillar == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPillar = _selectedPillar == index ? -1 : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                  duration: Duration(milliseconds: 1000 + (index * 200)),
                ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.headlineSmall.copyWith(
                color: color,
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
    ).animate(delay: Duration(milliseconds: index * 100)).fadeIn().slideY(
          begin: 0.2,
        );
  }

  Widget _buildSelectedDetail() {
    final details = [
      {
        'title': 'ESM - Electronic Support Measures',
        'color': AppColors.esColor,
        'tasks': ['ค้นหาสัญญาณ', 'ดักรับข่าวสาร', 'ระบุประเภท', 'หาตำแหน่ง'],
        'output': 'สร้าง EOB ข้าศึก'
      },
      {
        'title': 'ECM - Electronic Countermeasures',
        'color': AppColors.eaColor,
        'tasks': ['Jamming', 'Spoofing', 'CHAFF/FLARE', 'Deception'],
        'output': 'ทำลายความสามารถข้าศึก'
      },
      {
        'title': 'ECCM - Electronic Counter-Countermeasures',
        'color': AppColors.epColor,
        'tasks': ['Frequency Hopping', 'FHSS', 'EMCON', 'COMSEC'],
        'output': 'ปกป้องระบบของเรา'
      },
    ];

    final detail = details[_selectedPillar];
    final color = detail['color'] as Color;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail['title'] as String,
            style: AppTextStyles.labelLarge.copyWith(color: color),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: (detail['tasks'] as List<String>).map((task) {
              return Chip(
                label: Text(task, style: AppTextStyles.bodySmall),
                backgroundColor: color.withValues(alpha: 0.2),
                side: BorderSide.none,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.arrow_forward, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                detail['output'] as String,
                style: AppTextStyles.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}

/// Custom Painter สำหรับวงจร EW
class _EWCyclePainter extends CustomPainter {
  final double progress;
  final int selectedPillar;

  _EWCyclePainter({required this.progress, required this.selectedPillar});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // วงกลมพื้นหลัง
    final bgPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // วงกลมขอบ
    final borderPaint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);

    // วาดลูกศรวงกลมแสดงวงจร
    final colors = [AppColors.esColor, AppColors.eaColor, AppColors.epColor];
    final labels = ['ESM', 'ECM', 'ECCM'];

    for (int i = 0; i < 3; i++) {
      final angle = (i * 2 * math.pi / 3) - math.pi / 2 + (progress * 2 * math.pi);
      final x = center.dx + radius * 0.6 * math.cos(angle);
      final y = center.dy + radius * 0.6 * math.sin(angle);

      // วงกลมสำหรับแต่ละเสา
      final pillarPaint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      final pillarRadius = selectedPillar == i ? 25.0 : 20.0;
      canvas.drawCircle(Offset(x, y), pillarRadius, pillarPaint);

      // ข้อความ
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );

      // ลูกศรไปยังเสาถัดไป
      final nextAngle = ((i + 1) % 3 * 2 * math.pi / 3) - math.pi / 2 + (progress * 2 * math.pi);
      final nextX = center.dx + radius * 0.6 * math.cos(nextAngle);
      final nextY = center.dy + radius * 0.6 * math.sin(nextAngle);

      final arrowPaint = Paint()
        ..color = colors[i].withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      // วาดเส้นโค้ง
      final path = Path();
      path.moveTo(x + 15 * math.cos(angle + math.pi / 6), y + 15 * math.sin(angle + math.pi / 6));
      path.arcToPoint(
        Offset(nextX - 15 * math.cos(nextAngle - math.pi / 6), nextY - 15 * math.sin(nextAngle - math.pi / 6)),
        radius: Radius.circular(radius * 0.4),
        clockwise: true,
      );
      canvas.drawPath(path, arrowPaint);
    }

    // EW ตรงกลาง
    final centerTextPainter = TextPainter(
      text: const TextSpan(
        text: 'EW',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    centerTextPainter.layout();
    centerTextPainter.paint(
      canvas,
      Offset(center.dx - centerTextPainter.width / 2, center.dy - centerTextPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _EWCyclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedPillar != selectedPillar;
  }
}

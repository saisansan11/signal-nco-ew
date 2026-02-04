import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/constants.dart';

/// Widget แสดงกรณีศึกษายุทธที่เทนเนนเบิร์ก 1914
/// แสดงแผนที่ภูมิศาสตร์ การเคลื่อนกำลัง และจุดดักรับวิทยุ
class TannenbergCaseWidget extends StatefulWidget {
  const TannenbergCaseWidget({super.key});

  @override
  State<TannenbergCaseWidget> createState() => _TannenbergCaseWidgetState();
}

class _TannenbergCaseWidgetState extends State<TannenbergCaseWidget>
    with TickerProviderStateMixin {
  late AnimationController _radioWaveController;
  late AnimationController _armyMovementController;
  int _currentPhase = 0;

  final List<BattlePhase> _phases = [
    BattlePhase(
      title: 'สถานการณ์เริ่มต้น',
      description: 'กองทัพรัสเซีย 2 กองทัพเตรียมโจมตี',
      icon: Icons.flag,
    ),
    BattlePhase(
      title: 'ส่งคำสั่งทางวิทยุ',
      description: 'รัสเซียส่งคำสั่งโดยไม่เข้ารหัส',
      icon: Icons.radio,
    ),
    BattlePhase(
      title: 'เยอรมันดักรับ',
      description: 'ได้ข้อมูลแผนการทั้งหมด',
      icon: Icons.hearing,
    ),
    BattlePhase(
      title: 'ตอบโต้',
      description: 'เยอรมันวางกำลังตั้งรับ',
      icon: Icons.shield,
    ),
    BattlePhase(
      title: 'ผลลัพธ์',
      description: 'ชัยชนะเด็ดขาดของเยอรมัน',
      icon: Icons.emoji_events,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _radioWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _armyMovementController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _radioWaveController.dispose();
    _armyMovementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: AppColors.esColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: AppSizes.paddingM),

          // Battle Map
          _buildBattleMap(),
          const SizedBox(height: AppSizes.paddingM),

          // Phase Timeline
          _buildPhaseTimeline(),
          const SizedBox(height: AppSizes.paddingM),

          // Phase Details
          _buildPhaseDetails(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.esColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: const Icon(
            Icons.history_edu,
            color: AppColors.esColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ยุทธที่เทนเนนเบิร์ก',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '20-27 สิงหาคม 1914 • สงครามโลกครั้งที่ 1',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBattleMap() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          // Background grid
          CustomPaint(
            size: const Size(double.infinity, 200),
            painter: _MapGridPainter(),
          ),

          // German position (center)
          Positioned(
            left: 140,
            top: 80,
            child: _buildArmyMarker(
              label: 'เยอรมัน',
              color: Colors.grey[700]!,
              icon: Icons.shield,
            ),
          ),

          // Russian Army 1 (north)
          AnimatedBuilder(
            animation: _armyMovementController,
            builder: (context, child) {
              return Positioned(
                left: 220 + (_armyMovementController.value * 20),
                top: 20,
                child: _buildArmyMarker(
                  label: 'กองทัพที่ 1',
                  color: Colors.red[700]!,
                  icon: Icons.arrow_forward,
                ),
              );
            },
          ),

          // Russian Army 2 (south)
          AnimatedBuilder(
            animation: _armyMovementController,
            builder: (context, child) {
              return Positioned(
                left: 40 + (_armyMovementController.value * 30),
                top: 140,
                child: _buildArmyMarker(
                  label: 'กองทัพที่ 2',
                  color: Colors.red[700]!,
                  icon: Icons.arrow_forward,
                ),
              );
            },
          ),

          // Radio interception point
          if (_currentPhase >= 1)
            Positioned(
              left: 100,
              top: 60,
              child: _buildRadioWaves(),
            ),

          // Labels
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.card.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'แนวรบตะวันออก',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArmyMarker({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    ).animate().fadeIn().scale();
  }

  Widget _buildRadioWaves() {
    return AnimatedBuilder(
      animation: _radioWaveController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.33;
            final progress = (_radioWaveController.value + delay) % 1.0;
            return Container(
              width: 40 + (progress * 60),
              height: 40 + (progress * 60),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.esColor.withValues(alpha: 1 - progress),
                  width: 2,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildPhaseTimeline() {
    return SizedBox(
      height: 70, // เพิ่มจาก 60 เป็น 70 เพื่อป้องกัน overflow
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _phases.length,
        itemBuilder: (context, index) {
          final isActive = index == _currentPhase;
          final isPast = index < _currentPhase;

          return GestureDetector(
            onTap: () => setState(() => _currentPhase = index),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min, // ป้องกัน overflow
                children: [
                  Container(
                    width: 36, // ลดขนาดเล็กลงเพื่อประหยัดพื้นที่
                    height: 36,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.esColor
                          : isPast
                              ? AppColors.esColor.withValues(alpha: 0.3)
                              : AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive || isPast
                            ? AppColors.esColor
                            : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _phases[index].icon,
                      color: isActive
                          ? Colors.white
                          : isPast
                              ? AppColors.esColor
                              : AppColors.textMuted,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      '${index + 1}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isActive
                            ? AppColors.esColor
                            : AppColors.textMuted,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ).animate(delay: Duration(milliseconds: 100 * index))
                .fadeIn()
                .slideX(begin: 0.2, end: 0),
          );
        },
      ),
    );
  }

  Widget _buildPhaseDetails() {
    final phase = _phases[_currentPhase];

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.esColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: AppColors.esColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(phase.icon, color: AppColors.esColor, size: 20),
              const SizedBox(width: 8),
              Text(
                phase.title,
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.esColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            phase.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getPhaseDetail(_currentPhase),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    ).animate(key: ValueKey(_currentPhase))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0);
  }

  String _getPhaseDetail(int phase) {
    switch (phase) {
      case 0:
        return 'กองทัพรัสเซียที่ 1 อยู่ทางเหนือ กองทัพที่ 2 อยู่ทางใต้ วางแผนโจมตีสองทาง';
      case 1:
        return 'คำสั่ง: "กองทัพที่ 1 ตรึงกำลัง กองทัพที่ 2 รุกยึดเทนเนนเบิร์ก" - ส่งโดยไม่เข้ารหัส!';
      case 2:
        return 'พนักงานวิทยุเยอรมันดักรับคำสั่งได้ทั้งหมด รายงานผู้บังคับบัญชาทันที';
      case 3:
        return 'เยอรมันใช้กองพลม้าลวงกองทัพที่ 1 แล้วเคลื่อนกำลังหลักสกัดกองทัพที่ 2';
      case 4:
        return 'กองทัพรัสเซียที่ 2 ถูกโจมตีขนาบ สูญเสียหนัก - นี่คือจุดกำเนิด SIGINT';
      default:
        return '';
    }
  }
}

class BattlePhase {
  final String title;
  final String description;
  final IconData icon;

  const BattlePhase({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    // Draw grid
    for (var i = 0; i < size.width; i += 20) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }
    for (var i = 0; i < size.height; i += 20) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }

    // Draw border line (simulating front line)
    final frontPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.3,
        size.width,
        size.height * 0.5,
      );

    canvas.drawPath(path, frontPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Widget แสดงบทเรียนที่ได้จากกรณีศึกษา
class TannenbergLessonsWidget extends StatelessWidget {
  const TannenbergLessonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final lessons = [
      _LessonItem(
        icon: Icons.cancel,
        iconColor: Colors.red,
        text: 'การส่งข่าวโดยไม่เข้ารหัสเป็นอันตรายร้ายแรง',
      ),
      _LessonItem(
        icon: Icons.check_circle,
        iconColor: Colors.green,
        text: 'การดักรับวิทยุสามารถเปลี่ยนผลการรบได้',
      ),
      _LessonItem(
        icon: Icons.radio,
        iconColor: AppColors.esColor,
        text: 'นี่คือจุดเริ่มต้นของ SIGINT (Signal Intelligence)',
      ),
      _LessonItem(
        icon: Icons.lock,
        iconColor: Colors.blue,
        text: 'ความปลอดภัยทางการสื่อสารมีความสำคัญสูงสุด',
      ),
      _LessonItem(
        icon: Icons.flash_on,
        iconColor: Colors.orange,
        text: 'ข้อมูลที่ได้ทันเวลาชี้ขาดชัยชนะ',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb,
                color: AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'บทเรียนที่ได้',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          ...lessons.asMap().entries.map((entry) {
            final index = entry.key;
            final lesson = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    lesson.icon,
                    color: lesson.iconColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lesson.text,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate(delay: Duration(milliseconds: 150 * index))
                .fadeIn()
                .slideX(begin: 0.2, end: 0);
          }),
        ],
      ),
    );
  }
}

class _LessonItem {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _LessonItem({
    required this.icon,
    required this.iconColor,
    required this.text,
  });
}

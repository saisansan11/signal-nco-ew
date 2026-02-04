import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/constants.dart';

/// Widget แสดงกรณีศึกษาการโจมตีเพิร์ล ฮาร์เบอร์ 1941
/// แสดงแผนการลวง, Radio Silence และผลกระทบต่อ SIGINT
class PearlHarborCaseWidget extends StatefulWidget {
  const PearlHarborCaseWidget({super.key});

  @override
  State<PearlHarborCaseWidget> createState() => _PearlHarborCaseWidgetState();
}

class _PearlHarborCaseWidgetState extends State<PearlHarborCaseWidget>
    with TickerProviderStateMixin {
  late AnimationController _fleetController;
  late AnimationController _radioController;
  int _currentPhase = 0;
  bool _radioSilenceActive = false;

  final List<AttackPhase> _phases = [
    AttackPhase(
      title: 'การเตรียมการ',
      date: '3-7 พ.ย. 2484',
      description: 'กองเรือ 4 กอง เคลื่อนไหว',
      icon: Icons.directions_boat,
    ),
    AttackPhase(
      title: 'ปล่อยข่าวลวง',
      date: '1 ธ.ค. 2484',
      description: 'ประกาศยุติการประลองยุทธ',
      icon: Icons.campaign,
    ),
    AttackPhase(
      title: 'Radio Silence',
      date: '2 ธ.ค. 2484',
      description: 'ระงับวิทยุสนิท',
      icon: Icons.signal_wifi_off,
    ),
    AttackPhase(
      title: 'โจมตี',
      date: '7 ธ.ค. 2484',
      description: 'ความสำเร็จ 100%',
      icon: Icons.warning_amber,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fleetController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _radioController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _fleetController.dispose();
    _radioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Update radio silence state based on phase
    _radioSilenceActive = _currentPhase >= 2;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: AppSizes.paddingM),

          // Pacific Map
          _buildPacificMap(),
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
            color: Colors.red.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: const Icon(
            Icons.military_tech,
            color: Colors.red,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'การโจมตีเพิร์ล ฮาร์เบอร์',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '7 ธันวาคม 2484 • สงครามโลกครั้งที่ 2',
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

  Widget _buildPacificMap() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF1a3a5c), // Ocean blue
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          // Water wave effect
          CustomPaint(
            size: const Size(double.infinity, 180),
            painter: _WavePainter(),
          ),

          // Japan label
          Positioned(
            left: 30,
            top: 40,
            child: _buildLocationMarker('🇯🇵 ญี่ปุ่น', Colors.red[300]!),
          ),

          // Pearl Harbor label
          Positioned(
            right: 30,
            top: 60,
            child: _buildLocationMarker('🇺🇸 เพิร์ล ฮาร์เบอร์', Colors.blue[300]!),
          ),

          // Fleet movements (animated)
          if (_currentPhase == 0) ..._buildFleetMovements(),

          // Attack line (when phase is 3)
          if (_currentPhase == 3)
            Positioned(
              left: 60,
              right: 60,
              top: 80,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red,
                      Colors.red.withValues(alpha: 0.5),
                      Colors.orange,
                    ],
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.3)),
            ),

          // Radio Silence indicator
          if (_radioSilenceActive)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.signal_wifi_off, color: Colors.red, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'RADIO SILENCE',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeIn(duration: 800.ms)
                    .fadeOut(duration: 800.ms, delay: 800.ms),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildFleetMovements() {
    return [
      // Fleet 1 - Taiwan
      AnimatedBuilder(
        animation: _fleetController,
        builder: (context, child) {
          return Positioned(
            left: 50 + (_fleetController.value * 20),
            top: 50,
            child: _buildFleetIcon('1'),
          );
        },
      ),
      // Fleet 2 - China Sea
      AnimatedBuilder(
        animation: _fleetController,
        builder: (context, child) {
          return Positioned(
            left: 70,
            top: 30 + (_fleetController.value * 15),
            child: _buildFleetIcon('2'),
          );
        },
      ),
      // Fleet 3 - Kyushu
      AnimatedBuilder(
        animation: _fleetController,
        builder: (context, child) {
          return Positioned(
            left: 40 + (_fleetController.value * 30),
            top: 70 + (_fleetController.value * 10),
            child: _buildFleetIcon('3'),
          );
        },
      ),
      // Fleet 4 - Honshu
      AnimatedBuilder(
        animation: _fleetController,
        builder: (context, child) {
          return Positioned(
            left: 60 + (_fleetController.value * 40),
            top: 90,
            child: _buildFleetIcon('4'),
          );
        },
      ),
    ];
  }

  Widget _buildFleetIcon(String number) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.red[700],
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.5),
            blurRadius: 6,
          ),
        ],
      ),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationMarker(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
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
              width: 75,
              margin: const EdgeInsets.only(right: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min, // ป้องกัน overflow
                children: [
                  Container(
                    width: 36, // ลดขนาดเล็กลง
                    height: 36,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.red
                          : isPast
                              ? Colors.red.withValues(alpha: 0.3)
                              : AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive || isPast ? Colors.red : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _phases[index].icon,
                      color: isActive
                          ? Colors.white
                          : isPast
                              ? Colors.red
                              : AppColors.textMuted,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      '${index + 1}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isActive ? Colors.red : AppColors.textMuted,
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
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(phase.icon, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                phase.title,
                style: AppTextStyles.titleSmall.copyWith(
                  color: Colors.red,
                ),
              ),
              const Spacer(),
              Text(
                phase.date,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textMuted,
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
        return 'กองเรือ 4 กองเคลื่อนไหวหลายทิศทาง สร้างความสับสนว่าเป็นการประลองยุทธทางเรือ';
      case 1:
        return 'ญี่ปุ่นประกาศว่ายุติการประลองยุทธแล้ว ทำให้สหรัฐฯ ตายใจ';
      case 2:
        return 'กองเรือระงับวิทยุ รับคำสั่งทางเดียวจากวิทยุโตเกียว - สหรัฐฯ สูญเสียการติดตาม';
      case 3:
        return 'โจมตีเช้าตรู่ ระเบิด 360 ลูก เรือรบ 19 ลำ เครื่องบิน 180 ลำ ชีวิต 300+';
      default:
        return '';
    }
  }
}

class AttackPhase {
  final String title;
  final String date;
  final String description;
  final IconData icon;

  const AttackPhase({
    required this.title,
    required this.date,
    required this.description,
    required this.icon,
  });
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw wave lines
    for (var y = 20; y < size.height; y += 30) {
      final path = Path();
      path.moveTo(0, y.toDouble());
      for (var x = 0; x < size.width; x += 20) {
        path.quadraticBezierTo(
          x + 10,
          y + 5,
          x + 20,
          y.toDouble(),
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Widget แสดงบทเรียนที่ได้จากเพิร์ล ฮาร์เบอร์
class PearlHarborLessonsWidget extends StatelessWidget {
  const PearlHarborLessonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final lessons = [
      _LessonItem(
        icon: Icons.theater_comedy,
        iconColor: Colors.purple,
        text: 'การลวงทางอิเล็กทรอนิกส์มีประสิทธิภาพสูงมาก',
      ),
      _LessonItem(
        icon: Icons.signal_wifi_off,
        iconColor: Colors.red,
        text: 'Radio Silence ทำให้การติดตามเป็นไปไม่ได้',
      ),
      _LessonItem(
        icon: Icons.schedule,
        iconColor: Colors.blue,
        text: 'ESM ต้องทำงานอย่างต่อเนื่อง 24/7',
      ),
      _LessonItem(
        icon: Icons.search,
        iconColor: Colors.orange,
        text: 'การวิเคราะห์รูปแบบการสื่อสารมีความสำคัญ',
      ),
      _LessonItem(
        icon: Icons.warning,
        iconColor: Colors.amber,
        text: 'การขาดข้อมูลกะทันหันเป็นสัญญาณเตือน',
      ),
      _LessonItem(
        icon: Icons.hub,
        iconColor: Colors.teal,
        text: 'การรวมศูนย์ข่าวกรองหลายแหล่งจำเป็น',
      ),
      _LessonItem(
        icon: Icons.sync_problem,
        iconColor: Colors.deepPurple,
        text: 'ต้องมีแผนสำรองเมื่อสูญเสีย SIGINT',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
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
                'บทเรียนจากเพิร์ล ฮาร์เบอร์',
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
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    lesson.icon,
                    color: lesson.iconColor,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      lesson.text,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate(delay: Duration(milliseconds: 100 * index))
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

/// Widget แสดงการเปรียบเทียบ SIGINT ของสหรัฐฯ
class USIntelligenceWidget extends StatelessWidget {
  const USIntelligenceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.radar, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              Text(
                'การข่าวกรองของสหรัฐฯ',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          Row(
            children: [
              Expanded(
                child: _buildIntelBox(
                  'ทำได้ดี',
                  Colors.green,
                  Icons.check_circle,
                  [
                    'ติดตามกองเรือ 4 กอง',
                    'ดักรับการติดต่อวิทยุ',
                    'เฝ้าตรวจอย่างต่อเนื่อง',
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildIntelBox(
                  'ล้มเหลว',
                  Colors.red,
                  Icons.cancel,
                  [
                    'สูญเสียการติดตาม 2 ธ.ค.',
                    'ไม่รู้เรื่อง Radio Silence',
                    'ไม่รู้ว่าจะถูกโจมตี',
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntelBox(
    String title,
    Color color,
    IconData icon,
    List<String> items,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(color: color, fontSize: 12),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

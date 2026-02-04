import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../app/constants.dart';

/// กรณีศึกษา EW สมัยใหม่ - รวมกรณีศึกษาที่น่าสนใจในยุคปัจจุบัน
class ModernEWCasesWidget extends StatefulWidget {
  const ModernEWCasesWidget({super.key});

  @override
  State<ModernEWCasesWidget> createState() => _ModernEWCasesWidgetState();
}

class _ModernEWCasesWidgetState extends State<ModernEWCasesWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<ModernEWCase> _cases = [
    ModernEWCase(
      id: 'ukraine_russia',
      title: 'สงครามยูเครน-รัสเซีย (2022-ปัจจุบัน)',
      titleShort: 'ยูเครน',
      description: 'สนามรบ EW ที่ใหญ่ที่สุดในศตวรรษที่ 21',
      color: Colors.blue,
      icon: Icons.radar,
    ),
    ModernEWCase(
      id: 'thai_cambodia',
      title: 'ความขัดแย้งไทย-กัมพูชา (2008-2011)',
      titleShort: 'ไทย-กัมพูชา',
      description: 'การใช้ EW ในพื้นที่ชายแดนอาเซียน',
      color: Colors.orange,
      icon: Icons.cell_tower,
    ),
    ModernEWCase(
      id: 'syria',
      title: 'ซีเรีย (2015-ปัจจุบัน)',
      titleShort: 'ซีเรีย',
      description: 'การทดสอบระบบ EW ของรัสเซียในสนามรบจริง',
      color: Colors.red,
      icon: Icons.flight,
    ),
    ModernEWCase(
      id: 'nagorno_karabakh',
      title: 'สงคราม Nagorno-Karabakh (2020)',
      titleShort: 'อาร์เมเนีย',
      description: 'โดรนกับ EW ในสงครามสมัยใหม่',
      color: Colors.purple,
      icon: Icons.flight_takeoff,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _cases.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabBar(),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _UkraineRussiaCaseWidget(),
              _ThaiCambodiaCaseWidget(),
              _SyriaCaseWidget(),
              _NagornoKarabakhCaseWidget(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
        tabs: _cases.map((c) => Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(c.icon, size: 16),
              const SizedBox(width: 6),
              Text(c.titleShort),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

/// กรณีศึกษา: ยูเครน-รัสเซีย
class _UkraineRussiaCaseWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildTimeline(),
          const SizedBox(height: 20),
          _buildEWSystemsUsed(),
          const SizedBox(height: 20),
          _buildKeyLessons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0057B7), Color(0xFFFFD700)], // Ukraine colors
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.radar, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'สงครามอิเล็กทรอนิกส์ในยูเครน',
                      style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                    ),
                    Text(
                      '2022-ปัจจุบัน',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'สนามทดสอบ EW ที่ใหญ่ที่สุดนับตั้งแต่สงครามโลกครั้งที่ 2\n'
            'ทั้งสองฝ่ายใช้ระบบ EW หลากหลายในการต่อสู้',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildTimeline() {
    final events = [
      _TimelineEvent('ก.พ. 2022', 'เริ่มการรุกราน', 'รัสเซียใช้ EW รบกวน GPS และการสื่อสารยูเครน', Colors.red),
      _TimelineEvent('มี.ค. 2022', 'Starlink', 'ยูเครนนำ Starlink มาใช้ ต้านทานการรบกวน', Colors.blue),
      _TimelineEvent('เม.ย. 2022', 'โดรนสงคราม', 'ทั้งสองฝ่ายใช้โดรน FPV และ EW ต่อต้านโดรน', Colors.orange),
      _TimelineEvent('2023', 'วิวัฒนาการ EW', 'พัฒนาระบบ Anti-drone และ C-UAS อย่างรวดเร็ว', Colors.green),
      _TimelineEvent('2024', 'สงคราม AI', 'เริ่มใช้ AI ในการระบุและรบกวนสัญญาณ', Colors.purple),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
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
              const Icon(Icons.timeline, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('ไทม์ไลน์เหตุการณ์', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          ...events.asMap().entries.map((entry) {
            return _buildTimelineItem(entry.value, entry.key, events.length)
                .animate(delay: Duration(milliseconds: 100 * entry.key))
                .fadeIn()
                .slideX(begin: -0.2);
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(_TimelineEvent event, int index, int total) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and dot
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: event.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              if (index < total - 1)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.date,
                    style: AppTextStyles.labelSmall.copyWith(color: event.color),
                  ),
                  Text(event.title, style: AppTextStyles.titleSmall),
                  Text(
                    event.description,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEWSystemsUsed() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ระบบ EW ที่ใช้ในสนามรบ', style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSystemColumn('ฝ่ายรัสเซีย', [
                  'Krasukha-4 (C-band Jammer)',
                  'Zhitel (GPS Jammer)',
                  'RB-341V Leer-3 (Drone+Jammer)',
                  'Borisoglebsk-2 (COMINT)',
                ], Colors.red),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSystemColumn('ฝ่ายยูเครน', [
                  'NATO SIGINT Support',
                  'Bukovel-AD (Anti-Drone)',
                  'Starlink Terminals',
                  'Commercial Drone Detectors',
                ], Colors.blue),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildSystemColumn(String title, List<String> systems, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: Text(title, style: AppTextStyles.labelMedium.copyWith(color: color)),
        ),
        const SizedBox(height: 8),
        ...systems.map((s) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(Icons.arrow_right, color: color, size: 16),
              Expanded(
                child: Text(s, style: AppTextStyles.bodySmall),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildKeyLessons() {
    final lessons = [
      ('โดรนคือภัยคุกคามหลัก', 'ทั้งสองฝ่ายใช้โดรนราคาถูกในการโจมตี ต้องมีระบบ C-UAS'),
      ('Starlink เปลี่ยนเกม', 'การสื่อสารผ่านดาวเทียมทนทานต่อ Jamming ภาคพื้นดิน'),
      ('EW ต้องพัฒนาต่อเนื่อง', 'สงครามแมวจับหนู ต้องปรับปรุงระบบตลอดเวลา'),
      ('OSINT มีความสำคัญ', 'ข้อมูลจากโซเชียลมีเดียช่วยระบุตำแหน่งข้าศึก'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: AppColors.success),
              const SizedBox(width: 8),
              Text('บทเรียนสำคัญ', style: AppTextStyles.titleMedium.copyWith(color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 12),
          ...lessons.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.success),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.value.$1, style: AppTextStyles.titleSmall),
                        Text(
                          entry.value.$2,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate(delay: Duration(milliseconds: 100 * entry.key))
                .fadeIn()
                .slideX(begin: 0.1);
          }),
        ],
      ),
    );
  }
}

/// กรณีศึกษา: ความขัดแย้งไทย-กัมพูชา
class _ThaiCambodiaCaseWidget extends StatefulWidget {
  @override
  State<_ThaiCambodiaCaseWidget> createState() => _ThaiCambodiaCaseWidgetState();
}

class _ThaiCambodiaCaseWidgetState extends State<_ThaiCambodiaCaseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildConflictMap(),
          const SizedBox(height: 20),
          _buildTimeline(),
          const SizedBox(height: 20),
          _buildEWOperations(),
          const SizedBox(height: 20),
          _buildLessonsLearned(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0052B4), // Thai blue
            const Color(0xFFED1C24), // Thai/Cambodia red
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ความขัดแย้งชายแดนไทย-กัมพูชา',
                      style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                    ),
                    Text(
                      'พ.ศ. 2551-2554 (2008-2011)',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'ความขัดแย้งรอบปราสาทเขาพระวิหาร\n'
            'มีการใช้ระบบ SIGINT และ COMINT ในการรวบรวมข่าวกรอง',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildConflictMap() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          // Map background
          CustomPaint(
            size: const Size.fromHeight(250),
            painter: _BorderMapPainter(),
          ),
          // Animated radar sweep
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size.fromHeight(250),
                painter: _RadarSweepPainter(_animationController.value),
              );
            },
          ),
          // Locations overlay
          Positioned(
            left: 20,
            top: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.card.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('พื้นที่ปฏิบัติการ', style: AppTextStyles.labelSmall),
                  const SizedBox(height: 4),
                  _buildLocationLegend('ปราสาทเขาพระวิหาร', Colors.red),
                  _buildLocationLegend('จุดตรวจ SIGINT', AppColors.esColor),
                  _buildLocationLegend('เส้นแนวชายแดน', Colors.orange),
                ],
              ),
            ),
          ),
          // Preah Vihear marker
          Positioned(
            left: 150,
            top: 100,
            child: _buildPulsingMarker('เขาพระวิหาร', Colors.red),
          ),
          // SIGINT station markers
          Positioned(
            left: 80,
            top: 140,
            child: _buildStationMarker('S1', AppColors.esColor),
          ),
          Positioned(
            left: 200,
            top: 130,
            child: _buildStationMarker('S2', AppColors.esColor),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildLocationLegend(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }

  Widget _buildPulsingMarker(String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.location_on, color: Colors.white, size: 14),
        ).animate(onPlay: (c) => c.repeat())
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 1.seconds)
            .then()
            .scale(begin: const Offset(1.2, 1.2), end: const Offset(0.8, 0.8), duration: 1.seconds),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
      ],
    );
  }

  Widget _buildStationMarker(String label, Color color) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 2.seconds);
  }

  Widget _buildTimeline() {
    final events = [
      _TimelineEvent('2008', 'เริ่มความตึงเครียด', 'กัมพูชาขึ้นทะเบียนปราสาทเขาพระวิหารเป็นมรดกโลก', Colors.orange),
      _TimelineEvent('ต.ค. 2008', 'การปะทะครั้งแรก', 'เกิดการยิงปะทะบริเวณชายแดน มีผู้เสียชีวิต', Colors.red),
      _TimelineEvent('2009', 'เพิ่มกำลัง SIGINT', 'กองทัพไทยติดตั้งระบบ COMINT เพิ่มเติม', AppColors.esColor),
      _TimelineEvent('2010', 'การรบกวนสัญญาณ', 'ทั้งสองฝ่ายรบกวนการสื่อสารวิทยุ', AppColors.eaColor),
      _TimelineEvent('2011', 'การปะทะรุนแรง', 'เกิดการสู้รบหนักที่สุด มีการใช้ปืนใหญ่', Colors.red),
      _TimelineEvent('พ.ย. 2013', 'ศาลโลกตัดสิน', 'ศาลโลกตัดสินให้พื้นที่รอบปราสาทเป็นของกัมพูชา', Colors.blue),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
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
              const Icon(Icons.timeline, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('ไทม์ไลน์เหตุการณ์สำคัญ', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          ...events.asMap().entries.map((entry) {
            final event = entry.value;
            final index = entry.key;
            return _buildTimelineEventItem(event, index, events.length);
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineEventItem(_TimelineEvent event, int index, int total) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: event.color,
                  shape: BoxShape.circle,
                ),
              ),
              if (index < total - 1)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.date, style: AppTextStyles.labelSmall.copyWith(color: event.color)),
                  Text(event.title, style: AppTextStyles.titleSmall),
                  Text(
                    event.description,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 80 * index))
        .fadeIn()
        .slideX(begin: -0.1);
  }

  Widget _buildEWOperations() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ปฏิบัติการ EW ของกองทัพไทย', style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),
          _buildOperationCard(
            'SIGINT/COMINT',
            'การดักรับการสื่อสารวิทยุของฝ่ายตรงข้าม\nวิเคราะห์รูปแบบการสื่อสารและคำสั่งทางทหาร',
            Icons.hearing,
            AppColors.esColor,
          ),
          const SizedBox(height: 12),
          _buildOperationCard(
            'การรบกวนสัญญาณ',
            'รบกวนการสื่อสาร VHF/UHF ของข้าศึก\nในช่วงการปะทะเพื่อตัดการประสานงาน',
            Icons.signal_wifi_off,
            AppColors.eaColor,
          ),
          const SizedBox(height: 12),
          _buildOperationCard(
            'Direction Finding',
            'ระบุตำแหน่งเครื่องส่งวิทยุของข้าศึก\nใช้ข้อมูลในการวางแผนยิงสนับสนุน',
            Icons.gps_fixed,
            AppColors.primary,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildOperationCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall.copyWith(color: color)),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsLearned() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school, color: AppColors.success),
              const SizedBox(width: 8),
              Text('บทเรียนสำหรับกองทัพไทย', style: AppTextStyles.titleMedium.copyWith(color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 16),
          _buildLessonItem(1, 'SIGINT ช่วยเตือนภัยล่วงหน้า', 'การดักรับการสื่อสารช่วยทราบแผนการโจมตีก่อนเกิดเหตุ'),
          _buildLessonItem(2, 'ต้องมี COMSEC ที่ดี', 'ฝ่ายตรงข้ามก็ดักรับการสื่อสารของเราเช่นกัน'),
          _buildLessonItem(3, 'EW ต้องบูรณาการกับหน่วยรบ', 'ข้อมูล SIGINT ต้องส่งถึงผู้บังคับหน่วยอย่างทันเวลา'),
          _buildLessonItem(4, 'ภูมิประเทศมีผลต่อ EW', 'พื้นที่ภูเขาทำให้การ DF และ Jamming ทำได้ยาก'),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildLessonItem(int number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$number', style: AppTextStyles.labelSmall.copyWith(color: AppColors.success)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall),
                Text(description, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// กรณีศึกษา: ซีเรีย
class _SyriaCaseWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildRussianEWSystems(),
          const SizedBox(height: 20),
          _buildKeyIncidents(),
          const SizedBox(height: 20),
          _buildTechAnalysis(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1C2331), Color(0xFFC60C30)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flight, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'สนามทดสอบ EW ของรัสเซีย',
                      style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                    ),
                    Text(
                      'ซีเรีย 2015-ปัจจุบัน',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'รัสเซียใช้สงครามซีเรียเป็นสนามทดสอบระบบ EW สมัยใหม่\n'
            'ทั้ง GPS Jamming, Drone Detection และ Air Defense EW',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildRussianEWSystems() {
    final systems = [
      ('Krasukha-4', 'Ground-based EW', 'รบกวน AWACS และเรดาร์ทางอากาศ', Icons.radar),
      ('Zhitel', 'GPS Jammer', 'รบกวนสัญญาณ GPS/GLONASS', Icons.gps_off),
      ('Avtobaza', 'SIGINT', 'ดักรับสัญญาณ UAV และอากาศยาน', Icons.hearing),
      ('Khibiny', 'Airborne EW', 'ติดตั้งบน Su-34 รบกวนเรดาร์ข้าศึก', Icons.flight),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ระบบ EW หลักของรัสเซียในซีเรีย', style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),
          ...systems.asMap().entries.map((entry) {
            final s = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(s.$4, color: Colors.red, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(s.$1, style: AppTextStyles.titleSmall),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.textMuted.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(s.$2, style: AppTextStyles.labelSmall),
                              ),
                            ],
                          ),
                          Text(s.$3, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(delay: Duration(milliseconds: 100 * entry.key))
                .fadeIn()
                .slideX(begin: 0.1);
          }),
        ],
      ),
    );
  }

  Widget _buildKeyIncidents() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('เหตุการณ์ EW ที่สำคัญ', style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),
          _buildIncidentItem(
            '2015',
            'USS Donald Cook Incident',
            'Su-24 ของรัสเซียใช้ Khibiny รบกวนเรดาร์เรือพิฆาตสหรัฐ (ข่าวลือ)',
            Colors.blue,
          ),
          _buildIncidentItem(
            '2017',
            'Drone Swarm Attack',
            'ฐานทัพรัสเซียถูกโจมตีด้วย drone 13 ลำ ถูก Krasukha ยิงตก 7 ลำ',
            Colors.orange,
          ),
          _buildIncidentItem(
            '2018',
            'GPS Spoofing',
            'พบ GPS Spoofing รอบฐานทัพรัสเซียส่งผลกระทบต่อการบินพลเรือน',
            Colors.red,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildIncidentItem(String year, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(year, style: AppTextStyles.labelSmall.copyWith(color: color)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall),
                Text(description, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechAnalysis() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: AppColors.info),
              const SizedBox(width: 8),
              Text('การวิเคราะห์ทางเทคนิค', style: AppTextStyles.titleMedium.copyWith(color: AppColors.info)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Krasukha-4 สามารถรบกวน AWACS ได้ในระยะ 150-300 กม.\n'
            '• GPS Jamming ส่งผลกระทบต่อการบินพลเรือนในวงกว้าง\n'
            '• ระบบ EW ของรัสเซียมีประสิทธิภาพสูงในการป้องกันฐานทัพ\n'
            '• แต่ไม่สามารถป้องกัน drone swarm ขนาดใหญ่ได้ 100%',
            style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }
}

/// กรณีศึกษา: Nagorno-Karabakh 2020
class _NagornoKarabakhCaseWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildDroneWarfare(),
          const SizedBox(height: 20),
          _buildEWFailure(),
          const SizedBox(height: 20),
          _buildLessons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00AAAD), Color(0xFFEF3340)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flight_takeoff, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'สงครามโดรน Nagorno-Karabakh',
                      style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                    ),
                    Text(
                      '27 ก.ย. - 10 พ.ย. 2020 (44 วัน)',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'อาเซอร์ไบจาน vs อาร์เมเนีย\n'
            'โดรน Bayraktar TB2 ทำลายระบบป้องกันภัยทางอากาศของอาร์เมเนีย\n'
            'EW ล้มเหลวในการป้องกันโดรน',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildDroneWarfare() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('โดรนที่ใช้ในสนามรบ', style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDroneCard(
                  'Bayraktar TB2',
                  'Turkey',
                  '• UCAV ติดอาวุธ\n• ระยะ 150 กม.\n• สูง 8,200 ม.',
                  Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDroneCard(
                  'Harop',
                  'Israel',
                  '• Loitering Munition\n• ระยะ 1,000 กม.\n• Kamikaze drone',
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'โดรนทำลายรถถัง T-72 กว่า 185 คัน และระบบ S-300 หลายชุด',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildDroneCard(String name, String origin, String specs, Color color) {
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
              Icon(Icons.flight, color: color, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(name, style: AppTextStyles.titleSmall.copyWith(color: color)),
              ),
            ],
          ),
          Text(origin, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 8),
          Text(specs, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildEWFailure() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error),
              const SizedBox(width: 8),
              Text('ทำไม EW ของอาร์เมเนียล้มเหลว?', style: AppTextStyles.titleMedium.copyWith(color: AppColors.error)),
            ],
          ),
          const SizedBox(height: 16),
          _buildFailurePoint('ระบบล้าสมัย', 'ใช้ระบบจากยุคโซเวียต ไม่ได้ออกแบบมาต้านโดรนสมัยใหม่'),
          _buildFailurePoint('ไม่มี Layered Defense', 'พึ่งพาแค่ S-300 ไม่มีระบบ SHORAD'),
          _buildFailurePoint('ขาดการซ้อมรบ', 'ไม่เคยฝึกต่อต้านโดรนจริงจัง'),
          _buildFailurePoint('ข่าวกรองอ่อน', 'ไม่รู้ขีดความสามารถของ TB2 จนกว่าจะสาย'),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildFailurePoint(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.close, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall),
                Text(description, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: AppColors.success),
              const SizedBox(width: 8),
              Text('บทเรียนสำหรับกองทัพไทย', style: AppTextStyles.titleMedium.copyWith(color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 16),
          _buildLessonItem('1', 'ต้องมีระบบ C-UAS ที่ทันสมัย'),
          _buildLessonItem('2', 'Layered Air Defense (Short + Medium + Long Range)'),
          _buildLessonItem('3', 'ฝึกซ้อมต่อต้านโดรนอย่างสม่ำเสมอ'),
          _buildLessonItem('4', 'ติดตามเทคโนโลยีโดรนของประเทศเพื่อนบ้าน'),
          _buildLessonItem('5', 'บูรณาการ EW กับระบบป้องกันภัยทางอากาศ'),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildLessonItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(number, style: AppTextStyles.labelSmall.copyWith(color: AppColors.success)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}

// ============ Helper Classes ============

class ModernEWCase {
  final String id;
  final String title;
  final String titleShort;
  final String description;
  final Color color;
  final IconData icon;

  ModernEWCase({
    required this.id,
    required this.title,
    required this.titleShort,
    required this.description,
    required this.color,
    required this.icon,
  });
}

class _TimelineEvent {
  final String date;
  final String title;
  final String description;
  final Color color;

  _TimelineEvent(this.date, this.title, this.description, this.color);
}

// ============ Custom Painters ============

/// Border Map Painter for Thai-Cambodia conflict visualization
class _BorderMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = const Color(0xFF1A2332)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw terrain-like background
    final terrainPaint = Paint()
      ..color = const Color(0xFF243B45)
      ..style = PaintingStyle.fill;

    // Draw some "terrain" shapes
    final path = Path();
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.3, size.height * 0.5,
      size.width * 0.5, size.height * 0.55,
    );
    path.quadraticBezierTo(
      size.width * 0.7, size.height * 0.6,
      size.width, size.height * 0.5,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, terrainPaint);

    // Draw border line (dashed)
    final borderPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dashPath = Path();
    dashPath.moveTo(0, size.height * 0.55);
    dashPath.quadraticBezierTo(
      size.width * 0.5, size.height * 0.45,
      size.width, size.height * 0.5,
    );

    // Draw dashed line
    final dashLength = 10.0;
    final dashSpace = 5.0;
    double distance = 0.0;
    for (final metric in dashPath.computeMetrics()) {
      while (distance < metric.length) {
        final start = metric.getTangentForOffset(distance);
        final end = metric.getTangentForOffset(
          (distance + dashLength).clamp(0, metric.length),
        );
        if (start != null && end != null) {
          canvas.drawLine(start.position, end.position, borderPaint);
        }
        distance += dashLength + dashSpace;
      }
    }

    // Draw grid
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.1)
      ..strokeWidth = 0.5;

    for (var i = 0; i < size.width; i += 40) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        gridPaint,
      );
    }
    for (var i = 0; i < size.height; i += 40) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        gridPaint,
      );
    }

    // Labels
    final thaiLabel = TextPainter(
      text: const TextSpan(
        text: 'THAILAND',
        style: TextStyle(color: Color(0xFF4A90D9), fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    thaiLabel.layout();
    thaiLabel.paint(canvas, Offset(size.width - 80, size.height * 0.7));

    final cambodiaLabel = TextPainter(
      text: const TextSpan(
        text: 'CAMBODIA',
        style: TextStyle(color: Color(0xFFD94A4A), fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    cambodiaLabel.layout();
    cambodiaLabel.paint(canvas, Offset(20, size.height * 0.3));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Radar Sweep Painter for animated effect
class _RadarSweepPainter extends CustomPainter {
  final double progress;

  _RadarSweepPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(80, 140);
    final radius = 60.0;
    final angle = progress * 2 * math.pi;

    // Sweep gradient
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: angle - 0.5,
        endAngle: angle,
        colors: [
          AppColors.esColor.withValues(alpha: 0.0),
          AppColors.esColor.withValues(alpha: 0.3),
        ],
        transform: GradientRotation(angle),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, sweepPaint);

    // Sweep line
    final linePaint = Paint()
      ..color = AppColors.esColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final endPoint = Offset(
      center.dx + radius * math.cos(angle - math.pi / 2),
      center.dy + radius * math.sin(angle - math.pi / 2),
    );
    canvas.drawLine(center, endPoint, linePaint);
  }

  @override
  bool shouldRepaint(covariant _RadarSweepPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

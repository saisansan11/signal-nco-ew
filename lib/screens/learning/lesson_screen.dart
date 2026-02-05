import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../app/constants.dart';
import '../../models/curriculum_models.dart';
import '../../widgets/educational/ew_pillars_widget.dart';
import '../../widgets/educational/spectrum_bands_widget.dart';
import '../../widgets/educational/jamming_types_widget.dart';
import '../../widgets/educational/fhss_widget.dart';
import '../../widgets/educational/esm_process_widget.dart';
import '../../widgets/educational/tannenberg_case_widget.dart';
import '../../widgets/educational/pearl_harbor_case_widget.dart';
import '../../widgets/educational/modern_ew_cases_widget.dart';
import '../../widgets/educational/esm_signal_hunter_widget.dart';
import '../../widgets/educational/ecm_jamming_warfare_widget.dart';
import '../../widgets/educational/eccm_shield_defense_widget.dart';
import '../../widgets/educational/signal_waveform_widget.dart';
import '../../widgets/educational/memory_helper_widget.dart';
import '../../widgets/educational/radar_equation_widget.dart';
import '../../widgets/educational/ew_world_map_widget.dart';
import '../../widgets/educational/antenna_pattern_widget.dart';
import '../../widgets/educational/link_budget_widget.dart';
import '../../widgets/educational/gps_warfare_widget.dart';
import '../../widgets/educational/df_triangulation_widget.dart';

/// หน้าจอแสดงเนื้อหาบทเรียน
class LessonScreen extends StatefulWidget {
  final EWModule module;
  final Lesson lesson;

  const LessonScreen({
    super.key,
    required this.module,
    required this.lesson,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _currentPage = 0;
  late List<LessonPage> _pages;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pages = _buildLessonPages();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<LessonPage> _buildLessonPages() {
    // สร้างเนื้อหาตาม lesson id
    switch (widget.lesson.id) {
      // บทที่ 0: ประวัติศาสตร์ EW
      case 'junior_0_1':
        return _ewHistoryIntroPages();
      case 'junior_0_2':
        return _tannenbergCasePages();
      case 'junior_0_3':
        return _pearlHarborCasePages();

      // บทที่ 1: ภาพรวม EW
      case 'junior_1_1':
        return _ewOverviewPages();
      case 'junior_1_2':
        return _ewPillarsPages();

      // บทที่ 2: สเปกตรัม
      case 'junior_2_1':
        return _spectrumBasicsPages();
      case 'junior_2_2':
        return _spectrumSimPages();

      // บทที่ 3: ESM พื้นฐาน
      case 'junior_3_1':
        return _esmBasicsPages();
      case 'junior_3_2':
        return _sigintPages();

      // บทที่ 4: ECM พื้นฐาน
      case 'junior_4_1':
        return _jammingBasicsPages();
      case 'junior_4_2':
        return _jammingTypesPages();

      // บทที่ 5: ECCM พื้นฐาน
      case 'junior_5_1':
        return _eccmBasicsPages();
      case 'junior_5_2':
        return _fhssPages();

      // บทที่ 6: วิทยุยุทธวิธี
      case 'junior_6_1':
        return _tacticalRadioPages();
      case 'junior_6_2':
        return _comsecPages();

      // บทที่ 7: ระเบียบปฏิบัติภาคสนาม
      case 'junior_7_1':
        return _ewSopsPages();
      case 'junior_7_2':
        return _checklistPages();

      // ==================== นายสิบอาวุโส ====================

      // บทที่ 8: ESM ขั้นสูง
      case 'senior_8_1':
        return _advancedDFPages();
      case 'senior_8_2':
        return _triangulationPracticePages();
      case 'senior_8_3':
        return _eobAnalysisPages();

      // บทที่ 9: ECM ขั้นสูง
      case 'senior_9_1':
        return _jsRatioPages();
      case 'senior_9_2':
        return _jsCalculatorPages();
      case 'senior_9_3':
        return _jammingPlanningPages();

      // บทที่ 10: ECCM ขั้นสูง
      case 'senior_10_1':
        return _advancedECCMPages();
      case 'senior_10_2':
        return _eccmPracticePages();

      // บทที่ 11: ระบบเรดาร์
      case 'senior_11_1':
        return _radarTypesPages();
      case 'senior_11_2':
        return _radarSimPages();

      // บทที่ 12: Anti-Drone EW
      case 'senior_12_1':
        return _droneDetectionPages();
      case 'senior_12_2':
        return _droneCounterPages();

      // บทที่ 13: GPS Warfare
      case 'senior_13_1':
        return _gpsJammingSpoofingPages();
      case 'senior_13_2':
        return _gpsSpoofDetectionPages();

      // บทที่ 14: กรณีศึกษา EW
      case 'senior_14_1':
        return _ewCaseStudyPages();
      case 'senior_14_2':
        return _scenarioAnalysisPages();

      // บทที่ 15: การวางแผนยุทธวิธี
      case 'senior_15_1':
        return _missionPlanningPages();
      case 'senior_15_2':
        return _planningPracticePages();

      // บทที่ 16: การประมาณการ EW
      case 'senior_16_1':
        return _ewEstimatePages();
      case 'senior_16_2':
        return _ewAnnexPages();
      case 'senior_16_3':
        return _ewPrioritiesPages();

      // บทที่ 17: การจัดตั้งหน่วย EW
      case 'senior_17_1':
        return _ewOrgConsiderationsPages();
      case 'senior_17_2':
        return _ewBattalionPages();
      case 'senior_17_3':
        return _ewCompanyPages();

      // บทที่ 18: ยุทธวิธี EW
      case 'senior_18_1':
        return _modernBattlefieldPages();
      case 'senior_18_2':
        return _enemyEWAnalysisPages();
      case 'senior_18_3':
        return _ewTacticsPages();

      default:
        return _defaultPages();
    }
  }

  // ==================== บทที่ 0: ประวัติศาสตร์ EW ====================

  List<LessonPage> _ewHistoryIntroPages() {
    return [
      LessonPage(
        title: 'จุดเริ่มต้นของสงครามอิเล็กทรอนิกส์',
        content: '''
สงครามอิเล็กทรอนิกส์ไม่ได้เริ่มต้นจากเทคโนโลยีสมัยใหม่ แต่มีจุดกำเนิดตั้งแต่ต้นศตวรรษที่ 20

📻 ค.ศ. 1901
มาร์โคนีส่งสัญญาณวิทยุข้ามมหาสมุทรแอตแลนติกสำเร็จ

⚔️ ค.ศ. 1914
สงครามโลกครั้งที่ 1 เริ่มต้น
กองทัพเริ่มใช้วิทยุในการสื่อสารทางทหาร

🎯 จุดเปลี่ยนสำคัญ
การดักรับสัญญาณวิทยุครั้งแรกที่มีผลต่อการรบ
เกิดขึ้นที่ยุทธการเทนเนนเบิร์ก
''',
        visualWidget: _buildEWOriginTimeline(),
      ),
      LessonPage(
        title: 'แนวรบตะวันออก ค.ศ. 1914',
        content: '''
🌍 สถานการณ์:
สงครามโลกครั้งที่ 1 แนวรบตะวันออก

🇩🇪 ฝ่ายเยอรมัน:
• พลเอก ฟอน อินเดนเบิร์ก (ผู้บัญชาการ)
• กำลังน้อยกว่า ตั้งรับใกล้ชายแดน

🇷🇺 ฝ่ายรัสเซีย:
• กองทัพที่ 1 (นายพลเรนเนแคมฟ์) - ทางเหนือ
• กองทัพที่ 2 (นายพลแซมโซนอฟ) - ทางใต้
• วางแผนโจมตีสองทาง บีบเยอรมัน

⚡ จุดอ่อนสำคัญ:
รัสเซียส่งคำสั่งทางวิทยุ... โดยไม่เข้ารหัส!
''',
        visualWidget: _buildEasternFrontMap(),
      ),
      LessonPage(
        title: 'SIGINT คืออะไร?',
        content: '''
📡 SIGINT (Signal Intelligence)
= ข่าวกรองสัญญาณ

คือ การรวบรวมข่าวสารจากการดักรับสัญญาณสื่อสาร

SIGINT แบ่งเป็น 2 ประเภทหลัก:

📞 COMINT (Communications Intelligence)
• ดักรับการสื่อสาร (วิทยุ, โทรศัพท์)
• วิเคราะห์เนื้อหาข้อความ

📊 ELINT (Electronic Intelligence)
• ดักรับสัญญาณที่ไม่ใช่การสื่อสาร
• เช่น เรดาร์, ระบบนำทาง

ยุทธที่เทนเนนเบิร์กคือจุดกำเนิดของ COMINT!
''',
        visualWidget: _buildSigintDiagram(),
      ),

      // หน้าแผนที่โลก EW
      LessonPage(
        title: '🗺️ แผนที่ประวัติศาสตร์ EW',
        content: '''
🌍 เหตุการณ์สำคัญในประวัติศาสตร์ EW

สำรวจเหตุการณ์สำคัญทั่วโลกที่เปลี่ยนแปลงสงครามอิเล็กทรอนิกส์!

📍 แตะที่จุดบนแผนที่เพื่อดูรายละเอียด
🎬 กด "นำชม" เพื่อดูแบบพิพิธภัณฑ์

ตั้งแต่ปี 1914 ถึงปัจจุบัน:
• การดักรับสัญญาณครั้งแรก
• การใช้เรดาร์ในสงคราม
• ยุค EW สมัยใหม่
• สงครามโดรนในปัจจุบัน
''',
        // EWWorldMapWidget needs height constraint as it uses Expanded internally
        visualWidget: const SizedBox(
          height: 450,
          child: EWWorldMapWidget(),
        ),
      ),
    ];
  }

  List<LessonPage> _tannenbergCasePages() {
    return [
      LessonPage(
        title: 'ยุทธที่เทนเนนเบิร์ก',
        content: '''
📅 20-27 สิงหาคม ค.ศ. 1914
📍 ใกล้ชายแดนเยอรมัน-รัสเซีย (ปัจจุบันคือโปแลนด์)

นี่คือการรบที่พิสูจน์ว่า:
"ข้อมูลข่าวสาร สามารถชี้ขาดชัยชนะได้"

แตะที่แผนที่เพื่อดูขั้นตอนการรบ
และบทบาทของการดักรับวิทยุ
''',
        visualWidget: const TannenbergCaseWidget(),
      ),
      LessonPage(
        title: 'คำสั่งที่ถูกดักรับ',
        content: '''
📻 คำสั่งจากกองบัญชาการรัสเซีย:

"กองทัพที่ 1:
เข้าประชิดและตรึงกำลังเยอรมัน
(ไม่ต้องเข้าตี รอกองทัพที่ 2)

กองทัพที่ 2:
รุกข้ามพรมแดนเพื่อยึดเมืองเทนเนนเบิร์ก"

⚠️ ส่งโดยไม่เข้ารหัส!

พนักงานวิทยุเยอรมันดักรับได้ทั้งหมด
• รู้แผนการโจมตี
• รู้เส้นทางเคลื่อนกำลัง
• รู้เวลาโจมตี
''',
        visualWidget: _buildInterceptedMessageWidget(),
      ),
      LessonPage(
        title: 'การตอบโต้ของเยอรมัน',
        content: '''
🎯 การตัดสินใจเชิงยุทธวิธี:

1️⃣ ใช้กองพลทหารม้า 1 กองพล
   ลวงกองทัพที่ 1 ทางเหนือ
   (ทำให้คิดว่ายังมีกำลังหลักอยู่)

2️⃣ เคลื่อนกำลังหลักลงมาทางใต้
   ไปสกัดกองทัพที่ 2 ที่เทนเนนเบิร์ก

3️⃣ ตั้งรับโดยรู้ล่วงหน้า
   • ตำแหน่งข้าศึก
   • เส้นทางเข้าตี
   • เวลาโจมตี

💡 นี่คือพลังของ "ข้อมูลข่าวสาร"!
''',
        visualWidget: _buildGermanResponseWidget(),
      ),
      LessonPage(
        title: 'ผลลัพธ์และบทเรียน',
        content: '''
⚔️ ผลการรบ:
• กองทัพรัสเซียที่ 2 ถูกโจมตีขนาบ
• ถอยหนีไปจมในทะเลสาบมาซูเรี่ยน
• สูญเสียทหารกว่า 90,000 นาย
• นายพลแซมโซนอฟยิงตัวตาย

🏆 ชัยชนะเด็ดขาดของเยอรมัน

💡 บทเรียนที่ได้:
การดักรับวิทยุครั้งเดียว
เปลี่ยนผลการรบทั้งหมด!
''',
        visualWidget: const TannenbergLessonsWidget(),
      ),
      LessonPage(
        title: 'หลักการที่ได้จากเทนเนนเบิร์ก',
        content: '''
🔐 COMSEC (Communications Security)
ความปลอดภัยทางการสื่อสารมีความสำคัญสูงสุด

📡 SIGINT มีพลังมหาศาล
การดักรับสามารถเปลี่ยนผลการรบได้

⚡ ความทันเวลา (Timeliness)
ข้อมูลที่ได้ทันเวลา = ข้อมูลที่มีค่า

🎯 การประยุกต์ใช้ในปัจจุบัน:
• เข้ารหัสการสื่อสารทุกครั้ง
• ใช้ FHSS (กระโดดความถี่)
• ตรวจสอบความปลอดภัยสม่ำเสมอ
• ฝึกวินัยการสื่อสาร
''',
        visualWidget: _buildModernApplicationWidget(),
      ),
    ];
  }

  List<LessonPage> _pearlHarborCasePages() {
    return [
      LessonPage(
        title: 'การโจมตีเพิร์ล ฮาร์เบอร์',
        content: '''
📅 7 ธันวาคม 2484 (1941)
📍 เพิร์ล ฮาร์เบอร์ ฮาวาย

นี่คือกรณีศึกษาที่แสดงให้เห็นว่า:
"การลวงทางอิเล็กทรอนิกส์และ Radio Silence
สามารถทำให้ SIGINT ล้มเหลวได้"

แตะที่แผนที่เพื่อดูขั้นตอนการเตรียมการ
และการโจมตี
''',
        visualWidget: const PearlHarborCaseWidget(),
      ),
      LessonPage(
        title: 'แผนการลวง (Deception)',
        content: '''
🎭 การลวงเชิงยุทธศาสตร์ของญี่ปุ่น:

📅 3-7 พ.ย. 2484:
กองเรือ 4 กองเคลื่อนไหวในน่านน้ำต่างๆ
ปล่อยข่าวว่าเป็น "การประลองยุทธทางเรือครั้งใหญ่"

• กองเรือที่ 1: ไต้หวัน → ทะเลจีน
• กองเรือที่ 2: ทะเลจีนตอนเหนือ
• กองเรือที่ 3: คิวชิว
• กองเรือที่ 4: ฮอนชิว → หมู่เกาะโบนิน

📅 1 ธ.ค. 2484:
ประกาศว่า "ยุติการประลองยุทธแล้ว"
''',
        visualWidget: _buildDeceptionPlanWidget(),
      ),
      LessonPage(
        title: 'Radio Silence',
        content: '''
📵 การระงับวิทยุสนิท (EMCON)

📅 2 ธ.ค. 2484:
ญี่ปุ่นใช้มาตรการ Radio Silence

⛔ หยุดการส่งวิทยุทั้งหมด
📻 รับคำสั่งทางเดียวจากวิทยุโตเกียว
🚢 แสร้งแล่นขึ้นเหนือไปอะลาสกา
↩️ จริงๆ เบนกลับมุ่งเพิร์ล ฮาร์เบอร์

ผลกระทบต่อ SIGINT:
❌ สหรัฐฯ สูญเสียการติดตามทันที
❌ ไม่ทราบตำแหน่งกองเรือ
❌ ไม่รู้ว่ากำลังจะถูกโจมตี
''',
        visualWidget: _buildRadioSilenceWidget(),
      ),
      LessonPage(
        title: 'การข่าวกรองของสหรัฐฯ',
        content: '''
🔍 สิ่งที่ทำได้ดี:
• นาวาเอก Joseph Rochfort ดักรับการสื่อสาร
• ติดตามกองเรือทั้ง 4 กอง
• เฝ้าตรวจอย่างต่อเนื่อง

❌ สิ่งที่ล้มเหลว:
• สูญเสียการติดตามตั้งแต่ 2 ธ.ค.
• ไม่รู้เรื่อง Radio Silence
• ไม่เข้าใจว่าการหายไปคือสัญญาณเตือน

💡 บทเรียน:
"การขาดข้อมูลกะทันหัน อาจหมายถึงอันตราย"
''',
        visualWidget: const USIntelligenceWidget(),
      ),
      LessonPage(
        title: 'ผลการโจมตี',
        content: '''
💥 7 ธันวาคม 2484 เช้าตรู่:

⏰ เวลา: 07:48 น. (ตามเวลาท้องถิ่น)
💣 ระเบิด: 360 ลูก
🎯 ความสำเร็จ: 100%
   ไม่มีสิ่งใดขัดขวาง!

📊 ความเสียหาย:
👥 ชีวิต: มากกว่า 2,400 คน
🚢 เรือรบ: 19 ลำ ถูกจม/เสียหาย
✈️ เครื่องบิน: 180+ ลำ ถูกทำลาย

🏴 ผลกระทบ:
สหรัฐฯ ประกาศสงครามต่อญี่ปุ่นในวันรุ่งขึ้น
''',
        visualWidget: _buildAttackResultWidget(),
      ),
      LessonPage(
        title: 'บทเรียนจากเพิร์ล ฮาร์เบอร์',
        content: '''
📚 หลักการสำคัญที่ได้:

🎭 การลวงทางอิเล็กทรอนิกส์มีพลังมหาศาล
📵 Radio Silence ทำให้ SIGINT ตาบอด
⏰ ESM ต้องทำงาน 24/7 ไม่หยุด
🔍 วิเคราะห์รูปแบบ ไม่ใช่แค่เนื้อหา
⚠️ การหายไปของสัญญาณ = สัญญาณเตือน

🎯 การประยุกต์ใช้:
• ต้องมี Multi-INT (หลายแหล่งข่าว)
• เมื่อ SIGINT ล้มเหลว ต้องมีแผนสำรอง
• ติดตามทั้ง "สิ่งที่มี" และ "สิ่งที่หายไป"
''',
        visualWidget: const PearlHarborLessonsWidget(),
      ),
    ];
  }

  // Widget สำหรับเพิร์ล ฮาร์เบอร์

  Widget _buildDeceptionPlanWidget() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.theater_comedy, color: Colors.purple, size: 24),
              const SizedBox(width: 8),
              Text(
                'แผนการลวง 4 กองเรือ',
                style: AppTextStyles.titleSmall.copyWith(
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFleetDeception(1, 'ไต้หวัน → ทะเลจีน', Icons.directions_boat),
          _buildFleetDeception(2, 'ทะเลจีนตอนเหนือ', Icons.directions_boat),
          _buildFleetDeception(3, 'คิวชิว', Icons.directions_boat),
          _buildFleetDeception(4, 'ฮอนชิว → โบนิน', Icons.directions_boat),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_forward, color: Colors.orange, size: 16),
                const SizedBox(width: 6),
                Text(
                  'รวมพลที่โบนิน → เพิร์ล ฮาร์เบอร์',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFleetDeception(int fleet, String route, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$fleet',
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, color: AppColors.textMuted, size: 18),
          const SizedBox(width: 8),
          Text(
            'กองเรือที่ $fleet: $route',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 150 * fleet))
        .fadeIn()
        .slideX(begin: 0.2, end: 0);
  }

  Widget _buildRadioSilenceWidget() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          // Radio silence header with blinking effect
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.signal_wifi_off, color: Colors.red, size: 28),
                const SizedBox(width: 12),
                Text(
                  'RADIO SILENCE',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: 800.ms)
              .then()
              .fadeOut(duration: 800.ms),
          const SizedBox(height: 16),
          // Timeline
          Row(
            children: [
              _buildRadioStatus('ก่อน 2 ธ.ค.', true, 'สื่อสารปกติ'),
              const Icon(Icons.arrow_forward, color: AppColors.textMuted),
              _buildRadioStatus('หลัง 2 ธ.ค.', false, 'เงียบสนิท'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadioStatus(String label, bool active, String status) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: active
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          border: Border.all(
            color: active
                ? Colors.green.withValues(alpha: 0.3)
                : Colors.red.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              active ? Icons.wifi : Icons.signal_wifi_off,
              color: active ? Colors.green : Colors.red,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            Text(
              status,
              style: AppTextStyles.labelSmall.copyWith(
                color: active ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttackResultWidget() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(
            '💥 ความเสียหาย',
            style: AppTextStyles.titleSmall.copyWith(
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildCasualtyCard('👥', '2,400+', 'ผู้เสียชีวิต'),
              const SizedBox(width: 8),
              _buildCasualtyCard('🚢', '19', 'เรือรบ'),
              const SizedBox(width: 8),
              _buildCasualtyCard('✈️', '180+', 'เครื่องบิน'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  'ความสำเร็จ 100% - ไม่มีการขัดขวาง',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCasualtyCard(String emoji, String number, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            Text(
              number,
              style: AppTextStyles.titleMedium.copyWith(
                color: Colors.red,
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
        ),
      ).animate().fadeIn().scale(),
    );
  }

  // Widget สำหรับบทที่ 0

  Widget _buildEWOriginTimeline() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.esColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(child: _buildTimelineNode('1901', 'วิทยุข้าม\nมหาสมุทร', Icons.radio, 0)),
              Flexible(child: _buildTimelineNode('1914', 'สงคราม\nโลกครั้งที่ 1', Icons.flag, 1)),
              Flexible(child: _buildTimelineNode('1914', 'SIGINT\nครั้งแรก', Icons.hearing, 2)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.esColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: AppColors.warning, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'วิทยุเปลี่ยนโฉมการทำสงคราม - ทั้งเป็นข้อดีและข้อเสีย',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
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

  Widget _buildTimelineNode(String year, String label, IconData icon, int index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.esColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.esColor, width: 2),
          ),
          child: Icon(icon, color: AppColors.esColor, size: 20),
        ).animate(delay: Duration(milliseconds: 200 * index))
            .fadeIn()
            .scale(),
        const SizedBox(height: 6),
        Text(
          year,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.esColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildEasternFrontMap() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          // Grid background
          CustomPaint(
            size: const Size(double.infinity, 200),
            painter: _SimpleGridPainter(),
          ),
          // Germany label
          Positioned(
            left: 20,
            top: 80,
            child: _buildCountryLabel('🇩🇪 เยอรมัน', Colors.grey[700]!),
          ),
          // Russia label
          Positioned(
            right: 20,
            top: 80,
            child: _buildCountryLabel('🇷🇺 รัสเซีย', Colors.red[700]!),
          ),
          // Front line
          Positioned(
            left: 0,
            right: 0,
            top: 90,
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 100),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.red.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Label
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'แนวรบตะวันออก 1914',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryLabel(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSigintDiagram() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.esColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // SIGINT header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.esColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.radar, color: AppColors.esColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'SIGINT',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.esColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Two branches
          Row(
            children: [
              Expanded(
                child: _buildSigintBranch(
                  'COMINT',
                  'ข่าวกรองการสื่อสาร',
                  Icons.phone_in_talk,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSigintBranch(
                  'ELINT',
                  'ข่าวกรองอิเล็กทรอนิกส์',
                  Icons.sensors,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSigintBranch(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildInterceptedMessageWidget() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          // Warning header
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Text(
                  'คำสั่งที่ไม่เข้ารหัส',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Message content (simulated telegram style)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📻 สัญญาณวิทยุดักรับได้:',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '"กองทัพที่ 1 ตรึงกำลัง\nกองทัพที่ 2 รุกยึดเทนเนนเบิร์ก"',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ).animate()
              .fadeIn(delay: 300.ms)
              .shimmer(duration: 2000.ms, color: Colors.red.withValues(alpha: 0.3)),
        ],
      ),
    );
  }

  Widget _buildGermanResponseWidget() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            '🎯 การตอบโต้เชิงยุทธวิธี',
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 12),
          _buildResponseStep(1, 'ลวง', 'ใช้ทหารม้าลวงกองทัพที่ 1', Icons.visibility_off),
          _buildResponseStep(2, 'เคลื่อน', 'ย้ายกำลังหลักลงใต้', Icons.directions_run),
          _buildResponseStep(3, 'สกัด', 'ตั้งรับที่เทนเนนเบิร์ก', Icons.shield),
        ],
      ),
    );
  }

  Widget _buildResponseStep(int step, String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: AppColors.success, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 200 * step))
        .fadeIn()
        .slideX(begin: 0.2, end: 0);
  }

  Widget _buildModernApplicationWidget() {
    final applications = [
      ('🔐', 'เข้ารหัสทุกครั้ง', 'ใช้การเข้ารหัสที่แข็งแกร่ง'),
      ('📡', 'FHSS', 'กระโดดความถี่หลีกเลี่ยงการดักรับ'),
      ('✅', 'ตรวจสอบ', 'ตรวจสอบความปลอดภัยสม่ำเสมอ'),
      ('📋', 'วินัย', 'ฝึกวินัยการสื่อสาร'),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            '🎯 การประยุกต์ใช้ในปัจจุบัน',
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: applications.asMap().entries.map((entry) {
              final index = entry.key;
              final app = entry.value;
              return Container(
                width: 140,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Column(
                  children: [
                    Text(app.$1, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 4),
                    Text(
                      app.$2,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      app.$3,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: Duration(milliseconds: 150 * index))
                  .fadeIn()
                  .scale();
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ==================== บทที่ 1: ภาพรวม EW ====================

  List<LessonPage> _ewOverviewPages() {
    return [
      LessonPage(
        title: 'สงครามอิเล็กทรอนิกส์คืออะไร?',
        content: '''
📖 นิยาม (ตามตำรา):

"การปฏิบัติทางทหารที่เกี่ยวกับการใช้พลังงาน
คลื่นแม่เหล็กไฟฟ้า เพื่อกำหนด ขยายผล ลด
หรือป้องกันการใช้ย่านความถี่คลื่นแม่เหล็กไฟฟ้า
ของข้าศึก และปฏิบัติการซึ่งมุ่งดำรงรักษา
การใช้ย่านความถี่คลื่นแม่เหล็กไฟฟ้าของฝ่ายเรา"

🎯 วัตถุประสงค์:
ให้เกิดประโยชน์ต่อการดำเนินการสงคราม
ในส่วนรวมของฝ่ายเรา
''',
        visualWidget: _buildEWConceptDiagram(),
      ),
      LessonPage(
        title: 'สงครามแม่มด (Wizard War)',
        content: '''
💭 คำกล่าวของ Winston Churchill:

"มันเป็นสงครามลับที่แพ้ชนะกัน
ประชาชนทั่วไปไม่ทราบ เพราะมันมีความยุ่งยาก
เกินความเข้าใจของคนทั่วไป
นอกจากผู้เกี่ยวข้องและนักวิทยาศาสตร์ชั้นเยี่ยม

ถ้าอังกฤษไม่สามารถปรับปรุงด้านนี้
มาสู้กับเยอรมันเพื่อความอยู่รอดได้แล้ว
ก็หมายความว่าอังกฤษต้องเป็นฝ่ายพ่ายแพ้
และจะถูกทำลายโดยสิ้นเชิง"

🎖️ เรียกว่า "สงครามแม่มด" (Wizard War)
''',
        visualWidget: _buildWizardWarWidget(),
      ),
      LessonPage(
        title: 'ความสำคัญในสงครามสมัยใหม่',
        content: '''
📡 อำนาจกำลังรบขึ้นอยู่กับ:
• ขีดความสามารถทางอิเล็กทรอนิกส์
• การใช้ประโยชน์จากพลังงานคลื่นแม่เหล็กไฟฟ้า

⚔️ หลักการ:
"ใครชนะในการต่อสู้ทางอิเล็กทรอนิกส์
 ก็จะชนะสงคราม"

💰 การลงทุน:
• ประเทศพัฒนาแล้วทุ่มงบประมาณมหาศาล
• วิจัย พัฒนา ผลิตระบบ EW
• มีแนวโน้มสูงขึ้นทั้งปริมาณและคุณภาพ
''',
        visualWidget: _buildModernEWImportanceWidget(),
      ),
      LessonPage(
        title: 'ตัวอย่างการใช้งาน EW',
        content: '''
🔍 ESM (มาตรการสนับสนุน):
• ดักรับสัญญาณสื่อสารของข้าศึก
• ตรวจจับและระบุเรดาร์
• หาตำแหน่งเครื่องส่ง

⚡ ECM (มาตรการตอบโต้):
• รบกวนเรดาร์ป้องกันภัยทางอากาศ
• หลอกให้จรวดนำวิถีหลงเป้า
• ใช้ CHAFF และ FLARE

🛡️ ECCM (มาตรการต่อต้าน):
• ป้องกันการถูกดักรับสัญญาณ
• ใช้การกระโดดความถี่
• เข้ารหัสการสื่อสาร
''',
        visualWidget: _buildEWExamplesWidget(),
      ),
    ];
  }

  List<LessonPage> _ewPillarsPages() {
    return [
      // หน้าแรก: แนะนำโครงสร้าง EW
      LessonPage(
        title: 'โครงสร้างของ EW',
        content: '''
สงครามอิเล็กทรอนิกส์ แบ่งเป็น 3 องค์ประกอบหลัก:

🟡 ESM (Electronic Support Measures)
   มาตรการสนับสนุนทางอิเล็กทรอนิกส์
   "ตรวจจับ ดักรับ หาที่ตั้ง"

🔴 ECM (Electronic Countermeasures)
   มาตรการตอบโต้ทางอิเล็กทรอนิกส์
   "ก่อกวน หลอกลวง ทำให้ใช้งานไม่ได้"

🟢 ECCM (Electronic Counter-Countermeasures)
   มาตรการต่อต้านการตอบโต้ทางอิเล็กทรอนิกส์
   "ป้องกัน ต้านทาน แก้ไข"

💡 ความสัมพันธ์: วงจร EW ทำงานต่อเนื่อง
   ESM → ให้ข้อมูลสำหรับ ECM → ECCM ป้องกันระบบของเรา
''',
        visualWidget: const EWPillarsWidget(),
      ),

      // หน้าจำง่าย: ส-จ-ป
      LessonPage(
        title: '💡 จำง่ายๆ: ส-จ-ป',
        content: '''
🧠 เทคนิคช่วยจำ 3 เสาหลักของ EW:

   ส = สังเกต → ESM
   จ = จู่โจม → ECM
   ป = ป้องกัน → ECCM

📝 จำว่า "ส-จ-ป" แล้วจะไม่ลืม!

🔄 ลำดับการทำงาน:
1. สังเกต (ESM) - ค้นหาและวิเคราะห์สัญญาณข้าศึก
2. จู่โจม (ECM) - รบกวนหรือหลอกลวงข้าศึก
3. ป้องกัน (ECCM) - ปกป้องระบบของฝ่ายเรา

⭐ ทั้ง 3 ส่วนทำงานร่วมกันเป็นวงจร!
''',
        visualWidget: const EWMnemonicWidget(),
      ),

      // หน้าที่ 2: ESM โดยละเอียด
      LessonPage(
        title: 'ESM - มาตรการสนับสนุน',
        content: '''
🟡 ESM (Electronic Support Measures)

📌 คำจำกัดความ:
การค้นหา ดักรับ ระบุ บันทึก และวิเคราะห์พลังงาน
แม่เหล็กไฟฟ้าที่แผ่ออกมา เพื่อจัดทำข่าวกรอง

📊 กิจกรรมหลัก 6 อย่าง:
1) Search - ค้นหาสัญญาณ
2) Intercept - ดักรับสัญญาณ
3) DF - หาทิศทาง/ที่ตั้ง
4) Identification - ระบุชนิดสัญญาณ
5) Recording - บันทึกสัญญาณ
6) Analysis - วิเคราะห์และประเมิน

🎯 ผลผลิต → EOB (Electronic Order of Battle)
''',
        visualWidget: const ESMProcessWidget(),
      ),

      // หน้าที่ 3: ESM กับ SIGINT
      LessonPage(
        title: 'ESM กับ SIGINT',
        content: '''
ความสัมพันธ์ระหว่าง ESM กับ SIGINT:

📡 SIGINT (Signals Intelligence) ประกอบด้วย:

🔵 COMINT (Communications Intelligence)
   ข่าวกรองจากการสื่อสาร
   • ดักรับการสื่อสารวิทยุ
   • วิเคราะห์เนื้อหาข้อความ
   • หาที่ตั้งเครื่องส่ง

🔴 ELINT (Electronic Intelligence)
   ข่าวกรองจากระบบที่ไม่ใช่การสื่อสาร
   • เรดาร์ทุกประเภท
   • ระบบนำทาง
   • ระบบ IFF

💡 ESM เป็นเครื่องมือในการรวบรวม SIGINT
   "ESM ทำหน้าที่ → ได้ข้อมูล SIGINT"
''',
        visualWidget: _buildSIGINTDiagram(),
      ),

      // หน้าที่ 4: ECM โดยละเอียด
      LessonPage(
        title: 'ECM - มาตรการตอบโต้',
        content: '''
🔴 ECM (Electronic Countermeasures)

📌 คำจำกัดความ:
การปฏิบัติเพื่อป้องกัน หรือลดประสิทธิภาพ
การใช้แถบความถี่แม่เหล็กไฟฟ้าของข้าศึก

⚡ Active ECM (ใช้พลังงาน):

🔊 Jamming (การก่อกวน)
   • Spot - รบกวนความถี่เดียว
   • Barrage - รบกวนหลายความถี่พร้อมกัน
   • Sweep - กวาดรบกวนข้ามความถี่

🎭 Deception (การลวง)
   • Imitative - เลียนแบบสัญญาณ
   • Manipulative - เปลี่ยนแปลงสัญญาณ
''',
        visualWidget: const JammingTypesWidget(),
      ),

      // หน้าที่ 5: Passive ECM
      LessonPage(
        title: 'ECM แบบ Passive',
        content: '''
🔴 Passive ECM (ไม่ใช้พลังงานแผ่ออกมา):

📋 CHAFF (แถบโลหะ)
   • ตัดเป็นชิ้นเล็กๆ ตามความยาวคลื่นเรดาร์
   • สะท้อนคลื่นเรดาร์กลับไป
   • ทำให้เรดาร์สับสน หาเป้าจริงไม่ได้

🔥 FLARE (พลุความร้อน)
   • แผ่รังสี Infrared (ความร้อน)
   • หลอกจรวด Heat-Seeking
   • ดึงจรวดออกจากเป้าหมายจริง

🎯 DECOY (เป้าหลอก)
   • อุปกรณ์เลียนแบบลักษณะเป้าหมาย
   • หลอกเรดาร์ หลอกจรวด
   • เบี่ยงเบนอาวุธข้าศึกออกจากเป้าจริง
''',
        visualWidget: _buildPassiveECMWidget(),
      ),

      // หน้าที่ 6: ECCM โดยละเอียด
      LessonPage(
        title: 'ECCM - มาตรการป้องกัน',
        content: '''
🟢 ECCM (Electronic Counter-Countermeasures)

📌 คำจำกัดความ:
การป้องกันการใช้แถบความถี่แม่เหล็กไฟฟ้าของฝ่ายเรา
จากความพยายามของข้าศึกที่จะลดประสิทธิภาพ

🛡️ มาตรการป้องกัน (Protective Measures):
• EMCON - ควบคุมการแผ่คลื่น
• Radio Silence - งดใช้วิทยุ
• ใช้กำลังส่งต่ำสุดที่จำเป็น
• เสาอากาศทิศทาง

🔧 มาตรการแก้ไข (Remedial Actions):
• FHSS - กระโดดความถี่
• เพิ่มกำลังส่ง
• เปลี่ยนไปใช้ความถี่สำรอง
• รายงาน MIJI (Meaconing, Intrusion, Jamming, Interference)
''',
        visualWidget: const FHSSWidget(),
      ),

      // หน้าที่ 7: วงจร EW
      LessonPage(
        title: 'วงจร EW',
        content: '''
💫 วงจรการทำงานร่วมกันของ ESM, ECM, ECCM:

       ┌─────────────────────────┐
       │     🟡 ESM              │
       │  ตรวจจับ วิเคราะห์ ระบุ  │
       └───────────┬─────────────┘
                   │ ข้อมูลข่าวกรอง
                   ▼
       ┌─────────────────────────┐
       │     🔴 ECM              │
       │  ก่อกวน ลวง ทำให้ล้มเหลว │
       └───────────┬─────────────┘
                   │ ข้าศึกตอบโต้
                   ▼
       ┌─────────────────────────┐
       │     🟢 ECCM             │
       │  ป้องกัน ต้าน แก้ไข     │
       └───────────┬─────────────┘
                   │ วนกลับ
                   ▼
              (กลับไป ESM)

💡 ทั้ง 3 ทำงานต่อเนื่องในการรบ
''',
        visualWidget: _buildEWCycleWidget(),
      ),
    ];
  }

  // Widget แสดง Passive ECM
  Widget _buildPassiveECMWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Header
          const Text(
            'Passive ECM',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Three items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPassiveECMItem('CHAFF', '📋', 'สะท้อนเรดาร์'),
              _buildPassiveECMItem('FLARE', '🔥', 'หลอกจรวด IR'),
              _buildPassiveECMItem('DECOY', '🎯', 'เป้าหลอก'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassiveECMItem(String title, String icon, String desc) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 28)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          desc,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // Widget แสดง EW Cycle
  Widget _buildEWCycleWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ESM
          _buildEWCycleItem('ESM', Colors.amber, 'ตรวจจับ ดักรับ'),
          const Icon(Icons.arrow_downward, color: Colors.amber, size: 24),
          // ECM
          _buildEWCycleItem('ECM', Colors.red, 'ก่อกวน ลวง'),
          const Icon(Icons.arrow_downward, color: Colors.red, size: 24),
          // ECCM
          _buildEWCycleItem('ECCM', Colors.green, 'ป้องกัน แก้ไข'),
          const Icon(Icons.refresh, color: Colors.blue, size: 24),
          Text(
            'วนรอบต่อเนื่อง',
            style: TextStyle(
              color: Colors.blue[300],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEWCycleItem(String title, Color color, String desc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                title[0],
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                desc,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== บทที่ 2: สเปกตรัม ====================

  List<LessonPage> _spectrumBasicsPages() {
    return [
      LessonPage(
        title: 'สเปกตรัมแม่เหล็กไฟฟ้า',
        content: '''
สเปกตรัมแม่เหล็กไฟฟ้า คือ ช่วงความถี่ของคลื่นแม่เหล็กไฟฟ้าทั้งหมด

ใน EW เราสนใจช่วง "คลื่นวิทยุ" (Radio Frequency)

คลื่นวิทยุมีคุณสมบัติ:
• เดินทางด้วยความเร็วแสง
• ทะลุผ่านวัตถุบางชนิดได้
• สะท้อนกลับจากวัตถุบางชนิด
• ความถี่ต่ำ = ระยะไกล, ทะลุสิ่งกีดขวาง
• ความถี่สูง = ระยะสั้น, ข้อมูลมาก
''',
        visualWidget: const SpectrumBandsWidget(),
      ),
      LessonPage(
        title: 'ย่านความถี่ HF',
        content: '''
📻 HF (High Frequency)
ความถี่: 3-30 MHz

ลักษณะเด่น:
• สะท้อนชั้นบรรยากาศ (Ionosphere)
• ส่งได้ระยะไกลมาก (ข้ามทวีป)
• ไม่ต้องการ Line-of-Sight

การใช้งานทางทหาร:
• สื่อสารระยะไกล
• สื่อสารกับหน่วยที่อยู่ห่างไกล
• สำรองเมื่อดาวเทียมใช้งานไม่ได้

⚠️ ข้อเสีย: แบนด์วิดท์แคบ, ถูกดักรับง่าย
''',
        visualWidget: _buildHFPropagationWidget(),
      ),
      LessonPage(
        title: 'ย่านความถี่ VHF',
        content: '''
📻 VHF (Very High Frequency)
ความถี่: 30-300 MHz

ลักษณะเด่น:
• ต้องการ Line-of-Sight
• คุณภาพเสียงดี
• ระยะปานกลาง (30-50 กม.)

การใช้งานทางทหาร:
• วิทยุยุทธวิธีภาคพื้นดิน
• สื่อสารระหว่างหน่วยใกล้
• วิทยุการบินพลเรือน

✅ ข้อดี: น่าเชื่อถือ ใช้งานง่าย
⚠️ ข้อเสีย: ถูกภูมิประเทศกั้น
''',
        visualWidget: _buildVHFPropagationWidget(),
      ),
      LessonPage(
        title: 'ย่านความถี่ UHF และ SHF',
        content: '''
📻 UHF (Ultra High Frequency)
ความถี่: 300 MHz - 3 GHz
• สื่อสารอากาศยาน
• Data Link ทางทหาร
• ระบบดาวเทียม

📻 SHF (Super High Frequency)
ความถี่: 3-30 GHz
• เรดาร์
• สื่อสารผ่านดาวเทียม
• ไมโครเวฟ

ยิ่งความถี่สูง:
• ข้อมูลได้มาก
• ระยะสั้นลง
• ต้องการเล็งตรง
''',
        visualWidget: _buildUHFSHFWidget(),
      ),

      // หน้าสรุป: จำย่านความถี่
      LessonPage(
        title: '💡 จำย่านความถี่ง่ายๆ',
        content: '''
🧠 เทคนิคจำย่านความถี่:

📻 HF (3-30 MHz)
   "High = ไกล" → ส่งได้ไกลมาก ข้ามโลก

📻 VHF (30-300 MHz)
   "Very = ธรรมดา" → วิทยุทั่วไป FM

📻 UHF (300 MHz - 3 GHz)
   "Ultra = มือถือ" → โทรศัพท์, Wi-Fi

📻 SHF (3-30 GHz)
   "Super = เรดาร์" → ระบบเรดาร์, ดาวเทียม

🎯 แตะที่ช่องด้านล่างเพื่อดูรายละเอียด!
''',
        visualWidget: const FrequencyBandsMemoryWidget(),
      ),
    ];
  }

  List<LessonPage> _spectrumSimPages() {
    return [
      LessonPage(
        title: 'การอ่านสเปกตรัม',
        content: '''
Spectrum Analyzer แสดง:

แกนนอน (X): ความถี่ (MHz/GHz)
แกนตั้ง (Y): กำลังสัญญาณ (dBm)

สิ่งที่มองหา:
📍 ยอดสัญญาณ (Peak) = มีการส่งสัญญาณ
📍 ความกว้าง (Bandwidth) = ประเภทสัญญาณ
📍 รูปแบบ (Pattern) = ลักษณะเฉพาะ

ฝึกระบุ:
• สัญญาณมิตร vs ศัตรู
• ประเภทการมอดูเลชัน
• ความผิดปกติในสเปกตรัม
''',
        visualWidget: _buildSpectrumAnalyzerWidget(),
      ),

      // หน้าที่ 2: วิเคราะห์รูปคลื่น (Interactive)
      LessonPage(
        title: '🎮 วิเคราะห์รูปคลื่น',
        content: '''
📊 Signal Waveform Analyzer

เรียนรู้รูปคลื่นสัญญาณประเภทต่างๆ!

📍 ประเภทคลื่น:
• Sine - คลื่นไซน์ (พื้นฐาน)
• Square - คลื่นสี่เหลี่ยม (ดิจิตอล)
• Pulse - พัลส์ (เรดาร์)
• Noise - สัญญาณรบกวน

📍 ลองทดลอง:
1. เลือกประเภทคลื่น
2. ปรับความถี่และแอมพลิจูด
3. เปิด Noise ดูผลกระทบ
4. เปิด Jamming ดูการรบกวน

เล่นเลย! 👇
''',
        visualWidget: const SignalWaveformWidget(),
      ),
    ];
  }

  // ==================== บทที่ 3: ESM พื้นฐาน ====================

  List<LessonPage> _esmBasicsPages() {
    return [
      // หน้าที่ 1: แนะนำ ESM
      LessonPage(
        title: 'ESM คืออะไร?',
        content: '''
ESM = Electronic Support Measures
มาตรการสนับสนุนทางอิเล็กทรอนิกส์

📌 คำจำกัดความ:
การค้นหา ดักรับ ระบุ บันทึก และวิเคราะห์
พลังงานแม่เหล็กไฟฟ้าที่แผ่ออกมา

🎯 วัตถุประสงค์:
1. จัดทำข่าวกรองสัญญาณ
2. สนับสนุนการวางแผน ECM
3. สร้าง EOB (Electronic Order of Battle)

📊 กิจกรรมหลัก 6 อย่าง:
1️⃣ Search - ค้นหา
2️⃣ Intercept - ดักรับ
3️⃣ DF - หาทิศทาง
4️⃣ Identification - ระบุ
5️⃣ Recording - บันทึก
6️⃣ Analysis - วิเคราะห์
''',
        visualWidget: const ESMProcessWidget(),
      ),

      // หน้าที่ 2: Search (ค้นหา)
      LessonPage(
        title: '1. Search (ค้นหา)',
        content: '''
🔍 การค้นหา (Search)

📌 คำจำกัดความ:
การกวาดตรวจแถบความถี่แม่เหล็กไฟฟ้า
เพื่อค้นหาสัญญาณที่สนใจ

📊 รูปแบบการค้นหา:
• ค้นหาทั่วไป (General Search)
  → กวาดทุกช่วงความถี่
• ค้นหาเจาะจง (Specific Search)
  → เน้นความถี่ที่คาดว่าข้าศึกใช้

⚙️ พารามิเตอร์ที่กำหนด:
• ช่วงความถี่ที่ค้นหา
• ความเร็วในการกวาด
• เกณฑ์ตรวจจับสัญญาณ

💡 เป้าหมาย: หาสัญญาณที่ไม่รู้จักมาก่อน
''',
        visualWidget: _buildESMSearchWidget(),
      ),

      // หน้าที่ 3: Intercept (ดักรับ)
      LessonPage(
        title: '2. Intercept (ดักรับ)',
        content: '''
📡 การดักรับ (Intercept)

📌 คำจำกัดความ:
การรับสัญญาณที่ค้นพบมาเพื่อวิเคราะห์

🎯 ขั้นตอน:
1. ปรับจูนเครื่องรับไปที่ความถี่เป้าหมาย
2. ปรับ Bandwidth ให้เหมาะสม
3. รับและบันทึกสัญญาณ

📊 ข้อมูลที่ได้:
• ความถี่ที่แน่นอน
• ความแรงสัญญาณ
• ลักษณะการมอดูเลชัน
• ช่วงเวลาที่ส่ง

⚠️ ความท้าทาย:
• สัญญาณอาจกระโดดความถี่ (FHSS)
• ช่วงเวลาส่งสั้น (Burst)
• หลายสัญญาณทับซ้อน
''',
        visualWidget: _buildESMInterceptWidget(),
      ),

      // หน้าที่ 4: Direction Finding (DF)
      LessonPage(
        title: '3. Direction Finding (DF)',
        content: '''
🧭 การหาทิศทาง (Direction Finding)

📌 คำจำกัดความ:
การหาทิศทางและ/หรือตำแหน่งของเครื่องส่ง

📊 เทคนิคที่ใช้:
• เสาอากาศหมุน
• Interferometer
• Watson-Watt
• Doppler DF

🎯 วิธี Triangulation:
1. วัด Bearing จากสถานี A
2. วัด Bearing จากสถานี B
3. จุดตัด = ตำแหน่งเครื่องส่ง

📈 ความแม่นยำขึ้นกับ:
• ระยะห่างระหว่างสถานี DF
• คุณภาพเสาอากาศ
• สภาพภูมิประเทศ
• ระยะถึงเป้าหมาย
''',
        visualWidget: _buildDFWidget(),
      ),

      // หน้าที่ 5: Identification (ระบุ)
      LessonPage(
        title: '4. Identification (ระบุ)',
        content: '''
🏷️ การระบุ (Identification)

📌 คำจำกัดความ:
การวิเคราะห์ลักษณะสัญญาณเพื่อระบุชนิด

📊 พารามิเตอร์ที่วิเคราะห์:
สัญญาณวิทยุ (COMINT):
• ภาษาที่ใช้
• รหัสเรียกขาน
• ขั้นตอนการสื่อสาร
• ประเภทการมอดูเลชัน

สัญญาณเรดาร์ (ELINT):
• PRF (Pulse Repetition Frequency)
• PW (Pulse Width)
• ความถี่ปฏิบัติการ
• รูปแบบการกวาด

🎯 ผลลัพธ์ → ระบุ:
• ชนิดอุปกรณ์
• รุ่น/แบบ
• ประเทศผู้ผลิต
• หน่วยที่ใช้
''',
        visualWidget: _buildESMIdentificationWidget(),
      ),

      // หน้าที่ 6: Recording & Analysis
      LessonPage(
        title: '5-6. Recording & Analysis',
        content: '''
📼 การบันทึก (Recording)

บันทึกสัญญาณเพื่อ:
• วิเคราะห์ภายหลัง
• เก็บเป็นหลักฐาน
• สร้างฐานข้อมูล

📊 การวิเคราะห์ (Analysis)

ขั้นตอน:
1️⃣ รวบรวมข้อมูลทั้งหมด
2️⃣ เปรียบเทียบกับฐานข้อมูล
3️⃣ ประเมินความหมาย
4️⃣ จัดทำรายงาน

🎯 ผลผลิต → EOB:
Electronic Order of Battle
• รายการอุปกรณ์ EW ข้าศึก
• ที่ตั้งและการวางกำลัง
• ขีดความสามารถ
• ข้อจำกัด/จุดอ่อน
''',
        visualWidget: _buildESMAnalysisWidget(),
      ),
    ];
  }

  // Widget สำหรับ ESM Search
  Widget _buildESMSearchWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🔍 กวาดค้นหาสัญญาณ',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Spectrum bar
          Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.green, Colors.yellow, Colors.orange, Colors.red],
              ),
            ),
            child: const Center(
              child: Text(
                'HF ←────── VHF ─────── UHF ─────→ SHF',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'กวาดทุกช่วงความถี่เพื่อหาสัญญาณ',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // Widget สำหรับ ESM Intercept
  Widget _buildESMInterceptWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '📡 ดักรับสัญญาณ',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInterceptItem('ความถี่', '147.5 MHz'),
              _buildInterceptItem('ความแรง', '-65 dBm'),
              _buildInterceptItem('Modulation', 'FM'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInterceptItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // Widget สำหรับ DF
  Widget _buildDFWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🧭 Triangulation',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Simple triangulation diagram
          SizedBox(
            height: 100,
            child: CustomPaint(
              painter: _TriangulationPainter(),
              size: const Size(200, 100),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'จุดตัดของ Bearing = ตำแหน่งเครื่องส่ง',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // Widget สำหรับ Identification
  Widget _buildESMIdentificationWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🏷️ ระบุชนิดสัญญาณ',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildIDColumn('COMINT', ['ภาษา', 'รหัสเรียก', 'ขั้นตอน']),
              ),
              Container(width: 1, height: 60, color: Colors.grey),
              Expanded(
                child: _buildIDColumn('ELINT', ['PRF', 'PW', 'Freq']),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIDColumn(String title, List<String> items) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.amber, fontSize: 12)),
        const SizedBox(height: 6),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(item, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
        )),
      ],
    );
  }

  // Widget สำหรับ Analysis
  Widget _buildESMAnalysisWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.analytics, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text(
                'สร้าง EOB',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBasicEOBRow('📡', 'ระบบ', 'Type 123 Radar'),
                _buildBasicEOBRow('📍', 'ที่ตั้ง', 'Grid XY 1234'),
                _buildBasicEOBRow('⚡', 'สถานะ', 'Active'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicEOBRow(String icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Text('$label: ', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  List<LessonPage> _sigintPages() {
    return [
      // หน้าที่ 1: แนะนำ SIGINT
      LessonPage(
        title: 'SIGINT คืออะไร?',
        content: '''
SIGINT = Signals Intelligence
ข่าวกรองสัญญาณ

📌 คำจำกัดความ:
ข่าวกรองที่ได้จากการดักรับและวิเคราะห์
สัญญาณแม่เหล็กไฟฟ้าของข้าศึก

📊 แบ่งเป็น 2 ประเภทหลัก:

🔵 COMINT (Communications Intelligence)
   ข่าวกรองจากการสื่อสาร
   → ดักรับการพูดคุย/ข้อความ

🔴 ELINT (Electronic Intelligence)
   ข่าวกรองจากระบบที่ไม่ใช่การสื่อสาร
   → วิเคราะห์เรดาร์ ระบบนำวิถี

💡 ความสัมพันธ์:
ESM เป็นเครื่องมือในการรวบรวม SIGINT
"ESM ทำหน้าที่ → ได้ข้อมูล SIGINT"
''',
        visualWidget: _buildSIGINTDiagram(),
      ),

      // หน้าที่ 2: COMINT โดยละเอียด
      LessonPage(
        title: 'COMINT - ข่าวกรองการสื่อสาร',
        content: '''
🔵 COMINT (Communications Intelligence)

📌 เป้าหมาย:
สัญญาณการสื่อสารทุกประเภท

📡 ระบบที่ดักรับ:
• วิทยุสื่อสาร HF/VHF/UHF
• โทรศัพท์ (สาย/ไร้สาย)
• การสื่อสารข้อมูล (Data)
• ระบบดาวเทียมสื่อสาร

📊 ข้อมูลที่ได้รับ:
• เนื้อหาการสื่อสาร (ถ้าถอดรหัสได้)
• รหัสเรียกขาน (Call Signs)
• ขั้นตอนการสื่อสาร
• ความถี่ที่ใช้
• ที่ตั้งเครื่องส่ง (จาก DF)

🎯 ประโยชน์:
รู้แผนการ ความตั้งใจ การเคลื่อนไหวของข้าศึก
''',
        visualWidget: _buildCOMINTWidget(),
      ),

      // หน้าที่ 3: ELINT โดยละเอียด
      LessonPage(
        title: 'ELINT - ข่าวกรองอิเล็กทรอนิกส์',
        content: '''
🔴 ELINT (Electronic Intelligence)

📌 เป้าหมาย:
สัญญาณที่ไม่ใช่การสื่อสาร

📡 ระบบที่วิเคราะห์:
• เรดาร์ค้นหา (Search Radar)
• เรดาร์ติดตาม (Tracking Radar)
• เรดาร์ควบคุมการยิง (Fire Control)
• ระบบนำทาง (Navigation Aids)
• ระบบ IFF
• ระบบนำวิถีจรวด

📊 พารามิเตอร์ที่วิเคราะห์:
• PRF - ความถี่ซ้ำพัลส์
• PW - ความกว้างพัลส์
• RF - ความถี่ปฏิบัติการ
• Scan Rate - อัตราการกวาด
• Antenna Pattern - รูปแบบเสาอากาศ

🎯 ประโยชน์:
รู้ขีดความสามารถ จุดอ่อน วิธีตอบโต้
''',
        visualWidget: _buildELINTWidget(),
      ),

      // หน้าที่ 4: เปรียบเทียบ
      LessonPage(
        title: 'COMINT vs ELINT',
        content: '''
📊 เปรียบเทียบ COMINT และ ELINT:

         │ COMINT        │ ELINT
─────────┼───────────────┼──────────────
เป้าหมาย │ การสื่อสาร    │ เรดาร์/ระบบ
สัญญาณ   │ เสียง ข้อมูล  │ พัลส์เรดาร์
วิเคราะห์│ เนื้อหา ภาษา  │ PRF PW RF
ประโยชน์ │ รู้แผนการ     │ รู้ขีดความสามารถ

🔗 ทำงานร่วมกัน:
• COMINT บอก "กำลังจะทำอะไร"
• ELINT บอก "มีอะไรบ้าง"

💡 รวมกัน = ภาพข่าวกรองที่สมบูรณ์
   → สนับสนุนการตัดสินใจของ ผบ.
''',
        visualWidget: _buildCOMINTvsELINT(),
      ),

      // หน้าที่ 5: ฝึกระบุสัญญาณ (Interactive)
      LessonPage(
        title: '🎮 ฝึกล่าสัญญาณ',
        content: '''
🎯 ESM Signal Hunter

ฝึกค้นหาและระบุสัญญาณข้าศึกในสนามรบ!

📍 วิธีเล่น:
1. กด "เริ่มสแกน" เพื่อเปิดเรดาร์
2. รอให้เรดาร์กวาดพบสัญญาณ
3. แตะที่สัญญาณเพื่อระบุประเภท
4. เก็บคะแนนจากการระบุถูกต้อง

💡 เคล็ดลับ:
• สัญญาณเรดาร์ = สีฟ้า
• สัญญาณสื่อสาร = สีน้ำเงิน
• สัญญาณรบกวน = สีแดง

ลองฝึกเลย! 👇
''',
        visualWidget: const ESMSignalHunterWidget(),
      ),
    ];
  }

  // Widget สำหรับ COMINT
  Widget _buildCOMINTWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone_in_talk, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'COMINT',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildCOMINTChip('📻 วิทยุ'),
              _buildCOMINTChip('📱 โทรศัพท์'),
              _buildCOMINTChip('💬 ข้อความ'),
              _buildCOMINTChip('📡 ดาวเทียม'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCOMINTChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }

  // Widget สำหรับ ELINT
  Widget _buildELINTWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.radar, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text(
                'ELINT',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildELINTParam('PRF', '1000 Hz'),
              _buildELINTParam('PW', '2 μs'),
              _buildELINTParam('RF', '10 GHz'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildELINTParam(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // ==================== บทที่ 4: ECM พื้นฐาน ====================

  List<LessonPage> _jammingBasicsPages() {
    return [
      // หน้าที่ 1: แนะนำ ECM
      LessonPage(
        title: 'ECM คืออะไร?',
        content: '''
ECM = Electronic Countermeasures
มาตรการตอบโต้ทางอิเล็กทรอนิกส์

📌 คำจำกัดความ:
การปฏิบัติเพื่อป้องกัน หรือลดประสิทธิภาพ
การใช้แถบความถี่แม่เหล็กไฟฟ้าของข้าศึก

📊 แบ่งเป็น 2 ประเภทหลัก:

⚡ Active ECM (ใช้พลังงาน):
• Jamming - การก่อกวน
• Deception - การลวง

🛡️ Passive ECM (ไม่ใช้พลังงาน):
• CHAFF - แถบโลหะสะท้อนเรดาร์
• FLARE - พลุความร้อน
• DECOY - เป้าหลอก
''',
        visualWidget: _buildECMOverviewWidget(),
      ),

      // หน้าที่ 2: การก่อกวน
      LessonPage(
        title: 'การก่อกวน (Jamming)',
        content: '''
🔊 การก่อกวน (Jamming)

📌 คำจำกัดความ:
การส่งสัญญาณพลังงานแม่เหล็กไฟฟ้าโดยเจตนา
เพื่อทำให้ระบบข้าศึกใช้งานไม่ได้

📊 หลักการ:
ส่งสัญญาณรบกวนที่แรงกว่าสัญญาณเดิม
ทำให้เครื่องรับไม่สามารถรับสัญญาณที่ต้องการได้

⚙️ ตัววัดประสิทธิภาพ:
J/S Ratio (Jamming-to-Signal)
= กำลังสัญญาณรบกวน / กำลังสัญญาณเดิม

💡 J/S > 1 = รบกวนได้ผล
   ยิ่ง J/S สูง = รบกวนได้ผลยิ่งดี
''',
        visualWidget: _buildJammingConceptWidget(),
      ),

      // หน้าที่ 3: ประเภทการก่อกวน
      LessonPage(
        title: 'ประเภทการก่อกวน',
        content: '''
📊 การก่อกวน 3 แบบหลัก:

🎯 Spot Jamming (ก่อกวนจุด)
• รบกวนความถี่เดียว/ช่วงแคบ
• ใช้กำลังน้อยแต่มีประสิทธิภาพสูง
• ต้องรู้ความถี่เป้าหมายแม่นยำ

📊 Barrage Jamming (ก่อกวนกว้าง)
• รบกวนช่วงความถี่กว้าง
• ใช้กำลังมาก
• รบกวนได้หลายเป้าพร้อมกัน
• ไม่ต้องรู้ความถี่แน่นอน

🔄 Sweep Jamming (ก่อกวนกวาด)
• รบกวนโดยเลื่อนความถี่ไปมา
• ใช้กำลังปานกลาง
• เหมาะกับเป้าที่เปลี่ยนความถี่
''',
        visualWidget: const JammingTypesWidget(),
      ),

      // หน้าสาธิต: ลองรบกวนสัญญาณ
      LessonPage(
        title: '🎮 ลองรบกวนสัญญาณ!',
        content: '''
🧪 ทดลองการรบกวนสัญญาณแบบโต้ตอบ!

📍 ดูจากภาพด้านล่าง:
• สีแดง = สัญญาณข้าศึก
• สีส้ม = สัญญาณรบกวน (Jamming)

🎯 กดปุ่ม "เริ่มรบกวน" เพื่อดูผล:
เมื่อเราส่งสัญญาณรบกวนที่ความถี่เดียวกัน
ผู้รับจะไม่สามารถแยกแยะสัญญาณได้

💡 สังเกต:
• สัญญาณปกติ = คลื่นเรียบ
• สัญญาณถูกรบกวน = คลื่นผิดเพี้ยน
''',
        visualWidget: const JammingProcessWidget(),
      ),

      // หน้าที่ 4: เมื่อไรใช้การก่อกวน
      LessonPage(
        title: 'เมื่อไรใช้การก่อกวน?',
        content: '''
✅ ใช้การก่อกวนเมื่อ:

🎯 ตัดการสื่อสารข้าศึก
   → ก่อกวนวิทยุสั่งการ/รายงาน

🎯 ป้องกันจากเรดาร์
   → ก่อกวนเรดาร์ค้นหา/ติดตาม

🎯 ป้องกันจากจรวดนำวิถี
   → ก่อกวนระบบนำวิถี

⚠️ ข้อควรระวัง:
• เปิดเผยตำแหน่งเรา (Active Emission)
• อาจกระทบสัญญาณฝ่ายเรา
• ใช้พลังงานสูง
• ข้าศึกอาจใช้ Homing on Jamming
''',
        visualWidget: _buildWhenToJamWidget(),
      ),
    ];
  }

  // Widget สำหรับ ECM Overview
  Widget _buildECMOverviewWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🔴 ECM',
            style: TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildECMTypeBox('⚡ Active', ['Jamming', 'Deception'], Colors.orange)),
              const SizedBox(width: 8),
              Expanded(child: _buildECMTypeBox('🛡️ Passive', ['Chaff', 'Flare', 'Decoy'], Colors.blue)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildECMTypeBox(String title, List<String> items, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Text(item, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
          )),
        ],
      ),
    );
  }

  List<LessonPage> _jammingTypesPages() {
    return [
      // หน้าที่ 1: เปรียบเทียบ Jamming
      LessonPage(
        title: 'เปรียบเทียบการก่อกวน',
        content: '''
📊 เปรียบเทียบการก่อกวน 3 แบบ:

         │ Spot    │ Barrage │ Sweep
─────────┼─────────┼─────────┼────────
กำลังส่ง │ น้อย   │ มาก    │ ปานกลาง
ความแม่น │ สูง    │ ต่ำ    │ ปานกลาง
จำนวนเป้า│ 1 เป้า │ หลายเป้า│ หลายเป้า
ต้องรู้ความถี่│ ต้องรู้│ ไม่ต้อง│ ไม่ต้อง

🎯 เลือกใช้:
• รู้ความถี่แน่นอน → Spot
• ไม่รู้ความถี่ → Barrage
• เป้าเปลี่ยนความถี่ช้า → Sweep
• เป้ากระโดดความถี่เร็ว → Barrage
''',
        visualWidget: _buildJammingComparisonWidget(),
      ),

      // หน้าที่ 2: การลวง (Deception)
      LessonPage(
        title: 'การลวง (Deception)',
        content: '''
🎭 การลวง (Deception)

📌 คำจำกัดความ:
การทำให้ข้าศึกเข้าใจผิดโดยการส่งสัญญาณหลอก

📊 แบ่งเป็น 2 ประเภท:

🎭 Imitative Deception (การลวงเลียน)
   ปลอมแปลงสัญญาณของข้าศึก
   • ส่งคำสั่งปลอม
   • แทรกข้อมูลเท็จ
   • สร้างความสับสน

🔄 Manipulative Deception (การลวงเล่ห์)
   เปลี่ยนแปลงลักษณะสัญญาณที่แท้จริง
   • บิดเบือนตำแหน่ง
   • ปลอมขนาด/ความเร็ว
   • หลอกเซ็นเซอร์ข้าศึก
''',
        visualWidget: _buildDeceptionWidget(),
      ),

      // หน้าที่ 3: Passive ECM
      LessonPage(
        title: 'Passive ECM',
        content: '''
🛡️ Passive ECM (ไม่แผ่พลังงาน)

📋 CHAFF (แถบโลหะ)
• ตัดแถบโลหะตามความยาวคลื่นเรดาร์
• สะท้อนคลื่นเรดาร์กลับไป
• สร้าง False Target หลายเป้า
• ใช้ป้องกันเรดาร์ค้นหา/ติดตาม

🔥 FLARE (พลุความร้อน)
• แผ่รังสี Infrared (ความร้อน)
• หลอกจรวด Heat-Seeking
• ดึงจรวดออกจากเป้าจริง
• ใช้กับอากาศยาน/ยานรบ

🎯 DECOY (เป้าหลอก)
• อุปกรณ์เลียนแบบเป้าหมายจริง
• ปลอมลักษณะ Radar Cross Section
• ดึงดูดจรวด/อาวุธนำวิถี
''',
        visualWidget: _buildPassiveECMWidget(),
      ),

      // หน้าที่ 4: การประสาน ECM
      LessonPage(
        title: 'การประสาน ECM',
        content: '''
⚙️ หลักการใช้ ECM อย่างมีประสิทธิภาพ:

📌 การประสานงาน:
• ประสาน ESM เพื่อหาเป้าหมาย
• ประสาน ECCM เพื่อป้องกันตนเอง
• แจ้งหน่วยมิตรก่อนใช้ ECM

📊 ลำดับความสำคัญเป้าหมาย:
1️⃣ ระบบ C³I ของข้าศึก
2️⃣ เรดาร์ป้องกันภัยทางอากาศ
3️⃣ เรดาร์ควบคุมการยิง
4️⃣ ระบบสื่อสารสำคัญ

⚠️ ข้อพิจารณา:
• ใช้กำลังต่ำสุดที่ได้ผล
• จำกัดเวลาแผ่คลื่น
• เตรียมแผนสำรองเสมอ
''',
        visualWidget: _buildECMCoordinationWidget(),
      ),

      // หน้าที่ 5: ฝึกรบกวนสัญญาณ (Interactive)
      LessonPage(
        title: '🎮 ฝึกสงคราม Jamming',
        content: '''
🔊 ECM Jamming Warfare

ทดลองรบกวนสัญญาณข้าศึก!

📍 วิธีเล่น:
1. เลือกประเภทการรบกวน
   • Spot - รบกวนจุดเดียว
   • Barrage - รบกวนกว้าง
   • Sweep - กวาดรบกวน
2. ปรับกำลังส่ง (Power)
3. กด "เริ่มรบกวน"
4. สังเกตผลกระทบต่อสัญญาณข้าศึก

💡 เป้าหมาย:
รบกวนสัญญาณข้าศึกทั้ง 3 ให้สำเร็จ!

เริ่มภารกิจ! 👇
''',
        visualWidget: const ECMJammingWarfareWidget(),
      ),
    ];
  }

  // Widget สำหรับ Deception
  Widget _buildDeceptionWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🎭 Deception',
            style: TextStyle(
              color: Colors.purple,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDeceptionType('Imitative', 'เลียนแบบ', '📻→📻'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDeceptionType('Manipulative', 'บิดเบือน', '📍→❌'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeceptionType(String title, String desc, String icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.purple, fontSize: 11, fontWeight: FontWeight.bold)),
          Text(desc, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
        ],
      ),
    );
  }

  // Widget สำหรับ ECM Coordination
  Widget _buildECMCoordinationWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '⚙️ ECM Coordination',
            style: TextStyle(
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCoordItem('ESM', '🔍', 'หาเป้า'),
              const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
              _buildCoordItem('ECM', '🔊', 'โจมตี'),
              const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
              _buildCoordItem('ECCM', '🛡️', 'ป้องกัน'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoordItem(String title, String icon, String desc) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        Text(desc, style: TextStyle(color: Colors.grey[400], fontSize: 9)),
      ],
    );
  }

  // ==================== บทที่ 5: ECCM พื้นฐาน ====================

  List<LessonPage> _eccmBasicsPages() {
    return [
      // หน้าที่ 1: แนะนำ ECCM
      LessonPage(
        title: 'ECCM คืออะไร?',
        content: '''
ECCM = Electronic Counter-Countermeasures
มาตรการต่อต้านการตอบโต้ทางอิเล็กทรอนิกส์

📌 คำจำกัดความ:
การป้องกันการใช้แถบความถี่แม่เหล็กไฟฟ้าของฝ่ายเรา
จากความพยายามของข้าศึกที่จะลดประสิทธิภาพ

📊 แบ่งเป็น 2 ประเภทหลัก:

🛡️ Protective Measures (มาตรการป้องกัน)
   ดำเนินการก่อนถูกโจมตี
   → ป้องกันไม่ให้ข้าศึกรบกวนได้

🔧 Remedial Actions (มาตรการแก้ไข)
   ดำเนินการหลังถูกโจมตี
   → ฟื้นฟูการใช้งานให้กลับมาปกติ
''',
        visualWidget: _buildECCMConceptWidget(),
      ),

      // หน้าที่ 2: Protective Measures
      LessonPage(
        title: 'มาตรการป้องกัน',
        content: '''
🛡️ Protective Measures (มาตรการป้องกัน)

📵 EMCON (Emission Control)
   • ควบคุม/จำกัดการแผ่คลื่น
   • Radio Silence - งดใช้วิทยุ
   • ลดการแผ่คลื่นที่ไม่จำเป็น

📻 เทคนิคทางวิทยุ:
   • ใช้กำลังส่งต่ำสุดที่จำเป็น
   • ใช้เสาอากาศทิศทาง
   • ส่งสัญญาณสั้นที่สุด
   • เปลี่ยนความถี่บ่อย

🔒 SIGSEC (Signal Security):
   • COMSEC - ความปลอดภัยการสื่อสาร
   • TRANSEC - ความปลอดภัยการส่ง
   • เข้ารหัส, รหัสเรียกขาน
''',
        visualWidget: _buildProtectiveMeasuresWidget(),
      ),

      // หน้าที่ 3: Remedial Actions
      LessonPage(
        title: 'มาตรการแก้ไข',
        content: '''
🔧 Remedial Actions (มาตรการแก้ไข)

เมื่อถูก Jamming:
1️⃣ เปลี่ยนไปใช้ความถี่สำรอง
2️⃣ เพิ่มกำลังส่ง
3️⃣ ใช้ FHSS (กระโดดความถี่)
4️⃣ ย้ายตำแหน่งเสาอากาศ
5️⃣ ใช้ช่องทางสื่อสารสำรอง
6️⃣ รายงาน MIJI

เมื่อถูก Deception:
• ยืนยันตัวตนผู้ส่ง
• ใช้ Authentication Code
• เปรียบเทียบข้อมูลจากหลายแหล่ง

⚠️ สำคัญ: รายงานทันทีที่พบการรบกวน!
''',
        visualWidget: _buildRemedialActionsWidget(),
      ),

      // หน้าที่ 4: MIJI Reporting
      LessonPage(
        title: 'การรายงาน MIJI',
        content: '''
📋 MIJI = Meaconing, Intrusion, Jamming, Interference

📌 ความหมาย:
M - Meaconing: การส่งสัญญาณนำทางปลอม
I - Intrusion: การบุกรุกเข้าข่ายสื่อสาร
J - Jamming: การก่อกวนสัญญาณ
I - Interference: การรบกวน (อาจไม่ตั้งใจ)

📊 ข้อมูลที่ต้องรายงาน:
• วัน-เวลาที่พบ
• ความถี่ที่ถูกรบกวน
• ลักษณะการรบกวน
• ผลกระทบต่อการปฏิบัติ
• การแก้ไขที่ดำเนินการ

🎯 รายงานไปที่:
ผบ.หน่วย → สธ.3/สธ.4 → ศูนย์ EW
''',
        visualWidget: _buildMIJIWidget(),
      ),
    ];
  }

  // Widget สำหรับ Protective Measures
  Widget _buildProtectiveMeasuresWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🛡️ Protective Measures',
            style: TextStyle(
              color: Colors.green,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildProtectiveItem('📵', 'EMCON'),
              _buildProtectiveItem('📻', 'Technique'),
              _buildProtectiveItem('🔒', 'SIGSEC'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProtectiveItem(String icon, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
      ],
    );
  }

  // Widget สำหรับ Remedial Actions
  Widget _buildRemedialActionsWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🔧 Remedial Actions',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _buildRemedialChip('เปลี่ยนความถี่'),
              _buildRemedialChip('เพิ่มกำลังส่ง'),
              _buildRemedialChip('FHSS'),
              _buildRemedialChip('รายงาน MIJI'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRemedialChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
    );
  }

  // Widget สำหรับ MIJI
  Widget _buildMIJIWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '📋 MIJI Reporting',
            style: TextStyle(
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMIJIItem('M', 'Meaconing', Colors.purple),
              _buildMIJIItem('I', 'Intrusion', Colors.orange),
              _buildMIJIItem('J', 'Jamming', Colors.red),
              _buildMIJIItem('I', 'Interference', Colors.yellow),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMIJIItem(String letter, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
          child: Center(
            child: Text(letter, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 8)),
      ],
    );
  }

  List<LessonPage> _fhssPages() {
    return [
      // หน้าที่ 1: แนะนำ FHSS
      LessonPage(
        title: 'FHSS คืออะไร?',
        content: '''
FHSS = Frequency Hopping Spread Spectrum
การกระโดดความถี่แบบกระจายสเปกตรัม

📌 หลักการ:
• เปลี่ยนความถี่อย่างรวดเร็ว
• ตามรูปแบบที่กำหนดไว้ (Hopping Pattern)
• เครื่องส่ง-รับใช้รูปแบบเดียวกัน

🛡️ ทำไมจึงป้องกันการรบกวน:
❌ ข้าศึกรบกวนความถี่หนึ่ง
🔄 แต่เราเปลี่ยนไปความถี่อื่นแล้ว
✅ การสื่อสารยังทำงานได้

⚡ ความเร็ว:
กระโดดได้ 100-1000 ครั้ง/วินาที!
ข้าศึกตามไม่ทัน
''',
        visualWidget: const FHSSWidget(),
      ),

      // หน้าที่ 2: ข้อดี-ข้อเสีย
      LessonPage(
        title: 'ข้อดี-ข้อเสียของ FHSS',
        content: '''
✅ ข้อดี:
• ทนต่อการก่อกวน (Anti-Jam)
• ยากต่อการดักรับ (LPI)
• ยากต่อการติดตาม
• รองรับหลายผู้ใช้พร้อมกัน (CDMA)
• ลด Multipath Fading

⚠️ ข้อเสีย:
• ต้องซิงโครไนซ์เวลาที่แม่นยำ
• อุปกรณ์ซับซ้อน ราคาสูง
• ต้องแจกจ่าย Hopping Key
• Bandwidth รวมกว้างกว่าปกติ

📻 ตัวอย่างการใช้งาน:
• วิทยุ SINCGARS
• วิทยุ HAVEQUICK
• WiFi และ Bluetooth
''',
        visualWidget: _buildFHSSProsConsWidget(),
      ),

      // หน้าที่ 3: EMCON
      LessonPage(
        title: 'EMCON - ควบคุมการแผ่คลื่น',
        content: '''
📵 EMCON (Emission Control)

📌 คำจำกัดความ:
การควบคุมการแผ่พลังงานแม่เหล็กไฟฟ้า
เพื่อป้องกันการตรวจจับและดักรับ

📊 ระดับของ EMCON:

🔴 EMCON Alpha (เข้มงวดสุด)
   งดแผ่คลื่นทุกประเภท

🟡 EMCON Bravo (ปานกลาง)
   จำกัดเฉพาะบางระบบ

🟢 EMCON Charlie (ผ่อนคลาย)
   อนุญาตตามความจำเป็น

💡 หลักการ:
"ไม่แผ่คลื่น = ไม่ถูกตรวจจับ = ไม่ถูกโจมตี"
''',
        visualWidget: _buildEMCONWidget(),
      ),

      // หน้าที่ 4: ฝึกป้องกันการรบกวน (Interactive)
      LessonPage(
        title: '🎮 ฝึกป้องกัน ECCM',
        content: '''
🛡️ ECCM Shield Defense

ทดสอบระบบป้องกันการรบกวน!

📍 วิธีเล่น:
1. เลือกเทคนิค ECCM
   • FHSS - กระโดดความถี่
   • Spread Spectrum - กระจายสเปกตรัม
   • Adaptive Filter - กรองสัญญาณ
   • Power Control - ปรับกำลัง
2. กด "เปิดการป้องกัน"
3. สังเกตการป้องกันการโจมตี

💡 เป้าหมาย:
บล็อกการโจมตีให้มากที่สุด!

เริ่มเลย! 👇
''',
        visualWidget: const ECCMShieldDefenseWidget(),
      ),
    ];
  }

  // Widget สำหรับ EMCON
  Widget _buildEMCONWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '📵 EMCON Levels',
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildEMCONLevel('Alpha', 'งดแผ่คลื่นทั้งหมด', Colors.red),
          const SizedBox(height: 6),
          _buildEMCONLevel('Bravo', 'จำกัดบางระบบ', Colors.amber),
          const SizedBox(height: 6),
          _buildEMCONLevel('Charlie', 'ตามความจำเป็น', Colors.green),
        ],
      ),
    );
  }

  Widget _buildEMCONLevel(String level, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(level, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(width: 8),
          Text(desc, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
        ],
      ),
    );
  }

  // ==================== บทที่ 6: วิทยุยุทธวิธี ====================

  List<LessonPage> _tacticalRadioPages() {
    return [
      LessonPage(
        title: 'วิทยุยุทธวิธีคืออะไร?',
        content: '''
วิทยุยุทธวิธี (Tactical Radio) คือ ระบบสื่อสารไร้สายที่ใช้ในภารกิจทางทหาร

คุณสมบัติสำคัญ:
• ทนทานต่อสภาพแวดล้อม
• พกพาได้
• รองรับการเข้ารหัส
• ทนต่อการรบกวน

ใช้ในระดับ:
🎖️ ระดับยุทธการ (กองพัน-กรม)
🎖️ ระดับยุทธวิธี (หมู่-กองร้อย)
🎖️ ระดับปฏิบัติการพิเศษ
''',
        visualWidget: _buildTacticalRadioOverviewWidget(),
      ),
      LessonPage(
        title: 'ประเภทวิทยุยุทธวิธี',
        content: '''
แบ่งตามย่านความถี่:

📻 วิทยุ HF (3-30 MHz)
• ระยะไกลมาก (ข้ามทวีป)
• ไม่ต้องมี Line-of-Sight
• ใช้สื่อสารระหว่างหน่วยใหญ่
• ตัวอย่าง: AN/PRC-150

📻 วิทยุ VHF (30-300 MHz)
• ระยะปานกลาง (30-50 กม.)
• คุณภาพเสียงดี
• ใช้ในระดับกองพัน-กองร้อย
• ตัวอย่าง: AN/PRC-77

📻 วิทยุ UHF (300 MHz - 3 GHz)
• ระยะสั้น (ภายในระยะมองเห็น)
• ข้อมูลได้มาก
• ใช้สื่อสารอากาศยาน
• ตัวอย่าง: AN/PRC-117
''',
        visualWidget: _buildRadioTypesWidget(),
      ),
      LessonPage(
        title: 'วิทยุ SINCGARS',
        content: '''
SINCGARS = Single Channel Ground and Airborne Radio System

เป็นวิทยุยุทธวิธีมาตรฐานของสหรัฐฯ และพันธมิตร

คุณสมบัติเด่น:
✅ รองรับ FHSS (กระโดดความถี่)
✅ เข้ารหัสในตัว
✅ ทนต่อการรบกวน
✅ ใช้งานได้ทั้งพื้น-อากาศ

ย่านความถี่: 30-88 MHz (VHF)
กำลังส่ง: 0.05 - 50 วัตต์
โหมด:
• Single Channel (SC)
• Frequency Hopping (FH)
''',
        visualWidget: _buildSINCGARSWidget(),
      ),
      LessonPage(
        title: 'การตั้งค่าวิทยุยุทธวิธี',
        content: '''
ขั้นตอนพื้นฐาน:

1️⃣ ตรวจสอบแบตเตอรี่
   • ตรวจระดับแบตเตอรี่
   • ใส่แบตให้ถูกต้อง

2️⃣ เชื่อมต่อเสาอากาศ
   • ตรวจขั้วต่อ
   • เลือกเสาอากาศตามระยะ

3️⃣ ตั้งค่าความถี่/ช่อง
   • ตั้งตามคำสั่งหน่วย
   • ตรวจ COMSEC Key

4️⃣ ทดสอบการสื่อสาร
   • ทดสอบกับสถานีควบคุม
   • รายงาน Radio Check

⚠️ ปฏิบัติตาม EMCON เสมอ
''',
        visualWidget: _buildRadioSetupWidget(),
      ),
      LessonPage(
        title: 'รูปแบบการแผ่คลื่นเสาอากาศ',
        content: '''
เสาอากาศแต่ละประเภทมีรูปแบบการแผ่คลื่นต่างกัน:

📡 Omnidirectional (รอบทิศ)
• แผ่คลื่น 360° รอบตัว
• Gain ต่ำ แต่ครอบคลุมทั่ว
• ใช้ในวิทยุมือถือ

📡 Directional (ทิศทาง)
• แผ่คลื่นในทิศทางเดียว
• Gain สูง ระยะไกล
• ต้องหันเสาอากาศให้ถูก

📡 Yagi-Uda
• เสาทิศทางยอดนิยม
• มี Front-to-Back ratio ดี
• ใช้ในสถานีฐาน

ลองปรับค่าและดูรูปแบบการแผ่คลื่น:
''',
        visualWidget: const AntennaPatternWidget(),
      ),
      LessonPage(
        title: 'Link Budget - สมดุลสัญญาณ',
        content: '''
Link Budget คือการคำนวณว่าสัญญาณจะไปถึงปลายทางได้หรือไม่

สูตรพื้นฐาน:
Received Power = EIRP - Path Loss + Rx Gain - Losses

องค์ประกอบสำคัญ:

📤 ภาคส่ง (Transmitter)
• TX Power: กำลังส่ง
• TX Gain: Gain เสาอากาศ
• TX Loss: Loss สายนำสัญญาณ

📉 เส้นทาง (Path)
• FSPL: Free Space Path Loss
• ขึ้นกับระยะและความถี่
• Loss อื่นๆ: ฝน, สิ่งกีดขวาง

📥 ภาครับ (Receiver)
• RX Gain: Gain เสาอากาศ
• RX Loss: Loss สายนำสัญญาณ
• Sensitivity: ความไวรับ

⚡ Link Margin = Received Power - Sensitivity
ถ้า > 0 = สัญญาณถึง!
''',
        visualWidget: const LinkBudgetWidget(),
      ),
    ];
  }

  List<LessonPage> _comsecPages() {
    return [
      LessonPage(
        title: 'COMSEC คืออะไร?',
        content: '''
COMSEC = Communications Security
ความปลอดภัยการสื่อสาร

เป้าหมาย:
🔒 ป้องกันข้าศึกจากการ:
• ดักรับเนื้อหา
• วิเคราะห์รูปแบบการสื่อสาร
• หาตำแหน่งเครื่องส่ง
• รบกวนการสื่อสาร

องค์ประกอบ COMSEC:
• TRANSEC (Transmission Security)
• CRYPTOSEC (Cryptographic Security)
• Physical Security
• Emission Security
''',
        visualWidget: _buildCOMSECOverviewWidget(),
      ),
      LessonPage(
        title: 'TRANSEC',
        content: '''
TRANSEC = Transmission Security
ความปลอดภัยการส่ง

เทคนิค TRANSEC:

📡 การควบคุมการแผ่คลื่น (EMCON)
• Radio Silence - งดใช้วิทยุ
• Minimize - ใช้เท่าที่จำเป็น

🔄 การกระโดดความถี่ (FHSS)
• เปลี่ยนความถี่ตลอดเวลา
• ยากต่อการดักรับ

📶 การควบคุมกำลังส่ง
• ใช้กำลังต่ำสุดที่เพียงพอ
• ลดระยะการแพร่คลื่น

🔊 ลดเวลาส่ง
• พูดสั้น กระชับ
• ใช้รหัสย่อ
''',
        visualWidget: _buildTRANSECWidget(),
      ),
      LessonPage(
        title: 'การเข้ารหัส (Encryption)',
        content: '''
การเข้ารหัสทำให้ข้าศึกไม่สามารถอ่านข้อความได้

ประเภทการเข้ารหัส:

🔑 Symmetric Encryption
• ใช้ Key เดียวกันทั้งส่ง-รับ
• เร็ว แต่ต้องแจกจ่าย Key

🔐 Asymmetric Encryption
• ใช้ Public/Private Key
• ปลอดภัยกว่า แต่ช้ากว่า

ในทางทหาร:
• ใช้เครื่องเข้ารหัสเฉพาะ
• Key เปลี่ยนตามกำหนด
• มีระดับชั้นความลับ

⚠️ Key Management สำคัญมาก!
''',
        visualWidget: _buildEncryptionWidget(),
      ),
      LessonPage(
        title: 'ระเบียบการใช้วิทยุ',
        content: '''
การใช้วิทยุที่ดี ช่วยลดการถูกตรวจจับ:

✅ ทำ:
• ใช้รหัสเรียกขาน
• พูดสั้น กระชับ
• ใช้รหัสย่อมาตรฐาน
• Radio Check ก่อนภารกิจ
• ปฏิบัติตาม EMCON

❌ ห้าม:
• เอ่ยชื่อ-ตำแหน่งจริง
• พูดเรื่องลับทางวิทยุเปิด
• เปิดวิทยุโดยไม่จำเป็น
• ใช้กำลังส่งเกินจำเป็น
• ฝ่าฝืน Radio Silence

📋 ตัวอย่างรหัสย่อ:
• Roger = รับทราบ
• Wilco = จะปฏิบัติ
• Out = จบการส่ง
''',
        visualWidget: _buildRadioProceduresWidget(),
      ),
    ];
  }

  // ==================== บทที่ 7: ระเบียบปฏิบัติภาคสนาม ====================

  List<LessonPage> _ewSopsPages() {
    return [
      LessonPage(
        title: 'SOPs คืออะไร?',
        content: '''
SOPs = Standard Operating Procedures
ระเบียบปฏิบัติมาตรฐาน

ทำไมต้องมี SOPs?
• มาตรฐานเดียวกันทุกหน่วย
• ลดความผิดพลาด
• เพิ่มความรวดเร็ว
• ฝึกได้ง่าย

SOPs ด้าน EW ครอบคลุม:
📋 การปฏิบัติก่อนภารกิจ
📋 การปฏิบัติระหว่างภารกิจ
📋 การรายงาน
📋 การบำรุงรักษาอุปกรณ์
📋 การจัดการ COMSEC
''',
        visualWidget: _buildSOPsOverviewWidget(),
      ),
      LessonPage(
        title: 'SOP: ก่อนภารกิจ',
        content: '''
การเตรียมตัวก่อนออกภารกิจ:

1️⃣ ตรวจอุปกรณ์ EW
   □ วิทยุสื่อสารครบ
   □ แบตเตอรี่เต็ม
   □ เสาอากาศพร้อม
   □ อุปกรณ์เข้ารหัสพร้อม

2️⃣ รับข้อมูลความถี่
   □ รับ CEOI/SOI
   □ บันทึกความถี่ใช้งาน
   □ ความถี่ฉุกเฉิน

3️⃣ ประสานงาน
   □ รู้รหัสเรียกขานทุกหน่วย
   □ เวลานัดหมาย
   □ แผน EMCON

4️⃣ ทดสอบระบบ
   □ Radio Check
   □ ทดสอบการเข้ารหัส
''',
        visualWidget: _buildPreMissionWidget(),
      ),
      LessonPage(
        title: 'SOP: ระหว่างภารกิจ',
        content: '''
การปฏิบัติระหว่างภารกิจ:

📡 การสื่อสาร
• รายงานตามกำหนด
• ใช้รหัสที่กำหนด
• ปฏิบัติตาม EMCON

🔍 การเฝ้าฟัง
• ติดตามความถี่หลัก
• บันทึกสัญญาณผิดปกติ
• รายงานการรบกวน

⚠️ เมื่อถูกรบกวน
1. ตรวจสอบอุปกรณ์ตัวเอง
2. เปลี่ยนไปความถี่สำรอง
3. รายงานหน่วยเหนือ
4. ปฏิบัติตาม ECCM

🆘 เมื่อฉุกเฉิน
• ใช้ความถี่ฉุกเฉิน
• รายงานด้วยรหัส Distress
''',
        visualWidget: _buildDuringMissionWidget(),
      ),
      LessonPage(
        title: 'การรายงาน EW',
        content: '''
รูปแบบรายงาน MIJI (Meaconing, Intrusion, Jamming, Interference):

📝 รายงาน MIJI ประกอบด้วย:

1. วันเวลาที่ตรวจพบ
2. ความถี่ที่ถูกกระทบ
3. ประเภท (M/I/J/I)
4. ลักษณะสัญญาณ
5. ผลกระทบ
6. การแก้ไขที่ดำเนินการ

ตัวอย่าง:
"เวลา 0830 ตรวจพบ Jamming
ที่ความถี่ 45.500 MHz
ลักษณะ Barrage
ผลกระทบ: สื่อสารไม่ได้
แก้ไข: เปลี่ยนความถี่สำรอง"

รายงานทันทีเมื่อตรวจพบ!
''',
        visualWidget: _buildMIJIReportWidget(),
      ),
    ];
  }

  List<LessonPage> _checklistPages() {
    return [
      LessonPage(
        title: 'Checklists คืออะไร?',
        content: '''
Checklist = รายการตรวจสอบ

ทำไมต้องใช้ Checklist?
✅ ไม่ลืมขั้นตอนสำคัญ
✅ มาตรฐานเดียวกัน
✅ ตรวจสอบย้อนหลังได้
✅ ลดความผิดพลาด

Checklist สำคัญใน EW:
📋 Daily Equipment Check
📋 Pre-Mission Check
📋 COMSEC Check
📋 Maintenance Check
📋 After-Action Check
''',
        visualWidget: _buildChecklistOverviewWidget(),
      ),
      LessonPage(
        title: 'Checklist: ตรวจวิทยุประจำวัน',
        content: '''
รายการตรวจวิทยุประจำวัน:

□ ภายนอก
  ○ ตัวเครื่องไม่ชำรุด
  ○ ปุ่ม/สวิตช์ครบ
  ○ ขั้วต่อไม่เสียหาย

□ แบตเตอรี่
  ○ ระดับแบตเตอรี่ ≥ 80%
  ○ ขั้วไม่เป็นสนิม
  ○ แบตสำรองพร้อม

□ เสาอากาศ
  ○ ไม่หัก/งอ
  ○ ขั้วต่อแน่น
  ○ สายอากาศไม่ชำรุด

□ ทดสอบ
  ○ เปิด-ปิดได้ปกติ
  ○ รับ-ส่งได้
  ○ เสียงชัดเจน

ลงชื่อ: _________ วันที่: _____
''',
        visualWidget: _buildDailyCheckWidget(),
      ),
      LessonPage(
        title: 'Checklist: COMSEC',
        content: '''
รายการตรวจสอบ COMSEC:

□ เอกสาร COMSEC
  ○ CEOI/SOI อัปเดต
  ○ เก็บในที่ปลอดภัย
  ○ ทำลายฉบับเก่าแล้ว

□ อุปกรณ์เข้ารหัส
  ○ Key โหลดถูกต้อง
  ○ Zeroize ทำงานได้
  ○ แบตเตอรี่พอ

□ การปฏิบัติ
  ○ ไม่ส่งข้อมูลลับทาง UNSECURE
  ○ ไม่เปิดเผยรหัสเรียกขาน
  ○ ปฏิบัติตาม EMCON

□ การทำลาย (ฉุกเฉิน)
  ○ รู้วิธี Zeroize
  ○ รู้ลำดับการทำลาย

⚠️ COMSEC Incident = รายงานทันที!
''',
        visualWidget: _buildCOMSECCheckWidget(),
      ),
      LessonPage(
        title: 'สรุป: ภาพรวมหลักสูตร',
        content: '''
🎓 สรุปสิ่งที่เรียนมา:

บทที่ 1: ภาพรวม EW
• EW คืออะไร และความสำคัญ

บทที่ 2: สเปกตรัม
• ย่านความถี่ HF/VHF/UHF/SHF

บทที่ 3: ESM (Electronic Support Measures)
• การตรวจจับและดักรับสัญญาณ

บทที่ 4: ECM (Electronic Countermeasures)
• การรบกวน Spot/Barrage/Sweep

บทที่ 5: ECCM (Electronic Counter-Countermeasures)
• การป้องกันการรบกวน และ FHSS

บทที่ 6: วิทยุยุทธวิธี
• ประเภทวิทยุ และ COMSEC

บทที่ 7: SOPs
• ระเบียบปฏิบัติและ Checklists

✅ พร้อมสำหรับภาคปฏิบัติ!
''',
        visualWidget: _buildCourseSummaryWidget(),
      ),
    ];
  }

  // ==================== บทที่ 8: ESM ขั้นสูง ====================

  List<LessonPage> _advancedDFPages() {
    return [
      LessonPage(
        title: 'Direction Finding (DF)',
        content: '''
🎯 การหาทิศทางสัญญาณ (Direction Finding)

Direction Finding คือการระบุทิศทางที่สัญญาณแม่เหล็กไฟฟ้ามาถึง โดยใช้ระบบสายอากาศพิเศษ

📡 วิธีการ DF หลัก:

1. Watson-Watt
• ใช้สายอากาศ Adcock 2 คู่ (N-S, E-W)
• วัด phase difference
• คำนวณ bearing ทันที
• ความแม่นยำ ±5°

2. Doppler DF
• สายอากาศหมุนหรือสวิตช์
• วัด Doppler shift
• ความแม่นยำสูงกว่า ±2°

3. Interferometer
• ใช้ baseline หลายคู่
• วัด phase difference
• ความแม่นยำสูงมาก ±1°
''',
        visualWidget: _buildDFMethodsWidget(),
      ),
      LessonPage(
        title: 'Triangulation',
        content: '''
📐 การหาตำแหน่งด้วย Triangulation

เมื่อได้ bearing จากหลายสถานี สามารถหาตำแหน่งที่ตั้งเครื่องส่งได้

🔺 หลักการ:
• ต้องการ bearing อย่างน้อย 2 เส้น
• จุดตัดคือตำแหน่งเป้าหมาย
• ใช้ 3 เส้นขึ้นไปเพิ่มความแม่นยำ

⚠️ ความคลาดเคลื่อน:
• Error ellipse จากความไม่แม่นยำ
• ระยะห่างของสถานี DF
• มุมตัดที่เหมาะสม 60-120°

📍 Fix Quality:
• Class A: <1 km accuracy
• Class B: 1-5 km accuracy
• Class C: >5 km accuracy
''',
        visualWidget: _buildTriangulationWidget(),
      ),
    ];
  }

  List<LessonPage> _triangulationPracticePages() {
    return [
      LessonPage(
        title: 'ฝึก Triangulation',
        content: '''
🎯 ฝึกปฏิบัติการหาตำแหน่ง

ขั้นตอนการ Triangulation:

1️⃣ รับ Bearing จากสถานี A
• บันทึกเวลา, ความถี่, bearing

2️⃣ รับ Bearing จากสถานี B
• ต้องเป็นสัญญาณเดียวกัน
• เวลาใกล้เคียงกัน (<5 นาที)

3️⃣ Plot บนแผนที่
• ลากเส้น bearing จากทั้งสองสถานี
• จุดตัดคือตำแหน่งเป้าหมาย

4️⃣ ประเมิน Error
• คำนวณ error ellipse
• ระบุ fix quality

💡 ข้อควรระวัง:
• Multipath จากภูเขา/อาคาร
• สัญญาณอ่อน = bearing ไม่แม่น
• เป้าหมายเคลื่อนที่

👇 ลองใช้ DF Triangulation Simulator ด้านล่าง
''',
        visualWidget: const SizedBox(
          height: 750,
          child: DFTriangulationWidget(),
        ),
      ),
    ];
  }

  List<LessonPage> _eobAnalysisPages() {
    return [
      LessonPage(
        title: 'EOB Analysis',
        content: '''
📊 Electronic Order of Battle (EOB)

EOB คือฐานข้อมูลระบบอิเล็กทรอนิกส์ของข้าศึก

📋 ข้อมูลใน EOB:

🔹 ตัวระบุเครื่องส่ง (Emitter ID)
• ความถี่
• PRF, Pulse Width
• Modulation

🔹 ตำแหน่งที่ตั้ง
• พิกัด
• ความแม่นยำ
• วันเวลาที่พบ

🔹 การวิเคราะห์
• Platform type (เรือ, รถ, อากาศยาน)
• หน่วยที่ใช้งาน
• ภัยคุกคาม level

🎯 การใช้งาน EOB:
• วางแผนเส้นทางบิน
• กำหนดเป้าหมาย EW
• ประเมินภัยคุกคาม
''',
        visualWidget: _buildEOBWidget(),
      ),
    ];
  }

  // ==================== บทที่ 9: ECM ขั้นสูง ====================

  List<LessonPage> _jsRatioPages() {
    return [
      LessonPage(
        title: 'J/S Ratio',
        content: '''
📊 Jamming-to-Signal Ratio (J/S)

J/S คืออัตราส่วนกำลังสัญญาณรบกวนต่อสัญญาณเป้าหมาย

📐 สูตรคำนวณ (dB):
J/S = Pj + Gj - Lj - (Pt + Gt - Lt)

โดยที่:
• Pj = กำลังส่ง Jammer (dBW)
• Gj = Gain สายอากาศ Jammer (dBi)
• Lj = Loss ของ Jammer (dB)
• Pt = กำลังส่งเป้าหมาย (dBW)
• Gt = Gain เป้าหมาย (dBi)
• Lt = Loss เป้าหมาย (dB)

⚡ ค่า J/S ที่ต้องการ:
• FM: 6-10 dB
• AM: 10-15 dB
• PSK: 15-20 dB
• Spread Spectrum: 20-30 dB
''',
        visualWidget: _buildJSRatioWidget(),
      ),
      LessonPage(
        title: 'Burn-through Range',
        content: '''
🔥 Burn-through Range

คือระยะที่สัญญาณเป้าหมาย "ทะลุ" การรบกวนได้

📐 ปัจจัยที่มีผล:

1. กำลังส่งเป้าหมาย
   ยิ่งสูง ยิ่งทะลุได้ไกล

2. กำลังส่ง Jammer
   ยิ่งสูง ยิ่งมี burn-through ไกล

3. ระยะห่าง
   • Jammer-Target
   • Target-Receiver

4. Gain สายอากาศ
   ทั้งสองฝ่าย

⚠️ ผลกระทบ:
• ใกล้กว่า burn-through = รบกวนไม่ได้
• ต้องวางตำแหน่ง Jammer ให้เหมาะสม
''',
        visualWidget: _buildBurnThroughWidget(),
      ),
    ];
  }

  List<LessonPage> _jsCalculatorPages() {
    return [
      LessonPage(
        title: 'เครื่องคำนวณ J/S',
        content: '''
🧮 ฝึกคำนวณ J/S Ratio

ตัวอย่างการคำนวณ:

📡 Jammer:
• กำลังส่ง: 100W (20 dBW)
• Antenna Gain: 6 dBi
• ระยะถึงเป้า: 10 km

📻 เป้าหมาย:
• กำลังส่ง: 50W (17 dBW)
• Antenna Gain: 3 dBi
• ระยะถึง Rx: 20 km

🔢 คำนวณ:
Path Loss Jammer = 20log(10000) + 20log(f) + ...
Path Loss Target = 20log(20000) + 20log(f) + ...

J/S = (Pj + Gj - PLj) - (Pt + Gt - PLt)

💡 ใช้โปรแกรมช่วยคำนวณจริงในภาคสนาม
''',
        visualWidget: _buildJSCalculatorWidget(),
      ),

      // หน้าจำลอง J/S แบบโต้ตอบ
      LessonPage(
        title: '🎮 ทดลอง J/S Ratio',
        content: '''
🧪 ทดลองปรับค่าและดูผล J/S!

📻 ลองเปลี่ยนค่า:
• กำลังส่ง Jammer และ Signal
• ระยะห่างจากเป้าหมาย

📊 สังเกต:
• J/S > 1 = รบกวนได้ผล
• ระยะใกล้ = J/S สูงขึ้น
• กำลังสูง = J/S สูงขึ้น

💡 เคล็ดลับ:
วาง Jammer ให้ใกล้เป้ารับ
เพื่อเพิ่มประสิทธิภาพการรบกวน

⚠️ ข้อควรระวัง:
อย่าวางใกล้เกินไปจะถูก Homing on Jam
''',
        visualWidget: const JSRatioWidget(),
      ),
    ];
  }

  List<LessonPage> _jammingPlanningPages() {
    return [
      LessonPage(
        title: 'การวางแผนรบกวน',
        content: '''
📋 การวางแผนปฏิบัติการ Jamming

🎯 ขั้นตอนการวางแผน:

1️⃣ รวบรวมข่าวกรอง
• EOB ข้าศึก
• ความถี่ที่ใช้
• ตำแหน่งที่ตั้ง

2️⃣ กำหนดเป้าหมาย
• Priority targets
• ผลที่ต้องการ

3️⃣ เลือกเทคนิค
• Spot / Barrage / Sweep
• Noise / Deception

4️⃣ คำนวณ Parameters
• กำลังส่ง
• ตำแหน่งวาง Jammer
• ระยะเวลา

5️⃣ ประสานงาน
• กับหน่วยฝ่ายเดียวกัน
• เวลาเริ่ม-หยุด

⚠️ ระวัง Fratricide!
''',
        visualWidget: _buildJammingPlanWidget(),
      ),
    ];
  }

  // ==================== บทที่ 10: ECCM ขั้นสูง ====================

  List<LessonPage> _advancedECCMPages() {
    return [
      LessonPage(
        title: 'ECCM ขั้นสูง',
        content: '''
🛡️ เทคนิค ECCM ขั้นสูง

1️⃣ Adaptive Nulling
• ปรับ antenna pattern อัตโนมัติ
• สร้าง null ไปทาง jammer
• ต้องการ phased array

2️⃣ Sidelobe Blanking (SLB)
• Guard antenna รอบทิศ
• ตรวจจับสัญญาณจาก sidelobe
• Blank pulse ที่มาจาก sidelobe

3️⃣ Sidelobe Cancellation (SLC)
• Auxiliary antennas
• ลบสัญญาณ jamming ออก
• ใช้ได้กับ CW jamming

4️⃣ Frequency Diversity
• เปลี่ยนความถี่ระหว่าง pulse
• บังคับให้ jammer ใช้ barrage
• ลด J/S ต่อความถี่
''',
        visualWidget: _buildAdvancedECCMWidget(),
      ),
    ];
  }

  List<LessonPage> _eccmPracticePages() {
    return [
      LessonPage(
        title: 'ฝึก ECCM',
        content: '''
🎮 สถานการณ์จำลอง ECCM

📡 สถานการณ์:
ข้าศึกรบกวนข่ายวิทยุของเรา

🔴 อาการ:
• เสียงรบกวนตลอด
• รับส่งไม่ได้
• สัญญาณแรงมาก

🛡️ มาตรการแก้ไข:

ขั้นที่ 1: ยืนยันว่าถูกรบกวน
• ตรวจสอบอุปกรณ์
• เปลี่ยนความถี่ทดสอบ

ขั้นที่ 2: ใช้ ECCM
• Frequency Hopping
• เพิ่มกำลังส่ง
• ใช้สายอากาศ directional

ขั้นที่ 3: รายงาน MIJI
• เวลา, ความถี่
• ลักษณะการรบกวน
• ผลกระทบ

ขั้นที่ 4: ใช้แผนสำรอง
• สลับไปข่ายสำรอง
• ใช้การสื่อสารทางอื่น
''',
        visualWidget: _buildECCMPracticeWidget(),
      ),
    ];
  }

  // ==================== บทที่ 11: ระบบเรดาร์ ====================

  List<LessonPage> _radarTypesPages() {
    return [
      LessonPage(
        title: 'ประเภทเรดาร์',
        content: '''
📡 ประเภทเรดาร์หลัก

1️⃣ Pulse Radar
• ส่ง pulse สั้นๆ
• วัดระยะจาก time delay
• ใช้งานทั่วไป

2️⃣ CW Radar
• ส่งคลื่นต่อเนื่อง
• วัดความเร็ว Doppler
• ไม่วัดระยะ (pure CW)

3️⃣ FM-CW Radar
• Frequency Modulated CW
• วัดได้ทั้งระยะและความเร็ว
• ใช้ในเครื่องวัดความสูง

4️⃣ Pulse Doppler
• รวม Pulse + Doppler
• แยก clutter จากเป้า
• ใช้ในเครื่องบินรบ

5️⃣ Phased Array
• ควบคุม beam ด้วยไฟฟ้า
• scan เร็วมาก
• Track หลายเป้าพร้อมกัน
''',
        visualWidget: _buildRadarTypesWidget(),
      ),
      LessonPage(
        title: 'Parameters เรดาร์',
        content: '''
📊 Parameters สำคัญของเรดาร์

📡 PRF (Pulse Repetition Frequency)
• จำนวน pulse ต่อวินาที
• High PRF = วัด velocity ดี
• Low PRF = วัด range ไกล

⏱️ PW (Pulse Width)
• ความกว้างของ pulse
• กว้าง = พลังงานมาก
• แคบ = resolution ดี

📏 Range Resolution
• ΔR = c × PW / 2
• PW 1 μs = 150 m resolution

🎯 สิ่งที่ใช้ระบุเรดาร์:
• PRF pattern
• Pulse Width
• Frequency
• Scan rate
• Antenna pattern

→ ใช้สร้าง Radar EOB
''',
        visualWidget: _buildRadarParametersWidget(),
      ),

      // หน้าคำนวณระยะเรดาร์
      LessonPage(
        title: '🧮 คำนวณระยะเรดาร์',
        content: '''
📐 สมการระยะเรดาร์ (Radar Range Equation)

ระยะตรวจจับขึ้นอยู่กับ:

📡 Pt (Transmit Power)
   กำลังส่ง - ยิ่งสูงยิ่งไกล

📶 G (Antenna Gain)
   อัตราขยายเสาอากาศ - ยิ่งสูงยิ่งไกล

🎯 σ (RCS - Radar Cross Section)
   พื้นที่หน้าตัดเรดาร์ของเป้า
   • เครื่องบินรบ: 1-5 m²
   • Stealth: 0.001-0.1 m²
   • เรือ: 100-10,000 m²

📊 ลองปรับค่าด้านล่างดู!
''',
        visualWidget: const RadarEquationWidget(),
      ),
    ];
  }

  List<LessonPage> _radarSimPages() {
    return [
      LessonPage(
        title: 'จำลองเรดาร์',
        content: '''
🎮 ฝึกใช้จำลองเรดาร์

📡 องค์ประกอบบนจอ:

• Range Rings - วงกลมระยะ
• Azimuth - องศารอบทิศ
• Blip - จุดแสดงเป้า
• Clutter - สัญญาณรบกวน

🎯 การอ่านเป้า:
• ระยะ: อ่านจาก range ring
• ทิศทาง: อ่านจาก azimuth
• ความเร็ว: ดูการเคลื่อนที่

⚠️ การระบุเป้า:
• Friend หรือ Foe?
• ใช้ IFF
• ตรวจสอบ flight plan

🔧 การปรับแต่ง:
• Gain - ความไวรับ
• STC - ลด clutter ใกล้
• MTI - แสดงเฉพาะเป้าเคลื่อนที่
''',
        visualWidget: _buildRadarSimWidget(),
      ),
    ];
  }

  // ==================== บทที่ 12: Anti-Drone EW ====================

  List<LessonPage> _droneDetectionPages() {
    return [
      LessonPage(
        title: 'การตรวจจับโดรน',
        content: '''
🚁 ระบบตรวจจับโดรน (C-UAS Detection)

📡 เซ็นเซอร์หลัก:

1️⃣ RF Detection
• ตรวจจับสัญญาณ control link
• 2.4 GHz, 5.8 GHz
• ระยะไกล, passive

2️⃣ Radar
• ตรวจจับตัวโดรน
• ยากเพราะ RCS เล็ก
• ใช้ radar พิเศษ

3️⃣ Acoustic
• ตรวจจับเสียงใบพัด
• ระยะใกล้ <500m
• ไม่ดีในที่มีเสียงดัง

4️⃣ EO/IR
• กล้อง visual/thermal
• ระบุประเภทได้
• จำกัดระยะ/ทัศนวิสัย

💡 Sensor Fusion
รวมข้อมูลหลายเซ็นเซอร์
เพิ่มความแม่นยำ
''',
        visualWidget: _buildDroneDetectionWidget(),
      ),
    ];
  }

  List<LessonPage> _droneCounterPages() {
    return [
      LessonPage(
        title: 'การต่อต้านโดรน',
        content: '''
🛡️ มาตรการต่อต้านโดรน

📡 Soft Kill (EW):

1️⃣ RF Jamming
• รบกวน control link
• โดรนจะ RTH หรือลง
• ระวังผลกระทบรอง

2️⃣ GPS Jamming
• รบกวน GPS receiver
• โดรนหลงทาง
• ระวังผลกระทบ

3️⃣ GPS Spoofing
• หลอก GPS โดรน
• นำโดรนไปที่ต้องการ
• เทคนิคขั้นสูง

4️⃣ Takeover
• ยึดควบคุมโดรน
• ต้องรู้ protocol
• เทคนิคขั้นสูงมาก

⚔️ Hard Kill:
• ยิง (AA guns)
• Laser
• Net/Drone interceptor
''',
        visualWidget: _buildDroneCounterWidget(),
      ),
    ];
  }

  // ==================== บทที่ 13: GPS Warfare ====================

  List<LessonPage> _gpsJammingSpoofingPages() {
    return [
      LessonPage(
        title: 'GPS Jamming vs Spoofing',
        content: '''
🛰️ ลองใช้ GPS Warfare Simulator ด้านล่าง!

📡 Jamming = รบกวนสัญญาณ → GPS หาย
🎭 Spoofing = ส่งสัญญาณปลอม → ตำแหน่งผิด

👆 กดปุ่ม Normal / Jamming / Spoofing เพื่อดูผล
🔄 ลากแถบเลื่อนเพื่อปรับความแรง
🛡️ เปิด Anti-Jam เพื่อดูการป้องกัน
''',
        visualWidget: const GPSWarfareWidget(),
      ),
    ];
  }

  List<LessonPage> _gpsSpoofDetectionPages() {
    return [
      LessonPage(
        title: 'ตรวจจับ Spoofing',
        content: '''
🔍 การตรวจจับ GPS Spoofing

📊 วิธีการตรวจจับ:

1️⃣ Cross-check
• INS vs GPS
• Compass vs GPS heading
• Altimeter vs GPS altitude

2️⃣ Signal Analysis
• C/N0 สูงผิดปกติ
• ทิศทางสัญญาณผิด
• Doppler ไม่ตรง

3️⃣ Multi-antenna
• ตรวจสอบ angle of arrival
• Spoofing มาทิศเดียว

4️⃣ Authentication
• GPS III มี authentication
• ป้องกัน spoofing ได้

🛡️ มาตรการป้องกัน:
• Anti-jam antenna
• M-code receiver
• INS backup
• Terrain matching
''',
        visualWidget: _buildGPSSpoofDetectionWidget(),
      ),
    ];
  }

  // ==================== บทที่ 14: กรณีศึกษา ====================

  List<LessonPage> _ewCaseStudyPages() {
    return [
      LessonPage(
        title: 'กรณีศึกษา EW สมัยใหม่',
        content: '''
📚 สงครามอิเล็กทรอนิกส์ในโลกปัจจุบัน

🌍 บทเรียนจากสมรภูมิจริง:

สงครามอิเล็กทรอนิกส์ไม่ได้เป็นแค่ทฤษฎี
แต่เกิดขึ้นจริงในหลายพื้นที่ทั่วโลก

📍 กรณีศึกษาที่น่าสนใจ:
• ยูเครน-รัสเซีย (2022-ปัจจุบัน)
• ไทย-กัมพูชา (2008-2011)
• ซีเรีย (2015-ปัจจุบัน)
• Nagorno-Karabakh (2020)

💡 เลือกดูรายละเอียดแต่ละกรณี
ในแท็บด้านล่าง
''',
        visualWidget: const SizedBox(
          height: 500,
          child: ModernEWCasesWidget(),
        ),
      ),
      LessonPage(
        title: 'บทสรุปกรณีศึกษา',
        content: '''
📝 บทสรุปจากกรณีศึกษา EW

🎯 ข้อค้นพบสำคัญ:

1️⃣ โดรนเปลี่ยนสนามรบ
   • ราคาถูก แต่มีประสิทธิภาพสูง
   • ต้องมีระบบ C-UAS ที่ดี

2️⃣ GPS เปราะบาง
   • ทั้ง Jamming และ Spoofing
   • ต้องมี INS สำรอง

3️⃣ การสื่อสารคือเป้าหมาย
   • ทุกฝ่ายพยายามรบกวนการสื่อสาร
   • COMSEC และ TRANSEC สำคัญมาก

4️⃣ EW ต้องปรับตัวเร็ว
   • สงครามแมวจับหนู
   • ต้องพัฒนาระบบตลอดเวลา

🇹🇭 สำหรับกองทัพไทย:
ต้องเรียนรู้และเตรียมพร้อมรับมือ
กับภัยคุกคาม EW ในอนาคต
''',
        visualWidget: _buildEWCaseStudyWidget(),
      ),
    ];
  }

  List<LessonPage> _scenarioAnalysisPages() {
    return [
      LessonPage(
        title: 'วิเคราะห์สถานการณ์',
        content: '''
🎯 ฝึกวิเคราะห์สถานการณ์ EW

📋 สถานการณ์จำลอง:

หน่วยของเราถูกโจมตี:
• วิทยุสื่อสารถูกรบกวน
• GPS ไม่ทำงาน
• โดรนลาดตระเวนข้าศึกบินเหนือ

❓ คำถามวิเคราะห์:

1. ข้าศึกใช้มาตรการ EW อะไรบ้าง?

2. เราควรตอบโต้อย่างไร?
   • มาตรการ ECCM?
   • การสื่อสารสำรอง?

3. โอกาสโจมตี?
   • DF หาที่ตั้ง Jammer?
   • ต่อต้านโดรน?

4. รายงานใคร? อย่างไร?

💡 ฝึกคิดวิเคราะห์สถานการณ์จริง
''',
        visualWidget: _buildScenarioAnalysisWidget(),
      ),
    ];
  }

  // ==================== บทที่ 15: การวางแผนยุทธวิธี ====================

  List<LessonPage> _missionPlanningPages() {
    return [
      LessonPage(
        title: 'Mission Planning',
        content: '''
📋 การวางแผนภารกิจ EW

🎯 ขั้นตอนการวางแผน:

1️⃣ รับภารกิจ
• ทำความเข้าใจ intent
• กำหนดวัตถุประสงค์ EW

2️⃣ วิเคราะห์ภารกิจ
• EOB ข้าศึก
• ระบบที่ต้องรบกวน
• ระบบที่ต้องป้องกัน

3️⃣ พัฒนาหนทางปฏิบัติ
• ESM: จะหาข่าวอะไร?
• ECM: จะรบกวนอะไร?
• ECCM: จะป้องกันอย่างไร?

4️⃣ เปรียบเทียบหนทาง
• ประสิทธิผล
• ความเสี่ยง
• ทรัพยากร

5️⃣ ตัดสินใจ & ออกคำสั่ง
• EW Task Order
• ประสานงานเวลา
''',
        visualWidget: _buildMissionPlanningWidget(),
      ),
    ];
  }

  List<LessonPage> _planningPracticePages() {
    return [
      LessonPage(
        title: 'ฝึกวางแผน',
        content: '''
🎮 ฝึกวางแผนภารกิจ EW

📋 สถานการณ์:
หน่วยจะเคลื่อนที่ผ่านพื้นที่ที่มีระบบ EW ข้าศึก

📡 ข่าวกรอง EOB:
• Jammer 2 ตัว (50 MHz - 500 MHz)
• DF station 3 สถานี
• GPS jammer 1 ตัว

🎯 ภารกิจ:
รักษาการสื่อสารและ GPS ของหน่วย

❓ วางแผน:

1. ECCM อะไรบ้าง?
   □ Frequency hopping
   □ Low power
   □ Directional antenna
   □ GPS backup (INS)

2. เส้นทางเคลื่อนที่?
   □ หลบพื้นที่ jammer
   □ ใช้ terrain masking

3. แผนสำรอง?
   □ วิทยุสำรอง
   □ Messenger
''',
        visualWidget: _buildPlanningPracticeWidget(),
      ),
    ];
  }

  // ==================== Widgets สำหรับบทที่ 8-15 ====================

  Widget _buildDFMethodsWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.esColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.radar, size: 48, color: AppColors.esColor)
              .animate(onPlay: (c) => c.repeat())
              .rotate(duration: 3.seconds),
          const SizedBox(height: 12),
          Text(
            'Direction Finding',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.esColor),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDFMethodChip('Watson-Watt', '±5°'),
              _buildDFMethodChip('Doppler', '±2°'),
              _buildDFMethodChip('Interferometer', '±1°'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildDFMethodChip(String name, String accuracy) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.esColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(name, style: AppTextStyles.labelSmall),
        ),
        const SizedBox(height: 4),
        Text(accuracy, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildTriangulationWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: CustomPaint(
        size: const Size(double.infinity, 150),
        painter: _SimpleTriangulationPainter(),
      ),
    ).animate().fadeIn();
  }

  Widget _buildEOBWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.esColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.table_chart, color: AppColors.esColor),
              const SizedBox(width: 8),
              Text('EOB Database', style: AppTextStyles.titleSmall.copyWith(color: AppColors.esColor)),
            ],
          ),
          const SizedBox(height: 12),
          _buildEOBRow('ID', 'Freq', 'Type', 'Threat', isHeader: true),
          _buildEOBRow('E-001', '9.4 GHz', 'Radar', '🔴'),
          _buildEOBRow('E-002', '150 MHz', 'Comms', '🟡'),
          _buildEOBRow('E-003', '2.4 GHz', 'Drone', '🟠'),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildEOBRow(String id, String freq, String type, String threat, {bool isHeader = false}) {
    final style = isHeader
        ? AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold)
        : AppTextStyles.labelSmall;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(id, style: style)),
          Expanded(child: Text(freq, style: style)),
          Expanded(child: Text(type, style: style)),
          SizedBox(width: 30, child: Text(threat, style: style)),
        ],
      ),
    );
  }

  Widget _buildJSRatioWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.eaColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text('J/S Ratio', style: AppTextStyles.titleMedium.copyWith(color: AppColors.eaColor)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSignalBar('J', AppColors.eaColor, 0.8),
              _buildSignalBar('S', AppColors.primary, 0.4),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.eaColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('J/S = +6 dB (รบกวนสำเร็จ)', style: AppTextStyles.labelMedium),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildSignalBar(String label, Color color, double level) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 40,
              height: 80 * level,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelMedium.copyWith(color: color)),
      ],
    );
  }

  Widget _buildBurnThroughWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDeviceIcon('Jammer', Icons.flash_on, AppColors.eaColor),
              const Icon(Icons.arrow_forward, color: AppColors.textMuted),
              _buildDeviceIcon('Target', Icons.radio, AppColors.primary),
              const Icon(Icons.arrow_forward, color: AppColors.textMuted),
              _buildDeviceIcon('Receiver', Icons.hearing, AppColors.esColor),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.eaColor, Colors.transparent],
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Text('Burn-through Range', style: AppTextStyles.labelSmall.copyWith(color: AppColors.eaColor)),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildDeviceIcon(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelSmall.copyWith(fontSize: 9)),
      ],
    );
  }

  Widget _buildJSCalculatorWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.eaColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.calculate, size: 48, color: AppColors.eaColor),
          const SizedBox(height: 12),
          Text('J/S Calculator', style: AppTextStyles.titleMedium.copyWith(color: AppColors.eaColor)),
          const SizedBox(height: 8),
          Text('ฝึกคำนวณในภาคปฏิบัติ', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildJammingPlanWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.eaColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Jamming Plan', style: AppTextStyles.titleSmall.copyWith(color: AppColors.eaColor)),
          const SizedBox(height: 8),
          _buildPlanStep(1, 'Intel', Icons.search),
          _buildPlanStep(2, 'Target', Icons.gps_fixed),
          _buildPlanStep(3, 'Technique', Icons.flash_on),
          _buildPlanStep(4, 'Calculate', Icons.calculate),
          _buildPlanStep(5, 'Coordinate', Icons.sync),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildPlanStep(int number, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.eaColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$number', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }

  Widget _buildAdvancedECCMWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.epColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.shield, size: 48, color: AppColors.epColor)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1.seconds),
          const SizedBox(height: 12),
          Text('Advanced ECCM', style: AppTextStyles.titleMedium.copyWith(color: AppColors.epColor)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildECCMChip('Nulling'),
              _buildECCMChip('SLB'),
              _buildECCMChip('SLC'),
              _buildECCMChip('Diversity'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildECCMChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.epColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.epColor)),
    );
  }

  Widget _buildECCMPracticeWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.epColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.warning, size: 40, color: Colors.red),
          const SizedBox(height: 8),
          Text('ถูกรบกวน!', style: AppTextStyles.titleMedium.copyWith(color: Colors.red)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton('FH', AppColors.epColor),
              _buildActionButton('↑Power', AppColors.epColor),
              _buildActionButton('Report', AppColors.warning),
            ],
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildActionButton(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
    );
  }

  Widget _buildRadarTypesWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.radarColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.radar, size: 48, color: AppColors.radarColor)
              .animate(onPlay: (c) => c.repeat())
              .rotate(duration: 2.seconds),
          const SizedBox(height: 12),
          Text('Radar Types', style: AppTextStyles.titleMedium.copyWith(color: AppColors.radarColor)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildRadarChip('Pulse'),
              _buildRadarChip('CW'),
              _buildRadarChip('FM-CW'),
              _buildRadarChip('Doppler'),
              _buildRadarChip('Phased'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildRadarChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.radarColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.radarColor)),
    );
  }

  Widget _buildRadarParametersWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        children: [
          _buildParamRow('PRF', '1000 Hz'),
          _buildParamRow('PW', '1 μs'),
          _buildParamRow('Freq', '9.4 GHz'),
          _buildParamRow('Resolution', '150 m'),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildParamRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted)),
          Text(value, style: AppTextStyles.labelMedium.copyWith(color: AppColors.radarColor)),
        ],
      ),
    );
  }

  Widget _buildRadarSimWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.radarColor),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: _SimpleRadarPainter(),
            ),
          ),
          const SizedBox(height: 8),
          Text('Radar Display', style: AppTextStyles.labelMedium.copyWith(color: AppColors.radarColor)),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildDroneDetectionWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.droneColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.flight, size: 48, color: AppColors.droneColor),
          const SizedBox(height: 12),
          Text('C-UAS Detection', style: AppTextStyles.titleMedium.copyWith(color: AppColors.droneColor)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSensorIcon('RF', Icons.cell_tower),
              _buildSensorIcon('Radar', Icons.radar),
              _buildSensorIcon('EO/IR', Icons.camera_alt),
            ],
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildSensorIcon(String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.droneColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.droneColor, size: 20),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }

  Widget _buildDroneCounterWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.droneColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text('Counter Measures', style: AppTextStyles.titleSmall.copyWith(color: AppColors.droneColor)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCounterChip('Jamming', Colors.orange),
              _buildCounterChip('Spoof', Colors.purple),
              _buildCounterChip('Kinetic', Colors.red),
            ],
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildCounterChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
    );
  }

  Widget _buildGPSSpoofDetectionWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.gpsColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.search, size: 40, color: AppColors.gpsColor),
          const SizedBox(height: 8),
          Text('Spoof Detection', style: AppTextStyles.titleSmall.copyWith(color: AppColors.gpsColor)),
          const SizedBox(height: 8),
          _buildDetectionRow('Cross-check', true),
          _buildDetectionRow('Signal Analysis', true),
          _buildDetectionRow('Multi-antenna', false),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildDetectionRow(String method, bool available) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            available ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: available ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(method, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }

  Widget _buildEWCaseStudyWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.history_edu, size: 48, color: Colors.purple),
          const SizedBox(height: 12),
          Text('Modern EW Cases', style: AppTextStyles.titleMedium.copyWith(color: Colors.purple)),
          const SizedBox(height: 8),
          _buildCaseChip('🇺🇦 Ukraine'),
          const SizedBox(height: 4),
          _buildCaseChip('🇸🇾 Syria'),
          const SizedBox(height: 4),
          _buildCaseChip('🌊 Black Sea'),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildCaseChip(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(label, style: AppTextStyles.labelMedium),
      ),
    );
  }

  Widget _buildScenarioAnalysisWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.psychology, size: 48, color: Colors.orange),
          const SizedBox(height: 12),
          Text('Analyze & Decide', style: AppTextStyles.titleMedium.copyWith(color: Colors.orange)),
          const SizedBox(height: 8),
          Text('ฝึกคิดวิเคราะห์สถานการณ์', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildMissionPlanningWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.assignment, size: 48, color: AppColors.primary),
          const SizedBox(height: 12),
          Text('Mission Planning', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
          const SizedBox(height: 8),
          _buildPlanningStep('📋 Receive Mission'),
          _buildPlanningStep('🔍 Analyze'),
          _buildPlanningStep('💡 Develop COA'),
          _buildPlanningStep('⚖️ Compare'),
          _buildPlanningStep('✅ Decide'),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildPlanningStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(text, style: AppTextStyles.labelSmall),
    );
  }

  Widget _buildPlanningPracticeWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildThreatIcon('Jammer', Icons.flash_on, Colors.red),
              _buildThreatIcon('DF', Icons.radar, Colors.orange),
              _buildThreatIcon('GPS-J', Icons.gps_off, Colors.purple),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('วางแผน ECCM ให้ครบ!', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildThreatIcon(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelSmall.copyWith(fontSize: 10)),
      ],
    );
  }

  // ==================== Default Pages ====================

  List<LessonPage> _defaultPages() {
    return [
      LessonPage(
        title: widget.lesson.titleTh,
        content: widget.lesson.descriptionTh ?? 'เนื้อหากำลังพัฒนา...',
        visualWidget: _buildComingSoonWidget(),
      ),
    ];
  }

  // ==================== Visual Widgets ====================

  Widget _buildEWConceptDiagram() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.radar, size: 60, color: AppColors.primary)
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 2.seconds),
          const SizedBox(height: 12),
          Text(
            'Electronic Warfare',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ควบคุมสเปกตรัมแม่เหล็กไฟฟ้า\nเพื่อความได้เปรียบในสนามรบ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildWizardWarWidget() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Churchill portrait placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 50, color: Colors.purple),
          ),
          const SizedBox(height: 12),
          Text(
            'Winston Churchill',
            style: AppTextStyles.titleSmall.copyWith(
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Row(
              children: [
                const Icon(Icons.format_quote, color: Colors.purple, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"สงครามแม่มด" (Wizard War)\nสงครามลับที่ชี้ขาดชะตากรรม',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildModernEWImportanceWidget() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildImportanceItem(Icons.military_tech, 'อำนาจ\nกำลังรบ', Colors.red),
              _buildImportanceItem(Icons.trending_up, 'ความได้\nเปรียบ', Colors.green),
              _buildImportanceItem(Icons.attach_money, 'การลงทุน\nมหาศาล', Colors.amber),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Text(
              '"ใครชนะในการต่อสู้ทางอิเล็กทรอนิกส์\nก็จะชนะสงคราม"',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportanceItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ).animate().fadeIn().scale();
  }

  Widget _buildEWExamplesWidget() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildEWExampleCategory(
              '🔍 ESM',
              ['ดักรับ', 'ตรวจจับ', 'หาทิศ'],
              AppColors.esColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildEWExampleCategory(
              '⚡ ECM',
              ['รบกวน', 'ลวง', 'CHAFF'],
              AppColors.eaColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildEWExampleCategory(
              '🛡️ ECCM',
              ['ป้องกัน', 'FHSS', 'เข้ารหัส'],
              AppColors.epColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEWExampleCategory(String title, List<String> items, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '• $item',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildEWImportanceDiagram() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.eaColor.withOpacity(0.2),
            AppColors.epColor.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '50%',
                style: AppTextStyles.displayLarge.copyWith(
                  color: AppColors.eaColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ).animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
          const SizedBox(height: 8),
          Text(
            'REC สามารถลดประสิทธิภาพข้าศึก',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildEWHistoryTimeline() {
    return Column(
      children: [
        _buildTimelineItem('1914', 'WW1: เริ่มใช้วิทยุ', Colors.grey),
        _buildTimelineItem('1939', 'WW2: เรดาร์ & CHAFF', Colors.orange),
        _buildTimelineItem('ปัจจุบัน', 'EW สมัยใหม่', AppColors.primary),
      ],
    );
  }

  Widget _buildTimelineItem(String year, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              year,
              style: AppTextStyles.labelLarge.copyWith(color: color),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 200));
  }

  Widget _buildHFPropagationWidget() {
    return _buildFrequencyBandWidget(
      'HF',
      '3-30 MHz',
      'สะท้อนชั้นบรรยากาศ ส่งไกลมาก',
      Colors.purple,
      Icons.public,
    );
  }

  Widget _buildVHFPropagationWidget() {
    return _buildFrequencyBandWidget(
      'VHF',
      '30-300 MHz',
      'Line-of-Sight ใช้ทางยุทธวิธี',
      Colors.blue,
      Icons.settings_input_antenna,
    );
  }

  Widget _buildUHFSHFWidget() {
    return Column(
      children: [
        _buildFrequencyBandWidget(
          'UHF',
          '300 MHz - 3 GHz',
          'Data Link & ดาวเทียม',
          Colors.teal,
          Icons.satellite_alt,
        ),
        const SizedBox(height: 12),
        _buildFrequencyBandWidget(
          'SHF',
          '3-30 GHz',
          'เรดาร์ & ไมโครเวฟ',
          Colors.cyan,
          Icons.track_changes,
        ),
      ],
    );
  }

  Widget _buildFrequencyBandWidget(
    String band,
    String range,
    String use,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 1500.ms,
              ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$band ($range)',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  use,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.signal_cellular_alt, color: color.withValues(alpha: 0.5), size: 20),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildSpectrumAnalyzerWidget() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.esColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.esColor.withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Grid overlay
          CustomPaint(
            painter: _SpectrumPainter(),
            size: const Size(double.infinity, 140),
          ),
          // Scan line effect
          Positioned.fill(
            child: Container()
                .animate(onPlay: (c) => c.repeat())
                .shimmer(
                  duration: 2000.ms,
                  color: AppColors.esColor.withValues(alpha: 0.3),
                ),
          ),
          // Label
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.esColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.show_chart, color: AppColors.esColor, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    'SPECTRUM',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.esColor,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95));
  }

  // ignore: unused_element
  Widget _buildESMUsageWidget() {
    return Column(
      children: [
        _buildESMQuestion('ข้าศึกอยู่ไหน?', 'Direction Finding', Icons.location_on),
        _buildESMQuestion('มีอุปกรณ์อะไร?', 'EOB Analysis', Icons.devices),
        _buildESMQuestion('กำลังทำอะไร?', 'COMINT', Icons.hearing),
      ],
    );
  }

  Widget _buildESMQuestion(String question, String answer, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.esColor, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(question, style: AppTextStyles.bodySmall),
                Text(
                  '→ $answer',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.esColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSIGINTDiagram() {
    return Row(
      children: [
        Expanded(
          child: _buildSIGINTType('COMINT', 'การสื่อสาร', AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSIGINTType('ELINT', 'เรดาร์/นำทาง', AppColors.radarColor),
        ),
      ],
    );
  }

  Widget _buildSIGINTType(String title, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(color: color),
          ),
          Text(
            desc,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCOMINTvsELINT() {
    return _buildSIGINTDiagram();
  }

  Widget _buildJammingConceptWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.eaColor.withValues(alpha: 0.15),
            AppColors.eaColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.eaColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildJammingIcon('สัญญาณ', Icons.wifi, Colors.green)
                  .animate(delay: 0.ms).fadeIn().scale(),
              Icon(Icons.add, color: AppColors.textSecondary)
                  .animate(delay: 200.ms).fadeIn(),
              _buildJammingIcon('รบกวน', Icons.waves, AppColors.eaColor)
                  .animate(delay: 400.ms)
                  .fadeIn()
                  .scale()
                  .then()
                  .shake(hz: 3, rotation: 0.05),
              Icon(Icons.arrow_forward, color: AppColors.textSecondary)
                  .animate(delay: 600.ms).fadeIn(),
              _buildJammingIcon('ไม่ได้ยิน', Icons.wifi_off, Colors.grey)
                  .animate(delay: 800.ms).fadeIn().scale(),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildJammingIcon(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWhenToJamWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.eaColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _buildJamUseCase('ตัดการสื่อสาร', Icons.phone_disabled, 0),
          _buildJamUseCase('ป้องกันจากเรดาร์', Icons.shield, 1),
          _buildJamUseCase('ป้องกันจากจรวด', Icons.rocket_launch, 2),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildJamUseCase(String text, IconData icon, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.eaColor.withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.eaColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.eaColor, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Icon(Icons.check_circle, color: AppColors.eaColor.withValues(alpha: 0.5), size: 18),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 150 * index))
        .fadeIn()
        .slideX(begin: 0.1, end: 0);
  }

  Widget _buildJammingComparisonWidget() {
    return const JammingTypesWidget();
  }

  Widget _buildECCMConceptWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.epColor.withValues(alpha: 0.15),
            AppColors.epColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.epColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildECCMStep('ECM', 'ข้าศึกรบกวน', AppColors.eaColor, 0),
          Icon(Icons.arrow_forward, color: AppColors.textSecondary)
              .animate(delay: 300.ms).fadeIn(),
          _buildECCMStep('ECCM', 'เราป้องกัน', AppColors.epColor, 1),
          Icon(Icons.arrow_forward, color: AppColors.textSecondary)
              .animate(delay: 600.ms).fadeIn(),
          _buildECCMStep('✓', 'สื่อสารได้', Colors.green, 2),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildECCMStep(String title, String desc, Color color, int index) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.3),
                color.withValues(alpha: 0.1),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Text(
              title,
              style: AppTextStyles.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          desc,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ).animate(delay: Duration(milliseconds: 200 * index))
        .fadeIn()
        .scale(begin: const Offset(0.8, 0.8));
  }

  // ignore: unused_element
  Widget _buildECCMTechniquesWidget() {
    return Column(
      children: [
        _buildECCMTechnique('เปลี่ยนความถี่', Icons.swap_horiz, AppColors.epColor),
        _buildECCMTechnique('เพิ่มกำลังส่ง', Icons.signal_cellular_alt, Colors.orange),
        _buildECCMTechnique('เสาอากาศทิศทาง', Icons.settings_input_antenna, Colors.blue),
        _buildECCMTechnique('Radio Silence', Icons.volume_off, Colors.grey),
      ],
    );
  }

  Widget _buildECCMTechnique(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(text, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildFHSSProsConsWidget() {
    return const FHSSWidget();
  }

  // ==================== Module 6: Tactical Radio Widgets ====================

  Widget _buildTacticalRadioOverviewWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.radioColor.withValues(alpha: 0.2),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.settings_input_antenna, size: 60, color: AppColors.radioColor)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
          const SizedBox(height: 12),
          Text(
            'Tactical Radio',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.radioColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRadioFeature(Icons.shield, 'ทนทาน'),
              _buildRadioFeature(Icons.lock, 'เข้ารหัส'),
              _buildRadioFeature(Icons.signal_cellular_alt, 'ECCM'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadioFeature(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.radioColor, size: 28),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }

  Widget _buildRadioTypesWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildRadioTypeRow('HF', '3-30 MHz', 'ระยะไกล', Colors.blue, 0),
          _buildRadioTypeRow('VHF', '30-300 MHz', 'ยุทธวิธี', Colors.green, 1),
          _buildRadioTypeRow('UHF', '300+ MHz', 'อากาศยาน', Colors.orange, 2),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildRadioTypeRow(String band, String freq, String usage, Color color, [int index = 0]) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              band,
              style: AppTextStyles.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  freq,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  usage,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.radio, color: color, size: 20),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 150 * index))
        .fadeIn()
        .slideX(begin: 0.1, end: 0);
  }

  Widget _buildSINCGARSWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.epColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.radio, color: AppColors.epColor, size: 40),
              const SizedBox(width: 12),
              Text(
                'SINCGARS',
                style: AppTextStyles.headlineSmall.copyWith(color: AppColors.epColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFeatureChip('FHSS', AppColors.epColor),
              _buildFeatureChip('เข้ารหัส', AppColors.primary),
              _buildFeatureChip('30-88 MHz', Colors.blue),
              _buildFeatureChip('Anti-Jam', Colors.orange),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildFeatureChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }

  Widget _buildRadioSetupWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.radioColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _buildSetupStep(1, 'ตรวจแบตเตอรี่', Icons.battery_full, Colors.green),
          _buildSetupStep(2, 'เชื่อมต่อเสาอากาศ', Icons.settings_input_antenna, Colors.blue),
          _buildSetupStep(3, 'ตั้งค่าความถี่', Icons.tune, Colors.orange),
          _buildSetupStep(4, 'ทดสอบ Radio Check', Icons.check_circle, AppColors.radioColor),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildSetupStep(int step, String text, IconData icon, [Color? color]) {
    final stepColor = color ?? AppColors.primary;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            stepColor.withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: stepColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  stepColor,
                  stepColor.withValues(alpha: 0.8),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: stepColor.withValues(alpha: 0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$step',
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: stepColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: stepColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: stepColor.withValues(alpha: 0.5), size: 18),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 100 * step))
        .fadeIn()
        .slideX(begin: 0.15, end: 0);
  }

  Widget _buildCOMSECOverviewWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.withValues(alpha: 0.1),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.security, size: 50, color: Colors.red)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05)),
          const SizedBox(height: 12),
          Text(
            'COMSEC',
            style: AppTextStyles.headlineSmall.copyWith(color: Colors.red),
          ),
          Text(
            'Communications Security',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCOMSECElement('TRANSEC', Icons.swap_horiz),
              _buildCOMSECElement('CRYPTO', Icons.lock),
              _buildCOMSECElement('EMSEC', Icons.wifi_off),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCOMSECElement(String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.red.shade300, size: 28),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }

  Widget _buildTRANSECWidget() {
    return Column(
      children: [
        _buildTRANSECItem('EMCON', 'ควบคุมการแผ่คลื่น', Icons.volume_off, Colors.grey),
        _buildTRANSECItem('FHSS', 'กระโดดความถี่', Icons.shuffle, AppColors.epColor),
        _buildTRANSECItem('Low Power', 'ใช้กำลังต่ำ', Icons.signal_cellular_alt, Colors.orange),
        _buildTRANSECItem('Short TX', 'ส่งสั้นๆ', Icons.timer, Colors.blue),
      ],
    );
  }

  Widget _buildTRANSECItem(String title, String desc, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelMedium.copyWith(color: color)),
                Text(desc, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEncryptionWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Icon(Icons.message, color: Colors.blue, size: 30),
                  Text('Plain', style: AppTextStyles.labelSmall),
                ],
              ),
              const SizedBox(width: 16),
              Icon(Icons.arrow_forward, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Icon(Icons.lock, color: Colors.green, size: 36)
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 2.seconds),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward, color: AppColors.textSecondary),
              const SizedBox(width: 16),
              Column(
                children: [
                  Icon(Icons.code, color: Colors.orange, size: 30),
                  Text('Cipher', style: AppTextStyles.labelSmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'ข้อความถูกเข้ารหัส → ข้าศึกอ่านไม่ได้',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioProceduresWidget() {
    return Column(
      children: [
        _buildProcedureItem('Roger', 'รับทราบ', true),
        _buildProcedureItem('Wilco', 'จะปฏิบัติ', true),
        _buildProcedureItem('Out', 'จบการส่ง', true),
        _buildProcedureItem('เอ่ยชื่อจริง', 'ห้าม!', false),
      ],
    );
  }

  Widget _buildProcedureItem(String code, String meaning, bool isDo) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDo ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isDo ? Icons.check_circle : Icons.cancel,
            color: isDo ? Colors.green : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            code,
            style: AppTextStyles.labelMedium.copyWith(
              color: isDo ? Colors.green : Colors.red,
            ),
          ),
          const Spacer(),
          Text(meaning, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  // ==================== Module 7: SOPs & Checklists Widgets ====================

  Widget _buildSOPsOverviewWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.description, size: 50, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            'Standard Operating Procedures',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSOPBenefit(Icons.speed, 'เร็ว'),
              _buildSOPBenefit(Icons.check_circle, 'ถูกต้อง'),
              _buildSOPBenefit(Icons.groups, 'มาตรฐาน'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSOPBenefit(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }

  Widget _buildPreMissionWidget() {
    return Column(
      children: [
        _buildCheckItem('ตรวจวิทยุ', true),
        _buildCheckItem('แบตเตอรี่เต็ม', true),
        _buildCheckItem('เสาอากาศพร้อม', true),
        _buildCheckItem('รับ CEOI/SOI', true),
        _buildCheckItem('Radio Check', false),
      ],
    );
  }

  Widget _buildCheckItem(String text, bool checked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_box : Icons.check_box_outline_blank,
            color: checked ? Colors.green : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              decoration: checked ? TextDecoration.lineThrough : null,
              color: checked ? AppColors.textSecondary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuringMissionWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.1),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber, color: Colors.orange, size: 30),
              const SizedBox(width: 8),
              Text(
                'เมื่อถูกรบกวน',
                style: AppTextStyles.titleMedium.copyWith(color: Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildECCMAction(1, 'ตรวจสอบอุปกรณ์'),
          _buildECCMAction(2, 'เปลี่ยนความถี่สำรอง'),
          _buildECCMAction(3, 'รายงานหน่วยเหนือ'),
          _buildECCMAction(4, 'ปฏิบัติตาม ECCM'),
        ],
      ),
    );
  }

  Widget _buildECCMAction(int step, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.orange,
            child: Text('$step', style: AppTextStyles.labelSmall.copyWith(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Text(text, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildMIJIReportWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            'MIJI REPORT',
            style: AppTextStyles.titleMedium.copyWith(color: Colors.red),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMIJIType('M', 'Meaconing'),
              _buildMIJIType('I', 'Intrusion'),
              _buildMIJIType('J', 'Jamming'),
              _buildMIJIType('I', 'Interference'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMIJIType(String letter, String meaning) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(letter, style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 4),
        Text(meaning, style: AppTextStyles.labelSmall),
      ],
    );
  }

  Widget _buildChecklistOverviewWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.checklist, size: 50, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            'Checklists ที่ใช้บ่อย',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          _buildChecklistItem('Daily Check'),
          _buildChecklistItem('Pre-Mission'),
          _buildChecklistItem('COMSEC'),
          _buildChecklistItem('Maintenance'),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.assignment, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(name, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildDailyCheckWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Daily Equipment Check',
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          _buildDailyItem('ภายนอก', Icons.visibility),
          _buildDailyItem('แบตเตอรี่', Icons.battery_full),
          _buildDailyItem('เสาอากาศ', Icons.settings_input_antenna),
          _buildDailyItem('ทดสอบ', Icons.play_arrow),
        ],
      ),
    );
  }

  Widget _buildDailyItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_box_outline_blank, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(text, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildCOMSECCheckWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security, color: Colors.red, size: 28),
              const SizedBox(width: 8),
              Text(
                'COMSEC Checklist',
                style: AppTextStyles.labelMedium.copyWith(color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCOMSECItem('เอกสาร CEOI/SOI'),
          _buildCOMSECItem('อุปกรณ์เข้ารหัส'),
          _buildCOMSECItem('การปฏิบัติ'),
          _buildCOMSECItem('แผนการทำลาย'),
        ],
      ),
    );
  }

  Widget _buildCOMSECItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_box_outline_blank, color: Colors.red.shade300),
          const SizedBox(width: 8),
          Text(text, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildCourseSummaryWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.epColor.withValues(alpha: 0.1),
            AppColors.eaColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.military_tech, size: 60, color: Colors.amber)
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 2.seconds),
          const SizedBox(height: 12),
          Text(
            'หลักสูตรนายสิบชั้นต้น',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
          ),
          Text(
            'สงครามอิเล็กทรอนิกส์',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'เสร็จสิ้น 7 โมดูล',
                  style: AppTextStyles.labelMedium.copyWith(color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonWidget() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.construction,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'เนื้อหากำลังพัฒนา',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'บทที่ ${widget.module.moduleNumber + 1}',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(
                _pages.length,
                (index) => Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index <= _currentPage
                          ? widget.module.color
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final page = _pages[index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        page.title,
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: widget.module.color,
                        ),
                      ).animate().fadeIn().slideX(),
                      const SizedBox(height: 16),

                      // Content FIRST (above widget) - ensures proper stacking
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            page.content,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.6,
                            ),
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                      ),
                      const SizedBox(height: 16),

                      // Visual widget BELOW content
                      if (page.visualWidget != null) ...[
                        SizedBox(
                          width: double.infinity,
                          child: page.visualWidget!,
                        ),
                        const SizedBox(height: 16),
                      ],

                      const SizedBox(height: 100), // Space for button
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('ย้อนกลับ'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              if (_currentPage > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      // Lesson complete
                      _showLessonComplete();
                    }
                  },
                  icon: Icon(_currentPage < _pages.length - 1
                      ? Icons.arrow_forward
                      : Icons.check),
                  label: Text(_currentPage < _pages.length - 1
                      ? 'ถัดไป'
                      : 'เสร็จสิ้น'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.module.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLessonComplete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.celebration, color: widget.module.color),
            const SizedBox(width: 8),
            const Text('ยินดีด้วย!'),
          ],
        ),
        content: Text(
          'คุณเรียนจบบทเรียน "${widget.lesson.titleTh}" แล้ว',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to module
            },
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  // ==================== บทที่ 16: การประมาณการ EW ====================

  List<LessonPage> _ewEstimatePages() {
    return [
      LessonPage(
        title: 'การประมาณการ EW',
        content: '''
📋 การประมาณการ EW (EW Estimate)

📌 วัตถุประสงค์:
เครื่องมือช่วยผู้บังคับบัญชาในการตัดสินใจ
เพื่อหาหนทางปฏิบัติ (COA) ที่ดีที่สุด

📝 รูปแบบ: ข้อเขียนหรือปากเปล่า (ขึ้นกับเวลา)

🎯 ผู้ทำ: นายทหารฝ่ายอำนวยการ (สธ.3/สธ.4)

🔄 ประสานงาน:
• สธ.2 (ข่าวกรอง)
• สธ.3 (ยุทธการ)
• สธ.4 (การสื่อสาร)
''',
        visualWidget: _buildEWEstimateOverviewWidget(),
      ),
      LessonPage(
        title: '5 ขั้นตอนการประมาณการ',
        content: '''
📊 รูปแบบการประมาณการ EW:

1️⃣ ภารกิจ (Mission)
   ระบุภารกิจ EW ที่เจาะจง
   • ใคร ทำอะไร เพื่ออะไร

2️⃣ สถานการณ์และหนทางปฏิบัติ
   ก. ข้อพิจารณาที่มีผลกระทบ
   ข. สถานการณ์ข้าศึก
   ค. สถานการณ์ฝ่ายเรา

3️⃣ วิเคราะห์หนทางปฏิบัติ
   • จุดแข็ง-จุดอ่อนแต่ละ COA

4️⃣ เปรียบเทียบหนทางปฏิบัติ
   • เลือก COA ที่ดีที่สุด

5️⃣ ข้อเสนอ
   • แปล COA เป็นข้อเสนอสมบูรณ์ (5W1H)
''',
        visualWidget: _buildEWEstimateStepsWidget(),
      ),
      LessonPage(
        title: 'สถานการณ์ข้าศึก',
        content: '''
📊 การวิเคราะห์สถานการณ์ข้าศึก:

🎯 ขีดความสามารถ:
• EOB (Electronic Order of Battle)
• ระบบ ESM/ECM/ECCM ของข้าศึก
• หน่วย EW และที่ตั้ง
• หลักนิยมการใช้ (Doctrine)

📊 กิจกรรมที่สำคัญ:
• การใช้ EW ล่าสุด
• รูปแบบการปฏิบัติ
• ความถี่ที่ใช้

⚠️ ความล่อแหลมต่ออันตราย:
• จุดอ่อนของระบบ C³I
• ขาดแคลนกำลังพล/เครื่องมือ
• ระบบที่เป็นเป้าหมายสำคัญ

🎯 หนทางปฏิบัติข้าศึก (ไม่เกิน 3-4 COA)
''',
        visualWidget: _buildEnemySituationWidget(),
      ),
      LessonPage(
        title: 'สถานการณ์ฝ่ายเรา',
        content: '''
📊 การวิเคราะห์สถานการณ์ฝ่ายเรา:

🛡️ ขีดความสามารถ:
• หน่วย EW (จัด/บรรจุ/สมทบ)
• เครื่องมือ ESM/ECM/ECCM
• กำลังพลและความชำนาญ

⚠️ ความล่อแหลมต่ออันตราย:
• จุดอ่อนของระบบของเรา
• ข้อจำกัดของเครื่องมือ

📊 การเปรียบเทียบ:
• ใครมีเครื่องมือดีกว่า
• ใครมีกำลังพลมากกว่า/เก่งกว่า
• ใครมีตำแหน่งเหนือกว่า
• ใครมีความได้เปรียบ

🎯 หนทางปฏิบัติของฝ่ายเรา:
• COA 1: เน้น ESM
• COA 2: เน้น ECM
• COA 3: เน้น ECCM
• COA 4: ผสมผสาน
''',
        visualWidget: _buildFriendlySituationWidget(),
      ),
      LessonPage(
        title: 'ตัวอย่างข้อเสนอ',
        content: '''
📋 รูปแบบข้อเสนอ (5W1H):

✅ ตัวอย่าง:

"ร้อย ปสอ.ทบ. (ใคร)
 ปฏิบัติการก่อกวน (ทำอะไร)
 ข่ายการสื่อสารของ กรม ร.75 (เป้าหมาย)
 ในพื้นที่พิกัด... (ที่ไหน)
 ในขั้นตอนที่ 2 (เมื่อใด)
 โดยใช้ Spot Jamming (อย่างไร)
 เพื่อขัดขวางการบังคับบัญชา (ทำไม)"

📌 องค์ประกอบ:
• Who - ใคร (หน่วยไหนทำ)
• What - ทำอะไร (ESM/ECM/ECCM)
• Where - ที่ไหน (ตำแหน่ง)
• When - เมื่อใด (เวลา/ขั้นตอน)
• How - อย่างไร (วิธีการ)
• Why - ทำไม (วัตถุประสงค์)
''',
        visualWidget: _buildProposalExampleWidget(),
      ),
    ];
  }

  // Widget สำหรับ EW Estimate Overview
  Widget _buildEWEstimateOverviewWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.description, color: Colors.cyan, size: 24),
              SizedBox(width: 8),
              Text(
                'EW Estimate',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'ผบ. → สธ.3/4 → COA → ตัดสินใจ',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEWEstimateStepsWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildEstimateStep('1', 'ภารกิจ', Colors.blue),
          _buildEstimateStep('2', 'สถานการณ์', Colors.orange),
          _buildEstimateStep('3', 'วิเคราะห์', Colors.purple),
          _buildEstimateStep('4', 'เปรียบเทียบ', Colors.green),
          _buildEstimateStep('5', 'ข้อเสนอ', Colors.red),
        ],
      ),
    );
  }

  Widget _buildEstimateStep(String num, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color),
            ),
            child: Center(
              child: Text(num, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildEnemySituationWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔴 ข้าศึก', style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(children: [Text('📡', style: TextStyle(fontSize: 20)), Text('EOB', style: TextStyle(color: Colors.white70, fontSize: 10))]),
              Column(children: [Text('⚡', style: TextStyle(fontSize: 20)), Text('ขีดความสามารถ', style: TextStyle(color: Colors.white70, fontSize: 10))]),
              Column(children: [Text('⚠️', style: TextStyle(fontSize: 20)), Text('จุดอ่อน', style: TextStyle(color: Colors.white70, fontSize: 10))]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFriendlySituationWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔵 ฝ่ายเรา', style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(children: [Text('🛡️', style: TextStyle(fontSize: 20)), Text('ขีดความสามารถ', style: TextStyle(color: Colors.white70, fontSize: 10))]),
              Column(children: [Text('📊', style: TextStyle(fontSize: 20)), Text('เปรียบเทียบ', style: TextStyle(color: Colors.white70, fontSize: 10))]),
              Column(children: [Text('🎯', style: TextStyle(fontSize: 20)), Text('COAs', style: TextStyle(color: Colors.white70, fontSize: 10))]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProposalExampleWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('📋 5W1H', style: TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: [
              Chip(label: Text('Who', style: TextStyle(fontSize: 10)), backgroundColor: Colors.green),
              Chip(label: Text('What', style: TextStyle(fontSize: 10)), backgroundColor: Colors.green),
              Chip(label: Text('Where', style: TextStyle(fontSize: 10)), backgroundColor: Colors.green),
              Chip(label: Text('When', style: TextStyle(fontSize: 10)), backgroundColor: Colors.green),
              Chip(label: Text('How', style: TextStyle(fontSize: 10)), backgroundColor: Colors.green),
              Chip(label: Text('Why', style: TextStyle(fontSize: 10)), backgroundColor: Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  List<LessonPage> _ewAnnexPages() {
    return [
      LessonPage(
        title: 'ผนวก EW',
        content: '''
📋 ผนวก EW ประกอบคำสั่งยุทธการ

📌 ลักษณะ: เป็น Combat Order
🎯 วัตถุประสงค์: ให้รายละเอียดภารกิจ EW
👤 ผู้รับผิดชอบ: สธ.3 ประสาน สธ.2, สธ.4, ผบ.หน่วย EW
📁 เป็นส่วนหนึ่งของ: คำสั่งยุทธการ/แผนยุทธการ

📊 โครงสร้าง 5 ข้อ:
1. สถานการณ์
2. ภารกิจ
3. การปฏิบัติ
4. การบริการสนับสนุน
5. การบังคับบัญชาและการสื่อสาร

+ อนุผนวก (Appendices)
''',
        visualWidget: _buildEWAnnexWidget(),
      ),
      LessonPage(
        title: 'โครงสร้างผนวก EW',
        content: '''
📋 โครงสร้างผนวก EW:

1️⃣ สถานการณ์
   ก. กำลังฝ่ายข้าศึก
      • อ้างผนวกข่าวกรอง
      • EOB ของข้าศึก
      • ขีดความสามารถ EW
   ข. กำลังฝ่ายเรา
      • หน่วย EW ที่มี
      • ขีดความสามารถ

2️⃣ ภารกิจ
   • คำกล่าวภารกิจ EW เจาะจง
   • สั้น สมบูรณ์ ชัดเจน

3️⃣ การปฏิบัติ
   ก. แนวความคิด
   ข. คำแนะนำหน่วยรอง
   ค. คำแนะนำประสานงาน
''',
        visualWidget: _buildAnnexStructureWidget(),
      ),
      LessonPage(
        title: 'อนุผนวก EW',
        content: '''
📎 อนุผนวก (Appendices):

1️⃣ อนุผนวก 1: EOB ของข้าศึก
   ทำเนียบอิเล็กทรอนิกส์โดยละเอียด

2️⃣ อนุผนวก 2: การสนับสนุนการข่าวกรอง
   PIR, รายงาน, การประสาน

3️⃣ อนุผนวก 3: ECM
   Target List, Jamming Schedule

4️⃣ อนุผนวก 4: ECCM
   นโยบาย, กรรมวิธี, การฝึก

5️⃣ อนุผนวก 5: คำขอการสนับสนุน EW
   Request format, การประสาน

6️⃣ อนุผนวก 6: MIJI Reporting
   รูปแบบรายงาน, ขั้นตอน
''',
        visualWidget: _buildAppendicesWidget(),
      ),
    ];
  }

  Widget _buildEWAnnexWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('📋 ผนวก EW', style: TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('ประกอบคำสั่งยุทธการ', style: TextStyle(color: Colors.white70, fontSize: 11)),
          SizedBox(height: 8),
          Text('5 ข้อ + อนุผนวก', style: TextStyle(color: Colors.orange, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAnnexStructureWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAnnexItem('1', 'สถานการณ์'),
          _buildAnnexItem('2', 'ภารกิจ'),
          _buildAnnexItem('3', 'การปฏิบัติ'),
          _buildAnnexItem('4', 'การบริการ'),
          _buildAnnexItem('5', 'บังคับบัญชา'),
        ],
      ),
    );
  }

  Widget _buildAnnexItem(String num, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$num. ', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAppendicesWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Wrap(
        spacing: 6,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: [
          Chip(label: Text('EOB', style: TextStyle(fontSize: 9)), backgroundColor: Colors.deepOrange),
          Chip(label: Text('ESM', style: TextStyle(fontSize: 9)), backgroundColor: Colors.amber),
          Chip(label: Text('ECM', style: TextStyle(fontSize: 9)), backgroundColor: Colors.red),
          Chip(label: Text('ECCM', style: TextStyle(fontSize: 9)), backgroundColor: Colors.green),
          Chip(label: Text('Request', style: TextStyle(fontSize: 9)), backgroundColor: Colors.blue),
          Chip(label: Text('MIJI', style: TextStyle(fontSize: 9)), backgroundColor: Colors.purple),
        ],
      ),
    );
  }

  List<LessonPage> _ewPrioritiesPages() {
    return [
      LessonPage(
        title: 'ลำดับความสำคัญ EW',
        content: '''
📊 ลำดับความสำคัญของการยุทธทางอิเล็กทรอนิกส์:

🥇 ลำดับที่ 1 (สูงสุด):
   🎯 ป้องกันระบบ C³I ของฝ่ายเรา

   เหตุผล:
   ผลการรบขึ้นอยู่กับความสามารถในการควบคุม
   ทางอิเล็กทรอนิกส์ต่อกำลังและระบบอาวุธของเรา

🥈 ลำดับที่ 2 (สูง):
   🎯 โจมตีปืนใหญ่และจรวดข้าศึก

   เหตุผล:
   ข้าศึกมีขีดความสามารถปืนใหญ่เหนือกว่า
   ทั้งอำนาจการยิงและระยะ
''',
        visualWidget: _buildPriority12Widget(),
      ),
      LessonPage(
        title: 'ลำดับ 3-4',
        content: '''
🥉 ลำดับที่ 3 (ปานกลาง):
   🎯 ทำลายความสามารถป้องกันภัยทางอากาศข้าศึก

   เหตุผล:
   เพื่อให้กำลังทางอากาศของเราปฏิบัติการได้

   มาตรการ:
   ✅ หาที่ตั้งระบบกำหนดเป้าหมาย
   ✅ รบกวน/ทำลายเรดาร์ป้องกันภัยทางอากาศ
   ✅ ประสานร่วมกับกองทัพอากาศ

4️⃣ ลำดับที่ 4 (ปกติ):
   🎯 รบกวนระบบสื่อสารข้าศึก

   เหตุผล:
   เมื่อข้าศึกถูกบังคับให้เปลี่ยนแผน
   จะต้องพึ่งการสื่อสารมากขึ้น

💡 หมายเหตุ:
ลำดับความสำคัญอาจเปลี่ยนแปลงตามสถานการณ์
''',
        visualWidget: _buildPriority34Widget(),
      ),
    ];
  }

  Widget _buildPriority12Widget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPriorityRow('🥇', '1', 'ป้องกัน C³I ของเรา', Colors.amber),
          const SizedBox(height: 8),
          _buildPriorityRow('🥈', '2', 'โจมตี ปืนใหญ่/จรวด', Colors.grey),
        ],
      ),
    );
  }

  Widget _buildPriority34Widget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPriorityRow('🥉', '3', 'ทำลาย AD ข้าศึก', Colors.orange),
          const SizedBox(height: 8),
          _buildPriorityRow('4️⃣', '4', 'รบกวน COMMS', Colors.blue),
        ],
      ),
    );
  }

  Widget _buildPriorityRow(String medal, String num, String desc, Color color) {
    return Row(
      children: [
        Text(medal, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(desc, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ),
      ],
    );
  }

  // ==================== บทที่ 17: การจัดตั้งหน่วย EW ====================

  List<LessonPage> _ewOrgConsiderationsPages() {
    return [
      LessonPage(
        title: 'หลักการจัดตั้งหน่วย EW',
        content: '''
📊 ข้อพิจารณาในการจัดตั้งหน่วย EW:

1️⃣ การประเมินภัยคุกคาม
   • เขียน EOB ของข้าศึก
   • จุดอ่อนของข้าศึกใน ESM/ECM
   • ข้อได้เปรียบเมื่อใช้หน่วย EW

2️⃣ การจัดหน่วยเข้าสนับสนุน
   • หน่วยยุทธวิธีขนาดเล็ก → รวบรวมข่าวเร็ว
   • หน่วยระดับสูง → วิเคราะห์ละเอียด

3️⃣ การกำหนดภารกิจ
   • ภารกิจชัดเจน เจาะจง

4️⃣ งบประมาณ
   💰 กำลังพล | ยุทโธปกรณ์ | ส่งกำลังบำรุง
''',
        visualWidget: _buildOrgConsiderationsWidget(),
      ),
      LessonPage(
        title: 'ความต้องการยุทโธปกรณ์และกำลังพล',
        content: '''
🔧 ความต้องการยุทโธปกรณ์:

✅ ใช้เทคนิคใหม่ในการหาทิศ
✅ กวาดตรวจได้อย่างรวดเร็ว
✅ มีการสนับสนุนทางส่งกำลังบำรุง
✅ ใช้คอมพิวเตอร์ควบคุม
✅ มีแหล่งจ่ายกำลังงานเคลื่อนที่
✅ ส่วนประกอบเป็นโมดูล ซ่อมบำรุงง่าย

📌 เลือกตาม EOB ข้าศึกเป็นหลัก

👥 ความต้องการกำลังพล:

🎖️ หัวหน้าชุด:
   • มีประสบการณ์ EW สูง
   • มีความรู้ภาษาต่างประเทศ (ข้าศึก)

📊 จำนวน:
   • เพียงพอหมุนเวียน 24 ชม.
   • 3 เวร + สำรอง
''',
        visualWidget: _buildRequirementsWidget(),
      ),
    ];
  }

  Widget _buildOrgConsiderationsWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('📊 ข้อพิจารณา', style: TextStyle(color: Colors.teal, fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(children: [Text('1', style: TextStyle(color: Colors.teal, fontSize: 16, fontWeight: FontWeight.bold)), Text('ภัยคุกคาม', style: TextStyle(color: Colors.white70, fontSize: 9))]),
              Column(children: [Text('2', style: TextStyle(color: Colors.teal, fontSize: 16, fontWeight: FontWeight.bold)), Text('สนับสนุน', style: TextStyle(color: Colors.white70, fontSize: 9))]),
              Column(children: [Text('3', style: TextStyle(color: Colors.teal, fontSize: 16, fontWeight: FontWeight.bold)), Text('ภารกิจ', style: TextStyle(color: Colors.white70, fontSize: 9))]),
              Column(children: [Text('4', style: TextStyle(color: Colors.teal, fontSize: 16, fontWeight: FontWeight.bold)), Text('งบประมาณ', style: TextStyle(color: Colors.white70, fontSize: 9))]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildReqItem('🔧', 'ยุทโธปกรณ์'),
          _buildReqItem('👥', 'กำลังพล'),
          _buildReqItem('💰', 'งบประมาณ'),
        ],
      ),
    );
  }

  Widget _buildReqItem(String icon, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  List<LessonPage> _ewBattalionPages() {
    return [
      LessonPage(
        title: 'พัน ปสอ.',
        content: '''
🏛️ พัน ปสอ. (กองพันปฏิบัติการสงครามอิเล็กทรอนิกส์)
Electronic Warfare Battalion

📌 ระดับ: บก.ทหารสูงสุด

🎯 ภารกิจ:
ปฏิบัติการสงครามอิเล็กทรอนิกส์และการเฝ้าตรวจเป็นพื้นที่
สนับสนุนโดยทั่วไปแก่เหล่าทัพและส่วนราชการที่เกี่ยวข้อง

📊 ขีดความสามารถ:
📡 ปฏิบัติการ EW
   • ดักรับ เฝ้าฟัง ค้นหาที่ตั้งวิทยุและเรดาร์
   • วิเคราะห์ข่าวกรองทางการสื่อสาร
   • รบกวน ปลอมลวง ลวงเลียน

👁️ เฝ้าตรวจเป็นพื้นที่ด้วยเรดาร์

⚔️ ทำการรบอย่างทหารราบอย่างจำกัด
''',
        visualWidget: _buildBattalionWidget(),
      ),
      LessonPage(
        title: 'โครงสร้าง พัน ปสอ.',
        content: '''
📊 โครงสร้าง พัน ปสอ.:

   พัน ปสอ.
   ├── บก./ร้อย บก.
   ├── ร้อย ปสอ. (หลายร้อย)
   ├── ร้อยเฝ้าตรวจภาคพื้นดิน
   └── ร้อยสนับสนุน

📋 หน่วยย่อย:

🏢 บก./ร้อย บก.
   บังคับบัญชาและประสานงาน

📡 ร้อย ปสอ.
   ปฏิบัติการ ESM/ECM

👁️ ร้อยเฝ้าตรวจภาคพื้นดิน
   เฝ้าตรวจด้วยเรดาร์และเซ็นเซอร์

🔧 ร้อยสนับสนุน
   ส่งกำลังบำรุง ซ่อมบำรุง
''',
        visualWidget: _buildBattalionOrgWidget(),
      ),
    ];
  }

  Widget _buildBattalionWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.withValues(alpha: 0.3)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🏛️ พัน ปสอ.', style: TextStyle(color: Colors.indigo, fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('ระดับ บก.ทหารสูงสุด', style: TextStyle(color: Colors.white70, fontSize: 11)),
          SizedBox(height: 8),
          Text('EW + เฝ้าตรวจ + การรบ', style: TextStyle(color: Colors.indigo, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBattalionOrgWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('พัน ปสอ.', style: TextStyle(color: Colors.indigo, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildUnitBox('บก.', Colors.grey),
              _buildUnitBox('ร้อย ปสอ.', Colors.amber),
              _buildUnitBox('ร้อย GSR', Colors.blue),
              _buildUnitBox('ร้อย สน.', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnitBox(String name, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(name, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  List<LessonPage> _ewCompanyPages() {
    return [
      LessonPage(
        title: 'ร้อย ปสอ.',
        content: '''
🏢 ร้อย ปสอ. (กองร้อยปฏิบัติการสงครามอิเล็กทรอนิกส์)
Electronic Warfare Company

🎯 ภารกิจ:
ปฏิบัติการสงครามอิเล็กทรอนิกส์ทั้งเชิงรุกและเชิงรับ
ตามนโยบายและแผนการสื่อสารของหน่วยที่รับผิดชอบ

📊 ขีดความสามารถ:
✅ ปฏิบัติการ EW สนับสนุนการปฏิบัติการทางทหาร
✅ ดำเนินการดักรับ เฝ้าฟัง ค้นหา วิเคราะห์
✅ ดำเนินการรบกวน ขัดขวาง ปลอมลวง ลวงเลียน
✅ ทำการรบอย่างทหารราบได้อย่างจำกัด
''',
        visualWidget: _buildCompanyWidget(),
      ),
      LessonPage(
        title: 'โครงสร้าง ร้อย ปสอ.',
        content: '''
📊 โครงสร้าง ร้อย ปสอ.:

   ร้อย ปสอ.
   ├── บก.ร้อย
   ├── มว.ปฏิบัติการ
   │   ├── ตอนดักรับ/เฝ้าฟัง
   │   └── ตอนหาทิศ (DF)
   ├── มว.วิเคราะห์ข่าว
   │   └── ตอนวิเคราะห์ข่าว
   └── มว.รบกวน
       └── ตอนรบกวน

📋 หน้าที่แต่ละหมวด:

📡 มว.ปฏิบัติการ: ดักรับ + หาทิศ
📊 มว.วิเคราะห์: วิเคราะห์ + สร้าง EOB
🔊 มว.รบกวน: ก่อกวน + ลวง
''',
        visualWidget: _buildCompanyOrgWidget(),
      ),
    ];
  }

  Widget _buildCompanyWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🏢 ร้อย ปสอ.', style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('ระดับกองร้อย', style: TextStyle(color: Colors.white70, fontSize: 11)),
          SizedBox(height: 8),
          Text('เชิงรุก + เชิงรับ', style: TextStyle(color: Colors.amber, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCompanyOrgWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('ร้อย ปสอ.', style: TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPlatoonBox('มว.ปฏิบัติการ', '📡', Colors.blue),
              _buildPlatoonBox('มว.วิเคราะห์', '📊', Colors.green),
              _buildPlatoonBox('มว.รบกวน', '🔊', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlatoonBox(String name, String icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
        ),
        const SizedBox(height: 4),
        Text(name, style: TextStyle(color: color, fontSize: 8)),
      ],
    );
  }

  // ==================== บทที่ 18: ยุทธวิธี EW ====================

  List<LessonPage> _modernBattlefieldPages() {
    return [
      LessonPage(
        title: 'สนามรบสมัยใหม่',
        content: '''
🎯 แนวความคิดในการทำสงครามอิเล็กทรอนิกส์:

📡 สนามรบสมัยใหม่:
การใช้คลื่นแม่เหล็กไฟฟ้าทางทหารได้เพิ่มเติมมิติใหม่
ให้แก่สงครามอิเล็กทรอนิกส์ในสนามรบ

⚔️ อำนาจกำลังรบ:
จะหมดความหมาย หากไม่สามารถนำมาใช้ได้ทันที
ณ ตำบลที่ถูกต้อง ณ เวลาที่ถูกต้อง

🔮 สนามรบอนาคต:
• การต่อสู้สำคัญจะเกี่ยวกับการเข้าตี/ป้องกัน
  ระบบทางการรบที่ใช้พลังงานคลื่นแม่เหล็กไฟฟ้า
• ระบบ C³I เป็นเป้าหมายสำคัญสำหรับ EW
• ใช้ EW เพื่อเพิ่มอำนาจกำลังรบ
  และลดขีดความสามารถของข้าศึก
''',
        visualWidget: _buildModernBattlefieldWidget(),
      ),
    ];
  }

  Widget _buildModernBattlefieldWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔮 สนามรบอนาคต', style: TextStyle(color: Colors.purple, fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(children: [Text('📡', style: TextStyle(fontSize: 24)), Text('EW', style: TextStyle(color: Colors.white70, fontSize: 10))]),
              Text('→', style: TextStyle(color: Colors.purple, fontSize: 20)),
              Column(children: [Text('🎯', style: TextStyle(fontSize: 24)), Text('C³I', style: TextStyle(color: Colors.white70, fontSize: 10))]),
              Text('→', style: TextStyle(color: Colors.purple, fontSize: 20)),
              Column(children: [Text('⚔️', style: TextStyle(fontSize: 24)), Text('ชนะ', style: TextStyle(color: Colors.white70, fontSize: 10))]),
            ],
          ),
        ],
      ),
    );
  }

  List<LessonPage> _enemyEWAnalysisPages() {
    return [
      LessonPage(
        title: 'ขีดความสามารถ EW ของข้าศึก',
        content: '''
📊 Radio Electronic Combat (REC):

📌 แนวคิดของข้าศึก:
รวมเอาการยิงปืนใหญ่และจรวดกับการก่อกวน
ทางอิเล็กทรอนิกส์เข้าด้วยกัน

🎯 วัตถุประสงค์:
ขจัดกำลังฝ่ายเราอย่างน้อย 50%
ในเรื่องระบบสื่อสารของการควบคุมบังคับบัญชา

📊 กระบวนการ:
1. วิเคราะห์การติดต่อสื่อสารด้วย COMINT
2. เลือกเป้าหมายที่สำคัญ
3. จัดลำดับความเร่งด่วน
4. ทำลายด้วยการยิงปืนใหญ่/จรวด
5. รบกวนเป้าหมายที่เหลือ

⚙️ อุปกรณ์ข้าศึก:
✅ ไม่ยุ่งยากสลับซับซ้อน
✅ มีจำนวนมากพอ
✅ เรียบง่าย เชื่อถือได้
''',
        visualWidget: _buildEnemyEWWidget(),
      ),
    ];
  }

  Widget _buildEnemyEWWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔴 REC', style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Radio Electronic Combat', style: TextStyle(color: Colors.white70, fontSize: 11)),
          SizedBox(height: 8),
          Text('COMINT → ยิง → รบกวน', style: TextStyle(color: Colors.red, fontSize: 12)),
        ],
      ),
    );
  }

  List<LessonPage> _ewTacticsPages() {
    return [
      LessonPage(
        title: 'EW เชิงรับ',
        content: '''
🛡️ EW เชิงรับ (Defensive EW):

📌 วัตถุประสงค์:
ป้องกันระบบ C³I ของกองพล

📋 การปฏิบัติ:
✅ ประสานการปฏิบัติเกี่ยวกับ EMCON
✅ จัดช่องการสื่อสารเร่งด่วน
   MIJI Report → DF → ยิงทำลาย
✅ จัดสรรความถี่ตามลำดับความเร่งด่วน:
   1. ผู้บังคับบัญชา
   2. ส่วนอำนวยการยิง
   3. ส่วนข่าวกรอง
   4. ส่วนส่งกำลังบำรุง
   5. ผู้ใช้อื่นๆ
✅ ลดการรบกวนโดยไม่จงใจ
✅ เครื่องมือก่อกวนต้องป้องกันจาก ESM ข้าศึก
''',
        visualWidget: _buildDefensiveEWWidget(),
      ),
      LessonPage(
        title: 'EW เชิงรุก',
        content: '''
⚔️ EW เชิงรุก (Offensive EW):

📌 วัตถุประสงค์:
ทำลายระบบ C³I ของข้าศึก

📊 2 ขั้นตอน:

1️⃣ ขั้นที่ 1: ก่อนปฏิบัติการ EW
   ESM + ECM รวบรวมข้อมูลอิเล็กทรอนิกส์
   • เน้นหน่วยระดับกองพัน-กรม
   • ในเขตรับผิดชอบของเรา
   → เป็นข้อมูลสำหรับ ECM ต่อไป

2️⃣ ขั้นที่ 2: การก่อกวน
   ทำลายระบบ C³I ตาม Target List

   ลำดับความเร่งด่วน:
   1️⃣ สนับสนุน Defensive EW
   2️⃣ สนับสนุนภารกิจ ทอ.
   3️⃣ ทำลายระบบ C³I ข้าศึก
''',
        visualWidget: _buildOffensiveEWWidget(),
      ),
      LessonPage(
        title: 'หลักการสำคัญ',
        content: '''
💡 หลักการสำคัญของ EW:

1️⃣ EW ไม่ใช่การปฏิบัติการแยกต่างหาก
   แต่เป็นส่วนหนึ่งของการปฏิบัติการทางทหารโดยรวม

2️⃣ EW ต้องบูรณาการกับ:
   • การยิงปืนใหญ่
   • การโจมตีทางอากาศ
   • การดำเนินกลยุทธ
   • การข่าวกรอง

3️⃣ การประสานงานสำคัญ:
   ESM → ECM → ยิงทำลาย → ดำเนินกลยุทธ

4️⃣ ความต่อเนื่อง:
   ESM ตลอดเวลา | ECM ตามแผน | ECCM อยู่เสมอ

5️⃣ ความยืดหยุ่น:
   ปรับแผน EW ให้ทันสถานการณ์

6️⃣ การฝึกเป็นกุญแจ:
   พนักงานชำนาญ | ผบ.เข้าใจ | ฝึกร่วมหน่วยอื่น
''',
        visualWidget: _buildKeyPrinciplesWidget(),
      ),
    ];
  }

  Widget _buildDefensiveEWWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🛡️ Defensive EW', style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('ป้องกัน C³I ของเรา', style: TextStyle(color: Colors.white70, fontSize: 11)),
          SizedBox(height: 8),
          Text('EMCON | SIGSEC | MIJI', style: TextStyle(color: Colors.blue, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildOffensiveEWWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('⚔️ Offensive EW', style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('ทำลาย C³I ข้าศึก', style: TextStyle(color: Colors.white70, fontSize: 11)),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('ESM', style: TextStyle(color: Colors.amber)),
              Text(' → ', style: TextStyle(color: Colors.grey)),
              Text('ECM', style: TextStyle(color: Colors.red)),
              Text(' → ', style: TextStyle(color: Colors.grey)),
              Text('ยิง', style: TextStyle(color: Colors.orange)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyPrinciplesWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('💡 หลักการ EW', style: TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: [
              Chip(label: Text('บูรณาการ', style: TextStyle(fontSize: 9)), backgroundColor: Colors.green),
              Chip(label: Text('ประสาน', style: TextStyle(fontSize: 9)), backgroundColor: Colors.green),
              Chip(label: Text('ต่อเนื่อง', style: TextStyle(fontSize: 9)), backgroundColor: Colors.green),
              Chip(label: Text('ยืดหยุ่น', style: TextStyle(fontSize: 9)), backgroundColor: Colors.green),
              Chip(label: Text('ฝึก', style: TextStyle(fontSize: 9)), backgroundColor: Colors.green),
            ],
          ),
        ],
      ),
    );
  }
}

/// โครงสร้างหน้าบทเรียน
class LessonPage {
  final String title;
  final String content;
  final Widget? visualWidget;

  LessonPage({
    required this.title,
    required this.content,
    this.visualWidget,
  });
}

/// Spectrum Painter
class _SpectrumPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.8);

    // Draw random spectrum-like peaks
    for (double x = 0; x < size.width; x += 5) {
      final y = size.height * 0.8 -
          (x % 50 < 10 ? 60 : 10) * (1 + math.sin(x / 100));
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.green.withOpacity(0.3)
      ..strokeWidth = 0.5;

    for (int i = 0; i < 5; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Triangulation Painter for DF visualization
class _TriangulationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Draw stations A and B
    final stationA = Offset(30, size.height - 20);
    final stationB = Offset(size.width - 30, size.height - 20);
    final target = Offset(size.width / 2, 20);

    // Draw bearing lines
    canvas.drawLine(stationA, target, paint);
    canvas.drawLine(stationB, target, paint);

    // Draw stations
    canvas.drawCircle(stationA, 8, fillPaint);
    canvas.drawCircle(stationB, 8, fillPaint);
    canvas.drawCircle(stationA, 8, paint);
    canvas.drawCircle(stationB, 8, paint);

    // Draw target
    final targetPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(target, 10, targetPaint);

    // Labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    textPainter.text = const TextSpan(
      text: 'A',
      style: TextStyle(color: Colors.white, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, stationA - const Offset(3, -12));

    textPainter.text = const TextSpan(
      text: 'B',
      style: TextStyle(color: Colors.white, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, stationB - const Offset(3, -12));

    textPainter.text = const TextSpan(
      text: '📡',
      style: TextStyle(fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, target - const Offset(6, 6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simple Grid Painter for maps
class _SimpleGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    // Draw grid
    for (var i = 0; i < size.width; i += 25) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }
    for (var i = 0; i < size.height; i += 25) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simple Triangulation Painter for DF visualization
class _SimpleTriangulationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.esColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = AppColors.esColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Draw station positions (triangle points)
    final stationA = Offset(size.width * 0.2, size.height * 0.8);
    final stationB = Offset(size.width * 0.8, size.height * 0.8);
    final target = Offset(size.width * 0.5, size.height * 0.25);

    // Draw bearing lines from stations to target
    final linePaint = Paint()
      ..color = AppColors.esColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(stationA, target, linePaint);
    canvas.drawLine(stationB, target, linePaint);

    // Draw stations
    canvas.drawCircle(stationA, 8, paint);
    canvas.drawCircle(stationB, 8, paint);

    // Draw target with crosshair
    final targetPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(target, 10, targetPaint);
    canvas.drawLine(
      Offset(target.dx - 15, target.dy),
      Offset(target.dx + 15, target.dy),
      targetPaint,
    );
    canvas.drawLine(
      Offset(target.dx, target.dy - 15),
      Offset(target.dx, target.dy + 15),
      targetPaint,
    );

    // Draw triangle area
    final path = Path()
      ..moveTo(stationA.dx, stationA.dy)
      ..lineTo(stationB.dx, stationB.dy)
      ..lineTo(target.dx, target.dy)
      ..close();

    canvas.drawPath(path, fillPaint);

    // Labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Station A label
    textPainter.text = TextSpan(
      text: 'A',
      style: TextStyle(color: AppColors.esColor, fontSize: 12, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(stationA.dx - 4, stationA.dy + 12));

    // Station B label
    textPainter.text = TextSpan(
      text: 'B',
      style: TextStyle(color: AppColors.esColor, fontSize: 12, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(stationB.dx - 4, stationB.dy + 12));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simple Radar Painter for radar display visualization
class _SimpleRadarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Range rings
    final ringPaint = Paint()
      ..color = AppColors.radarColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * i / 3, ringPaint);
    }

    // Cross lines
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      ringPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      ringPaint,
    );

    // Radar sweep (static representation)
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: -math.pi / 2,
        endAngle: math.pi / 2,
        colors: [
          AppColors.radarColor.withValues(alpha: 0.0),
          AppColors.radarColor.withValues(alpha: 0.5),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi / 3,
      true,
      sweepPaint,
    );

    // Sample targets
    final targetPaint = Paint()
      ..color = AppColors.radarColor
      ..style = PaintingStyle.fill;

    // Draw a few blips
    canvas.drawCircle(Offset(center.dx + radius * 0.4, center.dy - radius * 0.3), 4, targetPaint);
    canvas.drawCircle(Offset(center.dx - radius * 0.2, center.dy + radius * 0.5), 3, targetPaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.6, center.dy + radius * 0.2), 3, targetPaint);

    // Border
    final borderPaint = Paint()
      ..color = AppColors.radarColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

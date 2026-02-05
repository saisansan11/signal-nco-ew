import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../app/constants.dart';

/// Map tile providers
enum MapStyle {
  satellite,
  dark,
  terrain,
}

/// EW Historical Era categories
enum EWEra {
  ww1,        // 1914-1918 สงครามโลกครั้งที่ 1
  ww2,        // 1939-1945 สงครามโลกครั้งที่ 2
  coldWar,    // 1947-1991 สงครามเย็น
  postColdWar, // 1991-2010 หลังสงครามเย็น
  modern,     // 2010-ปัจจุบัน ยุคปัจจุบัน
}

extension EWEraExtension on EWEra {
  String get thaiName {
    switch (this) {
      case EWEra.ww1:
        return 'สงครามโลกครั้งที่ 1';
      case EWEra.ww2:
        return 'สงครามโลกครั้งที่ 2';
      case EWEra.coldWar:
        return 'สงครามเย็น';
      case EWEra.postColdWar:
        return 'หลังสงครามเย็น';
      case EWEra.modern:
        return 'ยุคปัจจุบัน';
    }
  }

  String get yearRange {
    switch (this) {
      case EWEra.ww1:
        return '1914-1918';
      case EWEra.ww2:
        return '1939-1945';
      case EWEra.coldWar:
        return '1947-1991';
      case EWEra.postColdWar:
        return '1991-2010';
      case EWEra.modern:
        return '2010-ปัจจุบัน';
    }
  }

  Color get color {
    switch (this) {
      case EWEra.ww1:
        return const Color(0xFF8B4513); // Brown
      case EWEra.ww2:
        return const Color(0xFF696969); // Gray
      case EWEra.coldWar:
        return const Color(0xFF2E4057); // Navy blue
      case EWEra.postColdWar:
        return const Color(0xFF6B8E23); // Olive
      case EWEra.modern:
        return const Color(0xFF00BCD4); // Cyan
    }
  }
}

/// EW World Map Widget - Real map with historical EW events
class EWWorldMapWidget extends StatefulWidget {
  const EWWorldMapWidget({super.key});

  @override
  State<EWWorldMapWidget> createState() => _EWWorldMapWidgetState();
}

class _EWWorldMapWidgetState extends State<EWWorldMapWidget>
    with TickerProviderStateMixin {
  late final MapController _mapController;
  late AnimationController _pulseController;
  late AnimationController _markerAnimController;

  int _selectedEventIndex = -1;
  bool _isAutoTour = false;
  int _currentTourIndex = 0;
  MapStyle _currentMapStyle = MapStyle.satellite;

  // Filter for selected era
  EWEra? _selectedEra;

  final List<EWHistoricalEvent> _allEvents = [
    // ============ สงครามโลกครั้งที่ 1 (1914-1918) ============
    EWHistoricalEvent(
      id: 'tannenberg',
      title: 'ยุทธการแทนเนนเบิร์ก',
      year: 1914,
      location: 'ปรัสเซียตะวันออก',
      lat: 53.5,
      lon: 20.0,
      description: 'การใช้ข่าวกรองสัญญาณครั้งแรกในประวัติศาสตร์\n'
          'เยอรมันดักรับวิทยุรัสเซียที่ไม่เข้ารหัส\n'
          'ทำให้สามารถโจมตีล่วงหน้าและเอาชนะรัสเซียได้',
      significance: 'จุดเริ่มต้นของ SIGINT',
      icon: Icons.radio,
      color: AppColors.esColor,
      era: EWEra.ww1,
    ),
    EWHistoricalEvent(
      id: 'zimmermann',
      title: 'โทรเลข Zimmermann',
      year: 1917,
      location: 'ลอนดอน, อังกฤษ',
      lat: 51.5074,
      lon: -0.1278,
      description: 'อังกฤษถอดรหัสโทรเลขเยอรมัน\n'
          'เปิดเผยแผนดึงเม็กซิโกเข้าสงคราม\n'
          'ทำให้สหรัฐฯ เข้าร่วมสงครามโลกครั้งที่ 1',
      significance: 'Codebreaking เปลี่ยนประวัติศาสตร์',
      icon: Icons.lock_open,
      color: AppColors.esColor,
      era: EWEra.ww1,
    ),

    // ============ สงครามโลกครั้งที่ 2 (1939-1945) ============
    EWHistoricalEvent(
      id: 'britain',
      title: 'ยุทธการบริเตน',
      year: 1940,
      location: 'สหราชอาณาจักร',
      lat: 51.5074,
      lon: -0.5,
      description: 'ระบบ Chain Home Radar ป้องกันเกาะอังกฤษ\n'
          'ตรวจจับเครื่องบินเยอรมันล่วงหน้า\n'
          'ชัยชนะครั้งแรกที่เรดาร์มีบทบาทสำคัญ',
      significance: 'Radar เปลี่ยนแปลงสงคราม',
      icon: Icons.radar,
      color: AppColors.radarColor,
      era: EWEra.ww2,
    ),
    EWHistoricalEvent(
      id: 'pearl',
      title: 'เพิร์ลฮาร์เบอร์',
      year: 1941,
      location: 'ฮาวาย, สหรัฐฯ',
      lat: 21.3645,
      lon: -157.9761,
      description: 'เรดาร์ตรวจพบเครื่องบินญี่ปุ่นล่วงหน้า 1 ชม.\n'
          'แต่สัญญาณถูกมองข้าม คิดว่าเป็นฝ่ายเรา\n'
          'บทเรียนสำคัญ: ข้อมูลต้องวิเคราะห์ถูกต้อง',
      significance: 'บทเรียนการวิเคราะห์ข้อมูล',
      icon: Icons.warning_amber,
      color: AppColors.warning,
      era: EWEra.ww2,
    ),
    EWHistoricalEvent(
      id: 'midway',
      title: 'ยุทธนาวีมิดเวย์',
      year: 1942,
      location: 'เกาะมิดเวย์, แปซิฟิก',
      lat: 28.2072,
      lon: -177.3735,
      description: 'สหรัฐฯ ถอดรหัส JN-25 ของญี่ปุ่น\n'
          'รู้ล่วงหน้าว่าญี่ปุ่นจะโจมตีมิดเวย์\n'
          'จุดเปลี่ยนสงครามแปซิฟิก',
      significance: 'SIGINT ชนะสงคราม',
      icon: Icons.anchor,
      color: AppColors.esColor,
      era: EWEra.ww2,
    ),
    EWHistoricalEvent(
      id: 'window',
      title: 'Operation Window (Chaff)',
      year: 1943,
      location: 'ฮัมบูร์ก, เยอรมนี',
      lat: 53.5511,
      lon: 9.9937,
      description: 'อังกฤษใช้ Chaff ครั้งแรกในประวัติศาสตร์\n'
          'โปรยแถบอลูมิเนียมรบกวนเรดาร์เยอรมัน\n'
          'ทำให้เรดาร์ไม่สามารถติดตามเครื่องบินได้',
      significance: 'จุดกำเนิด ECM',
      icon: Icons.blur_on,
      color: AppColors.eaColor,
      era: EWEra.ww2,
    ),
    EWHistoricalEvent(
      id: 'normandy',
      title: 'D-Day: ปฏิบัติการ Fortitude',
      year: 1944,
      location: 'นอร์มังดี, ฝรั่งเศส',
      lat: 49.3294,
      lon: -0.8275,
      description: 'ปฏิบัติการลวงที่ซับซ้อนที่สุดในประวัติศาสตร์\n'
          'ใช้วิทยุปลอม เรดาร์หลอก และข่าวลวง\n'
          'เยอรมันเชื่อว่าจะขึ้นบกที่ Pas-de-Calais',
      significance: 'Electronic Deception',
      icon: Icons.psychology,
      color: AppColors.epColor,
      era: EWEra.ww2,
    ),

    // ============ สงครามเย็น (1947-1991) ============
    EWHistoricalEvent(
      id: 'u2',
      title: 'เหตุการณ์ U-2',
      year: 1960,
      location: 'สเวียร์ดลอฟสก์, โซเวียต',
      lat: 56.8389,
      lon: 60.6057,
      description: 'Gary Powers ถูกยิงตกด้วย SA-2\n'
          'ความสูง 70,000 ฟุตไม่ปลอดภัยอีกต่อไป\n'
          'นำไปสู่การพัฒนา SR-71 และดาวเทียมสอดแนม',
      significance: 'SAM vs เครื่องบินลาดตระเวน',
      icon: Icons.flight_takeoff,
      color: AppColors.radarColor,
      era: EWEra.coldWar,
    ),
    EWHistoricalEvent(
      id: 'cuban',
      title: 'วิกฤตการณ์ขีปนาวุธคิวบา',
      year: 1962,
      location: 'คิวบา',
      lat: 23.1136,
      lon: -82.3666,
      description: 'U-2 ถ่ายภาพฐานขีปนาวุธโซเวียต\n'
          'SIGINT ติดตามการเคลื่อนไหวของโซเวียต\n'
          'ข่าวกรองอิเล็กทรอนิกส์ป้องกันสงครามนิวเคลียร์',
      significance: 'SIGINT กับวิกฤตการณ์นิวเคลียร์',
      icon: Icons.dangerous,
      color: AppColors.error,
      era: EWEra.coldWar,
    ),
    EWHistoricalEvent(
      id: 'vietnam',
      title: 'สงครามเวียดนาม: Rolling Thunder',
      year: 1965,
      location: 'เวียดนามเหนือ',
      lat: 21.0285,
      lon: 105.8542,
      description: 'การรบกวนเรดาร์ SAM อย่างเป็นระบบครั้งแรก\n'
          'พัฒนา Wild Weasel สำหรับ SEAD\n'
          'ใช้ Chaff, Flare และ ECM pods',
      significance: 'ยุค EW สมัยใหม่เริ่มต้น',
      icon: Icons.flight,
      color: AppColors.eaColor,
      era: EWEra.coldWar,
    ),
    EWHistoricalEvent(
      id: 'ussLiberty',
      title: 'เหตุการณ์ USS Liberty',
      year: 1967,
      location: 'ทะเลเมดิเตอร์เรเนียน',
      lat: 31.4,
      lon: 33.9,
      description: 'เรือรวบรวมข่าวกรอง SIGINT ของสหรัฐฯ\n'
          'ถูกโจมตีระหว่างสงครามหกวัน\n'
          'แสดงความเสี่ยงของภารกิจ SIGINT',
      significance: 'ความเสี่ยงของ SIGINT',
      icon: Icons.directions_boat,
      color: AppColors.esColor,
      era: EWEra.coldWar,
    ),
    EWHistoricalEvent(
      id: 'yomkippur',
      title: 'สงคราม Yom Kippur',
      year: 1973,
      location: 'คาบสมุทรไซนาย',
      lat: 29.5,
      lon: 34.0,
      description: 'อียิปต์ใช้ SA-6 ยิงเครื่องบินอิสราเอลตก 40+ ลำ\n'
          'แสดงพลังของ SAM รุ่นใหม่\n'
          'นำไปสู่การพัฒนา SEAD ที่ดีขึ้น',
      significance: 'SAM ท้าทายอำนาจทางอากาศ',
      icon: Icons.rocket_launch,
      color: AppColors.radarColor,
      era: EWEra.coldWar,
    ),
    EWHistoricalEvent(
      id: 'bekaa',
      title: 'ยุทธการหุบเขาเบก้า',
      year: 1982,
      location: 'เลบานอน',
      lat: 33.85,
      lon: 35.9,
      description: 'อิสราเอลทำลาย SAM ซีเรีย 19 ฐานใน 2 ชม.\n'
          'ใช้โดรนล่อ, ECM และ HARM\n'
          'ยิงเครื่องบินซีเรียตก 82 ลำ โดยไม่เสียเลย',
      significance: 'ตำราการรบ SEAD สมัยใหม่',
      icon: Icons.local_fire_department,
      color: AppColors.eaColor,
      era: EWEra.coldWar,
    ),

    // ============ ยุคหลังสงครามเย็น (1991-2010) ============
    EWHistoricalEvent(
      id: 'gulf',
      title: 'สงครามอ่าว: Desert Storm',
      year: 1991,
      location: 'อิรัก/คูเวต',
      lat: 29.3759,
      lon: 47.9774,
      description: 'ทำลายระบบ IADS อิรักในคืนแรก\n'
          'F-117 Stealth + EW ประสานกัน\n'
          'GPS ใช้ในสงครามครั้งแรก',
      significance: 'EW ยุคดิจิทัล',
      icon: Icons.military_tech,
      color: AppColors.epColor,
      era: EWEra.postColdWar,
    ),
    EWHistoricalEvent(
      id: 'kosovo_f117',
      title: 'F-117 ถูกยิงตก',
      year: 1999,
      location: 'เซอร์เบีย',
      lat: 44.6472,
      lon: 20.2789,
      description: 'Stealth ไม่ใช่สิ่งที่มองไม่เห็น 100%\n'
          'เซอร์เบียใช้เรดาร์คลื่นยาวตรวจจับได้\n'
          'บทเรียน: ไม่มีเทคโนโลยีใดสมบูรณ์แบบ',
      significance: 'ข้อจำกัดของ Stealth',
      icon: Icons.visibility_off,
      color: AppColors.warning,
      era: EWEra.postColdWar,
    ),
    EWHistoricalEvent(
      id: 'georgia',
      title: 'สงครามรัสเซีย-จอร์เจีย',
      year: 2008,
      location: 'จอร์เจีย',
      lat: 42.2679,
      lon: 43.3569,
      description: 'รัสเซียใช้ Cyber + EW ร่วมกันครั้งแรก\n'
          'รบกวน GPS และการสื่อสารจอร์เจีย\n'
          'โจมตีไซเบอร์ประสานกับกำลังภาคพื้น',
      significance: 'Cyber + EW ประสานงาน',
      icon: Icons.computer,
      color: AppColors.eaColor,
      era: EWEra.postColdWar,
    ),

    // ============ ยุคปัจจุบัน (2010-ปัจจุบัน) ============
    EWHistoricalEvent(
      id: 'syria_pantsir',
      title: 'อิสราเอล vs Pantsir ในซีเรีย',
      year: 2018,
      location: 'ซีเรีย',
      lat: 33.5138,
      lon: 36.2765,
      description: 'อิสราเอลทำลายระบบ Pantsir-S1\n'
          'แม้จะเป็นระบบป้องกันภัยทางอากาศรุ่นใหม่\n'
          'แสดงศักยภาพ SEAD ของอิสราเอล',
      significance: 'SEAD ยุคใหม่',
      icon: Icons.gps_fixed,
      color: AppColors.eaColor,
      era: EWEra.modern,
    ),
    EWHistoricalEvent(
      id: 'armenia',
      title: 'สงคราม Nagorno-Karabakh',
      year: 2020,
      location: 'อาเซอร์ไบจาน',
      lat: 39.8,
      lon: 46.8,
      description: 'อาเซอร์ไบจานใช้โดรน TB2 ทำลาย SAM\n'
          'ยุทธวิธีล่อให้เรดาร์เปิดแล้วโจมตี\n'
          'เปลี่ยนแปลงสงครามสมัยใหม่',
      significance: 'โดรนเปลี่ยนสงคราม',
      icon: Icons.airplanemode_active,
      color: AppColors.droneColor,
      era: EWEra.modern,
    ),
    EWHistoricalEvent(
      id: 'ukraine',
      title: 'สงครามยูเครน',
      year: 2022,
      location: 'ยูเครน',
      lat: 48.3794,
      lon: 31.1656,
      description: 'สงครามโดรนและ C-UAS ขนาดใหญ่\n'
          'GPS Jamming และ Spoofing แพร่หลาย\n'
          'Starlink กับ EW รัสเซีย',
      significance: 'EW ในสงครามโดรน',
      icon: Icons.airplanemode_active,
      color: AppColors.droneColor,
      era: EWEra.modern,
    ),
    EWHistoricalEvent(
      id: 'redSea',
      title: 'วิกฤตทะเลแดง',
      year: 2024,
      location: 'ทะเลแดง',
      lat: 15.5,
      lon: 42.0,
      description: 'ฮูตีใช้โดรนและขีปนาวุธโจมตีเรือ\n'
          'สหรัฐฯ ใช้ระบบ Aegis ป้องกัน\n'
          'GPS Spoofing มีรายงานในพื้นที่',
      significance: 'EW ในทะเลยุคใหม่',
      icon: Icons.directions_boat,
      color: AppColors.radarColor,
      era: EWEra.modern,
    ),

    // ============ เอเชียตะวันออกเฉียงใต้ ============
    EWHistoricalEvent(
      id: 'thailand_ew',
      title: 'ไทยพัฒนาระบบ EW',
      year: 2020,
      location: 'ประเทศไทย',
      lat: 13.7563,
      lon: 100.5018,
      description: 'กองทัพไทยพัฒนาระบบ C-UAS\n'
          'ติดตั้งระบบตรวจจับและรบกวนโดรน\n'
          'ร่วมมือกับอิสราเอลในด้าน SIGINT',
      significance: 'ไทยก้าวสู่ EW ยุคใหม่',
      icon: Icons.shield,
      color: AppColors.esColor,
      era: EWEra.modern,
    ),
    EWHistoricalEvent(
      id: 'thai_cambodia',
      title: 'ชายแดนไทย-กัมพูชา',
      year: 2011,
      location: 'ปราสาทพระวิหาร',
      lat: 14.3920,
      lon: 104.6803,
      description: 'ความขัดแย้งชายแดน\n'
          'ใช้เรดาร์เฝ้าตรวจและ SIGINT\n'
          'การรบกวนสัญญาณสื่อสาร',
      significance: 'EW ในความขัดแย้งชายแดน',
      icon: Icons.terrain,
      color: AppColors.warning,
      era: EWEra.modern,
    ),
    EWHistoricalEvent(
      id: 'southchinasea',
      title: 'ทะเลจีนใต้: GPS Spoofing',
      year: 2019,
      location: 'ทะเลจีนใต้',
      lat: 15.0,
      lon: 114.0,
      description: 'เรือหลายลำรายงาน GPS ผิดพลาด\n'
          'มีการ Spoofing สัญญาณ GPS ในพื้นที่\n'
          'จีนสร้างฐานทัพพร้อมระบบ EW บนเกาะเทียม',
      significance: 'GPS Warfare ในเอเชีย',
      icon: Icons.satellite_alt,
      color: AppColors.gpsColor,
      era: EWEra.modern,
    ),

    // ============ อเมริกาใต้ ============
    EWHistoricalEvent(
      id: 'venezuela',
      title: 'สหรัฐฯ-เวเนซุเอลา',
      year: 2019,
      location: 'เวเนซุเอลา',
      lat: 10.4806,
      lon: -66.9036,
      description: 'เวเนซุเอลาใช้ระบบ EW รัสเซีย\n'
          'รบกวนการสื่อสารและ GPS ในพื้นที่\n'
          'สหรัฐฯ บินลาดตระเวนด้วย EP-3',
      significance: 'EW ในความขัดแย้งทางการเมือง',
      icon: Icons.airplanemode_active,
      color: AppColors.eaColor,
      era: EWEra.modern,
    ),

    // ============ ตะวันออกกลาง เพิ่มเติม ============
    EWHistoricalEvent(
      id: 'iran_drone',
      title: 'อิหร่านยึดโดรน RQ-170',
      year: 2011,
      location: 'อิหร่าน',
      lat: 35.6892,
      lon: 51.3890,
      description: 'อิหร่านอ้างว่า Spoof สัญญาณ GPS\n'
          'ทำให้โดรน Stealth ของสหรัฐฯ ลงจอด\n'
          'แสดงจุดอ่อนของการพึ่งพา GPS',
      significance: 'GPS Spoofing vs โดรน',
      icon: Icons.flight_land,
      color: AppColors.gpsColor,
      era: EWEra.modern,
    ),
    EWHistoricalEvent(
      id: 'gaza_2023',
      title: 'สงคราม Gaza 2023',
      year: 2023,
      location: 'กาซา',
      lat: 31.5,
      lon: 34.47,
      description: 'อิสราเอลใช้ EW รบกวนโดรน Hamas\n'
          'ระบบ Iron Dome ประสานกับ C-UAS\n'
          'Cyber + EW ในสงครามเมือง',
      significance: 'EW ในสงครามเมือง',
      icon: Icons.location_city,
      color: AppColors.eaColor,
      era: EWEra.modern,
    ),

    // ============ เกาหลี ============
    EWHistoricalEvent(
      id: 'korea_gps',
      title: 'เกาหลีเหนือ Jam GPS',
      year: 2016,
      location: 'คาบสมุทรเกาหลี',
      lat: 37.5665,
      lon: 126.9780,
      description: 'เกาหลีเหนือรบกวน GPS เกาหลีใต้\n'
          'กระทบเครื่องบินและเรือหลายร้อยลำ\n'
          'ทดสอบความสามารถ EW เป็นระยะ',
      significance: 'GPS Jamming ระดับชาติ',
      icon: Icons.gps_off,
      color: AppColors.gpsColor,
      era: EWEra.modern,
    ),
  ];

  List<EWHistoricalEvent> get _events {
    if (_selectedEra == null) return _allEvents;
    return _allEvents.where((e) => e.era == _selectedEra).toList();
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _markerAnimController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _markerAnimController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  String get _tileUrl {
    switch (_currentMapStyle) {
      case MapStyle.satellite:
        // ESRI World Imagery - Free satellite tiles
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapStyle.dark:
        // CartoDB Dark Matter - reliable dark theme (no API key needed)
        return 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png';
      case MapStyle.terrain:
        // OpenStreetMap - most reliable, works everywhere
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  String get _tileUrlFallback {
    // Fallback to OpenStreetMap if primary fails
    return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  }

  void _flyToEvent(int index) {
    if (index < 0 || index >= _events.length) return;

    final event = _events[index];
    _mapController.move(
      LatLng(event.lat, event.lon),
      5.0,
    );

    setState(() {
      _selectedEventIndex = index;
    });

    _markerAnimController.forward(from: 0);
  }

  void _startAutoTour() async {
    setState(() {
      _isAutoTour = true;
      _currentTourIndex = 0;
    });

    for (int i = 0; i < _events.length && _isAutoTour; i++) {
      setState(() => _currentTourIndex = i);
      _flyToEvent(i);
      await Future.delayed(const Duration(seconds: 4));
    }

    if (_isAutoTour) {
      setState(() => _isAutoTour = false);
    }
  }

  void _stopAutoTour() {
    setState(() => _isAutoTour = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header with controls
          _buildHeader(),

          // Real Map
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppSizes.radiusL),
              ),
              child: Stack(
                children: [
                  // Flutter Map
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: const LatLng(30.0, 20.0),
                      initialZoom: 2.0,
                      minZoom: 1.5,
                      maxZoom: 18.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                      onTap: (_, point) {
                        setState(() => _selectedEventIndex = -1);
                      },
                    ),
                    children: [
                      // Tile Layer with fallback
                      TileLayer(
                        urlTemplate: _tileUrl,
                        fallbackUrl: _tileUrlFallback,
                        userAgentPackageName: 'com.signalschool.signal_nco_ew',
                        maxZoom: 19,
                        errorTileCallback: (tile, error, stackTrace) {
                          debugPrint('Tile error: $error');
                        },
                      ),

                      // Connection lines between events
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _events.map((e) => LatLng(e.lat, e.lon)).toList(),
                            color: AppColors.primary.withAlpha(150),
                            strokeWidth: 2,
                            isDotted: true,
                          ),
                        ],
                      ),

                      // Event Markers
                      MarkerLayer(
                        markers: _events.asMap().entries.map((entry) {
                          final index = entry.key;
                          final event = entry.value;
                          final isSelected = _selectedEventIndex == index;

                          return Marker(
                            point: LatLng(event.lat, event.lon),
                            width: isSelected ? 60 : 40,
                            height: isSelected ? 60 : 40,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedEventIndex = isSelected ? -1 : index;
                                  _isAutoTour = false;
                                });
                                if (!isSelected) {
                                  _mapController.move(
                                    LatLng(event.lat, event.lon),
                                    5.0,
                                  );
                                }
                              },
                              child: AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  final scale = isSelected
                                      ? 1.0 + _pulseController.value * 0.2
                                      : 1.0;
                                  return Transform.scale(
                                    scale: scale,
                                    child: _buildMarker(event, isSelected),
                                  );
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  // Map style selector (top right)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _buildMapStyleSelector(),
                  ),

                  // Zoom controls (bottom right)
                  Positioned(
                    bottom: 80,
                    right: 10,
                    child: _buildZoomControls(),
                  ),

                  // Timeline (bottom)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildTimeline(),
                  ),

                  // Event detail popup
                  if (_selectedEventIndex >= 0)
                    Positioned(
                      top: 10,
                      left: 10,
                      right: 70,
                      child: _EventDetailPopup(
                        event: _events[_selectedEventIndex],
                        onClose: () => setState(() => _selectedEventIndex = -1),
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main header row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusL),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.esColor, AppColors.eaColor],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.public, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'แผนที่ประวัติศาสตร์ EW',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_events.length} เหตุการณ์ • ${_selectedEra?.thaiName ?? 'ทุกยุคสมัย'}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Tour button
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isAutoTour
                        ? [AppColors.error, AppColors.error.withAlpha(200)]
                        : [AppColors.primary, AppColors.primary.withAlpha(200)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (_isAutoTour ? AppColors.error : AppColors.primary)
                          .withAlpha(100),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _isAutoTour ? _stopAutoTour : _startAutoTour,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isAutoTour ? Icons.stop : Icons.play_arrow,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isAutoTour ? 'หยุด' : 'นำชม',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Era filter chips
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.border.withAlpha(50)),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // "All" button
                _EraFilterChip(
                  label: 'ทั้งหมด',
                  yearRange: '${_allEvents.first.year}-${_allEvents.last.year}',
                  color: AppColors.primary,
                  isSelected: _selectedEra == null,
                  onTap: () {
                    setState(() {
                      _selectedEra = null;
                      _selectedEventIndex = -1;
                    });
                  },
                ),
                const SizedBox(width: 8),
                // Era chips
                ...EWEra.values.map((era) {
                  final eventCount = _allEvents.where((e) => e.era == era).length;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _EraFilterChip(
                      label: era.thaiName,
                      yearRange: era.yearRange,
                      color: era.color,
                      isSelected: _selectedEra == era,
                      badge: eventCount.toString(),
                      onTap: () {
                        setState(() {
                          _selectedEra = era;
                          _selectedEventIndex = -1;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMarker(EWHistoricalEvent event, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: event.color,
        border: Border.all(
          color: Colors.white,
          width: isSelected ? 4 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: event.color.withAlpha(isSelected ? 180 : 100),
            blurRadius: isSelected ? 20 : 10,
            spreadRadius: isSelected ? 5 : 2,
          ),
          const BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          event.icon,
          color: Colors.white,
          size: isSelected ? 24 : 16,
        ),
      ),
    );
  }

  Widget _buildMapStyleSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(230),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MapStyleButton(
            icon: Icons.satellite_alt,
            label: 'ดาวเทียม',
            isSelected: _currentMapStyle == MapStyle.satellite,
            onTap: () => setState(() => _currentMapStyle = MapStyle.satellite),
          ),
          _MapStyleButton(
            icon: Icons.dark_mode,
            label: 'มืด',
            isSelected: _currentMapStyle == MapStyle.dark,
            onTap: () => setState(() => _currentMapStyle = MapStyle.dark),
          ),
          _MapStyleButton(
            icon: Icons.terrain,
            label: 'ภูมิประเทศ',
            isSelected: _currentMapStyle == MapStyle.terrain,
            onTap: () => setState(() => _currentMapStyle = MapStyle.terrain),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomControls() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(230),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            color: AppColors.textPrimary,
            onPressed: () {
              final currentZoom = _mapController.camera.zoom;
              _mapController.move(
                _mapController.camera.center,
                currentZoom + 1,
              );
            },
          ),
          Container(
            height: 1,
            width: 30,
            color: AppColors.border,
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            color: AppColors.textPrimary,
            onPressed: () {
              final currentZoom = _mapController.camera.zoom;
              _mapController.move(
                _mapController.camera.center,
                currentZoom - 1,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.background.withAlpha(200),
            AppColors.background,
          ],
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          final isSelected = _selectedEventIndex == index;
          final isCurrent = _isAutoTour && _currentTourIndex == index;

          return GestureDetector(
            onTap: () {
              _stopAutoTour();
              _flyToEvent(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 100 : 80,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: isSelected || isCurrent
                    ? LinearGradient(
                        colors: [
                          event.color.withAlpha(200),
                          event.color.withAlpha(150),
                        ],
                      )
                    : null,
                color: isSelected || isCurrent ? null : AppColors.surface.withAlpha(200),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected || isCurrent ? event.color : AppColors.border,
                  width: isSelected || isCurrent ? 2 : 1,
                ),
                boxShadow: isSelected || isCurrent
                    ? [
                        BoxShadow(
                          color: event.color.withAlpha(100),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${event.year}',
                    style: TextStyle(
                      color: isSelected || isCurrent
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: isSelected ? 16 : 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Icon(
                    event.icon,
                    color: isSelected || isCurrent
                        ? Colors.white
                        : event.color,
                    size: isSelected ? 20 : 16,
                  ),
                ],
              ),
            ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.2),
          );
        },
      ),
    );
  }
}

class _EraFilterChip extends StatelessWidget {
  final String label;
  final String yearRange;
  final Color color;
  final bool isSelected;
  final String? badge;
  final VoidCallback onTap;

  const _EraFilterChip({
    required this.label,
    required this.yearRange,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [color, color.withAlpha(180)],
                  )
                : null,
            color: isSelected ? null : AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withAlpha(80),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    yearRange,
                    style: TextStyle(
                      fontSize: 9,
                      color: isSelected
                          ? Colors.white.withAlpha(200)
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withAlpha(50)
                        : color.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MapStyleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MapStyleButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(30) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventDetailPopup extends StatelessWidget {
  final EWHistoricalEvent event;
  final VoidCallback onClose;

  const _EventDetailPopup({
    required this.event,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 350),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(245),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: event.color.withAlpha(100)),
        boxShadow: [
          BoxShadow(
            color: event.color.withAlpha(50),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  event.color.withAlpha(50),
                  event.color.withAlpha(20),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: event.color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: event.color.withAlpha(150),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(event.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${event.year} • ${event.location}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: event.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  color: AppColors.textMuted,
                  iconSize: 20,
                ),
              ],
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Significance tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        event.color.withAlpha(40),
                        event.color.withAlpha(20),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: event.color.withAlpha(100)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: event.color, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        event.significance,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: event.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// EW Historical Event model
class EWHistoricalEvent {
  final String id;
  final String title;
  final int year;
  final String location;
  final double lat;
  final double lon;
  final String description;
  final String significance;
  final IconData icon;
  final Color color;
  final EWEra era;

  const EWHistoricalEvent({
    required this.id,
    required this.title,
    required this.year,
    required this.location,
    required this.lat,
    required this.lon,
    required this.description,
    required this.significance,
    required this.icon,
    required this.color,
    required this.era,
  });
}

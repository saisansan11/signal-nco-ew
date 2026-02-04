import '../models/curriculum_models.dart';
import '../models/quiz_models.dart';

/// คำถามแบบทดสอบ EW สำหรับนายสิบเหล่าทหารสื่อสาร
class QuizData {
  /// คำถามทั้งหมด
  static const List<QuizQuestion> allQuestions = [
    // ================== ภาพรวม EW ==================
    QuizQuestion(
      id: 'ew_001',
      questionTh: 'สงครามอิเล็กทรอนิกส์ (EW) ประกอบด้วยกี่เสาหลัก?',
      optionsTh: ['2 เสาหลัก', '3 เสาหลัก', '4 เสาหลัก', '5 เสาหลัก'],
      correctIndex: 1,
      explanationTh: 'EW ประกอบด้วย 3 เสาหลัก: ES (Electronic Support), EA (Electronic Attack), และ EP (Electronic Protection)',
      category: EWCategory.overview,
      difficulty: DifficultyLevel.beginner,
    ),
    QuizQuestion(
      id: 'ew_002',
      questionTh: 'ES ย่อมาจากอะไร?',
      optionsTh: [
        'Electronic Support',
        'Electronic Signal',
        'Electromagnetic Surveillance',
        'Electronic System'
      ],
      correctIndex: 0,
      explanationTh: 'ES = Electronic Support หมายถึง การสนับสนุนทางอิเล็กทรอนิกส์',
      category: EWCategory.overview,
      difficulty: DifficultyLevel.beginner,
    ),
    QuizQuestion(
      id: 'ew_003',
      questionTh: 'EA หมายถึงอะไร?',
      optionsTh: [
        'การป้องกันทางอิเล็กทรอนิกส์',
        'การโจมตีทางอิเล็กทรอนิกส์',
        'การสนับสนุนทางอิเล็กทรอนิกส์',
        'การวิเคราะห์ทางอิเล็กทรอนิกส์'
      ],
      correctIndex: 1,
      explanationTh: 'EA = Electronic Attack หมายถึง การโจมตีทางอิเล็กทรอนิกส์ เป็นการใช้พลังงานแม่เหล็กไฟฟ้าเพื่อลดประสิทธิภาพหรือทำลายขีดความสามารถของข้าศึก',
      category: EWCategory.overview,
      difficulty: DifficultyLevel.beginner,
    ),
    QuizQuestion(
      id: 'ew_004',
      questionTh: 'EP มีหน้าที่หลักคืออะไร?',
      optionsTh: [
        'โจมตีระบบอิเล็กทรอนิกส์ของข้าศึก',
        'ดักรับสัญญาณของข้าศึก',
        'ป้องกันระบบของตนจากการรบกวน',
        'วิเคราะห์สเปกตรัมแม่เหล็กไฟฟ้า'
      ],
      correctIndex: 2,
      explanationTh: 'EP = Electronic Protection ทำหน้าที่ป้องกันบุคลากร สิ่งอำนวยความสะดวก และอุปกรณ์จากผลกระทบของ EW',
      category: EWCategory.overview,
      difficulty: DifficultyLevel.beginner,
    ),

    // ================== สเปกตรัม ==================
    QuizQuestion(
      id: 'spec_001',
      questionTh: 'ความถี่ VHF มีช่วงความถี่เท่าไร?',
      optionsTh: [
        '3-30 MHz',
        '30-300 MHz',
        '300 MHz - 3 GHz',
        '3-30 GHz'
      ],
      correctIndex: 1,
      explanationTh: 'VHF (Very High Frequency) มีช่วงความถี่ 30-300 MHz ใช้สำหรับวิทยุยุทธวิธีและการบิน',
      category: EWCategory.spectrum,
      difficulty: DifficultyLevel.beginner,
    ),
    QuizQuestion(
      id: 'spec_002',
      questionTh: 'ความถี่ใดใช้สำหรับการสื่อสารผ่านดาวเทียม?',
      optionsTh: ['HF', 'VHF', 'UHF', 'SHF'],
      correctIndex: 3,
      explanationTh: 'SHF (Super High Frequency) 3-30 GHz ใช้สำหรับเรดาร์และการสื่อสารผ่านดาวเทียม',
      category: EWCategory.spectrum,
      difficulty: DifficultyLevel.intermediate,
    ),
    QuizQuestion(
      id: 'spec_003',
      questionTh: 'HF มีช่วงความถี่เท่าใด?',
      optionsTh: [
        '0.3-3 MHz',
        '3-30 MHz',
        '30-300 MHz',
        '300 MHz - 3 GHz'
      ],
      correctIndex: 1,
      explanationTh: 'HF (High Frequency) มีช่วงความถี่ 3-30 MHz ใช้สำหรับการสื่อสารระยะไกลผ่านการสะท้อนชั้นบรรยากาศ',
      category: EWCategory.spectrum,
      difficulty: DifficultyLevel.beginner,
    ),

    // ================== ES ==================
    QuizQuestion(
      id: 'es_001',
      questionTh: 'ESM ย่อมาจากอะไร?',
      optionsTh: [
        'Electronic Support Measures',
        'Electronic Signal Monitoring',
        'Electromagnetic Spectrum Management',
        'Electronic System Maintenance'
      ],
      correctIndex: 0,
      explanationTh: 'ESM = Electronic Support Measures คือมาตรการสนับสนุนทางอิเล็กทรอนิกส์',
      category: EWCategory.es,
      difficulty: DifficultyLevel.beginner,
    ),
    QuizQuestion(
      id: 'es_002',
      questionTh: 'SIGINT ประกอบด้วยอะไรบ้าง?',
      optionsTh: [
        'COMINT และ ELINT',
        'HUMINT และ IMINT',
        'OSINT และ MASINT',
        'TECHINT และ GEOINT'
      ],
      correctIndex: 0,
      explanationTh: 'SIGINT (Signals Intelligence) ประกอบด้วย COMINT (Communications Intelligence) และ ELINT (Electronic Intelligence)',
      category: EWCategory.es,
      difficulty: DifficultyLevel.intermediate,
    ),
    QuizQuestion(
      id: 'es_003',
      questionTh: 'DF ในงาน ESM หมายถึงอะไร?',
      optionsTh: [
        'Digital Frequency',
        'Direction Finding',
        'Data Format',
        'Defense Function'
      ],
      correctIndex: 1,
      explanationTh: 'DF = Direction Finding คือเทคนิคการหาทิศทางหรือแหล่งที่มาของสัญญาณวิทยุ',
      category: EWCategory.es,
      difficulty: DifficultyLevel.beginner,
    ),
    QuizQuestion(
      id: 'es_004',
      questionTh: 'EOB ย่อมาจากอะไร?',
      optionsTh: [
        'Electronic Operations Brief',
        'Electronic Order of Battle',
        'Electromagnetic Observation Base',
        'Electronic Output Bandwidth'
      ],
      correctIndex: 1,
      explanationTh: 'EOB = Electronic Order of Battle คือฐานข้อมูลของระบบอิเล็กทรอนิกส์ของข้าศึก',
      category: EWCategory.es,
      difficulty: DifficultyLevel.intermediate,
    ),

    // ================== EA ==================
    QuizQuestion(
      id: 'ea_001',
      questionTh: 'Spot Jamming คืออะไร?',
      optionsTh: [
        'การรบกวนช่วงความถี่กว้าง',
        'การรบกวนความถี่เดียวหรือช่วงแคบ',
        'การรบกวนแบบกวาดความถี่',
        'การรบกวนแบบสุ่ม'
      ],
      correctIndex: 1,
      explanationTh: 'Spot Jamming คือการรบกวนความถี่เดียวหรือช่วงความถี่แคบๆ ใช้กำลังส่งน้อยแต่มีประสิทธิภาพสูงต่อเป้าหมายเดียว',
      category: EWCategory.ea,
      difficulty: DifficultyLevel.beginner,
    ),
    QuizQuestion(
      id: 'ea_002',
      questionTh: 'Barrage Jamming มีลักษณะอย่างไร?',
      optionsTh: [
        'รบกวนความถี่เดียว',
        'รบกวนช่วงความถี่กว้างพร้อมกัน',
        'รบกวนแบบเลื่อนความถี่',
        'รบกวนแบบพัลส์'
      ],
      correctIndex: 1,
      explanationTh: 'Barrage Jamming คือการรบกวนช่วงความถี่กว้างพร้อมกัน เหมาะกับเป้าหมายหลายตัว แต่ต้องใช้กำลังส่งมาก',
      category: EWCategory.ea,
      difficulty: DifficultyLevel.beginner,
    ),
    QuizQuestion(
      id: 'ea_003',
      questionTh: 'J/S Ratio คืออะไร?',
      optionsTh: [
        'อัตราส่วนสัญญาณต่อสัญญาณรบกวน',
        'อัตราส่วนสัญญาณรบกวนต่อสัญญาณ',
        'อัตราความถี่ต่อแบนด์วิดท์',
        'อัตราพลังงานต่อระยะทาง'
      ],
      correctIndex: 1,
      explanationTh: 'J/S Ratio = Jamming-to-Signal Ratio คืออัตราส่วนสัญญาณรบกวนต่อสัญญาณ ยิ่งสูงยิ่งรบกวนได้ผล',
      category: EWCategory.ea,
      difficulty: DifficultyLevel.intermediate,
    ),
    QuizQuestion(
      id: 'ea_004',
      questionTh: 'Spoofing ต่างจาก Jamming อย่างไร?',
      optionsTh: [
        'ใช้กำลังส่งมากกว่า',
        'ส่งสัญญาณปลอมหลอกระบบแทนการรบกวน',
        'ทำงานที่ความถี่ต่ำกว่า',
        'ใช้เฉพาะกับเรดาร์'
      ],
      correctIndex: 1,
      explanationTh: 'Spoofing คือการส่งสัญญาณปลอมเพื่อหลอกระบบของข้าศึก ต่างจาก Jamming ที่รบกวนโดยตรง',
      category: EWCategory.ea,
      difficulty: DifficultyLevel.intermediate,
    ),

    // ================== EP ==================
    QuizQuestion(
      id: 'ep_001',
      questionTh: 'FHSS ย่อมาจากอะไร?',
      optionsTh: [
        'Fast High Speed Signal',
        'Frequency Hopping Spread Spectrum',
        'Full Horizontal Signal System',
        'Fixed High Security Signal'
      ],
      correctIndex: 1,
      explanationTh: 'FHSS = Frequency Hopping Spread Spectrum เทคนิคการกระโดดความถี่แบบกระจายสเปกตรัมเพื่อหลีกเลี่ยงการรบกวน',
      category: EWCategory.ep,
      difficulty: DifficultyLevel.beginner,
    ),
    QuizQuestion(
      id: 'ep_002',
      questionTh: 'EMCON มีจุดประสงค์หลักคืออะไร?',
      optionsTh: [
        'เพิ่มกำลังส่งสัญญาณ',
        'จำกัดการแผ่คลื่นเพื่อไม่ให้ถูกตรวจจับ',
        'รบกวนสัญญาณข้าศึก',
        'วิเคราะห์สัญญาณที่รับได้'
      ],
      correctIndex: 1,
      explanationTh: 'EMCON = Emission Control คือการควบคุมการแผ่คลื่น โดยจำกัดหรือหยุดการแผ่คลื่นแม่เหล็กไฟฟ้าเพื่อไม่ให้ถูกตรวจจับ',
      category: EWCategory.ep,
      difficulty: DifficultyLevel.beginner,
    ),
    QuizQuestion(
      id: 'ep_003',
      questionTh: 'LPI ย่อมาจากอะไร?',
      optionsTh: [
        'Low Power Interference',
        'Low Probability of Intercept',
        'Local Position Indicator',
        'Linear Pulse Integration'
      ],
      correctIndex: 1,
      explanationTh: 'LPI = Low Probability of Intercept เทคนิคการส่งสัญญาณที่ยากต่อการถูกดักรับ',
      category: EWCategory.ep,
      difficulty: DifficultyLevel.intermediate,
    ),
    QuizQuestion(
      id: 'ep_004',
      questionTh: 'ECCM คืออะไร?',
      optionsTh: [
        'การโจมตีทางอิเล็กทรอนิกส์',
        'การสนับสนุนทางอิเล็กทรอนิกส์',
        'มาตรการต่อต้านการตอบโต้ทางอิเล็กทรอนิกส์',
        'การจัดการสเปกตรัมแม่เหล็กไฟฟ้า'
      ],
      correctIndex: 2,
      explanationTh: 'ECCM = Electronic Counter-Countermeasures มาตรการป้องกันระบบของตนจากการรบกวนของข้าศึก',
      category: EWCategory.ep,
      difficulty: DifficultyLevel.beginner,
    ),

    // ================== เรดาร์ ==================
    QuizQuestion(
      id: 'radar_001',
      questionTh: 'PRF ย่อมาจากอะไร?',
      optionsTh: [
        'Pulse Range Finder',
        'Pulse Repetition Frequency',
        'Power Radio Frequency',
        'Primary Radar Function'
      ],
      correctIndex: 1,
      explanationTh: 'PRF = Pulse Repetition Frequency ความถี่ซ้ำพัลส์ คืออัตราการส่งพัลส์เรดาร์',
      category: EWCategory.radar,
      difficulty: DifficultyLevel.beginner,
    ),
    QuizQuestion(
      id: 'radar_002',
      questionTh: 'RCS คืออะไร?',
      optionsTh: [
        'Radar Control System',
        'Radio Communication Service',
        'Radar Cross Section',
        'Remote Control Station'
      ],
      correctIndex: 2,
      explanationTh: 'RCS = Radar Cross Section พื้นที่หน้าตัดเรดาร์ คือขนาดการสะท้อนเรดาร์ของเป้าหมาย',
      category: EWCategory.radar,
      difficulty: DifficultyLevel.intermediate,
    ),
    QuizQuestion(
      id: 'radar_003',
      questionTh: 'Doppler Shift ใช้ทำอะไรในเรดาร์?',
      optionsTh: [
        'วัดระยะทาง',
        'วัดความเร็วของเป้าหมาย',
        'กำหนดทิศทาง',
        'ลดสัญญาณรบกวน'
      ],
      correctIndex: 1,
      explanationTh: 'Doppler Shift คือปรากฏการณ์เปลี่ยนความถี่เนื่องจากการเคลื่อนที่สัมพัทธ์ ใช้ในเรดาร์เพื่อตรวจวัดความเร็วของเป้าหมาย',
      category: EWCategory.radar,
      difficulty: DifficultyLevel.intermediate,
    ),
    QuizQuestion(
      id: 'radar_004',
      questionTh: 'SAR ย่อมาจากอะไร?',
      optionsTh: [
        'Search And Rescue',
        'Synthetic Aperture Radar',
        'Signal Analysis Receiver',
        'Surface Air Radar'
      ],
      correctIndex: 1,
      explanationTh: 'SAR = Synthetic Aperture Radar เรดาร์รูรับสังเคราะห์ สร้างภาพความละเอียดสูงของพื้นผิว',
      category: EWCategory.radar,
      difficulty: DifficultyLevel.advanced,
    ),

    // ================== วิทยุ COMSEC ==================
    QuizQuestion(
      id: 'radio_001',
      questionTh: 'COMSEC ย่อมาจากอะไร?',
      optionsTh: [
        'Combat Security',
        'Communications Security',
        'Command Security',
        'Computer Security'
      ],
      correctIndex: 1,
      explanationTh: 'COMSEC = Communications Security ความปลอดภัยการสื่อสาร',
      category: EWCategory.radio,
      difficulty: DifficultyLevel.beginner,
    ),
    QuizQuestion(
      id: 'radio_002',
      questionTh: 'TRANSEC หมายถึงอะไร?',
      optionsTh: [
        'การส่งผ่านอุปกรณ์',
        'ความปลอดภัยการส่งสัญญาณ',
        'การถ่ายโอนความลับ',
        'ความปลอดภัยการขนส่ง'
      ],
      correctIndex: 1,
      explanationTh: 'TRANSEC = Transmission Security ความปลอดภัยการส่ง เป็นส่วนหนึ่งของ COMSEC',
      category: EWCategory.radio,
      difficulty: DifficultyLevel.intermediate,
    ),

    // ================== ต่อต้านโดรน ==================
    QuizQuestion(
      id: 'drone_001',
      questionTh: 'C-UAS ย่อมาจากอะไร?',
      optionsTh: [
        'Command Unmanned Aircraft System',
        'Counter-Unmanned Aerial Systems',
        'Control Unit Air Security',
        'Combined UAV Attack System'
      ],
      correctIndex: 1,
      explanationTh: 'C-UAS = Counter-Unmanned Aerial Systems ระบบต่อต้านอากาศยานไร้คนขับ',
      category: EWCategory.antiDrone,
      difficulty: DifficultyLevel.beginner,
    ),
    QuizQuestion(
      id: 'drone_002',
      questionTh: 'การตรวจจับโดรนด้วย RF Detection อาศัยหลักการใด?',
      optionsTh: [
        'ตรวจจับความร้อน',
        'ตรวจจับสัญญาณควบคุมโดรน',
        'ตรวจจับเสียง',
        'ตรวจจับภาพ'
      ],
      correctIndex: 1,
      explanationTh: 'RF Detection ใช้เซ็นเซอร์คลื่นวิทยุเพื่อตรวจจับสัญญาณควบคุมระหว่างโดรนกับตัวควบคุม',
      category: EWCategory.antiDrone,
      difficulty: DifficultyLevel.intermediate,
    ),

    // ================== GPS Warfare ==================
    QuizQuestion(
      id: 'gps_001',
      questionTh: 'สัญญาณ GPS L1 มีความถี่เท่าไร?',
      optionsTh: [
        '1227.60 MHz',
        '1575.42 MHz',
        '2400.00 MHz',
        '5800.00 MHz'
      ],
      correctIndex: 1,
      explanationTh: 'สัญญาณ GPS L1 อยู่ที่ความถี่ 1575.42 MHz เป็นสัญญาณหลักสำหรับการนำทางทั่วไป',
      category: EWCategory.gpsWarfare,
      difficulty: DifficultyLevel.intermediate,
    ),
    QuizQuestion(
      id: 'gps_002',
      questionTh: 'GPS Spoofing ต่างจาก GPS Jamming อย่างไร?',
      optionsTh: [
        'Spoofing ใช้กำลังส่งน้อยกว่า',
        'Spoofing ส่งสัญญาณปลอมหลอกตำแหน่ง',
        'Spoofing ทำงานที่ความถี่สูงกว่า',
        'Spoofing มีผลกระทบน้อยกว่า'
      ],
      correctIndex: 1,
      explanationTh: 'GPS Spoofing ส่งสัญญาณ GPS ปลอมเพื่อหลอกให้อุปกรณ์แสดงตำแหน่งผิด ต่างจาก Jamming ที่แค่รบกวนไม่ให้รับสัญญาณ',
      category: EWCategory.gpsWarfare,
      difficulty: DifficultyLevel.advanced,
    ),
    QuizQuestion(
      id: 'gps_003',
      questionTh: 'GNSS ย่อมาจากอะไร?',
      optionsTh: [
        'Global Network Satellite System',
        'Global Navigation Satellite System',
        'General Navigation Signal Service',
        'Ground Network Support System'
      ],
      correctIndex: 1,
      explanationTh: 'GNSS = Global Navigation Satellite System คำรวมสำหรับระบบนำทางด้วยดาวเทียมทั่วโลก รวมถึง GPS, GLONASS, Galileo, BeiDou',
      category: EWCategory.gpsWarfare,
      difficulty: DifficultyLevel.beginner,
    ),

    // ================== คำถามเพิ่มเติมจากหลักสูตร EW ==================
    // ECM แบบต่างๆ
    QuizQuestion(
      id: 'ea_005',
      questionTh: 'ECM แบ่งออกเป็นกี่ประเภทหลัก?',
      optionsTh: ['1 ประเภท', '2 ประเภท', '3 ประเภท', '4 ประเภท'],
      correctIndex: 1,
      explanationTh: 'ECM แบ่งเป็น 2 ประเภท: Active (ใช้เครื่องส่ง) และ Passive (ไม่ใช้เครื่องส่ง)',
      category: EWCategory.ea,
      difficulty: DifficultyLevel.beginner,
    ),
    QuizQuestion(
      id: 'ea_006',
      questionTh: 'ข้อใดเป็น Active ECM?',
      optionsTh: ['CHAFF', 'FLARE', 'Jamming', 'DECOY'],
      correctIndex: 2,
      explanationTh: 'Jamming เป็น Active ECM เพราะใช้เครื่องส่งสัญญาณ ส่วน CHAFF, FLARE, DECOY เป็น Passive ECM',
      category: EWCategory.ea,
      difficulty: DifficultyLevel.beginner,
    ),
    QuizQuestion(
      id: 'ea_007',
      questionTh: 'CHAFF ทำหน้าที่อย่างไร?',
      optionsTh: [
        'แผ่ความร้อนหลอกจรวดนำวิถี',
        'สะท้อนคลื่นเรดาร์เพื่อรบกวน',
        'ส่งสัญญาณเลียนแบบเป้าหมาย',
        'รบกวนการสื่อสารวิทยุ'
      ],
      correctIndex: 1,
      explanationTh: 'CHAFF เป็นแถบโลหะที่ทำหน้าที่เป็นตัวสะท้อนคลื่นเรดาร์ (Dipole) เพื่อรบกวนการทำงานของเรดาร์',
      category: EWCategory.ea,
      difficulty: DifficultyLevel.intermediate,
    ),
    QuizQuestion(
      id: 'ea_008',
      questionTh: 'FLARE ใช้ต่อต้านอาวุธประเภทใด?',
      optionsTh: [
        'จรวดนำวิถีเรดาร์',
        'จรวดนำวิถีอินฟราเรด',
        'ปืนใหญ่ต่อสู้อากาศยาน',
        'ระเบิดลูกปราย'
      ],
      correctIndex: 1,
      explanationTh: 'FLARE แผ่ความร้อนเพื่อหลอกลวงจรวดนำวิถีอินฟราเรด (IR-guided missiles)',
      category: EWCategory.ea,
      difficulty: DifficultyLevel.beginner,
    ),
    QuizQuestion(
      id: 'ea_009',
      questionTh: 'Stream Chaff Dispensing ใช้ในสถานการณ์ใด?',
      optionsTh: [
        'ต่อต้านเรดาร์ติดตาม',
        'ช่วยในการเจาะแนวป้องกัน',
        'หลบหลีกจรวด',
        'รบกวนการสื่อสาร'
      ],
      correctIndex: 1,
      explanationTh: 'Stream Chaff Dispensing คือการปล่อย CHAFF ต่อเนื่องตลอดเส้นทางบิน ช่วยในการเจาะแนวป้องกัน (Penetration Aid)',
      category: EWCategory.ea,
      difficulty: DifficultyLevel.intermediate,
    ),
    QuizQuestion(
      id: 'ea_010',
      questionTh: 'Range Deception หลอกเรดาร์ด้วยวิธีใด?',
      optionsTh: [
        'เปลี่ยนความถี่สัญญาณ',
        'เปลี่ยน Pulse และ PRF',
        'ส่ง CHAFF',
        'ลดพื้นที่สะท้อน'
      ],
      correctIndex: 1,
      explanationTh: 'Range Deception หลอกเรดาร์โดยการเปลี่ยนแปลง Pulse และ PRF ทำให้แสดงระยะทางผิดพลาด',
      category: EWCategory.ea,
      difficulty: DifficultyLevel.advanced,
    ),

    // ECCM และการป้องกัน
    QuizQuestion(
      id: 'ep_005',
      questionTh: 'Radio Silence ใช้เมื่อใด?',
      optionsTh: [
        'เมื่อต้องการส่งสัญญาณระยะไกล',
        'เมื่อต้องการหลีกเลี่ยงการถูกตรวจจับ',
        'เมื่อต้องการเพิ่มกำลังส่ง',
        'เมื่อต้องการทดสอบอุปกรณ์'
      ],
      correctIndex: 1,
      explanationTh: 'Radio Silence คือการงดใช้วิทยุทั้งหมด เพื่อหลีกเลี่ยงการถูกตรวจจับ มักใช้ก่อนการปฏิบัติการสำคัญ',
      category: EWCategory.ep,
      difficulty: DifficultyLevel.beginner,
    ),
    QuizQuestion(
      id: 'ep_006',
      questionTh: 'MIJI ย่อมาจากอะไร?',
      optionsTh: [
        'Military Intelligence Joint Information',
        'Meaconing, Intrusion, Jamming, Interference',
        'Mission Information Joint Intelligence',
        'Multiple Interference Jamming Information'
      ],
      correctIndex: 1,
      explanationTh: 'MIJI = Meaconing, Intrusion, Jamming, Interference เป็นรหัสรายงานเหตุการณ์ EW',
      category: EWCategory.ep,
      difficulty: DifficultyLevel.intermediate,
    ),
    QuizQuestion(
      id: 'ep_007',
      questionTh: 'SIGSEC รวมถึงอะไรบ้าง?',
      optionsTh: [
        'COMSEC และ TRANSEC',
        'ESM และ ECM',
        'ELINT และ COMINT',
        'ECCM และ EMCON'
      ],
      correctIndex: 0,
      explanationTh: 'SIGSEC (Signal Security) รวมถึง COMSEC (Communications Security) และ TRANSEC (Transmission Security)',
      category: EWCategory.ep,
      difficulty: DifficultyLevel.intermediate,
    ),

    // IFF และเรดาร์
    QuizQuestion(
      id: 'radar_005',
      questionTh: 'IFF ย่อมาจากอะไร?',
      optionsTh: [
        'Identification Friend or Foe',
        'Information Frequency Format',
        'Integrated Fire Function',
        'Intelligence Field Force'
      ],
      correctIndex: 0,
      explanationTh: 'IFF = Identification Friend or Foe ระบบแยกแยะมิตรหรือศัตรู',
      category: EWCategory.radar,
      difficulty: DifficultyLevel.beginner,
    ),
    QuizQuestion(
      id: 'radar_006',
      questionTh: 'Burn-through Range คืออะไร?',
      optionsTh: [
        'ระยะทำลายเป้าหมาย',
        'ระยะที่เรดาร์ตรวจจับได้แม้มีการรบกวน',
        'ระยะสูงสุดของเรดาร์',
        'ระยะต่ำสุดของเรดาร์'
      ],
      correctIndex: 1,
      explanationTh: 'Burn-through Range คือระยะที่เรดาร์สามารถตรวจจับเป้าหมายได้แม้มีการรบกวน เพราะสัญญาณสะท้อนแรงกว่าสัญญาณรบกวน',
      category: EWCategory.radar,
      difficulty: DifficultyLevel.advanced,
    ),

    // ยุทธวิธี EW
    QuizQuestion(
      id: 'tac_001',
      questionTh: 'C3I ย่อมาจากอะไร?',
      optionsTh: [
        'Command, Control, Communications, Intelligence',
        'Combat, Counter, Communication, Information',
        'Central, Control, Computer, Integration',
        'Command, Combat, Counter, Intelligence'
      ],
      correctIndex: 0,
      explanationTh: 'C3I = Command, Control, Communications and Intelligence การบังคับบัญชา ควบคุม สื่อสาร และข่าวกรอง',
      category: EWCategory.tactics,
      difficulty: DifficultyLevel.beginner,
    ),
    QuizQuestion(
      id: 'tac_002',
      questionTh: 'REC สามารถลดประสิทธิภาพข้าศึกได้เท่าไร?',
      optionsTh: ['10%', '25%', '50%', '75%'],
      correctIndex: 2,
      explanationTh: 'REC (Radio Electronic Combat) สามารถลดประสิทธิภาพข้าศึกได้ถึง 50% ตามหลักนิยมทางทหาร',
      category: EWCategory.tactics,
      difficulty: DifficultyLevel.intermediate,
    ),
    QuizQuestion(
      id: 'tac_003',
      questionTh: 'EW Cell อยู่ในหน่วยงานใด?',
      optionsTh: [
        'หน่วยปฏิบัติการพิเศษ',
        'กองบัญชาการ',
        'หน่วยส่งกำลังบำรุง',
        'หน่วยแพทย์'
      ],
      correctIndex: 1,
      explanationTh: 'EW Cell เป็นหน่วยงานในกองบัญชาการที่รับผิดชอบการวางแผนและประสานงาน EW',
      category: EWCategory.tactics,
      difficulty: DifficultyLevel.intermediate,
    ),
    QuizQuestion(
      id: 'tac_004',
      questionTh: 'EOB ใช้ประโยชน์อย่างไร?',
      optionsTh: [
        'เก็บข้อมูลระบบอิเล็กทรอนิกส์ข้าศึก',
        'ควบคุมการยิง',
        'นำทางอากาศยาน',
        'สื่อสารทางยุทธวิธี'
      ],
      correctIndex: 0,
      explanationTh: 'EOB (Electronic Order of Battle) เป็นฐานข้อมูลระบบอิเล็กทรอนิกส์ของข้าศึก ใช้ในการวางแผน EW',
      category: EWCategory.tactics,
      difficulty: DifficultyLevel.beginner,
    ),
    QuizQuestion(
      id: 'tac_005',
      questionTh: 'การจัด Echelon ของ EW มีกี่ระดับ?',
      optionsTh: ['2 ระดับ', '3 ระดับ', '4 ระดับ', '5 ระดับ'],
      correctIndex: 1,
      explanationTh: 'การจัด Echelon ของ EW มี 3 ระดับ: ระดับกองพล ระดับกองทัพ และระดับยุทธบริเวณ',
      category: EWCategory.tactics,
      difficulty: DifficultyLevel.intermediate,
    ),

    // COMINT/ELINT
    QuizQuestion(
      id: 'es_005',
      questionTh: 'COMINT ได้ข่าวกรองจากแหล่งใด?',
      optionsTh: [
        'การสื่อสารของข้าศึก',
        'สัญญาณเรดาร์',
        'สัญญาณนำทาง',
        'สัญญาณ IFF'
      ],
      correctIndex: 0,
      explanationTh: 'COMINT (Communications Intelligence) ได้ข่าวกรองจากการดักรับการสื่อสารของข้าศึก',
      category: EWCategory.es,
      difficulty: DifficultyLevel.beginner,
    ),
    QuizQuestion(
      id: 'es_006',
      questionTh: 'ELINT ครอบคลุมอะไรบ้าง?',
      optionsTh: [
        'เฉพาะการสื่อสาร',
        'เรดาร์ Navigation Aids และ IFF',
        'เฉพาะ GPS',
        'เฉพาะวิทยุ'
      ],
      correctIndex: 1,
      explanationTh: 'ELINT (Electronic Intelligence) ครอบคลุมสัญญาณที่ไม่ใช่การสื่อสาร เช่น เรดาร์, Navigation Aids, และ IFF',
      category: EWCategory.es,
      difficulty: DifficultyLevel.intermediate,
    ),

    // คำถามสำหรับนายสิบอาวุโส
    QuizQuestion(
      id: 'adv_001',
      questionTh: 'หลักการใช้ ESM และ ECM ร่วมกันเรียกว่าอะไร?',
      optionsTh: [
        'Defensive EW',
        'Electronics Combat',
        'Signal Warfare',
        'Spectrum Control'
      ],
      correctIndex: 1,
      explanationTh: 'Electronics Combat คือการใช้ ESM และ ECM ร่วมกันในการปฏิบัติการ EW เชิงรุก',
      category: EWCategory.tactics,
      difficulty: DifficultyLevel.advanced,
    ),
    QuizQuestion(
      id: 'adv_002',
      questionTh: 'Defensive EW รวมถึงมาตรการใดบ้าง?',
      optionsTh: [
        'ECCM และ EMCON',
        'ESM และ Jamming',
        'ECM และ CHAFF',
        'SIGINT และ DF'
      ],
      correctIndex: 0,
      explanationTh: 'Defensive EW รวมถึง ECCM (มาตรการต่อต้านการรบกวน) และ EMCON (การควบคุมการแผ่คลื่น)',
      category: EWCategory.ep,
      difficulty: DifficultyLevel.advanced,
    ),
    QuizQuestion(
      id: 'adv_003',
      questionTh: 'MED ย่อมาจากอะไร?',
      optionsTh: [
        'Military Electronic Defense',
        'Manipulative Electronic Deception',
        'Maximum Effective Distance',
        'Mission Electronic Data'
      ],
      correctIndex: 1,
      explanationTh: 'MED = Manipulative Electronic Deception การหลอกลวงด้วยการจัดการอิเล็กทรอนิกส์',
      category: EWCategory.ea,
      difficulty: DifficultyLevel.advanced,
    ),
    QuizQuestion(
      id: 'adv_004',
      questionTh: 'CEOI ย่อมาจากอะไร?',
      optionsTh: [
        'Communications-Electronics Operating Instructions',
        'Combat Electronic Operations Intelligence',
        'Central Electronic Operations Integration',
        'Command Electronic Orders Information'
      ],
      correctIndex: 0,
      explanationTh: 'CEOI = Communications-Electronics Operating Instructions คำสั่งปฏิบัติการสื่อสาร-อิเล็กทรอนิกส์',
      category: EWCategory.radio,
      difficulty: DifficultyLevel.advanced,
    ),
    QuizQuestion(
      id: 'adv_005',
      questionTh: 'Imitative Deception คืออะไร?',
      optionsTh: [
        'การรบกวนสัญญาณ',
        'การส่งสัญญาณเลียนแบบข้าศึก',
        'การดักรับสัญญาณ',
        'การวิเคราะห์สเปกตรัม'
      ],
      correctIndex: 1,
      explanationTh: 'Imitative Deception คือการส่งสัญญาณเลียนแบบการสื่อสารของข้าศึกเพื่อแทรกคำสั่งปลอม',
      category: EWCategory.ea,
      difficulty: DifficultyLevel.advanced,
    ),
  ];

  /// กรองคำถามตามหมวดหมู่
  static List<QuizQuestion> getByCategory(EWCategory category) {
    return allQuestions.where((q) => q.category == category).toList();
  }

  /// กรองคำถามตามระดับความยาก
  static List<QuizQuestion> getByDifficulty(DifficultyLevel difficulty) {
    return allQuestions.where((q) => q.difficulty == difficulty).toList();
  }

  /// สุ่มคำถามตามจำนวนที่กำหนด
  static List<QuizQuestion> getRandom(int count, {
    EWCategory? category,
    DifficultyLevel? difficulty,
  }) {
    var questions = List<QuizQuestion>.from(allQuestions);

    if (category != null) {
      questions = questions.where((q) => q.category == category).toList();
    }

    if (difficulty != null) {
      questions = questions.where((q) => q.difficulty == difficulty).toList();
    }

    questions.shuffle();
    return questions.take(count).toList();
  }
}

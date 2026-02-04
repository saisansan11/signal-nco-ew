import '../models/curriculum_models.dart';

/// คำศัพท์ EW สำหรับนายสิบเหล่าทหารสื่อสาร
class GlossaryData {
  static const List<GlossaryTerm> terms = [
    // พื้นฐาน EW
    GlossaryTerm(
      term: 'EW',
      fullForm: 'Electronic Warfare',
      definitionTh: 'สงครามอิเล็กทรอนิกส์ - การปฏิบัติการทางทหารที่เกี่ยวข้องกับการใช้พลังงานแม่เหล็กไฟฟ้าเพื่อควบคุมสเปกตรัมแม่เหล็กไฟฟ้าหรือโจมตีข้าศึก',
      category: EWCategory.overview,
      relatedTerms: ['ES', 'EA', 'EP'],
    ),
    GlossaryTerm(
      term: 'EMS',
      fullForm: 'Electromagnetic Spectrum',
      definitionTh: 'สเปกตรัมแม่เหล็กไฟฟ้า - ช่วงความถี่ของคลื่นแม่เหล็กไฟฟ้าทั้งหมด ตั้งแต่คลื่นวิทยุไปจนถึงรังสีแกมมา',
      category: EWCategory.spectrum,
    ),

    // 3 เสาหลัก
    GlossaryTerm(
      term: 'ES',
      fullForm: 'Electronic Support',
      definitionTh: 'การสนับสนุนทางอิเล็กทรอนิกส์ - การค้นหา ดักรับ ระบุ และระบุตำแหน่งของแหล่งพลังงานแม่เหล็กไฟฟ้าที่ตั้งใจหรือไม่ตั้งใจ',
      category: EWCategory.es,
      relatedTerms: ['ESM', 'SIGINT', 'DF'],
    ),
    GlossaryTerm(
      term: 'EA',
      fullForm: 'Electronic Attack',
      definitionTh: 'การโจมตีทางอิเล็กทรอนิกส์ - การใช้พลังงานแม่เหล็กไฟฟ้าเพื่อทำให้ลดประสิทธิภาพ ทำให้เป็นกลาง หรือทำลายขีดความสามารถในการรบของข้าศึก',
      category: EWCategory.ea,
      relatedTerms: ['ECM', 'Jamming'],
    ),
    GlossaryTerm(
      term: 'EP',
      fullForm: 'Electronic Protection',
      definitionTh: 'การป้องกันทางอิเล็กทรอนิกส์ - มาตรการป้องกันบุคลากร สิ่งอำนวยความสะดวก และอุปกรณ์จากผลกระทบของ EW ฝ่ายเดียวกันหรือฝ่ายตรงข้าม',
      category: EWCategory.ep,
      relatedTerms: ['ECCM', 'FHSS'],
    ),

    // ESM & Intelligence
    GlossaryTerm(
      term: 'ESM',
      fullForm: 'Electronic Support Measures',
      definitionTh: 'มาตรการสนับสนุนทางอิเล็กทรอนิกส์ - การตรวจจับ ดักรับ ระบุ บันทึก และวิเคราะห์พลังงานแม่เหล็กไฟฟ้าที่แผ่ออกมา',
      category: EWCategory.es,
    ),
    GlossaryTerm(
      term: 'SIGINT',
      fullForm: 'Signals Intelligence',
      definitionTh: 'ข่าวกรองสัญญาณ - ข่าวกรองที่ได้จากการดักรับสัญญาณอิเล็กทรอนิกส์',
      category: EWCategory.es,
      relatedTerms: ['COMINT', 'ELINT'],
    ),
    GlossaryTerm(
      term: 'COMINT',
      fullForm: 'Communications Intelligence',
      definitionTh: 'ข่าวกรองการสื่อสาร - ข่าวกรองที่ได้จากการดักรับการสื่อสารของต่างชาติ',
      category: EWCategory.es,
    ),
    GlossaryTerm(
      term: 'ELINT',
      fullForm: 'Electronic Intelligence',
      definitionTh: 'ข่าวกรองอิเล็กทรอนิกส์ - ข่าวกรองที่ได้จากการดักรับสัญญาณที่ไม่ใช่การสื่อสาร เช่น เรดาร์',
      category: EWCategory.es,
    ),
    GlossaryTerm(
      term: 'DF',
      fullForm: 'Direction Finding',
      definitionTh: 'การหาทิศทาง - เทคนิคการหาทิศทางหรือแหล่งที่มาของสัญญาณวิทยุ',
      category: EWCategory.es,
    ),
    GlossaryTerm(
      term: 'EOB',
      fullForm: 'Electronic Order of Battle',
      definitionTh: 'คำสั่งยุทธการทางอิเล็กทรอนิกส์ - ฐานข้อมูลของระบบอิเล็กทรอนิกส์ของข้าศึก',
      category: EWCategory.es,
    ),

    // ECM & Jamming
    GlossaryTerm(
      term: 'ECM',
      fullForm: 'Electronic Countermeasures',
      definitionTh: 'มาตรการตอบโต้ทางอิเล็กทรอนิกส์ - การใช้พลังงานแม่เหล็กไฟฟ้าเพื่อรบกวนหรือหลอกลวงระบบอิเล็กทรอนิกส์ของข้าศึก',
      category: EWCategory.ea,
    ),
    GlossaryTerm(
      term: 'Jamming',
      definitionTh: 'การรบกวนสัญญาณ - การใช้สัญญาณรบกวนเพื่อขัดขวางการสื่อสารหรือเรดาร์ของข้าศึก',
      category: EWCategory.ea,
      relatedTerms: ['Spot Jamming', 'Barrage Jamming', 'Sweep Jamming'],
    ),
    GlossaryTerm(
      term: 'Spot Jamming',
      definitionTh: 'การรบกวนจุด - การรบกวนความถี่เดียวหรือช่วงความถี่แคบๆ',
      category: EWCategory.ea,
    ),
    GlossaryTerm(
      term: 'Barrage Jamming',
      definitionTh: 'การรบกวนกว้าง - การรบกวนช่วงความถี่กว้างพร้อมกัน',
      category: EWCategory.ea,
    ),
    GlossaryTerm(
      term: 'Sweep Jamming',
      definitionTh: 'การรบกวนกวาด - การรบกวนที่เลื่อนความถี่ไปมาอย่างต่อเนื่อง',
      category: EWCategory.ea,
    ),
    GlossaryTerm(
      term: 'J/S Ratio',
      fullForm: 'Jamming-to-Signal Ratio',
      definitionTh: 'อัตราส่วนสัญญาณรบกวนต่อสัญญาณ - ตัวชี้วัดประสิทธิผลของการรบกวน ยิ่งสูงยิ่งรบกวนได้ผล',
      category: EWCategory.ea,
    ),
    GlossaryTerm(
      term: 'Spoofing',
      definitionTh: 'การหลอกลวง - การส่งสัญญาณปลอมเพื่อหลอกระบบของข้าศึก เช่น GPS Spoofing',
      category: EWCategory.ea,
    ),

    // ECCM & Protection
    GlossaryTerm(
      term: 'ECCM',
      fullForm: 'Electronic Counter-Countermeasures',
      definitionTh: 'มาตรการต่อต้านการตอบโต้ทางอิเล็กทรอนิกส์ - เทคนิคการป้องกันระบบของตนจากการรบกวน',
      category: EWCategory.ep,
    ),
    GlossaryTerm(
      term: 'FHSS',
      fullForm: 'Frequency Hopping Spread Spectrum',
      definitionTh: 'การกระโดดความถี่แบบกระจายสเปกตรัม - เทคนิคการเปลี่ยนความถี่อย่างรวดเร็วเพื่อหลีกเลี่ยงการรบกวน',
      category: EWCategory.ep,
    ),
    GlossaryTerm(
      term: 'EMCON',
      fullForm: 'Emission Control',
      definitionTh: 'การควบคุมการแผ่คลื่น - การจำกัดหรือหยุดการแผ่คลื่นแม่เหล็กไฟฟ้าเพื่อไม่ให้ถูกตรวจจับ',
      category: EWCategory.ep,
    ),
    GlossaryTerm(
      term: 'COMSEC',
      fullForm: 'Communications Security',
      definitionTh: 'ความปลอดภัยการสื่อสาร - มาตรการป้องกันการสื่อสารจากการดักรับและการโจมตี',
      category: EWCategory.radio,
    ),
    GlossaryTerm(
      term: 'TRANSEC',
      fullForm: 'Transmission Security',
      definitionTh: 'ความปลอดภัยการส่ง - มาตรการป้องกันการส่งสัญญาณจากการถูกดักรับและวิเคราะห์',
      category: EWCategory.radio,
    ),

    // ความถี่
    GlossaryTerm(
      term: 'HF',
      fullForm: 'High Frequency',
      definitionTh: 'ความถี่สูง (3-30 MHz) - ใช้สำหรับการสื่อสารระยะไกลผ่านการสะท้อนชั้นบรรยากาศ',
      category: EWCategory.spectrum,
    ),
    GlossaryTerm(
      term: 'VHF',
      fullForm: 'Very High Frequency',
      definitionTh: 'ความถี่สูงมาก (30-300 MHz) - ใช้สำหรับวิทยุยุทธวิธี การบิน และ FM',
      category: EWCategory.spectrum,
    ),
    GlossaryTerm(
      term: 'UHF',
      fullForm: 'Ultra High Frequency',
      definitionTh: 'ความถี่สูงยิ่ง (300 MHz-3 GHz) - ใช้สำหรับ data link, โทรทัศน์ และอากาศยาน',
      category: EWCategory.spectrum,
    ),
    GlossaryTerm(
      term: 'SHF',
      fullForm: 'Super High Frequency',
      definitionTh: 'ความถี่สูงพิเศษ (3-30 GHz) - ใช้สำหรับเรดาร์และการสื่อสารผ่านดาวเทียม',
      category: EWCategory.spectrum,
    ),

    // เรดาร์
    GlossaryTerm(
      term: 'PRF',
      fullForm: 'Pulse Repetition Frequency',
      definitionTh: 'ความถี่ซ้ำพัลส์ - อัตราการส่งพัลส์เรดาร์ มีผลต่อระยะและความเร็วที่ตรวจจับได้',
      category: EWCategory.radar,
    ),
    GlossaryTerm(
      term: 'Doppler',
      definitionTh: 'ดอปเปลอร์ - ปรากฏการณ์เปลี่ยนความถี่เนื่องจากการเคลื่อนที่สัมพัทธ์ ใช้ในเรดาร์ตรวจจับความเร็ว',
      category: EWCategory.radar,
    ),
    GlossaryTerm(
      term: 'RCS',
      fullForm: 'Radar Cross Section',
      definitionTh: 'พื้นที่หน้าตัดเรดาร์ - ขนาดการสะท้อนเรดาร์ของเป้าหมาย ยิ่งเล็กยิ่งตรวจจับยาก',
      category: EWCategory.radar,
    ),
    GlossaryTerm(
      term: 'SAR',
      fullForm: 'Synthetic Aperture Radar',
      definitionTh: 'เรดาร์รูรับสังเคราะห์ - เรดาร์ที่สร้างภาพความละเอียดสูงของพื้นผิว',
      category: EWCategory.radar,
    ),

    // โดรน
    GlossaryTerm(
      term: 'C-UAS',
      fullForm: 'Counter-Unmanned Aerial Systems',
      definitionTh: 'การต่อต้านอากาศยานไร้คนขับ - ระบบและเทคนิคการตรวจจับและต่อต้านโดรน',
      category: EWCategory.antiDrone,
    ),
    GlossaryTerm(
      term: 'RF Detection',
      definitionTh: 'การตรวจจับ RF - การใช้เซ็นเซอร์คลื่นวิทยุเพื่อตรวจจับสัญญาณควบคุมโดรน',
      category: EWCategory.antiDrone,
    ),

    // GPS
    GlossaryTerm(
      term: 'GPS L1',
      definitionTh: 'สัญญาณ GPS L1 ที่ความถี่ 1575.42 MHz - สัญญาณหลักสำหรับการนำทางทั่วไป',
      category: EWCategory.gpsWarfare,
    ),
    GlossaryTerm(
      term: 'GNSS',
      fullForm: 'Global Navigation Satellite System',
      definitionTh: 'ระบบนำทางด้วยดาวเทียมทั่วโลก - คำรวมสำหรับระบบ GPS, GLONASS, Galileo, BeiDou',
      category: EWCategory.gpsWarfare,
    ),

    // ยุทธวิธี
    GlossaryTerm(
      term: 'Kill Chain',
      definitionTh: 'ห่วงโซ่การทำลาย - ขั้นตอนการโจมตีตั้งแต่ค้นหาเป้าหมายจนถึงประเมินความเสียหาย',
      category: EWCategory.tactics,
    ),
    GlossaryTerm(
      term: 'Link Budget',
      definitionTh: 'งบประมาณเชื่อมโยง - การคำนวณกำลังสัญญาณจากเครื่องส่งถึงเครื่องรับ',
      category: EWCategory.radio,
    ),
    GlossaryTerm(
      term: 'LPI',
      fullForm: 'Low Probability of Intercept',
      definitionTh: 'ความน่าจะเป็นต่ำในการถูกดักรับ - เทคนิคการส่งสัญญาณที่ยากต่อการตรวจจับ',
      category: EWCategory.ep,
    ),

    // คำศัพท์เพิ่มเติมจากหลักสูตร EW
    GlossaryTerm(
      term: 'Radio Silence',
      definitionTh: 'การงดใช้วิทยุ - การหยุดการส่งสัญญาณวิทยุทั้งหมดเพื่อหลีกเลี่ยงการถูกตรวจจับ ใช้ก่อนการปฏิบัติการสำคัญ',
      category: EWCategory.ep,
    ),
    GlossaryTerm(
      term: 'CHAFF',
      definitionTh: 'แผ่นโลหะสะท้อนคลื่น - แถบอะลูมิเนียมหรือไนลอนเคลือบโลหะที่ปล่อยออกมาเพื่อรบกวนเรดาร์ ทำหน้าที่เป็นตัวสะท้อน',
      category: EWCategory.ea,
      relatedTerms: ['FLARE', 'DECOY'],
    ),
    GlossaryTerm(
      term: 'FLARE',
      definitionTh: 'พลุรบกวน - อุปกรณ์แผ่ความร้อนที่ปล่อยจากอากาศยานเพื่อหลอกลวงจรวดนำวิถีอินฟราเรด',
      category: EWCategory.ea,
    ),
    GlossaryTerm(
      term: 'DECOY',
      definitionTh: 'เป้าหลอก - อุปกรณ์ที่สร้างสัญญาณหรือรูปร่างเลียนแบบเป้าหมายจริงเพื่อหลอกลวงระบบของข้าศึก',
      category: EWCategory.ea,
    ),
    GlossaryTerm(
      term: 'IFF',
      fullForm: 'Identification Friend or Foe',
      definitionTh: 'การแยกแยะมิตรหรือศัตรู - ระบบสอบถามอัตโนมัติที่ใช้ระบุว่าเป้าหมายเป็นฝ่ายเดียวกันหรือข้าศึก',
      category: EWCategory.radar,
    ),
    GlossaryTerm(
      term: 'C3I',
      fullForm: 'Command, Control, Communications and Intelligence',
      definitionTh: 'การบังคับบัญชา ควบคุม สื่อสาร และข่าวกรอง - ระบบบูรณาการสำหรับการสั่งการและควบคุมกำลัง',
      category: EWCategory.tactics,
    ),
    GlossaryTerm(
      term: 'MIJI',
      fullForm: 'Meaconing, Intrusion, Jamming, Interference',
      definitionTh: 'การหลอกนำทาง การบุกรุก การรบกวน การแทรกแซง - รหัสรายงานเหตุการณ์ EW ที่เกิดขึ้น',
      category: EWCategory.ep,
    ),
    GlossaryTerm(
      term: 'SIGSEC',
      fullForm: 'Signal Security',
      definitionTh: 'ความปลอดภัยสัญญาณ - มาตรการป้องกันสัญญาณสื่อสารทั้งหมด รวม COMSEC และ TRANSEC',
      category: EWCategory.radio,
      relatedTerms: ['COMSEC', 'TRANSEC'],
    ),
    GlossaryTerm(
      term: 'REC',
      fullForm: 'Radio Electronic Combat',
      definitionTh: 'การรบอิเล็กทรอนิกส์วิทยุ - การใช้ EW ในการสนับสนุนการรบ สามารถลดประสิทธิภาพข้าศึกได้ถึง 50%',
      category: EWCategory.tactics,
    ),
    GlossaryTerm(
      term: 'MED',
      fullForm: 'Manipulative Electronic Deception',
      definitionTh: 'การหลอกลวงด้วยการจัดการอิเล็กทรอนิกส์ - การเปลี่ยนแปลงลักษณะของสัญญาณแม่เหล็กไฟฟ้าเพื่อหลอกข้าศึก',
      category: EWCategory.ea,
    ),
    GlossaryTerm(
      term: 'Range Deception',
      definitionTh: 'การหลอกระยะ - เทคนิคการหลอกเรดาร์โดยการเปลี่ยน Pulse และ PRF ทำให้แสดงระยะผิดพลาด',
      category: EWCategory.ea,
    ),
    GlossaryTerm(
      term: 'Azimuth Deception',
      definitionTh: 'การหลอกมุมราบ - เทคนิคการหลอกเรดาร์โดยส่ง Pulse เข้า Slide Lobe ทำให้แสดงทิศทางผิดพลาด',
      category: EWCategory.ea,
    ),
    GlossaryTerm(
      term: 'Burn-through Range',
      definitionTh: 'ระยะทะลุการรบกวน - ระยะที่เรดาร์สามารถตรวจจับเป้าหมายได้แม้มีการรบกวน เนื่องจากสัญญาณสะท้อนแรงกว่าสัญญาณรบกวน',
      category: EWCategory.radar,
    ),
    GlossaryTerm(
      term: 'EIRP',
      fullForm: 'Effective Isotropic Radiated Power',
      definitionTh: 'กำลังแผ่ไอโซทรอปิกประสิทธิผล - กำลังส่งรวมของเครื่องส่งและอัตราขยายเสาอากาศ ใช้คำนวณระยะการสื่อสาร',
      category: EWCategory.radio,
    ),
    GlossaryTerm(
      term: 'Dipole',
      definitionTh: 'ไดโพล - เสาอากาศพื้นฐานที่มีความยาวครึ่งคลื่น ใช้เป็นตัวสะท้อนใน CHAFF',
      category: EWCategory.spectrum,
    ),
    GlossaryTerm(
      term: 'Stream Chaff',
      definitionTh: 'การปล่อย CHAFF แบบต่อเนื่อง - เทคนิคการปล่อย CHAFF ตลอดเส้นทางบินเพื่อช่วยในการเจาะแนวป้องกัน',
      category: EWCategory.ea,
    ),
    GlossaryTerm(
      term: 'Burst Chaff',
      definitionTh: 'การปล่อย CHAFF แบบระเบิด - เทคนิคการปล่อย CHAFF จำนวนมากพร้อมกันเพื่อต่อต้านเรดาร์ติดตาม',
      category: EWCategory.ea,
    ),
    GlossaryTerm(
      term: 'Active ECM',
      definitionTh: 'ECM แบบ Active - การรบกวนที่ใช้เครื่องส่งสัญญาณ ได้แก่ Jamming และ Deception',
      category: EWCategory.ea,
    ),
    GlossaryTerm(
      term: 'Passive ECM',
      definitionTh: 'ECM แบบ Passive - การรบกวนที่ไม่ใช้เครื่องส่ง ได้แก่ CHAFF, FLARE และ DECOY',
      category: EWCategory.ea,
    ),
    GlossaryTerm(
      term: 'Ground Surveillance Radar',
      definitionTh: 'เรดาร์เฝ้าตรวจภาคพื้น - เรดาร์ที่ใช้ตรวจจับการเคลื่อนไหวของยานพาหนะและบุคคลบนพื้นดิน',
      category: EWCategory.radar,
    ),
    GlossaryTerm(
      term: 'Antenna Gain',
      definitionTh: 'อัตราขยายเสาอากาศ - ความสามารถของเสาอากาศในการรวมพลังงานไปยังทิศทางที่ต้องการ วัดเป็น dBi',
      category: EWCategory.radio,
    ),
    GlossaryTerm(
      term: 'Sensitivity',
      definitionTh: 'ความไว - ระดับสัญญาณต่ำสุดที่เครื่องรับสามารถตรวจจับได้ วัดเป็น dBm',
      category: EWCategory.es,
    ),
    GlossaryTerm(
      term: 'CEOI',
      fullForm: 'Communications-Electronics Operating Instructions',
      definitionTh: 'คำสั่งปฏิบัติการสื่อสาร-อิเล็กทรอนิกส์ - เอกสารกำหนดความถี่ รหัสเรียกขาน และขั้นตอนการสื่อสาร',
      category: EWCategory.radio,
    ),
    GlossaryTerm(
      term: 'EW Cell',
      definitionTh: 'เซลล์ EW - หน่วยงานในกองบัญชาการที่รับผิดชอบการวางแผนและประสานงาน EW',
      category: EWCategory.tactics,
    ),
    GlossaryTerm(
      term: 'Imitative Deception',
      definitionTh: 'การหลอกลวงเลียนแบบ - การส่งสัญญาณเลียนแบบการสื่อสารของข้าศึกเพื่อแทรกคำสั่งปลอม',
      category: EWCategory.ea,
    ),
  ];

  /// ค้นหาคำศัพท์
  static List<GlossaryTerm> search(String query) {
    final lowerQuery = query.toLowerCase();
    return terms.where((term) {
      return term.term.toLowerCase().contains(lowerQuery) ||
          term.definitionTh.toLowerCase().contains(lowerQuery) ||
          (term.fullForm?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// กรองตามหมวดหมู่
  static List<GlossaryTerm> getByCategory(EWCategory category) {
    return terms.where((term) => term.category == category).toList();
  }

  /// รายการหมวดหมู่ทั้งหมด
  static List<EWCategory> get categories {
    return terms.map((t) => t.category).toSet().toList();
  }
}

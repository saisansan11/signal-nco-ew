import '../models/campaign_model.dart';

/// รายการ Campaign ทั้งหมดในแอพ
class CampaignData {
  static const List<Campaign> allCampaigns = [
    // ==================== CAMPAIGN 1: ESM BASICS ====================
    Campaign(
      id: 'campaign_esm_basics',
      name: 'Signal Hunter',
      nameTh: 'นักล่าสัญญาณ',
      description: 'Learn the basics of Electronic Support Measures',
      descriptionTh: 'เรียนรู้พื้นฐาน ESM - การค้นหาและระบุสัญญาณ',
      storyIntro: '''
สถานการณ์: หน่วยของคุณได้รับมอบหมายให้ตรวจจับสัญญาณวิทยุ
ของข้าศึกในพื้นที่ปฏิบัติการ คุณจะต้องใช้ทักษะ ESM ในการ
ค้นหา ระบุ และรายงานสัญญาณที่ตรวจพบ

เป้าหมาย: เข้าใจการทำงานของ ESM และฝึกทักษะการตรวจจับสัญญาณ
''',
      difficulty: CampaignDifficulty.recruit,
      totalXp: 200,
      missions: [
        CampaignMission(
          id: 'esm_1_detect',
          name: 'First Contact',
          nameTh: 'การติดต่อครั้งแรก',
          description: 'Detect your first enemy signals',
          descriptionTh: 'ตรวจจับสัญญาณข้าศึกครั้งแรก',
          briefing: '''
ภารกิจ: ตรวจจับสัญญาณในพื้นที่
- เปิดเครื่องรับสัญญาณ
- สแกนย่านความถี่ที่กำหนด
- ระบุสัญญาณที่พบ 3 รายการ

คำแนะนำ: สังเกตความแรงของสัญญาณและความถี่
''',
          type: MissionType.esm,
          difficulty: CampaignDifficulty.recruit,
          timeLimit: 180,
          xpReward: 30,
          objectives: [
            MissionObjective(
              id: 'detect_3',
              description: 'Detect 3 signals',
              descriptionTh: 'ตรวจจับสัญญาณ 3 รายการ',
              targetValue: 3,
              type: 'detect',
            ),
          ],
        ),
        CampaignMission(
          id: 'esm_2_identify',
          name: 'Signal Classification',
          nameTh: 'จำแนกประเภทสัญญาณ',
          description: 'Learn to classify different signal types',
          descriptionTh: 'เรียนรู้การจำแนกประเภทสัญญาณ',
          briefing: '''
ภารกิจ: จำแนกประเภทสัญญาณที่ตรวจพบ
- สัญญาณการสื่อสาร (Communication)
- สัญญาณเรดาร์ (Radar)
- สัญญาณนำร่อง (Navigation)

คำแนะนำ: ดูรูปแบบคลื่นและย่านความถี่
''',
          type: MissionType.esm,
          difficulty: CampaignDifficulty.recruit,
          timeLimit: 240,
          xpReward: 40,
          objectives: [
            MissionObjective(
              id: 'identify_5',
              description: 'Correctly identify 5 signals',
              descriptionTh: 'ระบุประเภทสัญญาณถูกต้อง 5 รายการ',
              targetValue: 5,
              type: 'identify',
            ),
          ],
        ),
        CampaignMission(
          id: 'esm_3_spectrum',
          name: 'Spectrum Analyst',
          nameTh: 'นักวิเคราะห์สเปกตรัม',
          description: 'Analyze the electromagnetic spectrum',
          descriptionTh: 'วิเคราะห์สเปกตรัมแม่เหล็กไฟฟ้า',
          briefing: '''
ภารกิจ: วิเคราะห์สเปกตรัมในพื้นที่
- ค้นหาสัญญาณที่ซ่อนอยู่
- วัดความแรงของสัญญาณ
- บันทึกพารามิเตอร์สำคัญ

คำแนะนำ: ปรับช่วงความถี่และ sensitivity
''',
          type: MissionType.esm,
          difficulty: CampaignDifficulty.soldier,
          timeLimit: 300,
          xpReward: 50,
          objectives: [
            MissionObjective(
              id: 'analyze_spectrum',
              description: 'Find all hidden signals',
              descriptionTh: 'ค้นหาสัญญาณที่ซ่อนทั้งหมด',
              targetValue: 4,
              type: 'detect',
            ),
            MissionObjective(
              id: 'measure_strength',
              description: 'Measure signal strength accurately',
              descriptionTh: 'วัดความแรงสัญญาณให้ถูกต้อง',
              targetValue: 3,
              type: 'identify',
            ),
          ],
        ),
        CampaignMission(
          id: 'esm_4_df',
          name: 'Signal Locator',
          nameTh: 'ผู้หาตำแหน่งสัญญาณ',
          description: 'Use Direction Finding to locate emitters',
          descriptionTh: 'ใช้ DF หาตำแหน่งแหล่งส่งสัญญาณ',
          briefing: '''
ภารกิจ: หาตำแหน่งแหล่งส่งสัญญาณข้าศึก
- ใช้สถานี DF 3 แห่ง
- หาทิศทางของสัญญาณ
- คำนวณตำแหน่งด้วย triangulation

คำแนะนำ: ยิ่งมุมตัดกันใกล้ 90° ยิ่งแม่นยำ
''',
          type: MissionType.df,
          difficulty: CampaignDifficulty.soldier,
          timeLimit: 300,
          xpReward: 60,
          objectives: [
            MissionObjective(
              id: 'locate_emitter',
              description: 'Locate 2 emitters with >80% accuracy',
              descriptionTh: 'หาตำแหน่ง 2 แหล่งส่ง ความแม่นยำ >80%',
              targetValue: 2,
              type: 'locate',
            ),
          ],
        ),
      ],
    ),

    // ==================== CAMPAIGN 2: ECM OPERATIONS ====================
    Campaign(
      id: 'campaign_ecm_ops',
      name: 'Jammer',
      nameTh: 'นักรบกวนสัญญาณ',
      description: 'Master Electronic Counter Measures',
      descriptionTh: 'เชี่ยวชาญ ECM - การรบกวนและหลอกลวงอิเล็กทรอนิกส์',
      storyIntro: '''
สถานการณ์: กองกำลังข้าศึกใช้ระบบเรดาร์และการสื่อสารในการ
ประสานงานการโจมตี หน่วยของคุณได้รับคำสั่งให้ใช้ ECM เพื่อ
ขัดขวางการสื่อสารและทำให้เรดาร์ข้าศึกไร้ประสิทธิภาพ

เป้าหมาย: เรียนรู้เทคนิคการรบกวนต่างๆ และการใช้งานอย่างมีประสิทธิภาพ
''',
      difficulty: CampaignDifficulty.soldier,
      totalXp: 300,
      missions: [
        CampaignMission(
          id: 'ecm_1_spot',
          name: 'Spot Jammer',
          nameTh: 'การรบกวนแบบจุด',
          description: 'Learn spot jamming technique',
          descriptionTh: 'เรียนรู้การรบกวนแบบจุดความถี่',
          briefing: '''
ภารกิจ: รบกวนสัญญาณเป้าหมายด้วย Spot Jamming
- ตั้งความถี่ให้ตรงกับเป้าหมาย
- ปรับกำลังส่งให้เหมาะสม
- ทำให้ J/S Ratio >10 dB

คำแนะนำ: Spot jamming มีประสิทธิภาพสูงสุดที่ความถี่เดียว
''',
          type: MissionType.ecm,
          difficulty: CampaignDifficulty.soldier,
          timeLimit: 180,
          xpReward: 50,
          objectives: [
            MissionObjective(
              id: 'jam_target',
              description: 'Successfully jam 3 targets',
              descriptionTh: 'รบกวนเป้าหมายสำเร็จ 3 รายการ',
              targetValue: 3,
              type: 'jam',
            ),
          ],
        ),
        CampaignMission(
          id: 'ecm_2_barrage',
          name: 'Barrage Jammer',
          nameTh: 'การรบกวนแบบกว้าง',
          description: 'Learn barrage jamming technique',
          descriptionTh: 'เรียนรู้การรบกวนแบบครอบคลุมความถี่',
          briefing: '''
ภารกิจ: รบกวนหลายสัญญาณพร้อมกันด้วย Barrage Jamming
- กำหนดช่วงความถี่ที่ต้องการรบกวน
- ปรับ bandwidth ให้ครอบคลุม
- ระวังการใช้พลังงานที่เพิ่มขึ้น

คำแนะนำ: Barrage jamming รบกวนได้กว้างแต่กำลังต่อความถี่ลดลง
''',
          type: MissionType.ecm,
          difficulty: CampaignDifficulty.soldier,
          timeLimit: 240,
          xpReward: 60,
          objectives: [
            MissionObjective(
              id: 'barrage_jam',
              description: 'Jam multiple frequencies simultaneously',
              descriptionTh: 'รบกวนหลายความถี่พร้อมกัน',
              targetValue: 5,
              type: 'jam',
            ),
          ],
        ),
        CampaignMission(
          id: 'ecm_3_sweep',
          name: 'Sweep Jammer',
          nameTh: 'การรบกวนแบบกวาด',
          description: 'Master sweep jamming against FHSS',
          descriptionTh: 'เชี่ยวชาญการรบกวนแบบกวาดต่อ FHSS',
          briefing: '''
ภารกิจ: รบกวนสัญญาณ FHSS ด้วย Sweep Jamming
- กำหนดช่วงความถี่การกวาด
- ปรับความเร็วการกวาดให้เหมาะสม
- ทำให้สัญญาณ FHSS หยุดชะงัก

คำแนะนำ: ความเร็วกวาดต้องเร็วพอที่จะตามทัน hop rate
''',
          type: MissionType.ecm,
          difficulty: CampaignDifficulty.sergeant,
          timeLimit: 300,
          xpReward: 80,
          objectives: [
            MissionObjective(
              id: 'sweep_fhss',
              description: 'Disrupt FHSS communications',
              descriptionTh: 'ขัดขวางการสื่อสาร FHSS',
              targetValue: 3,
              type: 'jam',
            ),
          ],
        ),
        CampaignMission(
          id: 'ecm_4_radar_jam',
          name: 'Radar Jammer',
          nameTh: 'การรบกวนเรดาร์',
          description: 'Jam enemy radar systems',
          descriptionTh: 'รบกวนระบบเรดาร์ข้าศึก',
          briefing: '''
ภารกิจ: รบกวนเรดาร์ข้าศึกเพื่อปกป้องหน่วยฝ่ายเรา
- วิเคราะห์พารามิเตอร์เรดาร์
- เลือกเทคนิครบกวนที่เหมาะสม
- ทำให้ burn-through range ลดลง

คำแนะนำ: เรดาร์ต่างประเภทต้องการเทคนิครบกวนต่างกัน
''',
          type: MissionType.ecm,
          difficulty: CampaignDifficulty.sergeant,
          timeLimit: 300,
          xpReward: 100,
          objectives: [
            MissionObjective(
              id: 'jam_radar',
              description: 'Successfully jam 2 radar systems',
              descriptionTh: 'รบกวนระบบเรดาร์สำเร็จ 2 ระบบ',
              targetValue: 2,
              type: 'jam',
            ),
            MissionObjective(
              id: 'protect_assets',
              description: 'Protect friendly assets from detection',
              descriptionTh: 'ปกป้องหน่วยฝ่ายเราจากการตรวจจับ',
              targetValue: 1,
              type: 'survive',
            ),
          ],
        ),
      ],
    ),

    // ==================== CAMPAIGN 3: ECCM DEFENSE ====================
    Campaign(
      id: 'campaign_eccm_defense',
      name: 'Shield Bearer',
      nameTh: 'ผู้ถือโล่',
      description: 'Defend against electronic attacks',
      descriptionTh: 'ป้องกันการโจมตีทางอิเล็กทรอนิกส์ด้วย ECCM',
      storyIntro: '''
สถานการณ์: ข้าศึกพยายามรบกวนระบบสื่อสารและเรดาร์ของเรา
คุณจะต้องใช้มาตรการ ECCM เพื่อรักษาการทำงานของระบบ
และรับรองการสื่อสารที่มีประสิทธิภาพ

เป้าหมาย: เรียนรู้เทคนิค ECCM และการป้องกันการรบกวน
''',
      difficulty: CampaignDifficulty.sergeant,
      totalXp: 350,
      missions: [
        CampaignMission(
          id: 'eccm_1_fhss',
          name: 'Frequency Hopper',
          nameTh: 'กระโดดความถี่',
          description: 'Use FHSS to avoid jamming',
          descriptionTh: 'ใช้ FHSS หลบหลีกการรบกวน',
          briefing: '''
ภารกิจ: รักษาการสื่อสารด้วย FHSS
- เปิดใช้งาน Frequency Hopping
- กำหนดรูปแบบการกระโดด
- ส่งข้อความสำเร็จภายใต้การรบกวน

คำแนะนำ: ยิ่ง hop rate สูงยิ่งยากที่จะรบกวน
''',
          type: MissionType.eccm,
          difficulty: CampaignDifficulty.sergeant,
          timeLimit: 240,
          xpReward: 60,
          objectives: [
            MissionObjective(
              id: 'survive_jamming',
              description: 'Maintain communications under jamming',
              descriptionTh: 'รักษาการสื่อสารภายใต้การรบกวน',
              targetValue: 5,
              type: 'survive',
            ),
          ],
        ),
        CampaignMission(
          id: 'eccm_2_spread',
          name: 'Spread Spectrum',
          nameTh: 'กระจายสเปกตรัม',
          description: 'Apply spread spectrum techniques',
          descriptionTh: 'ใช้เทคนิคกระจายสเปกตรัม',
          briefing: '''
ภารกิจ: ใช้ Spread Spectrum เพื่อลดโอกาสถูกตรวจจับ
- เปิดใช้งาน Direct Sequence Spread Spectrum
- ปรับ spreading factor
- ซ่อนสัญญาณในระดับ noise

คำแนะนำ: Spread spectrum ลดความหนาแน่นพลังงานต่อความถี่
''',
          type: MissionType.eccm,
          difficulty: CampaignDifficulty.sergeant,
          timeLimit: 300,
          xpReward: 80,
          objectives: [
            MissionObjective(
              id: 'hide_signal',
              description: 'Hide signal below noise floor',
              descriptionTh: 'ซ่อนสัญญาณใต้ระดับ noise',
              targetValue: 3,
              type: 'survive',
            ),
          ],
        ),
        CampaignMission(
          id: 'eccm_3_power',
          name: 'Power Manager',
          nameTh: 'จัดการกำลัง',
          description: 'Use power management for ECCM',
          descriptionTh: 'ใช้การจัดการกำลังเพื่อ ECCM',
          briefing: '''
ภารกิจ: ปรับกำลังส่งเพื่อเอาชนะการรบกวน
- วิเคราะห์ระดับการรบกวน
- เพิ่มกำลังส่งเพื่อ burn-through
- รักษาความลับตำแหน่ง

คำแนะนำ: กำลังสูงเกินไปอาจเผยตำแหน่ง
''',
          type: MissionType.eccm,
          difficulty: CampaignDifficulty.officer,
          timeLimit: 300,
          xpReward: 100,
          objectives: [
            MissionObjective(
              id: 'burn_through',
              description: 'Achieve burn-through against jamming',
              descriptionTh: 'ทำ burn-through ผ่านการรบกวน',
              targetValue: 2,
              type: 'survive',
            ),
            MissionObjective(
              id: 'stay_covert',
              description: 'Maintain position secrecy',
              descriptionTh: 'รักษาความลับตำแหน่ง',
              targetValue: 1,
              type: 'survive',
            ),
          ],
        ),
      ],
    ),

    // ==================== CAMPAIGN 4: RADAR OPERATIONS ====================
    Campaign(
      id: 'campaign_radar_ops',
      name: 'Eagle Eye',
      nameTh: 'ตาอินทรี',
      description: 'Master radar operations and detection',
      descriptionTh: 'เชี่ยวชาญการปฏิบัติการเรดาร์และการตรวจจับ',
      storyIntro: '''
สถานการณ์: คุณได้รับมอบหมายให้ควบคุมสถานีเรดาร์ภาคสนาม
ภารกิจคือตรวจจับและติดตามเป้าหมายทางอากาศ พร้อมรายงาน
สถานการณ์ให้ศูนย์บัญชาการ

เป้าหมาย: เรียนรู้การทำงานของเรดาร์และการตรวจจับเป้าหมาย
''',
      difficulty: CampaignDifficulty.soldier,
      totalXp: 280,
      missions: [
        CampaignMission(
          id: 'radar_1_basic',
          name: 'Radar Operator',
          nameTh: 'พนักงานเรดาร์',
          description: 'Learn basic radar operation',
          descriptionTh: 'เรียนรู้การทำงานเรดาร์พื้นฐาน',
          briefing: '''
ภารกิจ: ตรวจจับเป้าหมายด้วยเรดาร์
- เปิดเครื่องเรดาร์และปรับตั้งค่า
- สังเกตจอแสดงผล
- ระบุเป้าหมายที่ตรวจพบ

คำแนะนำ: เป้าหมายจะปรากฏเป็นจุดสว่างบนจอ
''',
          type: MissionType.radar,
          difficulty: CampaignDifficulty.soldier,
          timeLimit: 180,
          xpReward: 40,
          objectives: [
            MissionObjective(
              id: 'detect_targets',
              description: 'Detect 5 targets',
              descriptionTh: 'ตรวจจับเป้าหมาย 5 รายการ',
              targetValue: 5,
              type: 'detect',
            ),
          ],
        ),
        CampaignMission(
          id: 'radar_2_classify',
          name: 'Target Classifier',
          nameTh: 'ผู้จำแนกเป้าหมาย',
          description: 'Classify different target types',
          descriptionTh: 'จำแนกประเภทเป้าหมายต่างๆ',
          briefing: '''
ภารกิจ: จำแนกประเภทเป้าหมาย
- อากาศยาน (Aircraft)
- เรือ (Vessel)
- โดรน (Drone)

คำแนะนำ: ดูขนาด ความเร็ว และรูปแบบการเคลื่อนที่
''',
          type: MissionType.radar,
          difficulty: CampaignDifficulty.soldier,
          timeLimit: 240,
          xpReward: 50,
          objectives: [
            MissionObjective(
              id: 'classify_correct',
              description: 'Correctly classify 8 targets',
              descriptionTh: 'จำแนกเป้าหมายถูกต้อง 8 รายการ',
              targetValue: 8,
              type: 'identify',
            ),
          ],
        ),
        CampaignMission(
          id: 'radar_3_track',
          name: 'Target Tracker',
          nameTh: 'ผู้ติดตามเป้าหมาย',
          description: 'Track moving targets',
          descriptionTh: 'ติดตามเป้าหมายเคลื่อนที่',
          briefing: '''
ภารกิจ: ติดตามเป้าหมายเคลื่อนที่
- เลือกเป้าหมายที่ต้องการติดตาม
- รักษาการติดตามอย่างต่อเนื่อง
- รายงานตำแหน่งและทิศทาง

คำแนะนำ: อย่าให้เป้าหมายหลุดออกจากการติดตาม
''',
          type: MissionType.radar,
          difficulty: CampaignDifficulty.sergeant,
          timeLimit: 300,
          xpReward: 70,
          objectives: [
            MissionObjective(
              id: 'track_targets',
              description: 'Successfully track 3 targets for 30 seconds each',
              descriptionTh: 'ติดตามเป้าหมาย 3 รายการ รายละ 30 วินาที',
              targetValue: 3,
              type: 'detect',
            ),
          ],
        ),
        CampaignMission(
          id: 'radar_4_threat',
          name: 'Threat Assessor',
          nameTh: 'ผู้ประเมินภัยคุกคาม',
          description: 'Assess and prioritize threats',
          descriptionTh: 'ประเมินและจัดลำดับความสำคัญภัยคุกคาม',
          briefing: '''
ภารกิจ: ประเมินภัยคุกคามและจัดลำดับความสำคัญ
- วิเคราะห์เป้าหมายทั้งหมด
- ระบุภัยคุกคามหลัก
- จัดลำดับความสำคัญ

คำแนะนำ: เป้าหมายที่เข้าใกล้และเร็วมักเป็นภัยคุกคามสูง
''',
          type: MissionType.radar,
          difficulty: CampaignDifficulty.sergeant,
          timeLimit: 300,
          xpReward: 100,
          objectives: [
            MissionObjective(
              id: 'prioritize',
              description: 'Correctly prioritize all threats',
              descriptionTh: 'จัดลำดับความสำคัญภัยคุกคามถูกต้อง',
              targetValue: 5,
              type: 'identify',
            ),
          ],
        ),
      ],
    ),

    // ==================== CAMPAIGN 5: COMBINED OPERATIONS ====================
    Campaign(
      id: 'campaign_combined',
      name: 'EW Commander',
      nameTh: 'ผู้บัญชาการ EW',
      description: 'Lead combined EW operations',
      descriptionTh: 'นำการปฏิบัติการ EW แบบผสมผสาน',
      storyIntro: '''
สถานการณ์สุดท้าย: คุณได้รับมอบหมายให้เป็นผู้บัญชาการ EW
ในการปฏิบัติการขนาดใหญ่ ต้องประสานงาน ESM, ECM และ ECCM
เพื่อสนับสนุนกำลังฝ่ายเราและขัดขวางข้าศึก

เป้าหมาย: ใช้ทุกทักษะที่เรียนมาในสถานการณ์จำลองจริง
''',
      difficulty: CampaignDifficulty.officer,
      totalXp: 500,
      missions: [
        CampaignMission(
          id: 'combined_1_recon',
          name: 'Recon Mission',
          nameTh: 'ภารกิจลาดตระเวน',
          description: 'Support reconnaissance operation',
          descriptionTh: 'สนับสนุนการปฏิบัติการลาดตระเวน',
          briefing: '''
ภารกิจ: สนับสนุน EW ให้การลาดตระเวน
1. ESM: ตรวจจับและระบุแหล่งส่งสัญญาณข้าศึก
2. ECCM: ปกป้องการสื่อสารฝ่ายเรา
3. หลีกเลี่ยงการตรวจจับ

เป้าหมาย: รวบรวมข้อมูลข่าวสารโดยไม่ถูกตรวจจับ
''',
          type: MissionType.combined,
          difficulty: CampaignDifficulty.officer,
          timeLimit: 420,
          xpReward: 120,
          objectives: [
            MissionObjective(
              id: 'gather_intel',
              description: 'Gather intelligence on 5 emitters',
              descriptionTh: 'รวบรวมข้อมูลแหล่งส่ง 5 แห่ง',
              targetValue: 5,
              type: 'detect',
            ),
            MissionObjective(
              id: 'stay_undetected',
              description: 'Complete without being detected',
              descriptionTh: 'เสร็จภารกิจโดยไม่ถูกตรวจจับ',
              targetValue: 1,
              type: 'survive',
            ),
          ],
        ),
        CampaignMission(
          id: 'combined_2_strike',
          name: 'Strike Support',
          nameTh: 'สนับสนุนการโจมตี',
          description: 'Provide EW support for strike mission',
          descriptionTh: 'ให้การสนับสนุน EW แก่ภารกิจโจมตี',
          briefing: '''
ภารกิจ: สนับสนุน EW ให้การโจมตีทางอากาศ
1. ESM: หาตำแหน่งเรดาร์ SAM
2. ECM: รบกวนเรดาร์ในช่วงโจมตี
3. ECCM: รักษาการสื่อสารกับอากาศยาน

เป้าหมาย: ปกป้องอากาศยานฝ่ายเราจากระบบ SAM
''',
          type: MissionType.combined,
          difficulty: CampaignDifficulty.officer,
          timeLimit: 480,
          xpReward: 150,
          objectives: [
            MissionObjective(
              id: 'locate_sam',
              description: 'Locate all SAM radars',
              descriptionTh: 'หาตำแหน่งเรดาร์ SAM ทั้งหมด',
              targetValue: 3,
              type: 'locate',
            ),
            MissionObjective(
              id: 'jam_sam',
              description: 'Jam SAM radar during strike',
              descriptionTh: 'รบกวนเรดาร์ SAM ระหว่างโจมตี',
              targetValue: 2,
              type: 'jam',
            ),
            MissionObjective(
              id: 'protect_aircraft',
              description: 'Keep all friendly aircraft safe',
              descriptionTh: 'รักษาความปลอดภัยอากาศยานฝ่ายเรา',
              targetValue: 1,
              type: 'survive',
            ),
          ],
        ),
        CampaignMission(
          id: 'combined_3_defense',
          name: 'Homeland Defense',
          nameTh: 'ป้องกันมาตุภูมิ',
          description: 'Defend against electronic attack',
          descriptionTh: 'ป้องกันการโจมตีทางอิเล็กทรอนิกส์',
          briefing: '''
ภารกิจ: ป้องกัน EW จากการโจมตีทางอิเล็กทรอนิกส์
1. ตรวจจับการรบกวนของข้าศึก
2. เปิดใช้มาตรการ ECCM
3. หาตำแหน่งและทำลายแหล่งรบกวน

เป้าหมาย: รักษาการทำงานของระบบการสื่อสารและเรดาร์
''',
          type: MissionType.combined,
          difficulty: CampaignDifficulty.commander,
          timeLimit: 600,
          xpReward: 200,
          objectives: [
            MissionObjective(
              id: 'detect_jammers',
              description: 'Locate all enemy jammers',
              descriptionTh: 'หาตำแหน่งเครื่องรบกวนข้าศึกทั้งหมด',
              targetValue: 4,
              type: 'locate',
            ),
            MissionObjective(
              id: 'maintain_ops',
              description: 'Keep radar and comms operational',
              descriptionTh: 'รักษาการทำงานของเรดาร์และการสื่อสาร',
              targetValue: 1,
              type: 'survive',
            ),
            MissionObjective(
              id: 'neutralize',
              description: 'Neutralize enemy jammers',
              descriptionTh: 'ทำลายเครื่องรบกวนข้าศึก',
              targetValue: 3,
              type: 'jam',
            ),
          ],
        ),
      ],
    ),
  ];

  /// Get campaign by ID
  static Campaign? getById(String id) {
    try {
      return allCampaigns.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get campaigns by difficulty
  static List<Campaign> getByDifficulty(CampaignDifficulty difficulty) {
    return allCampaigns.where((c) => c.difficulty == difficulty).toList();
  }

  /// Get total missions across all campaigns
  static int get totalMissions {
    return allCampaigns.fold(0, (sum, c) => sum + c.missions.length);
  }

  /// Get total XP available from all campaigns
  static int get totalXpAvailable {
    return allCampaigns.fold(0, (sum, c) => sum + c.totalXp);
  }
}

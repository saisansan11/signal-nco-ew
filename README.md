# Signal NCO EW Training App

แอพฝึกอบรมสงครามอิเล็กทรอนิกส์สำหรับนายสิบเหล่าทหารสื่อสาร
**EW Training App for NCO Signal Corps, Royal Thai Army**

---

## ภาพรวม (Overview)

แอพพลิเคชั่นนี้ออกแบบมาเพื่อการฝึกอบรมสงครามอิเล็กทรอนิกส์ (Electronic Warfare - EW) สำหรับนายสิบชั้นต้นและนายสิบอาวุโส เหล่าทหารสื่อสาร กองทัพบกไทย

This application is designed for Electronic Warfare (EW) training for Junior and Senior NCOs of the Signal Corps, Royal Thai Army.

---

## หลักสูตร (Curriculum)

### นายสิบชั้นต้น (Junior NCO) - 8 บทเรียน

| บท | หัวข้อ | เนื้อหา |
|----|--------|---------|
| 0 | ประวัติศาสตร์ EW | ยุทธที่เทนเนนเบิร์ก, เพิร์ล ฮาร์เบอร์ |
| 1 | ภาพรวม EW | นิยาม, 3 เสาหลัก (ES/EA/EP) |
| 2 | สเปกตรัมแม่เหล็กไฟฟ้า | HF/VHF/UHF/SHF |
| 3 | ESM พื้นฐาน | SIGINT, COMINT, ELINT |
| 4 | ECM พื้นฐาน | Spot/Barrage/Sweep Jamming |
| 5 | ECCM พื้นฐาน | FHSS, Anti-Jamming |
| 6 | วิทยุยุทธวิธี | COMSEC, TRANSEC |
| 7 | ระเบียบปฏิบัติ | SOPs, Checklists |

### นายสิบอาวุโส (Senior NCO) - 11 บทเรียน

| บท | หัวข้อ | เนื้อหา |
|----|--------|---------|
| 8 | ESM ขั้นสูง | Direction Finding, EOB |
| 9 | ECM ขั้นสูง | J/S Ratio, การวางแผนรบกวน |
| 10 | ECCM ขั้นสูง | เทคนิคต่อต้านการรบกวน |
| 11 | ระบบเรดาร์ | Pulse, CW, Doppler, SAR |
| 12 | Anti-Drone EW | C-UAS, การตรวจจับโดรน |
| 13 | GPS Warfare | Jamming, Spoofing |
| 14 | กรณีศึกษา EW | ยูเครน-รัสเซีย, ไทย-กัมพูชา |
| 15 | การวางแผนยุทธวิธี | EW Mission Planning |
| 16 | การประมาณการ EW | EW Estimate, ผนวก EW |
| 17 | การจัดตั้งหน่วย EW | โครงสร้าง พัน/ร้อย ปสอ. |
| 18 | ยุทธวิธี EW | แนวคิดสนามรบสมัยใหม่ |

---

## ฟีเจอร์หลัก (Key Features)

### การเรียนรู้แบบโต้ตอบ (Interactive Learning)
- **Spectrum Analyzer Simulator** - จำลองการวิเคราะห์สเปกตรัม
- **Radar Simulator** - จำลองการทำงานของเรดาร์
- **Jamming Simulator** - จำลองการรบกวนสัญญาณ

### กรณีศึกษา (Case Studies)
- **ยุทธที่เทนเนนเบิร์ก 1914** - SIGINT ครั้งแรกในประวัติศาสตร์
- **เพิร์ล ฮาร์เบอร์ 1941** - Radio Silence และการลวง
- **ยูเครน-รัสเซีย** - EW สมัยใหม่
- **ไทย-กัมพูชา** - SIGINT ชายแดน

### ระบบการเรียนรู้ (Learning System)
- **Flashcards** - การ์ดคำศัพท์ EW พร้อมอนิเมชั่น 3D flip
- **Quiz** - แบบทดสอบท้ายบท
- **Progress Tracking** - ติดตามความก้าวหน้า
- **Achievements** - ระบบเกียรติบัตร

---

## การติดตั้ง (Installation)

### ความต้องการ (Requirements)
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / VS Code

### ขั้นตอนการติดตั้ง (Setup)

```bash
# Clone repository
git clone https://github.com/saisansan11/signal-nco-ew.git

# เข้าไปในโฟลเดอร์
cd signal-nco-ew

# ติดตั้ง dependencies
flutter pub get

# รันแอพ
flutter run
```

### Build สำหรับ Release

```bash
# Android APK
flutter build apk --release

# Windows
flutter build windows --release

# Web
flutter build web --release
```

---

## โครงสร้างโปรเจค (Project Structure)

```
lib/
├── main.dart
├── app/
│   └── constants.dart          # สี, ขนาด, อนิเมชั่น
├── data/
│   ├── curriculum_data.dart    # หลักสูตรนายสิบชั้นต้น/อาวุโส
│   ├── glossary_data.dart      # คำศัพท์ EW 100+ คำ
│   └── quiz_data.dart          # คำถามแบบทดสอบ
├── models/
│   ├── curriculum_models.dart  # EWModule, Lesson, NCOLevel
│   ├── progress_models.dart    # UserProgress, Achievement
│   └── quiz_models.dart        # QuizQuestion
├── screens/
│   ├── splash/                 # Splash screen
│   ├── onboarding/             # เลือกระดับนายสิบ
│   ├── home/                   # Dashboard หลัก
│   ├── learning/               # บทเรียน, Flashcards
│   ├── interactive/            # Simulators
│   └── quiz/                   # แบบทดสอบ
├── widgets/
│   └── educational/            # Widget การศึกษา
└── services/
    └── progress_service.dart   # ติดตามความก้าวหน้า
```

---

## พัฒนาโดย (Developed By)

**ร.ต. วสันต์ ทัศนามล**
โรงเรียนทหารสื่อสาร กรมการทหารสื่อสาร (รร.ส.สส.)

---

## License

This project is for educational purposes only.
สงวนลิขสิทธิ์สำหรับการศึกษาเท่านั้น

---

## Version

**1.0.0** - Initial Release

import 'package:flutter/foundation.dart';
import 'sound_service.dart';
import 'haptic_service.dart';

/// Feedback Service - รวม Sound + Haptic เข้าด้วยกัน
/// ใช้งานง่ายสำหรับ events ต่างๆ ในแอพ
class FeedbackService extends ChangeNotifier {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  final SoundService _sound = SoundService();
  final HapticService _haptic = HapticService();

  SoundService get sound => _sound;
  HapticService get haptic => _haptic;

  /// Initialize both services
  Future<void> init() async {
    await _sound.init();
    await _haptic.init();
  }

  // ================== Common Events ==================

  /// Button tap - เมื่อกดปุ่ม
  Future<void> buttonTap() async {
    await Future.wait([
      _sound.playClick(),
      _haptic.lightTap(),
    ]);
  }

  /// Selection - เมื่อเลือกตัวเลือก
  Future<void> selection() async {
    await _haptic.selectionClick();
  }

  // ================== Detection Events ==================

  /// Target detected - เมื่อตรวจจับเป้าหมายได้
  Future<void> targetDetected() async {
    await Future.wait([
      _sound.playDetectionPing(),
      _haptic.detectionPulse(),
    ]);
  }

  /// Radar sweep detection - เมื่อ radar กวาดผ่านเป้าหมาย
  Future<void> radarDetection() async {
    await Future.wait([
      _sound.playRadarSweep(),
      _haptic.radarSweepPulse(),
    ]);
  }

  /// Signal found - เมื่อพบสัญญาณ
  Future<void> signalFound() async {
    await Future.wait([
      _sound.playDetectionPing(),
      _haptic.mediumTap(),
    ]);
  }

  // ================== Jamming Events ==================

  /// Jamming started - เมื่อเริ่มรบกวน
  Future<void> jammingStarted() async {
    await Future.wait([
      _sound.playJammingBuzz(),
      _haptic.jammingPulse(),
    ]);
  }

  /// Jamming effective - เมื่อรบกวนได้ผล
  Future<void> jammingEffective() async {
    await Future.wait([
      _sound.playSuccess(),
      _haptic.successVibration(),
    ]);
  }

  // ================== Success/Error Events ==================

  /// Success - เมื่อทำสำเร็จ
  Future<void> success() async {
    await Future.wait([
      _sound.playSuccess(),
      _haptic.successVibration(),
    ]);
  }

  /// Error - เมื่อผิดพลาด
  Future<void> error() async {
    await Future.wait([
      _sound.playError(),
      _haptic.errorVibration(),
    ]);
  }

  /// Warning - เมื่อมีคำเตือน
  Future<void> warning() async {
    await _haptic.warningVibration();
  }

  // ================== Achievement Events ==================

  /// Achievement unlocked - เมื่อปลดล็อครางวัล
  Future<void> achievementUnlocked() async {
    await Future.wait([
      _sound.playAchievementUnlock(),
      _haptic.achievementUnlockVibration(),
    ]);
  }

  /// Level up - เมื่อเลื่อนระดับ
  Future<void> levelUp() async {
    await Future.wait([
      _sound.playLevelUp(),
      _haptic.levelUpVibration(),
    ]);
  }

  // ================== Mission Events ==================

  /// Mission complete - เมื่อจบภารกิจ
  Future<void> missionComplete() async {
    await Future.wait([
      _sound.playMissionComplete(),
      _haptic.missionCompleteVibration(),
    ]);
  }

  /// Countdown tick - เสียงนับถอยหลัง
  Future<void> countdownTick() async {
    await Future.wait([
      _sound.playCountdownTick(),
      _haptic.lightTap(),
    ]);
  }

  @override
  void dispose() {
    _sound.dispose();
    super.dispose();
  }
}

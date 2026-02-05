import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

/// Haptic Service - จัดการ vibration feedback ในแอพ
/// ให้ feedback แบบสัมผัสเมื่อเกิด events ต่างๆ
class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  bool _hapticEnabled = true;
  bool _hasVibrator = false;

  bool get hapticEnabled => _hapticEnabled;

  /// Initialize service
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _hapticEnabled = prefs.getBool('haptic_enabled') ?? true;

    // ตรวจสอบว่าอุปกรณ์รองรับ vibration หรือไม่
    final hasVibrator = await Vibration.hasVibrator();
    _hasVibrator = hasVibrator == true;
  }

  /// Toggle haptic on/off
  Future<void> toggleHaptic() async {
    _hapticEnabled = !_hapticEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptic_enabled', _hapticEnabled);
  }

  /// Light tap feedback - การกดปุ่มทั่วไป
  Future<void> lightTap() async {
    if (!_hapticEnabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Medium tap feedback - การเลือกตัวเลือก
  Future<void> mediumTap() async {
    if (!_hapticEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Heavy tap feedback - การยืนยันสำคัญ
  Future<void> heavyTap() async {
    if (!_hapticEnabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Selection click - เมื่อเลือก item
  Future<void> selectionClick() async {
    if (!_hapticEnabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Success vibration - เมื่อทำสำเร็จ (pattern: สั้น-หยุด-ยาว)
  Future<void> successVibration() async {
    if (!_hapticEnabled || !_hasVibrator) return;
    await Vibration.vibrate(pattern: [0, 100, 50, 200], intensities: [128, 255]);
  }

  /// Error vibration - เมื่อผิดพลาด (pattern: สั้น 3 ครั้ง)
  Future<void> errorVibration() async {
    if (!_hapticEnabled || !_hasVibrator) return;
    await Vibration.vibrate(pattern: [0, 50, 30, 50, 30, 50], intensities: [200, 200, 200]);
  }

  /// Detection pulse - เมื่อตรวจจับสัญญาณได้
  Future<void> detectionPulse() async {
    if (!_hapticEnabled || !_hasVibrator) return;
    await Vibration.vibrate(duration: 80, amplitude: 128);
  }

  /// Jamming pulse - เมื่อรบกวนสัญญาณ (สั่นต่อเนื่อง)
  Future<void> jammingPulse() async {
    if (!_hapticEnabled || !_hasVibrator) return;
    await Vibration.vibrate(pattern: [0, 30, 20, 30, 20, 30], intensities: [100, 150, 200]);
  }

  /// Radar sweep pulse - เมื่อ radar sweep ผ่านเป้าหมาย
  Future<void> radarSweepPulse() async {
    if (!_hapticEnabled || !_hasVibrator) return;
    await Vibration.vibrate(duration: 50, amplitude: 100);
  }

  /// Warning vibration - เมื่อมีคำเตือน
  Future<void> warningVibration() async {
    if (!_hapticEnabled || !_hasVibrator) return;
    await Vibration.vibrate(pattern: [0, 150, 100, 150], intensities: [180, 180]);
  }

  /// Achievement unlock vibration - เมื่อปลดล็อครางวัล
  Future<void> achievementUnlockVibration() async {
    if (!_hapticEnabled || !_hasVibrator) return;
    await Vibration.vibrate(pattern: [0, 50, 50, 100, 50, 200], intensities: [100, 150, 255]);
  }

  /// Level up vibration - เมื่อเลื่อนระดับ
  Future<void> levelUpVibration() async {
    if (!_hapticEnabled || !_hasVibrator) return;
    await Vibration.vibrate(pattern: [0, 100, 100, 100, 100, 300], intensities: [128, 180, 255]);
  }

  /// Mission complete vibration - เมื่อจบภารกิจ
  Future<void> missionCompleteVibration() async {
    if (!_hapticEnabled || !_hasVibrator) return;
    await Vibration.vibrate(pattern: [0, 200, 100, 200, 100, 400], intensities: [128, 180, 255]);
  }

  /// Cancel any ongoing vibration
  Future<void> cancel() async {
    await Vibration.cancel();
  }
}

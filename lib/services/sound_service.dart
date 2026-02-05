import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sound Service - จัดการเสียง feedback ในแอพ
/// เสียงที่ใช้: detection ping, jamming buzz, success chime, error beep
class SoundService extends ChangeNotifier {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _soundEnabled = true;
  double _volume = 0.7;

  bool get soundEnabled => _soundEnabled;
  double get volume => _volume;

  /// Initialize service
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _volume = prefs.getDouble('sound_volume') ?? 0.7;
    await _player.setVolume(_volume);
    notifyListeners();
  }

  /// Toggle sound on/off
  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', _soundEnabled);
    notifyListeners();
  }

  /// Set volume (0.0 - 1.0)
  Future<void> setVolume(double vol) async {
    _volume = vol.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sound_volume', _volume);
    notifyListeners();
  }

  /// Play detection ping sound - เมื่อตรวจจับสัญญาณได้
  Future<void> playDetectionPing() async {
    if (!_soundEnabled) return;
    try {
      await _player.play(AssetSource('audio/detection_ping.mp3'));
    } catch (e) {
      // Fallback: ใช้ system sound
      debugPrint('Sound not found: detection_ping.mp3');
    }
  }

  /// Play jamming buzz sound - เมื่อรบกวนสัญญาณ
  Future<void> playJammingBuzz() async {
    if (!_soundEnabled) return;
    try {
      await _player.play(AssetSource('audio/jamming_buzz.mp3'));
    } catch (e) {
      debugPrint('Sound not found: jamming_buzz.mp3');
    }
  }

  /// Play success chime - เมื่อทำภารกิจสำเร็จ
  Future<void> playSuccess() async {
    if (!_soundEnabled) return;
    try {
      await _player.play(AssetSource('audio/success_chime.mp3'));
    } catch (e) {
      debugPrint('Sound not found: success_chime.mp3');
    }
  }

  /// Play error beep - เมื่อผิดพลาด
  Future<void> playError() async {
    if (!_soundEnabled) return;
    try {
      await _player.play(AssetSource('audio/error_beep.mp3'));
    } catch (e) {
      debugPrint('Sound not found: error_beep.mp3');
    }
  }

  /// Play radar sweep sound - เสียงกวาดเรดาร์
  Future<void> playRadarSweep() async {
    if (!_soundEnabled) return;
    try {
      await _player.play(AssetSource('audio/radar_sweep.mp3'));
    } catch (e) {
      debugPrint('Sound not found: radar_sweep.mp3');
    }
  }

  /// Play button click - เสียงกดปุ่ม
  Future<void> playClick() async {
    if (!_soundEnabled) return;
    try {
      await _player.play(AssetSource('audio/click.mp3'));
    } catch (e) {
      debugPrint('Sound not found: click.mp3');
    }
  }

  /// Play achievement unlock - เสียงปลดล็อครางวัล
  Future<void> playAchievementUnlock() async {
    if (!_soundEnabled) return;
    try {
      await _player.play(AssetSource('audio/achievement_unlock.mp3'));
    } catch (e) {
      debugPrint('Sound not found: achievement_unlock.mp3');
    }
  }

  /// Play level up - เสียงเลื่อนระดับ
  Future<void> playLevelUp() async {
    if (!_soundEnabled) return;
    try {
      await _player.play(AssetSource('audio/level_up.mp3'));
    } catch (e) {
      debugPrint('Sound not found: level_up.mp3');
    }
  }

  /// Play countdown tick - เสียงนับถอยหลัง
  Future<void> playCountdownTick() async {
    if (!_soundEnabled) return;
    try {
      await _player.play(AssetSource('audio/countdown_tick.mp3'));
    } catch (e) {
      debugPrint('Sound not found: countdown_tick.mp3');
    }
  }

  /// Play mission complete - เสียงจบภารกิจ
  Future<void> playMissionComplete() async {
    if (!_soundEnabled) return;
    try {
      await _player.play(AssetSource('audio/mission_complete.mp3'));
    } catch (e) {
      debugPrint('Sound not found: mission_complete.mp3');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

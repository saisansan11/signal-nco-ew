// Central Security Service for Signal NCO EW
// Manages app lock, session timeout, and security settings

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

import '../models/security_models.dart';
import 'encrypted_storage_service.dart';

class SecurityService extends ChangeNotifier {
  static SecurityService? _instance;
  static SecurityService get instance => _instance ??= SecurityService._();

  SecurityService._();

  final EncryptedStorageService _storage = EncryptedStorageService.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();

  SecuritySettings _settings = const SecuritySettings();
  bool _isAppLocked = false;
  DateTime _lastActivityTime = DateTime.now();
  Timer? _sessionTimer;

  static const String _settingsKey = 'security_settings';

  // Getters
  SecuritySettings get settings => _settings;
  bool get isAppLocked => _isAppLocked;
  bool get isPinEnabled => _settings.isPinEnabled;
  bool get isBiometricEnabled => _settings.isBiometricEnabled;
  int get sessionTimeoutMinutes => _settings.sessionTimeoutMinutes;

  /// Initialize the service
  static Future<void> init() async {
    await instance._loadSettings();
    instance._startSessionTimer();

    // Lock app on start if PIN is enabled
    if (instance._settings.isPinEnabled) {
      instance._isAppLocked = true;
    }
  }

  /// Load security settings from encrypted storage
  Future<void> _loadSettings() async {
    try {
      final json = _storage.readEncrypted(_settingsKey);
      if (json != null) {
        final data = jsonDecode(json) as Map<String, dynamic>;
        _settings = SecuritySettings.fromJson(data);
      }
    } catch (e) {
      debugPrint('SecurityService: Error loading settings: $e');
      _settings = const SecuritySettings();
    }
  }

  /// Save security settings
  Future<void> _saveSettings() async {
    await _storage.writeEncrypted(
      _settingsKey,
      jsonEncode(_settings.toJson()),
    );
    notifyListeners();
  }

  // ============== PIN Management ==============

  /// Enable PIN lock
  Future<void> enablePin(String pin) async {
    await _storage.storePin(pin);
    _settings = _settings.copyWith(isPinEnabled: true, failedAttempts: 0, clearLockout: true);
    await _saveSettings();
  }

  /// Disable PIN lock
  Future<void> disablePin() async {
    await _storage.removePin();
    _settings = _settings.copyWith(
      isPinEnabled: false,
      isBiometricEnabled: false,
      failedAttempts: 0,
      clearLockout: true,
    );
    await _saveSettings();
  }

  /// Change PIN
  Future<bool> changePin(String currentPin, String newPin) async {
    final isValid = await _storage.verifyPin(currentPin);
    if (!isValid) return false;

    await _storage.storePin(newPin);
    _settings = _settings.copyWith(failedAttempts: 0, clearLockout: true);
    await _saveSettings();
    return true;
  }

  /// Verify PIN and unlock app
  Future<bool> verifyPinAndUnlock(String pin) async {
    // Check lockout
    if (_settings.isLockedOut) {
      return false;
    }

    final isValid = await _storage.verifyPin(pin);

    if (isValid) {
      _settings = _settings.copyWith(failedAttempts: 0, clearLockout: true);
      await _saveSettings();
      unlockApp();
      return true;
    } else {
      final newAttempts = _settings.failedAttempts + 1;
      if (newAttempts >= SecuritySettings.maxFailedAttempts) {
        // Lockout
        _settings = _settings.copyWith(
          failedAttempts: newAttempts,
          lockoutUntil: DateTime.now().add(
            Duration(minutes: SecuritySettings.lockoutDurationMinutes),
          ),
        );
      } else {
        _settings = _settings.copyWith(failedAttempts: newAttempts);
      }
      await _saveSettings();
      return false;
    }
  }

  // ============== Biometric ==============

  /// Check if device supports biometric
  Future<bool> canUseBiometric() async {
    if (kIsWeb) return false;
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      debugPrint('SecurityService: Biometric check failed: $e');
      return false;
    }
  }

  /// Enable biometric authentication
  Future<void> enableBiometric() async {
    if (!_settings.isPinEnabled) return; // PIN must be enabled first
    _settings = _settings.copyWith(isBiometricEnabled: true);
    await _saveSettings();
  }

  /// Disable biometric authentication
  Future<void> disableBiometric() async {
    _settings = _settings.copyWith(isBiometricEnabled: false);
    await _saveSettings();
  }

  /// Authenticate with biometric
  Future<bool> authenticateWithBiometric() async {
    if (kIsWeb) return false;
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'ยืนยันตัวตนเพื่อเข้าใช้แอป EW Training',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (authenticated) {
        unlockApp();
      }
      return authenticated;
    } catch (e) {
      debugPrint('SecurityService: Biometric auth failed: $e');
      return false;
    }
  }

  // ============== App Lock ==============

  /// Lock the app
  void lockApp() {
    if (_settings.isPinEnabled) {
      _isAppLocked = true;
      notifyListeners();
    }
  }

  /// Unlock the app
  void unlockApp() {
    _isAppLocked = false;
    _lastActivityTime = DateTime.now();
    notifyListeners();
  }

  // ============== Session Timeout ==============

  /// Update session timeout duration
  Future<void> setSessionTimeout(int minutes) async {
    _settings = _settings.copyWith(sessionTimeoutMinutes: minutes);
    await _saveSettings();
    _restartSessionTimer();
  }

  /// Record user activity (call on interactions)
  void recordActivity() {
    _lastActivityTime = DateTime.now();
  }

  /// Start session timeout timer
  void _startSessionTimer() {
    _sessionTimer?.cancel();
    if (_settings.sessionTimeoutMinutes <= 0) return;

    _sessionTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkSessionTimeout(),
    );
  }

  void _restartSessionTimer() {
    _sessionTimer?.cancel();
    _startSessionTimer();
  }

  void _checkSessionTimeout() {
    if (!_settings.isPinEnabled || _settings.sessionTimeoutMinutes <= 0) {
      return;
    }

    if (_isAppLocked) return; // Already locked

    final elapsed = DateTime.now().difference(_lastActivityTime);
    if (elapsed.inMinutes >= _settings.sessionTimeoutMinutes) {
      lockApp();
    }
  }

  /// Handle app lifecycle changes
  void onAppResumed() {
    if (!_settings.isPinEnabled || _settings.sessionTimeoutMinutes <= 0) {
      return;
    }

    final elapsed = DateTime.now().difference(_lastActivityTime);
    if (elapsed.inMinutes >= _settings.sessionTimeoutMinutes) {
      lockApp();
    }
  }

  void onAppPaused() {
    _lastActivityTime = DateTime.now();
  }

  /// Clean up
  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  /// Reset all security settings (logout)
  Future<void> resetAll() async {
    _sessionTimer?.cancel();
    await _storage.removePin();
    _settings = const SecuritySettings();
    _isAppLocked = false;
    await _saveSettings();
  }
}

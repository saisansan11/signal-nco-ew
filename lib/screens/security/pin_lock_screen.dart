// PIN Lock Screen for Signal NCO EW
// Military/sci-fi themed PIN entry with biometric support

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/constants.dart';
import '../../models/security_models.dart';
import '../../services/security_service.dart';
import '../../services/input_validator.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

enum PinScreenMode { verify, setup, confirm }

class PinLockScreen extends StatefulWidget {
  final PinScreenMode mode;
  final VoidCallback? onUnlocked;
  final VoidCallback? onPinSet;

  const PinLockScreen({
    super.key,
    this.mode = PinScreenMode.verify,
    this.onUnlocked,
    this.onPinSet,
  });

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  String _enteredPin = '';
  String _firstPin = ''; // For setup mode: store first entry
  String _statusMessage = '';
  bool _isProcessing = false;
  late PinScreenMode _currentMode;

  static const int _pinLength = 4;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.mode;
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _updateStatusMessage();
    _tryBiometric();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _updateStatusMessage() {
    setState(() {
      switch (_currentMode) {
        case PinScreenMode.verify:
          final security = SecurityService.instance;
          if (security.settings.isLockedOut) {
            final remaining = security.settings.lockoutRemaining;
            _statusMessage =
                'ถูกล็อก กรุณารอ ${remaining?.inMinutes ?? 5} นาที';
          } else if (security.settings.failedAttempts > 0) {
            final remaining = SecuritySettings.maxFailedAttempts -
                security.settings.failedAttempts;
            _statusMessage = 'ใส่รหัส PIN (เหลือ $remaining ครั้ง)';
          } else {
            _statusMessage = 'ใส่รหัส PIN เพื่อเข้าใช้งาน';
          }
          break;
        case PinScreenMode.setup:
          _statusMessage = 'สร้างรหัส PIN 4 หลัก';
          break;
        case PinScreenMode.confirm:
          _statusMessage = 'ยืนยันรหัส PIN อีกครั้ง';
          break;
      }
    });
  }

  Future<void> _tryBiometric() async {
    if (_currentMode != PinScreenMode.verify) return;
    if (kIsWeb) return;

    final security = SecurityService.instance;
    if (!security.isBiometricEnabled) return;
    if (security.settings.isLockedOut) return;

    // Small delay to let screen build
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final success = await security.authenticateWithBiometric();
    if (success && mounted) {
      widget.onUnlocked?.call();
    }
  }

  void _onDigitPressed(int digit) {
    if (_isProcessing) return;

    final security = SecurityService.instance;
    if (_currentMode == PinScreenMode.verify && security.settings.isLockedOut) {
      _updateStatusMessage();
      return;
    }

    if (_enteredPin.length >= _pinLength) return;

    setState(() {
      _enteredPin += digit.toString();
    });

    if (_enteredPin.length == _pinLength) {
      _handlePinComplete();
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty || _isProcessing) return;
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  Future<void> _handlePinComplete() async {
    setState(() => _isProcessing = true);

    switch (_currentMode) {
      case PinScreenMode.verify:
        await _verifyPin();
        break;
      case PinScreenMode.setup:
        _setupPin();
        break;
      case PinScreenMode.confirm:
        await _confirmPin();
        break;
    }

    setState(() => _isProcessing = false);
  }

  Future<void> _verifyPin() async {
    final security = SecurityService.instance;
    final success = await security.verifyPinAndUnlock(_enteredPin);

    if (success) {
      if (mounted) widget.onUnlocked?.call();
    } else {
      _shakeController.forward(from: 0);
      setState(() => _enteredPin = '');
      _updateStatusMessage();

      // Force logout after max attempts
      if (security.settings.isLockedOut) {
        _showLockoutDialog();
      }
    }
  }

  void _setupPin() {
    // Validate PIN strength
    final validation = InputValidator.validatePin(_enteredPin);
    if (!validation.isValid) {
      _shakeController.forward(from: 0);
      setState(() {
        _statusMessage = validation.errorMessage!;
        _enteredPin = '';
      });
      return;
    }

    _firstPin = _enteredPin;
    setState(() {
      _enteredPin = '';
      _currentMode = PinScreenMode.confirm;
    });
    _updateStatusMessage();
  }

  Future<void> _confirmPin() async {
    if (_enteredPin == _firstPin) {
      final security = SecurityService.instance;
      await security.enablePin(_enteredPin);
      if (mounted) {
        widget.onPinSet?.call();
      }
    } else {
      _shakeController.forward(from: 0);
      setState(() {
        _statusMessage = 'รหัส PIN ไม่ตรงกัน กรุณาเริ่มใหม่';
        _enteredPin = '';
        _firstPin = '';
        _currentMode = PinScreenMode.setup;
      });

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) _updateStatusMessage();
    }
  }

  void _showLockoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Row(
          children: [
            Icon(Icons.lock, color: AppColors.error),
            const SizedBox(width: 8),
            Text(
              'ถูกล็อก',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'ใส่รหัส PIN ผิดเกินจำนวนครั้งที่กำหนด\n\n'
          'กรุณารอ ${SecuritySettings.lockoutDurationMinutes} นาที หรือออกจากระบบ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'รอ',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService().signOut();
              await SecurityService.instance.resetAll();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('ออกจากระบบ',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Lock icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _currentMode == PinScreenMode.verify
                    ? Icons.lock
                    : Icons.lock_open,
                size: 36,
                color: Colors.white,
              ),
            ).animate().scale(
                  begin: const Offset(0.8, 0.8),
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                ),

            const SizedBox(height: 24),

            // Status message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // PIN dots
            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                final shakeOffset =
                    math.sin(_shakeController.value * math.pi * 4) * 10;
                return Transform.translate(
                  offset: Offset(shakeOffset, 0),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pinLength, (index) {
                  final isFilled = index < _enteredPin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled
                          ? AppColors.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: isFilled
                            ? AppColors.primary
                            : AppColors.textMuted,
                        width: 2,
                      ),
                      boxShadow: isFilled
                          ? [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                  );
                }),
              ),
            ),

            const Spacer(flex: 1),

            // Number pad
            _buildNumberPad(),

            const SizedBox(height: 16),

            // Bottom actions
            _buildBottomActions(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          for (int row = 0; row < 4; row++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int col = 0; col < 3; col++)
                    _buildKey(row, col),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKey(int row, int col) {
    if (row == 3) {
      // Last row: biometric / 0 / backspace
      if (col == 0) {
        // Biometric button (only in verify mode on mobile)
        if (_currentMode == PinScreenMode.verify &&
            !kIsWeb &&
            SecurityService.instance.isBiometricEnabled) {
          return _NumberButton(
            onTap: () => _tryBiometric(),
            child: const Icon(Icons.fingerprint, color: Colors.white, size: 28),
          );
        }
        return const SizedBox(width: 72, height: 72);
      } else if (col == 1) {
        return _NumberButton(
          child: Text(
            '0',
            style: AppTextStyles.headlineLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
          ),
          onTap: () => _onDigitPressed(0),
        );
      } else {
        return _NumberButton(
          onTap: _onBackspace,
          onLongPress: () => setState(() => _enteredPin = ''),
          child: const Icon(Icons.backspace_outlined,
              color: Colors.white, size: 24),
        );
      }
    }

    final digit = row * 3 + col + 1;
    return _NumberButton(
      child: Text(
        '$digit',
        style: AppTextStyles.headlineLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w300,
        ),
      ),
      onTap: () => _onDigitPressed(digit),
    );
  }

  Widget _buildBottomActions() {
    if (_currentMode == PinScreenMode.setup ||
        _currentMode == PinScreenMode.confirm) {
      return TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          'ยกเลิก',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    // Verify mode - show emergency logout
    return TextButton(
      onPressed: () async {
        await AuthService().signOut();
        await SecurityService.instance.resetAll();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Text(
        'ออกจากระบบ',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.error.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _NumberButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _NumberButton({
    required this.child,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(36),
        splashColor: AppColors.primary.withValues(alpha: 0.3),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

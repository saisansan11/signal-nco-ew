// Security data models for Signal NCO EW

/// Security settings persisted locally
class SecuritySettings {
  final bool isPinEnabled;
  final bool isBiometricEnabled;
  final int sessionTimeoutMinutes; // 0 = never
  final int failedAttempts;
  final DateTime? lockoutUntil;

  const SecuritySettings({
    this.isPinEnabled = false,
    this.isBiometricEnabled = false,
    this.sessionTimeoutMinutes = 15,
    this.failedAttempts = 0,
    this.lockoutUntil,
  });

  static const int maxFailedAttempts = 5;
  static const int lockoutDurationMinutes = 5;

  bool get isLockedOut =>
      lockoutUntil != null && DateTime.now().isBefore(lockoutUntil!);

  Duration? get lockoutRemaining {
    if (lockoutUntil == null) return null;
    final remaining = lockoutUntil!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  SecuritySettings copyWith({
    bool? isPinEnabled,
    bool? isBiometricEnabled,
    int? sessionTimeoutMinutes,
    int? failedAttempts,
    DateTime? lockoutUntil,
    bool clearLockout = false,
  }) {
    return SecuritySettings(
      isPinEnabled: isPinEnabled ?? this.isPinEnabled,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      sessionTimeoutMinutes:
          sessionTimeoutMinutes ?? this.sessionTimeoutMinutes,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockoutUntil: clearLockout ? null : (lockoutUntil ?? this.lockoutUntil),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isPinEnabled': isPinEnabled,
      'isBiometricEnabled': isBiometricEnabled,
      'sessionTimeoutMinutes': sessionTimeoutMinutes,
      'failedAttempts': failedAttempts,
      'lockoutUntil': lockoutUntil?.toIso8601String(),
    };
  }

  factory SecuritySettings.fromJson(Map<String, dynamic> json) {
    return SecuritySettings(
      isPinEnabled: json['isPinEnabled'] ?? false,
      isBiometricEnabled: json['isBiometricEnabled'] ?? false,
      sessionTimeoutMinutes: json['sessionTimeoutMinutes'] ?? 15,
      failedAttempts: json['failedAttempts'] ?? 0,
      lockoutUntil: json['lockoutUntil'] != null
          ? DateTime.parse(json['lockoutUntil'])
          : null,
    );
  }
}

/// Validation result
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult({required this.isValid, this.errorMessage});

  factory ValidationResult.valid() =>
      const ValidationResult(isValid: true);

  factory ValidationResult.invalid(String message) =>
      ValidationResult(isValid: false, errorMessage: message);
}
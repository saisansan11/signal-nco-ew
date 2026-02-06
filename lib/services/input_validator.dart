// Input Validation Utility for Signal NCO EW
// Prevents injection attacks and validates user inputs

import '../models/security_models.dart';

class InputValidator {
  // Dangerous patterns to strip
  static final RegExp _scriptTag =
      RegExp(r'<\s*script[^>]*>.*?<\s*/\s*script\s*>', caseSensitive: false, dotAll: true);
  static final RegExp _htmlTag = RegExp(r'<[^>]*>');
  static final RegExp _sqlInjection = RegExp(
      r"('|--|;|\b(DROP|DELETE|INSERT|UPDATE|SELECT|UNION|ALTER|EXEC)\b)",
      caseSensitive: false);

  // Allowed character patterns
  static final RegExp _thaiEnglishNumbers =
      RegExp(r'^[\u0E00-\u0E7Fa-zA-Z0-9\s\.\,\-\_\(\)\!\?\:]+$');
  static final RegExp _alphanumericOnly = RegExp(r'^[A-Z0-9]+$');
  static final RegExp _digitsOnly = RegExp(r'^[0-9]+$');
  static final RegExp _safeDisplayName =
      RegExp(r'^[\u0E00-\u0E7Fa-zA-Z0-9\s\.\-\_]+$');

  /// Sanitize input by stripping dangerous content
  static String sanitize(String input) {
    var sanitized = input;
    sanitized = sanitized.replaceAll(_scriptTag, '');
    sanitized = sanitized.replaceAll(_htmlTag, '');
    sanitized = sanitized.trim();
    return sanitized;
  }

  /// Validate classroom name
  static ValidationResult validateClassroomName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return ValidationResult.invalid('กรุณาใส่ชื่อห้องเรียน');
    }

    final trimmed = name.trim();

    if (trimmed.length > 100) {
      return ValidationResult.invalid(
          'ชื่อห้องเรียนต้องไม่เกิน 100 ตัวอักษร');
    }

    if (trimmed.length < 2) {
      return ValidationResult.invalid(
          'ชื่อห้องเรียนต้องมีอย่างน้อย 2 ตัวอักษร');
    }

    if (_scriptTag.hasMatch(trimmed) || _sqlInjection.hasMatch(trimmed)) {
      return ValidationResult.invalid('ชื่อห้องเรียนมีอักขระที่ไม่อนุญาต');
    }

    if (!_thaiEnglishNumbers.hasMatch(trimmed)) {
      return ValidationResult.invalid(
          'ใช้ได้เฉพาะตัวอักษรไทย อังกฤษ และตัวเลข');
    }

    return ValidationResult.valid();
  }

  /// Validate classroom join code
  static ValidationResult validateClassroomCode(String? code) {
    if (code == null || code.trim().isEmpty) {
      return ValidationResult.invalid('กรุณาใส่รหัสห้องเรียน');
    }

    final trimmed = code.trim().toUpperCase();

    if (trimmed.length != 6) {
      return ValidationResult.invalid('รหัสห้องเรียนต้องมี 6 ตัวอักษร');
    }

    if (!_alphanumericOnly.hasMatch(trimmed)) {
      return ValidationResult.invalid('รหัสต้องเป็นตัวอักษรภาษาอังกฤษพิมพ์ใหญ่และตัวเลขเท่านั้น');
    }

    return ValidationResult.valid();
  }

  /// Validate quiz answer text
  static ValidationResult validateQuizAnswer(String? answer) {
    if (answer == null || answer.trim().isEmpty) {
      return ValidationResult.invalid('กรุณาใส่คำตอบ');
    }

    final trimmed = answer.trim();

    if (trimmed.length > 500) {
      return ValidationResult.invalid('คำตอบต้องไม่เกิน 500 ตัวอักษร');
    }

    if (_scriptTag.hasMatch(trimmed)) {
      return ValidationResult.invalid('คำตอบมีเนื้อหาที่ไม่อนุญาต');
    }

    return ValidationResult.valid();
  }

  /// Validate display name
  static ValidationResult validateDisplayName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return ValidationResult.invalid('กรุณาใส่ชื่อแสดง');
    }

    final trimmed = name.trim();

    if (trimmed.length > 50) {
      return ValidationResult.invalid('ชื่อแสดงต้องไม่เกิน 50 ตัวอักษร');
    }

    if (trimmed.length < 2) {
      return ValidationResult.invalid('ชื่อแสดงต้องมีอย่างน้อย 2 ตัวอักษร');
    }

    if (!_safeDisplayName.hasMatch(trimmed)) {
      return ValidationResult.invalid(
          'ชื่อแสดงใช้ได้เฉพาะตัวอักษรไทย อังกฤษ ตัวเลข และ .- _');
    }

    return ValidationResult.valid();
  }

  /// Validate PIN code
  static ValidationResult validatePin(String? pin) {
    if (pin == null || pin.isEmpty) {
      return ValidationResult.invalid('กรุณาใส่รหัส PIN');
    }

    if (!_digitsOnly.hasMatch(pin)) {
      return ValidationResult.invalid('รหัส PIN ต้องเป็นตัวเลขเท่านั้น');
    }

    if (pin.length < 4 || pin.length > 6) {
      return ValidationResult.invalid('รหัส PIN ต้องมี 4-6 หลัก');
    }

    // Check for weak PINs
    if (_isWeakPin(pin)) {
      return ValidationResult.invalid(
          'รหัส PIN ไม่ปลอดภัย กรุณาใช้ตัวเลขที่ไม่ซ้ำ');
    }

    return ValidationResult.valid();
  }

  /// Validate general text input
  static ValidationResult validateTextInput(
    String? input, {
    required String fieldName,
    int maxLength = 500,
    int minLength = 1,
  }) {
    if (input == null || input.trim().isEmpty) {
      return ValidationResult.invalid('กรุณาใส่$fieldName');
    }

    final trimmed = input.trim();

    if (trimmed.length > maxLength) {
      return ValidationResult.invalid(
          '$fieldNameต้องไม่เกิน $maxLength ตัวอักษร');
    }

    if (trimmed.length < minLength) {
      return ValidationResult.invalid(
          '$fieldNameต้องมีอย่างน้อย $minLength ตัวอักษร');
    }

    if (_scriptTag.hasMatch(trimmed) || _sqlInjection.hasMatch(trimmed)) {
      return ValidationResult.invalid('$fieldNameมีเนื้อหาที่ไม่อนุญาต');
    }

    return ValidationResult.valid();
  }

  /// Check if PIN is too weak (all same digits, sequential)
  static bool _isWeakPin(String pin) {
    // All same digits: 1111, 0000
    if (pin.split('').toSet().length == 1) return true;

    // Sequential ascending: 1234, 2345
    bool isAscending = true;
    bool isDescending = true;
    for (int i = 1; i < pin.length; i++) {
      if (int.parse(pin[i]) != int.parse(pin[i - 1]) + 1) {
        isAscending = false;
      }
      if (int.parse(pin[i]) != int.parse(pin[i - 1]) - 1) {
        isDescending = false;
      }
    }
    if (isAscending || isDescending) return true;

    return false;
  }
}

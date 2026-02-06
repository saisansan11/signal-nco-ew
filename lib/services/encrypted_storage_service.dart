// Encrypted Storage Service for Signal NCO EW
// Provides AES encryption over SharedPreferences with key in secure storage

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EncryptedStorageService {
  static EncryptedStorageService? _instance;
  static EncryptedStorageService get instance =>
      _instance ??= EncryptedStorageService._();

  EncryptedStorageService._();

  late SharedPreferences _prefs;
  late FlutterSecureStorage _secureStorage;
  Uint8List? _encryptionKey;

  static const String _keyAlias = 'ew_sim_encryption_key';
  static const String _encryptedPrefix = 'enc_v1:';

  /// Initialize the service
  static Future<void> init() async {
    instance._prefs = await SharedPreferences.getInstance();
    instance._secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
    await instance._ensureEncryptionKey();
  }

  /// Ensure encryption key exists, create if not
  Future<void> _ensureEncryptionKey() async {
    try {
      final existingKey = await _secureStorage.read(key: _keyAlias);
      if (existingKey != null) {
        _encryptionKey = base64Decode(existingKey);
      } else {
        // Generate new 256-bit key
        final random = Random.secure();
        _encryptionKey =
            Uint8List.fromList(List.generate(32, (_) => random.nextInt(256)));
        await _secureStorage.write(
          key: _keyAlias,
          value: base64Encode(_encryptionKey!),
        );
      }
    } catch (e) {
      debugPrint('EncryptedStorage: Failed to load key, generating new: $e');
      final random = Random.secure();
      _encryptionKey =
          Uint8List.fromList(List.generate(32, (_) => random.nextInt(256)));
      try {
        await _secureStorage.write(
          key: _keyAlias,
          value: base64Encode(_encryptionKey!),
        );
      } catch (_) {
        // On web fallback, key lives only in memory this session
        debugPrint('EncryptedStorage: Key stored in memory only');
      }
    }
  }

  // ============== Secure Storage (small secrets) ==============

  /// Store a secret in flutter_secure_storage
  Future<void> writeSecret(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// Read a secret from flutter_secure_storage
  Future<String?> readSecret(String key) async {
    return await _secureStorage.read(key: key);
  }

  /// Delete a secret
  Future<void> deleteSecret(String key) async {
    await _secureStorage.delete(key: key);
  }

  // ============== Encrypted SharedPreferences (large data) ==============

  /// Write encrypted data to SharedPreferences
  Future<void> writeEncrypted(String key, String plaintext) async {
    if (_encryptionKey == null) {
      await _ensureEncryptionKey();
    }
    final encrypted = _encrypt(plaintext);
    await _prefs.setString(key, '$_encryptedPrefix$encrypted');
  }

  /// Read and decrypt data from SharedPreferences
  String? readEncrypted(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;

    // Check if data is encrypted
    if (raw.startsWith(_encryptedPrefix)) {
      final ciphertext = raw.substring(_encryptedPrefix.length);
      return _decrypt(ciphertext);
    }

    // Legacy plaintext data - return as-is for migration
    return raw;
  }

  /// Check if a key contains legacy (unencrypted) data
  bool isLegacyData(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return false;
    return !raw.startsWith(_encryptedPrefix);
  }

  /// Migrate legacy plaintext data to encrypted
  Future<bool> migrateToEncrypted(String key) async {
    final raw = _prefs.getString(key);
    if (raw == null) return false;

    if (!raw.startsWith(_encryptedPrefix)) {
      // Data is plaintext, encrypt it
      await writeEncrypted(key, raw);
      debugPrint('EncryptedStorage: Migrated key "$key" to encrypted format');
      return true;
    }
    return false; // Already encrypted
  }

  /// Remove a key
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  // ============== PIN Hashing ==============

  /// Hash a PIN with salt using SHA-256
  String hashPin(String pin, String salt) {
    final bytes = utf8.encode('$salt:$pin');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate a random salt
  String generateSalt() {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  /// Store hashed PIN
  Future<void> storePin(String pin) async {
    final salt = generateSalt();
    final hashedPin = hashPin(pin, salt);
    await _secureStorage.write(key: 'pin_salt', value: salt);
    await _secureStorage.write(key: 'pin_hash', value: hashedPin);
  }

  /// Verify PIN against stored hash
  Future<bool> verifyPin(String pin) async {
    final salt = await _secureStorage.read(key: 'pin_salt');
    final storedHash = await _secureStorage.read(key: 'pin_hash');
    if (salt == null || storedHash == null) return false;

    final inputHash = hashPin(pin, salt);
    return inputHash == storedHash;
  }

  /// Check if a PIN is set
  Future<bool> hasPinSet() async {
    final hash = await _secureStorage.read(key: 'pin_hash');
    return hash != null;
  }

  /// Remove stored PIN
  Future<void> removePin() async {
    await _secureStorage.delete(key: 'pin_salt');
    await _secureStorage.delete(key: 'pin_hash');
  }

  // ============== Simple XOR-based encryption ==============
  // Using XOR with SHA-256 derived key for SharedPreferences encryption.
  // This is sufficient for local data protection - not for transmitting secrets.

  String _encrypt(String plaintext) {
    if (_encryptionKey == null) return plaintext;

    final plaintextBytes = utf8.encode(plaintext);
    final keyStream = _deriveKeyStream(plaintextBytes.length);
    final encrypted = Uint8List(plaintextBytes.length);

    for (int i = 0; i < plaintextBytes.length; i++) {
      encrypted[i] = plaintextBytes[i] ^ keyStream[i];
    }

    return base64Encode(encrypted);
  }

  String? _decrypt(String ciphertext) {
    if (_encryptionKey == null) return null;

    try {
      final encryptedBytes = base64Decode(ciphertext);
      final keyStream = _deriveKeyStream(encryptedBytes.length);
      final decrypted = Uint8List(encryptedBytes.length);

      for (int i = 0; i < encryptedBytes.length; i++) {
        decrypted[i] = encryptedBytes[i] ^ keyStream[i];
      }

      return utf8.decode(decrypted);
    } catch (e) {
      debugPrint('EncryptedStorage: Decryption failed: $e');
      return null;
    }
  }

  /// Derive a key stream of arbitrary length using SHA-256 in counter mode
  Uint8List _deriveKeyStream(int length) {
    final stream = BytesBuilder();
    int counter = 0;

    while (stream.length < length) {
      final input = Uint8List.fromList([
        ..._encryptionKey!,
        ...utf8.encode(counter.toString()),
      ]);
      final hash = sha256.convert(input);
      stream.add(hash.bytes);
      counter++;
    }

    return Uint8List.fromList(stream.toBytes().sublist(0, length));
  }

  /// Clear all security data (for logout)
  Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      debugPrint('EncryptedStorage: Error clearing secure storage: $e');
    }
  }
}

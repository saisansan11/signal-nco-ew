// User Role Service for Signal NCO EW
// Manages user role state and provides role-based access control

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_role_model.dart';
import 'auth_service.dart';

/// Service to manage current user's role
/// Uses ChangeNotifier for reactive state management
class UserRoleService extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserRole? _currentRole;
  UserRoleData? _userData;
  bool _isLoading = true;
  String? _error;

  // Getters
  UserRole? get currentRole => _currentRole;
  UserRoleData? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isTeacher => _currentRole == UserRole.teacher;
  bool get isStudent => _currentRole == UserRole.student;
  bool get hasRole => _currentRole != null;

  /// Check and set the current user's role
  /// Call this after login or on app start
  Future<void> checkAndSetRole() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = _authService.currentUser;

      if (user == null) {
        _currentRole = null;
        _userData = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Check if user is teacher
      final isTeacher = await _authService.isCurrentUserTeacher();
      _currentRole = isTeacher ? UserRole.teacher : UserRole.student;

      // Get full user data
      final data = await _authService.getUserData();
      if (data != null) {
        _userData = UserRoleData.fromFirestore(data);
      } else {
        _userData = UserRoleData(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoURL: user.photoURL,
          role: _currentRole!,
        );
      }

      _isLoading = false;
      notifyListeners();

      debugPrint('UserRoleService: Role set to ${_currentRole?.thaiName}');
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('UserRoleService Error: $e');
    }
  }

  /// Clear role state (call on logout)
  void clearRole() {
    _currentRole = null;
    _userData = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
    debugPrint('UserRoleService: Role cleared');
  }

  /// Listen to auth state changes and update role accordingly
  void listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        clearRole();
      } else {
        checkAndSetRole();
      }
    });
  }

  /// Force refresh role from Firestore
  Future<void> refreshRole() async {
    await checkAndSetRole();
  }

  /// Get role display info
  String get roleDisplayName {
    if (_currentRole == null) return 'ไม่ทราบ';
    return _currentRole!.thaiName;
  }

  String get userDisplayName {
    return _userData?.displayName ?? 'ผู้ใช้';
  }

  String? get userPhotoURL {
    return _userData?.photoURL;
  }

  String? get userEmail {
    return _userData?.email;
  }
}

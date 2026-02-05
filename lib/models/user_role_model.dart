// User Role Model for Signal NCO EW
// Defines teacher and student roles

/// User role types
enum UserRole {
  teacher,
  student,
}

/// Extension to add Thai names and icons
extension UserRoleExtension on UserRole {
  String get thaiName {
    switch (this) {
      case UserRole.teacher:
        return 'ครูผู้สอน';
      case UserRole.student:
        return 'นักเรียน';
    }
  }

  String get englishName {
    switch (this) {
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.student:
        return 'Student';
    }
  }

  /// Convert string to UserRole
  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'teacher':
        return UserRole.teacher;
      case 'student':
      default:
        return UserRole.student;
    }
  }
}

/// User role data with additional info
class UserRoleData {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final UserRole role;
  final DateTime? lastLoginAt;

  const UserRoleData({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    required this.role,
    this.lastLoginAt,
  });

  bool get isTeacher => role == UserRole.teacher;
  bool get isStudent => role == UserRole.student;

  factory UserRoleData.fromFirestore(Map<String, dynamic> data) {
    return UserRoleData(
      uid: data['uid'] ?? '',
      email: data['email'],
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      role: UserRoleExtension.fromString(data['role'] ?? 'student'),
      lastLoginAt: data['lastLoginAt']?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'role': role == UserRole.teacher ? 'teacher' : 'student',
      'lastLoginAt': lastLoginAt,
    };
  }

  @override
  String toString() {
    return 'UserRoleData(uid: $uid, role: ${role.thaiName})';
  }
}

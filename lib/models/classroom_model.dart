// Classroom Model
// Model for virtual classrooms created by teachers

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Virtual classroom
class Classroom {
  final String id;
  final String name;
  final String nameTh;
  final String? description;
  final String teacherId;
  final String teacherName;
  final String code; // 6-digit join code
  final List<String> studentUids;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Classroom({
    required this.id,
    required this.name,
    required this.nameTh,
    this.description,
    required this.teacherId,
    required this.teacherName,
    required this.code,
    this.studentUids = const [],
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  int get studentCount => studentUids.length;

  factory Classroom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Classroom(
      id: doc.id,
      name: data['name'] ?? '',
      nameTh: data['nameTh'] ?? data['name'] ?? '',
      description: data['description'],
      teacherId: data['teacherId'] ?? '',
      teacherName: data['teacherName'] ?? '',
      code: data['code'] ?? '',
      studentUids: (data['studentUids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'nameTh': nameTh,
      'description': description,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'code': code,
      'studentUids': studentUids,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  Classroom copyWith({
    String? id,
    String? name,
    String? nameTh,
    String? description,
    String? teacherId,
    String? teacherName,
    String? code,
    List<String>? studentUids,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Classroom(
      id: id ?? this.id,
      name: name ?? this.name,
      nameTh: nameTh ?? this.nameTh,
      description: description ?? this.description,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      code: code ?? this.code,
      studentUids: studentUids ?? this.studentUids,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Generate a cryptographically secure 6-character classroom code
  /// Uses uppercase letters + digits, excluding ambiguous chars (O/0/I/1/L)
  static String generateCode() {
    const charset = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(6, (_) => charset[random.nextInt(charset.length)])
        .join();
  }
}

/// Assignment types
enum AssignmentType {
  quiz,
  lesson,
  campaign,
  simulation,
}

extension AssignmentTypeExtension on AssignmentType {
  String get thaiName {
    switch (this) {
      case AssignmentType.quiz:
        return 'แบบทดสอบ';
      case AssignmentType.lesson:
        return 'บทเรียน';
      case AssignmentType.campaign:
        return 'ภารกิจ';
      case AssignmentType.simulation:
        return 'จำลอง';
    }
  }

  String get value {
    switch (this) {
      case AssignmentType.quiz:
        return 'quiz';
      case AssignmentType.lesson:
        return 'lesson';
      case AssignmentType.campaign:
        return 'campaign';
      case AssignmentType.simulation:
        return 'simulation';
    }
  }

  static AssignmentType fromValue(String value) {
    switch (value) {
      case 'quiz':
        return AssignmentType.quiz;
      case 'lesson':
        return AssignmentType.lesson;
      case 'campaign':
        return AssignmentType.campaign;
      case 'simulation':
        return AssignmentType.simulation;
      default:
        return AssignmentType.lesson;
    }
  }
}

/// Assignment for a classroom
class Assignment {
  final String id;
  final String classroomId;
  final String title;
  final String titleTh;
  final String? description;
  final AssignmentType type;
  final String contentId; // ID of quiz/lesson/campaign/simulation
  final DateTime? dueDate;
  final bool isRequired;
  final int? maxAttempts;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Assignment({
    required this.id,
    required this.classroomId,
    required this.title,
    required this.titleTh,
    this.description,
    required this.type,
    required this.contentId,
    this.dueDate,
    this.isRequired = true,
    this.maxAttempts,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isOverdue =>
      dueDate != null && DateTime.now().isAfter(dueDate!);

  factory Assignment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Assignment(
      id: doc.id,
      classroomId: data['classroomId'] ?? '',
      title: data['title'] ?? '',
      titleTh: data['titleTh'] ?? data['title'] ?? '',
      description: data['description'],
      type: AssignmentTypeExtension.fromValue(data['type'] ?? 'lesson'),
      contentId: data['contentId'] ?? '',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      isRequired: data['isRequired'] ?? true,
      maxAttempts: data['maxAttempts'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'classroomId': classroomId,
      'title': title,
      'titleTh': titleTh,
      'description': description,
      'type': type.value,
      'contentId': contentId,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'isRequired': isRequired,
      'maxAttempts': maxAttempts,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  Assignment copyWith({
    String? id,
    String? classroomId,
    String? title,
    String? titleTh,
    String? description,
    AssignmentType? type,
    String? contentId,
    DateTime? dueDate,
    bool? isRequired,
    int? maxAttempts,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Assignment(
      id: id ?? this.id,
      classroomId: classroomId ?? this.classroomId,
      title: title ?? this.title,
      titleTh: titleTh ?? this.titleTh,
      description: description ?? this.description,
      type: type ?? this.type,
      contentId: contentId ?? this.contentId,
      dueDate: dueDate ?? this.dueDate,
      isRequired: isRequired ?? this.isRequired,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Assignment submission by a student
class AssignmentSubmission {
  final String id;
  final String assignmentId;
  final String studentUid;
  final String studentName;
  final bool isCompleted;
  final int? score;
  final int? maxScore;
  final int attemptCount;
  final DateTime? submittedAt;
  final DateTime? lastAttemptAt;

  const AssignmentSubmission({
    required this.id,
    required this.assignmentId,
    required this.studentUid,
    required this.studentName,
    this.isCompleted = false,
    this.score,
    this.maxScore,
    this.attemptCount = 0,
    this.submittedAt,
    this.lastAttemptAt,
  });

  double? get percentage =>
      score != null && maxScore != null && maxScore! > 0
          ? (score! / maxScore! * 100)
          : null;

  factory AssignmentSubmission.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AssignmentSubmission(
      id: doc.id,
      assignmentId: data['assignmentId'] ?? '',
      studentUid: data['studentUid'] ?? '',
      studentName: data['studentName'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      score: data['score'],
      maxScore: data['maxScore'],
      attemptCount: data['attemptCount'] ?? 0,
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate(),
      lastAttemptAt: (data['lastAttemptAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'assignmentId': assignmentId,
      'studentUid': studentUid,
      'studentName': studentName,
      'isCompleted': isCompleted,
      'score': score,
      'maxScore': maxScore,
      'attemptCount': attemptCount,
      'submittedAt': submittedAt != null ? Timestamp.fromDate(submittedAt!) : null,
      'lastAttemptAt':
          lastAttemptAt != null ? Timestamp.fromDate(lastAttemptAt!) : null,
    };
  }
}

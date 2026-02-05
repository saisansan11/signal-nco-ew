// Classroom Service
// Service for managing classrooms and assignments

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/classroom_model.dart';

class ClassroomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _classroomsRef => _firestore.collection('classrooms');
  CollectionReference get _assignmentsRef => _firestore.collection('assignments');
  CollectionReference get _submissionsRef =>
      _firestore.collection('assignment_submissions');

  // ============== Classroom CRUD ==============

  /// Create a new classroom
  Future<String> createClassroom(Classroom classroom) async {
    // Generate unique code
    String code = Classroom.generateCode();

    // Check if code already exists
    while (await _isCodeTaken(code)) {
      code = Classroom.generateCode();
    }

    final classroomWithCode = classroom.copyWith(code: code);
    final docRef = await _classroomsRef.add(classroomWithCode.toFirestore());
    return docRef.id;
  }

  /// Check if classroom code is already taken
  Future<bool> _isCodeTaken(String code) async {
    final query =
        await _classroomsRef.where('code', isEqualTo: code).limit(1).get();
    return query.docs.isNotEmpty;
  }

  /// Update a classroom
  Future<void> updateClassroom(Classroom classroom) async {
    await _classroomsRef.doc(classroom.id).update({
      ...classroom.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a classroom
  Future<void> deleteClassroom(String classroomId) async {
    // Delete all assignments
    final assignments = await _assignmentsRef
        .where('classroomId', isEqualTo: classroomId)
        .get();
    for (final doc in assignments.docs) {
      await deleteAssignment(doc.id);
    }

    // Delete the classroom
    await _classroomsRef.doc(classroomId).delete();
  }

  /// Get a classroom by ID
  Future<Classroom?> getClassroom(String classroomId) async {
    final doc = await _classroomsRef.doc(classroomId).get();
    if (!doc.exists) return null;
    return Classroom.fromFirestore(doc);
  }

  /// Get a classroom by join code
  Future<Classroom?> getClassroomByCode(String code) async {
    final query =
        await _classroomsRef.where('code', isEqualTo: code).limit(1).get();
    if (query.docs.isEmpty) return null;
    return Classroom.fromFirestore(query.docs.first);
  }

  /// Get all classrooms for a teacher
  Stream<List<Classroom>> getTeacherClassrooms(String teacherId) {
    return _classroomsRef
        .where('teacherId', isEqualTo: teacherId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Classroom.fromFirestore(doc)).toList());
  }

  /// Get all classrooms a student is enrolled in
  Stream<List<Classroom>> getStudentClassrooms(String studentUid) {
    return _classroomsRef
        .where('studentUids', arrayContains: studentUid)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Classroom.fromFirestore(doc)).toList());
  }

  // ============== Student Management ==============

  /// Join a classroom using code
  Future<bool> joinClassroom(String code, String studentUid) async {
    final classroom = await getClassroomByCode(code);
    if (classroom == null || !classroom.isActive) return false;

    if (classroom.studentUids.contains(studentUid)) return true; // Already joined

    await _classroomsRef.doc(classroom.id).update({
      'studentUids': FieldValue.arrayUnion([studentUid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return true;
  }

  /// Leave a classroom
  Future<void> leaveClassroom(String classroomId, String studentUid) async {
    await _classroomsRef.doc(classroomId).update({
      'studentUids': FieldValue.arrayRemove([studentUid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remove a student from classroom (by teacher)
  Future<void> removeStudent(String classroomId, String studentUid) async {
    await leaveClassroom(classroomId, studentUid);
  }

  /// Get all students in a classroom
  Future<List<Map<String, dynamic>>> getClassroomStudents(
      String classroomId) async {
    final classroom = await getClassroom(classroomId);
    if (classroom == null) return [];

    final students = <Map<String, dynamic>>[];
    for (final uid in classroom.studentUids) {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        students.add({
          'uid': uid,
          ...userDoc.data() as Map<String, dynamic>,
        });
      }
    }
    return students;
  }

  // ============== Assignment CRUD ==============

  /// Create an assignment
  Future<String> createAssignment(Assignment assignment) async {
    final docRef = await _assignmentsRef.add(assignment.toFirestore());
    return docRef.id;
  }

  /// Update an assignment
  Future<void> updateAssignment(Assignment assignment) async {
    await _assignmentsRef.doc(assignment.id).update({
      ...assignment.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete an assignment
  Future<void> deleteAssignment(String assignmentId) async {
    // Delete all submissions
    final submissions = await _submissionsRef
        .where('assignmentId', isEqualTo: assignmentId)
        .get();
    for (final doc in submissions.docs) {
      await doc.reference.delete();
    }

    // Delete the assignment
    await _assignmentsRef.doc(assignmentId).delete();
  }

  /// Get all assignments for a classroom
  Stream<List<Assignment>> getClassroomAssignments(String classroomId) {
    return _assignmentsRef
        .where('classroomId', isEqualTo: classroomId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Assignment.fromFirestore(doc)).toList());
  }

  /// Get pending assignments for a student in a classroom
  Future<List<Assignment>> getPendingAssignments(
      String classroomId, String studentUid) async {
    final assignments = await _assignmentsRef
        .where('classroomId', isEqualTo: classroomId)
        .get();

    final pending = <Assignment>[];
    for (final doc in assignments.docs) {
      final assignment = Assignment.fromFirestore(doc);

      // Check if student has completed this assignment
      final submission = await _submissionsRef
          .where('assignmentId', isEqualTo: assignment.id)
          .where('studentUid', isEqualTo: studentUid)
          .where('isCompleted', isEqualTo: true)
          .limit(1)
          .get();

      if (submission.docs.isEmpty) {
        pending.add(assignment);
      }
    }

    return pending;
  }

  // ============== Submission CRUD ==============

  /// Create or update a submission
  Future<void> submitAssignment(AssignmentSubmission submission) async {
    // Check if submission already exists
    final existing = await _submissionsRef
        .where('assignmentId', isEqualTo: submission.assignmentId)
        .where('studentUid', isEqualTo: submission.studentUid)
        .limit(1)
        .get();

    if (existing.docs.isEmpty) {
      await _submissionsRef.add(submission.toFirestore());
    } else {
      await existing.docs.first.reference.update({
        ...submission.toFirestore(),
        'attemptCount': FieldValue.increment(1),
        'lastAttemptAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Get submission for an assignment
  Future<AssignmentSubmission?> getSubmission(
      String assignmentId, String studentUid) async {
    final query = await _submissionsRef
        .where('assignmentId', isEqualTo: assignmentId)
        .where('studentUid', isEqualTo: studentUid)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return AssignmentSubmission.fromFirestore(query.docs.first);
  }

  /// Get all submissions for an assignment (for teachers)
  Stream<List<AssignmentSubmission>> getAssignmentSubmissions(
      String assignmentId) {
    return _submissionsRef
        .where('assignmentId', isEqualTo: assignmentId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AssignmentSubmission.fromFirestore(doc))
            .toList());
  }

  /// Get student's submissions for a classroom
  Future<List<AssignmentSubmission>> getStudentSubmissions(
      String classroomId, String studentUid) async {
    // Get all assignments for the classroom
    final assignments = await _assignmentsRef
        .where('classroomId', isEqualTo: classroomId)
        .get();

    final assignmentIds = assignments.docs.map((doc) => doc.id).toList();
    if (assignmentIds.isEmpty) return [];

    // Get submissions for these assignments
    final submissions = await _submissionsRef
        .where('assignmentId', whereIn: assignmentIds)
        .where('studentUid', isEqualTo: studentUid)
        .get();

    return submissions.docs
        .map((doc) => AssignmentSubmission.fromFirestore(doc))
        .toList();
  }

  // ============== Statistics ==============

  /// Get classroom statistics
  Future<ClassroomStats> getClassroomStats(String classroomId) async {
    final classroom = await getClassroom(classroomId);
    if (classroom == null) {
      return const ClassroomStats(
        totalStudents: 0,
        totalAssignments: 0,
        completedAssignments: 0,
        averageScore: 0,
      );
    }

    final assignments = await _assignmentsRef
        .where('classroomId', isEqualTo: classroomId)
        .get();

    int totalCompleted = 0;
    int totalScore = 0;
    int scoreCount = 0;

    for (final assignmentDoc in assignments.docs) {
      final submissions = await _submissionsRef
          .where('assignmentId', isEqualTo: assignmentDoc.id)
          .where('isCompleted', isEqualTo: true)
          .get();

      totalCompleted += submissions.docs.length;

      for (final subDoc in submissions.docs) {
        final data = subDoc.data() as Map<String, dynamic>;
        final score = data['score'] as int?;
        final maxScore = data['maxScore'] as int?;
        if (score != null && maxScore != null && maxScore > 0) {
          totalScore += ((score / maxScore) * 100).round();
          scoreCount++;
        }
      }
    }

    return ClassroomStats(
      totalStudents: classroom.studentCount,
      totalAssignments: assignments.docs.length,
      completedAssignments: totalCompleted,
      averageScore: scoreCount > 0 ? totalScore ~/ scoreCount : 0,
    );
  }
}

/// Classroom statistics
class ClassroomStats {
  final int totalStudents;
  final int totalAssignments;
  final int completedAssignments;
  final int averageScore;

  const ClassroomStats({
    required this.totalStudents,
    required this.totalAssignments,
    required this.completedAssignments,
    required this.averageScore,
  });
}

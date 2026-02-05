// Content Service
// Service for managing custom quizzes created by teachers

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/custom_quiz_model.dart';

class ContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _quizzesRef => _firestore.collection('custom_quizzes');
  CollectionReference get _submissionsRef =>
      _firestore.collection('quiz_submissions');

  // ============== Quiz CRUD ==============

  /// Create a new custom quiz
  Future<String> createQuiz(CustomQuiz quiz) async {
    final docRef = await _quizzesRef.add(quiz.toFirestore());
    return docRef.id;
  }

  /// Update an existing quiz
  Future<void> updateQuiz(CustomQuiz quiz) async {
    await _quizzesRef.doc(quiz.id).update({
      ...quiz.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a quiz
  Future<void> deleteQuiz(String quizId) async {
    await _quizzesRef.doc(quizId).delete();
    // Also delete all submissions for this quiz
    final submissions =
        await _submissionsRef.where('quizId', isEqualTo: quizId).get();
    for (final doc in submissions.docs) {
      await doc.reference.delete();
    }
  }

  /// Get a single quiz by ID
  Future<CustomQuiz?> getQuiz(String quizId) async {
    final doc = await _quizzesRef.doc(quizId).get();
    if (!doc.exists) return null;
    return CustomQuiz.fromFirestore(doc);
  }

  /// Get all quizzes created by a teacher
  Stream<List<CustomQuiz>> getQuizzesByTeacher(String teacherUid) {
    return _quizzesRef
        .where('createdBy', isEqualTo: teacherUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CustomQuiz.fromFirestore(doc)).toList());
  }

  /// Get all published quizzes
  Stream<List<CustomQuiz>> getPublishedQuizzes() {
    return _quizzesRef
        .where('isPublished', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CustomQuiz.fromFirestore(doc)).toList());
  }

  /// Get quizzes for a specific classroom
  Stream<List<CustomQuiz>> getQuizzesForClassroom(String classroomId) {
    return _quizzesRef
        .where('assignedClassroomId', isEqualTo: classroomId)
        .where('isPublished', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CustomQuiz.fromFirestore(doc)).toList());
  }

  /// Publish or unpublish a quiz
  Future<void> setPublished(String quizId, bool isPublished) async {
    await _quizzesRef.doc(quizId).update({
      'isPublished': isPublished,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Assign quiz to a classroom
  Future<void> assignToClassroom(String quizId, String? classroomId) async {
    await _quizzesRef.doc(quizId).update({
      'assignedClassroomId': classroomId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============== Submissions ==============

  /// Submit quiz answers
  Future<String> submitQuiz(QuizSubmission submission) async {
    final docRef = await _submissionsRef.add(submission.toFirestore());
    return docRef.id;
  }

  /// Get all submissions for a quiz
  Stream<List<QuizSubmission>> getSubmissionsForQuiz(String quizId) {
    return _submissionsRef
        .where('quizId', isEqualTo: quizId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QuizSubmission.fromFirestore(doc))
            .toList());
  }

  /// Get all submissions by a student
  Stream<List<QuizSubmission>> getSubmissionsByStudent(String studentUid) {
    return _submissionsRef
        .where('studentUid', isEqualTo: studentUid)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QuizSubmission.fromFirestore(doc))
            .toList());
  }

  /// Check if student has already submitted a quiz
  Future<bool> hasSubmitted(String quizId, String studentUid) async {
    final query = await _submissionsRef
        .where('quizId', isEqualTo: quizId)
        .where('studentUid', isEqualTo: studentUid)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  /// Get student's best submission for a quiz
  Future<QuizSubmission?> getBestSubmission(
      String quizId, String studentUid) async {
    final query = await _submissionsRef
        .where('quizId', isEqualTo: quizId)
        .where('studentUid', isEqualTo: studentUid)
        .orderBy('score', descending: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return QuizSubmission.fromFirestore(query.docs.first);
  }

  // ============== Statistics ==============

  /// Get quiz statistics
  Future<QuizStats> getQuizStats(String quizId) async {
    final submissions = await _submissionsRef
        .where('quizId', isEqualTo: quizId)
        .get();

    if (submissions.docs.isEmpty) {
      return const QuizStats(
        totalSubmissions: 0,
        passedCount: 0,
        failedCount: 0,
        averageScore: 0,
        highestScore: 0,
        lowestScore: 0,
      );
    }

    int totalScore = 0;
    int passedCount = 0;
    int highestScore = 0;
    int lowestScore = 999999;

    for (final doc in submissions.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final score = data['score'] as int? ?? 0;
      final passed = data['passed'] as bool? ?? false;

      totalScore += score;
      if (passed) passedCount++;
      if (score > highestScore) highestScore = score;
      if (score < lowestScore) lowestScore = score;
    }

    return QuizStats(
      totalSubmissions: submissions.docs.length,
      passedCount: passedCount,
      failedCount: submissions.docs.length - passedCount,
      averageScore: totalScore ~/ submissions.docs.length,
      highestScore: highestScore,
      lowestScore: lowestScore,
    );
  }
}

/// Quiz statistics
class QuizStats {
  final int totalSubmissions;
  final int passedCount;
  final int failedCount;
  final int averageScore;
  final int highestScore;
  final int lowestScore;

  const QuizStats({
    required this.totalSubmissions,
    required this.passedCount,
    required this.failedCount,
    required this.averageScore,
    required this.highestScore,
    required this.lowestScore,
  });

  double get passRate =>
      totalSubmissions > 0 ? (passedCount / totalSubmissions * 100) : 0;
}

// Custom Quiz Model
// Model for quizzes created by teachers

import 'package:cloud_firestore/cloud_firestore.dart';

/// Custom quiz created by a teacher
class CustomQuiz {
  final String id;
  final String title;
  final String titleTh;
  final String? description;
  final String createdBy; // Teacher UID
  final String createdByName;
  final List<CustomQuestion> questions;
  final bool isPublished;
  final int timeLimitMinutes;
  final int passingScore; // Percentage (0-100)
  final String? assignedClassroomId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CustomQuiz({
    required this.id,
    required this.title,
    required this.titleTh,
    this.description,
    required this.createdBy,
    required this.createdByName,
    required this.questions,
    this.isPublished = false,
    this.timeLimitMinutes = 30,
    this.passingScore = 60,
    this.assignedClassroomId,
    required this.createdAt,
    this.updatedAt,
  });

  int get totalQuestions => questions.length;
  int get totalPoints => questions.fold(0, (total, q) => total + q.points);

  factory CustomQuiz.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomQuiz(
      id: doc.id,
      title: data['title'] ?? '',
      titleTh: data['titleTh'] ?? data['title'] ?? '',
      description: data['description'],
      createdBy: data['createdBy'] ?? '',
      createdByName: data['createdByName'] ?? '',
      questions: (data['questions'] as List<dynamic>?)
              ?.map((q) => CustomQuestion.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
      isPublished: data['isPublished'] ?? false,
      timeLimitMinutes: data['timeLimitMinutes'] ?? 30,
      passingScore: data['passingScore'] ?? 60,
      assignedClassroomId: data['assignedClassroomId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'titleTh': titleTh,
      'description': description,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'questions': questions.map((q) => q.toMap()).toList(),
      'isPublished': isPublished,
      'timeLimitMinutes': timeLimitMinutes,
      'passingScore': passingScore,
      'assignedClassroomId': assignedClassroomId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  CustomQuiz copyWith({
    String? id,
    String? title,
    String? titleTh,
    String? description,
    String? createdBy,
    String? createdByName,
    List<CustomQuestion>? questions,
    bool? isPublished,
    int? timeLimitMinutes,
    int? passingScore,
    String? assignedClassroomId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomQuiz(
      id: id ?? this.id,
      title: title ?? this.title,
      titleTh: titleTh ?? this.titleTh,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      questions: questions ?? this.questions,
      isPublished: isPublished ?? this.isPublished,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      passingScore: passingScore ?? this.passingScore,
      assignedClassroomId: assignedClassroomId ?? this.assignedClassroomId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Question types
enum QuestionType {
  multipleChoice,
  trueFalse,
  fillBlank,
}

extension QuestionTypeExtension on QuestionType {
  String get thaiName {
    switch (this) {
      case QuestionType.multipleChoice:
        return 'ตัวเลือก';
      case QuestionType.trueFalse:
        return 'ถูก/ผิด';
      case QuestionType.fillBlank:
        return 'เติมคำ';
    }
  }

  String get value {
    switch (this) {
      case QuestionType.multipleChoice:
        return 'multiple_choice';
      case QuestionType.trueFalse:
        return 'true_false';
      case QuestionType.fillBlank:
        return 'fill_blank';
    }
  }

  static QuestionType fromValue(String value) {
    switch (value) {
      case 'multiple_choice':
        return QuestionType.multipleChoice;
      case 'true_false':
        return QuestionType.trueFalse;
      case 'fill_blank':
        return QuestionType.fillBlank;
      default:
        return QuestionType.multipleChoice;
    }
  }
}

/// Custom question in a quiz
class CustomQuestion {
  final String id;
  final String question;
  final String? questionTh;
  final QuestionType type;
  final List<String> options; // For multiple choice
  final int correctAnswerIndex; // For multiple choice & true/false
  final String? correctAnswerText; // For fill blank
  final String? explanation;
  final String? explanationTh;
  final int points;
  final String? imageUrl;

  const CustomQuestion({
    required this.id,
    required this.question,
    this.questionTh,
    required this.type,
    this.options = const [],
    this.correctAnswerIndex = 0,
    this.correctAnswerText,
    this.explanation,
    this.explanationTh,
    this.points = 1,
    this.imageUrl,
  });

  factory CustomQuestion.fromMap(Map<String, dynamic> map) {
    return CustomQuestion(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      questionTh: map['questionTh'],
      type: QuestionTypeExtension.fromValue(map['type'] ?? 'multiple_choice'),
      options: (map['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctAnswerIndex: map['correctAnswerIndex'] ?? 0,
      correctAnswerText: map['correctAnswerText'],
      explanation: map['explanation'],
      explanationTh: map['explanationTh'],
      points: map['points'] ?? 1,
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'questionTh': questionTh,
      'type': type.value,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'correctAnswerText': correctAnswerText,
      'explanation': explanation,
      'explanationTh': explanationTh,
      'points': points,
      'imageUrl': imageUrl,
    };
  }

  CustomQuestion copyWith({
    String? id,
    String? question,
    String? questionTh,
    QuestionType? type,
    List<String>? options,
    int? correctAnswerIndex,
    String? correctAnswerText,
    String? explanation,
    String? explanationTh,
    int? points,
    String? imageUrl,
  }) {
    return CustomQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      questionTh: questionTh ?? this.questionTh,
      type: type ?? this.type,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      correctAnswerText: correctAnswerText ?? this.correctAnswerText,
      explanation: explanation ?? this.explanation,
      explanationTh: explanationTh ?? this.explanationTh,
      points: points ?? this.points,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

/// Quiz submission by a student
class QuizSubmission {
  final String id;
  final String quizId;
  final String studentUid;
  final String studentName;
  final List<QuestionAnswer> answers;
  final int score;
  final int totalPoints;
  final bool passed;
  final Duration timeTaken;
  final DateTime submittedAt;

  const QuizSubmission({
    required this.id,
    required this.quizId,
    required this.studentUid,
    required this.studentName,
    required this.answers,
    required this.score,
    required this.totalPoints,
    required this.passed,
    required this.timeTaken,
    required this.submittedAt,
  });

  double get percentage => totalPoints > 0 ? (score / totalPoints * 100) : 0;

  factory QuizSubmission.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizSubmission(
      id: doc.id,
      quizId: data['quizId'] ?? '',
      studentUid: data['studentUid'] ?? '',
      studentName: data['studentName'] ?? '',
      answers: (data['answers'] as List<dynamic>?)
              ?.map((a) => QuestionAnswer.fromMap(a as Map<String, dynamic>))
              .toList() ??
          [],
      score: data['score'] ?? 0,
      totalPoints: data['totalPoints'] ?? 0,
      passed: data['passed'] ?? false,
      timeTaken: Duration(seconds: data['timeTakenSeconds'] ?? 0),
      submittedAt:
          (data['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'quizId': quizId,
      'studentUid': studentUid,
      'studentName': studentName,
      'answers': answers.map((a) => a.toMap()).toList(),
      'score': score,
      'totalPoints': totalPoints,
      'passed': passed,
      'timeTakenSeconds': timeTaken.inSeconds,
      'submittedAt': Timestamp.fromDate(submittedAt),
    };
  }
}

/// Answer to a single question
class QuestionAnswer {
  final String questionId;
  final int? selectedIndex;
  final String? textAnswer;
  final bool isCorrect;

  const QuestionAnswer({
    required this.questionId,
    this.selectedIndex,
    this.textAnswer,
    required this.isCorrect,
  });

  factory QuestionAnswer.fromMap(Map<String, dynamic> map) {
    return QuestionAnswer(
      questionId: map['questionId'] ?? '',
      selectedIndex: map['selectedIndex'],
      textAnswer: map['textAnswer'],
      isCorrect: map['isCorrect'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'selectedIndex': selectedIndex,
      'textAnswer': textAnswer,
      'isCorrect': isCorrect,
    };
  }
}

import 'curriculum_models.dart';

/// Quiz question with Thai content
class QuizQuestion {
  final String id;
  final String questionTh;
  final List<String> optionsTh;
  final int correctIndex;
  final String? explanationTh;
  final String? imagePath;
  final EWCategory category;
  final DifficultyLevel difficulty;

  const QuizQuestion({
    required this.id,
    required this.questionTh,
    required this.optionsTh,
    required this.correctIndex,
    this.explanationTh,
    this.imagePath,
    required this.category,
    required this.difficulty,
  });

  String get correctAnswer => optionsTh[correctIndex];

  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;
}

/// Quiz state for adaptive difficulty
class AdaptiveQuizState {
  int consecutiveCorrect;
  int consecutiveWrong;
  DifficultyLevel currentDifficulty;
  List<bool> recentResults;
  int totalQuestions;
  int correctAnswers;

  AdaptiveQuizState({
    this.consecutiveCorrect = 0,
    this.consecutiveWrong = 0,
    this.currentDifficulty = DifficultyLevel.beginner,
    List<bool>? recentResults,
    this.totalQuestions = 0,
    this.correctAnswers = 0,
  }) : recentResults = recentResults ?? [];

  void recordAnswer(bool correct) {
    recentResults.add(correct);
    totalQuestions++;

    if (correct) {
      correctAnswers++;
      consecutiveCorrect++;
      consecutiveWrong = 0;
    } else {
      consecutiveWrong++;
      consecutiveCorrect = 0;
    }

    // Adjust difficulty
    if (consecutiveCorrect >= 3 &&
        currentDifficulty != DifficultyLevel.advanced) {
      if (currentDifficulty == DifficultyLevel.beginner) {
        currentDifficulty = DifficultyLevel.intermediate;
      } else {
        currentDifficulty = DifficultyLevel.advanced;
      }
      consecutiveCorrect = 0;
    } else if (consecutiveWrong >= 2 &&
        currentDifficulty != DifficultyLevel.beginner) {
      if (currentDifficulty == DifficultyLevel.advanced) {
        currentDifficulty = DifficultyLevel.intermediate;
      } else {
        currentDifficulty = DifficultyLevel.beginner;
      }
      consecutiveWrong = 0;
    }
  }

  double get accuracy {
    if (totalQuestions == 0) return 0;
    return correctAnswers / totalQuestions;
  }

  int get scorePercent => (accuracy * 100).round();

  bool get isPassing => accuracy >= 0.7;
}

/// Quiz result
class QuizResult {
  final String quizId;
  final int totalQuestions;
  final int correctAnswers;
  final int timeSpentSeconds;
  final DateTime completedAt;
  final List<QuestionResult> questionResults;

  const QuizResult({
    required this.quizId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeSpentSeconds,
    required this.completedAt,
    required this.questionResults,
  });

  double get accuracy => correctAnswers / totalQuestions;
  int get scorePercent => (accuracy * 100).round();
  bool get isPassing => accuracy >= 0.7;

  Map<String, dynamic> toJson() => {
        'quizId': quizId,
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'timeSpentSeconds': timeSpentSeconds,
        'completedAt': completedAt.toIso8601String(),
        'accuracy': accuracy,
      };
}

/// Individual question result
class QuestionResult {
  final String questionId;
  final int selectedIndex;
  final bool isCorrect;
  final int timeSpentSeconds;

  const QuestionResult({
    required this.questionId,
    required this.selectedIndex,
    required this.isCorrect,
    required this.timeSpentSeconds,
  });
}

/// Quiz configuration
class QuizConfig {
  final int totalQuestions;
  final int timeLimitSeconds; // 0 = no limit
  final bool shuffleQuestions;
  final bool shuffleOptions;
  final bool showExplanation;
  final bool adaptiveDifficulty;

  const QuizConfig({
    this.totalQuestions = 10,
    this.timeLimitSeconds = 0,
    this.shuffleQuestions = true,
    this.shuffleOptions = true,
    this.showExplanation = true,
    this.adaptiveDifficulty = true,
  });
}

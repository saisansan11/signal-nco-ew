import ‘curriculum_models.dart’;
/// User progress tracking
class UserProgress {
final NCOLevel currentLevel;
final Map<String, ModuleProgress> moduleProgress;
final int totalXP;
final int currentStreak;
final DateTime? lastStudyDate;
final Set<String> unlockedAchievements;
final DailyGoals dailyGoals;
final Map<String, SpacedRepetitionCard> flashcardProgress;
UserProgress({
this.currentLevel = NCOLevel.junior,
Map<String, ModuleProgress>? moduleProgress,
this.totalXP = 0,
this.currentStreak = 0,
this.lastStudyDate,
Set<String>? unlockedAchievements,
DailyGoals? dailyGoals,
Map<String, SpacedRepetitionCard>? flashcardProgress,
})  : moduleProgress = moduleProgress ?? {},
unlockedAchievements = unlockedAchievements ?? {},
dailyGoals = dailyGoals ?? DailyGoals(),
flashcardProgress = flashcardProgress ?? {};
int get level => (totalXP / 100).floor() + 1;
double get overallProgress {
if (moduleProgress.isEmpty) return 0;
final completed =
moduleProgress.values.where((m) => m.isCompleted).length;
return completed / moduleProgress.length;
}
bool get isJuniorComplete {
// Check if all junior modules are completed
return moduleProgress.entries
.where((e) => e.key.startsWith(‘junior_’))
.every((e) => e.value.isCompleted);
}
bool get canAccessSenior => isJuniorComplete || currentLevel == NCOLevel.senior;
}
/// Progress for individual module
class ModuleProgress {
final String moduleId;
final Set<String> completedLessons;
final Map<String, int> quizScores; // quiz_id -> score percentage
final Map<String, int> scenarioScores;
final DateTime? startedAt;
final DateTime? completedAt;
ModuleProgress({
required this.moduleId,
Set<String>? completedLessons,
Map<String, int>? quizScores,
Map<String, int>? scenarioScores,
this.startedAt,
this.completedAt,
})  : completedLessons = completedLessons ?? {},
quizScores = quizScores ?? {},
scenarioScores = scenarioScores ?? {};
bool get isCompleted => completedAt != null;
double get completionPercentage {
// Simplified: based on completed lessons
// In real app, calculate based on total lessons in module
if (completedLessons.isEmpty) return 0;
return completedLessons.length / 5; // Assuming 5 lessons per module
}
bool get isPassed {
if (quizScores.isEmpty) return false;
return quizScores.values.every((score) => score >= 70);
}
Map<String, dynamic> toJson() => {
‘moduleId’: moduleId,
‘completedLessons’: completedLessons.toList(),
‘quizScores’: quizScores,
‘scenarioScores’: scenarioScores,
‘startedAt’: startedAt?.toIso8601String(),
‘completedAt’: completedAt?.toIso8601String(),
};
factory ModuleProgress.fromJson(Map<String, dynamic> json) => ModuleProgress(
moduleId: json[‘moduleId’] as String,
completedLessons: Set<String>.from(json[‘completedLessons’] ?? []),
quizScores: Map<String, int>.from(json[‘quizScores’] ?? {}),
scenarioScores: Map<String, int>.from(json[‘scenarioScores’] ?? {}),
startedAt: json[‘startedAt’] != null
? DateTime.parse(json[‘startedAt’])
: null,
completedAt: json[‘completedAt’] != null
? DateTime.parse(json[‘completedAt’])
: null,
);
}
/// Spaced Repetition (SM-2 algorithm)
class SpacedRepetitionCard {
final String cardId;
int repetitions;
double easeFactor;
int interval; // days
DateTime? nextReviewDate;
DateTime? lastReviewDate;
SpacedRepetitionCard({
required this.cardId,
this.repetitions = 0,
this.easeFactor = 2.5,
this.interval = 1,
this.nextReviewDate,
this.lastReviewDate,
});
/// Update card based on quality of recall (0-5)
/// 0 - Complete blackout
/// 1 - Incorrect; remembered on seeing answer
/// 2 - Incorrect; answer seemed easy to recall
/// 3 - Correct; with serious difficulty
/// 4 - Correct; with hesitation
/// 5 - Perfect response
void updateWithQuality(int quality) {
lastReviewDate = DateTime.now();

if (quality < 3) {
  // Failed recall, reset
  repetitions = 0;
  interval = 1;
} else {
  // Successful recall
  if (repetitions == 0) {
    interval = 1;
  } else if (repetitions == 1) {
    interval = 6;
  } else {
    interval = (interval * easeFactor).round();
  }
  repetitions++;
}

// Update ease factor
easeFactor = easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
if (easeFactor < 1.3) easeFactor = 1.3;

nextReviewDate = DateTime.now().add(Duration(days: interval));


}
bool get isDue {
if (nextReviewDate == null) return true;
return DateTime.now().isAfter(nextReviewDate!);
}
Map<String, dynamic> toJson() => {
‘cardId’: cardId,
‘repetitions’: repetitions,
‘easeFactor’: easeFactor,
‘interval’: interval,
‘nextReviewDate’: nextReviewDate?.toIso8601String(),
‘lastReviewDate’: lastReviewDate?.toIso8601String(),
};
factory SpacedRepetitionCard.fromJson(Map<String, dynamic> json) =>
SpacedRepetitionCard(
cardId: json[‘cardId’] as String,
repetitions: json[‘repetitions’] as int? ?? 0,
easeFactor: (json[‘easeFactor’] as num?)?.toDouble() ?? 2.5,
interval: json[‘interval’] as int? ?? 1,
nextReviewDate: json[‘nextReviewDate’] != null
? DateTime.parse(json[‘nextReviewDate’])
: null,
lastReviewDate: json[‘lastReviewDate’] != null
? DateTime.parse(json[‘lastReviewDate’])
: null,
);
}
/// Daily goals tracking
class DailyGoals {
int lessonsTarget;
int lessonsCompleted;
int flashcardsTarget;
int flashcardsStudied;
int quizzesTarget;
int quizzesTaken;
int minutesTarget;
int minutesStudied;
DateTime? lastReset;
DailyGoals({
this.lessonsTarget = 2,
this.lessonsCompleted = 0,
this.flashcardsTarget = 20,
this.flashcardsStudied = 0,
this.quizzesTarget = 1,
this.quizzesTaken = 0,
this.minutesTarget = 30,
this.minutesStudied = 0,
this.lastReset,
});
double get progress {
final lessonProgress = lessonsCompleted / lessonsTarget;
final flashcardProgress = flashcardsStudied / flashcardsTarget;
final quizProgress = quizzesTaken / quizzesTarget;
final minuteProgress = minutesStudied / minutesTarget;
return (lessonProgress + flashcardProgress + quizProgress + minuteProgress) / 4;
}
bool get isCompleted => progress >= 1.0;
void resetIfNeeded() {
final now = DateTime.now();
final today = DateTime(now.year, now.month, now.day);

if (lastReset == null || lastReset!.isBefore(today)) {
  lessonsCompleted = 0;
  flashcardsStudied = 0;
  quizzesTaken = 0;
  minutesStudied = 0;
  lastReset = today;
}


}
Map<String, dynamic> toJson() => {
‘lessonsTarget’: lessonsTarget,
‘lessonsCompleted’: lessonsCompleted,
‘flashcardsTarget’: flashcardsTarget,
‘flashcardsStudied’: flashcardsStudied,
‘quizzesTarget’: quizzesTarget,
‘quizzesTaken’: quizzesTaken,
‘minutesTarget’: minutesTarget,
‘minutesStudied’: minutesStudied,
‘lastReset’: lastReset?.toIso8601String(),
};
factory DailyGoals.fromJson(Map<String, dynamic> json) => DailyGoals(
lessonsTarget: json[‘lessonsTarget’] as int? ?? 2,
lessonsCompleted: json[‘lessonsCompleted’] as int? ?? 0,
flashcardsTarget: json[‘flashcardsTarget’] as int? ?? 20,
flashcardsStudied: json[‘flashcardsStudied’] as int? ?? 0,
quizzesTarget: json[‘quizzesTarget’] as int? ?? 1,
quizzesTaken: json[‘quizzesTaken’] as int? ?? 0,
minutesTarget: json[‘minutesTarget’] as int? ?? 30,
minutesStudied: json[‘minutesStudied’] as int? ?? 0,
lastReset: json[‘lastReset’] != null
? DateTime.parse(json[‘lastReset’])
: null,
);
}
/// Achievement definition
class Achievement {
final String id;
final String titleTh;
final String descriptionTh;
final String icon;
final AchievementTier tier;
final AchievementType type;
final int requirement;
final int xpReward;
const Achievement({
required this.id,
required this.titleTh,
required this.descriptionTh,
required this.icon,
required this.tier,
required this.type,
required this.requirement,
required this.xpReward,
});
}
enum AchievementTier { bronze, silver, gold, platinum }
extension AchievementTierExtension on AchievementTier {
String get titleTh {
switch (this) {
case AchievementTier.bronze:
return ‘ทองแดง’;
case AchievementTier.silver:
return ‘เงิน’;
case AchievementTier.gold:
return ‘ทอง’;
case AchievementTier.platinum:
return ‘แพลทินัม’;
}
}
}
enum AchievementType {
lessonsCompleted,
flashcardsStudied,
quizzesPassed,
perfectQuiz,
streakDays,
modulesCompleted,
levelCompleted,
scenariosCompleted,
}

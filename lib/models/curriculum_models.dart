import 'package:flutter/material.dart';

/// NCO training level
enum NCOLevel {
  junior, // นายสิบชั้นต้น
  senior, // นายสิบอาวุโส
}

extension NCOLevelExtension on NCOLevel {
  String get titleTh {
    switch (this) {
      case NCOLevel.junior:
        return 'นายสิบชั้นต้น';
      case NCOLevel.senior:
        return 'นายสิบอาวุโส';
    }
  }

  String get descriptionTh {
    switch (this) {
      case NCOLevel.junior:
        return 'หลักสูตรพื้นฐาน EW สำหรับนายสิบใหม่';
      case NCOLevel.senior:
        return 'หลักสูตรขั้นสูง EW สำหรับนายสิบอาวุโส';
    }
  }
}

/// EW discipline category
enum EWCategory {
  overview, // ภาพรวม EW
  spectrum, // สเปกตรัม
  es, // Electronic Support
  ea, // Electronic Attack
  ep, // Electronic Protection
  radio, // วิทยุสื่อสาร
  radar, // ระบบเรดาร์
  antiDrone, // ต่อต้านโดรน
  gpsWarfare, // สงคราม GPS
  caseStudy, // กรณีศึกษา
  tactics, // ยุทธวิธี
  procedures, // ระเบียบปฏิบัติ
}

extension EWCategoryExtension on EWCategory {
  String get titleTh {
    switch (this) {
      case EWCategory.overview:
        return 'ภาพรวม EW';
      case EWCategory.spectrum:
        return 'สเปกตรัมแม่เหล็กไฟฟ้า';
      case EWCategory.es:
        return 'Electronic Support';
      case EWCategory.ea:
        return 'Electronic Attack';
      case EWCategory.ep:
        return 'Electronic Protection';
      case EWCategory.radio:
        return 'วิทยุยุทธวิธี';
      case EWCategory.radar:
        return 'ระบบเรดาร์';
      case EWCategory.antiDrone:
        return 'ต่อต้านโดรน';
      case EWCategory.gpsWarfare:
        return 'สงคราม GPS';
      case EWCategory.caseStudy:
        return 'กรณีศึกษา';
      case EWCategory.tactics:
        return 'การวางแผนยุทธวิธี';
      case EWCategory.procedures:
        return 'ระเบียบปฏิบัติ';
    }
  }

  IconData get icon {
    switch (this) {
      case EWCategory.overview:
        return Icons.radar;
      case EWCategory.spectrum:
        return Icons.graphic_eq;
      case EWCategory.es:
        return Icons.hearing;
      case EWCategory.ea:
        return Icons.flash_on;
      case EWCategory.ep:
        return Icons.shield;
      case EWCategory.radio:
        return Icons.settings_input_antenna;
      case EWCategory.radar:
        return Icons.track_changes;
      case EWCategory.antiDrone:
        return Icons.flight_takeoff;
      case EWCategory.gpsWarfare:
        return Icons.satellite_alt;
      case EWCategory.caseStudy:
        return Icons.menu_book;
      case EWCategory.tactics:
        return Icons.map;
      case EWCategory.procedures:
        return Icons.checklist;
    }
  }

  Color get color {
    switch (this) {
      case EWCategory.overview:
        return const Color(0xFF58A6FF);
      case EWCategory.spectrum:
        return const Color(0xFF9C27B0);
      case EWCategory.es:
        return const Color(0xFFFFC107);
      case EWCategory.ea:
        return const Color(0xFFF44336);
      case EWCategory.ep:
        return const Color(0xFF4CAF50);
      case EWCategory.radio:
        return const Color(0xFFFF9500);
      case EWCategory.radar:
        return const Color(0xFF00BCD4);
      case EWCategory.antiDrone:
        return const Color(0xFFFF5722);
      case EWCategory.gpsWarfare:
        return const Color(0xFF3F51B5);
      case EWCategory.caseStudy:
        return const Color(0xFF795548);
      case EWCategory.tactics:
        return const Color(0xFF607D8B);
      case EWCategory.procedures:
        return const Color(0xFF8BC34A);
    }
  }
}

/// Lesson type
enum LessonType {
  reading, // Theory content
  flashcard, // Flashcard review
  interactive, // Simulation/hands-on
  quiz, // Assessment
  scenario, // Tactical scenario
}

extension LessonTypeExtension on LessonType {
  String get titleTh {
    switch (this) {
      case LessonType.reading:
        return 'อ่านเนื้อหา';
      case LessonType.flashcard:
        return 'บัตรคำ';
      case LessonType.interactive:
        return 'จำลองสถานการณ์';
      case LessonType.quiz:
        return 'แบบทดสอบ';
      case LessonType.scenario:
        return 'ยุทธการจำลอง';
    }
  }

  IconData get icon {
    switch (this) {
      case LessonType.reading:
        return Icons.menu_book;
      case LessonType.flashcard:
        return Icons.style;
      case LessonType.interactive:
        return Icons.touch_app;
      case LessonType.quiz:
        return Icons.quiz;
      case LessonType.scenario:
        return Icons.military_tech;
    }
  }
}

/// Difficulty level
enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
}

extension DifficultyLevelExtension on DifficultyLevel {
  String get titleTh {
    switch (this) {
      case DifficultyLevel.beginner:
        return 'พื้นฐาน';
      case DifficultyLevel.intermediate:
        return 'ปานกลาง';
      case DifficultyLevel.advanced:
        return 'ขั้นสูง';
    }
  }

  Color get color {
    switch (this) {
      case DifficultyLevel.beginner:
        return const Color(0xFF4CAF50);
      case DifficultyLevel.intermediate:
        return const Color(0xFFFF9800);
      case DifficultyLevel.advanced:
        return const Color(0xFFF44336);
    }
  }

  int get stars {
    switch (this) {
      case DifficultyLevel.beginner:
        return 1;
      case DifficultyLevel.intermediate:
        return 2;
      case DifficultyLevel.advanced:
        return 3;
    }
  }
}

/// Learning module
class EWModule {
  final String id;
  final int moduleNumber;
  final String titleTh;
  final String subtitleTh;
  final NCOLevel requiredLevel;
  final EWCategory category;
  final int estimatedMinutes;
  final DifficultyLevel difficulty;
  final List<String> learningObjectives;
  final List<Lesson> lessons;
  final List<String> prerequisites;

  const EWModule({
    required this.id,
    required this.moduleNumber,
    required this.titleTh,
    required this.subtitleTh,
    required this.requiredLevel,
    required this.category,
    required this.estimatedMinutes,
    required this.difficulty,
    required this.learningObjectives,
    required this.lessons,
    this.prerequisites = const [],
  });

  IconData get icon => category.icon;
  Color get color => category.color;

  int get totalLessons => lessons.length;
}

/// Individual lesson within a module
class Lesson {
  final String id;
  final String titleTh;
  final String? descriptionTh;
  final LessonType type;
  final int order;
  final int estimatedMinutes;
  final Widget Function(BuildContext)? contentBuilder;

  const Lesson({
    required this.id,
    required this.titleTh,
    this.descriptionTh,
    required this.type,
    required this.order,
    required this.estimatedMinutes,
    this.contentBuilder,
  });

  IconData get icon => type.icon;
}

/// Interactive simulation scenario
class InteractiveScenario {
  final String id;
  final String titleTh;
  final String descriptionTh;
  final ScenarioType type;
  final DifficultyLevel difficulty;
  final int timeLimit; // seconds, 0 = no limit
  final int passingScore;
  final List<String> objectives;

  const InteractiveScenario({
    required this.id,
    required this.titleTh,
    required this.descriptionTh,
    required this.type,
    required this.difficulty,
    this.timeLimit = 0,
    required this.passingScore,
    required this.objectives,
  });
}

enum ScenarioType {
  spectrumAnalysis,
  signalIdentification,
  jammingExercise,
  directionFinding,
  radarOperation,
  droneDetection,
  tacticalDecision,
}

extension ScenarioTypeExtension on ScenarioType {
  String get titleTh {
    switch (this) {
      case ScenarioType.spectrumAnalysis:
        return 'วิเคราะห์สเปกตรัม';
      case ScenarioType.signalIdentification:
        return 'ระบุสัญญาณ';
      case ScenarioType.jammingExercise:
        return 'ฝึกการรบกวน';
      case ScenarioType.directionFinding:
        return 'หาทิศทาง';
      case ScenarioType.radarOperation:
        return 'ปฏิบัติการเรดาร์';
      case ScenarioType.droneDetection:
        return 'ตรวจจับโดรน';
      case ScenarioType.tacticalDecision:
        return 'ตัดสินใจทางยุทธวิธี';
    }
  }
}

/// Glossary term
class GlossaryTerm {
  final String term;
  final String? fullForm;
  final String definitionTh;
  final EWCategory category;
  final List<String> relatedTerms;

  const GlossaryTerm({
    required this.term,
    this.fullForm,
    required this.definitionTh,
    required this.category,
    this.relatedTerms = const [],
  });
}

/// Flashcard for studying
class Flashcard {
  final String id;
  final String questionTh;
  final String answerTh;
  final String? hintTh;
  final EWCategory category;
  final DifficultyLevel difficulty;

  const Flashcard({
    required this.id,
    required this.questionTh,
    required this.answerTh,
    this.hintTh,
    required this.category,
    required this.difficulty,
  });
}

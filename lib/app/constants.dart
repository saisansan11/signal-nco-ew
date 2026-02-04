import 'package:flutter/material.dart';

/// App Colors - Military EW Theme (Dark Mode)
class AppColors {
  // Base colors - Dark military theme
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceLight = Color(0xFF21262D);
  static const Color card = Color(0xFF1C2128);
  static const Color cardElevated = Color(0xFF252C35);

  // Military colors
  static const Color militaryGreen = Color(0xFF4A5D23);
  static const Color militaryOlive = Color(0xFF6B8E23);
  static const Color militaryTan = Color(0xFFD2B48C);
  static const Color militaryNavy = Color(0xFF1E3A5F);

  // Primary colors - Signal Corps orange
  static const Color primary = Color(0xFFFF9500);
  static const Color primaryLight = Color(0xFFFFAD33);
  static const Color primaryDark = Color(0xFFE68600);

  // EW Category colors
  static const Color esColor = Color(0xFFFFC107); // Amber - Electronic Support
  static const Color eaColor = Color(0xFFF44336); // Red - Electronic Attack
  static const Color epColor = Color(0xFF4CAF50); // Green - Electronic Protection
  static const Color spectrumColor = Color(0xFF9C27B0); // Purple - Spectrum
  static const Color radarColor = Color(0xFF00BCD4); // Cyan - Radar
  static const Color droneColor = Color(0xFFFF5722); // Deep Orange - Anti-Drone
  static const Color gpsColor = Color(0xFF3F51B5); // Indigo - GPS
  static const Color radioColor = Color(0xFF7B68EE); // Medium Slate Blue - Tactical Radio
  static const Color sopColor = Color(0xFF607D8B); // Blue Grey - SOPs & Field Operations

  // NCO Level colors
  static const Color juniorNco = Color(0xFF8E8E93); // Silver
  static const Color juniorNcoLight = Color(0xFFC7C7CC);
  static const Color seniorNco = Color(0xFFFFD60A); // Gold
  static const Color seniorNcoLight = Color(0xFFFFE66D);

  // Accent colors
  static const Color accent = Color(0xFF00FFD1); // Cyan accent
  static const Color accentBlue = Color(0xFF58A6FF);
  static const Color accentGreen = Color(0xFF3FB950);
  static const Color accentPurple = Color(0xFFBC8CFF);

  // Status colors
  static const Color success = Color(0xFF3FB950);
  static const Color successLight = Color(0xFF1F3D2A);
  static const Color warning = Color(0xFFD29922);
  static const Color warningLight = Color(0xFF3D3215);
  static const Color error = Color(0xFFF85149);
  static const Color errorLight = Color(0xFF3D1F1F);
  static const Color info = Color(0xFF58A6FF);
  static const Color infoLight = Color(0xFF1F3D4D);

  // Text colors
  static const Color textPrimary = Color(0xFFC9D1D9);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF6E7681);
  static const Color textDisabled = Color(0xFF484F58);

  // Border colors
  static const Color border = Color(0xFF30363D);
  static const Color borderLight = Color(0xFF21262D);
  static const Color borderFocus = Color(0xFF58A6FF);

  // Gradient presets - Military style
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9500), Color(0xFFE68600)],
  );

  static const LinearGradient esGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFC107), Color(0xFFFFB300)],
  );

  static const LinearGradient eaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF44336), Color(0xFFD32F2F)],
  );

  static const LinearGradient epGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
  );

  static const LinearGradient radarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF00BCD4), Color(0xFF006064)],
  );

  static const LinearGradient spectrumGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF3F51B5),
      Color(0xFF2196F3),
      Color(0xFF4CAF50),
      Color(0xFFFFEB3B),
      Color(0xFFFF9800),
      Color(0xFFF44336),
    ],
  );

  static const LinearGradient juniorNcoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC7C7CC), Color(0xFF8E8E93)],
  );

  static const LinearGradient seniorNcoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFE66D), Color(0xFFFFD60A)],
  );

  // Shadow presets
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.5),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> glowShadow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.4),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];
}

/// App Sizes
class AppSizes {
  // Padding
  static const double paddingXXS = 2.0;
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // Border radius
  static const double radiusXS = 8.0;
  static const double radiusS = 12.0;
  static const double radiusM = 16.0;
  static const double radiusL = 20.0;
  static const double radiusXL = 28.0;
  static const double radiusXXL = 36.0;
  static const double radiusFull = 100.0;

  // Icon sizes
  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  static const double iconXXL = 64.0;

  // Font sizes
  static const double fontXXS = 10.0;
  static const double fontXS = 11.0;
  static const double fontS = 12.0;
  static const double fontM = 14.0;
  static const double fontL = 16.0;
  static const double fontXL = 18.0;
  static const double fontXXL = 20.0;
  static const double fontHeading = 24.0;
  static const double fontDisplay = 32.0;
  static const double fontHero = 40.0;

  // Component sizes
  static const double buttonHeight = 50.0;
  static const double buttonHeightS = 40.0;
  static const double buttonHeightL = 56.0;
  static const double inputHeight = 50.0;
  static const double cardMinHeight = 120.0;
}

/// App Durations
class AppDurations {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration slower = Duration(milliseconds: 600);
  static const Duration cardFlip = Duration(milliseconds: 450);
  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Duration staggerDelay = Duration(milliseconds: 60);
  static const Duration radarSweep = Duration(milliseconds: 3000);
  static const Duration spectrumScan = Duration(milliseconds: 2000);
}

/// App Curves
class AppCurves {
  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve bounceCurve = Curves.easeOutBack;
  static const Curve smoothCurve = Curves.easeInOutCubic;
  static const Curve sharpCurve = Curves.easeOutExpo;
  static const Curve springCurve = Curves.elasticOut;
}

/// App Text Styles
class AppTextStyles {
  // Display styles
  static const TextStyle displayHero = TextStyle(
    fontSize: AppSizes.fontHero,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -1.5,
    height: 1.1,
  );

  static const TextStyle displayLarge = TextStyle(
    fontSize: AppSizes.fontDisplay,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
    height: 1.15,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: AppSizes.fontHeading,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  // Headlines
  static const TextStyle headlineLarge = TextStyle(
    fontSize: AppSizes.fontHeading,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: AppSizes.fontXXL,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.25,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: AppSizes.fontXL,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
    height: 1.3,
  );

  // Titles
  static const TextStyle titleLarge = TextStyle(
    fontSize: AppSizes.fontL,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: AppSizes.fontM,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: AppSizes.fontS,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: AppSizes.fontL,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: AppSizes.fontM,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: AppSizes.fontS,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: AppSizes.fontM,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 0.3,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: AppSizes.fontS,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 0.2,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: AppSizes.fontXS,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 0.1,
    height: 1.4,
  );

  // Button text
  static const TextStyle buttonLarge = TextStyle(
    fontSize: AppSizes.fontL,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.2,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: AppSizes.fontM,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.2,
  );

  // Code/Technical text
  static const TextStyle codeLarge = TextStyle(
    fontSize: AppSizes.fontL,
    fontWeight: FontWeight.w500,
    color: AppColors.accent,
    fontFamily: 'monospace',
    height: 1.5,
  );

  static const TextStyle codeMedium = TextStyle(
    fontSize: AppSizes.fontM,
    fontWeight: FontWeight.w500,
    color: AppColors.accent,
    fontFamily: 'monospace',
    height: 1.5,
  );
}

/// Card Decorations
class CardDecoration {
  static BoxDecoration standard({
    Color? backgroundColor,
    double borderRadius = AppSizes.radiusL,
    bool hasShadow = true,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.card,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: AppColors.border, width: 1),
      boxShadow: hasShadow ? AppColors.softShadow : null,
    );
  }

  static BoxDecoration elevated({
    Color? backgroundColor,
    double borderRadius = AppSizes.radiusL,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.cardElevated,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: AppColors.border, width: 1),
      boxShadow: AppColors.cardShadow,
    );
  }

  static BoxDecoration gradient({
    required Gradient gradient,
    double borderRadius = AppSizes.radiusL,
  }) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: AppColors.cardShadow,
    );
  }

  static BoxDecoration glow({
    required Color glowColor,
    Color? backgroundColor,
    double borderRadius = AppSizes.radiusL,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.card,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: glowColor.withOpacity(0.3), width: 1),
      boxShadow: AppColors.glowShadow(glowColor),
    );
  }
}

/// Thai EW Strings
class AppStrings {
  // App
  static const String appName = 'EW NCO Training';
  static const String appNameTh = 'ฝึกอบรม EW นายสิบ';
  static const String appSubtitle = 'สงครามอิเล็กทรอนิกส์';

  // NCO Levels
  static const String juniorNco = 'นายสิบชั้นต้น';
  static const String seniorNco = 'นายสิบอาวุโส';
  static const String signalCorps = 'เหล่าทหารสื่อสาร';

  // EW Categories
  static const String ewOverview = 'ภาพรวม EW';
  static const String spectrum = 'สเปกตรัมแม่เหล็กไฟฟ้า';
  static const String es = 'Electronic Support';
  static const String ea = 'Electronic Attack';
  static const String ep = 'Electronic Protection';
  static const String esm = 'ESM - การสนับสนุนทางอิเล็กทรอนิกส์';
  static const String ecm = 'ECM - มาตรการตอบโต้ทางอิเล็กทรอนิกส์';
  static const String eccm = 'ECCM - มาตรการต่อต้านการตอบโต้';
  static const String radar = 'ระบบเรดาร์';
  static const String antiDrone = 'ต่อต้านโดรน';
  static const String gpsWarfare = 'สงคราม GPS';
  static const String tacticalRadio = 'วิทยุยุทธวิธี';
  static const String caseStudies = 'กรณีศึกษา';

  // Common Actions
  static const String start = 'เริ่มต้น';
  static const String continueText = 'ดำเนินการต่อ';
  static const String complete = 'เสร็จสิ้น';
  static const String next = 'ถัดไป';
  static const String previous = 'ก่อนหน้า';
  static const String submit = 'ส่งคำตอบ';
  static const String retry = 'ลองใหม่';
  static const String skip = 'ข้าม';

  // Learning
  static const String lesson = 'บทเรียน';
  static const String module = 'โมดูล';
  static const String quiz = 'แบบทดสอบ';
  static const String flashcard = 'บัตรคำ';
  static const String simulation = 'จำลอง';
  static const String glossary = 'คำศัพท์';
  static const String progress = 'ความก้าวหน้า';
  static const String achievement = 'ความสำเร็จ';

  // Difficulty
  static const String beginner = 'พื้นฐาน';
  static const String intermediate = 'ปานกลาง';
  static const String advanced = 'ขั้นสูง';
}

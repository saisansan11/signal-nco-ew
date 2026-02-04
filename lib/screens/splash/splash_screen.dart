import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../app/constants.dart';
import '../onboarding/level_selection_screen.dart';
import '../home/home_screen.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _radarController;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late AnimationController _hexagonController;

  double _loadingProgress = 0.0;
  bool _isLoadingComplete = false;
  bool _showEnterButton = false;
  String _loadingText = 'กำลังเริ่มต้นระบบ...';

  final List<String> _loadingSteps = [
    'กำลังเริ่มต้นระบบ...',
    'โหลดฐานข้อมูล EW...',
    'เตรียมโมดูลการเรียนรู้...',
    'เริ่มต้นระบบจำลอง...',
    'ตรวจสอบความพร้อม...',
    'พร้อมใช้งาน!',
  ];

  @override
  void initState() {
    super.initState();

    // Radar sweep animation
    _radarController = AnimationController(
      duration: AppDurations.radarSweep,
      vsync: this,
    )..repeat();

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Hexagon rotation
    _hexagonController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _progressController.addListener(() {
      setState(() {
        _loadingProgress = _progressController.value;

        // Update loading text based on progress
        final stepIndex = (_loadingProgress * (_loadingSteps.length - 1)).floor();
        _loadingText = _loadingSteps[stepIndex.clamp(0, _loadingSteps.length - 1)];
      });
    });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isLoadingComplete = true;
        });
        // Delay showing button for effect
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _showEnterButton = true;
            });
          }
        });
      }
    });

    // Start loading after a small delay
    Future.delayed(const Duration(milliseconds: 800), () {
      _progressController.forward();
    });
  }

  Future<void> _enterApp() async {
    // Check if user is logged in
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // Not logged in - go to login screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
      return;
    }

    // User is logged in - check if they have selected a level
    final prefs = await SharedPreferences.getInstance();
    final hasSelectedLevel = prefs.containsKey('user_progress');

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              hasSelectedLevel
                  ? const HomeScreen()
                  : const LevelSelectionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _radarController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    _hexagonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Stack(
          children: [
            // Animated grid background
            Positioned.fill(
              child: CustomPaint(
                painter: _SciFiGridPainter(
                  progress: _pulseController.value,
                ),
              ),
            ),

            // Floating hexagons - hide on small screens
            if (!isSmallScreen)
              ...List.generate(6, (index) {
                return AnimatedBuilder(
                  animation: _hexagonController,
                  builder: (context, child) {
                    final angle = (_hexagonController.value * 2 * math.pi) + (index * math.pi / 3);
                    final radius = 180.0 + (index * 20);
                    return Positioned(
                      left: MediaQuery.of(context).size.width / 2 +
                            math.cos(angle) * radius - 20,
                      top: MediaQuery.of(context).size.height / 2 +
                           math.sin(angle) * radius - 20,
                      child: Opacity(
                        opacity: 0.3,
                        child: _buildHexagon(40, AppColors.primary.withValues(alpha: 0.5)),
                      ),
                    );
                  },
                );
              }),

            // Radar sweep
            Center(
              child: AnimatedBuilder(
                animation: _radarController,
                builder: (context, child) {
                  final radarSize = isSmallScreen ? 220.0 : 320.0;
                  return CustomPaint(
                    size: Size(radarSize, radarSize),
                    painter: _SciFiRadarPainter(
                      sweepAngle: _radarController.value * 2 * math.pi,
                      color: AppColors.primary,
                    ),
                  );
                },
              ),
            ),

            // Pulse rings
            Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final pulseSize = isSmallScreen ? 240.0 : 350.0;
                  return CustomPaint(
                    size: Size(pulseSize, pulseSize),
                    painter: _SciFiPulsePainter(
                      progress: _pulseController.value,
                    ),
                  );
                },
              ),
            ),

            // Main content - scrollable for small screens
            Positioned.fill(
              child: SingleChildScrollView(
                physics: isSmallScreen ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: isSmallScreen ? 20 : 40),

                      // Animated Logo
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer ring
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final baseSize = isSmallScreen ? 100.0 : 140.0;
                              return Container(
                                width: baseSize + (_pulseController.value * 10),
                                height: baseSize + (_pulseController.value * 10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Inner glow
                          Container(
                            width: isSmallScreen ? 85 : 120,
                            height: isSmallScreen ? 85 : 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          // Main icon container
                          Container(
                            width: isSmallScreen ? 70 : 100,
                            height: isSmallScreen ? 70 : 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withValues(alpha: 0.7),
                                  const Color(0xFF00D4FF),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.6),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                                BoxShadow(
                                  color: const Color(0xFF00D4FF).withValues(alpha: 0.4),
                                  blurRadius: 50,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.radar,
                              size: isSmallScreen ? 36 : 50,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .scale(
                            begin: const Offset(0, 0),
                            end: const Offset(1, 1),
                            duration: 800.ms,
                            curve: Curves.elasticOut,
                          )
                          .fadeIn(duration: 400.ms),

                      SizedBox(height: isSmallScreen ? 20 : 32),

                      // Title with glow effect
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Colors.white,
                            Color(0xFF00D4FF),
                            AppColors.primary,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'EW TRAINING',
                          style: AppTextStyles.displayLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: isSmallScreen ? 4 : 6,
                            fontSize: isSmallScreen ? 26 : 32,
                          ),
                        ),
                      )
                          .animate(delay: 300.ms)
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),

                      SizedBox(height: isSmallScreen ? 6 : 8),

                      // Subtitle
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 14 : 20,
                          vertical: isSmallScreen ? 6 : 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'สงครามอิเล็กทรอนิกส์',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: const Color(0xFF00D4FF),
                            letterSpacing: isSmallScreen ? 2 : 4,
                            fontWeight: FontWeight.w300,
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
                      )
                          .animate(delay: 500.ms)
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: 0.3, end: 0),

                      SizedBox(height: isSmallScreen ? 8 : 12),

                      // Signal Corps text
                      Text(
                        '[ เหล่าทหารสื่อสาร ]',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 2,
                          fontSize: isSmallScreen ? 13 : 16,
                        ),
                      )
                          .animate(delay: 700.ms)
                          .fadeIn(duration: 500.ms),

                      SizedBox(height: isSmallScreen ? 30 : 50),

                      // Loading section
                      SizedBox(
                        width: isSmallScreen ? 240 : 280,
                        child: Column(
                          children: [
                            // Progress bar with sci-fi style
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.white.withValues(alpha: 0.1),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // Progress fill
                                  FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: _loadingProgress,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        gradient: const LinearGradient(
                                          colors: [
                                            AppColors.primary,
                                            Color(0xFF00D4FF),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.8),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Scan line effect
                                  if (!_isLoadingComplete)
                                    AnimatedBuilder(
                                      animation: _pulseController,
                                      builder: (context, child) {
                                        return Positioned(
                                          left: _loadingProgress * (isSmallScreen ? 240 : 280) * _pulseController.value,
                                          top: 0,
                                          bottom: 0,
                                          width: 20,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.white.withValues(alpha: 0.5),
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Progress percentage and text
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    _loadingText,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: isSmallScreen ? 10 : 11,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${(_loadingProgress * 100).toInt()}%',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: const Color(0xFF00D4FF),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate(delay: 900.ms).fadeIn(duration: 300.ms),

                      SizedBox(height: isSmallScreen ? 24 : 40),

                      // Enter button (appears after loading)
                      if (_showEnterButton)
                        GestureDetector(
                          onTap: _enterApp,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 36 : 48,
                              vertical: isSmallScreen ? 12 : 16,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  Color(0xFF00D4FF),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'เข้าสู่ระบบ',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
                            .then()
                            .shimmer(duration: 2000.ms, delay: 500.ms),

                      // Developer credit - moved inside column for small screens
                      SizedBox(height: isSmallScreen ? 30 : 60),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16,
                          vertical: isSmallScreen ? 6 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'พัฒนาโดย',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textMuted,
                                letterSpacing: 1,
                                fontSize: isSmallScreen ? 9 : 11,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 2 : 4),
                            Text(
                              'ร.ต. วสันต์ ทัศนามล',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: const Color(0xFF00D4FF),
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 13 : 14,
                              ),
                            ),
                            Text(
                              'รร.ส.สส.',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: isSmallScreen ? 11 : 12,
                              ),
                            ),
                          ],
                        ),
                      ).animate(delay: 1200.ms).fadeIn(duration: 500.ms),

                      SizedBox(height: isSmallScreen ? 10 : 16),

                      // Version
                      Text(
                        'Version 1.0.0',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textMuted.withValues(alpha: 0.5),
                          fontSize: isSmallScreen ? 9 : 11,
                        ),
                      ).animate(delay: 1400.ms).fadeIn(),

                      SizedBox(height: isSmallScreen ? 10 : 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHexagon(double size, Color color) {
    return CustomPaint(
      size: Size(size, size),
      painter: _HexagonPainter(color: color),
    );
  }
}

/// Sci-Fi Grid Background Painter
class _SciFiGridPainter extends CustomPainter {
  final double progress;

  _SciFiGridPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Horizontal lines
    const spacing = 40.0;
    for (double y = 0; y < size.height; y += spacing) {
      final opacity = 0.05 + (math.sin((y / size.height) * math.pi + progress * math.pi * 2) * 0.03);
      paint.color = AppColors.primary.withValues(alpha: opacity);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      final opacity = 0.05 + (math.sin((x / size.width) * math.pi + progress * math.pi * 2) * 0.03);
      paint.color = AppColors.primary.withValues(alpha: opacity);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SciFiGridPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Sci-Fi Radar Painter
class _SciFiRadarPainter extends CustomPainter {
  final double sweepAngle;
  final Color color;

  _SciFiRadarPainter({
    required this.sweepAngle,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw outer ring with glow
    final outerRingPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, outerRingPaint);

    // Draw range rings with tech look
    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * i / 4, ringPaint);
    }

    // Draw cross lines with dashes
    final dashPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    // Horizontal
    for (double x = 0; x < size.width; x += 10) {
      if ((x - center.dx).abs() % 20 < 10) {
        canvas.drawLine(
          Offset(x, center.dy),
          Offset(x + 5, center.dy),
          dashPaint,
        );
      }
    }

    // Vertical
    for (double y = 0; y < size.height; y += 10) {
      if ((y - center.dy).abs() % 20 < 10) {
        canvas.drawLine(
          Offset(center.dx, y),
          Offset(center.dx, y + 5),
          dashPaint,
        );
      }
    }

    // Draw sweep gradient
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: sweepAngle - 0.8,
        endAngle: sweepAngle,
        colors: [
          Colors.transparent,
          color.withValues(alpha: 0.05),
          color.withValues(alpha: 0.2),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius - 2, sweepPaint);

    // Draw sweep line with glow
    final lineEnd = Offset(
      center.dx + radius * math.cos(sweepAngle - math.pi / 2),
      center.dy + radius * math.sin(sweepAngle - math.pi / 2),
    );

    // Glow effect
    for (int i = 3; i >= 0; i--) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.1 * (4 - i) / 4)
        ..strokeWidth = 2 + i * 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(center, lineEnd, glowPaint);
    }

    // Main line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(center, lineEnd, linePaint);

    // Center dot
    final centerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, centerPaint);
  }

  @override
  bool shouldRepaint(covariant _SciFiRadarPainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle;
  }
}

/// Sci-Fi Pulse Painter
class _SciFiPulsePainter extends CustomPainter {
  final double progress;

  _SciFiPulsePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Multiple expanding rings
    for (int i = 0; i < 3; i++) {
      final ringProgress = (progress + i * 0.33) % 1.0;
      final radius = maxRadius * 0.3 + (maxRadius * 0.7 * ringProgress);
      final opacity = (1.0 - ringProgress) * 0.4;

      final paint = Paint()
        ..color = const Color(0xFF00D4FF).withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SciFiPulsePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Hexagon Painter
class _HexagonPainter extends CustomPainter {
  final Color color;

  _HexagonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

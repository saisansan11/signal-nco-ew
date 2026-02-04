// Login Screen with Google Sign-In
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/constants.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential != null && mounted) {
        // Navigate to home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ กรุณาลองใหม่อีกครั้ง';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 120,
                  height: 120,
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
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.radar,
                    size: 60,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(),

                const SizedBox(height: 32),

                // Title
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
                      letterSpacing: 4,
                    ),
                  ),
                )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'สงครามอิเล็กทรอนิกส์',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: const Color(0xFF00D4FF),
                    letterSpacing: 2,
                  ),
                )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 500.ms),

                const SizedBox(height: 8),

                Text(
                  'เหล่าทหารสื่อสาร',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                )
                    .animate(delay: 500.ms)
                    .fadeIn(duration: 500.ms),

                const SizedBox(height: 48),

                // Login Card
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'เข้าสู่ระบบ',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ใช้บัญชี @signalschool.ac.th',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Error message
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Google Sign In Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signInWithGoogle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black54,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      'https://www.google.com/favicon.ico',
                                      width: 24,
                                      height: 24,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.g_mobiledata,
                                        size: 28,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'เข้าสู่ระบบด้วย Google',
                                      style: AppTextStyles.titleMedium.copyWith(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 32),

                // Info text
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'ข้อมูลการเรียนรู้จะถูกบันทึกอัตโนมัติ',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(delay: 800.ms)
                    .fadeIn(duration: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

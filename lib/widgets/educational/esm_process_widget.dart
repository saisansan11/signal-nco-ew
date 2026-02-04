import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/constants.dart';

/// Widget แสดงกระบวนการ ESM พร้อมอนิเมชั่น
class ESMProcessWidget extends StatefulWidget {
  const ESMProcessWidget({super.key});

  @override
  State<ESMProcessWidget> createState() => _ESMProcessWidgetState();
}

class _ESMProcessWidgetState extends State<ESMProcessWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentStep = 0;

  final List<_ESMStep> _steps = [
    _ESMStep(
      title: 'ค้นหา',
      subtitle: 'Search',
      icon: Icons.search,
      description: 'กวาดหาสัญญาณในสเปกตรัม',
      color: Colors.blue,
    ),
    _ESMStep(
      title: 'ดักรับ',
      subtitle: 'Intercept',
      icon: Icons.wifi_tethering,
      description: 'จับสัญญาณมาบันทึก',
      color: Colors.orange,
    ),
    _ESMStep(
      title: 'ระบุ',
      subtitle: 'Identify',
      icon: Icons.fingerprint,
      description: 'วิเคราะห์ว่าเป็นสัญญาณอะไร',
      color: Colors.purple,
    ),
    _ESMStep(
      title: 'หาตำแหน่ง',
      subtitle: 'Locate',
      icon: Icons.location_on,
      description: 'หาว่าส่งมาจากไหน (DF)',
      color: Colors.red,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _controller.addListener(() {
      final newStep = (_controller.value * 4).floor() % 4;
      if (newStep != _currentStep) {
        setState(() => _currentStep = newStep);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Title
          Row(
            children: [
              Icon(Icons.hearing, color: AppColors.esColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'กระบวนการ ESM',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.esColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Steps flow
          Row(
            children: _steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isActive = index == _currentStep;
              final isPast = index < _currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStepCircle(step, isActive, isPast, index),
                    ),
                    if (index < _steps.length - 1)
                      _buildArrow(isPast || isActive),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Current step detail
          _buildStepDetail(_steps[_currentStep]),

          const SizedBox(height: 16),

          // Output
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.esColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.esColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.output, color: AppColors.esColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ผลลัพธ์: EOB',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.esColor,
                        ),
                      ),
                      Text(
                        'Electronic Order of Battle - ฐานข้อมูลระบบอิเล็กทรอนิกส์ข้าศึก',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle(_ESMStep step, bool isActive, bool isPast, int index) {
    return GestureDetector(
      onTap: () {
        setState(() => _currentStep = index);
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isActive ? 56 : 48,
            height: isActive ? 56 : 48,
            decoration: BoxDecoration(
              color: isActive
                  ? step.color
                  : isPast
                      ? step.color.withValues(alpha: 0.5)
                      : AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: step.color,
                width: isActive ? 3 : 2,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: step.color.withValues(alpha: 0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              step.icon,
              color: isActive || isPast ? Colors.white : step.color,
              size: isActive ? 28 : 24,
            ),
          )
              .animate(target: isActive ? 1 : 0)
              .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1))
              .then()
              .scale(begin: const Offset(1.1, 1.1), end: const Offset(1, 1)),
          const SizedBox(height: 4),
          Text(
            step.title,
            style: AppTextStyles.labelSmall.copyWith(
              color: isActive ? step.color : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildArrow(bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Icon(
        Icons.arrow_forward,
        color: isActive
            ? AppColors.esColor
            : AppColors.textSecondary.withValues(alpha: 0.3),
        size: 16,
      ),
    );
  }

  Widget _buildStepDetail(_ESMStep step) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: step.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: step.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: step.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(step.icon, color: step.color, size: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      step.title,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: step.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${step.subtitle})',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  step.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }
}

class _ESMStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final String description;
  final Color color;

  _ESMStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.description,
    required this.color,
  });
}

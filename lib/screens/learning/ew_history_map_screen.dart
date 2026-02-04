import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/constants.dart';
import '../../widgets/educational/ew_world_map_widget.dart';

/// หน้าจอแผนที่ประวัติศาสตร์ EW
/// เข้าถึงได้โดยตรงจากหน้า Dashboard
class EWHistoryMapScreen extends StatelessWidget {
  const EWHistoryMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.esColor.withAlpha(30),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: const Icon(
                Icons.public,
                color: AppColors.esColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'แผนที่ประวัติศาสตร์ EW',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          // Info button
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.textMuted),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header info
            Container(
              margin: const EdgeInsets.all(AppSizes.paddingM),
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.esColor.withAlpha(30),
                    AppColors.eaColor.withAlpha(20),
                    AppColors.epColor.withAlpha(30),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(
                  color: AppColors.esColor.withAlpha(50),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.esColor.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.history_edu,
                      color: AppColors.esColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'เหตุการณ์สำคัญในประวัติศาสตร์ EW',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'กดที่จุดบนแผนที่เพื่อดูรายละเอียด หรือกด "เริ่มทัวร์" เพื่อดูอัตโนมัติ',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

            // Map widget
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(
                  AppSizes.paddingM,
                  0,
                  AppSizes.paddingM,
                  AppSizes.paddingM,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.esColor.withAlpha(30),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  child: const EWWorldMapWidget(),
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 500.ms).scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1, 1),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.esColor.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline,
                color: AppColors.esColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'เกี่ยวกับแผนที่',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'แผนที่นี้แสดงเหตุการณ์สำคัญในประวัติศาสตร์สงครามอิเล็กทรอนิกส์ตั้งแต่สงครามโลกครั้งที่ 1 จนถึงปัจจุบัน',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.touch_app,
              label: 'กดที่จุด',
              description: 'ดูรายละเอียดเหตุการณ์',
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.play_circle_outline,
              label: 'เริ่มทัวร์',
              description: 'ดูเหตุการณ์ทั้งหมดอัตโนมัติ',
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.timeline,
              label: 'Timeline',
              description: 'เลื่อนดูตามลำดับเวลา',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('เข้าใจแล้ว'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.esColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(text: description),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

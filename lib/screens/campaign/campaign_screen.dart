import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/constants.dart';
import '../../models/campaign_model.dart';
import '../../data/campaign_data.dart';
import '../../services/campaign_service.dart';
import 'campaign_detail_screen.dart';

/// Campaign Screen - แสดงรายการ Campaign ทั้งหมด
class CampaignScreen extends StatefulWidget {
  const CampaignScreen({super.key});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  final CampaignService _campaignService = CampaignService();

  @override
  void initState() {
    super.initState();
    _campaignService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ภารกิจ Campaign'),
        backgroundColor: AppColors.surface,
        actions: [
          // Total stars
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: AppColors.warning, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${_campaignService.totalStars}',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress header
            _buildProgressHeader(),

            // Campaign list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: CampaignData.allCampaigns.length,
                itemBuilder: (context, index) {
                  final campaign = CampaignData.allCampaigns[index];
                  final isUnlocked = _campaignService.isCampaignUnlocked(campaign);
                  final progress = _campaignService.getProgress(campaign.id);

                  return _CampaignCard(
                    campaign: campaign,
                    progress: progress,
                    isUnlocked: isUnlocked,
                    onTap: isUnlocked
                        ? () => _openCampaign(campaign)
                        : () => _showLockedDialog(campaign),
                  )
                      .animate(delay: (index * 100).ms)
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: 0.1, end: 0);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    final completedMissions = _campaignService.totalCompletedMissions;
    final totalMissions = CampaignData.totalMissions;
    final progress = _campaignService.completionPercentage;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ความก้าวหน้า Campaign',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completedMissions / $totalMissions ภารกิจ',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
                child: Center(
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  void _openCampaign(Campaign campaign) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CampaignDetailScreen(campaign: campaign),
      ),
    ).then((_) {
      // Refresh star count and unlock status when returning
      if (mounted) setState(() {});
    });
  }

  void _showLockedDialog(Campaign campaign) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.lock, color: AppColors.warning),
            const SizedBox(width: 8),
            Text(
              'ยังไม่ปลดล็อค',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              campaign.nameTh,
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ต้องการ ${campaign.difficulty.starsRequired} ⭐ เพื่อปลดล็อค',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'คุณมี ${_campaignService.totalStars} ⭐',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.warning,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }
}

/// Campaign Card Widget
class _CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final UserCampaignProgress? progress;
  final bool isUnlocked;
  final VoidCallback onTap;

  const _CampaignCard({
    required this.campaign,
    this.progress,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final earnedStars = progress?.totalStars ?? 0;
    final maxStars = campaign.maxStars;
    final completedMissions = progress?.completedMissions ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isUnlocked ? AppColors.card : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? campaign.difficulty.color.withValues(alpha: 0.5)
                : AppColors.border,
            width: isUnlocked ? 2 : 1,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: campaign.difficulty.color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      // Campaign icon
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? campaign.difficulty.color.withValues(alpha: 0.2)
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: isUnlocked
                              ? Icon(
                                  Icons.military_tech,
                                  color: campaign.difficulty.color,
                                  size: 28,
                                )
                              : const Icon(
                                  Icons.lock,
                                  color: AppColors.textSecondary,
                                  size: 24,
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title and difficulty
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              campaign.nameTh,
                              style: AppTextStyles.titleMedium.copyWith(
                                color: isUnlocked
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isUnlocked
                                        ? campaign.difficulty.color.withValues(alpha: 0.2)
                                        : AppColors.border,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    campaign.difficulty.nameTh,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: isUnlocked
                                          ? campaign.difficulty.color
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${campaign.missions.length} ภารกิจ',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Stars
                      if (isUnlocked)
                        Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: AppColors.warning,
                                  size: 18,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '$earnedStars/$maxStars',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    campaign.descriptionTh,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Progress bar (if unlocked)
                  if (isUnlocked) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: completedMissions / campaign.missions.length,
                              backgroundColor: AppColors.border,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                campaign.difficulty.color,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$completedMissions/${campaign.missions.length}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Lock info
                  if (!isUnlocked) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_border,
                          color: AppColors.warning,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ต้องการ ${campaign.difficulty.starsRequired} ⭐ เพื่อปลดล็อค',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // XP reward
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.primary,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${campaign.totalXp} XP',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Completed badge
            if (progress?.isCompleted ?? false)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'สำเร็จ',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/constants.dart';
import '../../models/campaign_model.dart';
import '../../services/campaign_service.dart';

/// Campaign Detail Screen - แสดงรายละเอียด Campaign และ Mission
class CampaignDetailScreen extends StatefulWidget {
  final Campaign campaign;

  const CampaignDetailScreen({
    super.key,
    required this.campaign,
  });

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  final CampaignService _campaignService = CampaignService();

  @override
  Widget build(BuildContext context) {
    final progress = _campaignService.getProgress(widget.campaign.id);
    final earnedStars = progress?.totalStars ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar with campaign info
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: widget.campaign.difficulty.color,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.campaign.nameTh,
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.campaign.difficulty.color,
                      widget.campaign.difficulty.color.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Icon(
                          Icons.military_tech,
                          size: 200,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Stars earned
                    Positioned(
                      bottom: 60,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.warning,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$earnedStars / ${widget.campaign.maxStars}',
                              style: AppTextStyles.titleSmall.copyWith(
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
            ),
          ),

          // Story intro
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.campaign.difficulty.color.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_stories,
                        color: widget.campaign.difficulty.color,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'เรื่องราว',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: widget.campaign.difficulty.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.campaign.storyIntro,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms),
          ),

          // Mission list header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.flag,
                    color: widget.campaign.difficulty.color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ภารกิจ',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${progress?.completedMissions ?? 0} / ${widget.campaign.missions.length}',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Mission list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final mission = widget.campaign.missions[index];
                final isUnlocked = _campaignService.isMissionUnlocked(
                  widget.campaign,
                  index,
                );
                final missionResult = progress?.missionResults[mission.id];

                return _MissionCard(
                  mission: mission,
                  missionIndex: index + 1,
                  isUnlocked: isUnlocked,
                  result: missionResult,
                  campaignColor: widget.campaign.difficulty.color,
                  onTap: isUnlocked
                      ? () => _startMission(mission)
                      : null,
                )
                    .animate(delay: (index * 100).ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.1, end: 0);
              },
              childCount: widget.campaign.missions.length,
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  void _startMission(CampaignMission mission) {
    // Show mission briefing dialog
    showDialog(
      context: context,
      builder: (context) => _MissionBriefingDialog(
        mission: mission,
        campaignColor: widget.campaign.difficulty.color,
        onStart: () {
          Navigator.pop(context);
          _launchMission(mission);
        },
      ),
    );
  }

  void _launchMission(CampaignMission mission) {
    // Track mission start
    _campaignService.startMission(widget.campaign.id, mission.id);

    // TODO: Navigate to actual simulation based on mission type
    // For now, show a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('เริ่มภารกิจ: ${mission.nameTh}'),
        backgroundColor: widget.campaign.difficulty.color,
      ),
    );
  }
}

/// Mission Card Widget
class _MissionCard extends StatelessWidget {
  final CampaignMission mission;
  final int missionIndex;
  final bool isUnlocked;
  final MissionResult? result;
  final Color campaignColor;
  final VoidCallback? onTap;

  const _MissionCard({
    required this.mission,
    required this.missionIndex,
    required this.isUnlocked,
    this.result,
    required this.campaignColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = result?.isCompleted ?? false;
    final stars = result?.stars ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isUnlocked ? AppColors.card : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? AppColors.success.withValues(alpha: 0.5)
                : isUnlocked
                    ? mission.type.color.withValues(alpha: 0.3)
                    : AppColors.border,
            width: isCompleted ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Mission number
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? mission.type.color.withValues(alpha: 0.1)
                    : AppColors.border.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
              child: Column(
                children: [
                  if (isUnlocked)
                    Icon(
                      mission.type.icon,
                      color: mission.type.color,
                      size: 24,
                    )
                  else
                    const Icon(
                      Icons.lock,
                      color: AppColors.textSecondary,
                      size: 24,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '#$missionIndex',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isUnlocked
                          ? mission.type.color
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Mission info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and stars
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            mission.nameTh,
                            style: AppTextStyles.titleSmall.copyWith(
                              color: isUnlocked
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Stars display
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (i) {
                            return Icon(
                              i < stars ? Icons.star : Icons.star_border,
                              color: i < stars
                                  ? AppColors.warning
                                  : AppColors.textSecondary.withValues(alpha: 0.3),
                              size: 18,
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Description
                    Text(
                      mission.descriptionTh,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Tags
                    Row(
                      children: [
                        // Mission type
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isUnlocked
                                ? mission.type.color.withValues(alpha: 0.2)
                                : AppColors.border,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            mission.type.nameTh,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isUnlocked
                                  ? mission.type.color
                                  : AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Time limit
                        if (mission.timeLimit > 0) ...[
                          Icon(
                            Icons.timer_outlined,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${mission.timeLimit ~/ 60} นาที',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],

                        const Spacer(),

                        // XP reward
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '+${mission.xpReward} XP',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Completed indicator
            if (isCompleted)
              Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 24,
                ),
              )
            else if (isUnlocked)
              Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.play_circle_fill,
                  color: campaignColor,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Mission Briefing Dialog
class _MissionBriefingDialog extends StatelessWidget {
  final CampaignMission mission;
  final Color campaignColor;
  final VoidCallback onStart;

  const _MissionBriefingDialog({
    required this.mission,
    required this.campaignColor,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: campaignColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    mission.type.icon,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mission.nameTh,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      mission.type.nameTh,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Briefing content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'สรุปภารกิจ',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: campaignColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mission.briefing,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Objectives
                  Text(
                    'วัตถุประสงค์',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: campaignColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...mission.objectives.map((obj) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: campaignColor,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                obj.descriptionTh,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),

                  const SizedBox(height: 16),

                  // Mission info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (mission.timeLimit > 0)
                        _InfoChip(
                          icon: Icons.timer,
                          label: '${mission.timeLimit ~/ 60} นาที',
                          color: AppColors.warning,
                        ),
                      _InfoChip(
                        icon: Icons.star,
                        label: '+${mission.xpReward} XP',
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: campaignColor),
                      ),
                      child: Text(
                        'ยกเลิก',
                        style: TextStyle(color: campaignColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onStart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: campaignColor,
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('เริ่มภารกิจ'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

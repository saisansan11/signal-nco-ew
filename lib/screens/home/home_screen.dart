import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../app/constants.dart';
import '../../data/curriculum_data.dart';
import '../../models/curriculum_models.dart';
import '../../models/progress_models.dart';
import '../../services/progress_service.dart';
import '../interactive/df_sim_screen.dart';
import '../interactive/jamming_sim_screen.dart';
import '../interactive/radar_sim_screen.dart';
import '../interactive/spectrum_sim_screen.dart';
import '../learning/ew_history_map_screen.dart';
import '../learning/flashcard_screen.dart';
import '../learning/module_lessons_screen.dart';
import '../profile/profile_screen.dart';
import '../quiz/quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DashboardTab(),
          _CurriculumTab(),
          _SimulationsTab(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
            vertical: AppSizes.paddingS,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'หน้าหลัก',
                isSelected: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _NavItem(
                icon: Icons.school_rounded,
                label: 'บทเรียน',
                isSelected: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _NavItem(
                icon: Icons.radar_rounded,
                label: 'จำลอง',
                isSelected: _currentIndex == 2,
                onTap: () => setState(() => _currentIndex = 2),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'โปรไฟล์',
                isSelected: _currentIndex == 3,
                onTap: () => setState(() => _currentIndex = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(20) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dashboard Tab
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressService>(
      builder: (context, progressService, child) {
        final level = progressService.currentLevel;
        final xp = progressService.totalXP;
        final userLevel = progressService.level;
        final streak = progressService.currentStreak;
        final dailyGoals = progressService.dailyGoals;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'สวัสดี!',
                          style: AppTextStyles.displayMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingS,
                                vertical: AppSizes.paddingXXS,
                              ),
                              decoration: BoxDecoration(
                                gradient: level == NCOLevel.junior
                                    ? AppColors.juniorNcoGradient
                                    : AppColors.seniorNcoGradient,
                                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                              ),
                              child: Text(
                                level.titleTh,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Streak indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingM,
                        vertical: AppSizes.paddingS,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '$streak',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),

                const SizedBox(height: AppSizes.paddingL),

                // Progress Card
                _ProgressCard(
                  xp: xp,
                  level: userLevel,
                  dailyGoals: dailyGoals,
                ).animate(delay: 200.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: AppSizes.paddingL),

                // Quick Actions
                Text(
                  'เริ่มเรียน',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ).animate(delay: 300.ms).fadeIn(),

                const SizedBox(height: AppSizes.paddingM),

                // Action Cards Grid
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.style,
                        title: 'บัตรคำ',
                        subtitle: 'ทบทวนคำศัพท์',
                        color: AppColors.esColor,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FlashcardScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingM),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.quiz,
                        title: 'แบบทดสอบ',
                        subtitle: 'ทดสอบความรู้',
                        color: AppColors.eaColor,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuizScreen(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ).animate(delay: 400.ms).fadeIn(duration: 500.ms),

                const SizedBox(height: AppSizes.paddingM),

                Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.radar,
                        title: 'เรดาร์',
                        subtitle: 'จำลองเรดาร์',
                        color: AppColors.radarColor,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RadarSimScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingM),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.graphic_eq,
                        title: 'สเปกตรัม',
                        subtitle: 'วิเคราะห์สัญญาณ',
                        color: AppColors.spectrumColor,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SpectrumSimScreen(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ).animate(delay: 500.ms).fadeIn(duration: 500.ms),

                const SizedBox(height: AppSizes.paddingM),

                // World Map - quick access
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EWHistoryMapScreen(),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.esColor.withAlpha(40),
                          AppColors.eaColor.withAlpha(30),
                          AppColors.epColor.withAlpha(40),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                      border: Border.all(
                        color: AppColors.esColor.withAlpha(60),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.esColor.withAlpha(50),
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          ),
                          child: const Icon(
                            Icons.public,
                            color: AppColors.esColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🗺️ แผนที่ประวัติศาสตร์ EW',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'สำรวจเหตุการณ์สำคัญจากทั่วโลก',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.esColor,
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: 600.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: AppSizes.paddingXL),

                // EW Categories
                Text(
                  'หมวดหมู่ EW',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ).animate(delay: 600.ms).fadeIn(),

                const SizedBox(height: AppSizes.paddingM),

                _CategoryList().animate(delay: 700.ms).fadeIn(duration: 500.ms),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int xp;
  final int level;
  final DailyGoals dailyGoals;

  const _ProgressCard({
    required this.xp,
    required this.level,
    required this.dailyGoals,
  });

  @override
  Widget build(BuildContext context) {
    final progress = dailyGoals.progress.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: CardDecoration.glow(
        glowColor: AppColors.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'เป้าหมายวันนี้',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(progress * 100).toInt()}% เสร็จสิ้น',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                  vertical: AppSizes.paddingS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.warning, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Level $level',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: Icons.school,
                value: '${dailyGoals.lessonsCompleted}/${dailyGoals.lessonsTarget}',
                label: 'บทเรียน',
              ),
              _StatItem(
                icon: Icons.style,
                value: '${dailyGoals.flashcardsStudied}/${dailyGoals.flashcardsTarget}',
                label: 'บัตรคำ',
              ),
              _StatItem(
                icon: Icons.bolt,
                value: '$xp',
                label: 'XP',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textMuted, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: CardDecoration.standard(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList();

  @override
  Widget build(BuildContext context) {
    final categories = [
      EWCategory.es,
      EWCategory.ea,
      EWCategory.ep,
      EWCategory.radar,
      EWCategory.antiDrone,
      EWCategory.gpsWarfare,
    ];

    return Wrap(
      spacing: AppSizes.paddingS,
      runSpacing: AppSizes.paddingS,
      children: categories.map((cat) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlashcardScreen(filterCategory: cat),
            ),
          ),
          child: _CategoryChip(category: cat),
        );
      }).toList(),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final EWCategory category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      decoration: BoxDecoration(
        color: category.color.withAlpha(20),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: category.color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, color: category.color, size: 16),
          const SizedBox(width: 6),
          Text(
            category.titleTh,
            style: AppTextStyles.labelMedium.copyWith(
              color: category.color,
            ),
          ),
        ],
      ),
    );
  }
}

// Curriculum Tab - รายการบทเรียน
class _CurriculumTab extends StatelessWidget {
  const _CurriculumTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressService>(
      builder: (context, progressService, child) {
        final level = progressService.currentLevel;
        // ใช้ CurriculumData.getModulesForLevel() เพื่อให้ได้เนื้อหาที่เหมาะสม
        // - นายสิบชั้นต้น: ได้โมดูล 0-7 (8 โมดูล)
        // - นายสิบอาวุโส: ได้โมดูล 0-18 (19 โมดูล) รวมพื้นฐานด้วย
        final modules = CurriculumData.getModulesForLevel(level);

        return SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'หลักสูตร ${level.titleTh}',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${modules.length} โมดูล',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final module = modules[index];
                      return _ModuleCard(
                        module: module,
                        index: index,
                      ).animate(delay: Duration(milliseconds: 100 * index))
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: 0.1, end: 0);
                    },
                    childCount: modules.length,
                  ),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
            ],
          ),
        );
      },
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final EWModule module;
  final int index;

  const _ModuleCard({
    required this.module,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showModuleOptions(context),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              border: Border.all(
                color: module.category.color.withAlpha(50),
              ),
            ),
            child: Row(
              children: [
                // Module number
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: module.category.color.withAlpha(30),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: module.category.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                // Module info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.titleTh,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            module.category.icon,
                            size: 14,
                            color: module.category.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            module.category.titleTh,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: module.category.color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${module.estimatedMinutes} นาที',
                            style: AppTextStyles.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showModuleOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXL),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              module.titleTh,
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              module.subtitleTh,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),
            _OptionTile(
              icon: Icons.menu_book,
              title: 'เรียนบทเรียน',
              subtitle: 'เนื้อหาพร้อมภาพและอนิเมชั่น',
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModuleLessonsScreen(
                      module: module,
                    ),
                  ),
                );
              },
            ),
            _OptionTile(
              icon: Icons.style,
              title: 'บัตรคำ',
              subtitle: 'ทบทวนคำศัพท์ในโมดูลนี้',
              color: AppColors.esColor,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlashcardScreen(
                      filterCategory: module.category,
                    ),
                  ),
                );
              },
            ),
            _OptionTile(
              icon: Icons.quiz,
              title: 'แบบทดสอบ',
              subtitle: 'ทดสอบความรู้โมดูลนี้',
              color: AppColors.eaColor,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      category: module.category,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.paddingM),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.labelSmall,
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textMuted,
      ),
    );
  }
}

// Simulations Tab - รายการจำลอง
class _SimulationsTab extends StatelessWidget {
  const _SimulationsTab();

  @override
  Widget build(BuildContext context) {
    final simulations = [
      _SimulationItem(
        icon: Icons.radar,
        title: 'จำลองเรดาร์',
        subtitle: 'ฝึกตรวจจับและระบุเป้าหมาย',
        color: AppColors.radarColor,
        screen: const RadarSimScreen(),
      ),
      _SimulationItem(
        icon: Icons.graphic_eq,
        title: 'วิเคราะห์สเปกตรัม',
        subtitle: 'ฝึกตรวจจับและระบุสัญญาณ',
        color: AppColors.spectrumColor,
        screen: const SpectrumSimScreen(),
      ),
      _SimulationItem(
        icon: Icons.flash_on,
        title: 'จำลองการรบกวน',
        subtitle: 'ฝึกใช้เทคนิค Jamming',
        color: AppColors.eaColor,
        screen: const JammingSimScreen(),
      ),
      _SimulationItem(
        icon: Icons.gps_fixed,
        title: 'Direction Finding',
        subtitle: 'ฝึก Triangulation หาตำแหน่ง',
        color: AppColors.esColor,
        screen: const DFSimScreen(),
      ),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'การจำลอง EW',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 4),
            Text(
              'ฝึกทักษะด้วยการจำลองแบบโต้ตอบ',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: AppSizes.paddingL),
            ...simulations.asMap().entries.map((entry) {
              final index = entry.key;
              final sim = entry.value;
              return _SimulationCard(
                item: sim,
              ).animate(delay: Duration(milliseconds: 100 * index))
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.1, end: 0);
            }),
          ],
        ),
      ),
    );
  }
}

class _SimulationItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget screen;

  _SimulationItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.screen,
  });
}

class _SimulationCard extends StatelessWidget {
  final _SimulationItem item;

  const _SimulationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => item.screen),
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  item.color.withAlpha(30),
                  AppColors.card,
                ],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              border: Border.all(
                color: item.color.withAlpha(50),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: item.color.withAlpha(40),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


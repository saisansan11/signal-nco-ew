// Teacher Home Screen
// Main home screen for teachers with specialized tabs

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../app/constants.dart';
import '../../data/curriculum_data.dart';
import '../../models/curriculum_models.dart';
import '../../services/user_role_service.dart';
import '../interactive/df_sim_screen.dart';
import '../interactive/jamming_sim_screen.dart';
import '../interactive/radar_sim_screen.dart';
import '../interactive/spectrum_sim_screen.dart';
import '../learning/ew_history_map_screen.dart';
import '../learning/flashcard_screen.dart';
import '../learning/module_lessons_screen.dart';
import '../profile/profile_screen.dart';
import '../quiz/quiz_screen.dart';
import '../campaign/campaign_screen.dart';
import '../teacher/student_detail_screen.dart';
import '../teacher/classroom_screen.dart';
import '../teacher/quiz_editor_screen.dart';
import '../teacher/teacher_dashboard_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _TeacherDashboardTab(),
          _ContentTab(),
          _StudentsTab(),
          _LeaderboardTab(),
          _TeacherProfileTab(),
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
            horizontal: AppSizes.paddingS,
            vertical: AppSizes.paddingS,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.dashboard_rounded,
                label: 'หน้าหลัก',
                isSelected: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _NavItem(
                icon: Icons.school_rounded,
                label: 'เนื้อหา',
                isSelected: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _NavItem(
                icon: Icons.people_rounded,
                label: 'นักเรียน',
                isSelected: _currentIndex == 2,
                onTap: () => setState(() => _currentIndex = 2),
              ),
              _NavItem(
                icon: Icons.leaderboard_rounded,
                label: 'อันดับ',
                isSelected: _currentIndex == 3,
                onTap: () => setState(() => _currentIndex = 3),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'โปรไฟล์',
                isSelected: _currentIndex == 4,
                onTap: () => setState(() => _currentIndex = 4),
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
          color: isSelected ? AppColors.seniorNco.withAlpha(20) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.seniorNco : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.seniorNco : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Teacher Dashboard Tab - Overview statistics
class _TeacherDashboardTab extends StatelessWidget {
  const _TeacherDashboardTab();

  @override
  Widget build(BuildContext context) {
    final roleService = Provider.of<UserRoleService>(context);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: AppColors.seniorNcoGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'สวัสดี, ${roleService.userDisplayName}',
                              style: AppTextStyles.headlineMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.seniorNcoGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'ครูผู้สอน',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),

                  const SizedBox(height: 24),

                  // Quick Stats Cards
                  _buildQuickStats(),

                  const SizedBox(height: 24),

                  // Quick Actions
                  Text(
                    'เครื่องมือ',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActions(context),
                ],
              ),
            ),
          ),

          // Recent Activity Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'กิจกรรมล่าสุด',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ActivityFeed(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .snapshots(),
      builder: (context, snapshot) {
        int totalStudents = 0;
        int activeToday = 0;

        if (snapshot.hasData) {
          final students = snapshot.data!.docs;
          totalStudents = students.length;

          final today = DateTime.now();
          for (final doc in students) {
            final data = doc.data() as Map<String, dynamic>;

            final lastActive = data['lastActiveDate'];
            if (lastActive != null) {
              final lastActiveDate = (lastActive as Timestamp).toDate();
              if (lastActiveDate.year == today.year &&
                  lastActiveDate.month == today.month &&
                  lastActiveDate.day == today.day) {
                activeToday++;
              }
            }
          }
        }

        return Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.people,
                label: 'นักเรียนทั้งหมด',
                value: '$totalStudents',
                color: AppColors.info,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TeacherDashboardScreen(),
                  ),
                ),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.today,
                label: 'ใช้งานวันนี้',
                value: '$activeToday',
                color: AppColors.success,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TeacherDashboardScreen(),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.class_,
            label: 'จัดการห้องเรียน',
            color: Colors.cyan,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ClassroomScreen()),
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.quiz,
            label: 'สร้างแบบทดสอบ',
            color: Colors.purple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QuizEditorScreen()),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (onTap != null)
                  Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.displayMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('activities')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.timeline,
                    size: 48,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ยังไม่มีกิจกรรม',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final activities = snapshot.data!.docs;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length > 5 ? 5 : activities.length,
            separatorBuilder: (_, index) => Divider(
              color: AppColors.border,
              height: 1,
            ),
            itemBuilder: (context, index) {
              final activity = activities[index].data() as Map<String, dynamic>;
              return _ActivityItem(activity: activity);
            },
          ),
        );
      },
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final Map<String, dynamic> activity;

  const _ActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    final type = activity['activityType'] ?? '';
    final userName = activity['userName'] ?? 'ผู้ใช้';
    final timestamp = activity['timestamp'] as Timestamp?;

    IconData icon;
    Color color;
    String description;

    switch (type) {
      case 'lesson_completed':
        icon = Icons.check_circle;
        color = AppColors.success;
        description = 'เรียนจบบทเรียน';
        break;
      case 'quiz_passed':
        icon = Icons.quiz;
        color = AppColors.info;
        description = 'ผ่านแบบทดสอบ';
        break;
      case 'achievement_unlocked':
        icon = Icons.emoji_events;
        color = AppColors.warning;
        description = 'ปลดล็อกเหรียญ';
        break;
      case 'level_up':
        icon = Icons.arrow_upward;
        color = AppColors.seniorNco;
        description = 'เลเวลอัพ';
        break;
      default:
        icon = Icons.circle;
        color = AppColors.textMuted;
        description = type;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (timestamp != null)
            Text(
              _formatTime(timestamp.toDate()),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'เมื่อกี้';
    if (diff.inMinutes < 60) return '${diff.inMinutes} นาทีที่แล้ว';
    if (diff.inHours < 24) return '${diff.inHours} ชม.ที่แล้ว';
    return '${diff.inDays} วันที่แล้ว';
  }
}

// Students Tab
class _StudentsTab extends StatelessWidget {
  const _StudentsTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Row(
              children: [
                Icon(Icons.people, color: AppColors.seniorNco, size: 28),
                const SizedBox(width: 12),
                Text(
                  'รายชื่อนักเรียน',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Student List - simplified query with client-side sorting
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'เกิดข้อผิดพลาด: ${snapshot.error}',
                      style: TextStyle(color: AppColors.error),
                    ),
                  );
                }

                // Filter students and sort by XP on client side
                final allDocs = snapshot.data?.docs ?? [];
                final studentDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['role'] == 'student';
                }).toList();

                // Sort by totalXP (inside progress object)
                studentDocs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aProgress = aData['progress'] as Map<String, dynamic>?;
                  final bProgress = bData['progress'] as Map<String, dynamic>?;
                  final aXP = (aProgress?['totalXP'] ?? 0) as int;
                  final bXP = (bProgress?['totalXP'] ?? 0) as int;
                  return bXP.compareTo(aXP);
                });

                if (studentDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 64,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ยังไม่มีนักเรียน',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: studentDocs.length,
                  itemBuilder: (context, index) {
                    final doc = studentDocs[index];
                    final student = doc.data() as Map<String, dynamic>;
                    return _StudentCard(
                      student: student,
                      rank: index + 1,
                      studentUid: doc.id,
                    ).animate().fadeIn(delay: (index * 50).ms);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final Map<String, dynamic> student;
  final int rank;
  final String? studentUid;

  const _StudentCard({
    required this.student,
    required this.rank,
    this.studentUid,
  });

  @override
  Widget build(BuildContext context) {
    final name = student['displayName'] ?? 'ไม่ระบุชื่อ';
    final email = student['email'] ?? '';
    final totalXP = (student['totalXP'] as int?) ?? 0;
    final level = (totalXP / 100).floor() + 1;
    final streak = (student['currentStreak'] as int?) ?? 0;

    return GestureDetector(
      onTap: () {
        if (studentUid != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentDetailScreen(
                studentUid: studentUid!,
                studentName: name,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(color: AppColors.border),
        ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: rank <= 3
                  ? (rank == 1
                      ? AppColors.seniorNco
                      : rank == 2
                          ? AppColors.juniorNco
                          : AppColors.droneColor)
                  : AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: rank <= 3 ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Student info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  email,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: AppColors.warning, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$totalXP XP',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Lv.$level',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                  if (streak > 0) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.local_fire_department,
                      color: AppColors.warning,
                      size: 14,
                    ),
                    Text(
                      '$streak',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

// Leaderboard Tab
class _LeaderboardTab extends StatelessWidget {
  const _LeaderboardTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Row(
              children: [
                Icon(Icons.leaderboard, color: AppColors.seniorNco, size: 28),
                const SizedBox(width: 12),
                Text(
                  'ตารางอันดับ',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Leaderboard - simplified query with client-side sorting
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filter students and sort by XP on client side
                final allDocs = snapshot.data!.docs;
                final students = allDocs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .where((user) => user['role'] == 'student')
                    .toList();

                // Sort by totalXP (inside progress object) - descending
                students.sort((a, b) {
                  final aProgress = a['progress'] as Map<String, dynamic>?;
                  final bProgress = b['progress'] as Map<String, dynamic>?;
                  final aXP = (aProgress?['totalXP'] ?? 0) as int;
                  final bXP = (bProgress?['totalXP'] ?? 0) as int;
                  return bXP.compareTo(aXP);
                });

                // Limit to top 20
                final topStudents = students.take(20).toList();

                if (topStudents.isEmpty) {
                  return Center(
                    child: Text(
                      'ยังไม่มีข้อมูล',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: topStudents.length,
                  itemBuilder: (context, index) {
                    final student = topStudents[index];
                    return _LeaderboardItem(
                      student: student,
                      rank: index + 1,
                    ).animate().fadeIn(delay: (index * 50).ms);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  final Map<String, dynamic> student;
  final int rank;

  const _LeaderboardItem({required this.student, required this.rank});

  @override
  Widget build(BuildContext context) {
    final name = student['displayName'] ?? 'ไม่ระบุชื่อ';
    // Access totalXP from nested progress object
    final progress = student['progress'] as Map<String, dynamic>?;
    final totalXP = (progress?['totalXP'] ?? 0) as int;

    Color? badgeColor;
    IconData? badgeIcon;

    if (rank == 1) {
      badgeColor = AppColors.seniorNco;
      badgeIcon = Icons.emoji_events;
    } else if (rank == 2) {
      badgeColor = AppColors.juniorNco;
      badgeIcon = Icons.emoji_events;
    } else if (rank == 3) {
      badgeColor = AppColors.droneColor;
      badgeIcon = Icons.emoji_events;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: rank <= 3 ? badgeColor?.withAlpha(20) : AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: rank <= 3 ? badgeColor ?? AppColors.border : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          // Rank/Badge
          SizedBox(
            width: 40,
            child: rank <= 3
                ? Icon(badgeIcon, color: badgeColor, size: 28)
                : Text(
                    '#$rank',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: rank <= 3 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),

          // XP
          Text(
            '$totalXP XP',
            style: AppTextStyles.titleMedium.copyWith(
              color: rank <= 3 ? badgeColor : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Teacher Profile Tab
class _TeacherProfileTab extends StatelessWidget {
  const _TeacherProfileTab();

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}

// Content Tab - เนื้อหาบทเรียนและจำลอง (สำหรับครูดูตรวจสอบ)
class _ContentTab extends StatelessWidget {
  const _ContentTab();

  @override
  Widget build(BuildContext context) {
    // ครูเห็นเนื้อหาทั้งหมด (ทั้งชั้นต้นและอาวุโส)
    final allModules = CurriculumData.allModules;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.school, color: AppColors.seniorNco, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'เนื้อหาทั้งหมด',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ดูเนื้อหาเหมือนที่นักเรียนเห็น • ${allModules.length} โมดูล',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),
          ),

          // Quick Actions - Simulations & Tools
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'เครื่องมือจำลอง',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _SimCard(
                          icon: Icons.waves,
                          title: 'Spectrum',
                          color: AppColors.esColor,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SpectrumSimScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _SimCard(
                          icon: Icons.radar,
                          title: 'Radar',
                          color: AppColors.radarColor,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RadarSimScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _SimCard(
                          icon: Icons.wifi_tethering_off,
                          title: 'Jamming',
                          color: AppColors.eaColor,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const JammingSimScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _SimCard(
                          icon: Icons.explore,
                          title: 'DF',
                          color: AppColors.epColor,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DFSimScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _SimCard(
                          icon: Icons.public,
                          title: 'แผนที่ EW',
                          color: AppColors.info,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EWHistoryMapScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _SimCard(
                          icon: Icons.military_tech,
                          title: 'Campaign',
                          color: AppColors.warning,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CampaignScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'บทเรียนทั้งหมด',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
          ),

          // Module List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final module = allModules[index];
                  return _TeacherModuleCard(
                    module: module,
                    index: index,
                  ).animate(delay: Duration(milliseconds: 50 * index))
                      .fadeIn(duration: 200.ms)
                      .slideX(begin: 0.05, end: 0);
                },
                childCount: allModules.length,
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }
}

class _SimCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _SimCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              title,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _TeacherModuleCard extends StatelessWidget {
  final EWModule module;
  final int index;

  const _TeacherModuleCard({
    required this.module,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showModuleOptions(context),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(
                color: module.category.color.withAlpha(40),
              ),
            ),
            child: Row(
              children: [
                // Module number
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: module.category.color.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: module.category.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Module info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.titleTh,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            module.category.icon,
                            size: 12,
                            color: module.category.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            module.category.titleTh,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: module.category.color,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.timer_outlined,
                            size: 12,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${module.estimatedMinutes} นาที',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 10,
                            ),
                          ),
                          // Level badge
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: module.requiredLevel == NCOLevel.junior
                                  ? AppColors.juniorNco.withAlpha(30)
                                  : AppColors.seniorNco.withAlpha(30),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              module.requiredLevel == NCOLevel.junior ? 'ชั้นต้น' : 'อาวุโส',
                              style: TextStyle(
                                fontSize: 9,
                                color: module.requiredLevel == NCOLevel.junior
                                    ? AppColors.juniorNco
                                    : AppColors.seniorNco,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                  size: 20,
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: module.category.color.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    module.category.icon,
                    color: module.category.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.titleTh,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        module.subtitleTh,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingL),
            _OptionTile(
              icon: Icons.menu_book,
              title: 'ดูบทเรียน',
              subtitle: 'เนื้อหาที่นักเรียนจะเห็น',
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModuleLessonsScreen(module: module),
                  ),
                );
              },
            ),
            _OptionTile(
              icon: Icons.style,
              title: 'บัตรคำ',
              subtitle: 'Flashcards ในหมวดนี้',
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
              subtitle: 'ทดลองทำแบบทดสอบ',
              color: AppColors.eaColor,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(category: module.category),
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
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textMuted,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppColors.textMuted,
        size: 16,
      ),
    );
  }
}

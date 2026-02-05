import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../app/constants.dart';

/// Teacher Dashboard - ดูข้อมูลความก้าวหน้าของนักเรียนทั้งหมด
class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard ครู'),
        backgroundColor: AppColors.surface,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'นักเรียน'),
            Tab(icon: Icon(Icons.leaderboard), text: 'อันดับ'),
            Tab(icon: Icon(Icons.timeline), text: 'กิจกรรม'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _StudentsTab(),
          _LeaderboardTab(),
          _ActivityTab(),
        ],
      ),
    );
  }
}

class _StudentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Simplified query - no orderBy to avoid composite index requirement
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'เกิดข้อผิดพลาด',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ไม่สามารถโหลดข้อมูลนักเรียนได้',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Sort on client side to avoid Firestore composite index
        final studentDocs = snapshot.data?.docs ?? [];
        final students = studentDocs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        students.sort((a, b) {
          final aXP = (a['totalXP'] ?? 0) as int;
          final bXP = (b['totalXP'] ?? 0) as int;
          return bXP.compareTo(aXP); // Descending
        });

        if (students.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school_outlined, size: 64, color: AppColors.textMuted),
                const SizedBox(height: 16),
                Text(
                  'ยังไม่มีข้อมูลนักเรียน',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return _StudentCard(
              student: student,
              rank: index + 1,
            ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms);
          },
        );
      },
    );
  }
}

class _StudentCard extends StatelessWidget {
  final Map<String, dynamic> student;
  final int rank;

  const _StudentCard({required this.student, required this.rank});

  @override
  Widget build(BuildContext context) {
    final name = student['displayName'] ?? 'ไม่ระบุชื่อ';
    final email = student['email'] ?? '';
    final totalXP = student['totalXP'] ?? 0;
    final level = ((totalXP as int) / 100).floor() + 1;
    final streak = student['currentStreak'] ?? 0;
    final lessonsCompleted = student['lessonsCompleted'] ?? 0;

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showStudentDetail(context, student),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Rank badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getRankColor(rank).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: _getRankColor(rank),
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
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lv.$level',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: streak > 0 ? Colors.orange : AppColors.textMuted,
                      ),
                      Text(
                        '$streak',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: streak > 0 ? Colors.orange : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalXP XP | $lessonsCompleted บท',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown.shade400;
      default:
        return AppColors.primary;
    }
  }

  void _showStudentDetail(BuildContext context, Map<String, dynamic> student) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _StudentDetailSheet(student: student),
    );
  }
}

class _StudentDetailSheet extends StatelessWidget {
  final Map<String, dynamic> student;

  const _StudentDetailSheet({required this.student});

  @override
  Widget build(BuildContext context) {
    final name = student['displayName'] ?? 'ไม่ระบุชื่อ';
    final email = student['email'] ?? '';
    final totalXP = student['totalXP'] ?? 0;
    final level = ((totalXP as int) / 100).floor() + 1;
    final streak = student['currentStreak'] ?? 0;
    final lessonsCompleted = student['lessonsCompleted'] ?? 0;
    final quizzesPassed = student['quizzesPassed'] ?? 0;
    final flashcardsStudied = student['flashcardsStudied'] ?? 0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Profile
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            email,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Stats grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatColumn(
                icon: Icons.military_tech,
                value: 'Lv.$level',
                label: 'ระดับ',
                color: AppColors.primary,
              ),
              _StatColumn(
                icon: Icons.local_fire_department,
                value: '$streak',
                label: 'Streak',
                color: Colors.orange,
              ),
              _StatColumn(
                icon: Icons.star,
                value: '$totalXP',
                label: 'XP',
                color: Colors.amber,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Progress details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.menu_book,
                  label: 'บทเรียนที่เรียน',
                  value: '$lessonsCompleted บท',
                ),
                const Divider(height: 24),
                _DetailRow(
                  icon: Icons.quiz,
                  label: 'แบบทดสอบที่ผ่าน',
                  value: '$quizzesPassed ข้อ',
                ),
                const Divider(height: 24),
                _DetailRow(
                  icon: Icons.style,
                  label: 'Flashcards ที่ศึกษา',
                  value: '$flashcardsStudied ใบ',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatColumn({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _LeaderboardTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Simplified query - sort on client side
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Sort on client side and take top 20
        final studentDocs = snapshot.data?.docs ?? [];
        final students = studentDocs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        students.sort((a, b) {
          final aXP = (a['totalXP'] ?? 0) as int;
          final bXP = (b['totalXP'] ?? 0) as int;
          return bXP.compareTo(aXP);
        });
        final top20 = students.take(20).toList();

        if (top20.isEmpty) {
          return const Center(child: Text('ไม่มีข้อมูล'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: top20.length,
          itemBuilder: (context, index) {
            final student = top20[index];
            final name = student['displayName'] ?? 'ไม่ระบุชื่อ';
            final totalXP = student['totalXP'] ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: index < 3
                    ? _getTopColor(index).withValues(alpha: 0.1)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: index < 3
                    ? Border.all(color: _getTopColor(index).withValues(alpha: 0.5))
                    : null,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: index < 3
                        ? Icon(
                            Icons.emoji_events,
                            color: _getTopColor(index),
                            size: 28,
                          )
                        : Text(
                            '${index + 1}',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '$totalXP XP',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms, delay: (index * 30).ms);
          },
        );
      },
    );
  }

  Color _getTopColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey.shade400;
      case 2:
        return Colors.brown.shade400;
      default:
        return AppColors.primary;
    }
  }
}

class _ActivityTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Simplified query - sort on client side
      stream: FirebaseFirestore.instance.collection('activity_log').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Sort on client side and take latest 50
        final activityDocs = snapshot.data?.docs ?? [];
        final activities = activityDocs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        activities.sort((a, b) {
          final aTime = a['timestamp'] as Timestamp?;
          final bTime = b['timestamp'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });
        final latest50 = activities.take(50).toList();

        if (latest50.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: AppColors.textMuted),
                const SizedBox(height: 16),
                Text(
                  'ยังไม่มีกิจกรรม',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: latest50.length,
          itemBuilder: (context, index) {
            final activity = latest50[index];
            return _ActivityItem(activity: activity)
                .animate()
                .fadeIn(duration: 300.ms, delay: (index * 30).ms);
          },
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
    final type = activity['type'] ?? 'unknown';
    final userName = activity['userName'] ?? 'ไม่ระบุ';
    final details = activity['details'] ?? '';
    final timestamp = activity['timestamp'] as Timestamp?;
    final timeStr = timestamp != null
        ? _formatTime(timestamp.toDate())
        : '';

    IconData icon;
    Color color;

    switch (type) {
      case 'lesson_completed':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'quiz_passed':
        icon = Icons.quiz;
        color = Colors.blue;
        break;
      case 'achievement_unlocked':
        icon = Icons.emoji_events;
        color = Colors.amber;
        break;
      case 'level_up':
        icon = Icons.arrow_upward;
        color = Colors.purple;
        break;
      default:
        icon = Icons.info;
        color = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
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
                  details,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            timeStr,
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

    if (diff.inMinutes < 1) {
      return 'เมื่อกี้';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} นาที';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} ชม.';
    } else {
      return '${diff.inDays} วัน';
    }
  }
}

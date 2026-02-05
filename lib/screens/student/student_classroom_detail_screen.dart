// Student Classroom Detail Screen
// Screen for students to view classroom details and assignments

import 'package:flutter/material.dart';
import '../../models/classroom_model.dart';
import '../../services/classroom_service.dart';
import '../../services/auth_service.dart';

class StudentClassroomDetailScreen extends StatefulWidget {
  final Classroom classroom;

  const StudentClassroomDetailScreen({
    super.key,
    required this.classroom,
  });

  @override
  State<StudentClassroomDetailScreen> createState() =>
      _StudentClassroomDetailScreenState();
}

class _StudentClassroomDetailScreenState
    extends State<StudentClassroomDetailScreen> {
  final ClassroomService _classroomService = ClassroomService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.classroom.nameTh,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              'ครู: ${widget.classroom.teacherName}',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Classroom info card
          _buildInfoCard(),
          const SizedBox(height: 16),

          // Progress section
          _buildProgressSection(),
          const SizedBox(height: 16),

          // Assignments section
          _buildAssignmentsSection(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: const Color(0xFF1a1a2e),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.class_, color: Colors.cyan, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.classroom.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.classroom.nameTh,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.classroom.description != null) ...[
              const SizedBox(height: 12),
              Text(
                widget.classroom.description!,
                style: const TextStyle(color: Colors.white54),
              ),
            ],
            const Divider(color: Colors.white24, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoItem(
                  icon: Icons.person,
                  label: 'ครูผู้สอน',
                  value: widget.classroom.teacherName,
                ),
                _InfoItem(
                  icon: Icons.people,
                  label: 'นักเรียน',
                  value: '${widget.classroom.studentCount} คน',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    final user = _authService.currentUser;
    if (user == null) return const SizedBox.shrink();

    return FutureBuilder<List<AssignmentSubmission>>(
      future: _classroomService.getStudentSubmissions(
        widget.classroom.id,
        user.uid,
      ),
      builder: (context, snapshot) {
        final submissions = snapshot.data ?? [];
        final completedCount =
            submissions.where((s) => s.isCompleted).length;

        return Card(
          color: const Color(0xFF1a1a2e),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'ความก้าวหน้าของฉัน',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ProgressCard(
                        icon: Icons.check_circle,
                        label: 'งานที่ทำแล้ว',
                        value: '$completedCount',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ProgressCard(
                        icon: Icons.star,
                        label: 'คะแนนเฉลี่ย',
                        value: _calculateAverageScore(submissions),
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _calculateAverageScore(List<AssignmentSubmission> submissions) {
    final completedWithScore = submissions
        .where((s) => s.isCompleted && s.percentage != null)
        .toList();

    if (completedWithScore.isEmpty) return '-';

    final avg = completedWithScore.fold<double>(
          0,
          (sum, s) => sum + (s.percentage ?? 0),
        ) /
        completedWithScore.length;

    return '${avg.round()}%';
  }

  Widget _buildAssignmentsSection() {
    return StreamBuilder<List<Assignment>>(
      stream: _classroomService.getClassroomAssignments(widget.classroom.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.cyan),
          );
        }

        final assignments = snapshot.data ?? [];

        return Card(
          color: const Color(0xFF1a1a2e),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.assignment, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'งานมอบหมาย',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${assignments.length} รายการ',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (assignments.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 48,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'ยังไม่มีงานมอบหมาย',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...assignments.map((assignment) {
                    return _AssignmentItem(
                      assignment: assignment,
                      onTap: () => _openAssignment(assignment),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openAssignment(Assignment assignment) {
    // Navigate to assignment based on type
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('เปิด: ${assignment.titleTh}'),
        backgroundColor: Colors.cyan,
      ),
    );
    // TODO: Navigate to appropriate screen based on assignment.type
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.cyan, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ProgressCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _AssignmentItem extends StatelessWidget {
  final Assignment assignment;
  final VoidCallback onTap;

  const _AssignmentItem({
    required this.assignment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = assignment.isOverdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0a0a0a),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOverdue
              ? Colors.red.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getTypeColor(assignment.type).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTypeIcon(assignment.type),
            color: _getTypeColor(assignment.type),
            size: 20,
          ),
        ),
        title: Text(
          assignment.titleTh,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Row(
          children: [
            Text(
              assignment.type.thaiName,
              style: TextStyle(
                color: _getTypeColor(assignment.type),
                fontSize: 11,
              ),
            ),
            if (assignment.dueDate != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.schedule,
                size: 12,
                color: isOverdue ? Colors.red : Colors.white38,
              ),
              const SizedBox(width: 2),
              Text(
                _formatDate(assignment.dueDate!),
                style: TextStyle(
                  color: isOverdue ? Colors.red : Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (assignment.isRequired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'บังคับ',
                  style: TextStyle(color: Colors.orange, fontSize: 9),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(AssignmentType type) {
    switch (type) {
      case AssignmentType.quiz:
        return Colors.purple;
      case AssignmentType.lesson:
        return Colors.blue;
      case AssignmentType.campaign:
        return Colors.green;
      case AssignmentType.simulation:
        return Colors.orange;
    }
  }

  IconData _getTypeIcon(AssignmentType type) {
    switch (type) {
      case AssignmentType.quiz:
        return Icons.quiz;
      case AssignmentType.lesson:
        return Icons.menu_book;
      case AssignmentType.campaign:
        return Icons.flag;
      case AssignmentType.simulation:
        return Icons.science;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}

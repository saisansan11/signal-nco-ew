// Classroom Detail Screen
// Screen for viewing and managing a specific classroom

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/classroom_model.dart';
import '../../services/classroom_service.dart';
import 'assignment_editor_screen.dart';

class ClassroomDetailScreen extends StatefulWidget {
  final Classroom classroom;

  const ClassroomDetailScreen({
    super.key,
    required this.classroom,
  });

  @override
  State<ClassroomDetailScreen> createState() => _ClassroomDetailScreenState();
}

class _ClassroomDetailScreenState extends State<ClassroomDetailScreen>
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
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.classroom.name,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              'รหัส: ${widget.classroom.code}',
              style: const TextStyle(color: Colors.cyan, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white70),
            onPressed: _copyCode,
            tooltip: 'คัดลอกรหัส',
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white70),
            onPressed: _shareClassroom,
            tooltip: 'แชร์',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.cyan,
          labelColor: Colors.cyan,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'ภาพรวม', icon: Icon(Icons.dashboard, size: 20)),
            Tab(text: 'นักเรียน', icon: Icon(Icons.people, size: 20)),
            Tab(text: 'งาน', icon: Icon(Icons.assignment, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(classroom: widget.classroom),
          _StudentsTab(classroom: widget.classroom),
          _AssignmentsTab(classroom: widget.classroom),
        ],
      ),
    );
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: widget.classroom.code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('คัดลอกรหัส ${widget.classroom.code} แล้ว'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareClassroom() {
    final text = 'เข้าร่วมห้องเรียน "${widget.classroom.name}"\n'
        'รหัสเข้าร่วม: ${widget.classroom.code}\n\n'
        'ใช้รหัสนี้ในแอป Signal NCO EW';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('คัดลอกข้อความแชร์แล้ว'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// Overview Tab
class _OverviewTab extends StatelessWidget {
  final Classroom classroom;

  const _OverviewTab({required this.classroom});

  @override
  Widget build(BuildContext context) {
    final classroomService = ClassroomService();

    return FutureBuilder<ClassroomStats>(
      future: classroomService.getClassroomStats(classroom.id),
      builder: (context, snapshot) {
        final stats = snapshot.data;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Classroom info card
            _InfoCard(
              title: 'ข้อมูลห้องเรียน',
              icon: Icons.info_outline,
              children: [
                _InfoRow(label: 'ชื่อ', value: classroom.name),
                _InfoRow(label: 'ชื่อไทย', value: classroom.nameTh),
                _InfoRow(label: 'รหัสเข้าร่วม', value: classroom.code),
                _InfoRow(label: 'ครูผู้สอน', value: classroom.teacherName),
                _InfoRow(
                  label: 'สร้างเมื่อ',
                  value: _formatDate(classroom.createdAt),
                ),
                if (classroom.description != null)
                  _InfoRow(label: 'คำอธิบาย', value: classroom.description!),
              ],
            ),
            const SizedBox(height: 16),

            // Stats card
            _InfoCard(
              title: 'สถิติ',
              icon: Icons.bar_chart,
              children: [
                _StatRow(
                  icon: Icons.people,
                  label: 'จำนวนนักเรียน',
                  value: '${stats?.totalStudents ?? classroom.studentCount}',
                  color: Colors.blue,
                ),
                _StatRow(
                  icon: Icons.assignment,
                  label: 'งานทั้งหมด',
                  value: '${stats?.totalAssignments ?? 0}',
                  color: Colors.orange,
                ),
                _StatRow(
                  icon: Icons.check_circle,
                  label: 'งานที่เสร็จแล้ว',
                  value: '${stats?.completedAssignments ?? 0}',
                  color: Colors.green,
                ),
                _StatRow(
                  icon: Icons.score,
                  label: 'คะแนนเฉลี่ย',
                  value: '${stats?.averageScore ?? 0}%',
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quick actions
            _InfoCard(
              title: 'การดำเนินการ',
              icon: Icons.flash_on,
              children: [
                _ActionButton(
                  icon: Icons.person_add,
                  label: 'เชิญนักเรียน',
                  color: Colors.cyan,
                  onTap: () => _showInviteDialog(context),
                ),
                _ActionButton(
                  icon: Icons.add_task,
                  label: 'มอบหมายงานใหม่',
                  color: Colors.green,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AssignmentEditorScreen(
                        classroomId: classroom.id,
                      ),
                    ),
                  ),
                ),
                _ActionButton(
                  icon: Icons.announcement,
                  label: 'ประกาศ',
                  color: Colors.orange,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ฟีเจอร์กำลังพัฒนา')),
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text(
          'เชิญนักเรียน',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'แจ้งรหัสนี้ให้นักเรียน:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.cyan.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                classroom.code,
                style: const TextStyle(
                  color: Colors.cyan,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'นักเรียนใช้รหัสนี้ในเมนู "เข้าร่วมห้องเรียน"',
              style: TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: classroom.code));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('คัดลอกรหัสแล้ว'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('คัดลอก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }
}

// Students Tab
class _StudentsTab extends StatelessWidget {
  final Classroom classroom;

  const _StudentsTab({required this.classroom});

  @override
  Widget build(BuildContext context) {
    final classroomService = ClassroomService();

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: classroomService.getClassroomStudents(classroom.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.cyan),
          );
        }

        final students = snapshot.data ?? [];

        if (students.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ยังไม่มีนักเรียน',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'แจ้งรหัส ${classroom.code} ให้นักเรียน',
                  style: const TextStyle(color: Colors.white54),
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
              onRemove: () => _removeStudent(context, student['uid']),
            );
          },
        );
      },
    );
  }

  Future<void> _removeStudent(BuildContext context, String studentUid) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('ลบนักเรียน?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'ต้องการลบนักเรียนออกจากห้องเรียนนี้?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ClassroomService().removeStudent(classroom.id, studentUid);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ลบนักเรียนแล้ว'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาด: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}

class _StudentCard extends StatelessWidget {
  final Map<String, dynamic> student;
  final VoidCallback onRemove;

  const _StudentCard({
    required this.student,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: const Color(0xFF1a1a2e),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.cyan.withValues(alpha: 0.2),
          child: Text(
            (student['displayName'] ?? 'N')[0].toUpperCase(),
            style: const TextStyle(color: Colors.cyan),
          ),
        ),
        title: Text(
          student['displayName'] ?? student['email'] ?? 'ไม่ทราบชื่อ',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          student['email'] ?? '',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${student['xp'] ?? 0} XP',
                style: const TextStyle(color: Colors.amber, fontSize: 12),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

// Assignments Tab
class _AssignmentsTab extends StatelessWidget {
  final Classroom classroom;

  const _AssignmentsTab({required this.classroom});

  @override
  Widget build(BuildContext context) {
    final classroomService = ClassroomService();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<Assignment>>(
        stream: classroomService.getClassroomAssignments(classroom.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.cyan),
            );
          }

          final assignments = snapshot.data ?? [];

          if (assignments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ยังไม่มีงานมอบหมาย',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssignmentEditorScreen(
                          classroomId: classroom.id,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                    icon: const Icon(Icons.add),
                    label: const Text('มอบหมายงานแรก'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              return _AssignmentCard(assignment: assignments[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssignmentEditorScreen(
              classroomId: classroom.id,
            ),
          ),
        ),
        backgroundColor: Colors.cyan,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final Assignment assignment;

  const _AssignmentCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final isOverdue = assignment.isOverdue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1a1a2e),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOverdue
              ? Colors.red.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        assignment.type.thaiName,
                        style: TextStyle(
                          color: _getTypeColor(assignment.type),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'เลยกำหนด',
                      style: TextStyle(color: Colors.red, fontSize: 10),
                    ),
                  ),
              ],
            ),
            if (assignment.description != null) ...[
              const SizedBox(height: 8),
              Text(
                assignment.description!,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (assignment.dueDate != null) ...[
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: isOverdue ? Colors.red : Colors.white38,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'กำหนด: ${_formatDate(assignment.dueDate!)}',
                    style: TextStyle(
                      color: isOverdue ? Colors.red : Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
                const Spacer(),
                if (assignment.isRequired)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'บังคับ',
                      style: TextStyle(color: Colors.orange, fontSize: 10),
                    ),
                  ),
              ],
            ),
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
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Helper widgets
class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
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
                Icon(icon, color: Colors.cyan, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white70)),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: const TextStyle(color: Colors.white)),
              ),
              Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }
}

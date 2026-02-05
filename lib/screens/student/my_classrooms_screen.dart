// My Classrooms Screen (Student)
// Screen for students to view and join classrooms

import 'package:flutter/material.dart';
import '../../models/classroom_model.dart';
import '../../services/classroom_service.dart';
import '../../services/auth_service.dart';
import 'student_classroom_detail_screen.dart';

class MyClassroomsScreen extends StatefulWidget {
  const MyClassroomsScreen({super.key});

  @override
  State<MyClassroomsScreen> createState() => _MyClassroomsScreenState();
}

class _MyClassroomsScreenState extends State<MyClassroomsScreen> {
  final ClassroomService _classroomService = ClassroomService();
  final AuthService _authService = AuthService();
  final _joinCodeController = TextEditingController();

  @override
  void dispose() {
    _joinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('กรุณาเข้าสู่ระบบ')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text(
          'ห้องเรียนของฉัน',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showJoinDialog(),
            tooltip: 'เข้าร่วมห้องเรียน',
          ),
        ],
      ),
      body: StreamBuilder<List<Classroom>>(
        stream: _classroomService.getStudentClassrooms(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.cyan),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'เกิดข้อผิดพลาด: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final classrooms = snapshot.data ?? [];

          if (classrooms.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: classrooms.length,
            itemBuilder: (context, index) {
              return _ClassroomCard(
                classroom: classrooms[index],
                onTap: () => _navigateToClassroom(classrooms[index]),
                onLeave: () => _leaveClassroom(classrooms[index]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showJoinDialog(),
        backgroundColor: Colors.cyan,
        icon: const Icon(Icons.login),
        label: const Text('เข้าร่วม'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.cyan.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school_outlined,
                size: 64,
                color: Colors.cyan,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'ยังไม่ได้เข้าร่วมห้องเรียน',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ขอรหัส 6 หลักจากครูผู้สอน\nเพื่อเข้าร่วมห้องเรียน',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showJoinDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.login),
              label: const Text('เข้าร่วมห้องเรียน'),
            ),
          ],
        ),
      ),
    );
  }

  void _showJoinDialog() {
    _joinCodeController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text(
          'เข้าร่วมห้องเรียน',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'ใส่รหัส 6 หลักที่ได้รับจากครู',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _joinCodeController,
              style: const TextStyle(
                color: Colors.cyan,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: '000000',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.2),
                  fontSize: 24,
                  letterSpacing: 8,
                ),
                counterText: '',
                filled: true,
                fillColor: Colors.cyan.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.cyan),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.cyan, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _joinClassroom();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
            child: const Text('เข้าร่วม'),
          ),
        ],
      ),
    );
  }

  Future<void> _joinClassroom() async {
    final code = _joinCodeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาใส่รหัส 6 หลัก'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final success = await _classroomService.joinClassroom(code, user.uid);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('เข้าร่วมห้องเรียนสำเร็จ!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ไม่พบห้องเรียนหรือห้องเรียนถูกปิดใช้งาน'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToClassroom(Classroom classroom) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentClassroomDetailScreen(classroom: classroom),
      ),
    );
  }

  Future<void> _leaveClassroom(Classroom classroom) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text(
          'ออกจากห้องเรียน?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'ต้องการออกจากห้องเรียน "${classroom.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ออก'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final user = _authService.currentUser;
      if (user == null) return;

      try {
        await _classroomService.leaveClassroom(classroom.id, user.uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ออกจากห้องเรียนแล้ว'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('เกิดข้อผิดพลาด: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _ClassroomCard extends StatelessWidget {
  final Classroom classroom;
  final VoidCallback onTap;
  final VoidCallback onLeave;

  const _ClassroomCard({
    required this.classroom,
    required this.onTap,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1a1a2e),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.cyan.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                    child: const Icon(
                      Icons.class_,
                      color: Colors.cyan,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classroom.nameTh,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ครู: ${classroom.teacherName}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white54),
                    color: const Color(0xFF2a2a4e),
                    onSelected: (value) {
                      if (value == 'leave') {
                        onLeave();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'leave',
                        child: Row(
                          children: [
                            Icon(Icons.exit_to_app, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('ออกจากห้องเรียน', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Stats row
              Row(
                children: [
                  _StatChip(
                    icon: Icons.people,
                    label: '${classroom.studentCount} คน',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  const _StatChip(
                    icon: Icons.assignment,
                    label: 'ดูงาน',
                    color: Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

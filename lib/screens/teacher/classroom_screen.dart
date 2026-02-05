// Classroom Screen
// Main screen for teachers to manage their virtual classrooms

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/classroom_model.dart';
import '../../services/classroom_service.dart';
import '../../services/auth_service.dart';
import 'create_classroom_screen.dart';
import 'classroom_detail_screen.dart';

class ClassroomScreen extends StatefulWidget {
  const ClassroomScreen({super.key});

  @override
  State<ClassroomScreen> createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen> {
  final ClassroomService _classroomService = ClassroomService();
  final AuthService _authService = AuthService();

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
            onPressed: () => _navigateToCreateClassroom(),
            tooltip: 'สร้างห้องเรียนใหม่',
          ),
        ],
      ),
      body: StreamBuilder<List<Classroom>>(
        stream: _classroomService.getTeacherClassrooms(user.uid),
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
                onTap: () => _navigateToClassroomDetail(classrooms[index]),
                onCopyCode: () => _copyClassroomCode(classrooms[index].code),
                onDelete: () => _deleteClassroom(classrooms[index]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateClassroom(),
        backgroundColor: Colors.cyan,
        icon: const Icon(Icons.add),
        label: const Text('สร้างห้องเรียน'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.cyan.withOpacity(0.1),
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
            'ยังไม่มีห้องเรียน',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'สร้างห้องเรียนเพื่อเริ่มจัดการนักเรียน\nและมอบหมายงาน',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateClassroom(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add),
            label: const Text('สร้างห้องเรียนแรก'),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateClassroom() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateClassroomScreen()),
    );
  }

  void _navigateToClassroomDetail(Classroom classroom) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClassroomDetailScreen(classroom: classroom),
      ),
    );
  }

  void _copyClassroomCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('คัดลอกรหัส $code แล้ว'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteClassroom(Classroom classroom) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text(
          'ลบห้องเรียน?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'ต้องการลบห้องเรียน "${classroom.name}" หรือไม่?\nข้อมูลทั้งหมดจะถูกลบถาวร',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _classroomService.deleteClassroom(classroom.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ลบห้องเรียนแล้ว'),
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
  final VoidCallback onCopyCode;
  final VoidCallback onDelete;

  const _ClassroomCard({
    required this.classroom,
    required this.onTap,
    required this.onCopyCode,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1a1a2e),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: classroom.isActive ? Colors.cyan.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
        ),
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
                      color: Colors.cyan.withOpacity(0.1),
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
                          classroom.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (classroom.nameTh != classroom.name)
                          Text(
                            classroom.nameTh,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white54),
                    color: const Color(0xFF2a2a4e),
                    onSelected: (value) {
                      if (value == 'copy') {
                        onCopyCode();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'copy',
                        child: Row(
                          children: [
                            Icon(Icons.copy, color: Colors.white70, size: 20),
                            SizedBox(width: 8),
                            Text('คัดลอกรหัส', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('ลบห้องเรียน', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Join code
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.cyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.vpn_key, color: Colors.cyan, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'รหัสเข้าร่วม: ${classroom.code}',
                      style: const TextStyle(
                        color: Colors.cyan,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onCopyCode,
                      child: const Icon(Icons.copy, color: Colors.cyan, size: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Stats row
              Row(
                children: [
                  _StatItem(
                    icon: Icons.people,
                    label: 'นักเรียน',
                    value: '${classroom.studentCount}',
                  ),
                  const SizedBox(width: 24),
                  _StatItem(
                    icon: Icons.calendar_today,
                    label: 'สร้างเมื่อ',
                    value: _formatDate(classroom.createdAt),
                  ),
                ],
              ),
              if (classroom.description != null && classroom.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  classroom.description!,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 16),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

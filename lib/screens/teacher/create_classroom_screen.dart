// Create Classroom Screen
// Screen for teachers to create a new virtual classroom

import 'package:flutter/material.dart';
import '../../models/classroom_model.dart';
import '../../services/classroom_service.dart';
import '../../services/auth_service.dart';

class CreateClassroomScreen extends StatefulWidget {
  const CreateClassroomScreen({super.key});

  @override
  State<CreateClassroomScreen> createState() => _CreateClassroomScreenState();
}

class _CreateClassroomScreenState extends State<CreateClassroomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameThController = TextEditingController();
  final _descriptionController = TextEditingController();

  final ClassroomService _classroomService = ClassroomService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nameThController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text(
          'สร้างห้องเรียนใหม่',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.cyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.cyan),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'ระบบจะสร้างรหัสเข้าร่วม 6 หลักให้อัตโนมัติ\nนักเรียนใช้รหัสนี้ในการเข้าร่วมห้องเรียน',
                      style: TextStyle(color: Colors.cyan, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Name field
            _buildLabel('ชื่อห้องเรียน (ภาษาอังกฤษ)', isRequired: true),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                hintText: 'เช่น EW Training Class 1',
                prefixIcon: Icons.class_,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'กรุณากรอกชื่อห้องเรียน';
                }
                if (value.trim().length < 3) {
                  return 'ชื่อต้องมีอย่างน้อย 3 ตัวอักษร';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Thai name field
            _buildLabel('ชื่อห้องเรียน (ภาษาไทย)', isRequired: true),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameThController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                hintText: 'เช่น ห้องฝึกอบรม EW รุ่น 1',
                prefixIcon: Icons.translate,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'กรุณากรอกชื่อภาษาไทย';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description field
            _buildLabel('คำอธิบาย (ไม่บังคับ)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: _inputDecoration(
                hintText: 'รายละเอียดเพิ่มเติมเกี่ยวกับห้องเรียน...',
                prefixIcon: Icons.description,
              ),
            ),
            const SizedBox(height: 32),

            // Preview section
            _buildPreviewSection(),
            const SizedBox(height: 32),

            // Create button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createClassroom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'สร้างห้องเรียน',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(color: Colors.red),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIcon: Icon(prefixIcon, color: Colors.cyan),
      filled: true,
      fillColor: const Color(0xFF1a1a2e),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.cyan),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.preview, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text(
                'ตัวอย่างห้องเรียน',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.cyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.class_, color: Colors.cyan),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameController.text.isEmpty
                          ? 'ชื่อห้องเรียน'
                          : _nameController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _nameThController.text.isEmpty
                          ? 'ชื่อภาษาไทย'
                          : _nameThController.text,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.cyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.vpn_key, color: Colors.cyan, size: 16),
                SizedBox(width: 8),
                Text(
                  'รหัส: XXXXXX',
                  style: TextStyle(
                    color: Colors.cyan,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createClassroom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('ไม่พบข้อมูลผู้ใช้');
      }

      final classroom = Classroom(
        id: '',  // Will be set by Firestore
        name: _nameController.text.trim(),
        nameTh: _nameThController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        teacherId: user.uid,
        teacherName: user.displayName ?? user.email ?? 'ครู',
        code: '',  // Will be generated by service
        studentUids: [],
        isActive: true,
        createdAt: DateTime.now(),
      );

      final classroomId = await _classroomService.createClassroom(classroom);

      if (mounted) {
        // Show success with the generated code
        final createdClassroom = await _classroomService.getClassroom(classroomId);

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1a1a2e),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('สร้างสำเร็จ!', style: TextStyle(color: Colors.white)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'รหัสเข้าร่วมห้องเรียน:',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    createdClassroom?.code ?? 'N/A',
                    style: const TextStyle(
                      color: Colors.cyan,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'แจ้งรหัสนี้ให้นักเรียนเพื่อเข้าร่วมห้องเรียน',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);  // Close dialog
                  Navigator.pop(context);  // Go back to classroom list
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                child: const Text('ตกลง'),
              ),
            ],
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

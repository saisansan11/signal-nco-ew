// Assignment Editor Screen
// Screen for creating and editing assignments

import 'package:flutter/material.dart';
import '../../models/classroom_model.dart';
import '../../services/classroom_service.dart';
import '../../data/curriculum_data.dart';

class AssignmentEditorScreen extends StatefulWidget {
  final String classroomId;
  final Assignment? existingAssignment;

  const AssignmentEditorScreen({
    super.key,
    required this.classroomId,
    this.existingAssignment,
  });

  @override
  State<AssignmentEditorScreen> createState() => _AssignmentEditorScreenState();
}

class _AssignmentEditorScreenState extends State<AssignmentEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _titleThController = TextEditingController();
  final _descriptionController = TextEditingController();

  final ClassroomService _classroomService = ClassroomService();

  AssignmentType _selectedType = AssignmentType.lesson;
  String? _selectedContentId;
  DateTime? _dueDate;
  bool _isRequired = true;
  int? _maxAttempts;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingAssignment != null) {
      final assignment = widget.existingAssignment!;
      _titleController.text = assignment.title;
      _titleThController.text = assignment.titleTh;
      _descriptionController.text = assignment.description ?? '';
      _selectedType = assignment.type;
      _selectedContentId = assignment.contentId;
      _dueDate = assignment.dueDate;
      _isRequired = assignment.isRequired;
      _maxAttempts = assignment.maxAttempts;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleThController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingAssignment != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Text(
          isEditing ? 'แก้ไขงาน' : 'มอบหมายงานใหม่',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveAssignment,
            child: Text(
              isEditing ? 'บันทึก' : 'สร้าง',
              style: TextStyle(
                color: _isLoading ? Colors.grey : Colors.cyan,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Assignment type selector
            _buildSectionTitle('ประเภทงาน'),
            const SizedBox(height: 8),
            _buildTypeSelector(),
            const SizedBox(height: 24),

            // Content selector
            _buildSectionTitle('เลือกเนื้อหา'),
            const SizedBox(height: 8),
            _buildContentSelector(),
            const SizedBox(height: 24),

            // Title fields
            _buildSectionTitle('ชื่องาน'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _titleController,
              hint: 'ชื่องาน (ภาษาอังกฤษ)',
              icon: Icons.title,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'กรุณากรอกชื่องาน';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _titleThController,
              hint: 'ชื่องาน (ภาษาไทย)',
              icon: Icons.translate,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'กรุณากรอกชื่อภาษาไทย';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Description
            _buildSectionTitle('คำอธิบาย (ไม่บังคับ)'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _descriptionController,
              hint: 'คำแนะนำหรือรายละเอียดเพิ่มเติม...',
              icon: Icons.description,
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Due date
            _buildSectionTitle('กำหนดส่ง'),
            const SizedBox(height: 8),
            _buildDueDateSelector(),
            const SizedBox(height: 24),

            // Options
            _buildSectionTitle('ตัวเลือก'),
            const SizedBox(height: 8),
            _buildOptions(),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveAssignment,
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
                    : Text(
                        isEditing ? 'บันทึกการเปลี่ยนแปลง' : 'สร้างงานมอบหมาย',
                        style: const TextStyle(
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AssignmentType.values.map((type) {
        final isSelected = _selectedType == type;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedType = type;
              _selectedContentId = null;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? _getTypeColor(type).withValues(alpha: 0.2)
                  : const Color(0xFF1a1a2e),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? _getTypeColor(type)
                    : Colors.white.withValues(alpha: 0.1),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getTypeIcon(type),
                  color: isSelected ? _getTypeColor(type) : Colors.white54,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  type.thaiName,
                  style: TextStyle(
                    color: isSelected ? _getTypeColor(type) : Colors.white54,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContentSelector() {
    final contentList = _getContentList();

    if (contentList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a2e),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'ไม่มีเนื้อหาสำหรับประเภทนี้',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: contentList.length,
        separatorBuilder: (context, index) => Divider(
          color: Colors.white.withValues(alpha: 0.1),
          height: 1,
        ),
        itemBuilder: (context, index) {
          final content = contentList[index];
          final isSelected = _selectedContentId == content['id'];

          return ListTile(
            onTap: () {
              setState(() {
                _selectedContentId = content['id'];
                if (_titleController.text.isEmpty) {
                  _titleController.text = content['title'] ?? '';
                }
                if (_titleThController.text.isEmpty) {
                  _titleThController.text = content['titleTh'] ?? '';
                }
              });
            },
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.cyan.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                content['icon'] ?? Icons.article,
                color: isSelected ? Colors.cyan : Colors.white54,
                size: 20,
              ),
            ),
            title: Text(
              content['title'] ?? 'ไม่มีชื่อ',
              style: TextStyle(
                color: isSelected ? Colors.cyan : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              content['titleTh'] ?? '',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Colors.cyan)
                : null,
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getContentList() {
    switch (_selectedType) {
      case AssignmentType.lesson:
        return CurriculumData.allModules.map((module) {
          return {
            'id': module.id,
            'title': 'บทที่ ${module.moduleNumber + 1}',
            'titleTh': module.titleTh,
            'icon': Icons.menu_book,
          };
        }).toList();

      case AssignmentType.quiz:
        // Return quizzes from each module
        final quizzes = <Map<String, dynamic>>[];
        for (final module in CurriculumData.allModules) {
          quizzes.add({
            'id': 'quiz_${module.id}',
            'title': 'Quiz บทที่ ${module.moduleNumber + 1}',
            'titleTh': 'แบบทดสอบ ${module.titleTh}',
            'icon': Icons.quiz,
          });
        }
        return quizzes;

      case AssignmentType.campaign:
        return [
          {
            'id': 'campaign_sigint',
            'title': 'SIGINT Collection',
            'titleTh': 'ภารกิจรวบรวม SIGINT',
            'icon': Icons.radar,
          },
          {
            'id': 'campaign_jamming',
            'title': 'Jamming Operation',
            'titleTh': 'ภารกิจรบกวนสัญญาณ',
            'icon': Icons.wifi_off,
          },
          {
            'id': 'campaign_defense',
            'title': 'EW Defense',
            'titleTh': 'ภารกิจป้องกัน EW',
            'icon': Icons.shield,
          },
        ];

      case AssignmentType.simulation:
        return [
          {
            'id': 'sim_spectrum',
            'title': 'Spectrum Analyzer',
            'titleTh': 'จำลองวิเคราะห์สเปกตรัม',
            'icon': Icons.show_chart,
          },
          {
            'id': 'sim_radar',
            'title': 'Radar Simulator',
            'titleTh': 'จำลองเรดาร์',
            'icon': Icons.radar,
          },
          {
            'id': 'sim_jamming',
            'title': 'Jamming Simulator',
            'titleTh': 'จำลองการรบกวน',
            'icon': Icons.wifi_off,
          },
          {
            'id': 'sim_df',
            'title': 'Direction Finding',
            'titleTh': 'จำลองหาทิศทาง',
            'icon': Icons.explore,
          },
        ];
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.cyan),
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
      ),
      validator: validator,
    );
  }

  Widget _buildDueDateSelector() {
    return GestureDetector(
      onTap: _selectDueDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a2e),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.cyan),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _dueDate != null
                    ? _formatDate(_dueDate!)
                    : 'ไม่กำหนดวันส่ง',
                style: TextStyle(
                  color: _dueDate != null ? Colors.white : Colors.white54,
                ),
              ),
            ),
            if (_dueDate != null)
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.white54),
                onPressed: () => setState(() => _dueDate = null),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.cyan,
              onPrimary: Colors.white,
              surface: Color(0xFF1a1a2e),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 23, minute: 59),
        builder: (ctx, child) {
          return Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Colors.cyan,
                onPrimary: Colors.white,
                surface: Color(0xFF1a1a2e),
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (mounted) {
        setState(() {
          _dueDate = DateTime(
            date.year,
            date.month,
            date.day,
            time?.hour ?? 23,
            time?.minute ?? 59,
          );
        });
      }
    }
  }

  Widget _buildOptions() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('งานบังคับ', style: TextStyle(color: Colors.white)),
            subtitle: const Text(
              'นักเรียนต้องทำงานนี้',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            value: _isRequired,
            onChanged: (value) => setState(() => _isRequired = value),
            activeTrackColor: Colors.cyan,
          ),
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          ListTile(
            title: const Text('จำนวนครั้งที่ทำได้', style: TextStyle(color: Colors.white)),
            subtitle: const Text(
              'จำกัดจำนวนครั้งที่นักเรียนทำได้',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            trailing: DropdownButton<int?>(
              value: _maxAttempts,
              dropdownColor: const Color(0xFF2a2a4e),
              style: const TextStyle(color: Colors.white),
              underline: const SizedBox(),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('ไม่จำกัด'),
                ),
                ...[1, 2, 3, 5, 10].map((n) => DropdownMenuItem(
                  value: n,
                  child: Text('$n ครั้ง'),
                )),
              ],
              onChanged: (value) => setState(() => _maxAttempts = value),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAssignment() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedContentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกเนื้อหา'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final assignment = Assignment(
        id: widget.existingAssignment?.id ?? '',
        classroomId: widget.classroomId,
        title: _titleController.text.trim(),
        titleTh: _titleThController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        type: _selectedType,
        contentId: _selectedContentId!,
        dueDate: _dueDate,
        isRequired: _isRequired,
        maxAttempts: _maxAttempts,
        createdAt: widget.existingAssignment?.createdAt ?? DateTime.now(),
      );

      if (widget.existingAssignment != null) {
        await _classroomService.updateAssignment(assignment);
      } else {
        await _classroomService.createAssignment(assignment);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingAssignment != null
                  ? 'บันทึกการเปลี่ยนแปลงแล้ว'
                  : 'สร้างงานมอบหมายแล้ว',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

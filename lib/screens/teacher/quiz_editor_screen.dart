// Quiz Editor Screen
// Screen for teachers to create and edit custom quizzes

import 'package:flutter/material.dart';
import '../../models/custom_quiz_model.dart';
import '../../services/content_service.dart';
import '../../services/auth_service.dart';

class QuizEditorScreen extends StatefulWidget {
  final CustomQuiz? existingQuiz;
  final String? classroomId;

  const QuizEditorScreen({
    super.key,
    this.existingQuiz,
    this.classroomId,
  });

  @override
  State<QuizEditorScreen> createState() => _QuizEditorScreenState();
}

class _QuizEditorScreenState extends State<QuizEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _titleThController = TextEditingController();
  final _descriptionController = TextEditingController();

  final ContentService _contentService = ContentService();
  final AuthService _authService = AuthService();

  List<CustomQuestion> _questions = [];
  int _timeLimitMinutes = 30;
  int _passingScore = 60;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingQuiz != null) {
      final quiz = widget.existingQuiz!;
      _titleController.text = quiz.title;
      _titleThController.text = quiz.titleTh;
      _descriptionController.text = quiz.description ?? '';
      _questions = List.from(quiz.questions);
      _timeLimitMinutes = quiz.timeLimitMinutes;
      _passingScore = quiz.passingScore;
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
    final isEditing = widget.existingQuiz != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Text(
          isEditing ? 'แก้ไขแบบทดสอบ' : 'สร้างแบบทดสอบใหม่',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => _confirmExit(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveQuiz,
            child: Text(
              'บันทึก',
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
            // Quiz info section
            _buildSectionTitle('ข้อมูลแบบทดสอบ'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _titleController,
              label: 'ชื่อแบบทดสอบ (ภาษาอังกฤษ)',
              hint: 'e.g., ESM Fundamentals Quiz',
              validator: (v) => v?.isEmpty == true ? 'กรุณากรอกชื่อ' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _titleThController,
              label: 'ชื่อแบบทดสอบ (ภาษาไทย)',
              hint: 'เช่น แบบทดสอบ ESM พื้นฐาน',
              validator: (v) => v?.isEmpty == true ? 'กรุณากรอกชื่อภาษาไทย' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _descriptionController,
              label: 'คำอธิบาย (ไม่บังคับ)',
              hint: 'คำอธิบายเพิ่มเติมเกี่ยวกับแบบทดสอบ',
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Settings section
            _buildSectionTitle('การตั้งค่า'),
            const SizedBox(height: 12),
            _buildSettingsCard(),
            const SizedBox(height: 24),

            // Questions section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('คำถาม (${_questions.length} ข้อ)'),
                IconButton(
                  onPressed: _addQuestion,
                  icon: const Icon(Icons.add_circle, color: Colors.cyan),
                  tooltip: 'เพิ่มคำถาม',
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_questions.isEmpty)
              _buildEmptyQuestions()
            else
              ..._questions.asMap().entries.map((entry) {
                return _QuestionCard(
                  question: entry.value,
                  index: entry.key,
                  onEdit: () => _editQuestion(entry.key),
                  onDelete: () => _deleteQuestion(entry.key),
                  onMoveUp: entry.key > 0 ? () => _moveQuestion(entry.key, -1) : null,
                  onMoveDown: entry.key < _questions.length - 1
                      ? () => _moveQuestion(entry.key, 1)
                      : null,
                );
              }),

            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _addQuestion,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.cyan,
                side: const BorderSide(color: Colors.cyan),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.add),
              label: const Text('เพิ่มคำถาม'),
            ),
            const SizedBox(height: 32),
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
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
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
      ),
      validator: validator,
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      color: const Color(0xFF1a1a2e),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Time limit
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.cyan),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'เวลาจำกัด',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DropdownButton<int>(
                  value: _timeLimitMinutes,
                  dropdownColor: const Color(0xFF2a2a4e),
                  style: const TextStyle(color: Colors.white),
                  underline: const SizedBox(),
                  items: [10, 15, 20, 30, 45, 60, 90, 120].map((m) {
                    return DropdownMenuItem(
                      value: m,
                      child: Text('$m นาที'),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _timeLimitMinutes = v!),
                ),
              ],
            ),
            const Divider(color: Colors.white24),
            // Passing score
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'คะแนนผ่าน',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DropdownButton<int>(
                  value: _passingScore,
                  dropdownColor: const Color(0xFF2a2a4e),
                  style: const TextStyle(color: Colors.white),
                  underline: const SizedBox(),
                  items: [50, 60, 70, 80, 90].map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text('$s%'),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _passingScore = v!),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyQuestions() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 48,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'ยังไม่มีคำถาม',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'กดปุ่มด้านล่างเพื่อเพิ่มคำถาม',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  void _addQuestion() async {
    final result = await Navigator.push<CustomQuestion>(
      context,
      MaterialPageRoute(
        builder: (context) => const _QuestionEditorScreen(),
      ),
    );

    if (result != null) {
      setState(() => _questions.add(result));
    }
  }

  void _editQuestion(int index) async {
    final result = await Navigator.push<CustomQuestion>(
      context,
      MaterialPageRoute(
        builder: (context) => _QuestionEditorScreen(
          existingQuestion: _questions[index],
        ),
      ),
    );

    if (result != null) {
      setState(() => _questions[index] = result);
    }
  }

  void _deleteQuestion(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('ลบคำถาม?', style: TextStyle(color: Colors.white)),
        content: Text(
          'ต้องการลบคำถามข้อที่ ${index + 1}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _questions.removeAt(index));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  void _moveQuestion(int index, int direction) {
    setState(() {
      final item = _questions.removeAt(index);
      _questions.insert(index + direction, item);
    });
  }

  void _confirmExit() {
    if (_questions.isNotEmpty || _titleController.text.isNotEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1a1a2e),
          title: const Text('ออกจากหน้านี้?', style: TextStyle(color: Colors.white)),
          content: const Text(
            'การเปลี่ยนแปลงที่ยังไม่บันทึกจะหายไป',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('อยู่ต่อ'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('ออก'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเพิ่มอย่างน้อย 1 คำถาม'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('ไม่พบข้อมูลผู้ใช้');

      final quiz = CustomQuiz(
        id: widget.existingQuiz?.id ?? '',
        title: _titleController.text.trim(),
        titleTh: _titleThController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        createdBy: user.uid,
        createdByName: user.displayName ?? user.email ?? 'ครู',
        questions: _questions,
        isPublished: widget.existingQuiz?.isPublished ?? false,
        timeLimitMinutes: _timeLimitMinutes,
        passingScore: _passingScore,
        assignedClassroomId: widget.classroomId,
        createdAt: widget.existingQuiz?.createdAt ?? DateTime.now(),
      );

      if (widget.existingQuiz != null) {
        await _contentService.updateQuiz(quiz);
      } else {
        await _contentService.createQuiz(quiz);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingQuiz != null
                  ? 'บันทึกการเปลี่ยนแปลงแล้ว'
                  : 'สร้างแบบทดสอบแล้ว',
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
}

// Question Card Widget
class _QuestionCard extends StatelessWidget {
  final CustomQuestion question;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  const _QuestionCard({
    required this.question,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    this.onMoveUp,
    this.onMoveDown,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.cyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.question,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _TypeChip(type: question.type),
                          const SizedBox(width: 8),
                          Text(
                            '${question.points} คะแนน',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onMoveUp != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_upward, color: Colors.white54, size: 20),
                    onPressed: onMoveUp,
                  ),
                if (onMoveDown != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_downward, color: Colors.white54, size: 20),
                    onPressed: onMoveDown,
                  ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.cyan, size: 20),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final QuestionType type;

  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.thaiName,
        style: TextStyle(color: _getColor(), fontSize: 11),
      ),
    );
  }

  Color _getColor() {
    switch (type) {
      case QuestionType.multipleChoice:
        return Colors.blue;
      case QuestionType.trueFalse:
        return Colors.green;
      case QuestionType.fillBlank:
        return Colors.orange;
    }
  }
}

// Question Editor Screen
class _QuestionEditorScreen extends StatefulWidget {
  final CustomQuestion? existingQuestion;

  const _QuestionEditorScreen({this.existingQuestion});

  @override
  State<_QuestionEditorScreen> createState() => _QuestionEditorScreenState();
}

class _QuestionEditorScreenState extends State<_QuestionEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _questionThController = TextEditingController();
  final _explanationController = TextEditingController();
  final _explanationThController = TextEditingController();
  final _correctAnswerTextController = TextEditingController();

  QuestionType _type = QuestionType.multipleChoice;
  List<TextEditingController> _optionControllers = [];
  int _correctAnswerIndex = 0;
  int _points = 1;

  @override
  void initState() {
    super.initState();
    if (widget.existingQuestion != null) {
      final q = widget.existingQuestion!;
      _questionController.text = q.question;
      _questionThController.text = q.questionTh ?? '';
      _explanationController.text = q.explanation ?? '';
      _explanationThController.text = q.explanationTh ?? '';
      _correctAnswerTextController.text = q.correctAnswerText ?? '';
      _type = q.type;
      _correctAnswerIndex = q.correctAnswerIndex;
      _points = q.points;
      _optionControllers = q.options.map((o) => TextEditingController(text: o)).toList();
    } else {
      // Default 4 options for multiple choice
      _optionControllers = List.generate(4, (_) => TextEditingController());
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _questionThController.dispose();
    _explanationController.dispose();
    _explanationThController.dispose();
    _correctAnswerTextController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Text(
          widget.existingQuestion != null ? 'แก้ไขคำถาม' : 'เพิ่มคำถาม',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _saveQuestion,
            child: const Text(
              'บันทึก',
              style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Question type
            const Text(
              'ประเภทคำถาม',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTypeSelector(),
            const SizedBox(height: 24),

            // Question text
            const Text(
              'คำถาม',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _questionController,
              hint: 'ใส่คำถาม...',
              maxLines: 3,
              validator: (v) => v?.isEmpty == true ? 'กรุณากรอกคำถาม' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _questionThController,
              hint: 'คำถามภาษาไทย (ไม่บังคับ)',
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Answer section based on type
            if (_type == QuestionType.multipleChoice) ...[
              _buildMultipleChoiceSection(),
            ] else if (_type == QuestionType.trueFalse) ...[
              _buildTrueFalseSection(),
            ] else if (_type == QuestionType.fillBlank) ...[
              _buildFillBlankSection(),
            ],

            const SizedBox(height: 24),

            // Points
            Row(
              children: [
                const Text(
                  'คะแนน',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.white54),
                  onPressed: _points > 1 ? () => setState(() => _points--) : null,
                ),
                Text(
                  '$_points',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.cyan),
                  onPressed: _points < 10 ? () => setState(() => _points++) : null,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Explanation
            const Text(
              'คำอธิบาย (ไม่บังคับ)',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _explanationController,
              hint: 'อธิบายคำตอบที่ถูกต้อง...',
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _explanationThController,
              hint: 'คำอธิบายภาษาไทย...',
              maxLines: 2,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: 8,
      children: QuestionType.values.map((type) {
        final isSelected = _type == type;
        return ChoiceChip(
          label: Text(type.thaiName),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _type = type;
                if (type == QuestionType.trueFalse) {
                  _optionControllers = [
                    TextEditingController(text: 'ถูก'),
                    TextEditingController(text: 'ผิด'),
                  ];
                } else if (type == QuestionType.multipleChoice &&
                    _optionControllers.length != 4) {
                  _optionControllers = List.generate(4, (_) => TextEditingController());
                }
              });
            }
          },
          selectedColor: Colors.cyan,
          backgroundColor: const Color(0xFF1a1a2e),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
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
        filled: true,
        fillColor: const Color(0xFF1a1a2e),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.cyan),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildMultipleChoiceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ตัวเลือก',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            if (_optionControllers.length < 6)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _optionControllers.add(TextEditingController());
                  });
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('เพิ่มตัวเลือก'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(_optionControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Radio<int>(
                  value: index,
                  groupValue: _correctAnswerIndex,
                  onChanged: (v) => setState(() => _correctAnswerIndex = v!),
                  activeColor: Colors.green,
                ),
                Expanded(
                  child: TextFormField(
                    controller: _optionControllers[index],
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'ตัวเลือก ${index + 1}',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: _correctAnswerIndex == index
                          ? Colors.green.withValues(alpha: 0.1)
                          : const Color(0xFF1a1a2e),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) =>
                        v?.isEmpty == true ? 'กรุณากรอกตัวเลือก' : null,
                  ),
                ),
                if (_optionControllers.length > 2)
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
                    onPressed: () {
                      setState(() {
                        _optionControllers.removeAt(index);
                        if (_correctAnswerIndex >= _optionControllers.length) {
                          _correctAnswerIndex = _optionControllers.length - 1;
                        }
                      });
                    },
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        Text(
          'เลือกตัวเลือกที่ถูกต้องด้วยปุ่มวงกลม',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTrueFalseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'คำตอบที่ถูกต้อง',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _AnswerButton(
                label: 'ถูก',
                isSelected: _correctAnswerIndex == 0,
                color: Colors.green,
                onTap: () => setState(() => _correctAnswerIndex = 0),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _AnswerButton(
                label: 'ผิด',
                isSelected: _correctAnswerIndex == 1,
                color: Colors.red,
                onTap: () => setState(() => _correctAnswerIndex = 1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFillBlankSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'คำตอบที่ถูกต้อง',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _correctAnswerTextController,
          hint: 'พิมพ์คำตอบที่ถูกต้อง...',
          validator: (v) => v?.isEmpty == true ? 'กรุณากรอกคำตอบ' : null,
        ),
        const SizedBox(height: 8),
        Text(
          'ระบบจะตรวจสอบโดยไม่สนใจตัวพิมพ์ใหญ่/เล็ก',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
        ),
      ],
    );
  }

  void _saveQuestion() {
    if (!_formKey.currentState!.validate()) return;

    final options = _type == QuestionType.multipleChoice
        ? _optionControllers.map((c) => c.text.trim()).toList()
        : _type == QuestionType.trueFalse
            ? ['ถูก', 'ผิด']
            : <String>[];

    final question = CustomQuestion(
      id: widget.existingQuestion?.id ?? 'q_${DateTime.now().millisecondsSinceEpoch}',
      question: _questionController.text.trim(),
      questionTh: _questionThController.text.trim().isEmpty
          ? null
          : _questionThController.text.trim(),
      type: _type,
      options: options,
      correctAnswerIndex: _correctAnswerIndex,
      correctAnswerText: _type == QuestionType.fillBlank
          ? _correctAnswerTextController.text.trim()
          : null,
      explanation: _explanationController.text.trim().isEmpty
          ? null
          : _explanationController.text.trim(),
      explanationTh: _explanationThController.text.trim().isEmpty
          ? null
          : _explanationThController.text.trim(),
      points: _points,
    );

    Navigator.pop(context, question);
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : const Color(0xFF1a1a2e),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Colors.white54,
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

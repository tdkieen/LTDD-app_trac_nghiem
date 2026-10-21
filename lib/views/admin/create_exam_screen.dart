import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../models/de_thi.dart';
import '../../providers/quiz_provider.dart';

class CreateExamScreen extends StatefulWidget {
  final DeThi? editingExam;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  const CreateExamScreen({
    super.key,
    this.editingExam,
    required this.onSaved,
    required this.onCancel,
  });

  @override
  State<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _durationController;
  late TextEditingController _questionCountController;
  int? _selectedCategory;
  String _selectedDifficulty = 'Trung bình';

  @override
  void initState() {
    super.initState();
    final exam = widget.editingExam;
    _titleController = TextEditingController(text: exam?.tenDeThi ?? '');
    _durationController = TextEditingController(text: (exam?.thoiGian ?? 15).toString());
    _questionCountController = TextEditingController(text: (exam?.soCauHoi ?? 10).toString());
    _selectedCategory = exam?.maChuDe;
    _selectedDifficulty = exam?.mucDoKho ?? 'Trung bình';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _questionCountController.dispose();
    super.dispose();
  }

  void _saveExam() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn chủ đề cho đề thi!')),
      );
      return;
    }

    final quiz = context.read<QuizProvider>();
    final duration = int.tryParse(_durationController.text.trim()) ?? 15;
    final qCount = int.tryParse(_questionCountController.text.trim()) ?? 10;

    if (widget.editingExam != null) {
      // Edit mode
      final updated = widget.editingExam!.copyWith(
        tenDeThi: _titleController.text.trim(),
        maChuDe: _selectedCategory!,
        mucDoKho: _selectedDifficulty,
        thoiGian: duration,
        soCauHoi: qCount,
      );
      quiz.updateExam(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật đề thi thành công!')),
      );
    } else {
      // Create mode
      quiz.addExam(
        tenDeThi: _titleController.text.trim(),
        maChuDe: _selectedCategory!,
        mucDoKho: _selectedDifficulty,
        thoiGian: duration,
        soCauHoi: qCount,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tạo mới đề thi thành công!')),
      );
    }

    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final categories = quiz.getCategories();
    final isMobile = ResponsiveLayout.isMobile(context);
    final isEdit = widget.editingExam != null;

    if (_selectedCategory == null && categories.isNotEmpty) {
      _selectedCategory = categories.first.maChuDe;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(color: Color(0x06000000), blurRadius: 16, offset: Offset(0, 4)),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isEdit ? Icons.edit_note : Icons.add_circle,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEdit ? 'Chỉnh Sửa Đề Thi' : 'Tạo Đề Thi Trắc Nghiệm Mới',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              isEdit ? 'Cập nhật lại các thông số của bài thi' : 'Thiết lập thông số đề thi cho học viên làm bài',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Title field
                  const Text('Tên đề thi *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tên đề thi (ví dụ: Luyện thi ngữ pháp TOEIC Part 5)',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Vui lòng nhập tên đề thi';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Category & Difficulty Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Chủ đề môn học *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              initialValue: _selectedCategory,
                              decoration: const InputDecoration(),
                              items: categories.map((cat) {
                                return DropdownMenuItem(
                                  value: cat.maChuDe,
                                  child: Text(cat.tenChuDe),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedCategory = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Mức độ khó', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedDifficulty,
                              decoration: const InputDecoration(),
                              items: ['Dễ', 'Trung bình', 'Khó'].map((diff) {
                                return DropdownMenuItem(
                                  value: diff,
                                  child: Text(diff),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedDifficulty = val;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Duration & Target Question count Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Thời gian thi (phút) *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _durationController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Ví dụ: 15',
                                suffixText: 'phút',
                              ),
                              validator: (val) {
                                final n = int.tryParse(val ?? '');
                                if (n == null || n <= 0) return 'Thời gian phải lớn hơn 0';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Số lượng câu hỏi mục tiêu *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _questionCountController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Ví dụ: 10',
                                suffixText: 'câu',
                              ),
                              validator: (val) {
                                final n = int.tryParse(val ?? '');
                                if (n == null || n <= 0) return 'Số câu phải lớn hơn 0';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: widget.onCancel,
                        child: const Text('Hủy bỏ'),
                      ),
                      const SizedBox(width: 14),
                      ElevatedButton.icon(
                        onPressed: _saveExam,
                        icon: const Icon(Icons.check, size: 18),
                        label: Text(isEdit ? 'Lưu thay đổi' : 'Tạo đề thi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../models/de_thi.dart';
import '../../providers/quiz_provider.dart';

/// Màn hình Tạo / Chỉnh Sửa Đề Thi Trắc Nghiệm (QUẢN LÝ)
/// Thiết kế tối giản, sạch sẽ, nhập liệu nhanh và thuận tiện
class CreateExamScreen extends StatefulWidget {
  final DeThi? editingExam;
  final VoidCallback onSaved;
  final VoidCallback onCancel;
  final ValueChanged<int>? onManageQuestions;

  const CreateExamScreen({
    super.key,
    this.editingExam,
    required this.onSaved,
    required this.onCancel,
    this.onManageQuestions,
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

  /// Hàm lưu đề thi (Thêm mới hoặc Cập nhật)
  Future<void> _saveExam() async {
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
      // 1. Chế độ Chỉnh sửa đề cũ
      final updated = widget.editingExam!.copyWith(
        tenDeThi: _titleController.text.trim(),
        maChuDe: _selectedCategory!,
        mucDoKho: _selectedDifficulty,
        thoiGian: duration,
        soCauHoi: qCount,
      );
      await quiz.updateExam(updated);
      if (!mounted) return;
      if (quiz.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(quiz.errorMessage!), backgroundColor: AppColors.danger),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật đề thi thành công!')),
        );
      }
      widget.onSaved();
    } else {
      // 2. Chế độ Tạo đề mới
      final created = await quiz.addExam(
        tenDeThi: _titleController.text.trim(),
        maChuDe: _selectedCategory!,
        mucDoKho: _selectedDifficulty,
        thoiGian: duration,
        soCauHoi: qCount,
      );
      if (!mounted) return;
      if (quiz.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(quiz.errorMessage!), backgroundColor: AppColors.danger),
        );
      }

      // Mở hộp thoại hỏi có muốn thêm câu hỏi ngay không
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
              SizedBox(width: 10),
              Text('Tạo đề thi thành công!'),
            ],
          ),
          content: Text(
            'Đề thi "${created.tenDeThi}" đã được tạo thành công.\n\nBạn có muốn chuyển sang thêm câu hỏi cho đề này ngay bây giờ không?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                widget.onSaved();
              },
              child: const Text('Để sau (Về danh sách)', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                if (widget.onManageQuestions != null) {
                  widget.onManageQuestions!(created.maDeThi);
                } else {
                  widget.onSaved();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              icon: const Icon(Icons.add_task_rounded, size: 18),
              label: const Text('Thêm câu hỏi ngay'),
            ),
          ],
        ),
      );
    }
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
          constraints: const BoxConstraints(maxWidth: 750),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(isEdit),

              const SizedBox(height: 20),

              // Khung biểu mẫu chính
              Container(
                padding: EdgeInsets.all(isMobile ? 18 : 28),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x060F172A),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Tên đề thi
                      const Text(
                        'Tên đề thi *',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        autofocus: !isEdit,
                        decoration: InputDecoration(
                          hintText: 'Ví dụ: Kiểm tra 15 phút Lịch Sử Việt Nam...',
                          prefixIcon: const Icon(Icons.assignment_outlined, color: AppColors.primary),
                          filled: true,
                          fillColor: AppColors.surfaceSubtle,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Vui lòng nhập tên đề thi!';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // 2. Chủ đề môn học
                      const Text(
                        'Chủ đề môn học *',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedCategory,
                        isExpanded: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.category_outlined, color: AppColors.primary),
                          filled: true,
                          fillColor: AppColors.surfaceSubtle,
                        ),
                        items: categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat.maChuDe,
                            child: Text(cat.tenChuDe, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedCategory = val),
                      ),

                      const SizedBox(height: 20),

                      // 3. Mức độ khó (Chọn nhanh: Dễ - Trung bình - Khó)
                      const Text(
                        'Mức độ khó',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      _buildDifficultySelector(),

                      const SizedBox(height: 20),

                      // 4. Thời gian thi & Số câu hỏi
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Thời gian (phút) *',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _durationController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: '15',
                                    suffixText: 'phút',
                                    prefixIcon: const Icon(Icons.timer_outlined, color: AppColors.primary),
                                    filled: true,
                                    fillColor: AppColors.surfaceSubtle,
                                  ),
                                  validator: (val) {
                                    final n = int.tryParse(val ?? '');
                                    if (n == null || n <= 0) return 'Thời gian > 0';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Số câu hỏi mục tiêu *',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _questionCountController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: '10',
                                    suffixText: 'câu',
                                    prefixIcon: const Icon(Icons.format_list_bulleted, color: AppColors.primary),
                                    filled: true,
                                    fillColor: AppColors.surfaceSubtle,
                                  ),
                                  validator: (val) {
                                    final n = int.tryParse(val ?? '');
                                    if (n == null || n <= 0) return 'Số câu > 0';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),
                      const Divider(color: AppColors.borderLight, height: 1),
                      const SizedBox(height: 20),

                      // 5. Nút Thao tác Lưu / Hủy
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: widget.onCancel,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              side: const BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Hủy bỏ'),
                          ),
                          ElevatedButton.icon(
                            onPressed: _saveExam,
                            icon: const Icon(Icons.check_rounded, size: 18),
                            label: Text(isEdit ? 'Lưu thay đổi' : 'Tạo đề thi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- CÁC HÀM PHỤ TRỢ ---

  Widget _buildHeader(bool isEdit) {
    return Row(
      children: [
        InkWell(
          onTap: widget.onCancel,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      isEdit ? 'Chỉnh Sửa Đề Thi' : 'Tạo Đề Thi Mới',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(isEdit ? '✏️' : '📝', style: const TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                isEdit ? 'Cập nhật lại thông số cho đề thi' : 'Thiết lập các thông số cơ bản cho đề thi trắc nghiệm',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Bộ nút chọn nhanh độ khó (Dễ - Xanh lá, Trung bình - Cam, Khó - Đỏ)
  Widget _buildDifficultySelector() {
    final options = [
      {'label': 'Dễ', 'color': AppColors.success, 'softColor': AppColors.successSoft},
      {'label': 'Trung bình', 'color': AppColors.warning, 'softColor': AppColors.warningSoft},
      {'label': 'Khó', 'color': AppColors.danger, 'softColor': AppColors.dangerSoft},
    ];

    return Row(
      children: options.map((opt) {
        final label = opt['label'] as String;
        final color = opt['color'] as Color;
        final softColor = opt['softColor'] as Color;
        final isSelected = _selectedDifficulty == label;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => setState(() => _selectedDifficulty = label),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? softColor : AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 13,
                      color: isSelected ? color : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

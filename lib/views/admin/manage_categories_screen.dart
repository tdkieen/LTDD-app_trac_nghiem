import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/quiz_provider.dart';

/// Màn hình Quản Lý Danh Mục Chủ Đề (QUẢN LÝ)
/// Thiết kế tối giản, sạch sẽ, dễ dàng thêm và quản lý các môn học
class ManageCategoriesScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ManageCategoriesScreen({super.key, required this.onBack});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _catNameCtrl = TextEditingController();

  @override
  void dispose() {
    _catNameCtrl.dispose();
    super.dispose();
  }

  /// Hàm thêm chủ đề mới
  Future<void> _addCategory() async {
    final text = _catNameCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên chủ đề / môn học!')),
      );
      return;
    }

    final quiz = context.read<QuizProvider>();
    final success = await quiz.addCategory(text);
    if (!mounted) return;
    if (success) {
      _catNameCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã thêm chủ đề "$text" thành công!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(quiz.errorMessage ?? 'Chủ đề này đã tồn tại trong hệ thống!')),
      );
    }
  }

  /// Hàm xác nhận và xóa chủ đề
  void _confirmDeleteCategory(dynamic cat, int examCount) {
    if (examCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể xóa! Chủ đề "${cat.tenChuDe}" đang có $examCount đề thi liên kết.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa chủ đề?'),
        content: Text('Bạn có chắc chắn muốn xóa chủ đề "${cat.tenChuDe}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<QuizProvider>().deleteCategory(cat.maChuDe);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa chủ đề "${cat.tenChuDe}".')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Xóa chủ đề'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final isMobile = ResponsiveLayout.isMobile(context);
    final categories = quiz.getCategories();
    final allExams = quiz.getAllExams();

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tiêu đề và nút quay lại
              _buildHeader(),

              const SizedBox(height: 24),

              // 2. Khung thêm chủ đề nhanh
              _buildAddCategoryBox(isMobile),

              const SizedBox(height: 24),

              // 3. Tiêu đề danh sách
              Row(
                children: [
                  const Icon(Icons.category_outlined, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Danh Sách Các Môn Học & Chủ Đề (${categories.length})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 4. Danh sách các chủ đề
              if (categories.isEmpty)
                _buildEmptyState()
              else
                _buildCategoryList(categories, allExams),
            ],
          ),
        ),
      ),
    );
  }

  // --- CÁC HÀM XÂY DỰNG GIAO DIỆN CON ---

  /// Header trên cùng
  Widget _buildHeader() {
    return Row(
      children: [
        InkWell(
          onTap: widget.onBack,
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
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Quản Lý Danh Mục Chủ Đề',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('📚', style: TextStyle(fontSize: 20)),
                ],
              ),
              SizedBox(height: 2),
              Text(
                'Phân loại đề thi theo từng môn học và lĩnh vực kiến thức',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Khung nhập để thêm chủ đề mới
  Widget _buildAddCategoryBox(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'THÊM CHỦ ĐỀ MỚI',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _catNameCtrl,
                  decoration: InputDecoration(
                    hintText: 'Nhập tên môn học / chủ đề (ví dụ: Lịch sử, Tin học...)',
                    prefixIcon: const Icon(Icons.add_task, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.surfaceSubtle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onSubmitted: (_) => _addCategory(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _addCategory,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Thêm chủ đề'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 14 : 20,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Danh sách các chủ đề đã có
  Widget _buildCategoryList(List<dynamic> categories, List<dynamic> allExams) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final cat = categories[index];
        final examCount = allExams.where((e) => e.maChuDe == cat.maChuDe).length;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // Icon môn học bên trái
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_stories_outlined, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),

              // Tên môn học và số lượng đề thi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.tenChuDe,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: examCount > 0 ? AppColors.surfaceSubtle : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$examCount đề thi liên kết',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: examCount > 0 ? AppColors.textSecondary : AppColors.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Nút xóa chủ đề
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                tooltip: 'Xóa chủ đề',
                onPressed: () => _confirmDeleteCategory(cat, examCount),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Trạng thái trống
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.folder_open_rounded, size: 48, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text(
            'Chưa có chủ đề nào',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary),
          ),
          SizedBox(height: 4),
          Text(
            'Hãy nhập tên môn học ở trên để tạo chủ đề đầu tiên.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

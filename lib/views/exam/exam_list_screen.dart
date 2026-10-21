import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../models/de_thi.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quiz_provider.dart';
import '../widgets/exam_card.dart';

class ExamListScreen extends StatelessWidget {
  final ValueChanged<String> onNavigate;
  final void Function(DeThi exam, bool isPractice) onStartExam;

  const ExamListScreen({
    super.key,
    required this.onNavigate,
    required this.onStartExam,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final quiz = context.watch<QuizProvider>();
    final user = auth.currentUser;
    final isMobile = ResponsiveLayout.isMobile(context);

    final filteredExams = quiz.getFilteredExams();
    final categories = quiz.getCategories();

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Action Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Danh Sách Đề Thi Trắc Nghiệm',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tìm thấy ${filteredExams.length} đề thi sẵn sàng để bạn thử sức',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (auth.isTeacher || auth.isAdmin) ...[
                    ElevatedButton.icon(
                      onPressed: () => onNavigate('create_exam'),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tạo đề mới'),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 20),

              // Filter Controls Card (Search + Difficulty + Category)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(color: Color(0x04000000), blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    // Search bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm tên đề thi...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                        suffixIcon: quiz.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => quiz.setSearchQuery(''),
                              )
                            : null,
                      ),
                      onChanged: (val) => quiz.setSearchQuery(val),
                    ),
                    const SizedBox(height: 14),

                    // Filter row: Difficulty chips + Category dropdown
                    Row(
                      children: [
                        // Difficulty chips
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                const Text(
                                  'Mức độ: ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                ...['Tất cả', 'Dễ', 'Trung bình', 'Khó'].map((diff) {
                                  final isSelected = quiz.selectedDifficulty == diff;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: FilterChip(
                                      label: Text(diff),
                                      selected: isSelected,
                                      selectedColor: AppColors.primarySoft,
                                      checkmarkColor: AppColors.primary,
                                      labelStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                      ),
                                      onSelected: (_) => quiz.setDifficulty(diff),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),

                        // Category Dropdown
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: DropdownButtonFormField<int?>(
                            initialValue: quiz.selectedCategoryId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              isDense: true,
                            ),
                            hint: const Text('Tất cả chủ đề', style: TextStyle(fontSize: 12)),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('Tất cả chủ đề', style: TextStyle(fontSize: 12)),
                              ),
                              ...categories.map((c) => DropdownMenuItem<int?>(
                                value: c.maChuDe,
                                child: Text(c.tenChuDe, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                              )),
                            ],
                            onChanged: (val) => quiz.setCategory(val),
                          ),
                        ),

                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 20, color: AppColors.textSecondary),
                          tooltip: 'Đặt lại bộ lọc',
                          onPressed: () => quiz.resetFilters(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Exams List / Grid
              if (filteredExams.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off, size: 64, color: AppColors.textMuted),
                      const SizedBox(height: 16),
                      const Text(
                        'Không tìm thấy đề thi phù hợp',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Hãy thử thay đổi từ khóa hoặc điều chỉnh bộ lọc tìm kiếm',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => quiz.resetFilters(),
                        child: const Text('Xem tất cả đề thi'),
                      ),
                    ],
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth < 650
                        ? 1
                        : constraints.maxWidth < 1000
                            ? 2
                            : 3;
                    final itemWidth = (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: filteredExams.map((exam) {
                        final isBookmarked = user != null && quiz.isBookmarked(user.id, exam.maDeThi);
                        return SizedBox(
                          width: itemWidth,
                          height: 250,
                          child: ExamCard(
                            exam: exam,
                            isBookmarked: isBookmarked,
                            canManage: auth.isTeacher || auth.isAdmin,
                            onTakeExam: () => onStartExam(exam, false),
                            onPractice: () => onStartExam(exam, true),
                            onToggleBookmark: () {
                              if (user != null) {
                                quiz.toggleBookmark(user.id, exam.maDeThi);
                              }
                            },
                            onManageQuestions: () {
                              onNavigate('manage_questions_${exam.maDeThi}');
                            },
                            onEdit: () {
                              onNavigate('edit_exam_${exam.maDeThi}');
                            },
                            onDelete: () {
                              quiz.deleteExam(exam.maDeThi);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã xóa đề thi.')),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

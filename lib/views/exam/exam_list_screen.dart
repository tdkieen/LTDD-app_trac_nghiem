import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../models/de_thi.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exam_session_provider.dart';
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
    final session = context.watch<ExamSessionProvider>();
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
              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Danh sách đề thi',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tìm thấy ${filteredExams.length} đề thi sẵn sàng',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => onNavigate('create_exam'),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Tạo đề mới'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Danh sách đề thi trắc nghiệm',
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
                    ElevatedButton.icon(
                      onPressed: () => onNavigate('create_exam'),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Tạo đề mới'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm tên đề thi...',
                        filled: true,
                        fillColor: AppColors.surfaceSubtle,
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                        suffixIcon: quiz.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () => quiz.setSearchQuery(''),
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (val) => quiz.setSearchQuery(val),
                    ),
                    const SizedBox(height: 14),

                    if (isMobile) ...[
                      SingleChildScrollView(
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
                                child: ChoiceChip(
                                  label: Text(diff),
                                  selected: isSelected,
                                  selectedColor: AppColors.primarySoft,
                                  backgroundColor: AppColors.surfaceSubtle,
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                  side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                                  onSelected: (_) => quiz.setDifficulty(diff),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int?>(
                              initialValue: quiz.selectedCategoryId,
                              isExpanded: true,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.surfaceSubtle,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                                ),
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
                            icon: const Icon(Icons.refresh_rounded, size: 20, color: AppColors.textSecondary),
                            tooltip: 'Đặt lại bộ lọc',
                            onPressed: () => quiz.resetFilters(),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        children: [
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
                                      child: ChoiceChip(
                                        label: Text(diff),
                                        selected: isSelected,
                                        selectedColor: AppColors.primarySoft,
                                        backgroundColor: AppColors.surfaceSubtle,
                                        labelStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                        ),
                                        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                                        onSelected: (_) => quiz.setDifficulty(diff),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: DropdownButtonFormField<int?>(
                              initialValue: quiz.selectedCategoryId,
                              isExpanded: true,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.surfaceSubtle,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                                ),
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
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Tùy chọn thi: ',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          FilterChip(
                            label: const Text('Xáo trộn câu hỏi', style: TextStyle(fontSize: 12)),
                            selected: session.shuffleQuestions,
                            selectedColor: AppColors.primarySoft,
                            checkmarkColor: AppColors.primary,
                            onSelected: (val) => session.setShuffleQuestions(val),
                          ),
                          FilterChip(
                            label: const Text('Xáo trộn đáp án', style: TextStyle(fontSize: 12)),
                            selected: session.shuffleOptions,
                            selectedColor: AppColors.primarySoft,
                            checkmarkColor: AppColors.primary,
                            onSelected: (val) => session.setShuffleOptions(val),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (filteredExams.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded, size: 64, color: AppColors.textMuted),
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

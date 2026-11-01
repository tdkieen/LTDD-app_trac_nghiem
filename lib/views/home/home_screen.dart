import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../models/de_thi.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quiz_provider.dart';
import '../widgets/exam_card.dart';
import '../widgets/stat_card.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<String> onNavigate;
  final void Function(DeThi exam, bool isPractice) onStartExam;

  const HomeScreen({
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

    final results = user != null ? quiz.getUserHistory(user.id) : [];
    final completedCount = results.length;
    final avgScore = completedCount > 0
        ? results.fold<double>(0.0, (acc, r) => acc + r.tongDiem) / completedCount
        : 0.0;
    final accuracy = (avgScore * 10).toStringAsFixed(0);
    final mistakes = user != null ? quiz.getMistakes(user.id) : [];
    final bookmarks = user != null ? quiz.getBookmarks(user.id) : [];

    final exams = quiz.getAllExams().take(6).toList();
    final categories = quiz.getCategories();

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero banner hiện đại, nhã và dễ đọc hơn, không dùng gradient quá chói.
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 22 : 28),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.flash_on_rounded, size: 14, color: AppColors.warning),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Học tập chủ động & hiệu quả',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Xin chào, ${user?.fullName ?? "bạn"}! 👋',
                            style: TextStyle(
                              fontSize: isMobile ? 24 : 30,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hôm nay bạn muốn thử thách bản thân với đề thi nào? Hãy bắt đầu bằng một bài ngắn để duy trì nhịp học tập đều đặn.',
                            style: TextStyle(
                              fontSize: isMobile ? 13 : 15,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 12,
                            runSpacing: 10,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => onNavigate('exams'),
                                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                                label: const Text('Bắt đầu làm bài'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => onNavigate('mistakes'),
                                icon: const Icon(Icons.book_rounded, size: 18, color: AppColors.primary),
                                label: const Text('Sổ tay câu sai'),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                                  foregroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => onNavigate('create_exam'),
                                icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
                                label: const Text('Tạo đề thi mới'),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.border, width: 1.2),
                                  foregroundColor: AppColors.textPrimary,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!isMobile) ...[
                      const SizedBox(width: 22),
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.psychology_alt_rounded,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // Thẻ thống kê đơn giản, dễ đọc, không chật chội.
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = isMobile ? 2 : 4;
                  final width = (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;

                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: width,
                        child: StatCard(
                          title: 'Đề đã hoàn thành',
                          value: '$completedCount',
                          icon: Icons.task_alt_rounded,
                          iconColor: AppColors.primary,
                          iconBgColor: AppColors.primarySoft,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: StatCard(
                          title: 'Tỉ lệ đúng TB',
                          value: '$accuracy%',
                          icon: Icons.pie_chart_rounded,
                          iconColor: AppColors.success,
                          iconBgColor: AppColors.successSoft,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: StatCard(
                          title: 'Sổ tay câu sai',
                          value: '${mistakes.length}',
                          icon: Icons.menu_book_rounded,
                          iconColor: AppColors.danger,
                          iconBgColor: AppColors.dangerSoft,
                          subtitle: 'Cần ôn lại',
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: StatCard(
                          title: 'Đề thi đã lưu',
                          value: '${bookmarks.length}',
                          icon: Icons.bookmark_rounded,
                          iconColor: AppColors.warning,
                          iconBgColor: AppColors.warningSoft,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Chủ đề thi trắc nghiệm',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => onNavigate('exams'),
                    child: const Text('Xem tất cả'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 46,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return InkWell(
                      onTap: () {
                        quiz.setCategory(cat.maChuDe);
                        onNavigate('exams');
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.label_important_outline_rounded, size: 14, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              cat.tenChuDe,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Đề thi nổi bật & Mới nhất',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => onNavigate('exams'),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: const Text('Kho đề thi'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

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
                    children: exams.map((exam) {
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
                            quiz.setCategory(null);
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

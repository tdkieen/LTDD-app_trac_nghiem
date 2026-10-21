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

    // Compute metrics
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
              // Welcome Hero Banner
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 20 : 32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D6EFD), Color(0xFF1E40AF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x220D6EFD),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.flash_on, size: 14, color: Colors.yellowAccent),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Học tập chủ động & Hiệu quả',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Xin chào, ${user?.fullName ?? "bạn"}! 👋',
                            style: TextStyle(
                              fontSize: isMobile ? 22 : 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Hôm nay bạn muốn thử thách bản thân với đề thi nào? Ôn luyện ngay để củng cố kiến thức.',
                            style: TextStyle(
                              fontSize: isMobile ? 13 : 15,
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 12,
                            runSpacing: 10,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => onNavigate('exams'),
                                icon: const Icon(Icons.play_circle_fill, size: 18),
                                label: const Text('Bắt đầu làm bài'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primary,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => onNavigate('mistakes'),
                                icon: const Icon(Icons.book, size: 18, color: Colors.white),
                                label: const Text('Sổ tay câu sai', style: TextStyle(color: Colors.white)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white70, width: 1.5),
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
                      const SizedBox(width: 24),
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.psychology,
                          size: 72,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Stat Cards Grid
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
                          icon: Icons.task_alt,
                          iconColor: AppColors.primary,
                          iconBgColor: AppColors.primarySoft,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: StatCard(
                          title: 'Tỉ lệ đúng TB',
                          value: '$accuracy%',
                          icon: Icons.pie_chart_outline,
                          iconColor: AppColors.success,
                          iconBgColor: AppColors.successSoft,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: StatCard(
                          title: 'Sổ tay câu sai',
                          value: '${mistakes.length}',
                          icon: Icons.menu_book,
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
                          icon: Icons.bookmark,
                          iconColor: AppColors.warning,
                          iconBgColor: AppColors.warningSoft,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              // Categories Quick Bar
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
                height: 48,
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
                            const Icon(Icons.label_outline, size: 16, color: AppColors.primary),
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

              const SizedBox(height: 32),

              // Featured Exams Section
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
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('Kho đề thi'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Exams Grid
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

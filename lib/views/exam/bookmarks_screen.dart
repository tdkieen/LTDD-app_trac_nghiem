import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../models/de_thi.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quiz_provider.dart';
import '../widgets/exam_card.dart';

class BookmarksScreen extends StatelessWidget {
  final ValueChanged<String> onNavigate;
  final void Function(DeThi exam, bool isPractice) onStartExam;

  const BookmarksScreen({
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

    final bookmarks = user != null ? quiz.getBookmarks(user.id) : [];

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Đề Thi Đã Lưu (Yêu Thích)',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bạn đang lưu ${bookmarks.length} đề thi để ôn luyện dần',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: () => onNavigate('exams'),
                    icon: const Icon(Icons.explore, size: 18),
                    label: const Text('Khám phá thêm đề'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              if (bookmarks.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    children: [
                      const Icon(Icons.bookmark_border, size: 64, color: AppColors.textMuted),
                      const SizedBox(height: 16),
                      const Text(
                        'Bạn chưa lưu đề thi nào',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Nhấn vào biểu tượng dấu trang ở mỗi đề thi để lưu vào danh sách yêu thích.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => onNavigate('exams'),
                        child: const Text('Xem danh sách đề thi'),
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
                      children: bookmarks.map((b) {
                        final exam = b.deThi;
                        if (exam == null) return const SizedBox.shrink();

                        return SizedBox(
                          width: itemWidth,
                          height: 250,
                          child: ExamCard(
                            exam: exam,
                            isBookmarked: true,
                            canManage: auth.isTeacher || auth.isAdmin,
                            onTakeExam: () => onStartExam(exam, false),
                            onPractice: () => onStartExam(exam, true),
                            onToggleBookmark: () {
                              if (user != null) {
                                quiz.toggleBookmark(user.id, exam.maDeThi);
                              }
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

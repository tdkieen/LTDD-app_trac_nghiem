import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../models/cau_hoi.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quiz_provider.dart';

class MistakeNotebookScreen extends StatelessWidget {
  final ValueChanged<String> onNavigate;
  final void Function(List<CauHoi> questions, String title) onPracticeMistakes;

  const MistakeNotebookScreen({
    super.key,
    required this.onNavigate,
    required this.onPracticeMistakes,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final quiz = context.watch<QuizProvider>();
    final isMobile = ResponsiveLayout.isMobile(context);
    final user = auth.currentUser;

    final mistakes = user != null ? quiz.getMistakes(user.id) : [];
    final validMistakeQuestions = mistakes
        .map((m) => m.cauHoi)
        .where((q) => q != null)
        .cast<CauHoi>()
        .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Action Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sổ Tay Câu Hỏi Sai',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bạn đang có ${mistakes.length} câu hỏi cần được ôn tập lại',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (validMistakeQuestions.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () {
                        onPracticeMistakes(validMistakeQuestions, 'Luyện tập câu sai trong sổ tay');
                      },
                      icon: const Icon(Icons.fitness_center, size: 18),
                      label: const Text('Ôn tập tất cả'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              if (mistakes.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 64, color: AppColors.success),
                      const SizedBox(height: 16),
                      const Text(
                        'Tuyệt vời! Bạn không có câu sai nào',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tất cả câu hỏi trong các bài thi trước đều đã được bạn trả lời đúng hoặc đã ôn luyện xong.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => onNavigate('exams'),
                        child: const Text('Làm thêm đề thi mới'),
                      ),
                    ],
                  ),
                )
              else
                ...mistakes.map((m) {
                  final q = m.cauHoi;
                  if (q == null) return const SizedBox.shrink();

                  final timeStr = DateFormat('dd/MM/yyyy HH:mm').format(m.lanCuoiSai);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1.2),
                      boxShadow: const [
                        BoxShadow(color: Color(0x04000000), blurRadius: 8, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: Mistakes count pill + Last wrong date + Delete button
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.dangerSoft,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.warning, size: 14, color: AppColors.danger),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Sai ${m.lanSai} lần',
                                    style: const TextStyle(
                                      color: AppColors.danger,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Lần cuối: $timeStr',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () {
                                quiz.deleteMistake(m.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Đã gỡ câu hỏi khỏi sổ tay.')),
                                );
                              },
                              icon: const Icon(Icons.check, size: 16, color: AppColors.success),
                              label: const Text('Đã hiểu / Xóa', style: TextStyle(color: AppColors.success, fontSize: 12)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Question Text
                        Text(
                          q.noiDung,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Options
                        ...['A', 'B', 'C', 'D'].map((optKey) {
                          final text = q.getOption(optKey);
                          if (text.isEmpty) return const SizedBox.shrink();

                          final isCorrect = (q.dapAnDung ?? '').toUpperCase() == optKey;
                          final isWrongChoice = (m.dapAnDaChon ?? '').toUpperCase() == optKey;

                          Color borderCol = AppColors.border;
                          Color bgCol = AppColors.surfaceMuted;
                          Color textCol = AppColors.textSecondary;

                          if (isCorrect) {
                            borderCol = AppColors.success;
                            bgCol = AppColors.successSoft;
                            textCol = AppColors.success;
                          } else if (isWrongChoice) {
                            borderCol = AppColors.danger;
                            bgCol = AppColors.dangerSoft;
                            textCol = AppColors.danger;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: bgCol,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: borderCol),
                              ),
                              child: Row(
                                children: [
                                  Text('$optKey. ', style: TextStyle(fontWeight: FontWeight.bold, color: textCol)),
                                  Expanded(child: Text(text, style: TextStyle(color: textCol, fontSize: 13))),
                                  if (isCorrect)
                                    const Text('✓ Đáp án đúng', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
                                  if (isWrongChoice && !isCorrect)
                                    const Text('✗ Bạn đã chọn', style: TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          );
                        }),

                        if (q.giaiThich != null && q.giaiThich!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    q.giaiThich!,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../models/de_thi.dart';
import '../../providers/quiz_provider.dart';
import '../widgets/question_media_view.dart';
import 'add_question_sheet.dart';

class ManageQuestionsScreen extends StatefulWidget {
  final int initialExamId;
  final VoidCallback onBack;

  const ManageQuestionsScreen({
    super.key,
    required this.initialExamId,
    required this.onBack,
  });

  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  late int _selectedExamId;

  @override
  void initState() {
    super.initState();
    _selectedExamId = widget.initialExamId;
  }

  void _showAddQuestionDialog(BuildContext context, DeThi exam) {
    AddQuestionSheet.show(
      context,
      exam: exam,
      onSave: (newQ) {
        context.read<QuizProvider>().addQuestion(
          maDeThi: newQ.maDeThi ?? exam.maDeThi,
          maChuDe: newQ.maChuDe,
          noiDung: newQ.noiDung,
          phuongAnA: newQ.phuongAnA ?? '',
          phuongAnB: newQ.phuongAnB ?? '',
          phuongAnC: newQ.phuongAnC ?? '',
          phuongAnD: newQ.phuongAnD ?? '',
          dapAnDung: newQ.dapAnDung ?? 'A',
          mucDoKho: newQ.mucDoKho ?? 'Trung bình',
          laCauHoiNghe: newQ.laCauHoiNghe,
          audioPath: newQ.audioPath,
          imagePath: newQ.imagePath,
          giaiThich: newQ.giaiThich,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm câu hỏi mới thành công!')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final isMobile = ResponsiveLayout.isMobile(context);
    final allExams = quiz.getAllExams();

    if (allExams.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Chưa có đề thi nào trong hệ thống.'),
            ElevatedButton(onPressed: widget.onBack, child: const Text('Quay lại')),
          ],
        ),
      );
    }

    final currentExam = allExams.firstWhere(
      (e) => e.maDeThi == _selectedExamId,
      orElse: () => allExams.first,
    );
    final questions = quiz.getQuestions(currentExam.maDeThi);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Quản Lý Câu Hỏi Đề Thi',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddQuestionDialog(context, currentExam),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Thêm câu hỏi'),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Exam selector card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.folder_open, color: AppColors.primary),
                    const SizedBox(width: 12),
                    const Text('Đề thi đang chọn:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: currentExam.maDeThi,
                          isExpanded: true,
                          items: allExams.map((e) {
                            return DropdownMenuItem(
                              value: e.maDeThi,
                              child: Text(e.tenDeThi, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedExamId = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Questions list
              if (questions.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Column(
                    children: [
                      const Icon(Icons.help_outline, size: 54, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      const Text('Đề thi này chưa có câu hỏi nào', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: () => _showAddQuestionDialog(context, currentExam),
                        child: const Text('Thêm câu hỏi đầu tiên'),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: questions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final q = questions[index];
                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('Câu ${index + 1}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.difficultyBg(q.mucDoKho),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(q.mucDoKho ?? 'Trung bình', style: TextStyle(color: AppColors.difficultyColor(q.mucDoKho), fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              if (q.laCauHoiNghe) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.volume_up, size: 16, color: AppColors.info),
                              ],
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                                tooltip: 'Xóa câu hỏi',
                                onPressed: () {
                                  quiz.deleteQuestion(q.maCauHoi);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Đã xóa câu hỏi khỏi đề thi.')),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(q.noiDung, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          if (q.imagePath != null && q.imagePath!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            QuestionImageView(imagePath: q.imagePath!, maxHeight: 150),
                          ],
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            children: ['A', 'B', 'C', 'D'].map((key) {
                              final text = q.getOption(key);
                              if (text.isEmpty) return const SizedBox.shrink();
                              final isCorrect = (q.dapAnDung ?? '').toUpperCase() == key;
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isCorrect ? AppColors.successSoft : AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: isCorrect ? AppColors.success : AppColors.border),
                                ),
                                child: Text(
                                  '$key. $text ${isCorrect ? "✓" : ""}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                                    color: isCorrect ? AppColors.success : AppColors.textSecondary,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          if (q.giaiThich != null && q.giaiThich!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Giải thích: ${q.giaiThich}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../models/cau_hoi.dart';
import '../../models/ket_qua_thi.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exam_session_provider.dart';

class ExamTakingScreen extends StatefulWidget {
  final VoidCallback onExit;
  final ValueChanged<KetQuaThi> onFinish;

  const ExamTakingScreen({
    super.key,
    required this.onExit,
    required this.onFinish,
  });

  @override
  State<ExamTakingScreen> createState() => _ExamTakingScreenState();
}

class _ExamTakingScreenState extends State<ExamTakingScreen> with WidgetsBindingObserver {
  bool _audioPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      final session = context.read<ExamSessionProvider>();
      session.registerCheatWarning();
    }
  }

  void _showConfirmSubmitDialog(BuildContext context) {
    final session = context.read<ExamSessionProvider>();
    final auth = context.read<AuthProvider>();
    final answered = session.answeredCount;
    final total = session.totalQuestions;
    final unanswered = total - answered;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.assignment_turned_in, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Xác nhận nộp bài', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn đã hoàn thành: $answered / $total câu.'),
            if (unanswered > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warningSoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Còn $unanswered câu chưa trả lời. Bạn có chắc chắn muốn nộp không?',
                        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              const Text('Bạn đã trả lời hết tất cả câu hỏi. Chúc bạn đạt kết quả cao!'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Tiếp tục làm bài'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              final userId = auth.currentUser?.id ?? 'guest';
              final result = session.submit(userId: userId);
              widget.onFinish(result);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Nộp bài ngay', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ExamSessionProvider>();
    final exam = session.currentExam;
    final questions = session.questions;
    final isPractice = session.isPractice;
    final isMobile = ResponsiveLayout.isMobile(context);

    if (exam == null || questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Làm bài thi')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.inbox, size: 54, color: AppColors.textMuted),
              const SizedBox(height: 14),
              const Text('Đề thi này hiện chưa có câu hỏi.', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: widget.onExit,
                child: const Text('Quay lại danh sách'),
              ),
            ],
          ),
        ),
      );
    }

    final currentQ = session.currentQuestion!;
    final currentIndex = session.currentIndex;
    final chosenAnswer = session.answers[currentQ.maCauHoi];
    final isTimerLow = session.secondsRemaining <= 120 && !isPractice;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Thoát bài thi',
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Dừng làm bài?'),
                content: const Text('Tiến trình làm bài hiện tại sẽ không được lưu nếu bạn thoát.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ở lại')),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      widget.onExit();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                    child: const Text('Thoát', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exam.tenDeThi,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              isPractice ? 'Chế độ luyện tập • Tự do thời gian' : 'Chế độ thi thật • Thời gian có hạn',
              style: TextStyle(
                fontSize: 11,
                color: isPractice ? AppColors.success : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          // Timer Widget
          if (!isPractice)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isTimerLow ? AppColors.dangerSoft : AppColors.primarySoft,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isTimerLow ? AppColors.danger : AppColors.primaryLight,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: isTimerLow ? AppColors.danger : AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    session.formattedTimeRemaining,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isTimerLow ? AppColors.danger : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

          // Submit Button
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: () => _showConfirmSubmitDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPractice ? AppColors.success : AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                isPractice ? 'Hoàn tất' : 'Nộp bài',
                style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Anti-cheat warning strip (only in real exam)
            if (!isPractice && session.cheatWarnings > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.danger,
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Cảnh báo gian lận: Bạn đã rời khỏi màn hình thi ${session.cheatWarnings} lần!',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

            // Practice Mode Informational Banner
            if (isPractice)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.successSoft,
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppColors.success, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Chế độ luyện tập: Chọn đáp án để kiểm tra đúng/sai và xem giải thích tức thì.',
                      style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

            // Main Content Area (Question View + Palette on side if desktop)
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 12 : 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left / Main Column: Question Card + Options + Navigation
                        Expanded(
                          flex: 7,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildQuestionCard(context, currentQ, currentIndex, chosenAnswer, isPractice),
                                const SizedBox(height: 16),
                                _buildNavigationButtons(session, currentIndex, questions.length),
                                if (isMobile) ...[
                                  const SizedBox(height: 24),
                                  _buildQuestionPaletteCard(session),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // Right Column: Question Palette (Desktop/Tablet)
                        if (!isMobile) ...[
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 3,
                            child: _buildQuestionPaletteCard(session),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    CauHoi question,
    int index,
    String? chosenAnswer,
    bool isPractice,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header: Index badge + difficulty
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Câu ${index + 1}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              if (question.mucDoKho != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.difficultyBg(question.mucDoKho),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.difficultyColor(question.mucDoKho).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    question.mucDoKho!,
                    style: TextStyle(
                      color: AppColors.difficultyColor(question.mucDoKho),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              if (question.laCauHoiNghe) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.infoSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.volume_up, size: 14, color: AppColors.info),
                      SizedBox(width: 4),
                      Text('Audio Listening', style: TextStyle(color: AppColors.info, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 18),

          // Question Content
          Text(
            question.noiDung,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),

          // Audio player placeholder if listening question
          if (question.laCauHoiNghe) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(_audioPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                    color: AppColors.primary,
                    iconSize: 36,
                    onPressed: () {
                      setState(() {
                        _audioPlaying = !_audioPlaying;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'File nghe câu hỏi audio TOEIC',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: _audioPlaying ? 0.45 : 0.0,
                          backgroundColor: AppColors.border,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('00:15 / 00:32', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Options A, B, C, D
          ...['A', 'B', 'C', 'D'].map((optKey) {
            final text = question.getOption(optKey);
            if (text.isEmpty) return const SizedBox.shrink();

            final isSelected = chosenAnswer == optKey;
            final isCorrect = (question.dapAnDung ?? '').toUpperCase() == optKey;

            // In Practice Mode: reveal colors after choice made
            Color borderColor = AppColors.border;
            Color bgColor = AppColors.surface;
            Color textColor = AppColors.textPrimary;
            IconData? trailingIcon;
            Color? trailingColor;

            if (isPractice && chosenAnswer != null) {
              if (isCorrect) {
                borderColor = AppColors.success;
                bgColor = AppColors.successSoft;
                textColor = AppColors.success;
                trailingIcon = Icons.check_circle;
                trailingColor = AppColors.success;
              } else if (isSelected && !isCorrect) {
                borderColor = AppColors.danger;
                bgColor = AppColors.dangerSoft;
                textColor = AppColors.danger;
                trailingIcon = Icons.cancel;
                trailingColor = AppColors.danger;
              }
            } else if (isSelected) {
              borderColor = AppColors.primary;
              bgColor = AppColors.primarySoft;
              textColor = AppColors.primaryDark;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  context.read<ExamSessionProvider>().selectAnswer(question.maCauHoi, optKey);
                },
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor, width: isSelected ? 2 : 1.2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surfaceMuted,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: 1.2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          optKey,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (trailingIcon != null)
                        Icon(trailingIcon, color: trailingColor, size: 22),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Practice Mode instant explanation box
          if (isPractice && chosenAnswer != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Đáp án chính xác: ${question.dapAnDung}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.giaiThich ?? 'Phương án đúng là ${question.dapAnDung}. Hãy ghi nhớ cấu trúc này.',
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(ExamSessionProvider session, int currentIndex, int total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton.icon(
          onPressed: currentIndex > 0 ? () => session.previousQuestion() : null,
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('Câu trước'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        if (currentIndex < total - 1)
          ElevatedButton.icon(
            onPressed: () => session.nextQuestion(),
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('Câu tiếp theo'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: () => _showConfirmSubmitDialog(context),
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text('Nộp bài'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildQuestionPaletteCard(ExamSessionProvider session) {
    final questions = session.questions;
    final currentIndex = session.currentIndex;
    final answers = session.answers;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bảng câu hỏi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${answers.length}/${questions.length} đã làm',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 14),

          // Grid of numbers
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(questions.length, (idx) {
              final q = questions[idx];
              final isAnswered = answers.containsKey(q.maCauHoi);
              final isCurrent = idx == currentIndex;

              Color btnBg = AppColors.surfaceMuted;
              Color borderCol = AppColors.border;
              Color textCol = AppColors.textSecondary;

              if (isCurrent) {
                btnBg = AppColors.primary;
                borderCol = AppColors.primary;
                textCol = Colors.white;
              } else if (isAnswered) {
                btnBg = AppColors.successSoft;
                borderCol = AppColors.success;
                textCol = AppColors.success;
              }

              return InkWell(
                onTap: () => session.jumpToQuestion(idx),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: btnBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderCol, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${idx + 1}',
                    style: TextStyle(
                      color: textCol,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),

          // Legend
          const Row(
            children: [
              _LegendDot(color: AppColors.primary, label: 'Đang làm'),
              SizedBox(width: 14),
              _LegendDot(color: AppColors.success, label: 'Đã trả lời'),
              SizedBox(width: 14),
              _LegendDot(color: AppColors.border, label: 'Chưa làm'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

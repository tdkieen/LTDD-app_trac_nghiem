import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../models/ket_qua_thi.dart';
import '../../providers/quiz_provider.dart';

class ExamResultScreen extends StatelessWidget {
  final KetQuaThi result;
  final VoidCallback onRetake;
  final VoidCallback onViewHistory;
  final VoidCallback onGoHome;

  const ExamResultScreen({
    super.key,
    required this.result,
    required this.onRetake,
    required this.onViewHistory,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final isMobile = ResponsiveLayout.isMobile(context);
    final topList = quiz.getExamLeaderboard(result.maDeThi);

    final score = result.tongDiem;
    final total = result.tongSoCau;
    final correct = result.soCauDung;
    final wrong = result.soCauSai;

    Color scoreColor = AppColors.danger;
    Color scoreBg = AppColors.dangerSoft;
    if (score >= 8.0) {
      scoreColor = AppColors.success;
      scoreBg = AppColors.successSoft;
    } else if (score >= 5.0) {
      scoreColor = AppColors.primary;
      scoreBg = AppColors.primarySoft;
    }

    final durationMin = result.thoiGianLamGiay ~/ 60;
    final durationSec = result.thoiGianLamGiay % 60;
    final timeStr = '${durationMin}m ${durationSec}s';

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
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onGoHome,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Kết Quả Bài Thi Trắc Nghiệm',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Overview Cards: Score Summary + Exam Top 5 Leaderboard
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 900) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: _buildScoreCard(score, scoreColor, scoreBg, correct, wrong, total, timeStr),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 4,
                          child: _buildTop5Card(topList),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildScoreCard(score, scoreColor, scoreBg, correct, wrong, total, timeStr),
                        const SizedBox(height: 20),
                        _buildTop5Card(topList),
                      ],
                    );
                  }
                },
              ),

              const SizedBox(height: 36),

              // Detailed Question Review
              const Text(
                'Chi tiết câu trả lời & Giải thích',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Xem lại các câu hỏi để nắm rõ kiến thức và rút kinh nghiệm cho các lần thi sau.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),

              if (result.chiTiet.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text('Không có chi tiết bài làm được lưu.', style: TextStyle(color: AppColors.textMuted)),
                  ),
                )
              else
                ...result.chiTiet.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return _buildDetailItem(idx, item);
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(
    double score,
    Color scoreColor,
    Color scoreBg,
    int correct,
    int wrong,
    int total,
    String timeStr,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Header strip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D6EFD), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Text(
                  result.deThi?.tenDeThi ?? 'Bài thi trắc nghiệm',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(result.ngayThi),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Score Display
                Text(
                  score.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: scoreColor,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: scoreBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    result.danhGia,
                    style: TextStyle(
                      color: scoreColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Linear Progress Indicator
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (score / 10.0).clamp(0.0, 1.0),
                    minHeight: 12,
                    backgroundColor: AppColors.border,
                    color: scoreColor,
                  ),
                ),

                const SizedBox(height: 24),

                // Metrics Row (Correct, Wrong, Total, Time)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Câu đúng', '$correct', AppColors.success, Icons.check_circle_outline),
                    _buildStatItem('Câu sai', '$wrong', AppColors.danger, Icons.cancel_outlined),
                    _buildStatItem('Tổng câu', '$total', AppColors.textPrimary, Icons.help_outline),
                    _buildStatItem('Thời gian', timeStr, AppColors.primary, Icons.timer_outlined),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Actions
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onRetake,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Làm lại đề này'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: onViewHistory,
                      icon: const Icon(Icons.history, size: 18),
                      label: const Text('Nhật ký làm bài'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: onGoHome,
                      icon: const Icon(Icons.home, size: 18),
                      label: const Text('Về trang chủ'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTop5Card(List<dynamic> topList) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: const Row(
              children: [
                Icon(Icons.emoji_events, color: AppColors.warning, size: 22),
                SizedBox(width: 10),
                Text(
                  'Top 5 điểm cao — Đề này',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),

          if (topList.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('Chưa có thí sinh nào làm đề này.', style: TextStyle(color: AppColors.textMuted)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topList.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 60),
              itemBuilder: (context, index) {
                final item = topList[index];
                String medal = '#${index + 1}';
                if (index == 0) medal = '🥇';
                if (index == 1) medal = '🥈';
                if (index == 2) medal = '🥉';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 36,
                        child: Text(
                          medal,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.userName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${item.highestScore.toStringAsFixed(1)} đ',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildDetailItem(int index, ChiTietKetQua item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.laDung ? AppColors.success.withValues(alpha: 0.5) : AppColors.danger.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: item.laDung ? AppColors.successSoft : AppColors.dangerSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Câu ${index + 1}',
                  style: TextStyle(
                    color: item.laDung ? AppColors.success : AppColors.danger,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                item.laDung ? Icons.check_circle : Icons.cancel,
                color: item.laDung ? AppColors.success : AppColors.danger,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                item.laDung ? 'Trả lời đúng' : 'Trả lời chưa đúng',
                style: TextStyle(
                  color: item.laDung ? AppColors.success : AppColors.danger,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.noiDung,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 14),

          // Options A, B, C, D review
          ...['A', 'B', 'C', 'D'].map((optKey) {
            String text = '';
            if (optKey == 'A') text = item.phuongAnA ?? '';
            if (optKey == 'B') text = item.phuongAnB ?? '';
            if (optKey == 'C') text = item.phuongAnC ?? '';
            if (optKey == 'D') text = item.phuongAnD ?? '';

            if (text.isEmpty) return const SizedBox.shrink();

            final isCorrect = (item.dapAnDung ?? '').toUpperCase() == optKey;
            final isChosen = (item.dapAnChon ?? '').toUpperCase() == optKey;

            Color optBorder = AppColors.border;
            Color optBg = AppColors.surfaceMuted;
            Color optText = AppColors.textSecondary;
            IconData? icon;

            if (isCorrect) {
              optBorder = AppColors.success;
              optBg = AppColors.successSoft;
              optText = AppColors.success;
              icon = Icons.check;
            } else if (isChosen && !isCorrect) {
              optBorder = AppColors.danger;
              optBg = AppColors.dangerSoft;
              optText = AppColors.danger;
              icon = Icons.close;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: optBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: optBorder, width: (isCorrect || isChosen) ? 1.5 : 1),
                ),
                child: Row(
                  children: [
                    Text(
                      '$optKey.',
                      style: TextStyle(fontWeight: FontWeight.bold, color: optText),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(text, style: TextStyle(color: optText, fontSize: 13)),
                    ),
                    if (icon != null) ...[
                      const SizedBox(width: 8),
                      Icon(icon, size: 16, color: optText),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

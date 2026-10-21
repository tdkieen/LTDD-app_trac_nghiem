import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../models/ket_qua_thi.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quiz_provider.dart';

class HistoryScreen extends StatelessWidget {
  final ValueChanged<KetQuaThi> onViewResult;
  final VoidCallback onGoExams;

  const HistoryScreen({
    super.key,
    required this.onViewResult,
    required this.onGoExams,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final quiz = context.watch<QuizProvider>();
    final isMobile = ResponsiveLayout.isMobile(context);
    final user = auth.currentUser;

    final historyList = user != null ? quiz.getUserHistory(user.id) : <KetQuaThi>[];

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
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
                        'Nhật Ký Học Tập & Lịch Sử Thi',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tổng cộng ${historyList.length} lượt làm bài đã ghi nhận',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: onGoExams,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Làm đề mới'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              if (historyList.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    children: [
                      const Icon(Icons.history_toggle_off, size: 64, color: AppColors.textMuted),
                      const SizedBox(height: 16),
                      const Text(
                        'Bạn chưa hoàn thành bài thi nào',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Hãy chọn một đề thi và thử sức để theo dõi tiến độ của bạn.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: onGoExams,
                        child: const Text('Xem danh sách đề thi'),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: historyList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = historyList[index];
                    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(item.ngayThi);
                    final score = item.tongDiem;

                    Color scoreColor = AppColors.danger;
                    Color scoreBg = AppColors.dangerSoft;
                    if (score >= 8.0) {
                      scoreColor = AppColors.success;
                      scoreBg = AppColors.successSoft;
                    } else if (score >= 5.0) {
                      scoreColor = AppColors.primary;
                      scoreBg = AppColors.primarySoft;
                    }

                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: const [
                          BoxShadow(color: Color(0x04000000), blurRadius: 8, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Score Circle
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: scoreBg,
                              shape: BoxShape.circle,
                              border: Border.all(color: scoreColor, width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              score.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: scoreColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.deThi?.tenDeThi ?? 'Bài thi #${item.maDeThi}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.schedule, size: 14, color: AppColors.textMuted),
                                    const SizedBox(width: 4),
                                    Text(
                                      dateStr,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                    ),
                                    const SizedBox(width: 14),
                                    const Icon(Icons.check_circle_outline, size: 14, color: AppColors.success),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${item.soCauDung}/${item.tongSoCau} câu đúng',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Actions: View Result + Delete
                          OutlinedButton(
                            onPressed: () => onViewResult(item),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            child: const Text('Xem lại', style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                            tooltip: 'Xóa kết quả này',
                            onPressed: () {
                              quiz.deleteHistory(item.maKetQua);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã xóa kết quả làm bài khỏi nhật ký.')),
                              );
                            },
                          ),
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

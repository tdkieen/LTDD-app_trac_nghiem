import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/quiz_provider.dart';

class OverallLeaderboardScreen extends StatelessWidget {
  final VoidCallback onBack;

  const OverallLeaderboardScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final isMobile = ResponsiveLayout.isMobile(context);
    final leaderboard = quiz.getOverallLeaderboard();

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
                  IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bảng Xếp Hạng Thành Tích',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Vinh danh những thí sinh có thành tích học tập và điểm số xuất sắc',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Top 3 Podium Cards if at least 3 participants
              if (leaderboard.length >= 3) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Rank 2
                    _buildPodium(leaderboard[1], 2, '🥈', const Color(0xFF94A3B8), 150),
                    const SizedBox(width: 14),
                    // Rank 1
                    _buildPodium(leaderboard[0], 1, '🥇', const Color(0xFFF59E0B), 180),
                    const SizedBox(width: 14),
                    // Rank 3
                    _buildPodium(leaderboard[2], 3, '🥉', const Color(0xFFD97706), 130),
                  ],
                ),
                const SizedBox(height: 32),
              ],

              // Leaderboard Table / Cards
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(color: Color(0x04000000), blurRadius: 10, offset: Offset(0, 3)),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: leaderboard.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = leaderboard[index];
                    String rankBadge = '#${index + 1}';
                    if (index == 0) rankBadge = '🥇';
                    if (index == 1) rankBadge = '🥈';
                    if (index == 2) rankBadge = '🥉';

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 44,
                            child: Text(
                              rankBadge,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 14),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primarySoft,
                            child: Text(
                              item.name.isNotEmpty ? item.name[0].toUpperCase() : 'U',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                                Text(
                                  item.email,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${item.averageScore.toStringAsFixed(1)} đ TB',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primary),
                              ),
                              Text(
                                '${item.totalExams} bài thi • Cao nhất: ${item.highestScore.toStringAsFixed(1)}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPodium(dynamic item, int rank, String medal, Color color, double height) {
    return Container(
      width: 105,
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border.all(color: color.withOpacity(0.5), width: rank == 1 ? 2 : 1),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(medal, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            item.name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '${item.averageScore.toStringAsFixed(1)} đ',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: color),
          ),
        ],
      ),
    );
  }
}

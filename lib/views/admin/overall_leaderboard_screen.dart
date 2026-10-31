import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quiz_provider.dart';

/// Màn hình Bảng Xếp Hạng Thành Tích (BẢNG VÀNG)
/// Thiết kế tối giản, sạch sẽ, phân cấp rõ ràng theo phong cách Minimalist
class OverallLeaderboardScreen extends StatelessWidget {
  final VoidCallback onBack;

  const OverallLeaderboardScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final auth = context.watch<AuthProvider>();
    final isMobile = ResponsiveLayout.isMobile(context);
    final leaderboard = quiz.getOverallLeaderboard();
    final currentUserId = auth.currentUser?.id;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header trên cùng
              _buildHeader(context),

              const SizedBox(height: 24),

              // 2. Bục vinh danh Top 3 (nếu có đủ từ 3 thí sinh trở lên)
              if (leaderboard.length >= 3) ...[
                _buildTopThreePodium(leaderboard),
                const SizedBox(height: 28),
              ],

              // 3. Tiêu đề danh sách xếp hạng
              Row(
                children: [
                  const Icon(Icons.format_list_numbered, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Toàn Bộ Bảng Xếp Hạng (${leaderboard.length} học viên)',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 4. Danh sách thí sinh
              if (leaderboard.isEmpty)
                _buildEmptyState()
              else
                _buildRankedList(leaderboard, currentUserId),
            ],
          ),
        ),
      ),
    );
  }

  // --- CÁC HÀM XÂY DỰNG GIAO DIỆN CON (DỄ HIỂU & DỄ BẢO TRÌ) ---

  /// Header với nút quay lại và tiêu đề trang
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Bảng Xếp Hạng Thành Tích',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('🏆', style: TextStyle(fontSize: 20)),
                ],
              ),
              SizedBox(height: 2),
              Text(
                'Vinh danh những học viên có điểm trung bình thi đua cao nhất hệ thống',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Bục vinh danh Top 3 (Thứ tự: Hạng 2 bên trái - Hạng 1 ở giữa cao nhất - Hạng 3 bên phải)
  Widget _buildTopThreePodium(List<dynamic> leaderboard) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'BỤC VINH DANH TOP 3 XUẤT SẮC',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Hạng 2: Bạc (bên trái, cao 145px)
              _buildPodiumColumn(
                item: leaderboard[1],
                rank: 2,
                medal: '🥈',
                podiumColor: const Color(0xFFF1F5F9), // Xám bạc mềm
                borderColor: const Color(0xFF94A3B8),
                height: 145,
              ),
              const SizedBox(width: 12),
              // Hạng 1: Vàng (ở giữa, cao 185px)
              _buildPodiumColumn(
                item: leaderboard[0],
                rank: 1,
                medal: '🥇',
                podiumColor: const Color(0xFFFFFBEB), // Vàng kim mềm
                borderColor: const Color(0xFFF59E0B),
                height: 185,
              ),
              const SizedBox(width: 12),
              // Hạng 3: Đồng (bên phải, cao 125px)
              _buildPodiumColumn(
                item: leaderboard[2],
                rank: 3,
                medal: '🥉',
                podiumColor: const Color(0xFFFEF3C7), // Nâu đồng nhẹ
                borderColor: const Color(0xFFD97706),
                height: 125,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Cột hiển thị từng thí sinh trên bục vinh danh
  Widget _buildPodiumColumn({
    required dynamic item,
    required int rank,
    required String medal,
    required Color podiumColor,
    required Color borderColor,
    required double height,
  }) {
    final isFirst = rank == 1;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Huy chương
          Text(medal, style: TextStyle(fontSize: isFirst ? 30 : 24)),
          const SizedBox(height: 4),

          // Avatar tròn
          CircleAvatar(
            radius: isFirst ? 26 : 22,
            backgroundColor: isFirst ? AppColors.primary : AppColors.primarySoft,
            child: Text(
              item.name.isNotEmpty ? item.name[0].toUpperCase() : 'U',
              style: TextStyle(
                color: isFirst ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: isFirst ? 18 : 15,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Tên thí sinh
          Text(
            item.name,
            style: TextStyle(
              fontSize: isFirst ? 14 : 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),

          // Điểm trung bình dạng Badge nhỏ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isFirst ? AppColors.primary : AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${item.averageScore.toStringAsFixed(1)} đ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isFirst ? Colors.white : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Khối bục đứng hình chữ nhật bo tròn mép trên
          Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: podiumColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              border: Border.all(
                color: borderColor.withValues(alpha: 0.4),
                width: isFirst ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: isFirst ? 28 : 22,
                  fontWeight: FontWeight.w900,
                  color: borderColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Danh sách toàn bộ xếp hạng từ trên xuống dưới
  Widget _buildRankedList(List<dynamic> leaderboard, String? currentUserId) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: leaderboard.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.borderLight,
        ),
        itemBuilder: (context, index) {
          final item = leaderboard[index];
          final isCurrentUser = currentUserId != null && item.userId == currentUserId;

          // Biểu tượng thứ hạng
          String rankText = '#${index + 1}';
          Color rankColor = AppColors.textMuted;
          if (index == 0) {
            rankText = '🥇';
            rankColor = const Color(0xFFF59E0B);
          } else if (index == 1) {
            rankText = '🥈';
            rankColor = const Color(0xFF94A3B8);
          } else if (index == 2) {
            rankText = '🥉';
            rankColor = const Color(0xFFD97706);
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              // Nếu là chính người dùng đang đăng nhập thì highlight nền xanh nhạt
              color: isCurrentUser ? AppColors.primarySoft : Colors.transparent,
              borderRadius: BorderRadius.circular(index == 0
                  ? 16
                  : (index == leaderboard.length - 1 ? 16 : 0)),
            ),
            child: Row(
              children: [
                // Thứ hạng
                SizedBox(
                  width: 36,
                  child: Text(
                    rankText,
                    style: TextStyle(
                      fontSize: index < 3 ? 18 : 14,
                      fontWeight: FontWeight.w800,
                      color: rankColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),

                // Avatar
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isCurrentUser ? AppColors.primary : AppColors.surfaceSubtle,
                  child: Text(
                    item.name.isNotEmpty ? item.name[0].toUpperCase() : 'U',
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Tên và Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: isCurrentUser ? AppColors.primary : AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCurrentUser) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Bạn',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.totalExams} bài thi đã làm • Điểm cao nhất: ${item.highestScore.toStringAsFixed(1)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),

                // Điểm trung bình ở bên phải
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.averageScore.toStringAsFixed(1)} đ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      'Điểm trung bình',
                      style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Trạng thái khi chưa có ai làm bài thi
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.emoji_events_outlined, size: 48, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text(
            'Chưa có dữ liệu xếp hạng',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary),
          ),
          SizedBox(height: 4),
          Text(
            'Hãy làm bài thi đầu tiên để ghi tên mình lên bảng vàng nhé!',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

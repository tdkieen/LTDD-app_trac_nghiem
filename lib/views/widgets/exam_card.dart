import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/de_thi.dart';

class ExamCard extends StatelessWidget {
  final DeThi exam;
  final bool isBookmarked;
  final VoidCallback onTakeExam;
  final VoidCallback onPractice;
  final VoidCallback onToggleBookmark;
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onManageQuestions;

  const ExamCard({
    super.key,
    required this.exam,
    required this.isBookmarked,
    required this.onTakeExam,
    required this.onPractice,
    required this.onToggleBookmark,
    this.canManage = false,
    this.onEdit,
    this.onDelete,
    this.onManageQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final diffColor = AppColors.difficultyColor(exam.mucDoKho);
    final diffBg = AppColors.difficultyBg(exam.mucDoKho);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar: Category + Difficulty + Bookmark button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
            child: Row(
              children: [
                // Category pill
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            exam.chuDe?.tenChuDe ?? 'Chung',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Difficulty badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: diffBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: diffColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          exam.mucDoKho ?? 'Trung bình',
                          style: TextStyle(
                            color: diffColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Bookmark toggle
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? AppColors.primary : AppColors.textMuted,
                  ),
                  tooltip: isBookmarked ? 'Bỏ lưu đề thi' : 'Lưu đề thi',
                  onPressed: onToggleBookmark,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              exam.tenDeThi,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Details row: Questions count, Duration, Views
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _buildInfoItem(Icons.help_outline, '${exam.soCauHoi ?? 10} câu'),
                _buildInfoItem(Icons.timer_outlined, '${exam.thoiGian ?? 15} phút'),
                _buildInfoItem(Icons.people_outline, '${exam.luotThi} lượt thi'),
              ],
            ),
          ),

          const Spacer(),

          const Divider(height: 24),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPractice,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      side: const BorderSide(color: AppColors.primary, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Luyện tập', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onTakeExam,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Thi thật', style: TextStyle(fontSize: 13, color: Colors.white)),
                  ),
                ),
                if (canManage) ...[
                  const SizedBox(width: 6),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppColors.textSecondary, size: 20),
                    tooltip: 'Quản lý đề',
                    onSelected: (value) {
                      if (value == 'questions') onManageQuestions?.call();
                      if (value == 'edit') onEdit?.call();
                      if (value == 'delete') onDelete?.call();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'questions',
                        child: Row(
                          children: [
                            Icon(Icons.format_list_bulleted, size: 18, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text('Quản lý câu hỏi'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18, color: AppColors.warning),
                            SizedBox(width: 8),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: AppColors.danger),
                            SizedBox(width: 8),
                            Text('Xóa đề thi', style: TextStyle(color: AppColors.danger)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

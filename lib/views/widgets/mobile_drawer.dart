import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class MobileDrawer extends StatelessWidget {
  final String activeRoute;
  final ValueChanged<String> onNavigate;

  const MobileDrawer({
    super.key,
    required this.activeRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canManage = auth.isTeacher || auth.isAdmin;
    final isAdmin = auth.isAdmin;
    final user = auth.currentUser;

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // User Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user != null && user.fullName.isNotEmpty
                          ? user.fullName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? 'Khách',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          user?.role.displayName ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  _buildItem(context, 'home', 'Trang chủ', Icons.home_outlined, Icons.home),
                  _buildItem(context, 'exams', 'Danh sách đề thi', Icons.assignment_outlined, Icons.assignment),
                  _buildItem(context, 'history', 'Nhật ký học tập', Icons.history, Icons.history),
                  _buildItem(context, 'profile', 'Hồ sơ của tôi', Icons.person_outline, Icons.person),
                  _buildItem(context, 'bookmarks', 'Đề đã lưu', Icons.bookmark_outline, Icons.bookmark),
                  _buildItem(context, 'mistakes', 'Sổ tay câu sai', Icons.menu_book_outlined, Icons.menu_book),
                  _buildItem(context, 'leaderboard', 'Bảng xếp hạng', Icons.emoji_events_outlined, Icons.emoji_events),

                  if (canManage) ...[
                    const Divider(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Text('QUẢN LÝ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                    ),
                    _buildItem(context, 'create_exam', 'Tạo đề thi', Icons.add_circle_outline, Icons.add_circle),
                  ],

                  if (isAdmin) ...[
                    _buildItem(context, 'manage_categories', 'Quản lý chủ đề', Icons.category_outlined, Icons.category),
                    _buildItem(context, 'manage_users', 'Quản lý người dùng', Icons.manage_accounts_outlined, Icons.manage_accounts),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, String id, String label, IconData icon, IconData activeIcon) {
    final isActive = activeRoute == id;
    return ListTile(
      leading: Icon(
        isActive ? activeIcon : icon,
        color: isActive ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          color: isActive ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      selected: isActive,
      selectedTileColor: AppColors.primarySoft,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: () {
        Navigator.pop(context);
        onNavigate(id);
      },
    );
  }
}

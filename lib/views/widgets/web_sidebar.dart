import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class WebSidebar extends StatelessWidget {
  final String activeRoute;
  final ValueChanged<String> onNavigate;

  const WebSidebar({
    super.key,
    required this.activeRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canManage = auth.isTeacher || auth.isAdmin;
    final isAdmin = auth.isAdmin;

    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.school, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'EDUTECH',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Thi Trắc Nghiệm',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              children: [
                _buildSectionHeader('HỌC TẬP'),
                _buildMenuItem(
                  id: 'home',
                  label: 'Trang chủ',
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                ),
                _buildMenuItem(
                  id: 'exams',
                  label: 'Danh sách đề thi',
                  icon: Icons.assignment_outlined,
                  activeIcon: Icons.assignment,
                ),
                _buildMenuItem(
                  id: 'history',
                  label: 'Nhật ký học tập',
                  icon: Icons.history,
                  activeIcon: Icons.history,
                ),

                const SizedBox(height: 16),
                _buildSectionHeader('CÁ NHÂN'),
                _buildMenuItem(
                  id: 'profile',
                  label: 'Hồ sơ của tôi',
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                ),
                _buildMenuItem(
                  id: 'bookmarks',
                  label: 'Đề đã lưu',
                  icon: Icons.bookmark_outline,
                  activeIcon: Icons.bookmark,
                ),
                _buildMenuItem(
                  id: 'mistakes',
                  label: 'Sổ tay câu sai',
                  icon: Icons.menu_book_outlined,
                  activeIcon: Icons.menu_book,
                ),

                const SizedBox(height: 16),
                _buildSectionHeader('BẢNG VÀNG'),
                _buildMenuItem(
                  id: 'leaderboard',
                  label: 'Bảng xếp hạng',
                  icon: Icons.emoji_events_outlined,
                  activeIcon: Icons.emoji_events,
                ),

                if (canManage) ...[
                  const SizedBox(height: 16),
                  _buildSectionHeader('QUẢN LÝ'),
                  _buildMenuItem(
                    id: 'create_exam',
                    label: 'Tạo đề thi',
                    icon: Icons.add_circle_outline,
                    activeIcon: Icons.add_circle,
                  ),
                ],

                if (isAdmin) ...[
                  _buildMenuItem(
                    id: 'manage_categories',
                    label: 'Quản lý chủ đề',
                    icon: Icons.category_outlined,
                    activeIcon: Icons.category,
                  ),
                  _buildMenuItem(
                    id: 'manage_users',
                    label: 'Quản lý người dùng',
                    icon: Icons.manage_accounts_outlined,
                    activeIcon: Icons.manage_accounts,
                  ),
                ],
              ],
            ),
          ),

          // Bottom Version / User status
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.verified_outlined, size: 15, color: AppColors.success),
                const SizedBox(width: 6),
                const Text(
                  'v1.0.0',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    auth.currentUser?.role.displayName ?? '',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String id,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isActive = activeRoute == id;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () => onNavigate(id),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primarySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isActive
                ? Border.all(color: AppColors.primaryLight.withOpacity(0.3), width: 1)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 20,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
              if (isActive)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

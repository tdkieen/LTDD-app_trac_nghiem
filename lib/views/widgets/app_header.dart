import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import 'notification_dialog.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed;
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    required this.title,
    this.onMenuPressed,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final notif = context.watch<NotificationProvider>();
    final isMobile = ResponsiveLayout.isMobile(context);
    final unread = notif.getUnreadCount(auth.currentUser?.id);
    final user = auth.currentUser;

    return Container(
      height: 68,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          // Mobile menu toggle
          if (isMobile) ...[
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textPrimary),
              onPressed: onMenuPressed ?? () => Scaffold.of(context).openDrawer(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            const SizedBox(width: 8),
          ],

          // Title
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Custom actions
          ...?actions,

          // Debug Admin Seed Sample Data button
          if (kDebugMode && user != null && user.isAdmin) ...[
            TextButton.icon(
              onPressed: auth.isLoading
                  ? null
                  : () async {
                      final ok = await context.read<AuthProvider>().seedSampleData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? 'Đã tạo dữ liệu mẫu trên Firebase thành công!'
                                  : (context.read<AuthProvider>().errorMessage ?? 'Không thể tạo dữ liệu mẫu'),
                            ),
                            backgroundColor: ok ? AppColors.success : AppColors.danger,
                          ),
                        );
                      }
                    },
              icon: const Icon(Icons.dataset_outlined, size: 16),
              label: Text(isMobile ? 'Seed' : 'Tạo dữ liệu mẫu', style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 4),
          ],

          // Role Badge (Read-only status badge, role managed by account)
          if (user != null) ...[
            Tooltip(
              message: 'Vai trò: ${user.role.displayName}',
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_user_outlined, size: 14, color: AppColors.primary),
                    if (!isMobile) ...[
                      const SizedBox(width: 5),
                      Text(
                        user.role.displayName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Notification Bell
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
                tooltip: 'Thông báo',
                onPressed: () => NotificationDialog.show(context),
              ),
              if (unread > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 8),

          // User Profile Quick Menu (with Logout)
          if (user != null)
            PopupMenuButton<String>(
              tooltip: 'Tài khoản: ${user.fullName}',
              offset: const Offset(0, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              onSelected: (val) {
                if (val == 'logout') {
                  context.read<AuthProvider>().logout();
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                      ),
                      Text(
                        '${user.role.displayName} • ${user.email}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 18, color: AppColors.danger),
                      SizedBox(width: 8),
                      Text(
                        'Đăng xuất',
                        style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 120),
                      child: Text(
                        user.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textSecondary),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

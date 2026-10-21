import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';

class NotificationDialog extends StatelessWidget {
  const NotificationDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const NotificationDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final notifications = notifProvider.getNotifications(auth.currentUser?.id);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active, color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  const Text(
                    'Thông báo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (notifications.any((n) => !n.daDoc))
                    TextButton(
                      onPressed: () {
                        notifProvider.markAllAsRead(auth.currentUser?.id);
                      },
                      child: const Text('Đọc tất cả', style: TextStyle(fontSize: 12)),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // List
            Expanded(
              child: notifications.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_off_outlined, size: 48, color: AppColors.textMuted),
                          SizedBox(height: 12),
                          Text('Chưa có thông báo nào', style: TextStyle(color: AppColors.textMuted)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, indent: 64),
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        final timeStr = DateFormat('dd/MM HH:mm').format(notif.thoiGian);

                        IconData iconData = Icons.info_outline;
                        Color iconColor = AppColors.info;
                        Color iconBg = AppColors.infoSoft;

                        if (notif.loaiIcon == 'success') {
                          iconData = Icons.check_circle_outline;
                          iconColor = AppColors.success;
                          iconBg = AppColors.successSoft;
                        } else if (notif.loaiIcon == 'warning') {
                          iconData = Icons.warning_amber_outlined;
                          iconColor = AppColors.warning;
                          iconBg = AppColors.warningSoft;
                        }

                        return InkWell(
                          onTap: () {
                            if (!notif.daDoc) {
                              notifProvider.markAsRead(notif.id);
                            }
                          },
                          child: Container(
                            color: notif.daDoc ? Colors.transparent : AppColors.primarySoft.withValues(alpha: 0.4),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: iconBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(iconData, color: iconColor, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notif.noiDung,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: notif.daDoc ? FontWeight.normal : FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        timeStr,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!notif.daDoc)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(top: 6),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

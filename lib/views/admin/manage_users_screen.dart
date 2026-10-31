import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../models/app_user.dart';
import '../../providers/quiz_provider.dart';

/// Màn hình Quản Lý Người Dùng & Phân Quyền (QUẢN LÝ)
/// Thiết kế tối giản, sạch sẽ, quản lý vai trò và tài khoản người dùng trực quan
class ManageUsersScreen extends StatelessWidget {
  final VoidCallback onBack;

  const ManageUsersScreen({super.key, required this.onBack});

  /// Hàm hiển thị hộp thoại xác nhận xóa tài khoản
  void _confirmDeleteUser(BuildContext context, AppUser user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa tài khoản?'),
        content: Text(
          'Bạn có chắc chắn muốn xóa tài khoản "${user.fullName}" (${user.email}) khỏi hệ thống không?\n\nHành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<QuizProvider>().deleteUser(user.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa người dùng "${user.fullName}".')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Xóa vĩnh viễn'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final isMobile = ResponsiveLayout.isMobile(context);
    final users = quiz.getUsers();

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header trên cùng
              _buildHeader(users.length),

              const SizedBox(height: 24),

              // 2. Tiêu đề danh sách
              Row(
                children: [
                  const Icon(Icons.people_alt_outlined, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Danh Sách Tài Khoản Trong Hệ Thống (${users.length})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3. Danh sách người dùng
              if (users.isEmpty)
                _buildEmptyState()
              else
                _buildUserList(context, users),
            ],
          ),
        ),
      ),
    );
  }

  // --- CÁC HÀM XÂY DỰNG GIAO DIỆN CON ---

  /// Header với nút quay lại và tổng số tài khoản
  Widget _buildHeader(int userCount) {
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    'Quản Lý Người Dùng & Phân Quyền',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('👥', style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Tổng cộng $userCount tài khoản • Cấp quyền Học viên, Giáo viên, Admin',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Danh sách hiển thị từng thẻ người dùng
  Widget _buildUserList(BuildContext context, List<AppUser> users) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final user = users[index];
        final createdStr = DateFormat('dd/MM/yyyy').format(user.ngayTao);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x040F172A),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar hiển thị chữ cái đầu tiên của tên
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primarySoft,
                child: Text(
                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Thông tin người dùng
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${user.email} • Tạo: $createdStr',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              // Dropdown đổi vai trò (Học viên / Giáo viên / Admin)
              _buildRoleDropdown(context, user),

              const SizedBox(width: 8),

              // Nút xóa tài khoản
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                tooltip: 'Xóa tài khoản',
                onPressed: () => _confirmDeleteUser(context, user),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Dropdown chọn vai trò người dùng (Pill Badge)
  Widget _buildRoleDropdown(BuildContext context, AppUser user) {
    Color bg;
    Color fg;

    switch (user.role) {
      case UserRole.student:
        bg = AppColors.surfaceSubtle;
        fg = AppColors.textSecondary;
        break;
      case UserRole.teacher:
        bg = AppColors.primarySoft;
        fg = AppColors.primary;
        break;
      case UserRole.admin:
        bg = const Color(0xFFFEF3C7); // Vàng hổ phách
        fg = const Color(0xFFD97706);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<UserRole>(
          value: user.role,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          icon: Icon(Icons.arrow_drop_down, color: fg, size: 18),
          items: UserRole.values.map((role) {
            return DropdownMenuItem(
              value: role,
              child: Text(role.displayName),
            );
          }).toList(),
          onChanged: (newRole) {
            if (newRole != null && newRole != user.role) {
              context.read<QuizProvider>().changeUserRole(user.id, newRole);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Đã đổi vai trò của "${user.fullName}" thành ${newRole.displayName}.',
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  /// Trạng thái trống
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
          Icon(Icons.person_off_outlined, size: 48, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text(
            'Chưa có người dùng nào',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

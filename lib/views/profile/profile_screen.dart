import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quiz_provider.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onGoHome;

  const ProfileScreen({super.key, required this.onGoHome});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _targetCtrl;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    _nameCtrl = TextEditingController(text: user?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: user?.phoneNumber ?? '');
    _targetCtrl = TextEditingController(
      text: (user?.diemMucTieu ?? 8.0).toString(),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final target =
        double.tryParse(_targetCtrl.text.trim().replaceAll(',', '.')) ?? 8.0;

    auth.updateProfile(
      fullName: _nameCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      diemMucTieu: target,
    );

    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cập nhật hồ sơ cá nhân thành công!')),
    );
  }

  void _cancelEdit() {
    final user = context.read<AuthProvider>().currentUser;
    setState(() {
      _nameCtrl.text = user?.fullName ?? '';
      _phoneCtrl.text = user?.phoneNumber ?? '';
      _targetCtrl.text = (user?.diemMucTieu ?? 8.0).toString();
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final quiz = context.watch<QuizProvider>();
    final isMobile = ResponsiveLayout.isMobile(context);
    final user = auth.currentUser;

    if (user == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Vui lòng đăng nhập để xem hồ sơ.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: widget.onGoHome,
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      );
    }

    final history = quiz.getUserHistory(user.id);
    final bookmarks = quiz.getBookmarks(user.id);
    final totalExams = history.length;
    final avgScore = totalExams > 0
        ? history.fold<double>(0.0, (acc, r) => acc + r.tongDiem) / totalExams
        : 0.0;
    final maxScore = totalExams > 0
        ? history.map((r) => r.tongDiem).reduce((a, b) => a > b ? a : b)
        : 0.0;

    final createdStr = DateFormat('dd/MM/yyyy').format(user.ngayTao);

    final logoutButton = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (kDebugMode && user.isAdmin) ...[
          ElevatedButton.icon(
            onPressed: auth.isLoading
                ? null
                : () async {
                    final ok = await context.read<AuthProvider>().seedSampleData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? 'Đã tạo dữ liệu mẫu thành công!'
                                : (auth.errorMessage ?? 'Không thể tạo dữ liệu mẫu'),
                          ),
                          backgroundColor: ok ? AppColors.success : AppColors.danger,
                        ),
                      );
                    }
                  },
            icon: const Icon(Icons.dataset_outlined, size: 16),
            label: const Text('Tạo dữ liệu mẫu'),
          ),
          const SizedBox(width: 10),
        ],
        OutlinedButton.icon(
          onPressed: () => context.read<AuthProvider>().logout(),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            side: const BorderSide(color: AppColors.danger),
          ),
          icon: const Icon(Icons.logout, size: 16),
          label: const Text('Đăng xuất'),
        ),
      ],
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header (same pattern as other pages)
              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _headerTitle(),
                    const SizedBox(height: 12),
                    logoutButton,
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(child: _headerTitle()),
                    logoutButton,
                  ],
                ),

              const SizedBox(height: 20),

              // Profile hero card (same style as Trang chủ banner)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 20 : 28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D6EFD), Color(0xFF1E40AF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x220D6EFD),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: isMobile ? 30 : 38,
                      backgroundColor: Colors.white,
                      child: Text(
                        user.fullName.isNotEmpty
                            ? user.fullName[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          fontSize: isMobile ? 24 : 30,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 14 : 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user.role.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Thành viên từ $createdStr',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Stat tiles (same style as Thống kê / Trang chủ)
              LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 12.0;
                  final cols = constraints.maxWidth >= 700 ? 4 : 2;
                  final w =
                      (constraints.maxWidth - spacing * (cols - 1)) / cols;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      SizedBox(
                        width: w,
                        child: _StatTile(
                          icon: Icons.assignment_turned_in_outlined,
                          label: 'Số bài thi đã làm',
                          value: '$totalExams',
                          color: AppColors.primary,
                          bg: AppColors.primarySoft,
                        ),
                      ),
                      SizedBox(
                        width: w,
                        child: _StatTile(
                          icon: Icons.insights,
                          label: 'Điểm trung bình',
                          value: avgScore.toStringAsFixed(1),
                          color: AppColors.success,
                          bg: AppColors.successSoft,
                        ),
                      ),
                      SizedBox(
                        width: w,
                        child: _StatTile(
                          icon: Icons.emoji_events_outlined,
                          label: 'Điểm cao nhất',
                          value: maxScore.toStringAsFixed(1),
                          color: AppColors.warning,
                          bg: AppColors.warningSoft,
                        ),
                      ),
                      SizedBox(
                        width: w,
                        child: _StatTile(
                          icon: Icons.bookmark_outline,
                          label: 'Đề đã lưu',
                          value: '${bookmarks.length}',
                          color: AppColors.secondary,
                          bg: AppColors.secondarySoft,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Goal progress card
              _GoalCard(
                average: avgScore,
                target: user.diemMucTieu,
                hasData: totalExams > 0,
              ),

              const SizedBox(height: 16),

              // Edit form card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Thông tin cá nhân',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (!_isEditing)
                            OutlinedButton.icon(
                              onPressed: () =>
                                  setState(() => _isEditing = true),
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('Chỉnh sửa'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _nameCtrl,
                        enabled: _isEditing,
                        decoration: const InputDecoration(
                          labelText: 'Họ và tên',
                          prefixIcon: Icon(Icons.badge_outlined, size: 20),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Họ tên không được trống'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _phoneCtrl,
                        enabled: _isEditing,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Số điện thoại',
                          prefixIcon: Icon(Icons.phone_outlined, size: 20),
                        ),
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _targetCtrl,
                        enabled: _isEditing,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Điểm mục tiêu (thang điểm 10)',
                          prefixIcon: Icon(Icons.flag_outlined, size: 20),
                        ),
                        validator: (v) {
                          final n = double.tryParse(
                            (v ?? '').trim().replaceAll(',', '.'),
                          );
                          if (n == null || n < 0 || n > 10)
                            return 'Nhập điểm từ 0 đến 10';
                          return null;
                        },
                      ),

                      if (_isEditing) ...[
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: _cancelEdit,
                              child: const Text('Hủy'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _saveProfile,
                              child: const Text('Lưu thông tin'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hồ Sơ Cá Nhân',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Thông tin chi tiết tài khoản và lịch sử rèn luyện',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bg;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final double average;
  final double target;
  final bool hasData;

  const _GoalCard({
    required this.average,
    required this.target,
    required this.hasData,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0
        ? (average / target).clamp(0.0, 1.0).toDouble()
        : 0.0;
    final reached = hasData && average >= target;
    final color = reached ? AppColors.success : AppColors.primary;

    final String message;
    if (!hasData) {
      message = 'Làm bài thi đầu tiên để bắt đầu theo dõi mục tiêu.';
    } else if (reached) {
      message = 'Bạn đã đạt mục tiêu. Hãy thử đặt mục tiêu cao hơn.';
    } else {
      message =
          'Còn thiếu ${(target - average).toStringAsFixed(1)} điểm để đạt mục tiêu.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
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
          Row(
            children: [
              const Icon(
                Icons.flag_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Tiến độ so với mục tiêu',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${average.toStringAsFixed(1)} / ${target.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

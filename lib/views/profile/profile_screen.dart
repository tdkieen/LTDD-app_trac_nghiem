import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quiz_provider.dart';
import '../widgets/role_switcher_dialog.dart';

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
    _targetCtrl = TextEditingController(text: (user?.diemMucTieu ?? 8.0).toString());
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
    final target = double.tryParse(_targetCtrl.text.trim()) ?? 8.0;

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
            ElevatedButton(onPressed: widget.onGoHome, child: const Text('Về trang chủ')),
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

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hồ Sơ Cá Nhân',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Thông tin chi tiết tài khoản và lịch sử rèn luyện',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Profile Header Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(color: Color(0x06000000), blurRadius: 12, offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user.fullName,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  user.role.displayName,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(user.email, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          Text('Thành viên từ ngày: $createdStr', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => RoleSwitcherDialog.show(context),
                      icon: const Icon(Icons.swap_horiz, size: 16),
                      label: const Text('Đổi tài khoản'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildMetricBox('Số bài thi đã làm', '$totalExams', Icons.assignment_turned_in, AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildMetricBox('Điểm trung bình', avgScore.toStringAsFixed(1), Icons.insights, AppColors.success),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildMetricBox('Điểm cao nhất', maxScore.toStringAsFixed(1), Icons.emoji_events, AppColors.warning),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildMetricBox('Đề đã bookmark', '${bookmarks.length}', Icons.bookmark, AppColors.secondary),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Edit Form Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Chỉnh sửa thông tin cá nhân',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          if (!_isEditing)
                            OutlinedButton.icon(
                              onPressed: () => setState(() => _isEditing = true),
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('Chỉnh sửa'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _nameCtrl,
                        enabled: _isEditing,
                        decoration: const InputDecoration(labelText: 'Họ và tên'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Họ tên không được trống' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _phoneCtrl,
                        enabled: _isEditing,
                        decoration: const InputDecoration(labelText: 'Số điện thoại'),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _targetCtrl,
                        enabled: _isEditing,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Điểm mục tiêu (Thang điểm 10)'),
                      ),

                      if (_isEditing) ...[
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => setState(() => _isEditing = false),
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

  Widget _buildMetricBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  final bool initialIsRegister;

  const AuthScreen({
    super.key,
    this.initialIsRegister = false,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isRegister;

  // Login Controllers
  final _loginFormKey = GlobalKey<FormState>();
  final _loginUserCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  bool _loginObscure = true;

  // Register Controllers
  final _regFormKey = GlobalKey<FormState>();
  final _regFullNameCtrl = TextEditingController();
  final _regUserCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPhoneCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  final _regConfirmPassCtrl = TextEditingController();
  bool _regObscure = true;
  UserRole _selectedRole = UserRole.student;

  @override
  void initState() {
    super.initState();
    _isRegister = widget.initialIsRegister;
  }

  @override
  void dispose() {
    _loginUserCtrl.dispose();
    _loginPassCtrl.dispose();
    _regFullNameCtrl.dispose();
    _regUserCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPhoneCtrl.dispose();
    _regPassCtrl.dispose();
    _regConfirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_loginUserCtrl.text, _loginPassCtrl.text);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Đăng nhập thất bại'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _handleQuickLogin(String username, String password) async {
    _loginUserCtrl.text = username;
    _loginPassCtrl.text = password;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(username, password);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Đăng nhập thất bại'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _handleRegister() async {
    if (!_regFormKey.currentState!.validate()) return;
    if (_regPassCtrl.text != _regConfirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu xác nhận không trùng khớp'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      userName: _regUserCtrl.text,
      email: _regEmailCtrl.text,
      password: _regPassCtrl.text,
      fullName: _regFullNameCtrl.text,
      phoneNumber: _regPhoneCtrl.text.isNotEmpty ? _regPhoneCtrl.text : null,
      role: _selectedRole,
    );

    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Đăng ký thất bại'),
          backgroundColor: AppColors.danger,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký tài khoản thành công!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              elevation: 4,
              shadowColor: Colors.black.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppColors.border),
              ),
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Logo & Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EDUTECH',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'Nền tảng thi trắc nghiệm trực tuyến',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Tab Selector: Đăng nhập vs Đăng ký
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _isRegister = false;
                                  auth.clearError();
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !_isRegister ? AppColors.surface : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: !_isRegister
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  'Đăng Nhập',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: !_isRegister ? FontWeight.w700 : FontWeight.w500,
                                    color: !_isRegister ? AppColors.primary : AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _isRegister = true;
                                  auth.clearError();
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _isRegister ? AppColors.surface : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: _isRegister
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  'Đăng Ký',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: _isRegister ? FontWeight.w700 : FontWeight.w500,
                                    color: _isRegister ? AppColors.primary : AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.dangerSoft,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                auth.errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // FORM CONTENT
                    if (!_isRegister) _buildLoginForm() else _buildRegisterForm(),

                    const SizedBox(height: 24),

                    // Quick Demo Login Section (very helpful for instructors and tests)
                    _buildDemoAccountsCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tên đăng nhập hoặc Email *',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _loginUserCtrl,
            decoration: const InputDecoration(
              hintText: 'Nhập tên đăng nhập hoặc email',
              prefixIcon: Icon(Icons.person_outline, size: 20),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập tên đăng nhập hoặc email' : null,
          ),
          const SizedBox(height: 16),

          const Text(
            'Mật khẩu *',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _loginPassCtrl,
            obscureText: _loginObscure,
            decoration: InputDecoration(
              hintText: 'Nhập mật khẩu',
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _loginObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 20,
                ),
                onPressed: () => setState(() => _loginObscure = !_loginObscure),
              ),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập mật khẩu' : null,
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _handleLogin,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Đăng Nhập',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _regFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Họ và tên *',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _regFullNameCtrl,
            decoration: const InputDecoration(
              hintText: 'Ví dụ: Nguyễn Văn An',
              prefixIcon: Icon(Icons.badge_outlined, size: 20),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập họ và tên' : null,
          ),
          const SizedBox(height: 14),

          const Text(
            'Tên đăng nhập *',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _regUserCtrl,
            decoration: const InputDecoration(
              hintText: 'Ví dụ: vanan123',
              prefixIcon: Icon(Icons.account_circle_outlined, size: 20),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Vui lòng nhập tên đăng nhập';
              if (v.trim().length < 3) return 'Tên đăng nhập tối thiểu 3 ký tự';
              return null;
            },
          ),
          const SizedBox(height: 14),

          const Text(
            'Email *',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _regEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'vanan@gmail.com',
              prefixIcon: Icon(Icons.email_outlined, size: 20),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
              if (!v.contains('@') || !v.contains('.')) return 'Email không hợp lệ';
              return null;
            },
          ),
          const SizedBox(height: 14),

          const Text(
            'Số điện thoại (tùy chọn)',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _regPhoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: '0912345678',
              prefixIcon: Icon(Icons.phone_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 14),

          const Text(
            'Vai trò đăng ký *',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<UserRole>(
            initialValue: _selectedRole,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.manage_accounts_outlined, size: 20),
            ),
            items: const [
              DropdownMenuItem(
                value: UserRole.student,
                child: Text('👨‍🎓 Học viên (Tham gia thi & luyện tập)'),
              ),
              DropdownMenuItem(
                value: UserRole.teacher,
                child: Text('👩‍🏫 Giáo viên (Tạo đề thi & ngân hàng câu hỏi)'),
              ),
            ],
            onChanged: (role) {
              if (role != null) setState(() => _selectedRole = role);
            },
          ),
          const SizedBox(height: 14),

          const Text(
            'Mật khẩu *',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _regPassCtrl,
            obscureText: _regObscure,
            decoration: InputDecoration(
              hintText: 'Tối thiểu 6 ký tự',
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _regObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 20,
                ),
                onPressed: () => setState(() => _regObscure = !_regObscure),
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Vui lòng nhập mật khẩu';
              if (v.trim().length < 6) return 'Mật khẩu phải từ 6 ký tự trở lên';
              return null;
            },
          ),
          const SizedBox(height: 14),

          const Text(
            'Xác nhận mật khẩu *',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _regConfirmPassCtrl,
            obscureText: _regObscure,
            decoration: const InputDecoration(
              hintText: 'Nhập lại mật khẩu vừa nhập',
              prefixIcon: Icon(Icons.lock_reset_outlined, size: 20),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng xác nhận mật khẩu' : null,
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _handleRegister,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Tạo Tài Khoản',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoAccountsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flash_on, color: AppColors.primary, size: 18),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Tài khoản mẫu thử nghiệm (Mật khẩu: 123456)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildDemoChip('👨‍🎓 Học viên: duyki', () => _handleQuickLogin('duyki', '123456')),
              _buildDemoChip('👩‍🏫 Giáo viên: gv_huong', () => _handleQuickLogin('gv_huong', '123456')),
              _buildDemoChip('👑 Admin: admin', () => _handleQuickLogin('admin', '123456')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDemoChip(String label, VoidCallback onTap) {
    return ActionChip(
      onPressed: onTap,
      label: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
      ),
      backgroundColor: Colors.white,
      side: const BorderSide(color: AppColors.border),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }
}

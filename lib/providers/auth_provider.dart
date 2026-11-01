import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/quiz_repository.dart';

class AuthProvider extends ChangeNotifier {
  final QuizRepository _repo = QuizRepository();
  AppUser? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  AuthProvider() {
    // Start unauthenticated so user sees login/register screen
    _currentUser = null;
  }

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isTeacher => _currentUser?.isTeacher ?? false;
  bool get isStudent => _currentUser?.isStudent ?? true;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void switchUser(AppUser user) {
    if (!kDebugMode) return;
    _currentUser = user;
    _repo.setActiveUser(_currentUser);
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> switchRole(UserRole newRole) async {
    if (!kDebugMode || _currentUser == null) return;
    _currentUser = _currentUser!.copyWith(role: newRole);
    _repo.setActiveUser(_currentUser);
    await _repo.updateUser(_currentUser!);
    notifyListeners();
  }

  Future<bool> changeUserRole(String userId, UserRole newRole) async {
    if (!isAdmin) {
      _errorMessage = 'Chỉ Admin mới có quyền thay đổi vai trò người dùng';
      notifyListeners();
      return false;
    }
    final ok = await _repo.changeUserRole(userId, newRole, caller: _currentUser);
    if (ok && _currentUser?.id == userId) {
      _currentUser = _currentUser!.copyWith(role: newRole);
      _repo.setActiveUser(_currentUser);
    }
    notifyListeners();
    return ok;
  }

  Future<bool> login(String usernameOrEmail, String password) async {
    _errorMessage = null;
    final trimmedUser = usernameOrEmail.trim();
    final trimmedPass = password.trim();

    if (trimmedUser.isEmpty || trimmedPass.isEmpty) {
      _errorMessage = 'Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final user = await _repo.authenticate(trimmedUser, trimmedPass);
    _isLoading = false;
    if (user != null) {
      _currentUser = user;
      _repo.setActiveUser(_currentUser);
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = _repo.lastError ?? 'Tên đăng nhập hoặc mật khẩu không chính xác';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String userName,
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    UserRole role = UserRole.student,
  }) async {
    _errorMessage = null;
    final u = userName.trim();
    final e = email.trim();
    final p = password.trim();
    final name = fullName.trim();

    if (u.isEmpty || e.isEmpty || p.isEmpty || name.isEmpty) {
      _errorMessage = 'Vui lòng điền đầy đủ các thông tin bắt buộc';
      notifyListeners();
      return false;
    }

    if (p.length < 6) {
      _errorMessage = 'Mật khẩu phải có tối thiểu 6 ký tự';
      notifyListeners();
      return false;
    }

    if (_repo.isUsernameTaken(u)) {
      _errorMessage = 'Tên đăng nhập "$u" đã tồn tại';
      notifyListeners();
      return false;
    }

    if (_repo.isEmailTaken(e)) {
      _errorMessage = 'Email "$e" đã được đăng ký';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final newUser = AppUser(
      id: '',
      userName: u,
      fullName: name,
      email: e,
      password: p,
      phoneNumber: phoneNumber?.trim(),
      role: role,
      diemMucTieu: 8.0,
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    );

    final created = await _repo.registerUser(newUser);
    _isLoading = false;
    if (created != null) {
      _currentUser = created;
      _repo.setActiveUser(_currentUser);
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = _repo.lastError ?? 'Không thể tạo tài khoản, vui lòng thử lại';
      notifyListeners();
      return false;
    }
  }

  Future<bool> seedSampleData() async {
    if (!kDebugMode || !isAdmin) return false;
    _isLoading = true;
    notifyListeners();
    final ok = await _repo.seedSampleData();
    if (ok && _repo.activeUser != null) {
      _currentUser = _repo.activeUser;
    }
    _errorMessage = _repo.lastError;
    _isLoading = false;
    notifyListeners();
    return ok;
  }

  Future<void> updateProfile({
    required String fullName,
    String? phoneNumber,
    double? diemMucTieu,
  }) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      fullName: fullName.trim(),
      phoneNumber: phoneNumber?.trim(),
      diemMucTieu: diemMucTieu,
    );
    _repo.setActiveUser(_currentUser);
    await _repo.updateUser(_currentUser!);
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    await _repo.signOut();
    _errorMessage = null;
    notifyListeners();
  }
}

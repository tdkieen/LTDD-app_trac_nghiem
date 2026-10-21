import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/quiz_repository.dart';

class AuthProvider extends ChangeNotifier {
  final QuizRepository _repo = QuizRepository();
  AppUser? _currentUser;

  AuthProvider() {
    // Default to the first student user (Duy Kì)
    final users = _repo.getUsers();
    if (users.isNotEmpty) {
      _currentUser = users.first;
    }
  }

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isTeacher => _currentUser?.isTeacher ?? false;
  bool get isStudent => _currentUser?.isStudent ?? true;

  void switchUser(AppUser user) {
    _currentUser = user;
    notifyListeners();
  }

  void switchRole(UserRole newRole) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(role: newRole);
    _repo.updateUser(_currentUser!);
    notifyListeners();
  }

  void updateProfile({
    required String fullName,
    String? phoneNumber,
    double? diemMucTieu,
  }) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      fullName: fullName.trim(),
      phoneNumber: phoneNumber?.trim(),
      diemMucTieu: diemMucTieu,
    );
    _repo.updateUser(_currentUser!);
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void login(String userName) {
    final users = _repo.getUsers();
    try {
      _currentUser = users.firstWhere(
        (u) => u.userName.toLowerCase() == userName.toLowerCase().trim() ||
               u.email.toLowerCase() == userName.toLowerCase().trim(),
      );
    } catch (_) {
      // Create guest student
      _currentUser = AppUser(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
        userName: userName,
        fullName: userName,
        email: '$userName@edutech.vn',
        role: UserRole.student,
      );
    }
    notifyListeners();
  }
}

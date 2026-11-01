import 'package:flutter/material.dart';
import '../models/thong_bao.dart';
import '../services/quiz_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final QuizRepository _repo = QuizRepository();

  List<ThongBao> getNotifications(String? userId) {
    return _repo.getNotifications(userId);
  }

  int getUnreadCount(String? userId) {
    return _repo.getUnreadNotificationCount(userId);
  }

  Future<void> markAsRead(String id) async {
    await _repo.markAsRead(id);
    notifyListeners();
  }

  Future<void> markAllAsRead(String? userId) async {
    await _repo.markAllAsRead(userId);
    notifyListeners();
  }

  Future<void> sendNotification({
    required String noiDung,
    String? userId,
    String loaiIcon = 'info',
  }) async {
    await _repo.sendNotification(
      noiDung: noiDung,
      userId: userId,
      loaiIcon: loaiIcon,
    );
    notifyListeners();
  }
}

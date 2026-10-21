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

  void markAsRead(int id) {
    _repo.markAsRead(id);
    notifyListeners();
  }

  void markAllAsRead(String? userId) {
    _repo.markAllAsRead(userId);
    notifyListeners();
  }

  void sendNotification({
    required String noiDung,
    String? userId,
    String loaiIcon = 'info',
  }) {
    _repo.sendNotification(
      noiDung: noiDung,
      userId: userId,
      loaiIcon: loaiIcon,
    );
    notifyListeners();
  }
}

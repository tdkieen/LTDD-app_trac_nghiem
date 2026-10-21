import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/chu_de.dart';
import '../models/de_thi.dart';
import '../models/cau_hoi.dart';
import '../models/ket_qua_thi.dart';
import '../models/cau_hoi_sai.dart';
import '../models/de_thi_yeu_thich.dart';
import '../services/quiz_repository.dart';

class QuizProvider extends ChangeNotifier {
  final QuizRepository _repo = QuizRepository();

  String _selectedDifficulty = 'Tất cả';
  int? _selectedCategoryId;
  String _searchQuery = '';

  String get selectedDifficulty => _selectedDifficulty;
  int? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;

  // Filters
  void setDifficulty(String diff) {
    _selectedDifficulty = diff;
    notifyListeners();
  }

  void setCategory(int? catId) {
    _selectedCategoryId = catId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void resetFilters() {
    _selectedDifficulty = 'Tất cả';
    _selectedCategoryId = null;
    _searchQuery = '';
    notifyListeners();
  }

  // Data Getters
  List<DeThi> getFilteredExams() {
    return _repo.getExams(
      mucDo: _selectedDifficulty,
      maChuDe: _selectedCategoryId,
      search: _searchQuery,
    );
  }

  List<DeThi> getAllExams() => _repo.getExams();

  List<ChuDe> getCategories() => _repo.getCategories();

  List<CauHoi> getQuestions(int maDeThi) => _repo.getQuestionsByExam(maDeThi);

  List<DeThiYeuThich> getBookmarks(String userId) => _repo.getBookmarksByUser(userId);

  bool isBookmarked(String userId, int maDeThi) => _repo.isBookmarked(userId, maDeThi);

  void toggleBookmark(String userId, int maDeThi) {
    _repo.toggleBookmark(userId, maDeThi);
    notifyListeners();
  }

  List<CauHoiSai> getMistakes(String userId) => _repo.getMistakesByUser(userId);

  void deleteMistake(int id) {
    _repo.deleteMistake(id);
    notifyListeners();
  }

  List<KetQuaThi> getUserHistory(String userId) => _repo.getResultsByUser(userId);

  void deleteHistory(int id) {
    _repo.deleteResult(id);
    notifyListeners();
  }

  List<ExamLeaderboardItem> getExamLeaderboard(int maDeThi) => _repo.getLeaderboardByExam(maDeThi);

  List<OverallLeaderboardItem> getOverallLeaderboard() => _repo.getOverallLeaderboard();

  List<AppUser> getUsers() => _repo.getUsers();

  // Admin / Teacher operations
  void addExam({
    required String tenDeThi,
    required int maChuDe,
    required String mucDoKho,
    required int thoiGian,
    int soCauHoi = 10,
  }) {
    _repo.addExam(
      tenDeThi: tenDeThi,
      maChuDe: maChuDe,
      mucDoKho: mucDoKho,
      thoiGian: thoiGian,
      soCauHoi: soCauHoi,
    );
    notifyListeners();
  }

  void updateExam(DeThi exam) {
    _repo.updateExam(exam);
    notifyListeners();
  }

  void deleteExam(int id) {
    _repo.deleteExam(id);
    notifyListeners();
  }

  void addQuestion({
    required int maDeThi,
    required int maChuDe,
    required String noiDung,
    required String phuongAnA,
    required String phuongAnB,
    required String phuongAnC,
    required String phuongAnD,
    required String dapAnDung,
    String mucDoKho = 'Trung bình',
    bool laCauHoiNghe = false,
    String? audioPath,
    String? giaiThich,
  }) {
    _repo.addQuestion(
      maDeThi: maDeThi,
      maChuDe: maChuDe,
      noiDung: noiDung,
      phuongAnA: phuongAnA,
      phuongAnB: phuongAnB,
      phuongAnC: phuongAnC,
      phuongAnD: phuongAnD,
      dapAnDung: dapAnDung,
      mucDoKho: mucDoKho,
      laCauHoiNghe: laCauHoiNghe,
      audioPath: audioPath,
      giaiThich: giaiThich,
    );
    notifyListeners();
  }

  void deleteQuestion(int id) {
    _repo.deleteQuestion(id);
    notifyListeners();
  }

  bool addCategory(String name) {
    final success = _repo.addCategory(name);
    if (success) notifyListeners();
    return success;
  }

  bool deleteCategory(int id) {
    final success = _repo.deleteCategory(id);
    if (success) notifyListeners();
    return success;
  }

  void changeUserRole(String userId, UserRole newRole) {
    _repo.changeUserRole(userId, newRole);
    notifyListeners();
  }

  void deleteUser(String userId) {
    _repo.deleteUser(userId);
    notifyListeners();
  }
}

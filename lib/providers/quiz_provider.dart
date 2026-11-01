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
  bool _isLoading = false;
  String? _errorMessage;

  String get selectedDifficulty => _selectedDifficulty;
  int? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage ?? _repo.lastError;

  void clearError() {
    _errorMessage = null;
    _repo.lastError = null;
    notifyListeners();
  }

  Future<void> syncData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    await _repo.syncFromFirestore();
    _errorMessage = _repo.lastError;
    _isLoading = false;
    notifyListeners();
  }

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

  Future<bool> toggleBookmark(String userId, int maDeThi) async {
    final res = await _repo.toggleBookmark(userId, maDeThi);
    _errorMessage = _repo.lastError;
    notifyListeners();
    return res;
  }

  List<CauHoiSai> getMistakes(String userId) => _repo.getMistakesByUser(userId);

  Future<void> deleteMistake(String id) async {
    await _repo.deleteMistake(id);
    _errorMessage = _repo.lastError;
    notifyListeners();
  }

  List<KetQuaThi> getUserHistory(String userId) => _repo.getResultsByUser(userId);

  Future<void> deleteHistory(String id) async {
    await _repo.deleteResult(id);
    _errorMessage = _repo.lastError;
    notifyListeners();
  }

  List<ExamLeaderboardItem> getExamLeaderboard(int maDeThi) => _repo.getLeaderboardByExam(maDeThi);

  List<OverallLeaderboardItem> getOverallLeaderboard() => _repo.getOverallLeaderboard();

  List<AppUser> getUsers() => _repo.getUsers();

  // Admin / Teacher operations
  Future<DeThi> addExam({
    required String tenDeThi,
    required int maChuDe,
    required String mucDoKho,
    required int thoiGian,
    int soCauHoi = 10,
  }) async {
    _isLoading = true;
    notifyListeners();
    final created = await _repo.addExam(
      tenDeThi: tenDeThi,
      maChuDe: maChuDe,
      mucDoKho: mucDoKho,
      thoiGian: thoiGian,
      soCauHoi: soCauHoi,
    );
    _errorMessage = _repo.lastError;
    _isLoading = false;
    notifyListeners();
    return created;
  }

  Future<void> updateExam(DeThi exam) async {
    _isLoading = true;
    notifyListeners();
    await _repo.updateExam(exam);
    _errorMessage = _repo.lastError;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteExam(int id) async {
    _isLoading = true;
    notifyListeners();
    await _repo.deleteExam(id);
    _errorMessage = _repo.lastError;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addQuestion({
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
    String? imagePath,
    String? giaiThich,
  }) async {
    _isLoading = true;
    notifyListeners();
    await _repo.addQuestion(
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
      imagePath: imagePath,
      giaiThich: giaiThich,
    );
    _errorMessage = _repo.lastError;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteQuestion(int id) async {
    await _repo.deleteQuestion(id);
    _errorMessage = _repo.lastError;
    notifyListeners();
  }

  Future<bool> addCategory(String name) async {
    final success = await _repo.addCategory(name);
    _errorMessage = _repo.lastError;
    if (success) notifyListeners();
    return success;
  }

  Future<bool> deleteCategory(int id) async {
    final success = await _repo.deleteCategory(id);
    _errorMessage = _repo.lastError;
    if (success) notifyListeners();
    return success;
  }

  Future<bool> changeUserRole(String userId, UserRole newRole, {AppUser? caller}) async {
    final actor = caller ?? _repo.activeUser;
    if (actor == null || !actor.isAdmin) {
      return false;
    }
    final ok = await _repo.changeUserRole(userId, newRole, caller: actor);
    _errorMessage = _repo.lastError;
    if (ok) notifyListeners();
    return ok;
  }

  Future<void> deleteUser(String userId) async {
    await _repo.deleteUser(userId);
    _errorMessage = _repo.lastError;
    notifyListeners();
  }
}

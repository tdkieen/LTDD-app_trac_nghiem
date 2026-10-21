import '../models/app_user.dart';
import '../models/chu_de.dart';
import '../models/de_thi.dart';
import '../models/cau_hoi.dart';
import '../models/ket_qua_thi.dart';
import '../models/cau_hoi_sai.dart';
import '../models/de_thi_yeu_thich.dart';
import '../models/thong_bao.dart';
import 'mock_data.dart';

class OverallLeaderboardItem {
  final String userId;
  final String name;
  final String email;
  final int totalExams;
  final double averageScore;
  final double highestScore;

  OverallLeaderboardItem({
    required this.userId,
    required this.name,
    required this.email,
    required this.totalExams,
    required this.averageScore,
    required this.highestScore,
  });
}

class ExamLeaderboardItem {
  final String userName;
  final double highestScore;
  final DateTime date;

  ExamLeaderboardItem({
    required this.userName,
    required this.highestScore,
    required this.date,
  });
}

class QuizRepository {
  static final QuizRepository _instance = QuizRepository._internal();
  factory QuizRepository() => _instance;
  QuizRepository._internal() {
    _init();
  }

  final List<AppUser> _users = [];
  final List<ChuDe> _categories = [];
  final List<DeThi> _exams = [];
  final List<CauHoi> _questions = [];
  final List<KetQuaThi> _results = [];
  final List<CauHoiSai> _mistakes = [];
  final List<DeThiYeuThich> _bookmarks = [];
  final List<ThongBao> _notifications = [];

  void _init() {
    _users.addAll(MockData.initialUsers);
    _categories.addAll(MockData.initialCategories);
    _exams.addAll(MockData.initialExams);
    _questions.addAll(MockData.initialQuestions);
    _results.addAll(MockData.initialResults);
    _mistakes.addAll(MockData.initialMistakes);
    _bookmarks.addAll(MockData.initialBookmarks);
    _notifications.addAll(MockData.initialNotifications);
  }

  // ================= USERS =================
  List<AppUser> getUsers() => List.unmodifiable(_users);

  AppUser? getUserById(String id) {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  bool updateUser(AppUser user) {
    final idx = _users.indexWhere((u) => u.id == user.id);
    if (idx != -1) {
      _users[idx] = user;
      return true;
    }
    return false;
  }

  bool changeUserRole(String userId, UserRole newRole) {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      _users[idx] = _users[idx].copyWith(role: newRole);
      return true;
    }
    return false;
  }

  bool deleteUser(String userId) {
    final countBefore = _users.length;
    _users.removeWhere((u) => u.id == userId);
    return _users.length < countBefore;
  }

  // ================= CATEGORIES =================
  List<ChuDe> getCategories() => List.unmodifiable(_categories);

  ChuDe? getCategoryById(int id) {
    try {
      return _categories.firstWhere((c) => c.maChuDe == id);
    } catch (_) {
      return null;
    }
  }

  bool addCategory(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    final exists = _categories.any((c) => c.tenChuDe.toLowerCase() == trimmed.toLowerCase());
    if (exists) return false;

    final nextId = _categories.isEmpty
        ? 1
        : _categories.map((c) => c.maChuDe).reduce((a, b) => a > b ? a : b) + 1;
    _categories.add(ChuDe(maChuDe: nextId, tenChuDe: trimmed));
    return true;
  }

  bool deleteCategory(int id) {
    // Check if category is used
    final isUsedByExam = _exams.any((e) => e.maChuDe == id);
    final isUsedByQuestion = _questions.any((q) => q.maChuDe == id);
    if (isUsedByExam || isUsedByQuestion) return false;

    _categories.removeWhere((c) => c.maChuDe == id);
    return true;
  }

  // ================= EXAMS =================
  List<DeThi> getExams({String? mucDo, int? maChuDe, String? search}) {
    var list = _exams.map((e) {
      final category = getCategoryById(e.maChuDe);
      final questionCount = _questions.where((q) => q.maDeThi == e.maDeThi).length;
      return e.copyWith(
        chuDe: category,
        soCauHoi: questionCount > 0 ? questionCount : e.soCauHoi,
      );
    }).toList();

    if (mucDo != null && mucDo.isNotEmpty && mucDo != 'Tất cả') {
      list = list.where((e) => e.mucDoKho?.toLowerCase() == mucDo.toLowerCase()).toList();
    }
    if (maChuDe != null && maChuDe > 0) {
      list = list.where((e) => e.maChuDe == maChuDe).toList();
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      list = list.where((e) => e.tenDeThi.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  DeThi? getExamById(int id) {
    try {
      final e = _exams.firstWhere((ex) => ex.maDeThi == id);
      final cat = getCategoryById(e.maChuDe);
      final questionCount = _questions.where((q) => q.maDeThi == e.maDeThi).length;
      return e.copyWith(
        chuDe: cat,
        soCauHoi: questionCount > 0 ? questionCount : e.soCauHoi,
      );
    } catch (_) {
      return null;
    }
  }

  DeThi addExam({
    required String tenDeThi,
    required int maChuDe,
    required String mucDoKho,
    required int thoiGian,
    int soCauHoi = 10,
  }) {
    final nextId = _exams.isEmpty
        ? 101
        : _exams.map((e) => e.maDeThi).reduce((a, b) => a > b ? a : b) + 1;

    final newExam = DeThi(
      maDeThi: nextId,
      tenDeThi: tenDeThi.trim(),
      maChuDe: maChuDe,
      mucDoKho: mucDoKho,
      thoiGian: thoiGian,
      soCauHoi: soCauHoi,
      luotThi: 0,
      ngayTao: DateTime.now(),
      chuDe: getCategoryById(maChuDe),
    );
    _exams.add(newExam);
    return newExam;
  }

  bool updateExam(DeThi exam) {
    final idx = _exams.indexWhere((e) => e.maDeThi == exam.maDeThi);
    if (idx != -1) {
      _exams[idx] = exam.copyWith(chuDe: getCategoryById(exam.maChuDe));
      return true;
    }
    return false;
  }

  bool deleteExam(int id) {
    _questions.removeWhere((q) => q.maDeThi == id);
    _bookmarks.removeWhere((b) => b.maDeThi == id);
    _exams.removeWhere((e) => e.maDeThi == id);
    return true;
  }

  // ================= QUESTIONS =================
  List<CauHoi> getQuestionsByExam(int maDeThi) {
    return _questions.where((q) => q.maDeThi == maDeThi).toList();
  }

  CauHoi? getQuestionById(int id) {
    try {
      return _questions.firstWhere((q) => q.maCauHoi == id);
    } catch (_) {
      return null;
    }
  }

  CauHoi addQuestion({
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
    final nextId = _questions.isEmpty
        ? 1
        : _questions.map((q) => q.maCauHoi).reduce((a, b) => a > b ? a : b) + 1;

    final question = CauHoi(
      maCauHoi: nextId,
      maDeThi: maDeThi,
      maChuDe: maChuDe,
      noiDung: noiDung.trim(),
      phuongAnA: phuongAnA.trim(),
      phuongAnB: phuongAnB.trim(),
      phuongAnC: phuongAnC.trim(),
      phuongAnD: phuongAnD.trim(),
      dapAnDung: dapAnDung.toUpperCase().trim(),
      mucDoKho: mucDoKho,
      laCauHoiNghe: laCauHoiNghe,
      audioPath: audioPath,
      giaiThich: giaiThich,
    );
    _questions.add(question);

    // Update count in exam
    final examIdx = _exams.indexWhere((e) => e.maDeThi == maDeThi);
    if (examIdx != -1) {
      final count = _questions.where((q) => q.maDeThi == maDeThi).length;
      _exams[examIdx] = _exams[examIdx].copyWith(soCauHoi: count);
    }

    return question;
  }

  bool deleteQuestion(int id) {
    final q = getQuestionById(id);
    if (q != null) {
      _questions.removeWhere((item) => item.maCauHoi == id);
      _mistakes.removeWhere((m) => m.maCauHoi == id);
      if (q.maDeThi != null) {
        final examIdx = _exams.indexWhere((e) => e.maDeThi == q.maDeThi);
        if (examIdx != -1) {
          final count = _questions.where((item) => item.maDeThi == q.maDeThi).length;
          _exams[examIdx] = _exams[examIdx].copyWith(soCauHoi: count);
        }
      }
      return true;
    }
    return false;
  }

  // ================= EXAM TAKING & RESULTS =================
  KetQuaThi submitExam({
    required String userId,
    required int maDeThi,
    required Map<int, String> answers, // maCauHoi -> 'A' | 'B' | 'C' | 'D'
    required int thoiGianLamGiay,
  }) {
    final exam = getExamById(maDeThi);
    final questions = getQuestionsByExam(maDeThi);
    int correctCount = 0;
    final List<ChiTietKetQua> details = [];

    for (final q in questions) {
      final chosen = answers[q.maCauHoi];
      final isCorrect = chosen != null && chosen.toUpperCase() == (q.dapAnDung ?? '').toUpperCase();
      if (isCorrect) {
        correctCount++;
      } else {
        // Record into Mistake Notebook
        recordMistake(userId: userId, maCauHoi: q.maCauHoi, dapAnDaChon: chosen);
      }

      details.add(ChiTietKetQua(
        maCauHoi: q.maCauHoi,
        noiDung: q.noiDung,
        phuongAnA: q.phuongAnA,
        phuongAnB: q.phuongAnB,
        phuongAnC: q.phuongAnC,
        phuongAnD: q.phuongAnD,
        dapAnChon: chosen,
        dapAnDung: q.dapAnDung,
        laDung: isCorrect,
      ));
    }

    final totalQuestions = questions.isNotEmpty ? questions.length : (exam?.soCauHoi ?? 10);
    final score = totalQuestions > 0 ? (correctCount / totalQuestions) * 10.0 : 0.0;
    final roundedScore = double.parse(score.toStringAsFixed(1));

    final nextId = _results.isEmpty
        ? 1
        : _results.map((r) => r.maKetQua).reduce((a, b) => a > b ? a : b) + 1;

    final user = getUserById(userId);

    final result = KetQuaThi(
      maKetQua: nextId,
      userId: userId,
      maDeThi: maDeThi,
      tongDiem: roundedScore,
      soCauDung: correctCount,
      tongSoCau: totalQuestions,
      thoiGianLamGiay: thoiGianLamGiay,
      ngayThi: DateTime.now(),
      chiTiet: details,
      deThi: exam,
      userName: user?.fullName ?? user?.userName ?? 'Ẩn danh',
    );

    _results.insert(0, result);

    // Increase exam take count
    final examIdx = _exams.indexWhere((e) => e.maDeThi == maDeThi);
    if (examIdx != -1) {
      _exams[examIdx] = _exams[examIdx].copyWith(luotThi: _exams[examIdx].luotThi + 1);
    }

    return result;
  }

  List<KetQuaThi> getResultsByUser(String userId) {
    return _results.where((r) => r.userId == userId).map((r) {
      return KetQuaThi(
        maKetQua: r.maKetQua,
        userId: r.userId,
        maDeThi: r.maDeThi,
        tongDiem: r.tongDiem,
        soCauDung: r.soCauDung,
        tongSoCau: r.tongSoCau,
        thoiGianLamGiay: r.thoiGianLamGiay,
        ngayThi: r.ngayThi,
        chiTiet: r.chiTiet,
        deThi: getExamById(r.maDeThi),
        userName: r.userName,
      );
    }).toList();
  }

  KetQuaThi? getResultById(int id) {
    try {
      final r = _results.firstWhere((res) => res.maKetQua == id);
      return KetQuaThi(
        maKetQua: r.maKetQua,
        userId: r.userId,
        maDeThi: r.maDeThi,
        tongDiem: r.tongDiem,
        soCauDung: r.soCauDung,
        tongSoCau: r.tongSoCau,
        thoiGianLamGiay: r.thoiGianLamGiay,
        ngayThi: r.ngayThi,
        chiTiet: r.chiTiet,
        deThi: getExamById(r.maDeThi),
        userName: r.userName,
      );
    } catch (_) {
      return null;
    }
  }

  bool deleteResult(int id) {
    final before = _results.length;
    _results.removeWhere((r) => r.maKetQua == id);
    return _results.length < before;
  }

  List<ExamLeaderboardItem> getLeaderboardByExam(int maDeThi) {
    final examResults = _results.where((r) => r.maDeThi == maDeThi).toList();
    final Map<String, ExamLeaderboardItem> map = {};

    for (final r in examResults) {
      final userName = r.userName ?? 'Thí sinh';
      if (!map.containsKey(userName) || (r.tongDiem > map[userName]!.highestScore)) {
        map[userName] = ExamLeaderboardItem(
          userName: userName,
          highestScore: r.tongDiem,
          date: r.ngayThi,
        );
      }
    }

    final list = map.values.toList();
    list.sort((a, b) => b.highestScore.compareTo(a.highestScore));
    return list.take(5).toList();
  }

  List<OverallLeaderboardItem> getOverallLeaderboard() {
    final List<OverallLeaderboardItem> list = [];

    for (final user in _users) {
      final userResults = _results.where((r) => r.userId == user.id).toList();
      if (userResults.isNotEmpty) {
        final totalExams = userResults.length;
        final sumScore = userResults.fold<double>(0.0, (acc, curr) => acc + curr.tongDiem);
        final avgScore = double.parse((sumScore / totalExams).toStringAsFixed(1));
        final maxScore = userResults.map((r) => r.tongDiem).reduce((a, b) => a > b ? a : b);

        list.add(OverallLeaderboardItem(
          userId: user.id,
          name: user.fullName.isNotEmpty ? user.fullName : user.userName,
          email: user.email,
          totalExams: totalExams,
          averageScore: avgScore,
          highestScore: maxScore,
        ));
      }
    }

    list.sort((a, b) {
      final cmp = b.averageScore.compareTo(a.averageScore);
      if (cmp != 0) return cmp;
      return b.totalExams.compareTo(a.totalExams);
    });

    return list;
  }

  // ================= BOOKMARKS =================
  List<DeThiYeuThich> getBookmarksByUser(String userId) {
    return _bookmarks.where((b) => b.userId == userId).map((b) {
      return DeThiYeuThich(
        id: b.id,
        userId: b.userId,
        maDeThi: b.maDeThi,
        deThi: getExamById(b.maDeThi),
        ngayLuu: b.ngayLuu,
      );
    }).toList();
  }

  bool isBookmarked(String userId, int maDeThi) {
    return _bookmarks.any((b) => b.userId == userId && b.maDeThi == maDeThi);
  }

  bool toggleBookmark(String userId, int maDeThi) {
    final idx = _bookmarks.indexWhere((b) => b.userId == userId && b.maDeThi == maDeThi);
    if (idx != -1) {
      _bookmarks.removeAt(idx);
      return false; // Removed
    } else {
      final nextId = _bookmarks.isEmpty
          ? 1
          : _bookmarks.map((b) => b.id).reduce((a, b) => a > b ? a : b) + 1;
      _bookmarks.add(DeThiYeuThich(
        id: nextId,
        userId: userId,
        maDeThi: maDeThi,
        deThi: getExamById(maDeThi),
      ));
      return true; // Added
    }
  }

  // ================= MISTAKE NOTEBOOK =================
  List<CauHoiSai> getMistakesByUser(String userId) {
    return _mistakes.where((m) => m.userId == userId).map((m) {
      final q = getQuestionById(m.maCauHoi);
      return CauHoiSai(
        id: m.id,
        userId: m.userId,
        maCauHoi: m.maCauHoi,
        cauHoi: q?.copyWith(giaiThich: q.giaiThich ?? 'Đáp án chính xác là ${q.dapAnDung}.'),
        dapAnDaChon: m.dapAnDaChon,
        lanSai: m.lanSai,
        lanCuoiSai: m.lanCuoiSai,
      );
    }).toList();
  }

  void recordMistake({
    required String userId,
    required int maCauHoi,
    String? dapAnDaChon,
  }) {
    final idx = _mistakes.indexWhere((m) => m.userId == userId && m.maCauHoi == maCauHoi);
    if (idx != -1) {
      final existing = _mistakes[idx];
      _mistakes[idx] = existing.copyWith(
        lanSai: existing.lanSai + 1,
        lanCuoiSai: DateTime.now(),
        dapAnDaChon: dapAnDaChon,
      );
    } else {
      final nextId = _mistakes.isEmpty
          ? 1
          : _mistakes.map((m) => m.id).reduce((a, b) => a > b ? a : b) + 1;
      _mistakes.add(CauHoiSai(
        id: nextId,
        userId: userId,
        maCauHoi: maCauHoi,
        dapAnDaChon: dapAnDaChon,
        lanSai: 1,
        lanCuoiSai: DateTime.now(),
      ));
    }
  }

  bool deleteMistake(int id) {
    final before = _mistakes.length;
    _mistakes.removeWhere((m) => m.id == id);
    return _mistakes.length < before;
  }

  // ================= NOTIFICATIONS =================
  List<ThongBao> getNotifications(String? userId) {
    return _notifications
        .where((n) => n.userId == null || n.userId == userId)
        .toList()
      ..sort((a, b) => b.thoiGian.compareTo(a.thoiGian));
  }

  int getUnreadNotificationCount(String? userId) {
    return _notifications.where((n) => (n.userId == null || n.userId == userId) && !n.daDoc).length;
  }

  void markAsRead(int id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(daDoc: true);
    }
  }

  void markAllAsRead(String? userId) {
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == null || _notifications[i].userId == userId) {
        _notifications[i] = _notifications[i].copyWith(daDoc: true);
      }
    }
  }

  void sendNotification({
    required String noiDung,
    String? userId,
    String loaiIcon = 'info',
  }) {
    final nextId = _notifications.isEmpty
        ? 1
        : _notifications.map((n) => n.id).reduce((a, b) => a > b ? a : b) + 1;
    _notifications.insert(0, ThongBao(
      id: nextId,
      userId: userId,
      noiDung: noiDung,
      loaiIcon: loaiIcon,
      daDoc: false,
      thoiGian: DateTime.now(),
    ));
  }
}

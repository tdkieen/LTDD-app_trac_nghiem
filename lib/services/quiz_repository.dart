import 'dart:async';
import 'package:firebase_core/firebase_core.dart' hide FirebaseService;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../models/chu_de.dart';
import '../models/de_thi.dart';
import '../models/cau_hoi.dart';
import '../models/ket_qua_thi.dart';
import '../models/cau_hoi_sai.dart';
import '../models/de_thi_yeu_thich.dart';
import '../models/thong_bao.dart';
import 'firebase_service.dart';
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
  final String userId;
  final String userName;
  final double highestScore;
  final DateTime date;

  ExamLeaderboardItem({
    this.userId = '',
    required this.userName,
    required this.highestScore,
    required this.date,
  });
}

class QuizRepository {
  static final QuizRepository _instance = QuizRepository._internal();
  factory QuizRepository() => _instance;
  QuizRepository._internal() {
    _initMockCache();
  }

  final FirebaseService _firebase = FirebaseService();
  bool useMockOnly = false;
  bool isInitialSynced = false;
  String? lastError;
  final ValueNotifier<int> dataVersion = ValueNotifier<int>(0);

  StreamSubscription<List<DeThi>>? _examsSub;
  StreamSubscription<List<CauHoi>>? _questionsSub;
  StreamSubscription<List<ThongBao>>? _notificationsSub;

  final List<AppUser> _users = [];
  final List<ChuDe> _categories = [];
  final List<DeThi> _exams = [];
  final List<CauHoi> _questions = [];
  final List<KetQuaThi> _results = [];
  final List<CauHoiSai> _mistakes = [];
  final List<DeThiYeuThich> _bookmarks = [];
  final List<ThongBao> _notifications = [];
  AppUser? _activeUser;

  bool get _useRemote => !useMockOnly && _firebase.isAvailable;
  bool get isSyncedOrOffline => isInitialSynced || !_useRemote;

  AppUser? get activeUser => _activeUser;
  void setActiveUser(AppUser? user) {
    _activeUser = user;
  }

  void _initMockCache() {
    _users
      ..clear()
      ..addAll(MockData.initialUsers);
    _categories
      ..clear()
      ..addAll(MockData.initialCategories);
    _exams
      ..clear()
      ..addAll(MockData.initialExams);
    _questions
      ..clear()
      ..addAll(MockData.initialQuestions);
    _results
      ..clear()
      ..addAll(MockData.initialResults);
    _mistakes
      ..clear()
      ..addAll(MockData.initialMistakes);
    _bookmarks
      ..clear()
      ..addAll(MockData.initialBookmarks);
    _notifications
      ..clear()
      ..addAll(MockData.initialNotifications);
    _activeUser = null;
    lastError = null;
  }

  void resetForTesting({bool mockOnly = true}) {
    stopRealtimeListeners();
    useMockOnly = mockOnly;
    isInitialSynced = false;
    _initMockCache();
  }

  Stream<List<DeThi>> watchExams() => _firebase.watchExams();
  Stream<List<CauHoi>> watchQuestions() => _firebase.watchQuestions();
  Stream<List<ThongBao>> watchNotifications() => _firebase.watchNotifications();

  Future<bool> checkFirebaseConnection({Duration timeout = const Duration(seconds: 5)}) async {
    if (!_useRemote) return false;
    return _firebase.checkConnection(timeout: timeout);
  }

  void startRealtimeListeners() {
    if (!_useRemote) return;
    _examsSub ??= _firebase.watchExams().listen(
      (remoteExams) {
        if (remoteExams.isNotEmpty) {
          _exams
            ..clear()
            ..addAll(remoteExams);
          dataVersion.value++;
        }
      },
      onError: (_) {},
    );
    _questionsSub ??= _firebase.watchQuestions().listen(
      (remoteQuestions) {
        if (remoteQuestions.isNotEmpty) {
          _questions
            ..clear()
            ..addAll(remoteQuestions);
          dataVersion.value++;
        }
      },
      onError: (_) {},
    );
    _notificationsSub ??= _firebase.watchNotifications().listen(
      (remoteNotifs) {
        if (remoteNotifs.isNotEmpty) {
          _notifications
            ..clear()
            ..addAll(remoteNotifs);
          dataVersion.value++;
        }
      },
      onError: (_) {},
    );
  }

  void stopRealtimeListeners() {
    _examsSub?.cancel();
    _examsSub = null;
    _questionsSub?.cancel();
    _questionsSub = null;
    _notificationsSub?.cancel();
    _notificationsSub = null;
  }

  Future<void> syncFromFirestore() async {
    if (!_useRemote) {
      isInitialSynced = true;
      return;
    }
    try {
      lastError = null;
      final results = await Future.wait([
        _firebase.getUsers(),
        _firebase.getCategories(),
        _firebase.getExams(),
        _firebase.getQuestions(),
        _firebase.getResults(),
        _firebase.getMistakes(),
        _firebase.getBookmarks(),
        _firebase.getNotifications(),
      ]);

      final users = results[0] as List<AppUser>;
      final categories = results[1] as List<ChuDe>;
      final exams = results[2] as List<DeThi>;
      final questions = results[3] as List<CauHoi>;
      final examResults = results[4] as List<KetQuaThi>;
      final mistakes = results[5] as List<CauHoiSai>;
      final bookmarks = results[6] as List<DeThiYeuThich>;
      final notifications = results[7] as List<ThongBao>;

      if (users.isNotEmpty) {
        _users
          ..clear()
          ..addAll(users);
      }
      if (categories.isNotEmpty) {
        _categories
          ..clear()
          ..addAll(categories);
      }
      if (exams.isNotEmpty) {
        _exams
          ..clear()
          ..addAll(exams);
      }
      if (questions.isNotEmpty) {
        _questions
          ..clear()
          ..addAll(questions);
      }
      if (examResults.isNotEmpty || exams.isNotEmpty) {
        _results
          ..clear()
          ..addAll(examResults);
      }
      if (mistakes.isNotEmpty || exams.isNotEmpty) {
        _mistakes
          ..clear()
          ..addAll(mistakes);
      }
      if (bookmarks.isNotEmpty || exams.isNotEmpty) {
        _bookmarks
          ..clear()
          ..addAll(bookmarks);
      }
      if (notifications.isNotEmpty) {
        _notifications
          ..clear()
          ..addAll(notifications);
      }
    } catch (e) {
      lastError = 'Không thể đồng bộ dữ liệu từ máy chủ: $e';
    } finally {
      isInitialSynced = true;
      startRealtimeListeners();
    }
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

  bool isUsernameTaken(String username) {
    final query = username.trim().toLowerCase();
    return _users.any((u) => u.userName.toLowerCase() == query);
  }

  bool isEmailTaken(String email) {
    final query = email.trim().toLowerCase();
    return _users.any((u) => u.email.toLowerCase() == query);
  }

  Future<AppUser?> registerUser(AppUser user) async {
    if (isUsernameTaken(user.userName) || isEmailTaken(user.email)) {
      return null;
    }
    try {
      lastError = null;
      AppUser createdUser = user;
      if (_useRemote) {
        final cred = await _firebase.createUserWithEmailAndPassword(
          user.email,
          user.password,
        );
        final uid = cred.user?.uid ?? _firebase.generateDocId(FirebaseService.colUsers);
        createdUser = user.copyWith(id: uid);
        await _firebase.setUser(createdUser);
      } else if (createdUser.id.isEmpty) {
        createdUser = user.copyWith(
          id: _firebase.generateDocId(FirebaseService.colUsers),
        );
      }
      _users.removeWhere((u) => u.id == createdUser.id || u.email.toLowerCase() == createdUser.email.toLowerCase());
      _users.add(createdUser);
      _activeUser = createdUser;
      return createdUser;
    } on FirebaseAuthException catch (e) {
      lastError = 'Lỗi đăng ký FirebaseAuth (${e.code}): ${e.message ?? e.code}';
      return null;
    } catch (e) {
      lastError = 'Lỗi kết nối mạng khi đăng ký người dùng: $e';
      return null;
    }
  }

  Future<bool> addUser(AppUser user) async {
    final created = await registerUser(user);
    return created != null;
  }

  Future<AppUser?> authenticate(String usernameOrEmail, String password) async {
    final query = usernameOrEmail.trim();
    final lowerQuery = query.toLowerCase();
    final trimmedPass = password.trim();

    if (_useRemote) {
      try {
        lastError = null;
        String email = query;
        AppUser? matchedLocal;
        for (final u in _users) {
          if (u.userName.toLowerCase() == lowerQuery || u.email.toLowerCase() == lowerQuery) {
            matchedLocal = u;
            break;
          }
        }
        if (!email.contains('@')) {
          if (matchedLocal != null) {
            email = matchedLocal.email;
          } else {
            final remoteMatch = await _firebase.getUserByUsernameOrEmail(query);
            if (remoteMatch != null) {
              matchedLocal = remoteMatch;
              email = remoteMatch.email;
            } else {
              for (final m in MockData.initialUsers) {
                if (m.userName.toLowerCase() == lowerQuery) {
                  matchedLocal = m;
                  email = m.email;
                  break;
                }
              }
            }
          }
        }

        UserCredential? cred;
        try {
          cred = await _firebase.signInWithEmailAndPassword(email, trimmedPass);
        } on FirebaseAuthException catch (e) {
          if (kDebugMode &&
              (e.code == 'user-not-found' ||
                  e.code == 'invalid-credential' ||
                  e.code == 'invalid-login-credentials' ||
                  e.code == 'wrong-password' ||
                  e.code == 'user-disabled')) {
            AppUser? mockUser;
            for (final m in MockData.initialUsers) {
              if (m.email.toLowerCase() == email.toLowerCase() ||
                  m.userName.toLowerCase() == lowerQuery) {
                mockUser = m;
                break;
              }
            }
            if (mockUser != null && trimmedPass == mockUser.password) {
              try {
                cred = await _firebase.createUserWithEmailAndPassword(mockUser.email, trimmedPass);
                matchedLocal = mockUser;
              } catch (_) {}
            }
          }
          if (cred == null) rethrow;
        }
        final uid = cred.user!.uid;

        AppUser? profile = await _firebase.getUserById(uid);
        if (profile == null) {
          final baseUser = matchedLocal ??
              AppUser(
                id: uid,
                userName: email.split('@').first,
                fullName: email.split('@').first,
                email: email,
                role: email.toLowerCase() == 'admin@edutech.vn' ? UserRole.admin : UserRole.student,
              );
          profile = baseUser.copyWith(id: uid);
          await _firebase.setUser(profile);
        }

        final idx = _users.indexWhere(
          (u) => u.id == uid || u.email.toLowerCase() == profile!.email.toLowerCase(),
        );
        if (idx != -1) {
          _users[idx] = profile;
        } else {
          _users.add(profile);
        }
        _activeUser = profile;
        return profile;
      } on FirebaseAuthException catch (e) {
        lastError = 'Đăng nhập thất bại (${e.code})';
        return null;
      } catch (e) {
        lastError = 'Lỗi kết nối khi đăng nhập: $e';
        return null;
      }
    }

    try {
      final user = _users.firstWhere(
        (u) => u.userName.toLowerCase() == lowerQuery || u.email.toLowerCase() == lowerQuery,
      );
      if (user.password == trimmedPass) {
        _activeUser = user;
        return user;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    _activeUser = null;
    if (_useRemote) {
      try {
        await _firebase.signOut();
      } catch (_) {}
    }
  }

  Future<bool> seedSampleData() async {
    if (!kDebugMode || _activeUser == null || !_activeUser!.isAdmin) {
      lastError = 'Chỉ Admin ở chế độ Debug mới được tạo dữ liệu mẫu';
      return false;
    }

    final currentAdmin = _activeUser!;
    try {
      lastError = null;
      final Map<String, String> userIdMap = {};

      if (_useRemote) {
        FirebaseApp? tempApp;
        FirebaseAuth? tempAuth;
        try {
          tempApp = await Firebase.initializeApp(
            name: 'SeedApp_${DateTime.now().millisecondsSinceEpoch}',
            options: Firebase.app().options,
          );
          tempAuth = FirebaseAuth.instanceFor(app: tempApp);
        } catch (_) {}

        for (final mockUser in MockData.initialUsers) {
          String uid = mockUser.id;
          if (mockUser.email.toLowerCase() == currentAdmin.email.toLowerCase()) {
            uid = _firebase.currentAuthUid ?? currentAdmin.id;
          } else if (tempAuth != null) {
            try {
              final cred = await tempAuth.createUserWithEmailAndPassword(
                email: mockUser.email,
                password: mockUser.password,
              );
              uid = cred.user?.uid ?? mockUser.id;
            } on FirebaseAuthException catch (e) {
              if (e.code == 'email-already-in-use') {
                try {
                  final cred = await tempAuth.signInWithEmailAndPassword(
                    email: mockUser.email,
                    password: mockUser.password,
                  );
                  uid = cred.user?.uid ?? mockUser.id;
                } catch (_) {}
              }
            } catch (_) {}
          }
          userIdMap[mockUser.id] = uid;
          final seededUser = mockUser.copyWith(id: uid);
          await _firebase.setUser(seededUser);
        }

        if (tempApp != null) {
          try {
            await tempApp.delete();
          } catch (_) {}
        }

        for (final cat in MockData.initialCategories) {
          await _firebase.setCategory(cat, docId: cat.maChuDe.toString());
        }
        for (final exam in MockData.initialExams) {
          await _firebase.setExam(exam, docId: exam.maDeThi.toString());
        }
        for (final q in MockData.initialQuestions) {
          await _firebase.setQuestion(q, docId: q.maCauHoi.toString());
        }
        for (final r in MockData.initialResults) {
          final mappedUid = userIdMap[r.userId] ?? r.userId;
          final seededResult = KetQuaThi(
            maKetQua: r.maKetQua,
            userId: mappedUid,
            maDeThi: r.maDeThi,
            tongDiem: r.tongDiem,
            soCauDung: r.soCauDung,
            tongSoCau: r.tongSoCau,
            thoiGianLamGiay: r.thoiGianLamGiay,
            ngayThi: r.ngayThi,
            chiTiet: r.chiTiet,
            deThi: r.deThi,
            userName: r.userName,
            soLanViPham: r.soLanViPham,
          );
          await _firebase.setResult(seededResult, docId: r.maKetQua);
        }
        for (final m in MockData.initialMistakes) {
          final mappedUid = userIdMap[m.userId] ?? m.userId;
          final seededMistake = m.copyWith(userId: mappedUid);
          await _firebase.setMistake(seededMistake, docId: m.id);
        }
        for (final b in MockData.initialBookmarks) {
          final mappedUid = userIdMap[b.userId] ?? b.userId;
          final seededBookmark = DeThiYeuThich(
            id: b.id,
            userId: mappedUid,
            maDeThi: b.maDeThi,
            deThi: b.deThi,
            ngayLuu: b.ngayLuu,
          );
          await _firebase.setBookmark(seededBookmark, docId: b.id);
        }
        for (final n in MockData.initialNotifications) {
          final mappedUid = n.userId != null ? (userIdMap[n.userId!] ?? n.userId) : null;
          final seededNotif = ThongBao(
            id: n.id,
            userId: mappedUid,
            noiDung: n.noiDung,
            loaiIcon: n.loaiIcon,
            daDoc: n.daDoc,
            thoiGian: n.thoiGian,
          );
          await _firebase.setNotification(seededNotif, docId: n.id);
        }

        // Re-authenticate admin if possible
        try {
          await _firebase.signInWithEmailAndPassword(
            currentAdmin.email,
            currentAdmin.password,
          );
        } catch (_) {}

        await syncFromFirestore();
        _activeUser = getUserById(userIdMap[currentAdmin.id] ?? currentAdmin.id) ?? currentAdmin;
      } else {
        _initMockCache();
        _activeUser = currentAdmin;
      }
      dataVersion.value++;
      return true;
    } catch (e) {
      lastError = 'Lỗi tạo dữ liệu mẫu: $e';
      return false;
    }
  }

  Future<bool> updateUser(AppUser user) async {
    final idx = _users.indexWhere((u) => u.id == user.id);
    try {
      lastError = null;
      if (_useRemote) {
        await _firebase.updateUser(user);
      }
      if (idx != -1) {
        _users[idx] = user;
      } else {
        _users.add(user);
      }
      return true;
    } catch (e) {
      lastError = 'Lỗi kết nối mạng khi cập nhật hồ sơ: $e';
      return false;
    }
  }

  Future<bool> changeUserRole(String userId, UserRole newRole, {AppUser? caller}) async {
    final actor = caller ?? _activeUser;
    if (actor == null || !actor.isAdmin) {
      return false;
    }
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      try {
        lastError = null;
        if (_useRemote) {
          await _firebase.updateUserRole(userId, newRole);
        }
        _users[idx] = _users[idx].copyWith(role: newRole);
        return true;
      } catch (e) {
        lastError = 'Lỗi kết nối mạng khi đổi vai trò: $e';
        return false;
      }
    }
    return false;
  }

  Future<bool> deleteUser(String userId) async {
    try {
      lastError = null;
      if (_useRemote) {
        await _firebase.deleteUser(userId);
      }
      final countBefore = _users.length;
      _users.removeWhere((u) => u.id == userId);
      return _users.length < countBefore;
    } catch (e) {
      lastError = 'Lỗi kết nối mạng khi xóa người dùng: $e';
      return false;
    }
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

  Future<bool> addCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    final exists = _categories.any((c) => c.tenChuDe.toLowerCase() == trimmed.toLowerCase());
    if (exists) return false;

    final docId = _firebase.generateDocId(FirebaseService.colCategories);
    final nextId = docId.hashCode.abs() > 0 ? docId.hashCode.abs() : DateTime.now().millisecondsSinceEpoch;
    final newCat = ChuDe(maChuDe: nextId, tenChuDe: trimmed);
    try {
      lastError = null;
      if (_useRemote) {
        await _firebase.setCategory(newCat, docId: docId);
      }
      _categories.add(newCat);
      return true;
    } catch (e) {
      lastError = 'Lỗi kết nối mạng khi thêm chủ đề: $e';
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    final isUsedByExam = _exams.any((e) => e.maChuDe == id);
    final isUsedByQuestion = _questions.any((q) => q.maChuDe == id);
    if (isUsedByExam || isUsedByQuestion) return false;

    try {
      lastError = null;
      if (_useRemote) {
        await _firebase.deleteCategory(id);
      }
      _categories.removeWhere((c) => c.maChuDe == id);
      return true;
    } catch (e) {
      lastError = 'Lỗi kết nối mạng khi xóa chủ đề: $e';
      return false;
    }
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

  Future<DeThi> addExam({
    required String tenDeThi,
    required int maChuDe,
    required String mucDoKho,
    required int thoiGian,
    int soCauHoi = 10,
  }) async {
    final docId = _firebase.generateDocId(FirebaseService.colExams);
    final nextId = docId.hashCode.abs() > 0 ? docId.hashCode.abs() : DateTime.now().millisecondsSinceEpoch;

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
    try {
      lastError = null;
      if (_useRemote) {
        await _firebase.setExam(newExam, docId: docId);
      }
      _exams.add(newExam);
    } catch (e) {
      lastError = 'Lỗi kết nối mạng khi tạo đề thi: $e';
      _exams.add(newExam);
    }
    return newExam;
  }

  Future<bool> updateExam(DeThi exam) async {
    final idx = _exams.indexWhere((e) => e.maDeThi == exam.maDeThi);
    if (idx != -1) {
      try {
        lastError = null;
        if (_useRemote) {
          await _firebase.updateExam(exam);
        }
        _exams[idx] = exam.copyWith(chuDe: getCategoryById(exam.maChuDe));
        return true;
      } catch (e) {
        lastError = 'Lỗi kết nối mạng khi cập nhật đề thi: $e';
        return false;
      }
    }
    return false;
  }

  Future<bool> deleteExam(int id) async {
    try {
      lastError = null;
      if (_useRemote) {
        await _firebase.deleteQuestionsByExam(id);
        await _firebase.deleteExam(id);
      }
      _questions.removeWhere((q) => q.maDeThi == id);
      _bookmarks.removeWhere((b) => b.maDeThi == id);
      _exams.removeWhere((e) => e.maDeThi == id);
      return true;
    } catch (e) {
      lastError = 'Lỗi kết nối mạng khi xóa đề thi: $e';
      return false;
    }
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

  Future<CauHoi> addQuestion({
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
    final docId = _firebase.generateDocId(FirebaseService.colQuestions);
    final nextId = docId.hashCode.abs() > 0 ? docId.hashCode.abs() : DateTime.now().millisecondsSinceEpoch;

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
      imagePath: imagePath,
      giaiThich: giaiThich,
    );
    try {
      lastError = null;
      if (_useRemote) {
        await _firebase.setQuestion(question, docId: docId);
      }
      _questions.add(question);

      final examIdx = _exams.indexWhere((e) => e.maDeThi == maDeThi);
      if (examIdx != -1) {
        final count = _questions.where((q) => q.maDeThi == maDeThi).length;
        _exams[examIdx] = _exams[examIdx].copyWith(soCauHoi: count);
        if (_useRemote) {
          await _firebase.updateExam(_exams[examIdx]);
        }
      }
    } catch (e) {
      lastError = 'Lỗi kết nối mạng khi thêm câu hỏi: $e';
      _questions.add(question);
    }

    return question;
  }

  Future<bool> deleteQuestion(int id) async {
    final q = getQuestionById(id);
    if (q != null) {
      try {
        lastError = null;
        if (_useRemote) {
          await _firebase.deleteQuestion(id);
        }
        _questions.removeWhere((item) => item.maCauHoi == id);
        _mistakes.removeWhere((m) => m.maCauHoi == id);
        if (q.maDeThi != null) {
          final examIdx = _exams.indexWhere((e) => e.maDeThi == q.maDeThi);
          if (examIdx != -1) {
            final count = _questions.where((item) => item.maDeThi == q.maDeThi).length;
            _exams[examIdx] = _exams[examIdx].copyWith(soCauHoi: count);
            if (_useRemote) {
              await _firebase.updateExam(_exams[examIdx]);
            }
          }
        }
        return true;
      } catch (e) {
        lastError = 'Lỗi kết nối mạng khi xóa câu hỏi: $e';
        return false;
      }
    }
    return false;
  }

  // ================= EXAM TAKING & RESULTS =================
  Future<KetQuaThi> submitExam({
    required String userId,
    required int maDeThi,
    required Map<int, String> answers, // maCauHoi -> 'A' | 'B' | 'C' | 'D'
    required int thoiGianLamGiay,
    List<CauHoi>? questions,
    bool isPractice = false,
    bool isMistakePractice = false,
    int soLanViPham = 0,
  }) async {
    final exam = getExamById(maDeThi);
    final examQuestions = questions ?? getQuestionsByExam(maDeThi);
    int correctCount = 0;
    final List<ChiTietKetQua> details = [];

    for (final q in examQuestions) {
      final chosen = answers[q.maCauHoi];
      final isCorrect = chosen != null && chosen.toUpperCase() == (q.dapAnDung ?? '').toUpperCase();
      if (isCorrect) {
        correctCount++;
        if (isMistakePractice || maDeThi == 9999) {
          await resolveMistake(userId: userId, maCauHoi: q.maCauHoi);
        }
      } else if (!isPractice) {
        await recordMistake(userId: userId, maCauHoi: q.maCauHoi, dapAnDaChon: chosen);
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

    final totalQuestions = examQuestions.isNotEmpty ? examQuestions.length : (exam?.soCauHoi ?? 10);
    final score = totalQuestions > 0 ? (correctCount / totalQuestions) * 10.0 : 0.0;
    final roundedScore = double.parse(score.toStringAsFixed(1));

    final nextId = _firebase.generateDocId(FirebaseService.colResults);

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
      soLanViPham: soLanViPham,
    );

    if (!isPractice) {
      try {
        lastError = null;
        if (_useRemote) {
          await _firebase.setResult(result, docId: nextId);
        }
      } catch (e) {
        lastError = 'Lỗi kết nối mạng khi lưu kết quả thi: $e';
      }
      _results.insert(0, result);

      final examIdx = _exams.indexWhere((e) => e.maDeThi == maDeThi);
      if (examIdx != -1) {
        _exams[examIdx] = _exams[examIdx].copyWith(luotThi: _exams[examIdx].luotThi + 1);
        if (_useRemote) {
          try {
            await _firebase.updateExam(_exams[examIdx]);
          } catch (_) {}
        }
      }
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
        soLanViPham: r.soLanViPham,
      );
    }).toList();
  }

  KetQuaThi? getResultById(String id) {
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
        soLanViPham: r.soLanViPham,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> deleteResult(String id) async {
    try {
      lastError = null;
      if (_useRemote) {
        await _firebase.deleteResult(id);
      }
      final before = _results.length;
      _results.removeWhere((r) => r.maKetQua == id);
      return _results.length < before;
    } catch (e) {
      lastError = 'Lỗi kết nối mạng khi xóa kết quả: $e';
      return false;
    }
  }

  List<ExamLeaderboardItem> getLeaderboardByExam(int maDeThi) {
    final examResults = _results.where((r) => r.maDeThi == maDeThi).toList();
    final Map<String, ExamLeaderboardItem> map = {};

    for (final r in examResults) {
      final uid = r.userId.isNotEmpty ? r.userId : (r.userName ?? 'guest');
      final user = getUserById(r.userId);
      final userName = r.userName ?? user?.fullName ?? user?.userName ?? 'Thí sinh';
      if (!map.containsKey(uid) || (r.tongDiem > map[uid]!.highestScore)) {
        map[uid] = ExamLeaderboardItem(
          userId: uid,
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

  Future<bool> toggleBookmark(String userId, int maDeThi) async {
    final idx = _bookmarks.indexWhere((b) => b.userId == userId && b.maDeThi == maDeThi);
    if (idx != -1) {
      final removed = _bookmarks[idx];
      try {
        lastError = null;
        if (_useRemote) {
          await _firebase.deleteBookmark(removed.id);
        }
      } catch (e) {
        lastError = 'Lỗi kết nối mạng khi bỏ lưu đề thi: $e';
      }
      _bookmarks.removeAt(idx);
      return false;
    } else {
      final nextId = _firebase.generateDocId(FirebaseService.colBookmarks);
      final added = DeThiYeuThich(
        id: nextId,
        userId: userId,
        maDeThi: maDeThi,
        deThi: getExamById(maDeThi),
      );
      try {
        lastError = null;
        if (_useRemote) {
          await _firebase.setBookmark(added, docId: nextId);
        }
      } catch (e) {
        lastError = 'Lỗi kết nối mạng khi lưu đề thi: $e';
      }
      _bookmarks.add(added);
      return true;
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

  Future<void> recordMistake({
    required String userId,
    required int maCauHoi,
    String? dapAnDaChon,
  }) async {
    final idx = _mistakes.indexWhere((m) => m.userId == userId && m.maCauHoi == maCauHoi);
    if (idx != -1) {
      final existing = _mistakes[idx];
      final updated = existing.copyWith(
        lanSai: existing.lanSai + 1,
        lanCuoiSai: DateTime.now(),
        dapAnDaChon: dapAnDaChon,
      );
      _mistakes[idx] = updated;
      if (_useRemote) {
        try {
          await _firebase.setMistake(updated, docId: updated.id);
        } catch (_) {}
      }
    } else {
      final nextId = _firebase.generateDocId(FirebaseService.colMistakes);
      final created = CauHoiSai(
        id: nextId,
        userId: userId,
        maCauHoi: maCauHoi,
        dapAnDaChon: dapAnDaChon,
        lanSai: 1,
        lanCuoiSai: DateTime.now(),
      );
      _mistakes.add(created);
      if (_useRemote) {
        try {
          await _firebase.setMistake(created, docId: nextId);
        } catch (_) {}
      }
    }
  }

  Future<void> resolveMistake({
    required String userId,
    required int maCauHoi,
  }) async {
    final idx = _mistakes.indexWhere((m) => m.userId == userId && m.maCauHoi == maCauHoi);
    if (idx != -1) {
      final existing = _mistakes[idx];
      final newLanSai = existing.lanSai - 1;
      if (newLanSai <= 0) {
        _mistakes.removeAt(idx);
        if (_useRemote) {
          try {
            await _firebase.deleteMistake(existing.id);
          } catch (_) {}
        }
      } else {
        final updated = existing.copyWith(lanSai: newLanSai);
        _mistakes[idx] = updated;
        if (_useRemote) {
          try {
            await _firebase.setMistake(updated, docId: updated.id);
          } catch (_) {}
        }
      }
    }
  }

  Future<bool> deleteMistake(String id) async {
    try {
      lastError = null;
      if (_useRemote) {
        await _firebase.deleteMistake(id);
      }
      final before = _mistakes.length;
      _mistakes.removeWhere((m) => m.id == id);
      return _mistakes.length < before;
    } catch (e) {
      lastError = 'Lỗi kết nối mạng khi xóa câu sai: $e';
      return false;
    }
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

  Future<void> markAsRead(String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(daDoc: true);
      if (_useRemote) {
        try {
          await _firebase.updateNotification(_notifications[idx]);
        } catch (_) {}
      }
    }
  }

  Future<void> markAllAsRead(String? userId) async {
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == null || _notifications[i].userId == userId) {
        _notifications[i] = _notifications[i].copyWith(daDoc: true);
        if (_useRemote) {
          try {
            await _firebase.updateNotification(_notifications[i]);
          } catch (_) {}
        }
      }
    }
  }

  Future<void> sendNotification({
    required String noiDung,
    String? userId,
    String loaiIcon = 'info',
  }) async {
    final nextId = _firebase.generateDocId(FirebaseService.colNotifications);
    final notif = ThongBao(
      id: nextId,
      userId: userId,
      noiDung: noiDung,
      loaiIcon: loaiIcon,
      daDoc: false,
      thoiGian: DateTime.now(),
    );
    _notifications.insert(0, notif);
    if (_useRemote) {
      try {
        await _firebase.setNotification(notif, docId: nextId);
      } catch (_) {}
    }
  }
}

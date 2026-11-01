import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/app_user.dart';
import '../models/chu_de.dart';
import '../models/de_thi.dart';
import '../models/cau_hoi.dart';
import '../models/ket_qua_thi.dart';
import '../models/cau_hoi_sai.dart';
import '../models/de_thi_yeu_thich.dart';
import '../models/thong_bao.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  static const String colUsers = 'users';
  static const String colCategories = 'categories';
  static const String colExams = 'exams';
  static const String colQuestions = 'questions';
  static const String colResults = 'results';
  static const String colMistakes = 'mistakes';
  static const String colBookmarks = 'bookmarks';
  static const String colNotifications = 'notifications';

  bool get isAvailable => Firebase.apps.isNotEmpty;

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;
  String? get currentAuthUid => isAvailable ? _auth.currentUser?.uid : null;
  int _localDocCounter = 0;

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
  }

  Future<void> signOut() async {
    if (!isAvailable) return;
    await _auth.signOut();
  }

  String generateDocId(String collection) {
    if (!isAvailable) {
      _localDocCounter++;
      return '${collection}_${DateTime.now().microsecondsSinceEpoch}_$_localDocCounter';
    }
    return _db.collection(collection).doc().id;
  }

  int generateHashId(String collection) {
    final docId = generateDocId(collection);
    final hash = docId.hashCode.abs();
    return hash > 0 ? hash : DateTime.now().millisecondsSinceEpoch;
  }

  Future<bool> checkConnection({Duration timeout = const Duration(seconds: 5)}) async {
    if (!isAvailable) return false;
    try {
      await _db
          .collection(colCategories)
          .limit(1)
          .get(const GetOptions(source: Source.server))
          .timeout(timeout);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ================= USERS =================
  Future<List<AppUser>> getUsers() async {
    if (!isAvailable) return [];
    final snap = await _db.collection(colUsers).get();
    return snap.docs.map((d) {
      final data = Map<String, dynamic>.from(d.data());
      data['id'] ??= d.id;
      return AppUser.fromJson(data);
    }).toList();
  }

  Future<AppUser?> getUserById(String id) async {
    if (!isAvailable) return null;
    final doc = await _db.collection(colUsers).doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    final data = Map<String, dynamic>.from(doc.data()!);
    data['id'] = doc.id;
    return AppUser.fromJson(data);
  }

  Future<AppUser?> getUserByUsernameOrEmail(String query) async {
    if (!isAvailable) return null;
    final q = query.trim();
    final byEmail = await _db.collection(colUsers).where('email', isEqualTo: q).limit(1).get();
    if (byEmail.docs.isNotEmpty) {
      final d = byEmail.docs.first;
      final data = Map<String, dynamic>.from(d.data());
      data['id'] = d.id;
      return AppUser.fromJson(data);
    }
    final byUser = await _db.collection(colUsers).where('userName', isEqualTo: q).limit(1).get();
    if (byUser.docs.isNotEmpty) {
      final d = byUser.docs.first;
      final data = Map<String, dynamic>.from(d.data());
      data['id'] = d.id;
      return AppUser.fromJson(data);
    }
    return null;
  }

  Future<void> setUser(AppUser user) async {
    if (!isAvailable) return;
    final docId = user.id.isNotEmpty ? user.id : generateDocId(colUsers);
    await _db.collection(colUsers).doc(docId).set(user.copyWith(id: docId).toJson());
  }

  Future<void> updateUser(AppUser user) async {
    if (!isAvailable) return;
    await _db.collection(colUsers).doc(user.id).set(user.toJson(), SetOptions(merge: true));
  }

  Future<void> updateUserRole(String userId, UserRole role) async {
    if (!isAvailable) return;
    await _db.collection(colUsers).doc(userId).update({'role': role.name});
  }

  Future<void> deleteUser(String userId) async {
    if (!isAvailable) return;
    await _db.collection(colUsers).doc(userId).delete();
  }

  // ================= CATEGORIES =================
  Future<List<ChuDe>> getCategories() async {
    if (!isAvailable) return [];
    final snap = await _db.collection(colCategories).get();
    return snap.docs.map((d) => ChuDe.fromJson(d.data())).toList();
  }

  Future<void> setCategory(ChuDe category, {String? docId}) async {
    if (!isAvailable) return;
    final id = docId ?? category.maChuDe.toString();
    await _db.collection(colCategories).doc(id).set(category.toJson());
  }

  Future<void> deleteCategory(int maChuDe) async {
    if (!isAvailable) return;
    final snap = await _db
        .collection(colCategories)
        .where('maChuDe', isEqualTo: maChuDe)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
    await _db.collection(colCategories).doc(maChuDe.toString()).delete();
  }

  // ================= EXAMS =================
  Future<List<DeThi>> getExams() async {
    if (!isAvailable) return [];
    final snap = await _db.collection(colExams).get();
    return snap.docs.map((d) => DeThi.fromJson(d.data())).toList();
  }

  Stream<List<DeThi>> watchExams() {
    if (!isAvailable) return const Stream.empty();
    return _db.collection(colExams).snapshots().map(
          (snap) => snap.docs.map((d) => DeThi.fromJson(d.data())).toList(),
        );
  }

  Future<void> setExam(DeThi exam, {String? docId}) async {
    if (!isAvailable) return;
    final id = docId ?? exam.maDeThi.toString();
    await _db.collection(colExams).doc(id).set(exam.toJson());
  }

  Future<void> updateExam(DeThi exam) async {
    if (!isAvailable) return;
    final snap = await _db
        .collection(colExams)
        .where('maDeThi', isEqualTo: exam.maDeThi)
        .get();
    if (snap.docs.isNotEmpty) {
      for (final doc in snap.docs) {
        await doc.reference.set(exam.toJson(), SetOptions(merge: true));
      }
    } else {
      await _db.collection(colExams).doc(exam.maDeThi.toString()).set(exam.toJson(), SetOptions(merge: true));
    }
  }

  Future<void> deleteExam(int maDeThi) async {
    if (!isAvailable) return;
    final snap = await _db
        .collection(colExams)
        .where('maDeThi', isEqualTo: maDeThi)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
    await _db.collection(colExams).doc(maDeThi.toString()).delete();
  }

  // ================= QUESTIONS =================
  Future<List<CauHoi>> getQuestions() async {
    if (!isAvailable) return [];
    final snap = await _db.collection(colQuestions).get();
    return snap.docs.map((d) => CauHoi.fromJson(d.data())).toList();
  }

  Stream<List<CauHoi>> watchQuestions() {
    if (!isAvailable) return const Stream.empty();
    return _db.collection(colQuestions).snapshots().map(
          (snap) => snap.docs.map((d) => CauHoi.fromJson(d.data())).toList(),
        );
  }

  Future<void> setQuestion(CauHoi question, {String? docId}) async {
    if (!isAvailable) return;
    final id = docId ?? question.maCauHoi.toString();
    await _db.collection(colQuestions).doc(id).set(question.toJson());
  }

  Future<void> deleteQuestion(int maCauHoi) async {
    if (!isAvailable) return;
    final snap = await _db
        .collection(colQuestions)
        .where('maCauHoi', isEqualTo: maCauHoi)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
    await _db.collection(colQuestions).doc(maCauHoi.toString()).delete();
  }

  Future<void> deleteQuestionsByExam(int maDeThi) async {
    if (!isAvailable) return;
    final snap = await _db
        .collection(colQuestions)
        .where('maDeThi', isEqualTo: maDeThi)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  // ================= RESULTS =================
  Future<List<KetQuaThi>> getResults({String? userId}) async {
    if (!isAvailable) return [];
    Query<Map<String, dynamic>> query = _db.collection(colResults);
    if (userId != null && userId.isNotEmpty) {
      query = query.where('userId', isEqualTo: userId);
    }
    final snap = await query.get();
    return snap.docs.map((d) {
      final data = Map<String, dynamic>.from(d.data());
      data['maKetQua'] ??= d.id;
      return KetQuaThi.fromJson(data);
    }).toList();
  }

  Future<void> setResult(KetQuaThi result, {String? docId}) async {
    if (!isAvailable) return;
    final id = docId ?? result.maKetQua;
    final json = result.toJson();
    if (result.userName != null) {
      json['userName'] = result.userName;
    }
    await _db.collection(colResults).doc(id).set(json);
  }

  Future<void> deleteResult(String maKetQua) async {
    if (!isAvailable) return;
    final snap = await _db
        .collection(colResults)
        .where('maKetQua', isEqualTo: maKetQua)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
    await _db.collection(colResults).doc(maKetQua).delete();
  }

  // ================= MISTAKES =================
  Future<List<CauHoiSai>> getMistakes({String? userId}) async {
    if (!isAvailable) return [];
    Query<Map<String, dynamic>> query = _db.collection(colMistakes);
    if (userId != null && userId.isNotEmpty) {
      query = query.where('userId', isEqualTo: userId);
    }
    final snap = await query.get();
    return snap.docs.map((d) {
      final data = Map<String, dynamic>.from(d.data());
      data['id'] ??= d.id;
      return CauHoiSai.fromJson(data);
    }).toList();
  }

  Future<void> setMistake(CauHoiSai mistake, {String? docId}) async {
    if (!isAvailable) return;
    final id = docId ?? mistake.id;
    await _db.collection(colMistakes).doc(id).set(mistake.toJson());
  }

  Future<void> deleteMistake(String id) async {
    if (!isAvailable) return;
    final snap = await _db
        .collection(colMistakes)
        .where('id', isEqualTo: id)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
    await _db.collection(colMistakes).doc(id).delete();
  }

  // ================= BOOKMARKS =================
  Future<List<DeThiYeuThich>> getBookmarks({String? userId}) async {
    if (!isAvailable) return [];
    Query<Map<String, dynamic>> query = _db.collection(colBookmarks);
    if (userId != null && userId.isNotEmpty) {
      query = query.where('userId', isEqualTo: userId);
    }
    final snap = await query.get();
    return snap.docs.map((d) {
      final data = Map<String, dynamic>.from(d.data());
      data['id'] ??= d.id;
      return DeThiYeuThich.fromJson(data);
    }).toList();
  }

  Future<void> setBookmark(DeThiYeuThich bookmark, {String? docId}) async {
    if (!isAvailable) return;
    final id = docId ?? bookmark.id;
    await _db.collection(colBookmarks).doc(id).set(bookmark.toJson());
  }

  Future<void> deleteBookmark(String id) async {
    if (!isAvailable) return;
    final snap = await _db
        .collection(colBookmarks)
        .where('id', isEqualTo: id)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
    await _db.collection(colBookmarks).doc(id).delete();
  }

  // ================= NOTIFICATIONS =================
  Future<List<ThongBao>> getNotifications() async {
    if (!isAvailable) return [];
    final snap = await _db.collection(colNotifications).get();
    return snap.docs.map((d) {
      final data = Map<String, dynamic>.from(d.data());
      data['id'] ??= d.id;
      return ThongBao.fromJson(data);
    }).toList();
  }

  Stream<List<ThongBao>> watchNotifications() {
    if (!isAvailable) return const Stream.empty();
    return _db.collection(colNotifications).snapshots().map(
          (snap) => snap.docs.map((d) {
            final data = Map<String, dynamic>.from(d.data());
            data['id'] ??= d.id;
            return ThongBao.fromJson(data);
          }).toList(),
        );
  }

  Future<void> setNotification(ThongBao notification, {String? docId}) async {
    if (!isAvailable) return;
    final id = docId ?? notification.id;
    await _db.collection(colNotifications).doc(id).set(notification.toJson());
  }

  Future<void> updateNotification(ThongBao notification) async {
    if (!isAvailable) return;
    final snap = await _db
        .collection(colNotifications)
        .where('id', isEqualTo: notification.id)
        .get();
    if (snap.docs.isNotEmpty) {
      for (final doc in snap.docs) {
        await doc.reference.set(notification.toJson(), SetOptions(merge: true));
      }
    } else {
      await _db.collection(colNotifications).doc(notification.id).set(notification.toJson(), SetOptions(merge: true));
    }
  }
}

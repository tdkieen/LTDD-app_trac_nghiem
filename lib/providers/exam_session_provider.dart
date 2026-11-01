import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/de_thi.dart';
import '../models/cau_hoi.dart';
import '../models/ket_qua_thi.dart';
import '../services/quiz_repository.dart';

class ExamSessionProvider extends ChangeNotifier {
  final QuizRepository _repo = QuizRepository();

  DeThi? _currentExam;
  List<CauHoi> _questions = [];
  bool _isPractice = false;
  bool _isMistakePractice = false;
  int _currentIndex = 0;
  final Map<int, String> _answers = {}; // maCauHoi -> 'A', 'B', 'C', 'D'
  int _totalSeconds = 0;
  int _secondsRemaining = 0;
  Timer? _timer;
  int _cheatWarnings = 0;
  bool _isSubmitted = false;
  KetQuaThi? _lastResult;
  String _currentUserId = 'guest';
  VoidCallback? onTimeUp;
  final ValueNotifier<KetQuaThi?> autoSubmitNotifier = ValueNotifier<KetQuaThi?>(null);

  DeThi? get currentExam => _currentExam;
  List<CauHoi> get questions => _questions;
  bool get isPractice => _isPractice;
  bool get isMistakePractice => _isMistakePractice;
  int get currentIndex => _currentIndex;
  Map<int, String> get answers => Map.unmodifiable(_answers);
  int get secondsRemaining => _secondsRemaining;
  int get totalSeconds => _totalSeconds;
  int get cheatWarnings => _cheatWarnings;
  bool get isSubmitted => _isSubmitted;
  KetQuaThi? get lastResult => _lastResult;

  void setCurrentUser(String userId) {
    _currentUserId = userId;
  }

  String _progressKey(int maDeThi, bool isPractice) =>
      'exam_progress_${maDeThi}_${isPractice ? "practice" : "real"}';

  Future<void> _saveProgress() async {
    final exam = _currentExam;
    if (exam == null || _isSubmitted || _isMistakePractice) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'maDeThi': exam.maDeThi,
        'isPractice': _isPractice,
        'currentIndex': _currentIndex,
        'secondsRemaining': _secondsRemaining,
        'totalSeconds': _totalSeconds,
        'cheatWarnings': _cheatWarnings,
        'answers': _answers.map((k, v) => MapEntry(k.toString(), v)),
        'questions': _questions.map((q) => q.toJson()).toList(),
      };
      await prefs.setString(_progressKey(exam.maDeThi, _isPractice), jsonEncode(data));
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> getSavedProgress(int maDeThi, {bool isPractice = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_progressKey(maDeThi, isPractice));
      if (raw == null || raw.isEmpty) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> hasSavedProgress(int maDeThi, {bool isPractice = false}) async {
    final data = await getSavedProgress(maDeThi, isPractice: isPractice);
    if (data == null) return false;
    final savedSeconds = data['secondsRemaining'] as int? ?? 0;
    if (!isPractice && savedSeconds <= 0) return false;
    return true;
  }

  Future<void> clearSavedProgress(int maDeThi, {bool isPractice = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_progressKey(maDeThi, isPractice));
    } catch (_) {}
  }

  Future<bool> restoreSavedProgress({
    required DeThi exam,
    bool isPractice = false,
    String? userId,
    VoidCallback? onTimeUp,
  }) async {
    final data = await getSavedProgress(exam.maDeThi, isPractice: isPractice);
    if (data == null) return false;

    _timer?.cancel();
    _currentExam = exam;
    _isPractice = isPractice;
    _isMistakePractice = false;
    _isSubmitted = false;
    _lastResult = null;
    autoSubmitNotifier.value = null;
    if (userId != null) _currentUserId = userId;
    if (onTimeUp != null) this.onTimeUp = onTimeUp;

    final rawQuestions = data['questions'] as List?;
    if (rawQuestions != null && rawQuestions.isNotEmpty) {
      _questions = rawQuestions
          .map((e) => CauHoi.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } else {
      _questions = List.from(_repo.getQuestionsByExam(exam.maDeThi));
    }

    _answers.clear();
    final rawAnswers = data['answers'] as Map?;
    if (rawAnswers != null) {
      rawAnswers.forEach((k, v) {
        final qId = int.tryParse(k.toString());
        if (qId != null && v != null) {
          _answers[qId] = v.toString();
        }
      });
    }

    _currentIndex = (data['currentIndex'] as int? ?? 0).clamp(
      0,
      _questions.isEmpty ? 0 : _questions.length - 1,
    );
    _totalSeconds = data['totalSeconds'] as int? ?? (exam.thoiGian ?? 15) * 60;
    _secondsRemaining = data['secondsRemaining'] as int? ?? _totalSeconds;
    _cheatWarnings = data['cheatWarnings'] as int? ?? 0;

    if (!_isPractice && _secondsRemaining > 0) {
      _startTimer();
    }
    notifyListeners();
    return true;
  }

  Future<void> pauseExam() async {
    _timer?.cancel();
    await _saveProgress();
  }

  CauHoi? get currentQuestion =>
      _questions.isNotEmpty && _currentIndex < _questions.length
          ? _questions[_currentIndex]
          : null;

  int get answeredCount => _answers.length;
  int get totalQuestions => _questions.length;
  bool get isAllAnswered => _answers.length == _questions.length && _questions.isNotEmpty;

  String get formattedTimeRemaining {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void startExam({
    required DeThi exam,
    bool isPractice = false,
    String? userId,
    VoidCallback? onTimeUp,
    int? customDurationSeconds,
  }) {
    _timer?.cancel();
    _currentExam = exam;
    _isPractice = isPractice;
    _isMistakePractice = false;
    _currentIndex = 0;
    _answers.clear();
    _cheatWarnings = 0;
    _isSubmitted = false;
    _lastResult = null;
    autoSubmitNotifier.value = null;
    if (userId != null) _currentUserId = userId;
    if (onTimeUp != null) this.onTimeUp = onTimeUp;

    final qList = _repo.getQuestionsByExam(exam.maDeThi);
    _questions = List.from(qList);

    _totalSeconds = customDurationSeconds ?? (exam.thoiGian ?? 15) * 60;
    _secondsRemaining = _totalSeconds;

    if (!_isPractice && _secondsRemaining > 0) {
      _startTimer();
    }
    _saveProgress();
    notifyListeners();
  }

  void startPracticeFromQuestions({
    required List<CauHoi> customQuestions,
    required String title,
  }) {
    _timer?.cancel();
    _isPractice = true;
    _isMistakePractice = true;
    _currentIndex = 0;
    _answers.clear();
    _cheatWarnings = 0;
    _isSubmitted = false;
    _lastResult = null;
    autoSubmitNotifier.value = null;

    _questions = List.from(customQuestions);
    _currentExam = DeThi(
      maDeThi: 9999,
      tenDeThi: title,
      maChuDe: 1,
      soCauHoi: _questions.length,
      thoiGian: 30,
    );
    _totalSeconds = 1800;
    _secondsRemaining = 1800;
    notifyListeners();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
      }
      if (_secondsRemaining <= 0) {
        _timer?.cancel();
        if (!_isSubmitted) {
          final result = submit(userId: _currentUserId);
          autoSubmitNotifier.value = result;
          onTimeUp?.call();
        }
      } else {
        if (_secondsRemaining % 5 == 0) {
          _saveProgress();
        }
        notifyListeners();
      }
    });
  }

  void selectAnswer(int maCauHoi, String optionKey) {
    if (_isSubmitted) return;
    _answers[maCauHoi] = optionKey.toUpperCase();
    _saveProgress();
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      _saveProgress();
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _saveProgress();
      notifyListeners();
    }
  }

  void jumpToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentIndex = index;
      _saveProgress();
      notifyListeners();
    }
  }

  void registerCheatWarning({String? userId}) {
    if (!_isPractice && !_isSubmitted) {
      _cheatWarnings++;
      if (_cheatWarnings >= 3) {
        final result = submit(userId: userId ?? _currentUserId);
        autoSubmitNotifier.value = result;
        onTimeUp?.call();
      } else {
        notifyListeners();
      }
    }
  }

  KetQuaThi submit({required String userId}) {
    _timer?.cancel();
    _isSubmitted = true;
    if (_currentExam != null) {
      clearSavedProgress(_currentExam!.maDeThi, isPractice: _isPractice);
    }

    final timeSpent = _totalSeconds - _secondsRemaining;

    final result = _repo.submitExam(
      userId: userId,
      maDeThi: _currentExam?.maDeThi ?? 0,
      answers: _answers,
      thoiGianLamGiay: timeSpent > 0 ? timeSpent : 30,
      questions: _questions,
      isPractice: _isPractice,
      isMistakePractice: _isMistakePractice,
      soLanViPham: _cheatWarnings,
    );

    _lastResult = result;
    notifyListeners();
    return result;
  }

  @override
  void dispose() {
    _timer?.cancel();
    autoSubmitNotifier.dispose();
    super.dispose();
  }
}

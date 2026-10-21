import 'dart:async';
import 'package:flutter/material.dart';
import '../models/de_thi.dart';
import '../models/cau_hoi.dart';
import '../models/ket_qua_thi.dart';
import '../services/quiz_repository.dart';

class ExamSessionProvider extends ChangeNotifier {
  final QuizRepository _repo = QuizRepository();

  DeThi? _currentExam;
  List<CauHoi> _questions = [];
  bool _isPractice = false;
  int _currentIndex = 0;
  final Map<int, String> _answers = {}; // maCauHoi -> 'A', 'B', 'C', 'D'
  int _totalSeconds = 0;
  int _secondsRemaining = 0;
  Timer? _timer;
  int _cheatWarnings = 0;
  bool _isSubmitted = false;
  KetQuaThi? _lastResult;

  DeThi? get currentExam => _currentExam;
  List<CauHoi> get questions => _questions;
  bool get isPractice => _isPractice;
  int get currentIndex => _currentIndex;
  Map<int, String> get answers => Map.unmodifiable(_answers);
  int get secondsRemaining => _secondsRemaining;
  int get totalSeconds => _totalSeconds;
  int get cheatWarnings => _cheatWarnings;
  bool get isSubmitted => _isSubmitted;
  KetQuaThi? get lastResult => _lastResult;

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
  }) {
    _timer?.cancel();
    _currentExam = exam;
    _isPractice = isPractice;
    _currentIndex = 0;
    _answers.clear();
    _cheatWarnings = 0;
    _isSubmitted = false;
    _lastResult = null;

    final qList = _repo.getQuestionsByExam(exam.maDeThi);
    _questions = List.from(qList);

    _totalSeconds = (exam.thoiGian ?? 15) * 60;
    _secondsRemaining = _totalSeconds;

    if (!_isPractice && _secondsRemaining > 0) {
      _startTimer();
    }
    notifyListeners();
  }

  void startPracticeFromQuestions({
    required List<CauHoi> customQuestions,
    required String title,
  }) {
    _timer?.cancel();
    _isPractice = true;
    _currentIndex = 0;
    _answers.clear();
    _cheatWarnings = 0;
    _isSubmitted = false;
    _lastResult = null;

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
        notifyListeners();
      } else {
        _timer?.cancel();
        // Auto submit when time is up
        notifyListeners();
      }
    });
  }

  void selectAnswer(int maCauHoi, String optionKey) {
    if (_isSubmitted) return;
    _answers[maCauHoi] = optionKey.toUpperCase();
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void jumpToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void registerCheatWarning() {
    if (!_isPractice && !_isSubmitted) {
      _cheatWarnings++;
      notifyListeners();
    }
  }

  KetQuaThi submit({required String userId}) {
    _timer?.cancel();
    _isSubmitted = true;

    final timeSpent = _totalSeconds - _secondsRemaining;

    final result = _repo.submitExam(
      userId: userId,
      maDeThi: _currentExam?.maDeThi ?? 0,
      answers: _answers,
      thoiGianLamGiay: timeSpent > 0 ? timeSpent : 30,
    );

    _lastResult = result;
    notifyListeners();
    return result;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

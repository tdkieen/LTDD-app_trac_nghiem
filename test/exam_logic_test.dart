import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_trac_nghiem/models/cau_hoi.dart';
import 'package:app_trac_nghiem/models/de_thi.dart';
import 'package:app_trac_nghiem/providers/exam_session_provider.dart';
import 'package:app_trac_nghiem/services/quiz_repository.dart';

void main() {
  late QuizRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = QuizRepository()..resetForTesting(mockOnly: true);
  });

  group('Exam Logic & Repository Tests (Offline Mock Repository)', () {
    test('1. Chấm điểm chính xác với câu đúng, câu sai và câu bỏ trống', () async {
      final questions = [
        CauHoi(
          maCauHoi: 1001,
          maDeThi: 101,
          maChuDe: 1,
          noiDung: 'Câu 1',
          phuongAnA: 'A1',
          phuongAnB: 'B1',
          phuongAnC: 'C1',
          phuongAnD: 'D1',
          dapAnDung: 'A',
        ),
        CauHoi(
          maCauHoi: 1002,
          maDeThi: 101,
          maChuDe: 1,
          noiDung: 'Câu 2',
          phuongAnA: 'A2',
          phuongAnB: 'B2',
          phuongAnC: 'C2',
          phuongAnD: 'D2',
          dapAnDung: 'B',
        ),
        CauHoi(
          maCauHoi: 1003,
          maDeThi: 101,
          maChuDe: 1,
          noiDung: 'Câu 3',
          phuongAnA: 'A3',
          phuongAnB: 'B3',
          phuongAnC: 'C3',
          phuongAnD: 'D3',
          dapAnDung: 'C',
        ),
        CauHoi(
          maCauHoi: 1004,
          maDeThi: 101,
          maChuDe: 1,
          noiDung: 'Câu 4',
          phuongAnA: 'A4',
          phuongAnB: 'B4',
          phuongAnC: 'C4',
          phuongAnD: 'D4',
          dapAnDung: 'D',
        ),
      ];

      // 2 đúng (1001->A, 1002->B), 1 sai (1003->A), 1 bỏ trống (1004)
      final result = await repo.submitExam(
        userId: 'u_student_1',
        maDeThi: 101,
        answers: {
          1001: 'A',
          1002: 'B',
          1003: 'A',
        },
        thoiGianLamGiay: 120,
        questions: questions,
        isPractice: false,
      );

      expect(result.soCauDung, 2);
      expect(result.tongSoCau, 4);
      expect(result.tongDiem, 5.0);
      expect(result.chiTiet.length, 4);
      expect(result.chiTiet[0].laDung, isTrue);
      expect(result.chiTiet[1].laDung, isTrue);
      expect(result.chiTiet[2].laDung, isFalse);
      expect(result.chiTiet[3].dapAnChon, isNull);
      expect(result.chiTiet[3].laDung, isFalse);
    });

    test('2. Chế độ luyện câu sai (maDeThi=9999) chấm theo danh sách _questions của phiên', () async {
      final session = ExamSessionProvider();
      final customQuestions = [
        CauHoi(
          maCauHoi: 501,
          maDeThi: 101,
          maChuDe: 1,
          noiDung: 'Câu sai 1',
          phuongAnA: 'Đúng',
          phuongAnB: 'Sai 1',
          phuongAnC: 'Sai 2',
          phuongAnD: 'Sai 3',
          dapAnDung: 'A',
        ),
        CauHoi(
          maCauHoi: 502,
          maDeThi: 102,
          maChuDe: 2,
          noiDung: 'Câu sai 2',
          phuongAnA: 'Sai 1',
          phuongAnB: 'Đúng',
          phuongAnC: 'Sai 2',
          phuongAnD: 'Sai 3',
          dapAnDung: 'B',
        ),
      ];

      session.startPracticeFromQuestions(
        customQuestions: customQuestions,
        title: 'Luyện câu sai',
      );
      expect(session.currentExam?.maDeThi, 9999);

      session.selectAnswer(501, 'A');
      session.selectAnswer(502, 'B');

      final result = await session.submit(userId: 'u_student_1');
      expect(result.soCauDung, 2);
      expect(result.tongSoCau, 2);
      expect(result.tongDiem, 10.0);
    });

    test('3. Hết giờ (_secondsRemaining == 0) tự động nộp bài và báo qua callback/ValueNotifier', () async {
      final session = ExamSessionProvider();
      final shortExam = DeThi(
        maDeThi: 101,
        tenDeThi: 'Đề thi ngắn',
        maChuDe: 1,
        thoiGian: 1,
        soCauHoi: 5,
      );

      bool timeUpCallbackFired = false;
      session.startExam(
        exam: shortExam,
        isPractice: false,
        userId: 'u_student_1',
        customDurationSeconds: 1,
        shuffleQuestions: false,
        shuffleOptions: false,
        onTimeUp: () {
          timeUpCallbackFired = true;
        },
      );

      final firstQ = session.questions.first;
      session.selectAnswer(firstQ.maCauHoi, firstQ.dapAnDung ?? 'A');

      // Chờ hơn 1 giây để Timer.periodic kích hoạt hết giờ và tự nộp
      await Future<void>.delayed(const Duration(milliseconds: 1400));

      expect(session.secondsRemaining, 0);
      expect(session.isSubmitted, isTrue);
      expect(session.lastResult, isNotNull);
      expect(session.autoSubmitNotifier.value, isNotNull);
      expect(timeUpCallbackFired, isTrue);
    });

    test('4. Chế độ Practice KHÔNG lưu KetQuaThi, KHÔNG tăng luotThi, KHÔNG ghi sổ câu sai', () async {
      const userId = 'u_student_1';
      const examId = 101;
      final beforeResults = repo.getResultsByUser(userId).length;
      final beforeMistakes = repo.getMistakesByUser(userId).length;
      final beforeLuotThi = repo.getExamById(examId)!.luotThi;

      final examQuestions = repo.getQuestionsByExam(examId);
      // Chọn đáp án sai cho tất cả câu hỏi
      final wrongAnswers = <int, String>{};
      for (final q in examQuestions) {
        wrongAnswers[q.maCauHoi] = q.dapAnDung == 'A' ? 'B' : 'A';
      }

      final result = await repo.submitExam(
        userId: userId,
        maDeThi: examId,
        answers: wrongAnswers,
        thoiGianLamGiay: 45,
        questions: examQuestions,
        isPractice: true,
      );

      expect(result.soCauDung, 0);
      expect(repo.getResultsByUser(userId).length, beforeResults);
      expect(repo.getMistakesByUser(userId).length, beforeMistakes);
      expect(repo.getExamById(examId)!.luotThi, beforeLuotThi);
    });

    test('5. Sổ câu sai: trả lời đúng ở chế độ luyện câu sai thì giảm lanSai; về 0 thì xoá khỏi sổ', () async {
      const userId = 'u_test_mistake_user';
      // Ghi nhận câu 1 sai 2 lần (lanSai=2) và câu 2 sai 1 lần (lanSai=1)
      await repo.recordMistake(userId: userId, maCauHoi: 1, dapAnDaChon: 'A');
      await repo.recordMistake(userId: userId, maCauHoi: 1, dapAnDaChon: 'A');
      await repo.recordMistake(userId: userId, maCauHoi: 2, dapAnDaChon: 'B');

      final initialMistakes = repo.getMistakesByUser(userId);
      final m1Before = initialMistakes.firstWhere((m) => m.maCauHoi == 1);
      final m2Before = initialMistakes.firstWhere((m) => m.maCauHoi == 2);
      expect(m1Before.lanSai, 2);
      expect(m2Before.lanSai, 1);

      final q1 = repo.getQuestionById(1)!;
      final q2 = repo.getQuestionById(2)!;

      final session = ExamSessionProvider();
      session.startPracticeFromQuestions(
        customQuestions: [q1, q2],
        title: 'Ôn câu sai',
      );

      // Trả lời đúng cả 2 câu trong chế độ luyện câu sai
      session.selectAnswer(q1.maCauHoi, q1.dapAnDung!);
      session.selectAnswer(q2.maCauHoi, q2.dapAnDung!);
      await session.submit(userId: userId);

      final afterFirstPractice = repo.getMistakesByUser(userId);
      final m1After1 = afterFirstPractice.firstWhere((m) => m.maCauHoi == 1);
      // Câu 1 giảm lanSai từ 2 xuống 1
      expect(m1After1.lanSai, 1);
      // Câu 2 giảm lanSai từ 1 về 0 nên đã bị xóa khỏi sổ câu sai
      expect(afterFirstPractice.any((m) => m.maCauHoi == 2), isFalse);

      // Luyện thêm 1 lần nữa và trả lời đúng câu 1 -> lanSai về 0 và xóa khỏi sổ
      session.startPracticeFromQuestions(
        customQuestions: [q1],
        title: 'Ôn câu sai lần 2',
      );
      session.selectAnswer(q1.maCauHoi, q1.dapAnDung!);
      await session.submit(userId: userId);

      final afterSecondPractice = repo.getMistakesByUser(userId);
      expect(afterSecondPractice.any((m) => m.maCauHoi == 1), isFalse);
    });
  });
}

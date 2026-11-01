import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_trac_nghiem/main.dart';
import 'package:app_trac_nghiem/services/quiz_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    QuizRepository().resetForTesting(mockOnly: true);
  });

  testWidgets('Edutech Quiz App auth and desktop smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const EdutechQuizApp());
    await tester.pumpAndSettle();

    // Verify Auth screen displays with EDUTECH and login elements
    expect(find.text('EDUTECH'), findsWidgets);
    expect(find.text('Đăng Nhập'), findsWidgets);
    expect(find.text('Đăng Ký'), findsWidgets);

    // Tap quick demo login for student
    final studentChip = find.text('👨‍🎓 Học viên: duyki');
    expect(studentChip, findsOneWidget);
    await tester.tap(studentChip);
    await tester.pumpAndSettle();

    // Verify navigation into main app home screen
    expect(find.text('Trang Chủ Học Tập'), findsWidgets);
  });

  testWidgets('Edutech Quiz App mobile smoke test with login', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const EdutechQuizApp());
    await tester.pumpAndSettle();

    // Tap quick login
    final studentChip = find.text('👨‍🎓 Học viên: duyki');
    expect(studentChip, findsOneWidget);
    await tester.tap(studentChip);
    await tester.pumpAndSettle();

    // Verify bottom nav items
    expect(find.text('Trang chủ'), findsWidgets);
    expect(find.text('Đề thi'), findsWidgets);

    // Navigate to Nhật ký on mobile and verify no overflow
    await tester.tap(find.text('Nhật ký'));
    await tester.pumpAndSettle();
    expect(find.text('Nhật Ký Học Tập'), findsWidgets);

    // Navigate to Hồ sơ on mobile and verify no overflow
    await tester.tap(find.text('Hồ sơ'));
    await tester.pumpAndSettle();
    expect(find.text('Hồ Sơ Cá Nhân'), findsWidgets);
    expect(find.text('Đăng xuất'), findsWidgets);
  });

  testWidgets('Create exam screen mobile test with keyboard input', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const EdutechQuizApp());
    await tester.pumpAndSettle();

    // Login as teacher
    final teacherChip = find.text('👩‍🏫 Giáo viên: gv_huong');
    expect(teacherChip, findsOneWidget);
    await tester.tap(teacherChip);
    await tester.pumpAndSettle();

    // Click "Tạo đề thi mới" on banner
    final createExamBtn = find.text('Tạo đề thi mới');
    expect(createExamBtn, findsWidgets);
    await tester.tap(createExamBtn.first);
    await tester.pumpAndSettle();

    // Verify Create Exam Screen is visible
    expect(find.text('Tạo Đề Thi Mới'), findsWidgets);
    expect(find.text('Tên đề thi *'), findsOneWidget);

    // Enter exam name
    final examNameField = find.byType(TextFormField).first;
    await tester.enterText(examNameField, 'Đề thi trắc nghiệm Flutter');
    await tester.pumpAndSettle();

    expect(find.text('Đề thi trắc nghiệm Flutter'), findsOneWidget);
  });
}

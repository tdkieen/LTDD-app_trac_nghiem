import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_trac_nghiem/main.dart';

void main() {
  testWidgets('Edutech Quiz App desktop smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const EdutechQuizApp());
    await tester.pumpAndSettle();

    expect(find.text('Trang Chủ Học Tập'), findsWidgets);
    expect(find.text('EDUTECH'), findsWidgets);
  });

  testWidgets('Edutech Quiz App mobile smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const EdutechQuizApp());
    await tester.pumpAndSettle();

    expect(find.text('Trang chủ'), findsWidgets);
    expect(find.text('Đề thi'), findsWidgets);
  });
}

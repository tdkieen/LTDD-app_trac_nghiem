import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/exam_session_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/quiz_provider.dart';
import 'views/main_layout_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EdutechQuizApp());
}

class EdutechQuizApp extends StatelessWidget {
  const EdutechQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => ExamSessionProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'EDUTECH - Thi Trắc Nghiệm',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainLayoutShell(),
      ),
    );
  }
}

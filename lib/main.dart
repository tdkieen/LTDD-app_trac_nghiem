import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/exam_session_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/quiz_provider.dart';
import 'services/quiz_repository.dart';
import 'views/main_layout_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
    await QuizRepository().syncFromFirestore();
  } catch (e) {
    debugPrint('Firebase init warning: $e');
    QuizRepository().isInitialSynced = true;
  }
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/responsive/responsive_layout.dart';
import '../core/theme/app_colors.dart';
import '../models/cau_hoi.dart';
import '../models/de_thi.dart';
import '../models/ket_qua_thi.dart';
import '../providers/exam_session_provider.dart';
import '../providers/quiz_provider.dart';
import 'admin/create_exam_screen.dart';
import 'admin/manage_categories_screen.dart';
import 'admin/manage_questions_screen.dart';
import 'admin/manage_users_screen.dart';
import 'admin/overall_leaderboard_screen.dart';
import 'exam/bookmarks_screen.dart';
import 'exam/exam_list_screen.dart';
import 'exam/exam_result_screen.dart';
import 'exam/exam_taking_screen.dart';
import 'exam/history_screen.dart';
import 'exam/mistake_notebook_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'widgets/app_header.dart';
import 'widgets/mobile_drawer.dart';
import 'widgets/web_sidebar.dart';

class MainLayoutShell extends StatefulWidget {
  const MainLayoutShell({super.key});

  @override
  State<MainLayoutShell> createState() => _MainLayoutShellState();
}

class _MainLayoutShellState extends State<MainLayoutShell> {
  String _activeRoute = 'home';
  DeThi? _editingExam;
  int? _managingQuestionExamId;
  KetQuaThi? _viewingResult;
  bool _isTakingExam = false;

  void _navigateTo(String route) {
    setState(() {
      _isTakingExam = false;
      _viewingResult = null;

      if (route.startsWith('edit_exam_')) {
        final id = int.tryParse(route.replaceFirst('edit_exam_', ''));
        if (id != null) {
          final exam = context.read<QuizProvider>().getAllExams().firstWhere((e) => e.maDeThi == id);
          _editingExam = exam;
          _activeRoute = 'create_exam';
          return;
        }
      }

      if (route.startsWith('manage_questions_')) {
        final id = int.tryParse(route.replaceFirst('manage_questions_', ''));
        if (id != null) {
          _managingQuestionExamId = id;
          _activeRoute = 'manage_questions';
          return;
        }
      }

      _editingExam = null;
      _activeRoute = route;
    });
  }

  void _startExam(DeThi exam, bool isPractice) {
    final session = context.read<ExamSessionProvider>();
    session.startExam(exam: exam, isPractice: isPractice);
    setState(() {
      _isTakingExam = true;
      _viewingResult = null;
    });
  }

  void _startPracticeMistakes(List<CauHoi> questions, String title) {
    final session = context.read<ExamSessionProvider>();
    session.startPracticeFromQuestions(customQuestions: questions, title: title);
    setState(() {
      _isTakingExam = true;
      _viewingResult = null;
    });
  }

  void _onExamFinished(KetQuaThi result) {
    setState(() {
      _isTakingExam = false;
      _viewingResult = result;
    });
  }

  String _getPageTitle() {
    switch (_activeRoute) {
      case 'home':
        return 'Trang Chủ Học Tập';
      case 'exams':
        return 'Danh Sách Đề Thi';
      case 'history':
        return 'Nhật Ký Học Tập';
      case 'profile':
        return 'Hồ Sơ Của Tôi';
      case 'bookmarks':
        return 'Đề Thi Đã Lưu';
      case 'mistakes':
        return 'Sổ Tay Câu Sai';
      case 'leaderboard':
        return 'Bảng Xếp Hạng';
      case 'create_exam':
        return _editingExam != null ? 'Chỉnh Sửa Đề Thi' : 'Tạo Đề Thi Mới';
      case 'manage_questions':
        return 'Quản Lý Câu Hỏi';
      case 'manage_categories':
        return 'Quản Lý Chủ Đề';
      case 'manage_users':
        return 'Quản Lý Người Dùng';
      default:
        return 'Thi Trắc Nghiệm Edutech';
    }
  }

  Widget _buildBody() {
    if (_isTakingExam) {
      return ExamTakingScreen(
        onExit: () => setState(() => _isTakingExam = false),
        onFinish: _onExamFinished,
      );
    }

    if (_viewingResult != null) {
      return ExamResultScreen(
        result: _viewingResult!,
        onRetake: () {
          final exam = _viewingResult!.deThi ??
              context.read<QuizProvider>().getAllExams().firstWhere((e) => e.maDeThi == _viewingResult!.maDeThi);
          _startExam(exam, false);
        },
        onViewHistory: () => _navigateTo('history'),
        onGoHome: () => _navigateTo('home'),
      );
    }

    switch (_activeRoute) {
      case 'home':
        return HomeScreen(
          onNavigate: _navigateTo,
          onStartExam: _startExam,
        );
      case 'exams':
        return ExamListScreen(
          onNavigate: _navigateTo,
          onStartExam: _startExam,
        );
      case 'history':
        return HistoryScreen(
          onViewResult: (result) {
            setState(() {
              _viewingResult = result;
            });
          },
          onGoExams: () => _navigateTo('exams'),
        );
      case 'profile':
        return ProfileScreen(
          onGoHome: () => _navigateTo('home'),
        );
      case 'bookmarks':
        return BookmarksScreen(
          onNavigate: _navigateTo,
          onStartExam: _startExam,
        );
      case 'mistakes':
        return MistakeNotebookScreen(
          onNavigate: _navigateTo,
          onPracticeMistakes: _startPracticeMistakes,
        );
      case 'leaderboard':
        return OverallLeaderboardScreen(
          onBack: () => _navigateTo('home'),
        );
      case 'create_exam':
        return CreateExamScreen(
          editingExam: _editingExam,
          onSaved: () => _navigateTo('exams'),
          onCancel: () => _navigateTo('exams'),
        );
      case 'manage_questions':
        return ManageQuestionsScreen(
          initialExamId: _managingQuestionExamId ?? 101,
          onBack: () => _navigateTo('exams'),
        );
      case 'manage_categories':
        return ManageCategoriesScreen(
          onBack: () => _navigateTo('home'),
        );
      case 'manage_users':
        return ManageUsersScreen(
          onBack: () => _navigateTo('home'),
        );
      default:
        return HomeScreen(
          onNavigate: _navigateTo,
          onStartExam: _startExam,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    // If currently taking an exam, show full screen taking view without sidebars
    if (_isTakingExam) {
      return ExamTakingScreen(
        onExit: () => setState(() => _isTakingExam = false),
        onFinish: _onExamFinished,
      );
    }

    if (!isMobile) {
      // Desktop / Web layout with Sidebar + Header
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            WebSidebar(
              activeRoute: _activeRoute,
              onNavigate: _navigateTo,
            ),
            Expanded(
              child: Column(
                children: [
                  AppHeader(
                    title: _getPageTitle(),
                  ),
                  Expanded(
                    child: _buildBody(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile Layout with AppBar + Drawer + BottomNavigationBar
      int bottomNavIdx = 0;
      if (_activeRoute == 'exams') bottomNavIdx = 1;
      if (_activeRoute == 'history') bottomNavIdx = 2;
      if (_activeRoute == 'profile') bottomNavIdx = 3;

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppHeader(
          title: _getPageTitle(),
        ),
        drawer: MobileDrawer(
          activeRoute: _activeRoute,
          onNavigate: _navigateTo,
        ),
        body: _buildBody(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: bottomNavIdx,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          backgroundColor: AppColors.surface,
          type: BottomNavigationBarType.fixed,
          onTap: (idx) {
            if (idx == 0) _navigateTo('home');
            if (idx == 1) _navigateTo('exams');
            if (idx == 2) _navigateTo('history');
            if (idx == 3) _navigateTo('profile');
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Trang chủ'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Đề thi'),
            BottomNavigationBarItem(icon: Icon(Icons.history), activeIcon: Icon(Icons.history), label: 'Nhật ký'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Hồ sơ'),
          ],
        ),
      );
    }
  }
}

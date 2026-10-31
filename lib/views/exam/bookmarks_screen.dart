import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../models/de_thi.dart';
import '../../models/de_thi_yeu_thich.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quiz_provider.dart';
import '../widgets/exam_card.dart';

class BookmarksScreen extends StatefulWidget {
  final ValueChanged<String> onNavigate;
  final void Function(DeThi exam, bool isPractice) onStartExam;

  const BookmarksScreen({
    super.key,
    required this.onNavigate,
    required this.onStartExam,
  });

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  String _difficulty = 'Tất cả';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final quiz = context.watch<QuizProvider>();
    final user = auth.currentUser;
    final isMobile = ResponsiveLayout.isMobile(context);
    final canManage = auth.isTeacher || auth.isAdmin;

    final List<DeThiYeuThich> bookmarks = user != null
        ? quiz.getBookmarks(user.id)
        : <DeThiYeuThich>[];
    final allExams = bookmarks.map((b) => b.deThi).whereType<DeThi>().toList();

    final exams = allExams.where((e) {
      final okName =
          _query.isEmpty ||
          e.tenDeThi.toLowerCase().contains(_query.toLowerCase());
      final okDiff = _difficulty == 'Tất cả' || e.mucDoKho == _difficulty;
      return okName && okDiff;
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isMobile, allExams.length),
              const SizedBox(height: 20),
              if (allExams.isEmpty)
                _buildEmptyAll()
              else ...[
                _buildFilterCard(),
                const SizedBox(height: 24),
                if (exams.isEmpty)
                  _buildEmptyFiltered()
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth < 650
                          ? 1
                          : constraints.maxWidth < 1000
                          ? 2
                          : 3;
                      final itemWidth =
                          (constraints.maxWidth - (crossAxisCount - 1) * 16) /
                          crossAxisCount;

                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: exams.map((exam) {
                          return SizedBox(
                            width: itemWidth,
                            height: 250,
                            child: ExamCard(
                              exam: exam,
                              isBookmarked: true,
                              canManage: canManage,
                              onTakeExam: () => widget.onStartExam(exam, false),
                              onPractice: () => widget.onStartExam(exam, true),
                              onToggleBookmark: () {
                                if (user != null) {
                                  quiz.toggleBookmark(user.id, exam.maDeThi);
                                }
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Header (same pattern as Danh sách đề thi) ----------
  Widget _buildHeader(bool isMobile, int total) {
    final title = Text(
      isMobile ? 'Đề Thi Đã Lưu' : 'Đề Thi Đã Lưu (Yêu Thích)',
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
    final subtitle = Text(
      'Bạn đang lưu $total đề thi để ôn luyện dần',
      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
    );
    final exploreButton = OutlinedButton.icon(
      onPressed: () => widget.onNavigate('exams'),
      icon: const Icon(Icons.explore_outlined, size: 18),
      label: const Text('Khám phá thêm đề'),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 4),
          subtitle,
          const SizedBox(height: 12),
          exploreButton,
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, const SizedBox(height: 4), subtitle],
          ),
        ),
        exploreButton,
      ],
    );
  }

  // ---------- Filter card (same pattern as Danh sách đề thi) ----------
  Widget _buildFilterCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Tìm trong đề đã lưu...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
            ),
            onChanged: (val) => setState(() => _query = val.trim()),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text(
                    'Mức độ: ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  for (final diff in ['Tất cả', 'Dễ', 'Trung bình', 'Khó'])
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(diff),
                        selected: _difficulty == diff,
                        selectedColor: AppColors.primarySoft,
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: _difficulty == diff
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: _difficulty == diff
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        onSelected: (_) => setState(() => _difficulty = diff),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Empty states ----------
  Widget _buildEmptyAll() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.bookmark_border,
            size: 56,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          const Text(
            'Bạn chưa lưu đề thi nào',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Nhấn vào biểu tượng dấu trang ở mỗi đề thi để lưu vào danh sách yêu thích.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => widget.onNavigate('exams'),
            child: const Text('Xem danh sách đề thi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFiltered() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 56, color: AppColors.textMuted),
          const SizedBox(height: 12),
          const Text(
            'Không có đề đã lưu phù hợp',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Hãy thử đổi từ khóa hoặc mức độ.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () {
              _searchCtrl.clear();
              setState(() {
                _query = '';
                _difficulty = 'Tất cả';
              });
            },
            child: const Text('Xóa bộ lọc'),
          ),
        ],
      ),
    );
  }
}

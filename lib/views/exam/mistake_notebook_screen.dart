import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../models/cau_hoi.dart';
import '../../models/cau_hoi_sai.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quiz_provider.dart';

enum _MistakeFilter { all, repeated, recent }

class MistakeNotebookScreen extends StatefulWidget {
  final ValueChanged<String> onNavigate;
  final void Function(List<CauHoi> questions, String title) onPracticeMistakes;

  const MistakeNotebookScreen({
    super.key,
    required this.onNavigate,
    required this.onPracticeMistakes,
  });

  @override
  State<MistakeNotebookScreen> createState() => _MistakeNotebookScreenState();
}

class _MistakeNotebookScreenState extends State<MistakeNotebookScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  _MistakeFilter _filter = _MistakeFilter.all;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final quiz = context.watch<QuizProvider>();
    final isMobile = ResponsiveLayout.isMobile(context);
    final user = auth.currentUser;

    final List<CauHoiSai> mistakes = user != null
        ? List<CauHoiSai>.from(quiz.getMistakes(user.id))
        : <CauHoiSai>[];
    final valid = mistakes.where((m) => m.cauHoi != null).toList();

    final totalWrongTimes = valid.fold<int>(0, (s, m) => s + m.lanSai);
    final repeatedCount = valid.where((m) => m.lanSai >= 2).length;
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final recentCount = valid.where((m) => m.lanCuoiSai.isAfter(cutoff)).length;

    // Apply filter + search
    var shown = valid.where((m) {
      final q = m.cauHoi!;
      final okQuery =
          _query.isEmpty ||
          q.noiDung.toLowerCase().contains(_query.toLowerCase());
      final okFilter = switch (_filter) {
        _MistakeFilter.all => true,
        _MistakeFilter.repeated => m.lanSai >= 2,
        _MistakeFilter.recent => m.lanCuoiSai.isAfter(cutoff),
      };
      return okQuery && okFilter;
    }).toList()..sort((a, b) => b.lanCuoiSai.compareTo(a.lanCuoiSai));

    final practiceQuestions = valid.map((m) => m.cauHoi!).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isMobile, valid.length, practiceQuestions),
              const SizedBox(height: 20),
              if (valid.isEmpty)
                _buildEmptyAll()
              else ...[
                // Summary tiles
                Row(
                  children: [
                    Expanded(
                      child: _SummaryTile(
                        icon: Icons.menu_book_outlined,
                        value: '${valid.length}',
                        label: 'Câu cần ôn',
                        color: AppColors.danger,
                        bg: AppColors.dangerSoft,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryTile(
                        icon: Icons.replay,
                        value: '$totalWrongTimes',
                        label: 'Tổng lượt sai',
                        color: AppColors.warning,
                        bg: AppColors.warningSoft,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryTile(
                        icon: Icons.priority_high,
                        value: '$repeatedCount',
                        label: 'Sai nhiều lần',
                        color: AppColors.primary,
                        bg: AppColors.primarySoft,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFilterCard(valid.length, repeatedCount, recentCount),
                const SizedBox(height: 20),
                if (shown.isEmpty)
                  _buildEmptyFiltered()
                else
                  for (final m in shown)
                    _MistakeCard(
                      entry: m,
                      onDelete: () {
                        quiz.deleteMistake(m.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã gỡ câu hỏi khỏi sổ tay.'),
                          ),
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
  Widget _buildHeader(
    bool isMobile,
    int count,
    List<CauHoi> practiceQuestions,
  ) {
    final title = const Text(
      'Sổ Tay Câu Hỏi Sai',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
    final subtitle = Text(
      'Bạn đang có $count câu hỏi cần được ôn tập lại',
      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
    );
    final practiceButton = ElevatedButton.icon(
      onPressed: () => widget.onPracticeMistakes(
        practiceQuestions,
        'Luyện tập câu sai trong sổ tay',
      ),
      icon: const Icon(Icons.fitness_center, size: 18),
      label: const Text('Ôn tập tất cả'),
    );
    final showButton = practiceQuestions.isNotEmpty;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 4),
          subtitle,
          if (showButton) ...[const SizedBox(height: 12), practiceButton],
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
        if (showButton) practiceButton,
      ],
    );
  }

  // ---------- Filter card ----------
  Widget _buildFilterCard(int all, int repeated, int recent) {
    Widget chip(String label, _MistakeFilter value) {
      final selected = _filter == value;
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: FilterChip(
          label: Text(label),
          selected: selected,
          selectedColor: AppColors.primarySoft,
          checkmarkColor: AppColors.primary,
          labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
          onSelected: (_) => setState(() => _filter = value),
        ),
      );
    }

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
              hintText: 'Tìm theo nội dung câu hỏi...',
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
                    'Lọc: ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  chip('Tất cả ($all)', _MistakeFilter.all),
                  chip('Sai nhiều lần ($repeated)', _MistakeFilter.repeated),
                  chip('7 ngày qua ($recent)', _MistakeFilter.recent),
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
            Icons.check_circle_outline,
            size: 56,
            color: AppColors.success,
          ),
          const SizedBox(height: 12),
          const Text(
            'Tuyệt vời! Bạn không có câu sai nào',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tất cả câu hỏi trong các bài thi trước đều đã được bạn trả lời đúng hoặc đã ôn luyện xong.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => widget.onNavigate('exams'),
            child: const Text('Làm thêm đề thi mới'),
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
            'Không có câu hỏi phù hợp',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Hãy thử đổi từ khóa hoặc bộ lọc.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () {
              _searchCtrl.clear();
              setState(() {
                _query = '';
                _filter = _MistakeFilter.all;
              });
            },
            child: const Text('Xóa bộ lọc'),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color bg;

  const _SummaryTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MistakeCard extends StatelessWidget {
  final CauHoiSai entry;
  final VoidCallback onDelete;

  const _MistakeCard({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final q = entry.cauHoi!;
    final timeStr = DateFormat('dd/MM/yyyy HH:mm').format(entry.lanCuoiSai);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.dangerSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: AppColors.danger,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Sai ${entry.lanSai} lần',
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lần cuối: $timeStr',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onDelete,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(
                  Icons.check,
                  size: 15,
                  color: AppColors.success,
                ),
                label: const Text(
                  'Đã hiểu / Xóa',
                  style: TextStyle(color: AppColors.success, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            q.noiDung,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          for (final optKey in ['A', 'B', 'C', 'D']) _buildOption(q, optKey),
          if (q.giaiThich != null && q.giaiThich!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      q.giaiThich!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOption(CauHoi q, String optKey) {
    final text = q.getOption(optKey);
    if (text.isEmpty) return const SizedBox.shrink();

    final isCorrect = (q.dapAnDung ?? '').toUpperCase() == optKey;
    final isWrongChoice = (entry.dapAnDaChon ?? '').toUpperCase() == optKey;

    Color borderCol = AppColors.border;
    Color bgCol = AppColors.surfaceMuted;
    Color textCol = AppColors.textSecondary;

    if (isCorrect) {
      borderCol = AppColors.success;
      bgCol = AppColors.successSoft;
      textCol = AppColors.success;
    } else if (isWrongChoice) {
      borderCol = AppColors.danger;
      bgCol = AppColors.dangerSoft;
      textCol = AppColors.danger;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgCol,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderCol),
        ),
        child: Row(
          children: [
            Text(
              '$optKey. ',
              style: TextStyle(fontWeight: FontWeight.bold, color: textCol),
            ),
            Expanded(
              child: Text(text, style: TextStyle(color: textCol, fontSize: 13)),
            ),
            if (isCorrect)
              const Text(
                '✓ Đáp án đúng',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (isWrongChoice && !isCorrect)
              const Text(
                '✗ Bạn đã chọn',
                style: TextStyle(
                  color: AppColors.danger,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

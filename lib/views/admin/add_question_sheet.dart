import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../models/cau_hoi.dart';
import '../../models/de_thi.dart';

class AddQuestionSheet extends StatefulWidget {
  final DeThi exam;
  final CauHoi? editingQuestion;
  final ValueChanged<CauHoi> onSave;

  const AddQuestionSheet({
    super.key,
    required this.exam,
    this.editingQuestion,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required DeThi exam,
    CauHoi? editingQuestion,
    required ValueChanged<CauHoi> onSave,
  }) {
    final isMobile = ResponsiveLayout.isMobile(context);
    if (isMobile) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => AddQuestionSheet(
          exam: exam,
          editingQuestion: editingQuestion,
          onSave: onSave,
        ),
      );
    } else {
      return showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680, maxHeight: 820),
            child: AddQuestionSheet(
              exam: exam,
              editingQuestion: editingQuestion,
              onSave: onSave,
            ),
          ),
        ),
      );
    }
  }

  @override
  State<AddQuestionSheet> createState() => _AddQuestionSheetState();
}

class _AddQuestionSheetState extends State<AddQuestionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _contentCtrl;
  late final TextEditingController _optACtrl;
  late final TextEditingController _optBCtrl;
  late final TextEditingController _optCCtrl;
  late final TextEditingController _optDCtrl;
  late final TextEditingController _explainCtrl;
  late final TextEditingController _audioPathCtrl;
  late final TextEditingController _imagePathCtrl;

  late String _correctAns;
  late String _difficulty;
  late bool _isAudio;

  AudioPlayer? _testAudioPlayer;
  bool _isPlayingTestAudio = false;

  @override
  void initState() {
    super.initState();
    final q = widget.editingQuestion;
    _contentCtrl = TextEditingController(text: q?.noiDung ?? '');
    _optACtrl = TextEditingController(text: q?.phuongAnA ?? '');
    _optBCtrl = TextEditingController(text: q?.phuongAnB ?? '');
    _optCCtrl = TextEditingController(text: q?.phuongAnC ?? '');
    _optDCtrl = TextEditingController(text: q?.phuongAnD ?? '');
    _explainCtrl = TextEditingController(text: q?.giaiThich ?? '');
    _audioPathCtrl = TextEditingController(text: q?.audioPath ?? '');
    _imagePathCtrl = TextEditingController(text: q?.imagePath ?? '');

    _correctAns = q?.dapAnDung ?? 'A';
    _difficulty = q?.mucDoKho ?? 'Trung bình';
    _isAudio = q?.laCauHoiNghe ?? false;
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    _optACtrl.dispose();
    _optBCtrl.dispose();
    _optCCtrl.dispose();
    _optDCtrl.dispose();
    _explainCtrl.dispose();
    _audioPathCtrl.dispose();
    _imagePathCtrl.dispose();
    _testAudioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _pickAudioFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'aac', 'm4a', 'ogg'],
      );

      if (files.isNotEmpty) {
        final path = files.first.path ?? files.first.name;
        setState(() {
          _audioPathCtrl.text = path;
          _isAudio = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể chọn file âm thanh: $e')),
        );
      }
    }
  }

  Future<void> _pickImageFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'gif'],
      );

      if (files.isNotEmpty) {
        final path = files.first.path ?? files.first.name;
        setState(() {
          _imagePathCtrl.text = path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể chọn file ảnh: $e')),
        );
      }
    }
  }

  Future<void> _toggleTestAudio() async {
    final path = _audioPathCtrl.text.trim();
    if (path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn hoặc nhập đường dẫn file âm thanh trước.')),
      );
      return;
    }

    _testAudioPlayer ??= AudioPlayer();

    if (_isPlayingTestAudio) {
      await _testAudioPlayer!.stop();
      setState(() => _isPlayingTestAudio = false);
    } else {
      try {
        Source source;
        if (path.startsWith('http://') || path.startsWith('https://')) {
          source = UrlSource(path);
        } else if (!kIsWeb && File(path).existsSync()) {
          source = DeviceFileSource(path);
        } else {
          source = UrlSource('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3');
        }

        setState(() => _isPlayingTestAudio = true);
        await _testAudioPlayer!.play(source);
        _testAudioPlayer!.onPlayerComplete.listen((_) {
          if (mounted) setState(() => _isPlayingTestAudio = false);
        });
      } catch (e) {
        if (mounted) {
          setState(() => _isPlayingTestAudio = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi phát thử âm thanh: $e')),
          );
        }
      }
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final q = CauHoi(
      maCauHoi: widget.editingQuestion?.maCauHoi ?? 0,
      maDeThi: widget.exam.maDeThi,
      maChuDe: widget.exam.maChuDe,
      noiDung: _contentCtrl.text.trim(),
      phuongAnA: _optACtrl.text.trim(),
      phuongAnB: _optBCtrl.text.trim(),
      phuongAnC: _optCCtrl.text.trim(),
      phuongAnD: _optDCtrl.text.trim(),
      dapAnDung: _correctAns,
      mucDoKho: _difficulty,
      laCauHoiNghe: _isAudio,
      audioPath: _audioPathCtrl.text.trim().isNotEmpty ? _audioPathCtrl.text.trim() : null,
      imagePath: _imagePathCtrl.text.trim().isNotEmpty ? _imagePathCtrl.text.trim() : null,
      giaiThich: _explainCtrl.text.trim().isNotEmpty ? _explainCtrl.text.trim() : null,
    );

    widget.onSave(q);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editingQuestion != null;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              children: [
                Icon(
                  isEdit ? Icons.edit_note : Icons.add_circle,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isEdit ? 'Chỉnh Sửa Câu Hỏi' : 'Thêm Câu Hỏi Mới',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Form fields (Scrollable with keyboard support)
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Content
                    const Text('Nội dung câu hỏi *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _contentCtrl,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'Nhập nội dung câu hỏi trắc nghiệm...',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Nội dung không được để trống' : null,
                    ),
                    const SizedBox(height: 16),

                    // Options A, B, C, D
                    const Text('Các phương án lựa chọn *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),

                    _buildOptionField('A', _optACtrl),
                    const SizedBox(height: 8),
                    _buildOptionField('B', _optBCtrl),
                    const SizedBox(height: 8),
                    _buildOptionField('C', _optCCtrl),
                    const SizedBox(height: 8),
                    _buildOptionField('D', _optDCtrl),
                    const SizedBox(height: 16),

                    // Correct answer & difficulty
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Đáp án đúng *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: _correctAns,
                                isExpanded: true,
                                decoration: const InputDecoration(),
                                items: ['A', 'B', 'C', 'D'].map((k) => DropdownMenuItem(value: k, child: Text('Phương án $k'))).toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => _correctAns = v);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Mức độ khó', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: _difficulty,
                                isExpanded: true,
                                decoration: const InputDecoration(),
                                items: ['Dễ', 'Trung bình', 'Khó'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => _difficulty = v);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ================= IMAGE PICKER SECTION =================
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.image_outlined, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Hình ảnh minh họa câu hỏi',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _pickImageFile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primarySoft,
                                  foregroundColor: AppColors.primary,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                ),
                                icon: const Icon(Icons.folder_open, size: 16),
                                label: const Text('Chọn ảnh từ máy', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _imagePathCtrl,
                            keyboardType: TextInputType.url,
                            decoration: InputDecoration(
                              hintText: 'Đường dẫn ảnh hoặc URL (hoặc bấm nút để chọn file)...',
                              prefixIcon: const Icon(Icons.link, size: 18),
                              suffixIcon: _imagePathCtrl.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 16),
                                      onPressed: () => setState(() => _imagePathCtrl.clear()),
                                    )
                                  : null,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          if (_imagePathCtrl.text.trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildImagePreview(_imagePathCtrl.text.trim()),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ================= AUDIO PICKER SECTION =================
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Row(
                              children: [
                                Icon(Icons.audiotrack, color: AppColors.primary, size: 20),
                                SizedBox(width: 8),
                                Text('Là câu hỏi nghe (Audio TOEIC)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            value: _isAudio,
                            onChanged: (v) => setState(() => _isAudio = v),
                          ),
                          if (_isAudio) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _audioPathCtrl,
                                    decoration: InputDecoration(
                                      hintText: 'Đường dẫn file .mp3 hoặc URL...',
                                      prefixIcon: const Icon(Icons.audio_file, size: 18),
                                      suffixIcon: _audioPathCtrl.text.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(Icons.clear, size: 16),
                                              onPressed: () => setState(() => _audioPathCtrl.clear()),
                                            )
                                          : null,
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: _pickAudioFile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primarySoft,
                                    foregroundColor: AppColors.primary,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  ),
                                  icon: const Icon(Icons.folder_open, size: 16),
                                  label: const Text('Chọn file', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                            if (_audioPathCtrl.text.trim().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: _toggleTestAudio,
                                icon: Icon(_isPlayingTestAudio ? Icons.stop : Icons.play_arrow, size: 16),
                                label: Text(_isPlayingTestAudio ? 'Dừng phát' : 'Nghe thử âm thanh'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _isPlayingTestAudio ? AppColors.danger : AppColors.primary,
                                  side: BorderSide(color: _isPlayingTestAudio ? AppColors.danger : AppColors.primary),
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Explanation note
                    const Text('Lời giải thích', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _explainCtrl,
                      maxLines: 2,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(hintText: 'Giải thích chi tiết tại sao đáp án này đúng...'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom sticky action buttons
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(isEdit ? 'Lưu thay đổi' : 'Lưu câu hỏi'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionField(String key, TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Phương án $key *',
        prefixIcon: Container(
          width: 32,
          alignment: Alignment.center,
          child: Text(
            key,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ),
      ),
      validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập phương án $key' : null,
    );
  }

  Widget _buildImagePreview(String path) {
    Widget img;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      img = Image.network(path, height: 100, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.broken_image));
    } else if (!kIsWeb) {
      final f = File(path);
      if (f.existsSync()) {
        img = Image.file(f, height: 100, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.broken_image));
      } else {
        img = const Text('File ảnh không tồn tại ở đường dẫn này', style: TextStyle(color: AppColors.danger, fontSize: 12));
      }
    } else {
      img = Image.network(path, height: 100, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.broken_image));
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(width: 80, height: 60, child: img),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              path,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

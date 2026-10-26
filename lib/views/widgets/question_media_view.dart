import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class QuestionImageView extends StatelessWidget {
  final String imagePath;
  final double? maxHeight;

  const QuestionImageView({
    super.key,
    required this.imagePath,
    this.maxHeight = 220,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.trim().isEmpty) return const SizedBox.shrink();

    final path = imagePath.trim();
    Widget imgWidget;

    if (path.startsWith('http://') || path.startsWith('https://')) {
      imgWidget = Image.network(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _buildErrorWidget(),
      );
    } else if (path.startsWith('assets/')) {
      imgWidget = Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _buildErrorWidget(),
      );
    } else if (!kIsWeb) {
      final file = File(path);
      if (file.existsSync()) {
        imgWidget = Image.file(
          file,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => _buildErrorWidget(),
        );
      } else {
        imgWidget = _buildErrorWidget(label: 'Không tìm thấy file ảnh: $path');
      }
    } else {
      imgWidget = Image.network(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _buildErrorWidget(),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      constraints: BoxConstraints(maxHeight: maxHeight ?? 220),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Center(child: imgWidget),
    );
  }

  Widget _buildErrorWidget({String? label}) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.broken_image_outlined, color: AppColors.textMuted, size: 36),
          const SizedBox(height: 6),
          Text(
            label ?? 'Không thể tải hình ảnh minh họa',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

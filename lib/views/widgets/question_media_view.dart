import 'dart:convert';
import 'dart:typed_data';
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

  static Uint8List? tryDecodeDataUri(String path) {
    try {
      final trimmed = path.trim();
      if (trimmed.startsWith('data:image')) {
        final commaIdx = trimmed.indexOf(',');
        if (commaIdx != -1) {
          return base64Decode(trimmed.substring(commaIdx + 1));
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (imagePath.trim().isEmpty) return const SizedBox.shrink();

    final path = imagePath.trim();
    Widget imgWidget;

    final memoryBytes = tryDecodeDataUri(path);
    if (memoryBytes != null) {
      imgWidget = Image.memory(
        memoryBytes,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _buildErrorWidget(),
      );
    } else if (path.startsWith('http://') || path.startsWith('https://')) {
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
    } else {
      imgWidget = _buildErrorWidget(label: 'Định dạng ảnh không hợp lệ (chỉ hỗ trợ URL http/https hoặc ảnh Base64)');
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

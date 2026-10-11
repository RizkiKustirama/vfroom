import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PromptInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onGenerate;
  final VoidCallback? onAttachmentTap;

  const PromptInputBar({
    super.key,
    required this.controller,
    required this.onGenerate,
    this.onAttachmentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.slateGrey),
            onPressed: onAttachmentTap,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Describe your look...',
                hintStyle: TextStyle(color: AppColors.lightTextSecondary, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.sunsetGradient,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: IconButton(
              icon: const Text(
                '✨',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: onGenerate,
            ),
          ),
        ],
      ),
    );
  }
}

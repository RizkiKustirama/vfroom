import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'gradient_button.dart';

class PoseModal extends StatelessWidget {
  final String previewImageUrl;
  final VoidCallback onSave;
  final VoidCallback onRegenerate;
  final VoidCallback onDiscard;

  const PoseModal({
    super.key,
    required this.previewImageUrl,
    required this.onSave,
    required this.onRegenerate,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'New Pose Preview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Generated via AI Pose Switcher',
              style: TextStyle(fontSize: 13, color: AppColors.lightTextSecondary),
            ),
            const SizedBox(height: 20),

            // Pose Image Container
            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.lightBackgroundStart,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(Icons.person, size: 100, color: AppColors.primaryOrange),
              ),
            ),
            const SizedBox(height: 24),

            // Action 1: Save Pose
            GradientButton(
              text: 'Simpan Pose Permanen',
              icon: const Icon(Icons.check, color: Colors.white, size: 20),
              onPressed: onSave,
            ),
            const SizedBox(height: 12),

            // Action 2: Regenerate
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                side: const BorderSide(color: AppColors.primaryOrange, width: 1.5),
              ),
              onPressed: onRegenerate,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, color: AppColors.primaryOrange, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Generate Ulang',
                    style: TextStyle(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Action 3: Discard
            TextButton(
              onPressed: onDiscard,
              child: const Text(
                'Abaikan / Discard',
                style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

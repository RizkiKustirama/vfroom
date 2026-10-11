import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/app_colors.dart';
import 'gradient_button.dart';

class PoseModal extends StatefulWidget {
  final Uint8List? baseImageBytes;
  final String currentPoseName;
  final Function(Uint8List? newImageBytes, String poseName, bool isFlipped) onSave;
  final VoidCallback onRegenerate;
  final VoidCallback onDiscard;

  const PoseModal({
    super.key,
    this.baseImageBytes,
    required this.currentPoseName,
    required this.onSave,
    required this.onRegenerate,
    required this.onDiscard,
  });

  @override
  State<PoseModal> createState() => _PoseModalState();
}

class _PoseModalState extends State<PoseModal> {
  int _selectedTemplateIndex = 1; // Default to Walking Side
  final ImagePicker _picker = ImagePicker();
  Uint8List? _customUploadedBytes;

  final List<Map<String, dynamic>> _templates = [
    {
      'name': 'Front Standing',
      'label': '🧍 Tegak Lurus',
      'flip': false,
      'scaleY': 1.0,
      'angle': 0.0,
    },
    {
      'name': 'Walking Side Pose',
      'label': '🚶 Pose Berjalan',
      'flip': true,
      'scaleY': 1.0,
      'angle': 0.05,
    },
    {
      'name': '45° Angle Stance',
      'label': '📐 Sudut 45°',
      'flip': true,
      'scaleY': 0.98,
      'angle': -0.05,
    },
    {
      'name': 'Hands in Pocket',
      'label': '👖 Tangan Saku',
      'flip': false,
      'scaleY': 0.96,
      'angle': 0.02,
    },
  ];

  Future<void> _uploadCustomPose() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        final Uint8List bytes = await file.readAsBytes();
        setState(() {
          _customUploadedBytes = bytes;
          _selectedTemplateIndex = -1; // Custom
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih foto pose: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = _selectedTemplateIndex == -1;
    final activeTemplate = isCustom ? null : _templates[_selectedTemplateIndex];
    final activePoseName = isCustom ? 'Custom Uploaded Pose' : activeTemplate!['name'] as String;
    final isFlipped = isCustom ? false : activeTemplate!['flip'] as bool;
    final angle = isCustom ? 0.0 : (activeTemplate!['angle'] as double);

    final displayBytes = _customUploadedBytes ?? widget.baseImageBytes;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              const Text(
                'AI Pose Switcher',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pilih variasi pose atau unggah pose baru',
                style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
              ),
              const SizedBox(height: 16),

              // Template Pills Selector
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _templates.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    if (idx == _templates.length) {
                      // Custom Upload Pill
                      return GestureDetector(
                        onTap: _uploadCustomPose,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isCustom ? AppColors.primaryOrange : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(9999),
                            border: Border.all(
                              color: isCustom ? AppColors.primaryOrange : Colors.grey.shade300,
                            ),
                          ),
                          child: Center(
                            child: Row(
                              children: [
                                Icon(Icons.upload, size: 14, color: isCustom ? Colors.white : AppColors.lightTextPrimary),
                                const SizedBox(width: 4),
                                Text(
                                  'Upload Pose',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isCustom ? Colors.white : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final t = _templates[idx];
                    final isSelected = _selectedTemplateIndex == idx;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTemplateIndex = idx;
                          _customUploadedBytes = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryOrange : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(9999),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryOrange : Colors.grey.shade300,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            t['label'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Pose Preview Container
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.lightBackgroundStart,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryOrange.withOpacity(0.2)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Center(
                    child: displayBytes != null
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..scale(isFlipped ? -1.0 : 1.0, 1.0, 1.0)
                              ..rotateZ(angle),
                            child: Image.memory(
                              displayBytes,
                              height: 230,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Image.asset(
                            'assets/images/body.png',
                            height: 230,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.accessibility_new_rounded,
                              size: 100,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Pose Aktif: $activePoseName ✨',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryOrange,
                ),
              ),
              const SizedBox(height: 18),

              // Action 1: Save Pose
              GradientButton(
                text: 'Simpan & Terapkan Pose Ini',
                icon: const Icon(Icons.check, color: Colors.white, size: 20),
                onPressed: () {
                  widget.onSave(displayBytes, activePoseName, isFlipped);
                },
              ),
              const SizedBox(height: 10),

              // Action 2: Regenerate (Randomize template)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                  side: const BorderSide(color: AppColors.primaryOrange, width: 1.5),
                ),
                onPressed: () {
                  setState(() {
                    _selectedTemplateIndex = (_selectedTemplateIndex + 1) % _templates.length;
                    _customUploadedBytes = null;
                  });
                  widget.onRegenerate();
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shuffle, color: AppColors.primaryOrange, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Acak Pose Lain (Regenerate)',
                      style: TextStyle(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // Action 3: Discard
              TextButton(
                onPressed: widget.onDiscard,
                child: const Text(
                  'Abaikan / Discard',
                  style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

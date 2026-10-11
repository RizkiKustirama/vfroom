import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/app_colors.dart';
import '../providers/avatar_provider.dart';
import '../widgets/gradient_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onGetStarted;

  const OnboardingScreen({super.key, required this.onGetStarted});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _fileName;

  Future<void> _pickPhoto() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (file != null) {
        final Uint8List bytes = await file.readAsBytes();
        ref.read(avatarProvider.notifier).setAvatarImage(bytes);
        setState(() {
          _fileName = file.name;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primaryOrange,
              content: Text('Foto "${file.name}" berhasil dipilih!'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Gagal memilih foto: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarState = ref.watch(avatarProvider);
    final hasPhoto = avatarState.imageBytes != null;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Brand Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: const TextSpan(
                      text: 'VYRO ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'AI',
                          style: TextStyle(color: AppColors.primaryOrange),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
              const Spacer(),

              // Headline & Tagline
              RichText(
                text: const TextSpan(
                  text: 'Redefine Your\n',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  children: [
                    TextSpan(
                      text: 'Style ',
                      style: TextStyle(color: AppColors.primaryOrange),
                    ),
                    TextSpan(text: 'with AI'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Smart recommendations. Tailored to you.\nInstant virtual try-on on your own model.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.darkTextSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Interactive Upload Photo Card
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: _pickPhoto,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: hasPhoto
                          ? AppColors.primaryOrange.withOpacity(0.12)
                          : AppColors.darkCardSurface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: hasPhoto
                            ? AppColors.primaryOrange
                            : Colors.white.withOpacity(0.12),
                        width: hasPhoto ? 2 : 1,
                      ),
                      boxShadow: hasPhoto
                          ? [
                              BoxShadow(
                                color: AppColors.primaryOrange.withOpacity(0.25),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        // Thumbnail or Icon
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: hasPhoto
                              ? Image.memory(
                                  avatarState.imageBytes!,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryOrange.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: AppColors.primaryOrange,
                                    size: 24,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasPhoto ? 'Foto Model Terpilih ✓' : 'Upload Your Full-Body Photo',
                                style: TextStyle(
                                  color: hasPhoto ? AppColors.primaryOrange : Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hasPhoto
                                    ? (_fileName ?? 'Siap diproses oleh AI Landmark')
                                    : 'Tap di sini untuk memilih foto dari galeri',
                                style: const TextStyle(
                                  color: AppColors.darkTextSecondary,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          hasPhoto ? Icons.check_circle : Icons.upload_file,
                          color: hasPhoto ? AppColors.primaryOrange : AppColors.darkTextSecondary,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // CTA Button
              GradientButton(
                text: hasPhoto ? 'Mulai Virtual Fitting ->' : 'Get Started ->',
                onPressed: widget.onGetStarted,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

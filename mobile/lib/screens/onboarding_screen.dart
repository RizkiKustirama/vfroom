import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../widgets/gradient_button.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onGetStarted;

  const OnboardingScreen({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
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

              // Upload Photo Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.darkCardSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: AppColors.primaryOrange, size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upload Your Full-Body Photo',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'AI extracts your body landmarks instantly',
                            style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // CTA Button
              GradientButton(
                text: 'Get Started ->',
                onPressed: onGetStarted,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../widgets/prompt_input_bar.dart';
import '../widgets/wardrobe_selector.dart';

class StylistScreen extends StatefulWidget {
  const StylistScreen({super.key});

  @override
  State<StylistScreen> createState() => _StylistScreenState();
}

class _StylistScreenState extends State<StylistScreen> {
  final TextEditingController _promptController = TextEditingController();
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['All', 'Atasan', 'Bawahan', 'Outer', 'Sepatu', 'Aksesoris'];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackgroundEnd,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.search, color: AppColors.lightTextPrimary),
                    onPressed: () {},
                  ),
                  const Column(
                    children: [
                      Text(
                        'Hi, Alex',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        'AI Stylist Viewport',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: AppColors.lightTextPrimary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Center Viewport: Avatar Model with 360 Rotation Arc
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 360 Arc Indicator
                    Container(
                      width: 280,
                      height: 180,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primaryOrange.withOpacity(0.3),
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignCenter,
                        ),
                        borderRadius: BorderRadius.circular(140),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Text(
                          '< 360° >',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ),
                    ),

                    // Avatar Model Placeholder
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.accessibility_new_rounded,
                          size: 160,
                          color: AppColors.primaryOrange.withOpacity(0.85),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap garment below to try on',
                          style: TextStyle(
                            color: AppColors.lightTextSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Floating Wardrobe Category Selector
            WardrobeSelector(
              categories: _categories,
              selectedIndex: _selectedCategoryIndex,
              onCategorySelected: (idx) {
                setState(() => _selectedCategoryIndex = idx);
              },
            ),
            const SizedBox(height: 16),

            // AI Prompt Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: PromptInputBar(
                controller: _promptController,
                onGenerate: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('AI Stylist recommending matching outfit...')),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Bottom Floating Navigation Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(Icons.home, 'Home', true),
                  _navItem(Icons.favorite_border, 'Favorites', false),
                  _navItem(Icons.checkroom, 'Wardrobe', false),
                  _navItem(Icons.shopping_bag_outlined, 'Bag', false),
                  _navItem(Icons.person_outline, 'Profile', false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? AppColors.primaryOrange : AppColors.lightTextSecondary,
          size: 24,
        ),
      ],
    );
  }
}

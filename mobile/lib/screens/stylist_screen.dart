import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/app_colors.dart';
import '../providers/avatar_provider.dart';
import '../providers/wardrobe_provider.dart';
import '../widgets/prompt_input_bar.dart';
import '../widgets/wardrobe_selector.dart';
import 'item_detail_screen.dart';

class StylistScreen extends ConsumerStatefulWidget {
  const StylistScreen({super.key});

  @override
  ConsumerState<StylistScreen> createState() => _StylistScreenState();
}

class _StylistScreenState extends ConsumerState<StylistScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['All', 'Atasan', 'Bawahan', 'Outer', 'Sepatu', 'Aksesoris'];

  // Sample Wardrobe Items for testing
  final List<Map<String, dynamic>> _demoGarments = [
    {'name': 'Nexus Jacket', 'category': 'Outer', 'icon': Icons.dry_cleaning_rounded, 'color': AppColors.slateGrey},
    {'name': 'White Tee', 'category': 'Atasan', 'icon': Icons.checkroom, 'color': Colors.white},
    {'name': 'Indigo Denim', 'category': 'Bawahan', 'icon': Icons.airline_seat_legroom_extra, 'color': AppColors.obsidianBlack},
    {'name': 'Urban Kicks', 'category': 'Sepatu', 'icon': Icons.snowshoeing, 'color': AppColors.primaryOrange},
  ];

  String? _activeGarmentName;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _uploadNewGarment() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primaryOrange,
              content: Text('Baju "${file.name}" berhasil diunggah ke lemari!'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.redAccent, content: Text('Gagal memilih baju: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarState = ref.watch(avatarProvider);
    final hasAvatarPhoto = avatarState.imageBytes != null;

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
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.lightTextPrimary),
                    onPressed: () {
                      Navigator.maybePop(context);
                    },
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
                      height: 190,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primaryOrange.withOpacity(0.35),
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignCenter,
                        ),
                        borderRadius: BorderRadius.circular(140),
                      ),
                    ),

                    // Avatar Model Display
                    if (hasAvatarPhoto)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.memory(
                          avatarState.imageBytes!,
                          height: 250,
                          fit: BoxFit.contain,
                        ),
                      )
                    else
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.accessibility_new_rounded,
                            size: 150,
                            color: AppColors.primaryOrange.withOpacity(0.85),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Model Default Standby',
                            style: TextStyle(
                              color: AppColors.lightTextSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                    // Active garment badge if worn
                    if (_activeGarmentName != null)
                      Positioned(
                        top: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: AppColors.sunsetGradient,
                            borderRadius: BorderRadius.circular(9999),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryOrange.withOpacity(0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Text(
                            'Worn: $_activeGarmentName ✨',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                    // 360 Label Pill
                    Positioned(
                      bottom: 12,
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
                  ],
                ),
              ),
            ),

            // Horizontal Garment Grid/Cards
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Add New Garment Button
                  GestureDetector(
                    onTap: _uploadNewGarment,
                    child: Container(
                      width: 64,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryOrange, width: 1.5),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, color: AppColors.primaryOrange, size: 22),
                          SizedBox(height: 2),
                          Text('Tambah', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryOrange)),
                        ],
                      ),
                    ),
                  ),

                  // Garment cards
                  ..._demoGarments.map((g) {
                    final isWorn = _activeGarmentName == g['name'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeGarmentName = isWorn ? null : g['name'];
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isWorn ? 'Melepas ${g['name']}' : 'Mencoba ${g['name']} pada model!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        width: 64,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: isWorn ? AppColors.primaryOrange : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isWorn ? AppColors.primaryOrange : Colors.black.withOpacity(0.08),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              g['icon'] as IconData,
                              size: 24,
                              color: isWorn ? Colors.white : AppColors.lightTextPrimary,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              g['name'] as String,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: isWorn ? Colors.white : AppColors.lightTextSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Floating Wardrobe Category Selector
            WardrobeSelector(
              categories: _categories,
              selectedIndex: _selectedCategoryIndex,
              onCategorySelected: (idx) {
                setState(() => _selectedCategoryIndex = idx);
              },
            ),
            const SizedBox(height: 12),

            // AI Prompt Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: PromptInputBar(
                controller: _promptController,
                onAttachmentTap: _uploadNewGarment,
                onGenerate: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('AI Stylist merekomendasikan padu-padan terbaik... ✨')),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

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
                  _navItem(Icons.home, 'Home', true, null),
                  _navItem(Icons.favorite_border, 'Favorites', false, null),
                  _navItem(Icons.checkroom, 'Wardrobe', false, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ItemDetailScreen()),
                    );
                  }),
                  _navItem(Icons.shopping_bag_outlined, 'Bag', false, null),
                  _navItem(Icons.person_outline, 'Profile', false, null),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primaryOrange : AppColors.lightTextSecondary,
            size: 24,
          ),
        ],
      ),
    );
  }
}

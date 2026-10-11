import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/app_colors.dart';
import '../providers/avatar_provider.dart';
import '../providers/wardrobe_provider.dart';
import '../widgets/prompt_input_bar.dart';
import '../widgets/wardrobe_selector.dart';
import '../widgets/pose_modal.dart';
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

  String _currentPoseName = "Front Standing";
  bool _isFlippedPose = false;
  Uint8List? _activePoseImageBytes;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _changeBodyPhoto() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        final Uint8List bytes = await file.readAsBytes();
        ref.read(avatarProvider.notifier).setAvatarImage(bytes);
        setState(() {
          _activePoseImageBytes = bytes;
          _isFlippedPose = false;
          _currentPoseName = "Front Standing";
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primaryOrange,
              content: Text('Foto model berhasil diperbarui: "${file.name}"! ✨'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengganti foto model: $e')),
        );
      }
    }
  }

  Future<void> _uploadNewGarment() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        final Uint8List bytes = await file.readAsBytes();
        final newGarment = CustomGarment(
          id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
          name: file.name.replaceAll(RegExp(r'\.[a-zA-Z]+$'), ''),
          category: 'Atasan',
          imageBytes: bytes,
        );

        ref.read(wardrobeProvider.notifier).addCustomGarment(newGarment);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primaryOrange,
              content: Text('Baju "${file.name}" berhasil diunggah & dipasangkan ke model! ✨'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.redAccent, content: Text('Gagal upload: $e')),
        );
      }
    }
  }

  void _openPoseModal(Uint8List? baseBytes) {
    showDialog(
      context: context,
      builder: (ctx) => PoseModal(
        baseImageBytes: _activePoseImageBytes ?? baseBytes,
        currentPoseName: _currentPoseName,
        onSave: (newBytes, poseName, isFlipped) {
          Navigator.pop(ctx);
          setState(() {
            _currentPoseName = poseName;
            _isFlippedPose = isFlipped;
            if (newBytes != null) {
              _activePoseImageBytes = newBytes;
              ref.read(avatarProvider.notifier).setAvatarImage(newBytes);
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primaryOrange,
              content: Text('Pose berhasil diubah menjadi: "$poseName"! ✨'),
            ),
          );
        },
        onRegenerate: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mengacak variasi pose baru... 🔄')),
          );
        },
        onDiscard: () {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pose sementara dibatalkan (Discarded).')),
          );
        },
      ),
    );
  }

  void _showFavoritesSheet(Set<String> favIds) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.favorite, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text(
                    'Koleksi Favorit & Saved OOTD',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (favIds.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: Text(
                      'Belum ada item favorit.\nTekan ikon hati pada pakaian untuk menyimpan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.lightTextSecondary),
                    ),
                  ),
                )
              else
                ...favIds.map(
                  (id) => ListTile(
                    leading: const Icon(Icons.checkroom, color: AppColors.primaryOrange),
                    title: Text('Item ID: $id', style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Tersimpan di Saved Outfits'),
                    trailing: const Icon(Icons.favorite, color: Colors.redAccent, size: 20),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarState = ref.watch(avatarProvider);
    final wardrobe = ref.watch(wardrobeProvider);
    final currentAvatarBytes = _activePoseImageBytes ?? avatarState.imageBytes;
    final hasAvatarPhoto = currentAvatarBytes != null;

    final selectedCategory = _categories[_selectedCategoryIndex];
    final displayItems = selectedCategory == 'All'
        ? wardrobe.catalogGarments
        : wardrobe.catalogGarments.where((g) => g.category == selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.lightBackgroundEnd,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.lightTextPrimary),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  Column(
                    children: [
                      const Text(
                        'Hi, Alex',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        'Pose: $_currentPoseName',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w600,
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

            // Viewport Controls Bar: Ubah Pose, Ganti Foto, Reset
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ubah Pose Button
                  GestureDetector(
                    onTap: () => _openPoseModal(avatarState.imageBytes),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: AppColors.primaryOrange, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('💃', style: TextStyle(fontSize: 13)),
                          SizedBox(width: 6),
                          Text(
                            'Ubah Pose',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Ganti Foto Model Button
                  GestureDetector(
                    onTap: _changeBodyPhoto,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: AppColors.slateGrey.withOpacity(0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt_outlined, size: 14, color: AppColors.slateGrey),
                          SizedBox(width: 4),
                          Text(
                            'Ganti Foto',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slateGrey),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Reset Outfit Button if worn
                  if (wardrobe.wornGarments.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        ref.read(wardrobeProvider.notifier).clearWorn();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Semua pakaian dilepas dari model.')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: const Text(
                          'Lepas Baju ↺',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Center Viewport: Clean, Crisp Avatar Model (No 360 distortion)
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Base Model Body with Natural Orientation (Supports clean pose flips)
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..scale(_isFlippedPose ? -1.0 : 1.0, 1.0, 1.0),
                        child: hasAvatarPhoto
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.memory(
                                  currentAvatarBytes,
                                  height: 270,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : Image.asset(
                                'assets/images/body.png',
                                height: 270,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.accessibility_new_rounded,
                                      size: 160,
                                      color: AppColors.primaryOrange.withOpacity(0.85),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Model Standby',
                                      style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                      ),

                      // Layered Worn Garments (Z-Index Compositing Engine)
                      ...wardrobe.wornGarments.map((g) {
                        return Positioned(
                          top: 45,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: g.imageBytes != null
                                ? Image.memory(
                                    g.imageBytes!,
                                    height: 140,
                                    fit: BoxFit.contain,
                                  )
                                : Image.asset(
                                    g.assetPath ?? 'assets/images/garment1.png',
                                    height: 140,
                                    color: g.tintColor != null ? g.tintColor!.withOpacity(0.4) : null,
                                    colorBlendMode: g.tintColor != null ? BlendMode.srcATop : null,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.dry_cleaning_rounded,
                                      size: 100,
                                      color: g.tintColor ?? AppColors.primaryOrange,
                                    ),
                                  ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),

            // Horizontal Garment Grid/Cards
            Container(
              height: 78,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Upload Garment Button
                  GestureDetector(
                    onTap: _uploadNewGarment,
                    child: Container(
                      width: 66,
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
                          SizedBox(height: 3),
                          Text('Upload Baju', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryOrange)),
                        ],
                      ),
                    ),
                  ),

                  // Dynamic catalog garment cards
                  ...displayItems.map((g) {
                    final isWorn = wardrobe.wornGarments.any((item) => item.id == g.id);
                    return GestureDetector(
                      onTap: () {
                        ref.read(wardrobeProvider.notifier).toggleWearGarment(g);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isWorn
                                ? 'Melepas ${g.name}'
                                : 'Memakaikan ${g.name} pada avatar! ✨'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      onLongPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ItemDetailScreen(garment: g),
                          ),
                        );
                      },
                      child: Container(
                        width: 66,
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
                              color: isWorn ? AppColors.primaryOrange.withOpacity(0.3) : Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (g.imageBytes != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(g.imageBytes!, width: 28, height: 28, fit: BoxFit.cover),
                              )
                            else if (g.assetPath != null)
                              Image.asset(
                                g.assetPath!,
                                width: 28,
                                height: 28,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.checkroom,
                                  size: 24,
                                  color: isWorn ? Colors.white : AppColors.lightTextPrimary,
                                ),
                              )
                            else
                              Icon(
                                Icons.checkroom,
                                size: 24,
                                color: isWorn ? Colors.white : AppColors.lightTextPrimary,
                              ),
                            const SizedBox(height: 3),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                g.name,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: isWorn ? Colors.white : AppColors.lightTextSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
                  final text = _promptController.text.trim();
                  final nexus = wardrobe.catalogGarments.firstWhere((g) => g.id == 'nexus-jacket');
                  ref.read(wardrobeProvider.notifier).wearGarmentWithColor(nexus, AppColors.sunsetCoral);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.primaryOrange,
                      content: Text(text.isNotEmpty
                          ? 'AI Stylist merekomendasikan "$text": Memakaikan Nexus Jacket Coral ✨'
                          : 'AI Stylist merekomendasikan Casual Sunset Vibe: Memakaikan Nexus Jacket ✨'),
                    ),
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
                  _navItem(Icons.home, 'Home', true, () {}),
                  _navItem(Icons.favorite_border, 'Favorites', false, () {
                    _showFavoritesSheet(wardrobe.favoriteItemIds);
                  }),
                  _navItem(Icons.checkroom, 'Wardrobe', false, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ItemDetailScreen()),
                    );
                  }),
                  _navItem(Icons.shopping_bag_outlined, 'Bag', false, () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bag / Cart: 1 item siap checkout.')),
                    );
                  }),
                  _navItem(Icons.person_outline, 'Profile', false, () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Alex Profile: Model Avatar Aktif')),
                    );
                  }),
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

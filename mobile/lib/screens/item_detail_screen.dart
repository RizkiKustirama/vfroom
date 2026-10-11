import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../providers/wardrobe_provider.dart';
import '../widgets/gradient_button.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  final CustomGarment? garment;

  const ItemDetailScreen({super.key, this.garment});

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  int _selectedColorIndex = 0;
  final List<Color> _swatches = [
    AppColors.obsidianBlack,
    AppColors.slateGrey,
    AppColors.sageOliveGreen,
    AppColors.nudeBeige,
    AppColors.sunsetCoral,
  ];

  final List<String> _swatchNames = [
    'Obsidian Black',
    'Slate Grey',
    'Sage Olive',
    'Nude Beige',
    'Sunset Coral',
  ];

  @override
  Widget build(BuildContext context) {
    final wardrobe = ref.watch(wardrobeProvider);
    final targetGarment = widget.garment ??
        wardrobe.catalogGarments.firstWhere(
          (g) => g.id == 'nexus-jacket',
          orElse: () => CustomGarment(
            id: 'nexus-jacket',
            name: 'Nexus Tech Jacket',
            category: 'Outer',
            assetPath: 'assets/images/garment1.png',
          ),
        );

    final isFav = wardrobe.favoriteItemIds.contains(targetGarment.id);
    final selectedColor = _swatches[_selectedColorIndex];
    final selectedColorName = _swatchNames[_selectedColorIndex];

    return Scaffold(
      backgroundColor: AppColors.lightBackgroundEnd,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.lightTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Items',
          style: TextStyle(
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.redAccent : AppColors.lightTextPrimary,
            ),
            onPressed: () {
              ref.read(wardrobeProvider.notifier).toggleFavorite(targetGarment.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isFav
                      ? 'Dihapus dari koleksi favorit'
                      : 'Disimpan ke koleksi favorit ❤️'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.lightTextPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Card with Swatches and Dynamic Tint Preview
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Product Image with dynamic color tint
                      Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(24),
                          child: targetGarment.imageBytes != null
                              ? Image.memory(
                                  targetGarment.imageBytes!,
                                  height: 220,
                                  color: selectedColor.withOpacity(0.25),
                                  colorBlendMode: BlendMode.srcATop,
                                  fit: BoxFit.contain,
                                )
                              : Image.asset(
                                  targetGarment.assetPath ?? 'assets/images/garment1.png',
                                  height: 220,
                                  color: selectedColor.withOpacity(0.35),
                                  colorBlendMode: BlendMode.srcATop,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.dry_cleaning_rounded,
                                    size: 150,
                                    color: selectedColor,
                                  ),
                                ),
                        ),
                      ),

                      // Left Color Swatches Stack
                      Positioned(
                        left: 20,
                        top: 24,
                        bottom: 24,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_swatches.length, (idx) {
                            final isSelected = _selectedColorIndex == idx;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedColorIndex = idx),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                width: isSelected ? 32 : 26,
                                height: isSelected ? 32 : 26,
                                decoration: BoxDecoration(
                                  color: _swatches[idx],
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? AppColors.primaryOrange : Colors.white,
                                    width: isSelected ? 3 : 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      // Selected Color Badge
                      Positioned(
                        right: 20,
                        top: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.lightBackgroundEnd,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: selectedColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                selectedColorName,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.lightTextPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Product Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      targetGarment.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                  const Text(
                    'Zero-Shot AI Ready ✨',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slateGrey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                targetGarment.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Water-resistant fabric with modern urban ergonomic fit. Ideal for versatile casual outings.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.lightTextSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Action Footer
              Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$129.00',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        '\$199.00 (35% OFF)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.lightTextSecondary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: GradientButton(
                      text: 'Add to Wardrobe',
                      icon: const Icon(Icons.checkroom, color: Colors.white, size: 20),
                      onPressed: () {
                        // Pasang pakaian ini ke model di provider dengan warna terpilih
                        ref.read(wardrobeProvider.notifier).wearGarmentWithColor(
                              targetGarment,
                              selectedColor,
                            );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.primaryOrange,
                            content: Text(
                              '${targetGarment.name} ($selectedColorName) berhasil dipasang ke avatar! ✨',
                            ),
                          ),
                        );
                        // Kembali ke layar stylist untuk melihat hasilnya terpasang
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

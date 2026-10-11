import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../widgets/gradient_button.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int _selectedColorIndex = 0;
  final List<Color> _swatches = [
    AppColors.obsidianBlack,
    AppColors.slateGrey,
    AppColors.sageOliveGreen,
    AppColors.nudeBeige,
    AppColors.sunsetCoral,
  ];

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.favorite_border, color: AppColors.lightTextPrimary),
            onPressed: () {},
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
              // Product Card with Swatches and Preview
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
                      // Product Icon / Image Placeholder
                      const Center(
                        child: Icon(
                          Icons.dry_cleaning_rounded,
                          size: 160,
                          color: AppColors.primaryOrange,
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
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: _swatches[idx],
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? AppColors.primaryOrange : Colors.transparent,
                                    width: 2.5,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Product Info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: const Text(
                  'NEW ARRIVAL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'NEXUS TECH JACKET',
                style: TextStyle(
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Garment added to your active fitting!')),
                        );
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

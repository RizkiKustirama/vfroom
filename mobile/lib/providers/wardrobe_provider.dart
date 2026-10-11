import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomGarment {
  final String id;
  final String name;
  final String category;
  final Uint8List? imageBytes;
  final String? assetPath;
  final String? cleanImageUrl;
  final Color? tintColor;

  CustomGarment({
    required this.id,
    required this.name,
    required this.category,
    this.imageBytes,
    this.assetPath,
    this.cleanImageUrl,
    this.tintColor,
  });
}

class WardrobeState {
  final List<CustomGarment> wornGarments;
  final List<CustomGarment> catalogGarments;
  final Set<String> favoriteItemIds;
  final double rotationAngle;
  final bool isLoading;

  WardrobeState({
    this.wornGarments = const [],
    this.catalogGarments = const [],
    this.favoriteItemIds = const {},
    this.rotationAngle = 0.0,
    this.isLoading = false,
  });

  WardrobeState copyWith({
    List<CustomGarment>? wornGarments,
    List<CustomGarment>? catalogGarments,
    Set<String>? favoriteItemIds,
    double? rotationAngle,
    bool? isLoading,
  }) {
    return WardrobeState(
      wornGarments: wornGarments ?? this.wornGarments,
      catalogGarments: catalogGarments ?? this.catalogGarments,
      favoriteItemIds: favoriteItemIds ?? this.favoriteItemIds,
      rotationAngle: rotationAngle ?? this.rotationAngle,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WardrobeNotifier extends StateNotifier<WardrobeState> {
  WardrobeNotifier()
      : super(WardrobeState(
          catalogGarments: [
            CustomGarment(
              id: 'nexus-jacket',
              name: 'Nexus Tech Jacket',
              category: 'Outer',
              assetPath: 'assets/images/garment1.png',
            ),
            CustomGarment(
              id: 'white-tee',
              name: 'White Graphic Tee',
              category: 'Atasan',
              assetPath: 'assets/images/garment1.png',
            ),
            CustomGarment(
              id: 'dark-denim',
              name: 'Dark Indigo Denim',
              category: 'Bawahan',
            ),
            CustomGarment(
              id: 'urban-kicks',
              name: 'Urban Tech Kicks',
              category: 'Sepatu',
            ),
          ],
        ));

  void toggleWearGarment(CustomGarment garment) {
    final current = List<CustomGarment>.from(state.wornGarments);
    final existsIndex = current.indexWhere((g) => g.id == garment.id);

    if (existsIndex != -1) {
      current.removeAt(existsIndex);
    } else {
      // Replace garment in same category if exists
      current.removeWhere((g) => g.category == garment.category);
      current.add(garment);
    }
    state = state.copyWith(wornGarments: current);
  }

  void wearGarmentWithColor(CustomGarment garment, Color color) {
    final updated = CustomGarment(
      id: garment.id,
      name: garment.name,
      category: garment.category,
      imageBytes: garment.imageBytes,
      assetPath: garment.assetPath,
      tintColor: color,
    );

    final current = List<CustomGarment>.from(state.wornGarments);
    current.removeWhere((g) => g.category == garment.category);
    current.add(updated);
    state = state.copyWith(wornGarments: current);
  }

  void addCustomGarment(CustomGarment garment) {
    final catalog = List<CustomGarment>.from(state.catalogGarments);
    catalog.insert(0, garment);
    // Automatically wear it
    final worn = List<CustomGarment>.from(state.wornGarments);
    worn.removeWhere((g) => g.category == garment.category);
    worn.add(garment);

    state = state.copyWith(catalogGarments: catalog, wornGarments: worn);
  }

  void toggleFavorite(String garmentId) {
    final favs = Set<String>.from(state.favoriteItemIds);
    if (favs.contains(garmentId)) {
      favs.remove(garmentId);
    } else {
      favs.add(garmentId);
    }
    state = state.copyWith(favoriteItemIds: favs);
  }

  void setRotationAngle(double angle) {
    state = state.copyWith(rotationAngle: angle % 360.0);
  }

  void clearWorn() {
    state = state.copyWith(wornGarments: []);
  }
}

final wardrobeProvider = StateNotifierProvider<WardrobeNotifier, WardrobeState>((ref) {
  return WardrobeNotifier();
});

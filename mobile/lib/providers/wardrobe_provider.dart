import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/garment_item.dart';

class WardrobeState {
  final List<GarmentItem> activeGarments;
  final bool isLoading;
  final String? tryonResultImageUrl;

  WardrobeState({
    this.activeGarments = const [],
    this.isLoading = false,
    this.tryonResultImageUrl,
  });

  WardrobeState copyWith({
    List<GarmentItem>? activeGarments,
    bool? isLoading,
    String? tryonResultImageUrl,
  }) {
    return WardrobeState(
      activeGarments: activeGarments ?? this.activeGarments,
      isLoading: isLoading ?? this.isLoading,
      tryonResultImageUrl: tryonResultImageUrl ?? this.tryonResultImageUrl,
    );
  }
}

class WardrobeNotifier extends StateNotifier<WardrobeState> {
  WardrobeNotifier() : super(WardrobeState());

  void toggleGarment(GarmentItem item) {
    final current = List<GarmentItem>.from(state.activeGarments);
    final exists = current.any((g) => g.id == item.id);

    if (exists) {
      current.removeWhere((g) => g.id == item.id);
    } else {
      // Replace existing garment in the same category (e.g. only 1 top active)
      current.removeWhere((g) => g.categoryId == item.categoryId);
      current.add(item);
    }
    state = state.copyWith(activeGarments: current);
  }

  void setTryonResult(String? url) {
    state = state.copyWith(tryonResultImageUrl: url, isLoading: false);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void clearWardrobe() {
    state = WardrobeState();
  }
}

final wardrobeProvider = StateNotifierProvider<WardrobeNotifier, WardrobeState>((ref) {
  return WardrobeNotifier();
});

import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AvatarState {
  final Uint8List? imageBytes;
  final String? avatarId;
  final String? imageUrl;
  final bool isLoading;

  AvatarState({
    this.imageBytes,
    this.avatarId,
    this.imageUrl,
    this.isLoading = false,
  });

  AvatarState copyWith({
    Uint8List? imageBytes,
    String? avatarId,
    String? imageUrl,
    bool? isLoading,
  }) {
    return AvatarState(
      imageBytes: imageBytes ?? this.imageBytes,
      avatarId: avatarId ?? this.avatarId,
      imageUrl: imageUrl ?? this.imageUrl,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AvatarNotifier extends StateNotifier<AvatarState> {
  AvatarNotifier() : super(AvatarState());

  void setAvatarImage(Uint8List bytes) {
    state = state.copyWith(imageBytes: bytes);
  }

  void setAvatarUploaded({required String id, required String url}) {
    state = state.copyWith(avatarId: id, imageUrl: url, isLoading: false);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}

final avatarProvider = StateNotifierProvider<AvatarNotifier, AvatarState>((ref) {
  return AvatarNotifier();
});

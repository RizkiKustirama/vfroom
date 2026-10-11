class AvatarModel {
  final String id;
  final String userId;
  final String poseName;
  final String imageUrl;
  final String? skeletonDataUrl;
  final String status;

  AvatarModel({
    required this.id,
    required this.userId,
    required this.poseName,
    required this.imageUrl,
    this.skeletonDataUrl,
    required this.status,
  });

  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    return AvatarModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      poseName: json['pose_name'] as String? ?? 'Front Standing',
      imageUrl: json['image_url'] as String,
      skeletonDataUrl: json['skeleton_data_url'] as String?,
      status: json['status'] as String? ?? 'saved',
    );
  }
}

class GarmentItem {
  final String id;
  final String userId;
  final int categoryId;
  final String name;
  final String? subCategory;
  final String? brand;
  final String imageRawUrl;
  final String imageCleanUrl;
  final int zIndex;

  GarmentItem({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.name,
    this.subCategory,
    this.brand,
    required this.imageRawUrl,
    required this.imageCleanUrl,
    required this.zIndex,
  });

  factory GarmentItem.fromJson(Map<String, dynamic> json) {
    return GarmentItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as int,
      name: json['name'] as String,
      subCategory: json['sub_category'] as String?,
      brand: json['brand'] as String?,
      imageRawUrl: json['image_raw_url'] as String,
      imageCleanUrl: json['image_clean_url'] as String,
      zIndex: json['z_index'] as int? ?? 3,
    );
  }
}

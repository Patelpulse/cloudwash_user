class AddonModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String duration;
  final String imageUrl;
  final String category;
  final String? subCategory;
  final bool isActive;

  AddonModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.imageUrl,
    required this.category,
    this.subCategory,
    required this.isActive,
  });

  factory AddonModel.fromJson(Map<String, dynamic> json) {
    // Handle category being Map or String
    String catId = '';
    if (json['category'] is Map) {
      catId = json['category']['_id'] ?? '';
    } else if (json['category'] is String) {
      catId = json['category'];
    }

    // Handle subCategory being Map or String
    String? subCatId;
    if (json['subCategory'] is Map) {
      subCatId = json['subCategory']['_id'];
    } else if (json['subCategory'] is String) {
      subCatId = json['subCategory'];
    }

    return AddonModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      duration: json['duration'] ?? '0',
      imageUrl: json['imageUrl'] ?? '',
      category: catId,
      subCategory: subCatId,
      isActive: json['isActive'] ?? true,
    );
  }
}

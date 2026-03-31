import 'package:json_annotation/json_annotation.dart';

part 'service_model.g.dart';

@JsonSerializable()
class ServiceModel {
  @JsonKey(name: '_id') // MongoDB often uses _id
  final String id;
  final String title;
  final String? description;
  final double price;
  final String? image;
  final String category;
  final String? subCategory;
  final int? duration; // in minutes
  final double? rating;
  final int? reviewCount;
  final int displayOrder;

  ServiceModel({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    this.image,
    required this.category,
    this.subCategory,
    this.duration,
    this.rating,
    this.reviewCount,
    this.displayOrder = 100000,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
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

    int parseOrder(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 100000;
      return 100000;
    }

    return ServiceModel(
      id: json['_id'] ?? '',
      title: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      image: json['imageUrl'] ?? '',
      category: catId,
      subCategory: subCatId,
      duration: json['duration'],
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'],
      displayOrder: parseOrder(json['displayOrder']),
    );
  }

  Map<String, dynamic> toJson() => _$ServiceModelToJson(this);
}

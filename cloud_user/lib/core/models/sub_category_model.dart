import 'package:json_annotation/json_annotation.dart';

part 'sub_category_model.g.dart';

@JsonSerializable()
class SubCategoryModel {
  @JsonKey(name: '_id')
  final String id;
  final String name;
  final String? description;
  final double price;
  final String imageUrl;
  final bool isActive;
  final dynamic category;
  final int displayOrder;
  final String? mongoId;

  SubCategoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.imageUrl,
    this.isActive = true,
    this.category,
    this.displayOrder = 100000,
    this.mongoId,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$SubCategoryModelFromJson(json);
  Map<String, dynamic> toJson() => _$SubCategoryModelToJson(this);
}

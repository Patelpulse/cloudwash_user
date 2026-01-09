import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel {
  @JsonKey(name: '_id')
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final bool isActive;
  final String? mongoId;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isActive = true,
    this.mongoId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);
}

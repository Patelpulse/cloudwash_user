import 'package:json_annotation/json_annotation.dart';

part 'banner_model.g.dart';

@JsonSerializable()
class BannerModel {
  @JsonKey(name: '_id')
  final String id;
  final String title;
  final String description;
  final String position;
  final bool isActive;
  final String imageUrl;
  final int displayOrder;

  BannerModel({
    required this.id,
    required this.title,
    required this.description,
    required this.position,
    required this.isActive,
    required this.imageUrl,
    required this.displayOrder,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) =>
      _$BannerModelFromJson(json);

  Map<String, dynamic> toJson() => _$BannerModelToJson(this);
}

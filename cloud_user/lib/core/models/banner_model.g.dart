// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BannerModel _$BannerModelFromJson(Map<String, dynamic> json) => BannerModel(
  id: json['_id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  position: json['position'] as String,
  isActive: json['isActive'] as bool,
  imageUrl: json['imageUrl'] as String,
  displayOrder: (json['displayOrder'] as num).toInt(),
);

Map<String, dynamic> _$BannerModelToJson(BannerModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'position': instance.position,
      'isActive': instance.isActive,
      'imageUrl': instance.imageUrl,
      'displayOrder': instance.displayOrder,
    };

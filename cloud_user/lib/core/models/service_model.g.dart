// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceModel _$ServiceModelFromJson(Map<String, dynamic> json) => ServiceModel(
  id: json['_id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  price: (json['price'] as num).toDouble(),
  image: json['image'] as String?,
  category: json['category'] as String,
  subCategory: json['subCategory'] as String?,
  duration: (json['duration'] as num?)?.toInt(),
  rating: (json['rating'] as num?)?.toDouble(),
  reviewCount: (json['reviewCount'] as num?)?.toInt(),
  displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 100000,
);

Map<String, dynamic> _$ServiceModelToJson(ServiceModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'image': instance.image,
      'category': instance.category,
      'subCategory': instance.subCategory,
      'duration': instance.duration,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'displayOrder': instance.displayOrder,
    };

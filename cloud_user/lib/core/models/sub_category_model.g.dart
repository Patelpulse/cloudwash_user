// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubCategoryModel _$SubCategoryModelFromJson(Map<String, dynamic> json) =>
    SubCategoryModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      isActive: json['isActive'] as bool? ?? true,
      category: json['category'],
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 100000,
      mongoId: json['mongoId'] as String?,
    );

Map<String, dynamic> _$SubCategoryModelToJson(SubCategoryModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'imageUrl': instance.imageUrl,
      'isActive': instance.isActive,
      'category': instance.category,
      'displayOrder': instance.displayOrder,
      'mongoId': instance.mongoId,
    };

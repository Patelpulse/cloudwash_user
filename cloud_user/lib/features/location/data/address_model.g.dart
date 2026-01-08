// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressModel _$AddressModelFromJson(Map<String, dynamic> json) => AddressModel(
  id: json['_id'] as String,
  label: json['label'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String,
  houseNumber: json['houseNumber'] as String,
  street: json['street'] as String,
  landmark: json['landmark'] as String?,
  city: json['city'] as String,
  pincode: json['pincode'] as String,
  isDefault: json['isDefault'] as bool,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$AddressModelToJson(AddressModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'label': instance.label,
      'name': instance.name,
      'phone': instance.phone,
      'houseNumber': instance.houseNumber,
      'street': instance.street,
      'landmark': instance.landmark,
      'city': instance.city,
      'pincode': instance.pincode,
      'isDefault': instance.isDefault,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

import 'package:json_annotation/json_annotation.dart';

part 'address_model.g.dart';

@JsonSerializable()
class AddressModel {
  @JsonKey(name: '_id')
  final String id;
  final String label;
  final String name;
  final String phone;
  final String houseNumber;
  final String street;
  final String? landmark;
  final String city;
  final String pincode;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  AddressModel({
    required this.id,
    required this.label,
    required this.name,
    required this.phone,
    required this.houseNumber,
    required this.street,
    this.landmark,
    required this.city,
    required this.pincode,
    required this.isDefault,
    this.latitude,
    this.longitude,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);
  Map<String, dynamic> toJson() => _$AddressModelToJson(this);

  String get fullAddress =>
      '$houseNumber, $street, ${landmark != null ? "$landmark, " : ""}$city - $pincode';
}

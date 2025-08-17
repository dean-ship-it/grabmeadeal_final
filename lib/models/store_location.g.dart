// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreLocation _$StoreLocationFromJson(Map<String, dynamic> json) =>
    StoreLocation(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$StoreLocationToJson(StoreLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'createdAt': instance.createdAt.toIso8601String(),
    };

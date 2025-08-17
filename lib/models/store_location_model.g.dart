// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreLocation _$StoreLocationFromJson(Map<String, dynamic> json) =>
    StoreLocation(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zipCode'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phone: json['phone'] as String?,
      website: json['website'] as String?,
    );

Map<String, dynamic> _$StoreLocationToJson(StoreLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'city': instance.city,
      'state': instance.state,
      'zipCode': instance.zipCode,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'phone': instance.phone,
      'website': instance.website,
    };

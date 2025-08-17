// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Deal _$DealFromJson(Map<String, dynamic> json) => Deal(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  vendor: json['vendor'] as String,
  category: json['category'] as String,
  price: (json['price'] as num).toDouble(),
  originalPrice: (json['originalPrice'] as num?)?.toDouble(),
  imageUrl: json['imageUrl'] as String?,
  expiryDate: json['expiryDate'] == null
      ? null
      : DateTime.parse(json['expiryDate'] as String),
);

Map<String, dynamic> _$DealToJson(Deal instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'vendor': instance.vendor,
  'category': instance.category,
  'price': instance.price,
  'originalPrice': instance.originalPrice,
  'imageUrl': instance.imageUrl,
  'expiryDate': instance.expiryDate?.toIso8601String(),
};

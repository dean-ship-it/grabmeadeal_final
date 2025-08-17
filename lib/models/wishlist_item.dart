import 'package:json_annotation/json_annotation.dart';

part 'wishlist_item.g.dart';

@JsonSerializable()
class WishlistItem {
  final String id;
  final String dealId;
  final String userId;
  final DateTime addedAt;

  WishlistItem({
    required this.id,
    required this.dealId,
    required this.userId,
    required this.addedAt,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) =>
      _$WishlistItemFromJson(json);

  Map<String, dynamic> toJson() => _$WishlistItemToJson(this);
}

// lib/models/want_item.dart

class WantItem {
  final String id;
  final String userId;
  final String keyword;
  final String? category;
  final double? maxPrice;
  final bool active;
  final DateTime createdAt;
  final DateTime? lastMatchedAt;
  final String? lastMatchedDealId;

  const WantItem({
    required this.id,
    required this.userId,
    required this.keyword,
    this.category,
    this.maxPrice,
    this.active = true,
    required this.createdAt,
    this.lastMatchedAt,
    this.lastMatchedDealId,
  });

  factory WantItem.fromMap(Map<String, dynamic> map, String id) => WantItem(
        id: id,
        userId: map["userId"] ?? "",
        keyword: map["keyword"] ?? "",
        category: map["category"],
        maxPrice: map["maxPrice"] != null
            ? (map["maxPrice"] as num).toDouble()
            : null,
        active: map["active"] ?? true,
        createdAt: map["createdAt"] != null
            ? DateTime.parse(map["createdAt"])
            : DateTime.now(),
        lastMatchedAt: map["lastMatchedAt"] != null
            ? DateTime.parse(map["lastMatchedAt"])
            : null,
        lastMatchedDealId: map["lastMatchedDealId"],
      );

  Map<String, dynamic> toMap() => {
        "userId": userId,
        "keyword": keyword,
        "category": category,
        "maxPrice": maxPrice,
        "active": active,
        "createdAt": createdAt.toIso8601String(),
        "lastMatchedAt": lastMatchedAt?.toIso8601String(),
        "lastMatchedDealId": lastMatchedDealId,
      };

  WantItem copyWith({
    bool? active,
    DateTime? lastMatchedAt,
    String? lastMatchedDealId,
  }) =>
      WantItem(
        id: id,
        userId: userId,
        keyword: keyword,
        category: category,
        maxPrice: maxPrice,
        active: active ?? this.active,
        createdAt: createdAt,
        lastMatchedAt: lastMatchedAt ?? this.lastMatchedAt,
        lastMatchedDealId: lastMatchedDealId ?? this.lastMatchedDealId,
      );
}

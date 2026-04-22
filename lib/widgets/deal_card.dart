// lib/widgets/deal_card.dart

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:grabmeadeal_final/models/deal.dart";
import "package:grabmeadeal_final/services/deal_sanity.dart";

class DealCard extends StatelessWidget {
  final Deal deal;
  final bool isInWishlist;
  final VoidCallback onTap;
  final VoidCallback onWishlistToggle;

  const DealCard({
    super.key,
    required this.deal,
    required this.isInWishlist,
    required this.onTap,
    required this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Only show the -XX% badge when the underlying savings look real.
    // Shared predicate in deal_sanity.dart keeps grid tiles consistent
    // with the hero card and hero auto-picker.
    final hasSavings = hasBelievableSavings(deal);
    final savings = hasSavings ? deal.originalPrice! - deal.price : 0.0;
    final savingsPct = hasSavings
        ? ((savings / deal.originalPrice!) * 100).round()
        : 0;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──
            Stack(
              children: [
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: deal.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: deal.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _placeholder(),
                          errorWidget: (_, __, ___) => _fallback(),
                        )
                      : _fallback(),
                ),
                // Savings badge top right
                if (hasSavings)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "-$savingsPct%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                // Wishlist button top left
                Positioned(
                  top: 4,
                  left: 4,
                  child: GestureDetector(
                    onTap: onWishlistToggle,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isInWishlist
                            ? Icons.favorite_rounded
                            : Icons.favorite_border,
                        color: isInWishlist ? Colors.red : Colors.grey,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Content ──
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    deal.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Vendor
                  if (deal.vendor.isNotEmpty)
                    Text(
                      deal.vendor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  const SizedBox(height: 4),
                  // Price row
                  Row(
                    children: [
                      Text(
                        "\$${deal.price.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      if (hasSavings) ...[
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            "\$${deal.originalPrice!.toStringAsFixed(0)}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _fallback() {
    const Map<String, String> categoryAssets = {
      "electronics": "assets/category_icons/electronics.png",
      "furniture": "assets/category_icons/furniture.png",
      "tools": "assets/category_icons/tools.png",
      "beauty": "assets/category_icons/beauty.png",
      "petSupplies": "assets/category_icons/pet_supplies.png",
      "pet_supplies": "assets/category_icons/pet_supplies.png",
      "petsupplies": "assets/category_icons/pet_supplies.png",
      "apparel": "assets/category_icons/apparel.png",
      "automotive": "assets/category_icons/automotive.png",
      "grocery": "assets/category_icons/grocery.png",
      "homeGoods": "assets/category_icons/home_goods.png",
      "home_goods": "assets/category_icons/home_goods.png",
      "homegoods": "assets/category_icons/home_goods.png",
      "food": "assets/category_icons/food.png",
      "travel": "assets/category_icons/travel.png",
      "healthWellness": "assets/category_icons/health_wellness.png",
      "health_wellness": "assets/category_icons/health_wellness.png",
      "sports": "assets/category_icons/sports.png",
      "insurance": "assets/category_icons/insurance.png",
      "energy": "assets/category_icons/energy.png",
    };
    const Map<String, String> categoryEmoji = {
      "electronics": "\u{1F4BB}",
      "furniture": "\u{1F6CB}",
      "tools": "\u{1F6E0}",
      "gaming": "\u{1F3AE}",
      "beauty": "\u{1F484}",
      "petSupplies": "\u{1F43E}",
      "apparel": "\u{1F455}",
      "automotive": "\u{1F697}",
      "grocery": "\u{1F6D2}",
      "homeGoods": "\u{1F3E0}",
      "fitness": "\u{1F3CB}\u{FE0F}",
    };
    final key = deal.category;
    final asset = categoryAssets[key];
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF5F6F8), Color(0xFFEDEFF3)],
        ),
      ),
      child: Center(
        child: asset != null
            ? Padding(
                padding: const EdgeInsets.all(14),
                child: Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Text(
                    categoryEmoji[key] ?? "\u{1F3F7}",
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              )
            : Text(
                categoryEmoji[key] ?? "\u{1F3F7}",
                style: const TextStyle(fontSize: 40),
              ),
      ),
    );
  }
}

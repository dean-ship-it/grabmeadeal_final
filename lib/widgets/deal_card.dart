// lib/widgets/deal_card.dart

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:grabmeadeal_final/models/deal.dart";

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
    final hasSavings = deal.originalPrice != null && deal.originalPrice! > deal.price;
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
    final Map<String, Color> categoryColors = {
      "electronics": const Color(0xFF1565C0),
      "furniture": const Color(0xFF4E342E),
      "tools": const Color(0xFF37474F),
      "gaming": const Color(0xFF6A1B9A),
      "beauty": const Color(0xFFAD1457),
      "petSupplies": const Color(0xFF2E7D32),
      "apparel": const Color(0xFF0075C9),
      "automotive": const Color(0xFF004A8D),
      "grocery": const Color(0xFF558B2F),
      "homeGoods": const Color(0xFFE65100),
      "fitness": const Color(0xFFC62828),
    };
    final Map<String, String> categoryIcons = {
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
    final color = categoryColors[deal.category] ?? const Color(0xFF0075C9);
    final icon = categoryIcons[deal.category] ?? "\u{1F3F7}";
    return Container(
      color: color,
      child: Center(
        child: Text(icon, style: const TextStyle(fontSize: 40)),
      ),
    );
  }
}

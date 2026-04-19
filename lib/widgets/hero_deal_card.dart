// lib/widgets/hero_deal_card.dart
//
// The "Recommended for You" hero card. Bigger, splashier visual treatment
// than the regular DealCard — earns the prime above-the-fold real estate.
//
// Design language:
//   - Larger image (220px vs 120px)
//   - Gold accent border (brand color, signals "premium pick")
//   - Bold gold "SAVE $X" badge with both savings amount and percent
//   - Wishlist heart top-left (same as DealCard)
//   - Bigger title (18px) + price (24px) typography
//   - Full-width lime green CTA button — high-contrast call to action
//
// Single-purpose widget. The regular DealCard handles grid/list contexts.

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:grabmeadeal_final/models/deal.dart";

class HeroDealCard extends StatelessWidget {
  final Deal deal;
  final bool isInWishlist;
  final VoidCallback onTap;
  final VoidCallback onWishlistToggle;

  const HeroDealCard({
    super.key,
    required this.deal,
    required this.isInWishlist,
    required this.onTap,
    required this.onWishlistToggle,
  });

  static const _gold = Color(0xFFF5C518);
  static const _navy = Color(0xFF062245);
  static const _lime = Color(0xFFA6CE39);

  @override
  Widget build(BuildContext context) {
    final hasSavings =
        deal.originalPrice != null && deal.originalPrice! > deal.price;
    final savingsAmount = hasSavings ? deal.originalPrice! - deal.price : 0.0;
    final savingsPct = hasSavings
        ? ((savingsAmount / deal.originalPrice!) * 100).round()
        : 0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _gold, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: _gold.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image with overlays ──
              Stack(
                children: [
                  SizedBox(
                    height: 220,
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
                  // Gold "SAVE $X" badge (top right) — the splash element
                  if (hasSavings)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_gold, Color(0xFFD4A017)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "SAVE \$${savingsAmount.toStringAsFixed(0)}",
                              style: const TextStyle(
                                color: _navy,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              "$savingsPct% OFF",
                              style: const TextStyle(
                                color: _navy,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Wishlist heart (top left)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: GestureDetector(
                      onTap: onWishlistToggle,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isInWishlist
                              ? Icons.favorite_rounded
                              : Icons.favorite_border,
                          color: isInWishlist ? Colors.red : Colors.grey.shade700,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Content ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      deal.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: _navy,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Vendor
                    if (deal.vendor.isNotEmpty)
                      Text(
                        deal.vendor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    const SizedBox(height: 10),
                    // Price row — bigger, more emphatic
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (deal.price > 0) ...[
                          Text(
                            "\$${deal.price.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              height: 1.0,
                            ),
                          ),
                          if (hasSavings) ...[
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                "\$${deal.originalPrice!.toStringAsFixed(0)}",
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey.shade500,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // ── CTA button — full-width lime ──
              InkWell(
                onTap: onTap,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  color: _lime,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "GRAB IT NOW",
                        style: TextStyle(
                          color: _navy,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: _navy,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: _navy,
      child: const Center(
        child: Text("\u{1F3F7}", style: TextStyle(fontSize: 60)),
      ),
    );
  }
}

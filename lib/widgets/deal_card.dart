import "package:cached_network_image/cached_network_image.dart";
import "package:firebase_auth/firebase_auth.dart";
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

  Widget _imageFallback() {
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
      "outdoor": const Color(0xFF00695C),
      "homeGoods": const Color(0xFFE65100),
      "toys": const Color(0xFFF9A825),
      "cleaning": const Color(0xFF00838F),
      "fitness": const Color(0xFFC62828),
      "art": const Color(0xFF6A1B9A),
      "business": const Color(0xFF1B5E20),
    };

    final Map<String, String> categoryIcons = {
      "electronics": "💻",
      "furniture": "🛋",
      "tools": "🛠",
      "gaming": "🎮",
      "beauty": "💄",
      "petSupplies": "🐾",
      "apparel": "👕",
      "automotive": "🚗",
      "grocery": "🛒",
      "outdoor": "🏕",
      "homeGoods": "🏠",
      "toys": "🧸",
      "cleaning": "🧹",
      "fitness": "🏋️",
      "art": "🎨",
      "business": "📈",
    };

    final color = categoryColors[deal.category] ?? const Color(0xFF0075C9);
    final icon = categoryIcons[deal.category] ?? "🏷";

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          icon,
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }

  void _promptSignIn(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_border, size: 48, color: Color(0xFF0075C9)),
            const SizedBox(height: 16),
            const Text(
              "Sign in to save deals",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              "Create a free account to save deals, build your want list, and get deal alerts.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, "/auth");
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0075C9),
                ),
                child: const Text(
                  "Sign In / Create Account",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "Maybe later",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSavings = deal.originalPrice != null &&
        deal.originalPrice! > deal.price;
    final savings = hasSavings
        ? ((1 - deal.price / deal.originalPrice!) * 100).round()
        : 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image ──
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: deal.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: deal.imageUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 72,
                          height: 72,
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => _imageFallback(),
                      )
                    : _imageFallback(),
              ),
              const SizedBox(width: 12),

              // ── Text content — Flexible prevents Row overflow ──
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title: max 2 lines with ellipsis
                    Text(
                      deal.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),

                    // Vendor: single line with ellipsis
                    Text(
                      deal.vendor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                    const SizedBox(height: 6),

                    // Price row with optional savings badge
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            "\$${deal.price.toStringAsFixed(2)}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        if (hasSavings) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              "-$savings%",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    if (deal.originalPrice != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        "Was \$${deal.originalPrice!.toStringAsFixed(2)}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],

                    // Category chip
                    if (deal.category.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0075C9).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          deal.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0075C9),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Wishlist icon — compact Column with min size ──
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      isInWishlist ? Icons.favorite : Icons.favorite_border,
                      color: isInWishlist ? Colors.red : null,
                    ),
                    onPressed: () {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        _promptSignIn(context);
                      } else {
                        onWishlistToggle();
                      }
                    },
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

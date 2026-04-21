import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:url_launcher/url_launcher.dart";
import "package:grabmeadeal_final/models/deal.dart";
import "package:grabmeadeal_final/providers/puzzle_provider.dart";
import "package:grabmeadeal_final/providers/want_list_provider.dart";
import "package:grabmeadeal_final/providers/wishlist_provider.dart";
import "package:grabmeadeal_final/services/amazon_affiliate.dart";

class DealDetailScreen extends StatelessWidget {
  final Deal? deal;

  const DealDetailScreen({super.key, required this.deal});

  Future<void> _launchDealUrl(BuildContext context, String url) async {
    // Unlock puzzle piece for this category before launching
    if (deal!.category.isNotEmpty) {
      try {
        final puzzle = context.read<PuzzleProvider>();
        await puzzle.unlockCategory(deal!.category);
      } catch (e) {
        debugPrint("[Puzzle] Unlock error: $e");
      }
    }

    // Tag Amazon URLs with our Associates ID so click-throughs earn
    // commission. No-op for non-Amazon hosts.
    final taggedUrl = addAmazonAffiliateTag(url);
    final uri = Uri.tryParse(taggedUrl);
    if (uri == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid deal URL.")),
        );
      }
      return;
    }

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open deal link.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (deal == null) {
      return const Scaffold(
        body: Center(child: Text("Deal not found.")),
      );
    }

    final wishlist = context.watch<WishlistProvider>();
    final isInWishlist = wishlist.wishlistIds.contains(deal!.id);
    final hasSavings = deal!.originalPrice != null &&
        deal!.originalPrice! > deal!.price;
    final savings = hasSavings
        ? ((1 - deal!.price / deal!.originalPrice!) * 100).round()
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(deal!.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? Colors.red : Colors.white,
            ),
            onPressed: () => wishlist.toggleWishlist(deal!),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero image ──
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                deal!.imageUrl,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 220, color: Colors.grey[300]),
              ),
            ),
            const SizedBox(height: 16),

            // ── Title ──
            Text(
              deal!.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // ── Price row ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "\$${deal!.price.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                if (hasSavings) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      "-$savings%",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  deal!.vendor,
                  style: const TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            if (hasSavings) ...[
              const SizedBox(height: 4),
              Text(
                "Was \$${deal!.originalPrice!.toStringAsFixed(2)}",
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // ── Category chip ──
            Row(
              children: [
                const Icon(Icons.category, color: Colors.blueGrey, size: 18),
                const SizedBox(width: 6),
                Text(
                  deal!.category,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0075C9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Description ──
            const Text(
              "Description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(deal!.description, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 32),

            // ── View Deal button ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart_checkout),
                label: const Text(
                  "View Deal",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0075C9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: deal!.dealUrl.isNotEmpty
                    ? () => _launchDealUrl(context, deal!.dealUrl)
                    : null,
              ),
            ),

            // ── Notify Me Nearby ──
            if (deal!.category.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      Navigator.pushNamed(context, "/auth");
                      return;
                    }
                    final wantList = context.read<WantListProvider>();
                    await wantList.addWant(
                      keyword: deal!.title,
                      category: deal!.category,
                      maxPrice: deal!.price,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.notifications_active, color: Colors.white),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "We'll notify you when this deal goes on sale nearby!",
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF0075C9),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.notifications_outlined),
                  label: const Text("Notify Me Nearby"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0075C9),
                    side: const BorderSide(color: Color(0xFF0075C9)),
                  ),
                ),
              ),
            ],

            // ── Puzzle unlock hint ──
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.extension, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  "Viewing this deal unlocks a puzzle piece!",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

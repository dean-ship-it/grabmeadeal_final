// lib/screens/wishlist_screen.dart

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:grabmeadeal_final/providers/wishlist_provider.dart";
import "package:grabmeadeal_final/routes/app_routes.dart";
import "package:grabmeadeal_final/widgets/deal_card.dart";

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final deals = wishlist.wishlistDeals;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Wishlist",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: deals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    "Your wishlist is empty",
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Browse deals and tap the ♥ to save them here.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black45),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: deals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final deal = deals[index];
                return DealCard(
                  deal: deal,
                  isInWishlist: true,
                  onWishlistToggle: () => wishlist.toggleWishlist(deal),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.dealDetail,
                    arguments: deal,
                  ),
                );
              },
            ),
    );
  }
}

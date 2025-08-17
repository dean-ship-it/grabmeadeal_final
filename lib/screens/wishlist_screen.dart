import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/widgets/deal_card.dart';

class WishlistScreen extends StatelessWidget {
  final List<Deal> wishlistDeals;
  final Function(Deal deal, bool isInWishlist) onWishlistToggle;

  const WishlistScreen({
    super.key,
    required this.wishlistDeals,
    required this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Wishlist",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: wishlistDeals.isEmpty
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
              itemCount: wishlistDeals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final deal = wishlistDeals[index];
                return DealCard(
                  deal: deal,
                  isInWishlist: true,
                  onWishlistToggle: () => onWishlistToggle(deal, true),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/dealDetail',
                      arguments: deal,
                    );
                  },
                );
              },
            ),
    );
  }
}

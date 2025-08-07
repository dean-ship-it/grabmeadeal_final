import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/widgets/deal_card.dart';

class WishlistDealsScreen extends StatelessWidget {
  final List<Deal> wishlistDeals;
  final Set<String> wishlistIds;
  final void Function(Deal) onWishlistToggle;

  const WishlistDealsScreen({
    super.key,
    required this.wishlistDeals,
    required this.wishlistIds,
    required this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Wishlist'),
      ),
      body: wishlistDeals.isEmpty
          ? const Center(
              child: Text(
                'No items in your wishlist yet.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: wishlistDeals.length,
              itemBuilder: (context, index) {
                final deal = wishlistDeals[index];
                return DealCard(
                  deal: deal,
                  isInWishlist: wishlistIds.contains(deal.id),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/deal-detail',
                      arguments: {'deal': deal, 'isInWishlist': true},
                    );
                  },
                  onWishlistToggle: () => onWishlistToggle(deal),
                );
              },
            ),
    );
  }
}

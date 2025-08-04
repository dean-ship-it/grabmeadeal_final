import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/providers/wishlist_provider.dart';
import 'package:grabmeadeal_final/widgets/deal_card.dart';

class WishlistDealsScreen extends StatelessWidget {
  const WishlistDealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final List<Deal> wishlistDeals = wishlistProvider.wishlistDeals;
    final Set<String> wishlistIds = wishlistProvider.wishlistIds;

    if (wishlistDeals.isEmpty) {
      return const Center(child: Text('No deals in your wishlist.'));
    }
    return ListView.builder(
      itemCount: wishlistDeals.length,
      itemBuilder: (context, index) {
        final deal = wishlistDeals[index];
        return DealCard(
          deal: deal,
          isInWishlist: wishlistIds.contains(deal.id),
          onWishlistToggle: wishlistProvider.toggleWishlist,
        );
      },
    );
  }
}

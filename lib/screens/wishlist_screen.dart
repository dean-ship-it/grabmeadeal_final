// lib/screens/wishlist_screen.dart

import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/widgets/wishlist_deal_card.dart';

class WishlistScreen extends StatelessWidget {
  final List<Deal> wishlistDeals;
  final Set<String> wishlistIds;
  final void Function(Deal) onWishlistToggle;

  const WishlistScreen({
    Key? key,
    required this.wishlistDeals,
    required this.wishlistIds,
    required this.onWishlistToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedWishlist = [...wishlistDeals]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Wishlist'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
      ),
      body: wishlistDeals.isEmpty
          ? const Center(
              child: Text(
                'No deals in your wishlist yet.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemCount: sortedWishlist.length,
              itemBuilder: (ctx, i) {
                final deal = sortedWishlist[i];
                return WishlistDealCard(
                  imageUrl: deal.imageUrl,
                  title: deal.title,
                  vendor: deal.vendor,
                  deal: deal,
                  isInWishlist: wishlistIds.contains(deal.id),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/deal-detail',
                      arguments: deal,
                    );
                  },
                  onWishlistToggle: () => onWishlistToggle(deal),
                );
              },
            ),
    );
  }
}

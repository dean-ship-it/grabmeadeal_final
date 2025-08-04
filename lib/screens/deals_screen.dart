// lib/screens/deals_screen.dart

import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/widgets/deal_card.dart';
import 'package:grabmeadeal_final/widgets/search_bar.dart';

class DealsScreen extends StatelessWidget {
  final List<Deal> deals;
  final Set<String> wishlistIds;
  final void Function(Deal) onWishlistToggle;

  const DealsScreen({
    super.key,
    required this.deals,
    required this.wishlistIds,
    required this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    final sortedDeals = [...deals]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deals'),
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomSearchBar(
              results: sortedDeals,
              wishlistIds: wishlistIds,
              onWishlistToggle: onWishlistToggle,
              onSearch: (query) {},
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemCount: sortedDeals.length,
              itemBuilder: (ctx, i) {
                final deal = sortedDeals[i];
                return DealCard(
                  deal: deal,
                  isInWishlist: wishlistIds.contains(deal.id),
                  onWishlistToggle: onWishlistToggle,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

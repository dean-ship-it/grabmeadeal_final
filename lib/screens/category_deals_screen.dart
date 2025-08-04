// lib/screens/category_deals_screen.dart

import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/widgets/deal_card.dart';

class CategoryDealsScreen extends StatelessWidget {
  final String category;
  final List<Deal> deals;
  final Set<String> wishlistIds;
  final void Function(Deal) onWishlistToggle;

  const CategoryDealsScreen({
    super.key,
    required this.category,
    required this.deals,
    required this.wishlistIds,
    required this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Filter deals for this category
    final filteredDeals = deals
        .where((deal) => deal.category == category)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // optional: sort by date

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: filteredDeals.isEmpty
          ? const Center(child: Text('No deals in this category.'))
          : ListView.builder(
              itemCount: filteredDeals.length,
              itemBuilder: (ctx, i) {
                final deal = filteredDeals[i];
                return DealCard(
                  deal: deal,
                  isInWishlist: wishlistIds.contains(deal.id),
                  onWishlistToggle: onWishlistToggle,
                );
              },
            ),
    );
  }
}

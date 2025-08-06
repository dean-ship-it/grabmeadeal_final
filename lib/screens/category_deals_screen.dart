// lib/screens/category_deals_screen.dart

import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/widgets/deal_card.dart';

class CategoryDealsScreen extends StatelessWidget {
  final String category;
  final List<Deal> deals;
  final Set<String> wishlistIds;
  final void Function(Deal) onWishlistToggle;
  final VoidCallback onTap;

  const CategoryDealsScreen({
    super.key,
    required this.category,
    required this.deals,
    required this.wishlistIds,
    required this.onWishlistToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final filteredDeals = deals.where((deal) => deal.category == category).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: filteredDeals.isEmpty
          ? const Center(
              child: Text('No deals found in this category.'),
            )
          : ListView.builder(
              itemCount: filteredDeals.length,
              itemBuilder: (ctx, i) {
                final deal = filteredDeals[i];
                return DealCard(
                  deal: deal,
                  isInWishlist: wishlistIds.contains(deal.id),
                  onWishlistToggle: () => onWishlistToggle(deal),
                  onTap: onTap,
                );
              },
            ),
    );
  }
}

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
    final filteredDeals = deals.where((deal) => deal.category == category).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: ListView.builder(
        itemCount: filteredDeals.length,
        itemBuilder: (context, index) {
          final deal = filteredDeals[index];
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

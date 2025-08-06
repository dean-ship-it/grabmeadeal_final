import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/models/category.dart';
import 'package:grabmeadeal_final/widgets/deal_card.dart';

class CategoryDealsScreen extends StatelessWidget {
  final Category category;
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
    final categoryDeals = deals.where((deal) => deal.category == category.name).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${category.name} Deals'),
        centerTitle: true,
      ),
      body: categoryDeals.isEmpty
          ? const Center(child: Text('No deals found in this category.'))
          : ListView.builder(
              itemCount: categoryDeals.length,
              itemBuilder: (context, index) {
                final deal = categoryDeals[index];
                return DealCard(
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

import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/widgets/deal_card.dart';

class SearchResultsScreen extends StatelessWidget {
  final List<Deal> deals;
  final Set<String> wishlistIds;
  final void Function(Deal) onWishlistToggle;

  const SearchResultsScreen({
    super.key,
    required this.deals,
    required this.wishlistIds,
    required this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Results',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0075c9),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: deals.isEmpty
          ? const Center(
              child: Text(
                'No deals found.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: deals.length,
              itemBuilder: (context, index) {
                final deal = deals[index];
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

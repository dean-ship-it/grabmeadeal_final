import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/widgets/deal_card.dart';

class SearchResultsScreen extends StatelessWidget {
  final List<Deal> results;
  final Set<String> wishlistIds;
  final void Function(Deal) onWishlistToggle;

  const SearchResultsScreen({
    super.key,
    required this.results,
    required this.wishlistIds,
    required this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
      ),
      body: results.isEmpty
          ? const Center(child: Text('No results found.'))
          : ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final deal = results[index];
                return DealCard(
                  deal: deal,
                  isInWishlist: wishlistIds.contains(deal.id),
                  onTap: () {
                    // TODO: Add navigation to deal detail if needed
                  },
                  onWishlistToggle: () => onWishlistToggle(deal),
                );
              },
            ),
    );
  }
}

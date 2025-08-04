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
    required this.onWishlistToggle, required String searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final sortedResults = [...results]
      ..sort((a, b) => (b.date).compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: sortedResults.isEmpty
          ? const Center(
              child: Text(
                'No deals found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
              itemCount: sortedResults.length,
              itemBuilder: (context, index) {
                final deal = sortedResults[index];
                final isInWishlist = wishlistIds.contains(deal.id);

                return DealCard(
                  deal: deal,
                  isInWishlist: isInWishlist,
                  onWishlistToggle: onWishlistToggle,
                );
              },
            ),
    );
  }
}

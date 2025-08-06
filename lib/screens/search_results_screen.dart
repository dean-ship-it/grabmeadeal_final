import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/widgets/deal_card.dart';

class SearchResultsScreen extends StatelessWidget {
  final List<Deal> results;
  final Set<String> wishlistIds;
  final void Function(Deal) onWishlistToggle;
  final VoidCallback onTap;

  const SearchResultsScreen({
    super.key,
    required this.results,
    required this.wishlistIds,
    required this.onWishlistToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
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
                  onWishlistToggle: () => onWishlistToggle(deal),
                  onTap: onTap,
                );
              },
            ),
    );
  }
}

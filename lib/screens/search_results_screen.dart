import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/widgets/deal_card.dart';
import 'package:grabmeadeal_final/screens/deal_detail_screen.dart';

class SearchResultsScreen extends StatelessWidget {
  final String searchQuery;
  final List<Deal> results;
  final Function(Deal deal, bool isInWishlist) onWishlistToggle;
  final List<String> wishlistIds;

  const SearchResultsScreen({
    super.key,
    required this.searchQuery,
    required this.results,
    required this.onWishlistToggle,
    required this.wishlistIds,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Results for "$searchQuery"',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: results.isEmpty
          ? const Center(
              child: Text(
                "No deals found.\nTry another search.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final deal = results[index];
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DealCard(
                    deal: deal,
                    isInWishlist: wishlistIds.contains(deal.id),
                    onWishlistToggle: (deal, isInWishlist) {
                      onWishlistToggle(deal, isInWishlist);
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DealDetailScreen(
                            deal: deal,
                            isInWishlist: wishlistIds.contains(deal.id),
                            onWishlistToggle: onWishlistToggle,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

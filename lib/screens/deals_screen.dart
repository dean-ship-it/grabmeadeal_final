import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/widgets/deal_card.dart';
import 'package:grabmeadeal_final/widgets/search_bar.dart';

class DealsScreen extends StatelessWidget {
  final List<Deal> deals;
  final Set<String> wishlistIds;
  final void Function(Deal) onWishlistToggle;
  final void Function(String) onSearch;

  const DealsScreen({
    super.key,
    required this.deals,
    required this.wishlistIds,
    required this.onWishlistToggle,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deals'),
      ),
      body: Column(
        children: [
          CustomSearchBar(
            results: deals,
            wishlistIds: wishlistIds,
            onWishlistToggle: onWishlistToggle,
            onSearch: onSearch,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: deals.length,
              itemBuilder: (context, index) {
                final deal = deals[index];
                final isInWishlist = wishlistIds.contains(deal.id);

                return DealCard(
                  deal: deal,
                  isInWishlist: isInWishlist,
                  onWishlistToggle: () => onWishlistToggle(deal),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/deal-detail',
                      arguments: deal,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

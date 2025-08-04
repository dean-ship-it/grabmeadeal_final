import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/models/category.dart';
import 'package:grabmeadeal_final/screens/main_tab_controller.dart';

class HomeScreen extends StatelessWidget {
  final List<Deal> deals;
  final List<Deal> wishlistDeals;
  final Set<String> wishlistIds;
  final List<Category> categories;
  final void Function(Deal) onWishlistToggle;

  const HomeScreen({
    super.key,
    required this.deals,
    required this.wishlistDeals,
    required this.wishlistIds,
    required this.categories,
    required this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    return MainTabController(
      deals: deals,
      wishlistDeals: wishlistDeals,
      wishlistIds: wishlistIds,
      categories: categories,
      onWishlistToggle: onWishlistToggle, allDeals: [],
    );
  }
}

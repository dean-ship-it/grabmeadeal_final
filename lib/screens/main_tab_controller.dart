import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/screens/deals_screen.dart';
import 'package:grabmeadeal_final/screens/wishlist_screen.dart';
import 'package:grabmeadeal_final/screens/categories_screen.dart';

class MainTabController extends StatefulWidget {
  final List<Deal> deals;
  final Set<String> wishlistIds;
  final Function(Deal) onWishlistToggle;

  const MainTabController({
    super.key,
    required this.deals,
    required this.wishlistIds,
    required this.onWishlistToggle,
  });

  @override
  State<MainTabController> createState() => _MainTabControllerState();
}

class _MainTabControllerState extends State<MainTabController> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final wishlistDeals = widget.deals
        .where((deal) => widget.wishlistIds.contains(deal.id))
        .toList();

    final screens = [
      DealsScreen(
        deals: widget.deals,
        wishlistIds: widget.wishlistIds,
        onWishlistToggle: widget.onWishlistToggle,
      ),
      WishlistScreen(
        wishlistDeals: wishlistDeals,
        wishlistIds: widget.wishlistIds,
        onWishlistToggle: widget.onWishlistToggle,
      ),
      CategoriesScreen(
        deals: widget.deals,
        wishlistIds: widget.wishlistIds,
        onWishlistToggle: widget.onWishlistToggle,
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'Deals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
        ],
      ),
    );
  }
}

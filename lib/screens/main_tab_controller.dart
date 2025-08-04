import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/models/category.dart';
import 'package:grabmeadeal_final/screens/deals_screen.dart';
import 'package:grabmeadeal_final/screens/wishlist_screen.dart';
import 'package:grabmeadeal_final/screens/categories_screen.dart';

class MainTabController extends StatefulWidget {
  final List<Deal> deals;
  final List<Deal> wishlistDeals;
  final Set<String> wishlistIds;
  final List<Category> categories;
  final List<Deal> allDeals;
  final void Function(Deal) onWishlistToggle;

  const MainTabController({
    super.key,
    required this.deals,
    required this.wishlistDeals,
    required this.wishlistIds,
    required this.categories,
    required this.allDeals,
    required this.onWishlistToggle,
  });

  @override
  State<MainTabController> createState() => _MainTabControllerState();
}

class _MainTabControllerState extends State<MainTabController> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      DealsScreen(
        deals: widget.deals,
        wishlistIds: widget.wishlistIds,
        onWishlistToggle: widget.onWishlistToggle,
        allDeals: widget.allDeals, categories: const [], wishlistDeals: const [],
      ),
      WishlistScreen(
        wishlistDeals: widget.wishlistDeals,
        wishlistIds: widget.wishlistIds,
        onWishlistToggle: widget.onWishlistToggle,
      ),
      CategoriesScreen(
        categories: widget.categories,
        deals: widget.deals,
        wishlistIds: widget.wishlistIds,
        onWishlistToggle: widget.onWishlistToggle,
      ),
    ];

    return Scaffold(
      body: tabs[_currentIndex],
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

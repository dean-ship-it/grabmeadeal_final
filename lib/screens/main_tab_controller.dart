// lib/screens/main_tab_controller.dart

import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/category.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/screens/deals_screen.dart';
import 'package:grabmeadeal_final/screens/wishlist_screen.dart';
import 'package:grabmeadeal_final/screens/categories_screen.dart';

class MainTabController extends StatefulWidget {
  final List<Deal> deals;
  final List<Deal> wishlistDeals;
  final Set<String> wishlistIds;
  final List<Category> categories;
  final void Function(Deal) onWishlistToggle;
  final void Function(Category) onCategoryTap;

  const MainTabController({
    super.key,
    required this.deals,
    required this.wishlistDeals,
    required this.wishlistIds,
    required this.categories,
    required this.onWishlistToggle,
    required this.onCategoryTap, required List allDeals,
  });

  @override
  State<MainTabController> createState() => _MainTabControllerState();
}

class _MainTabControllerState extends State<MainTabController> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      DealsScreen(
        deals: widget.deals,
        wishlistIds: widget.wishlistIds,
        onWishlistToggle: widget.onWishlistToggle, onTap: (Deal deal) {  }, allDeals: [], categories: [], wishlistDeals: [],
      ),
      WishlistScreen(
        wishlistDeals: widget.wishlistDeals,
        wishlistIds: widget.wishlistIds,
        onWishlistToggle: widget.onWishlistToggle, onTap: (Deal deal) {  },
      ),
      CategoriesScreen(
        categories: widget.categories,
        onCategoryTap: widget.onCategoryTap, deals: [], wishlistIds: null, onWishlistToggle: (Deal p1) {  },
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
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

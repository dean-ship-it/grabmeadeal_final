// lib/screens/main_tab_controller.dart

import "package:flutter/material.dart";
import "package:grabmeadeal_final/screens/categories_screen.dart";
import "package:grabmeadeal_final/screens/deals_screen.dart";
import "package:grabmeadeal_final/screens/wishlist_screen.dart";

class MainTabController extends StatefulWidget {
  const MainTabController({super.key});

  @override
  State<MainTabController> createState() => _MainTabControllerState();
}

class _MainTabControllerState extends State<MainTabController> {
  int _currentIndex = 0;

  static const _screens = [
    DealsScreen(),
    WishlistScreen(),
    CategoriesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: "Deals",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Wishlist",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: "Categories",
          ),
        ],
      ),
    );
  }
}

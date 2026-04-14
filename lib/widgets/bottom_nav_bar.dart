import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String userId;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF0075C9),
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 2) {
          // Wishlist Deals tab
          Navigator.pushNamed(
            context,
            AppRoutes.wishlistDeals,
            arguments: {'userId': userId},
          );
        } else {
          onTap(index);
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Deals',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Categories',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Wishlist',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}

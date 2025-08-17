import 'dart:async';
import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/models/category.dart';
import 'package:grabmeadeal_final/screens/main_tab_controller.dart';
import 'package:grabmeadeal_final/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {

  const SplashScreen({
    Key? key,
    required this.deals,
    required this.wishlistIds,
    required this.onWishlistToggle,
  }) : super(key: key);
  final List<Deal> deals;
  final Set<String> wishlistIds;
  final void Function(Deal) onWishlistToggle;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // ✅ Debug check: make sure we receive deals from main.dart
    print('🟢 SplashScreen received ${widget.deals.length} deals');

    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MainTabController(
            deals: widget.deals,
            wishlistIds: widget.wishlistIds,
            onWishlistToggle: widget.onWishlistToggle,
            wishlistDeals: widget.deals
                .where((Deal deal) => widget.wishlistIds.contains(deal.id))
                .toList(),
            categories: <Category>[
              const Category(id: 'grocery', name: 'Grocery', iconName: 'shopping_cart'),
              const Category(id: 'tools', name: 'Tools & Equipment', iconName: 'build'),
              const Category(id: 'electronics', name: 'Electronics', iconName: 'electrical_services'),
              const Category(id: 'fitness', name: 'Fitness & Wellness', iconName: 'fitness_center'),
              const Category(id: 'pets', name: 'Pet Supplies', iconName: 'pets'),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.local_offer, color: Colors.white, size: 80),
            SizedBox(height: 20),
            Text(
              'Grab Me A Deal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

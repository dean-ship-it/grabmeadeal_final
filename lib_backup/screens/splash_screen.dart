import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/models/category.dart';
import 'package:grabmeadeal_final/screens/main_tab_controller.dart';

class SplashScreen extends StatefulWidget {
  final List<Deal> deals;
  final List<Deal> wishlistDeals;
  final Set<String> wishlistIds;
  final List<Category> categories;
  final List<Deal> allDeals;
  final void Function(Deal) onWishlistToggle;

  const SplashScreen({
    super.key,
    required this.deals,
    required this.wishlistDeals,
    required this.wishlistIds,
    required this.categories,
    required this.allDeals,
    required this.onWishlistToggle,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainTabController(
            deals: widget.deals,
            wishlistDeals: widget.wishlistDeals,
            wishlistIds: widget.wishlistIds,
            categories: widget.categories,
            allDeals: widget.allDeals,
            onWishlistToggle: widget.onWishlistToggle, onCategoryTap: (Category ) {  },
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

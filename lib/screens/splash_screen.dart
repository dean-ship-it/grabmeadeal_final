import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/routes/app_routes.dart';
import 'package:grabmeadeal_final/screens/deals_screen.dart';

class SplashScreen extends StatelessWidget {
  final List<Deal> wishlistDeals;
  final Set<String> wishlistIds;
  final void Function(Deal) onWishlistToggle;

  const SplashScreen({
    Key? key,
    required this.wishlistDeals,
    required this.wishlistIds,
    required this.onWishlistToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DealsScreen(
            deals: const [],
            wishlistIds: wishlistIds,
            onWishlistToggle: onWishlistToggle,
            onSearch: (String query) {},
          ),
        ),
      );
    });

    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

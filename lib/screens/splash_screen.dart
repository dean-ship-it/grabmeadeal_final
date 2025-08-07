import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  final List<Deal> deals;
  final Set<String> wishlistIds;
  final void Function(Deal) onWishlistToggle;

  const SplashScreen({
    Key? key,
    required this.deals,
    required this.wishlistIds,
    required this.onWishlistToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'Loading deals...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

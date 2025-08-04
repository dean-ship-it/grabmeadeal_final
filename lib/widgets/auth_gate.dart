// lib/widgets/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grabmeadeal_final/screens/auth_screen.dart';
import 'package:grabmeadeal_final/screens/home_screen.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/models/category.dart';

class AuthGate extends StatelessWidget {
  final List<Deal> deals;
  final List<Deal> wishlistDeals;
  final Set<String> wishlistIds;
  final List<Category> categories;
  final void Function(Deal) onWishlistToggle;

  const AuthGate({
    super.key,
    required this.deals,
    required this.wishlistDeals,
    required this.wishlistIds,
    required this.categories,
    required this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return HomeScreen(
            deals: deals,
            wishlistDeals: wishlistDeals,
            wishlistIds: wishlistIds,
            categories: categories,
            onWishlistToggle: onWishlistToggle,
          );
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}

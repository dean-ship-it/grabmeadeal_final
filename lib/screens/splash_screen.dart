import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grabmeadeal_final/screens/home_screen.dart';
import 'package:grabmeadeal_final/screens/auth_screen.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/models/category.dart';

class SplashScreen extends StatefulWidget {
  final List<Deal> allDeals;
  final List<Category> categories;
  final List<Deal> wishlistDeals;
  final Set<String> wishlistIds;
  final void Function(Deal) onWishlistToggle;
  final void Function(Category) onCategoryTap;

  const SplashScreen({
    super.key,
    required this.allDeals,
    required this.categories,
    required this.wishlistDeals,
    required this.wishlistIds,
    required this.onWishlistToggle,
    required this.onCategoryTap,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            allDeals: widget.allDeals,
            categories: widget.categories,
            wishlistDeals: widget.wishlistDeals,
            wishlistIds: widget.wishlistIds,
            onWishlistToggle: widget.onWishlistToggle,
            onCategoryTap: widget.onCategoryTap,
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Grab Me A Deal',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

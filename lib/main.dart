// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:grabmeadeal_final/firebase_options.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/models/category.dart';
import 'package:grabmeadeal_final/screens/deals_screen.dart';
import 'package:grabmeadeal_final/screens/deal_detail_screen.dart';
import 'package:grabmeadeal_final/screens/category_deals_screen.dart';
import 'package:grabmeadeal_final/screens/wishlist_screen.dart';
import 'package:grabmeadeal_final/screens/categories_screen.dart';
import 'package:grabmeadeal_final/screens/notifications_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<Deal> _allDeals = [];
  final List<Deal> _wishlistDeals = [];
  final Set<String> _wishlistIds = {};
  final List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    // TODO: load _allDeals & _categories from Firestore here
  }

  void _handleWishlistToggle(Deal deal) {
    setState(() {
      if (_wishlistIds.contains(deal.id)) {
        _wishlistIds.remove(deal.id);
        _wishlistDeals.removeWhere((d) => d.id == deal.id);
      } else {
        _wishlistIds.add(deal.id);
        _wishlistDeals.add(deal);
      }
    });
  }

  void _handleCategoryTap(Category category) {
    Navigator.pushNamed(
      context,
      '/category-deals',
      arguments: category.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grab Me A Deal',
      debugShowCheckedModeBanner: false,

      // Home screen:
      home: DealsScreen(
        deals: _allDeals,
        wishlistIds: _wishlistIds,
        onWishlistToggle: _handleWishlistToggle,
      ),

      // All named routes handled here:
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/deal-detail':
            final deal = settings.arguments as Deal;
            return MaterialPageRoute(
              builder: (_) => DealDetailScreen(deal: deal),
            );

          case '/category-deals':
            final categoryName = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => CategoryDealsScreen(
                category: categoryName,
                deals: _allDeals,
                wishlistIds: _wishlistIds,
                onWishlistToggle: _handleWishlistToggle,
              ),
            );

          case '/wishlist':
            return MaterialPageRoute(
              builder: (_) => WishlistScreen(
                wishlistDeals: _wishlistDeals,
                wishlistIds: _wishlistIds,
                onWishlistToggle: _handleWishlistToggle,
              ),
            );

          case '/categories':
            return MaterialPageRoute(
              builder: (_) => CategoriesScreen(
                categories: _categories,
                onCategoryTap: _handleCategoryTap,
              ),
            );

          case '/notifications':
            return MaterialPageRoute(
              builder: (_) => NotificationsScreen(),
            );

          default:
            return null;
        }
      },
    );
  }
}

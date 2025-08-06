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
    // TODO: Load data from Firestore or mock here
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

  void _handleDealTap(Deal deal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DealDetailScreen(deal: deal, isInWishlist: null,, onWishlistToggle: (Deal ) {  },),
      ),
    );
  }

  void _handleCategoryTap(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryDealsScreen(
          category: category.name,
          deals: _allDeals,
          wishlistIds: _wishlistIds,
          onWishlistToggle: _handleWishlistToggle,
          onTap: _handleDealTap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grab Me A Deal',
      debugShowCheckedModeBanner: false,
      home: DealsScreen(
        deals: _allDeals,
        wishlistIds: _wishlistIds,
        onWishlistToggle: _handleWishlistToggle,
        onTap: _handleDealTap, allDeals: [], categories: [], wishlistDeals: [],
      ),
      routes: {
        '/wishlist': (_) => WishlistScreen(
              wishlistDeals: _wishlistDeals,
              wishlistIds: _wishlistIds,
              onWishlistToggle: _handleWishlistToggle,
              onTap: _handleDealTap,
            ),
        '/categories': (_) => CategoriesScreen(
              categories: _categories,
              onCategoryTap: _handleCategoryTap, deals: [], wishlistIds: null, onWishlistToggle: (Deal p1) {  },
            ),
        '/notifications': (_) => const NotificationsScreen(),
      },
    );
  }
}

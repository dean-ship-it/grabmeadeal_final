import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/category.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/screens/admin_upload_screen.dart';
import 'package:grabmeadeal_final/screens/categories_screen.dart';
import 'package:grabmeadeal_final/screens/category_deals_screen.dart';
import 'package:grabmeadeal_final/screens/deal_detail_screen.dart';
import 'package:grabmeadeal_final/screens/deals_screen.dart';
import 'package:grabmeadeal_final/screens/notifications_screen.dart';
import 'package:grabmeadeal_final/screens/search_results_screen.dart';
import 'package:grabmeadeal_final/screens/splash_screen.dart';
import 'package:grabmeadeal_final/screens/wishlist_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String deals = '/deals';
  static const String wishlist = '/wishlist';
  static const String categories = '/categories';
  static const String categoryDeals = '/category-deals';
  static const String dealDetail = '/deal-detail';
  static const String adminUpload = '/admin-upload';
  static const String notifications = '/notifications';
  static const String searchResults = '/search-results';
  static const String splash = '/splash';
  static const String signup = '/signup'; // Placeholder

  static Map<String, Widget Function(BuildContext)> routes = {
    home: (context) => SplashScreen(
          wishlistDeals: const [],
          wishlistIds: const {},
          onWishlistToggle: (Deal deal) {},
        ),
    deals: (context) => DealsScreen(
          deals: const [],
          wishlistIds: const {},
          onWishlistToggle: (Deal deal) {},
          onSearch: (String query) {},
        ),
    wishlist: (context) => WishlistScreen(
          wishlistDeals: const [],
          onWishlistToggle: (Deal deal) {},
        ),
    categories: (context) => CategoriesScreen(
          categories: const [],
        ),
    categoryDeals: (context) => CategoryDealsScreen(
          category: const Category(id: '0', name: 'Default'),
          deals: const [],
          wishlistIds: const {},
          onWishlistToggle: (Deal deal) {},
        ),
    dealDetail: (context) => DealDetailScreen(
          deal: Deal(
            id: '0',
            title: 'Sample Deal',
            description: 'Sample description',
            price: 0.0,
            imageUrl: '',
            vendor: 'Vendor',
            category: 'Category',
            date: DateTime.now(),
          ),
          onWishlistToggle: (Deal deal) {},
        ),
    adminUpload: (context) => AdminUploadScreen(
          allDeals: const [],
        ),
    notifications: (context) => const NotificationsScreen(),
    searchResults: (context) => SearchResultsScreen(
          deals: const [],
          wishlistIds: const {},
          onWishlistToggle: (Deal deal) {},
        ),
    signup: (context) => const Placeholder(), // Replace with real SignupScreen
  };
}

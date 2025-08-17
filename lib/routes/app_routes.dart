// lib/routes/app_routes.dart

import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/screens/deals_screen.dart';
import 'package:grabmeadeal_final/screens/wishlist_screen.dart';
import 'package:grabmeadeal_final/screens/categories_screen.dart';
import 'package:grabmeadeal_final/screens/category_deals_screen.dart';
import 'package:grabmeadeal_final/screens/deal_detail_screen.dart';
import 'package:grabmeadeal_final/screens/search_results_screen.dart';
import 'package:grabmeadeal_final/screens/notifications_screen.dart';

class AppRoutes {
  static const String deals = '/deals';
  static const String wishlist = '/wishlist';
  static const String categories = '/categories';
  static const String categoryDeals = '/category-deals';
  static const String dealDetail = '/deal-detail';
  static const String searchResults = '/search-results';
  static const String notifications = '/notifications';

  static Map<String, WidgetBuilder> routes({
    required List<Deal> allDeals,
    required List<Deal> wishlistDeals,
    required Set<String> wishlistIds,
    required Function(Deal) onWishlistToggle,
  }) {
    return {
      deals: (_) => DealsScreen(
            deals: allDeals,
            wishlistIds: wishlistIds,
            onWishlistToggle: onWishlistToggle,
          ),
      wishlist: (_) => WishlistScreen(
            wishlistDeals: wishlistDeals,
            wishlistIds: wishlistIds,
            onWishlistToggle: onWishlistToggle,
          ),
      categories: (_) => CategoriesScreen(
            deals: allDeals,
            wishlistIds: wishlistIds,
            onWishlistToggle: onWishlistToggle,
          ),
      notifications: (_) => const NotificationsScreen(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings,
      {required List<Deal> allDeals,
      required List<Deal> wishlistDeals,
      required Set<String> wishlistIds,
      required Function(Deal) onWishlistToggle}) {
    switch (settings.name) {
      case categoryDeals:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CategoryDealsScreen(
            categoryName: args['categoryName'] as String,
            deals: allDeals,
            wishlistIds: wishlistIds,
            onWishlistToggle: onWishlistToggle,
          ),
        );
      case dealDetail:
        final deal = settings.arguments as Deal;
        return MaterialPageRoute(
          builder: (_) => DealDetailScreen(
            deal: deal,
            onWishlistToggle: onWishlistToggle,
            wishlistIds: wishlistIds,
          ),
        );
      case searchResults:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => SearchResultsScreen(
            results: args['results'] as List<Deal>,
            wishlistIds: wishlistIds,
            onWishlistToggle: onWishlistToggle,
          ),
        );
      case notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
        );
      default:
        return null;
    }
  }
}

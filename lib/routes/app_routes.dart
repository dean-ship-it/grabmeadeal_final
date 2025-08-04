import 'package:flutter/material.dart';

import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/models/category.dart';

import 'package:grabmeadeal_final/screens/deals_screen.dart';
import 'package:grabmeadeal_final/screens/categories_screen.dart';
import 'package:grabmeadeal_final/screens/category_deals_screen.dart';
import 'package:grabmeadeal_final/screens/deal_detail_screen.dart';
import 'package:grabmeadeal_final/screens/wishlist_screen.dart';
import 'package:grabmeadeal_final/screens/search_results_screen.dart';
import 'package:grabmeadeal_final/screens/notifications_screen.dart';

class AppRoutes {
  static const String home          = '/';
  static const String deals         = '/deals';
  static const String categories    = '/categories';
  static const String categoryDeals = '/category-deals';
  static const String dealDetail    = '/deal-detail';
  static const String wishlist      = '/wishlist';
  static const String searchResults = '/search-results';
  static const String notifications = '/notifications';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
      case deals:
        return MaterialPageRoute(builder: (_) => const DealsScreen());

      case categories:
        return MaterialPageRoute(builder: (_) => const CategoriesScreen());

      case categoryDeals:
        final category = settings.arguments as Category?;
        return MaterialPageRoute(
          builder: (_) => CategoryDealsScreen(category: category!),
        );

      case dealDetail:
        final deal = settings.arguments as Deal?;
        return MaterialPageRoute(
          builder: (_) => DealDetailScreen(deal: deal!),
        );

      case wishlist:
        return MaterialPageRoute(builder: (_) => const WishlistScreen());

      case searchResults:
        final query = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => SearchResultsScreen(query: query!),
        );

      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      default:
        // fallback to home if route not found
        return MaterialPageRoute(builder: (_) => const DealsScreen());
    }
  }
}

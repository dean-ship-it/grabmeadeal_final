// lib/routes/app_routes.dart
import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/screens/deals_screen.dart';
import 'package:grabmeadeal_final/screens/wishlist_screen.dart';
import 'package:grabmeadeal_final/screens/categories_screen.dart';
import 'package:grabmeadeal_final/screens/deal_detail_screen.dart';
import 'package:grabmeadeal_final/screens/category_deals_screen.dart';
import 'package:grabmeadeal_final/screens/search_results_screen.dart';
import 'package:grabmeadeal_final/screens/notifications_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => DealsScreen(
            deals: const [],
            wishlistIds: const <String>{},
            onWishlistToggle: (deal) {}, allDeals: const [], categories: const [], wishlistDeals: const [],
          ),
        );

      case '/wishlist':
        return MaterialPageRoute(
          builder: (_) => WishlistScreen(
            wishlistDeals: const [],
            onWishlistToggle: (deal) {}, wishlistIds: null,
          ),
        );

      case '/categories':
        return MaterialPageRoute(
          builder: (_) => CategoriesScreen(
            categories: const [],
            deals: const [],
            wishlistIds: const <String>{},
            onWishlistToggle: (deal) {},
          ),
        );

      case '/dealDetail':
        if (args is Deal) {
          return MaterialPageRoute(
            builder: (_) => DealDetailScreen(deal: args),
          );
        }
        return _errorRoute();

      case '/categoryDeals':
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => CategoryDealsScreen(
              category: args['category'] ?? '',
              deals: args['deals'] ?? <Deal>[],
              wishlistIds: Set<String>.from(args['wishlistIds'] ?? <String>[]),
              onWishlistToggle: args['onWishlistToggle'] ?? (Deal _) {},
            ),
          );
        }
        return _errorRoute();

      case '/searchResults':
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => SearchResultsScreen(
              searchQuery: args['searchQuery'] ?? '',
              results: args['results'] ?? <Deal>[],
              wishlistIds: Set<String>.from(args['wishlistIds'] ?? <String>[]),
              onWishlistToggle: args['onWishlistToggle'] ?? (Deal _) {},
            ),
          );
        }
        return _errorRoute();

      case '/notifications':
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
        );

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found')),
      ),
    );
  }
}

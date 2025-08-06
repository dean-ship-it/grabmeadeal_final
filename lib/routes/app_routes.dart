// lib/routes/app_routes.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:grabmeadeal_final/providers/deals_provider.dart';
import 'package:grabmeadeal_final/providers/wishlist_provider.dart';

import 'package:grabmeadeal_final/models/deal.dart';

import 'package:grabmeadeal_final/screens/deals_screen.dart';
import 'package:grabmeadeal_final/screens/deal_detail_screen.dart';
import 'package:grabmeadeal_final/screens/category_deals_screen.dart';
import 'package:grabmeadeal_final/screens/search_results_screen.dart';
import 'package:grabmeadeal_final/screens/wishlist_screen.dart';
import 'package:grabmeadeal_final/screens/notifications_screen.dart';

class AppRoutes {
  static String notifications;

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (ctx) {
          final dealsProv = ctx.watch<DealsProvider>();
          final wishlistProv = ctx.watch<WishlistProvider>();
          return DealsScreen(
            deals: dealsProv.deals,
            wishlistIds: wishlistProv.ids,
            onWishlistToggle: wishlistProv.toggleDeal, onTap: (Deal deal) {  }, allDeals: [], categories: [], wishlistDeals: [],
          );
        });

      case '/deal_detail':
        final deal = settings.arguments as Deal;
        return MaterialPageRoute(builder: (ctx) {
          final wishlistProv = ctx.watch<WishlistProvider>();
          return DealDetailScreen(
            deal: deal,
            isInWishlist: wishlistProv.ids.contains(deal.id),
            onWishlistToggle: wishlistProv.toggleDeal,
          );
        });

      case '/category_deals':
        final category = settings.arguments as String;
        return MaterialPageRoute(builder: (ctx) {
          final dealsProv = ctx.watch<DealsProvider>();
          final wishlistProv = ctx.watch<WishlistProvider>();
          return CategoryDealsScreen(
            category: category,
            deals: dealsProv.deals,
            wishlistIds: wishlistProv.ids,
            onWishlistToggle: wishlistProv.toggleDeal, onTap: (Deal ) {  },
          );
        });

      case '/search_results':
        final query = settings.arguments as String;
        return MaterialPageRoute(builder: (ctx) {
          final dealsProv = ctx.watch<DealsProvider>();
          final wishlistProv = ctx.watch<WishlistProvider>();
          final results = dealsProv.deals
              .where((d) => d.title.toLowerCase().contains(query.toLowerCase()))
              .toList();
          return SearchResultsScreen(
            results: results,
            searchQuery: query,
            wishlistIds: wishlistProv.ids,
            onWishlistToggle: wishlistProv.toggleDeal,
          );
        });

      case '/wishlist':
        return MaterialPageRoute(builder: (ctx) {
          final wishlistProv = ctx.watch<WishlistProvider>();
          return WishlistScreen(
            wishlistDeals: wishlistProv.wishlistDeals,
            wishlistIds: wishlistProv.ids,
            onWishlistToggle: wishlistProv.toggleDeal, onTap: (Deal deal) {  },
          );
        });

      case '/notifications':
        return MaterialPageRoute(
          builder: (_) => NotificationsScreen(),
        );

      default:
        // Fallback for undefined routes
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/category.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/screens/category_deals_screen.dart';
import 'package:grabmeadeal_final/screens/categories_screen.dart';
import 'package:grabmeadeal_final/screens/deal_detail_screen.dart';
import 'package:grabmeadeal_final/screens/deals_screen.dart';
import 'package:grabmeadeal_final/screens/notifications_screen.dart';
import 'package:grabmeadeal_final/screens/search_results_screen.dart';
import 'package:grabmeadeal_final/screens/splash_screen.dart';
import 'package:grabmeadeal_final/screens/wishlist_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String deals = '/deals';
  static const String wishlist = '/wishlist';
  static const String categories = '/categories';
  static const String categoryDeals = '/category-deals';
  static const String dealDetail = '/deal-detail';
  static const String notifications = '/notifications';
  static const String searchResults = '/search-results';

  static Map<String, WidgetBuilder> routes({
    required List<Deal> deals,
    required List<Deal> wishlistDeals,
    required Set<String> wishlistIds, // Use Set<String>
    required List<Category> categories,
    required void Function(Deal) onWishlistToggle,
  }) {
    return {
      splash: (BuildContext context) => SplashScreen(
            wishlistDeals: wishlistDeals,
            wishlistIds: wishlistIds,
            onWishlistToggle: onWishlistToggle,
          ),
      deals: (BuildContext context) => DealsScreen(
            deals: deals,
            wishlistDeals: wishlistDeals,
            wishlistIds: wishlistIds,
            onWishlistToggle: onWishlistToggle,
          ),
      wishlist: (BuildContext context) => WishlistScreen(
            wishlistDeals: wishlistDeals,
            wishlistIds: wishlistIds,
            onWishlistToggle: onWishlistToggle,
          ),
      categories: (BuildContext context) => CategoriesScreen(
            categories: categories,
            onWishlistToggle: onWishlistToggle,
            wishlistDeals: wishlistDeals,
            wishlistIds: wishlistIds,
          ),
      categoryDeals: (BuildContext context) => CategoryDealsScreen(
            category: Category(id: '0', title: 'Default'), // Use correct property name
            wishlistDeals: wishlistDeals,
            wishlistIds: wishlistIds,
            onWishlistToggle: onWishlistToggle,
          ),
      dealDetail: (BuildContext context) => DealDetailScreen(
            deal: Deal(
              id: '0',
              title: 'Sample Deal',
              description: 'This is a placeholder deal.',
              imageUrl: '',
              price: 0.0,
              originalPrice: 0.0,
              vendor: 'Placeholder',
              categoryId: '0',
              date: DateTime.now(),
              isInWishlist: false,
            ),
            onWishlistToggle: onWishlistToggle,
          ),
      notifications: (BuildContext context) => NotificationsScreen(id: 1),
      searchResults: (BuildContext context) => SearchResultsScreen(
            deals: deals,
            wishlistDeals: wishlistDeals,
            wishlistIds: wishlistIds,
            onWishlistToggle: onWishlistToggle,
          ),
    };
  }
}
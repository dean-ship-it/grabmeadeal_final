// lib/routes/app_routes.dart

import "package:flutter/material.dart";
import "package:grabmeadeal_final/screens/admin_login_screen.dart";
import "package:grabmeadeal_final/screens/admin_upload_screen.dart";
import "package:grabmeadeal_final/screens/auth_gate.dart";
import "package:grabmeadeal_final/screens/auth_screen.dart";
import "package:grabmeadeal_final/screens/categories_screen.dart";
import "package:grabmeadeal_final/screens/deal_detail_screen.dart";
import "package:grabmeadeal_final/screens/deals_screen.dart";
import "package:grabmeadeal_final/screens/events_screen.dart";
import "package:grabmeadeal_final/screens/main_tab_controller.dart";
import "package:grabmeadeal_final/screens/notifications_screen.dart";
import "package:grabmeadeal_final/screens/search_results_screen.dart";
import "package:grabmeadeal_final/screens/wishlist_screen.dart";
import "package:grabmeadeal_final/screens/puzzle_reward_screen.dart";
import "package:grabmeadeal_final/screens/prize_claim_screen.dart";
import "package:grabmeadeal_final/screens/shopping_list_screen.dart";
import "package:grabmeadeal_final/models/deal.dart";

class AppRoutes {
  AppRoutes._();

  static const String root          = "/";
  static const String home          = "/home";
  static const String auth          = "/auth";
  static const String deals         = "/deals";
  static const String events        = "/events";
  static const String wishlist      = "/wishlist";
  static const String wishlistDeals = "/wishlist";
  static const String notifications = "/notifications";
  static const String adminLogin    = "/admin-login";
  static const String adminUpload   = "/admin-upload";
  static const String search        = "/search";
  static const String categories    = "/categories";
  static const String dealDetail    = "/deal-detail";
  static const String puzzle        = "/puzzle";
  static const String prizeClaim    = "/prize-claim";
  static const String shoppingList  = "/shopping-list";

  static Route<dynamic> onGenerate(RouteSettings settings) {
    switch (settings.name) {
      case root:
        return _fade(const AuthGate());
      case home:
        return _fade(const MainTabController());
      case auth:
        return MaterialPageRoute(
          builder: (_) => const AuthScreen(),
        );
      case deals:
        return MaterialPageRoute(
          builder: (_) => const DealsScreen(),
        );
      case events:
        return MaterialPageRoute(
          builder: (_) => const EventsScreen(),
        );
      case wishlist:
        return MaterialPageRoute(
          builder: (_) => const WishlistScreen(),
        );
      case notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
        );
      case categories:
        return MaterialPageRoute(
          builder: (_) => const CategoriesScreen(),
        );
      case search:
        final query = settings.arguments is String
            ? settings.arguments as String
            : "";
        return MaterialPageRoute(
          builder: (_) => SearchResultsScreen(initialQuery: query),
        );
      case dealDetail:
        final deal = settings.arguments is Deal
            ? settings.arguments as Deal
            : null;
        return MaterialPageRoute(
          builder: (_) => DealDetailScreen(deal: deal),
        );
      case adminLogin:
        return MaterialPageRoute(
          builder: (_) => const AdminLoginScreen(),
        );
      case adminUpload:
        return MaterialPageRoute(
          builder: (_) => const AdminUploadScreen(),
        );
      case puzzle:
        return MaterialPageRoute(
          builder: (_) => const PuzzleRewardScreen(),
        );
      case shoppingList:
        return MaterialPageRoute(
          builder: (_) => const ShoppingListScreen(),
        );
      case prizeClaim:
        final prize = settings.arguments is String
            ? settings.arguments as String
            : "Prize";
        return MaterialPageRoute(
          builder: (_) => PrizeClaimScreen(prize: prize),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("404 — Route not found")),
          ),
        );
    }
  }

  static PageRouteBuilder<void> _fade(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}

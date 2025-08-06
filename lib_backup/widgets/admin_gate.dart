import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/screens/admin_dashboard_screen.dart';
import 'package:grabmeadeal_final/screens/deals_screen.dart';

class AdminGate extends StatelessWidget {
  final bool isAdmin;
  final List<Deal> deals;
  final List<Deal> allDeals;
  final Set<String> wishlistIds;
  final void Function(Deal) onWishlistToggle;

  const AdminGate({
    super.key,
    required this.isAdmin,
    required this.deals,
    required this.allDeals,
    required this.wishlistIds,
    required this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (isAdmin) {
      return const AdminDashboardScreen();
    } else {
      return DealsScreen(
        deals: deals,
        allDeals: allDeals,
        wishlistIds: wishlistIds,
        onWishlistToggle: onWishlistToggle, categories: const [], wishlistDeals: const [], onTap: (Deal deal) {  },
      );
    }
  }
}

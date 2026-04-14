// lib/screens/category_deals_screen.dart

import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:grabmeadeal_final/models/deal.dart";
import "package:grabmeadeal_final/models/deal_category.dart";
import "package:grabmeadeal_final/providers/wishlist_provider.dart";
import "package:grabmeadeal_final/widgets/deal_card.dart";

class CategoryDealsScreen extends StatelessWidget {
  final DealCategory category;

  const CategoryDealsScreen({
    super.key,
    required this.category,
  });

  Stream<List<Deal>> _categoryStream() {
    return FirebaseFirestore.instance
        .collection("deals")
        .where("category", isEqualTo: category.name)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Deal.fromFirestore(doc)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(category.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(category.label),
          ],
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Deal>>(
        stream: _categoryStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  "Failed to load ${category.label} deals. Please try again.",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final deals = snapshot.data ?? [];
          if (deals.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(category.icon, style: const TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text(
                      "No deals in ${category.label} yet.\nCheck back soon!",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            );
          }
          return Consumer<WishlistProvider>(
            builder: (context, wishlist, _) {
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: deals.length,
                itemBuilder: (context, index) {
                  final deal = deals[index];
                  return DealCard(
                    deal: deal,
                    isInWishlist: wishlist.isWishlisted(deal.id),
                    onWishlistToggle: () => wishlist.toggleWishlist(deal),
                    onTap: () => Navigator.pushNamed(
                      context,
                      "/deal-detail",
                      arguments: deal,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// lib/screens/deals_screen.dart

import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:grabmeadeal_final/models/deal.dart";
import "package:grabmeadeal_final/models/deal_category.dart";
import "package:grabmeadeal_final/providers/wishlist_provider.dart";
import "package:grabmeadeal_final/screens/category_deals_screen.dart";
import "package:grabmeadeal_final/widgets/deal_card.dart";

class DealsScreen extends StatelessWidget {
  const DealsScreen({super.key});

  Stream<List<Deal>> _dealsStream() {
    return FirebaseFirestore.instance
        .collection("deals")
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Deal.fromFirestore(doc))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: SizedBox(
          height: 40,
          child: Image.asset(
            "assets/logo/logo.png",
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Text(
              "Grab Me A Deal",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Text("🧩", style: TextStyle(fontSize: 22)),
            tooltip: "Puzzle Rewards",
            onPressed: () => Navigator.pushNamed(context, "/puzzle"),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, "/admin-upload"),
        tooltip: "Admin Upload",
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // ── Category Banner ──
          const _CategoryBanner(),
          // ── Deals Content ──
          Expanded(
            child: StreamBuilder<List<Deal>>(
              stream: _dealsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        "Failed to load deals. Please try again.",
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                final deals = snapshot.data ?? [];
                if (deals.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        "No deals available at the moment. Check back soon!",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return Consumer<WishlistProvider>(
                  builder: (context, wishlist, _) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Featured Deal ──
                          Text(
                            "Featured Deal",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          DealCard(
                            deal: deals.first,
                            isInWishlist: wishlist.isWishlisted(deals.first.id),
                            onWishlistToggle: () =>
                                wishlist.toggleWishlist(deals.first),
                            onTap: () => Navigator.pushNamed(
                              context,
                              "/deal-detail",
                              arguments: deals.first,
                            ),
                          ),
                          if (deals.length > 1) ...[
                            const SizedBox(height: 24),
                            Text(
                              "More Deals",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: deals.length - 1,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.72,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemBuilder: (context, index) {
                                final deal = deals[index + 1];
                                return DealCard(
                                  deal: deal,
                                  isInWishlist:
                                      wishlist.isWishlisted(deal.id),
                                  onWishlistToggle: () =>
                                      wishlist.toggleWishlist(deal),
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    "/deal-detail",
                                    arguments: deal,
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category Banner ──────────────────────────────────────────────────────────

class _CategoryBanner extends StatelessWidget {
  const _CategoryBanner();

  @override
  Widget build(BuildContext context) {
    final categories = DealCategory.values;
    return Container(
      height: 90,
      color: const Color(0xFF0075C9),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryDealsScreen(category: category),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF004A8D),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        category.icon,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.label.split(" ").first,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

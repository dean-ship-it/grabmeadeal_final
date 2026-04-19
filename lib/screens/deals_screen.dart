// lib/screens/deals_screen.dart

import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:grabmeadeal_final/models/deal.dart";
import "package:grabmeadeal_final/models/deal_category.dart";
import "package:grabmeadeal_final/providers/wishlist_provider.dart";
import "package:grabmeadeal_final/screens/category_deals_screen.dart";
import "package:grabmeadeal_final/services/deal_detective_service.dart";
import "package:grabmeadeal_final/widgets/deal_card.dart";
import "package:grabmeadeal_final/widgets/hero_deal_card.dart";

class DealsScreen extends StatefulWidget {
  const DealsScreen({super.key});

  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen> {
  bool _detectiveActive = false;

  void _toggleDetective() async {
    final detective = DealDetectiveService.instance;
    if (_detectiveActive) {
      await detective.stopDetecting();
    } else {
      await detective.startDetecting();
    }
    setState(() => _detectiveActive = detective.isActive);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _detectiveActive
                ? "🕵️ Deal Detective activated! I'm on the case — I'll find deals near you."
                : "🕵️ Deal Detective is off the clock.",
          ),
          backgroundColor: _detectiveActive
              ? const Color(0xFF0075C9)
              : Colors.grey.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

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
        centerTitle: false,
        titleSpacing: 12,
        toolbarHeight: 64,
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF5C518).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  "assets/logo/launcher_v2_cropped.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Grab Me A Deal",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    "Your Personal Shopping Engine",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          // Deal Detective toggle — detective in trench coat
          GestureDetector(
            onTap: _toggleDetective,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "🕵️",
                    style: TextStyle(
                      fontSize: 22,
                      color: _detectiveActive ? null : Colors.white38,
                    ),
                  ),
                  if (_detectiveActive)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFA6CE39),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: "Notifications",
            onPressed: () => Navigator.pushNamed(context, "/notifications"),
          ),
          IconButton(
            icon: const Text("🧩", style: TextStyle(fontSize: 22)),
            tooltip: "Puzzle Rewards",
            onPressed: () => Navigator.pushNamed(context, "/puzzle"),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Category Banner ──
          const _CategoryBanner(),
          // ── Search Bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              onSubmitted: (query) {
                if (query.trim().isNotEmpty) {
                  Navigator.pushNamed(
                    context,
                    "/search",
                    arguments: query.trim(),
                  );
                }
              },
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: "Search deals...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF0075C9)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF0075C9),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
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
                    return StreamBuilder<DocumentSnapshot>(
                      // "Recommended for You" hero — three-tier picker:
                      //
                      //   1. TIME-OF-DAY ROTATION (preferred): if the doc has
                      //      a `rotation` array, walk it and pick the entry
                      //      whose [startHour, endHour) matches the user's
                      //      current local hour. Wrap-around windows allowed
                      //      (e.g., startHour:22, endHour:5 = 10pm–5am).
                      //   2. ADMIN OVERRIDE: if no rotation matches but the
                      //      doc has a `dealId`, use that.
                      //   3. AUTO FALLBACK: highest-discount-with-image.
                      //
                      // Doc shape (Firebase Console editable, no rebuild):
                      //   featured/current_recommended
                      //     enabled: true
                      //     rotation: [
                      //       { dealId, badgeText, startHour, endHour }, ...
                      //     ]
                      //     dealId: <fallback if rotation misses>
                      //     badgeText: <fallback badge>
                      //
                      // Strategy lives in memory/roadmap_visual_features.md.
                      stream: FirebaseFirestore.instance
                          .doc("featured/current_recommended")
                          .snapshots(),
                      builder: (context, recSnap) {
                        Deal heroDeal = deals.first;
                        bool isAdminCurated = false;
                        String? badgeText;

                        if (recSnap.hasData && recSnap.data!.exists) {
                          final data = recSnap.data!.data()
                              as Map<String, dynamic>?;
                          if (data != null && data["enabled"] == true) {
                            String? pickedDealId;
                            // 1. Try time-of-day rotation
                            final rotation = data["rotation"] as List<dynamic>?;
                            if (rotation != null && rotation.isNotEmpty) {
                              final hour = DateTime.now().hour;
                              for (final entry in rotation) {
                                if (entry is! Map) continue;
                                final m = entry as Map<dynamic, dynamic>;
                                final s = (m["startHour"] as num?)?.toInt();
                                final e = (m["endHour"] as num?)?.toInt();
                                final id = m["dealId"] as String?;
                                if (s == null || e == null || id == null) continue;
                                final inWindow = s < e
                                    ? (hour >= s && hour < e)
                                    : (hour >= s || hour < e); // wrap-around
                                if (inWindow) {
                                  pickedDealId = id;
                                  badgeText = m["badgeText"] as String?;
                                  break;
                                }
                              }
                            }
                            // 2. Fall back to single dealId override
                            pickedDealId ??= data["dealId"] as String?;
                            badgeText ??= data["badgeText"] as String?;

                            if (pickedDealId != null) {
                              for (final d in deals) {
                                if (d.id == pickedDealId) {
                                  heroDeal = d;
                                  isAdminCurated = true;
                                  break;
                                }
                              }
                            }
                          }
                        }

                        if (!isAdminCurated) {
                          // 3. Auto fallback — biggest discount % with image
                          badgeText = null;
                          double bestDiscount = -1;
                          for (final d in deals) {
                            if (d.imageUrl.isEmpty) continue;
                            if (d.originalPrice == null ||
                                d.originalPrice! <= d.price) continue;
                            final pct = (d.originalPrice! - d.price) /
                                d.originalPrice!;
                            if (pct > bestDiscount) {
                              bestDiscount = pct;
                              heroDeal = d;
                            }
                          }
                        }

                        final otherDeals = deals
                            .where((d) => d.id != heroDeal.id)
                            .toList();

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Deal Count ──
                              Text(
                                "${deals.length} deals found today",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // ── Recommended for You ──
                              Row(
                                children: [
                                  const Text("💡 ", style: TextStyle(fontSize: 22)),
                                  Text(
                                    "Recommended for You",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  if (badgeText != null && badgeText.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5C518),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        badgeText,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF062245),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Save today on what you'd buy anyway",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 12),
                              HeroDealCard(
                                deal: heroDeal,
                                isInWishlist:
                                    wishlist.isWishlisted(heroDeal.id),
                                onWishlistToggle: () =>
                                    wishlist.toggleWishlist(heroDeal),
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  "/deal-detail",
                                  arguments: heroDeal,
                                ),
                              ),
                              if (otherDeals.isNotEmpty) ...[
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
                                  itemCount: otherDeals.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.72,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                                  itemBuilder: (context, index) {
                                    final deal = otherDeals[index];
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
// Two-row grid: row 1 = first 6 categories, row 2 = remaining 5 + a "More" tile
// linking to the full Categories screen.

class _CategoryBanner extends StatelessWidget {
  const _CategoryBanner();

  @override
  Widget build(BuildContext context) {
    final categories = DealCategory.values;
    // Banner shows the first 11 categories in a 6 + 5 grid + a "More" tile.
    // Any categories beyond index 10 (e.g., Insurance, Energy) are reachable
    // via the "More" tile → full Categories tab.
    final row1 = categories.take(6).toList();
    final row2 = categories.skip(6).take(5).toList();

    return Container(
      color: const Color(0xFF0075C9),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final c in row1)
                Expanded(child: _CategoryTile(category: c)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final c in row2)
                Expanded(child: _CategoryTile(category: c)),
              const Expanded(child: _MoreTile()),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final DealCategory category;
  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryDealsScreen(category: category),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
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
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    category.asset,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Text(
                        category.icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              category.label.split(" ").first,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/categories"),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
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
                child: const Center(
                  child: Icon(Icons.apps, color: Colors.white, size: 28),
                ),
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              "More",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

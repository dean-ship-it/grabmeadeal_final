import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:grabmeadeal_final/models/deal.dart";
import "package:grabmeadeal_final/providers/wishlist_provider.dart";
import "package:grabmeadeal_final/screens/deal_detail_screen.dart";
import "package:grabmeadeal_final/widgets/deal_card.dart";

class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;

  const SearchResultsScreen({
    super.key,
    this.initialQuery = "",
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late final TextEditingController _searchCtrl;
  String _query = "";

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery.trim().toLowerCase();
    _searchCtrl = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Stream<List<Deal>> _searchStream() {
    return FirebaseFirestore.instance
        .collection("deals")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snap) {
      final all = snap.docs
          .map((doc) => Deal.fromJson(doc.data(), doc.id))
          .toList();
      if (_query.isEmpty) return all;
      return all.where((deal) {
        return deal.title.toLowerCase().contains(_query) ||
            deal.vendor.toLowerCase().contains(_query) ||
            deal.category.toLowerCase().contains(_query) ||
            deal.description.toLowerCase().contains(_query);
      }).toList();
    });
  }

  void _onSearch(String value) {
    setState(() => _query = value.trim().toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TextField(
          controller: _searchCtrl,
          autofocus: widget.initialQuery.isEmpty,
          textInputAction: TextInputAction.search,
          onSubmitted: _onSearch,
          onChanged: _onSearch,
          decoration: InputDecoration(
            hintText: "Search deals...",
            border: InputBorder.none,
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchCtrl.clear();
                      _onSearch("");
                    },
                  )
                : null,
          ),
        ),
      ),
      body: StreamBuilder<List<Deal>>(
        stream: _searchStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  "Search failed. Please try again.",
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
                child: Text(
                  _query.isEmpty
                      ? "No deals available."
                      : 'No results for "$_query".',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          final wishlist = context.watch<WishlistProvider>();
          return ListView.builder(
            itemCount: deals.length,
            itemBuilder: (context, index) {
              final deal = deals[index];
              final inWishlist = wishlist.wishlistIds.contains(deal.id);
              return DealCard(
                deal: deal,
                isInWishlist: inWishlist,
                onWishlistToggle: () => wishlist.toggleWishlist(deal),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DealDetailScreen(
                        deal: deal,
                        isInWishlist: wishlist.wishlistIds.contains(deal.id),
                        onWishlistToggle: () => wishlist.toggleWishlist(deal),
                      ),
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

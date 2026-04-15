// lib/screens/wishlist_screen.dart

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:grabmeadeal_final/models/deal.dart";
import "package:grabmeadeal_final/models/deal_category.dart";
import "package:grabmeadeal_final/models/want_item.dart";
import "package:grabmeadeal_final/providers/wishlist_provider.dart";
import "package:grabmeadeal_final/providers/want_list_provider.dart";
import "package:grabmeadeal_final/widgets/deal_card.dart";

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WantListProvider>().loadWants();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF0075C9),
        foregroundColor: Colors.white,
        title: const Text(
          "My Wishlist",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFA6CE39),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.favorite), text: "Saved Deals"),
            Tab(icon: Icon(Icons.search), text: "Want List"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _SavedDealsTab(),
          _WantListTab(),
        ],
      ),
    );
  }
}

// ── Saved Deals Tab ───────────────────────────────────────────────────────────

class _SavedDealsTab extends StatelessWidget {
  const _SavedDealsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistProvider>(
      builder: (context, wishlist, _) {
        final deals = wishlist.wishlistDeals;
        if (deals.isEmpty) return _emptyState(context);
        return Column(
          children: [
            if (deals.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${deals.length} saved deal${deals.length == 1 ? "" : "s"}",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _confirmClear(context, wishlist),
                      icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                      label: const Text("Clear all"),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: deals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final Deal deal = deals[index];
                  return Hero(
                    tag: "deal_${deal.id}",
                    child: DealCard(
                      deal: deal,
                      isInWishlist: true,
                      onWishlistToggle: () =>
                          wishlist.toggleWishlist(deal),
                      onTap: () => Navigator.pushNamed(
                        context,
                        "/deal-detail",
                        arguments: deal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmClear(BuildContext context, WishlistProvider wishlist) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Clear Wishlist"),
        content: const Text("Remove all saved deals? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              wishlist.clearWishlist();
              Navigator.pop(ctx);
            },
            child: const Text("Clear All"),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded,
                size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            const Text(
              "No saved deals yet.\nTap the heart on any deal to save it!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16, color: Colors.black54, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Want List Tab ─────────────────────────────────────────────────────────────

class _WantListTab extends StatefulWidget {
  const _WantListTab();

  @override
  State<_WantListTab> createState() => _WantListTabState();
}

class _WantListTabState extends State<_WantListTab> {
  final _keywordCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  DealCategory? _selectedCategory;
  bool _adding = false;

  @override
  void dispose() {
    _keywordCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _addWant() async {
    if (_keywordCtrl.text.trim().isEmpty) return;
    setState(() => _adding = true);
    final provider = context.read<WantListProvider>();
    await provider.addWant(
      keyword: _keywordCtrl.text.trim(),
      category: _selectedCategory?.name,
      maxPrice: double.tryParse(_priceCtrl.text.trim()),
    );
    if (!mounted) return;
    final error = provider.lastError;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save: $error"),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 5),
        ),
      );
      provider.clearError();
    }
    _keywordCtrl.clear();
    _priceCtrl.clear();
    setState(() {
      _adding = false;
      _selectedCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WantListProvider>(
      builder: (context, wantList, _) {
        return Column(
          children: [
            // ── Add Want Form ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "What are you looking for?",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF0075C9),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _keywordCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: 'e.g. "Sony 65 inch TV" or "KitchenAid mixer"',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF0075C9),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _priceCtrl,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _addWant(),
                          decoration: InputDecoration(
                            hintText: "Max price (optional)",
                            prefixIcon: const Icon(Icons.attach_money),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF0075C9),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<DealCategory>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            hintText: "Category",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          items: DealCategory.values.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(
                                "${cat.icon} ${cat.label.split(" ").first}",
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedCategory = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: _adding ? null : _addWant,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFA6CE39),
                        foregroundColor: Colors.black,
                      ),
                      icon: _adding
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(Icons.add),
                      label: Text(
                        _adding ? "Adding..." : "Add to Want List",
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Want List Items ──
            Expanded(
              child: wantList.loading
                  ? const Center(child: CircularProgressIndicator())
                  : wantList.wants.isEmpty
                      ? _emptyWantList()
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: wantList.wants.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final want = wantList.wants[index];
                            return _WantItemCard(
                              want: want,
                              onDelete: () =>
                                  wantList.removeWant(want.id),
                              onToggle: () =>
                                  wantList.toggleActive(want),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _emptyWantList() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.playlist_add, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              "Your want list is empty.\nAdd items above and we'll find deals for you!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Want Item Card ────────────────────────────────────────────────────────────

class _WantItemCard extends StatelessWidget {
  final WantItem want;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _WantItemCard({
    required this.want,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: want.active
              ? const Color(0xFF0075C9).withOpacity(0.3)
              : Colors.grey.shade300,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: want.active
                ? const Color(0xFF0075C9)
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.search,
            color: want.active ? Colors.white : Colors.grey,
            size: 22,
          ),
        ),
        title: Text(
          want.keyword,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: want.active ? Colors.black87 : Colors.grey,
            decoration:
                want.active ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Row(
          children: [
            if (want.maxPrice != null)
              _chip(
                "Max \$${want.maxPrice!.toStringAsFixed(0)}",
                const Color(0xFFA6CE39),
                Colors.black,
              ),
            if (want.category != null) ...[
              const SizedBox(width: 6),
              _chip(
                want.category!,
                const Color(0xFF0075C9).withOpacity(0.1),
                const Color(0xFF0075C9),
              ),
            ],
            if (want.lastMatchedAt != null) ...[
              const SizedBox(width: 6),
              _chip("Match found!", Colors.green.shade50, Colors.green),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: want.active,
              onChanged: (_) => onToggle(),
              activeColor: const Color(0xFF0075C9),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
              tooltip: "Remove",
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: text, fontWeight: FontWeight.w600),
      ),
    );
  }
}

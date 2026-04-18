// lib/screens/shopping_list_screen.dart
// Smart Shopping List — Out of Milk style with deal matching
// Categories organized like store aisles, quantities, prices, running total

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

// ── Store Aisle Categories ──────────────────────────────────────────────────

class _AisleCategory {
  final String name;
  final String emoji;
  final Color color;
  const _AisleCategory(this.name, this.emoji, this.color);
}

const List<_AisleCategory> _aisles = [
  _AisleCategory("Produce", "🥬", Color(0xFF388E3C)),
  _AisleCategory("Dairy & Eggs", "🥛", Color(0xFF1565C0)),
  _AisleCategory("Meat & Seafood", "🥩", Color(0xFFC62828)),
  _AisleCategory("Bakery", "🍞", Color(0xFFE65100)),
  _AisleCategory("Pantry", "🥫", Color(0xFF6A1B9A)),
  _AisleCategory("Frozen", "🧊", Color(0xFF0277BD)),
  _AisleCategory("Beverages", "☕", Color(0xFF4E342E)),
  _AisleCategory("Snacks", "🍿", Color(0xFFFF8F00)),
  _AisleCategory("Household", "🧹", Color(0xFF37474F)),
  _AisleCategory("Baby & Kids", "🍼", Color(0xFFEC407A)),
  _AisleCategory("Pet", "🐾", Color(0xFF2E7D32)),
  _AisleCategory("Other", "📦", Color(0xFF78909C)),
];

// Auto-categorize items by keyword
String _autoCategory(String item) {
  final lower = item.toLowerCase();
  const map = {
    "Produce": ["apple", "banana", "tomato", "onion", "potato", "lettuce",
      "avocado", "pepper", "cucumber", "carrot", "broccoli", "spinach",
      "garlic", "lemon", "lime", "orange", "grape", "strawberry", "blueberry",
      "mushroom", "celery", "corn", "jalapeño", "cilantro"],
    "Dairy & Eggs": ["milk", "egg", "cheese", "yogurt", "butter", "cream",
      "sour cream", "half and half", "cottage cheese", "whipping cream"],
    "Meat & Seafood": ["chicken", "beef", "pork", "ground", "steak", "salmon",
      "shrimp", "bacon", "sausage", "turkey", "fish", "tilapia", "hamburger"],
    "Bakery": ["bread", "tortilla", "bun", "roll", "bagel", "muffin",
      "croissant", "cake", "donut", "pie"],
    "Pantry": ["rice", "pasta", "bean", "sauce", "oil", "flour", "sugar",
      "salt", "spice", "seasoning", "soup", "broth", "canned", "noodle",
      "peanut butter", "jelly", "honey", "vinegar", "ketchup", "mustard",
      "mayo", "salsa"],
    "Frozen": ["frozen", "ice cream", "pizza", "fries", "waffle",
      "popsicle", "lean cuisine"],
    "Beverages": ["coffee", "tea", "juice", "soda", "water", "wine",
      "beer", "energy drink", "creamer", "lemonade", "gatorade"],
    "Snacks": ["chip", "cracker", "cookie", "candy", "popcorn", "pretzel",
      "nut", "granola", "trail mix", "fruit snack"],
    "Household": ["paper towel", "toilet paper", "dish soap", "trash bag",
      "detergent", "bleach", "sponge", "foil", "plastic wrap", "ziplock",
      "cleaning", "lysol", "wipes"],
    "Baby & Kids": ["diaper", "formula", "baby food", "wipes", "sippy",
      "pacifier", "baby"],
    "Pet": ["dog food", "cat food", "pet", "kibble", "litter", "treats"],
  };
  for (final entry in map.entries) {
    for (final keyword in entry.value) {
      if (lower.contains(keyword)) return entry.key;
    }
  }
  return "Other";
}

// ── Shopping List Screen ─────────────────────────────────────────────────────

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final _addController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  String? _uid;
  String _selectedCategory = "Other";

  // Quick-add staples — organized by what Texas families buy most
  static const List<Map<String, String>> _quickItems = [
    {"name": "Milk", "cat": "Dairy & Eggs"},
    {"name": "Eggs", "cat": "Dairy & Eggs"},
    {"name": "Bread", "cat": "Bakery"},
    {"name": "Butter", "cat": "Dairy & Eggs"},
    {"name": "Chicken", "cat": "Meat & Seafood"},
    {"name": "Ground Beef", "cat": "Meat & Seafood"},
    {"name": "Rice", "cat": "Pantry"},
    {"name": "Tortillas", "cat": "Bakery"},
    {"name": "Cheese", "cat": "Dairy & Eggs"},
    {"name": "Bananas", "cat": "Produce"},
    {"name": "Coffee", "cat": "Beverages"},
    {"name": "Cereal", "cat": "Pantry"},
    {"name": "Pasta", "cat": "Pantry"},
    {"name": "Tomatoes", "cat": "Produce"},
    {"name": "Onions", "cat": "Produce"},
    {"name": "Avocados", "cat": "Produce"},
    {"name": "Bacon", "cat": "Meat & Seafood"},
    {"name": "Paper Towels", "cat": "Household"},
    {"name": "Chips", "cat": "Snacks"},
    {"name": "Juice", "cat": "Beverages"},
  ];

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  CollectionReference? get _listRef {
    if (_uid == null) return null;
    return _firestore.collection("users").doc(_uid).collection("shoppingList");
  }

  Future<void> _addItem(String name, {String? category, int qty = 1}) async {
    if (name.trim().isEmpty || _listRef == null) return;
    final trimmed = name.trim();
    final cat = category ?? _autoCategory(trimmed);

    // Check for duplicate
    final existing = await _listRef!
        .where("name", isEqualTo: trimmed.toLowerCase())
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      // Increment quantity instead
      final doc = existing.docs.first;
      final currentQty = (doc["qty"] as num?)?.toInt() ?? 1;
      await _listRef!.doc(doc.id).update({"qty": currentQty + 1});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("\"$trimmed\" quantity updated to ${currentQty + 1}")),
        );
      }
      return;
    }

    // Find matching deals
    final matchingDeal = await _findMatchingDeal(trimmed);

    await _listRef!.add({
      "name": trimmed.toLowerCase(),
      "displayName": trimmed,
      "category": cat,
      "qty": qty,
      "estimatedPrice": matchingDeal?["price"],
      "checked": false,
      "addedAt": FieldValue.serverTimestamp(),
      "matchedDealTitle": matchingDeal?["title"],
      "matchedDealPrice": matchingDeal?["price"],
      "matchedDealOriginalPrice": matchingDeal?["originalPrice"],
      "matchedDealVendor": matchingDeal?["vendor"],
    });

    _addController.clear();

    if (mounted && matchingDeal != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "🔥 Deal found! ${matchingDeal["vendor"]} has ${matchingDeal["title"]} on sale!",
          ),
          backgroundColor: const Color(0xFF0075C9),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<Map<String, dynamic>?> _findMatchingDeal(String itemName) async {
    try {
      final snap = await _firestore.collection("deals").get();
      final lower = itemName.toLowerCase();
      Map<String, dynamic>? bestMatch;
      double bestSavings = 0;
      for (final doc in snap.docs) {
        final data = doc.data();
        final title = (data["title"] ?? "").toString().toLowerCase();
        final desc = (data["description"] ?? "").toString().toLowerCase();
        if (title.contains(lower) || desc.contains(lower)) {
          final price = (data["price"] as num?)?.toDouble() ?? 0;
          final original = (data["originalPrice"] as num?)?.toDouble() ?? 0;
          final savings = original - price;
          if (savings > bestSavings) {
            bestSavings = savings;
            bestMatch = data;
          }
        }
      }
      return bestMatch;
    } catch (e) {
      debugPrint("[ShoppingList] Deal match error: $e");
    }
    return null;
  }

  Future<void> _toggleChecked(String docId, bool currentValue) async {
    await _listRef?.doc(docId).update({"checked": !currentValue});
  }

  Future<void> _updateQty(String docId, int newQty) async {
    if (newQty <= 0) {
      await _listRef?.doc(docId).delete();
    } else {
      await _listRef?.doc(docId).update({"qty": newQty});
    }
  }

  Future<void> _deleteItem(String docId) async {
    await _listRef?.doc(docId).delete();
  }

  Future<void> _clearCheckedItems() async {
    if (_listRef == null) return;
    final checked = await _listRef!.where("checked", isEqualTo: true).get();
    if (checked.docs.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Clear checked items?"),
        content: Text("Remove ${checked.docs.length} checked items from your list?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Clear")),
        ],
      ),
    );
    if (confirm != true) return;

    final batch = _firestore.batch();
    for (final doc in checked.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  void _showAddItemSheet() {
    _selectedCategory = "Other";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Add Item",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  // Item name field
                  TextField(
                    controller: _addController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (val) {
                      setSheetState(() {
                        _selectedCategory = _autoCategory(val);
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Item name (e.g., Milk, Chicken)",
                      prefixIcon: const Icon(Icons.edit),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Auto-detected category chip
                  Row(
                    children: [
                      const Text("Category: ", style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _aisles.firstWhere(
                            (a) => a.name == _selectedCategory,
                            orElse: () => _aisles.last,
                          ).color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${_aisles.firstWhere((a) => a.name == _selectedCategory, orElse: () => _aisles.last).emoji} $_selectedCategory",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _aisles.firstWhere(
                              (a) => a.name == _selectedCategory,
                              orElse: () => _aisles.last,
                            ).color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Add button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () {
                        _addItem(_addController.text, category: _selectedCategory);
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Add to List", style: TextStyle(fontSize: 16)),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0075C9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("🛒 ", style: TextStyle(fontSize: 20)),
            Text("Shopping List"),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: "Clear checked items",
            onPressed: _clearCheckedItems,
          ),
        ],
      ),
      floatingActionButton: user != null
          ? FloatingActionButton.extended(
              onPressed: _showAddItemSheet,
              backgroundColor: const Color(0xFF0075C9),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text("Add Item"),
            )
          : null,
      body: user == null
          ? _buildSignInPrompt()
          : Column(
              children: [
                // ── Quick Add Chips ──
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
                  color: Colors.grey.shade50,
                  child: SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _quickItems.length,
                      itemBuilder: (context, index) {
                        final item = _quickItems[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ActionChip(
                            label: Text(
                              item["name"]!,
                              style: const TextStyle(fontSize: 12),
                            ),
                            avatar: Text(
                              _aisles.firstWhere(
                                (a) => a.name == item["cat"],
                                orElse: () => _aisles.last,
                              ).emoji,
                              style: const TextStyle(fontSize: 14),
                            ),
                            onPressed: () =>
                                _addItem(item["name"]!, category: item["cat"]),
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // ── Shopping List grouped by aisle ──
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _listRef
                        ?.orderBy("checked")
                        .orderBy("addedAt", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data?.docs ?? [];

                      if (docs.isEmpty) {
                        return _buildEmptyState();
                      }

                      final unchecked =
                          docs.where((d) => !(d["checked"] ?? false)).toList();
                      final checked =
                          docs.where((d) => (d["checked"] ?? false)).toList();

                      // Group unchecked by category (aisle)
                      final Map<String, List<QueryDocumentSnapshot>> grouped = {};
                      for (final doc in unchecked) {
                        final cat =
                            (doc.data() as Map<String, dynamic>)["category"] ??
                                "Other";
                        grouped.putIfAbsent(cat as String, () => []).add(doc);
                      }

                      // Calculate running total
                      double estimatedTotal = 0;
                      int totalItems = 0;
                      int dealsFound = 0;
                      for (final doc in unchecked) {
                        final data = doc.data() as Map<String, dynamic>;
                        final price =
                            (data["estimatedPrice"] as num?)?.toDouble() ?? 0;
                        final qty = (data["qty"] as num?)?.toInt() ?? 1;
                        estimatedTotal += price * qty;
                        totalItems += qty;
                        if (data["matchedDealTitle"] != null) dealsFound++;
                      }

                      return Column(
                        children: [
                          // ── Summary Bar ──
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF004A8D),
                                  Color(0xFF0075C9)
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Items count
                                _summaryChip(
                                  "$totalItems",
                                  "items",
                                  Icons.shopping_cart_outlined,
                                ),
                                const SizedBox(width: 16),
                                // Deals found
                                if (dealsFound > 0) ...[
                                  _summaryChip(
                                    "$dealsFound",
                                    "deals",
                                    Icons.local_fire_department,
                                  ),
                                  const SizedBox(width: 16),
                                ],
                                const Spacer(),
                                // Estimated total
                                if (estimatedTotal > 0)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        "Est. Total",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                        ),
                                      ),
                                      Text(
                                        "\$${estimatedTotal.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),

                          // ── Items by Aisle ──
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.only(bottom: 80),
                              children: [
                                // Unchecked items grouped by aisle
                                for (final aisle in _aisles)
                                  if (grouped.containsKey(aisle.name))
                                    _buildAisleSection(
                                        aisle, grouped[aisle.name]!),

                                // Checked items
                                if (checked.isNotEmpty) ...[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 20, 16, 8),
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_circle,
                                            size: 18,
                                            color: Colors.grey.shade400),
                                        const SizedBox(width: 8),
                                        Text(
                                          "In Cart (${checked.length})",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ...checked.map(
                                      (doc) => _buildItemTile(doc, true)),
                                ],
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _summaryChip(String value, String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildAisleSection(
      _AisleCategory aisle, List<QueryDocumentSnapshot> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Aisle header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: aisle.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child:
                      Text(aisle.emoji, style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                aisle.name,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: aisle.color,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: aisle.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${items.length}",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: aisle.color,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...items.map((doc) => _buildItemTile(doc, false)),
      ],
    );
  }

  Widget _buildItemTile(QueryDocumentSnapshot doc, bool isChecked) {
    final data = doc.data() as Map<String, dynamic>;
    final displayName = data["displayName"] ?? data["name"] ?? "";
    final qty = (data["qty"] as num?)?.toInt() ?? 1;
    final matchedDeal = data["matchedDealTitle"];
    final matchedVendor = data["matchedDealVendor"];
    final matchedPrice = data["matchedDealPrice"];
    final matchedOriginal = data["matchedDealOriginalPrice"];

    return Dismissible(
      key: Key(doc.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade400,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteItem(doc.id),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
          color: isChecked ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: matchedDeal != null && !isChecked
              ? Border.all(color: const Color(0xFFA6CE39), width: 1.5)
              : Border.all(color: Colors.grey.shade100),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _toggleChecked(doc.id, isChecked),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                // Checkbox
                SizedBox(
                  width: 32,
                  child: Checkbox(
                    value: isChecked,
                    onChanged: (_) => _toggleChecked(doc.id, isChecked),
                    activeColor: const Color(0xFF0075C9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 4),
                // Item info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration:
                              isChecked ? TextDecoration.lineThrough : null,
                          color: isChecked ? Colors.grey : Colors.black87,
                        ),
                      ),
                      if (matchedDeal != null && !isChecked)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            children: [
                              const Text("🔥 ",
                                  style: TextStyle(fontSize: 10)),
                              Expanded(
                                child: Text(
                                  "$matchedVendor — \$${(matchedPrice as num?)?.toStringAsFixed(2) ?? ''}",
                                  style: const TextStyle(
                                    color: Color(0xFF0075C9),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (matchedOriginal != null)
                                Text(
                                  " \$${(matchedOriginal as num).toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Quantity controls
                if (!isChecked) ...[
                  // Deal badge
                  if (matchedDeal != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA6CE39),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "DEAL",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  // Qty stepper
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => _updateQty(doc.id, qty - 1),
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child:
                                Icon(Icons.remove, size: 16, color: Colors.grey),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "$qty",
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => _updateQty(doc.id, qty + 1),
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.add,
                                size: 16, color: Color(0xFF0075C9)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("🛒", style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              "Your shopping list is empty",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap the quick-add chips above or hit + to add items.\n"
              "We'll automatically find deals on your list items!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _showAddItemSheet,
              icon: const Icon(Icons.add),
              label: const Text("Add Your First Item"),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0075C9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("🛒", style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              "Sign in to use your Shopping List",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Your list syncs across devices and matches\nitems to active deals automatically.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, "/auth"),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0075C9),
              ),
              child: const Text("Sign In"),
            ),
          ],
        ),
      ),
    );
  }
}

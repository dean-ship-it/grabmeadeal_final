// lib/screens/shopping_list_screen.dart
// Smart Shopping List with inline deal matching — each item shows the
// matched active deal's savings, vendor, and price comparison inline.
// Multiple lists, pantry tracker, aisle categories, curbside pickup.

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

import "../services/barcode_lookup.dart";
import "../widgets/animated_curbside_pickup_icon.dart";
import "barcode_scanner_screen.dart";

// ── Auto-categorize items ────────────────────────────────────────────────────

String _autoCategory(String item) {
  final lower = item.toLowerCase();
  const map = {
    "Produce": ["apple", "banana", "tomato", "onion", "potato", "lettuce",
      "avocado", "pepper", "cucumber", "carrot", "broccoli", "spinach",
      "garlic", "lemon", "lime", "orange", "grape", "strawberry", "blueberry",
      "mushroom", "celery", "corn", "jalapeño", "cilantro", "ginger"],
    "Dairy & Eggs": ["milk", "egg", "cheese", "yogurt", "butter", "cream",
      "sour cream", "half and half", "cottage cheese", "whipping cream"],
    "Meat & Seafood": ["chicken", "beef", "pork", "ground", "steak", "salmon",
      "shrimp", "bacon", "sausage", "turkey", "fish", "tilapia", "hamburger"],
    "Bakery": ["bread", "tortilla", "bun", "roll", "bagel", "muffin",
      "croissant", "cake", "donut", "pie"],
    "Pantry": ["rice", "pasta", "bean", "sauce", "oil", "flour", "sugar",
      "salt", "spice", "seasoning", "soup", "broth", "canned", "noodle",
      "peanut butter", "jelly", "honey", "vinegar", "ketchup", "mustard",
      "mayo", "salsa", "round pan"],
    "Frozen": ["frozen", "ice cream", "pizza", "fries", "waffle", "popsicle"],
    "Beverages": ["coffee", "tea", "juice", "soda", "water", "wine",
      "beer", "energy drink", "creamer", "lemonade", "gatorade"],
    "Snacks": ["chip", "cracker", "cookie", "candy", "popcorn", "pretzel",
      "nut", "granola", "trail mix", "fruit snack"],
    "Household": ["paper towel", "toilet paper", "dish soap", "trash bag",
      "detergent", "bleach", "sponge", "foil", "plastic wrap", "ziplock",
      "cleaning", "lysol", "wipes"],
    "Baby & Kids": ["diaper", "formula", "baby food", "sippy", "pacifier", "baby"],
    "Pet": ["dog food", "cat food", "pet", "kibble", "litter", "treats"],
  };
  for (final entry in map.entries) {
    for (final keyword in entry.value) {
      if (lower.contains(keyword)) return entry.key;
    }
  }
  return "Uncategorized";
}

// ── List Types ───────────────────────────────────────────────────────────────

class _ListType {
  final String id;
  final String name;
  final String emoji;
  const _ListType(this.id, this.name, this.emoji);
}

const List<_ListType> _listTypes = [
  _ListType("groceries", "Groceries", "🛒"),
  _ListType("heb", "HEB Run", "🏪"),
  _ListType("costco", "Costco Run", "📦"),
  _ListType("walmart", "Walmart Run", "🔵"),
  _ListType("pantry", "Pantry List", "🏠"),
];

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
  int _currentTab = 0; // 0=Shopping, 1=Pantry, 2=To Do
  String _selectedList = "groceries";

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

  // Collection reference based on selected list and tab.
  // Reads the uid live from FirebaseAuth on every access so we don't get
  // stuck with a null uid if auth wasn't ready when initState ran.
  CollectionReference? get _listRef {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? _uid;
    if (uid == null) return null;
    final collection = _currentTab == 1
        ? "pantryList"
        : _currentTab == 2
            ? "todoList"
            : "shoppingList_$_selectedList";
    return _firestore.collection("users").doc(uid).collection(collection);
  }

  // ── Add Item ──

  Future<void> _addItem(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final listRef = _listRef;
    if (listRef == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sign in required to add items"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    try {
      // Check for duplicate
      final existing = await listRef
          .where("name", isEqualTo: trimmed.toLowerCase())
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        final doc = existing.docs.first;
        final currentQty = (doc["qty"] as num?)?.toInt() ?? 1;
        await listRef.doc(doc.id).update({"qty": currentQty + 1});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("\"$trimmed\" qty → ${currentQty + 1}")),
          );
        }
        _addController.clear();
        return;
      }

      final category = _autoCategory(trimmed);
      final matchingDeal = await _findMatchingDeal(trimmed);

      await listRef.add({
        "name": trimmed.toLowerCase(),
        "displayName": trimmed,
        "category": category,
        "qty": 1,
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
              "🔥 ${matchingDeal["vendor"]} has ${matchingDeal["title"]} on sale!",
            ),
            backgroundColor: const Color(0xFF0075C9),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Couldn't add \"$trimmed\": $e"),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _scanBarcode() async {
    final barcode = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (!mounted || barcode == null || barcode.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text("Looking up $barcode…"),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    final name = await lookupProductName(barcode);
    if (!mounted) return;
    await _addItem(name ?? barcode);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(name != null
            ? "Added \"$name\""
            : "No match for $barcode — added the barcode (tap to rename)"),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<Map<String, dynamic>?> _findMatchingDeal(String itemName) async {
    try {
      final snap = await _firestore.collection("deals").get();
      final lower = itemName.toLowerCase();
      Map<String, dynamic>? best;
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
            best = data;
          }
        }
      }
      return best;
    } catch (e) {
      debugPrint("[ShoppingList] Deal match error: $e");
    }
    return null;
  }

  Future<void> _toggleChecked(String docId, bool current) async {
    await _listRef?.doc(docId).update({"checked": !current});
  }

  Future<void> _updateQty(String docId, int newQty) async {
    if (newQty <= 0) {
      await _listRef?.doc(docId).delete();
    } else {
      await _listRef?.doc(docId).update({"qty": newQty});
    }
  }

  Future<void> _uncheckAll() async {
    if (_listRef == null) return;
    final checked = await _listRef!.where("checked", isEqualTo: true).get();
    final batch = _firestore.batch();
    for (final doc in checked.docs) {
      batch.update(doc.reference, {"checked": false});
    }
    await batch.commit();
  }

  Future<void> _deleteChecked() async {
    if (_listRef == null) return;
    final checked = await _listRef!.where("checked", isEqualTo: true).get();
    if (checked.docs.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete checked items?"),
        content: Text("Remove ${checked.docs.length} items from your list?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
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

  // ── Curbside Pickup ──

  Future<void> _orderCurbside(String store) async {
    if (_listRef == null) return;
    final snap = await _listRef!.where("checked", isEqualTo: false).get();
    final items = snap.docs
        .map((d) => (d.data() as Map<String, dynamic>)["displayName"] as String? ?? "")
        .where((n) => n.isNotEmpty)
        .toList();
    if (items.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Add items to your list first!")),
        );
      }
      return;
    }
    final query = items.take(5).join(" ");
    final q = Uri.encodeComponent(query);
    Uri url;
    // HEB and Costco are unmonetized goodwill — neither has a public
    // affiliate program. The other four are affiliate targets and will
    // get Rakuten/Impact/Amazon-Associates deep-link wrapping once each
    // network approves the program. See reference_affiliate_accounts.md
    // for account status.
    switch (store) {
      case "heb":
        url = Uri.parse("https://www.heb.com/search/?q=$q");
        break;
      case "costco":
        url = Uri.parse("https://www.costco.com/CatalogSearch?keyword=$q");
        break;
      case "walmart":
        // TODO: wrap in Rakuten deeplink once Walmart program approved (SID 4692019)
        url = Uri.parse("https://www.walmart.com/search?q=$q&cat_id=976759");
        break;
      case "target":
        // TODO: wrap in Impact deeplink once Brand→Publisher ticket resolves
        url = Uri.parse("https://www.target.com/s?searchTerm=$q&category=5xt1a");
        break;
      case "amazon_fresh":
        // TODO: append &tag=<amazon-associates-tag> once Amazon approval lands
        url = Uri.parse("https://www.amazon.com/alm/search?k=$q");
        break;
      case "instacart":
        // TODO: wrap in Impact deeplink once Brand→Publisher ticket resolves
        url = Uri.parse("https://www.instacart.com/store/s?k=$q");
        break;
      default:
        return;
    }
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("[ShoppingList] Launch error: $e");
    }
  }

  void _showCurbsideSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Row(children: [
              const AnimatedCurbsidePickupIcon(
                size: 64,
                pinSizeRatio: 0.34,
                bounceHeight: 5,
              ),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Order Curbside Pickup", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                Text("They pick & pack — you just drive up!", style: TextStyle(fontSize: 13, color: Colors.grey)),
              ])),
            ]),
            const SizedBox(height: 20),
            _storeBtn("HEB Curbside", "Free next-day · \$4.95 same-day", const Color(0xFFCC0000), "🏪", () { Navigator.pop(ctx); _orderCurbside("heb"); }),
            const SizedBox(height: 8),
            _storeBtn("Walmart Pickup", "Free · No minimum order", const Color(0xFF0071DC), "🔵", () { Navigator.pop(ctx); _orderCurbside("walmart"); }),
            const SizedBox(height: 8),
            _storeBtn("Target Drive Up", "Free · Ready in 2 hours", const Color(0xFFCC0000), "🎯", () { Navigator.pop(ctx); _orderCurbside("target"); }),
            const SizedBox(height: 8),
            _storeBtn("Amazon Fresh", "Prime · Same-day delivery", const Color(0xFF232F3E), "📦", () { Navigator.pop(ctx); _orderCurbside("amazon_fresh"); }),
            const SizedBox(height: 8),
            _storeBtn("Instacart", "Multiple stores · 1-hour delivery", const Color(0xFF43B02A), "🛒", () { Navigator.pop(ctx); _orderCurbside("instacart"); }),
            const SizedBox(height: 8),
            _storeBtn("Costco Same-Day", "Members only · Warehouse pickup", const Color(0xFFE31837), "🏬", () { Navigator.pop(ctx); _orderCurbside("costco"); }),
          ],
        ),
      ),
    );
  }

  Widget _storeBtn(String name, String sub, Color color, String emoji, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: color)),
            Text(sub, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ])),
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
        ]),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: user == null ? _buildSignInPrompt() : _buildMainContent(),
      // ── Bottom Nav — Shopping List | Pantry | To Do ──
      bottomNavigationBar: user != null
          ? BottomNavigationBar(
              currentIndex: _currentTab,
              onTap: (i) => setState(() => _currentTab = i),
              selectedItemColor: const Color(0xFF0075C9),
              unselectedItemColor: Colors.grey.shade500,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart_outlined),
                  activeIcon: Icon(Icons.shopping_cart),
                  label: "Shopping List",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.kitchen_outlined),
                  activeIcon: Icon(Icons.kitchen),
                  label: "Pantry",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.checklist_outlined),
                  activeIcon: Icon(Icons.checklist),
                  label: "To Do",
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildMainContent() {
    final listLabel = _currentTab == 0
        ? _listTypes.firstWhere((l) => l.id == _selectedList).name
        : _currentTab == 1
            ? "Pantry List"
            : "To Do List";

    return SafeArea(
      child: Column(
        children: [
          // ── Top Bar with list selector ──
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0075C9), Color(0xFF004A8D)],
              ),
            ),
            child: Column(
              children: [
                // Header row
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    // List selector dropdown (only on Shopping tab)
                    if (_currentTab == 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedList,
                            dropdownColor: const Color(0xFF004A8D),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                            items: _listTypes.map((lt) => DropdownMenuItem(
                              value: lt.id,
                              child: Text("${lt.emoji} ${lt.name}"),
                            )).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedList = val);
                            },
                          ),
                        ),
                      )
                    else
                      Text(listLabel, style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                    const Spacer(),
                    // Curbside button
                    if (_currentTab == 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedCurbsidePickupIcon(
                              size: 50,
                              onTap: _showCurbsideSheet,
                              pinSizeRatio: 0.34,
                              bounceHeight: 5,
                              bounceDuration: const Duration(milliseconds: 900),
                              pauseDuration: const Duration(milliseconds: 700),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "Order Curbside",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 8),
                // ── Add Item Bar ──
                Container(
                  margin: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _addController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (val) => _addItem(val),
                          style: const TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            hintText: _currentTab == 1
                                ? "Add pantry item..."
                                : _currentTab == 2
                                    ? "Add to-do..."
                                    : "Add item...",
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: const Icon(Icons.edit_outlined, size: 20),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.mic_outlined, color: Colors.grey.shade500, size: 22),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Voice input coming soon!")),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.qr_code_scanner, color: Colors.grey.shade500, size: 22),
                                  onPressed: _scanBarcode,
                                ),
                              ],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Explicit "Add" button — users shouldn't have to know
                      // that Enter submits. Lime circle + white plus.
                      Material(
                        color: const Color(0xFFA6CE39),
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => _addItem(_addController.text),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(Icons.add, color: Color(0xFF062245), size: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── List Content ──
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Single-field orderBy — no composite index required.
              // Checked vs unchecked items get separated client-side below.
              stream: _listRef
                  ?.orderBy("addedAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_currentTab == 0)
                          Image.asset(
                            "assets/category_icons/grocery.png",
                            width: 96,
                            height: 96,
                            fit: BoxFit.contain,
                          )
                        else
                          Text(
                            _currentTab == 1 ? "🏠" : "✅",
                            style: const TextStyle(fontSize: 56),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          _currentTab == 1
                              ? "Track what you have at home"
                              : _currentTab == 2
                                  ? "Add tasks to your to-do list"
                                  : "Start adding items!",
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Type above or use the quick-add below",
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  );
                }

                final unchecked = docs.where((d) => !(d["checked"] ?? false)).toList();
                final checked = docs.where((d) => (d["checked"] ?? false)).toList();

                // Group unchecked by category
                final Map<String, List<QueryDocumentSnapshot>> grouped = {};
                for (final doc in unchecked) {
                  final cat = (doc.data() as Map<String, dynamic>)["category"] ?? "Uncategorized";
                  grouped.putIfAbsent(cat as String, () => []).add(doc);
                }

                // Calculate totals
                double total = 0;
                int itemCount = unchecked.length;
                int cartCount = checked.length;
                for (final doc in unchecked) {
                  final data = doc.data() as Map<String, dynamic>;
                  final price = (data["estimatedPrice"] as num?)?.toDouble() ?? 0;
                  final qty = (data["qty"] as num?)?.toInt() ?? 1;
                  total += price * qty;
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.only(bottom: 8),
                        children: [
                          // Uncategorized / categorized items
                          for (final entry in grouped.entries) ...[
                            _categoryHeader(entry.key, entry.value.length),
                            ...entry.value.map((doc) => _buildItem(doc, false)),
                          ],
                          // ── In Your Cart section ──
                          if (checked.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            // Uncheck All / Delete All buttons
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _uncheckAll,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF0075C9),
                                        side: const BorderSide(color: Color(0xFF0075C9)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                      child: const Text("UNCHECK ALL",
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _deleteChecked,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(color: Colors.red),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                      child: const Text("DELETE ALL",
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _categoryHeader("IN YOUR CART", cartCount),
                            ...checked.map((doc) => _buildItem(doc, true)),
                          ],
                        ],
                      ),
                    ),
                    // ── Footer: Totals Bar ──
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(top: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "List Total: \$${total.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: Color(0xFF004A8D),
                                ),
                              ),
                              Text(
                                "Cart Total: \$0.00",
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Items in cart: $cartCount",
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                              Text(
                                "Items in list: ${itemCount + cartCount}",
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // ── Quick Add Chips ──
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: Colors.white,
            child: SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final item in const [
                    "Apples", "Avocados", "Bacon", "Bagels", "Bananas",
                    "Berries", "Bread", "Broccoli", "Butter", "Carrots",
                    "Cereal", "Cheese", "Chicken", "Chips", "Coffee",
                    "Cookies", "Crackers", "Cream Cheese", "Detergent",
                    "Dish Soap", "Eggs", "Flour", "Garlic", "Ground Beef",
                    "Ham", "Honey", "Ice Cream", "Jelly", "Juice", "Ketchup",
                    "Lemons", "Lettuce", "Mayo", "Milk", "Mushrooms",
                    "Mustard", "Oats", "Onions", "Oranges", "Pasta",
                    "Paper Towels", "Peanut Butter", "Peppers", "Pizza",
                    "Potatoes", "Rice", "Salmon", "Salsa", "Sausage",
                    "Soda", "Soup", "Sour Cream", "Spinach", "Strawberries",
                    "Sugar", "Tea", "Toilet Paper", "Tomatoes", "Tortillas",
                    "Trash Bags", "Turkey", "Water", "Yogurt",
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        label: Text(item, style: const TextStyle(fontSize: 11)),
                        onPressed: () => _addItem(item),
                        backgroundColor: Colors.grey.shade100,
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryHeader(String name, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        "$name".toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade500,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildItem(QueryDocumentSnapshot doc, bool isChecked) {
    final data = doc.data() as Map<String, dynamic>;
    final displayName = data["displayName"] ?? data["name"] ?? "";
    final qty = (data["qty"] as num?)?.toInt() ?? 1;
    final matchedDeal = data["matchedDealTitle"];
    final matchedVendor = data["matchedDealVendor"];
    final matchedPrice = (data["matchedDealPrice"] as num?)?.toDouble();
    final matchedOriginal = (data["matchedDealOriginalPrice"] as num?)?.toDouble();
    final hasDeal = matchedDeal != null && matchedPrice != null && !isChecked;
    final savings = (matchedOriginal != null && matchedPrice != null && matchedOriginal > matchedPrice)
        ? matchedOriginal - matchedPrice
        : null;

    // Row background: checked = faint blue, matched = faint lime tint, else white.
    final rowColor = isChecked
        ? const Color(0xFF0075C9).withValues(alpha: 0.06)
        : hasDeal
            ? const Color(0xFFA6CE39).withValues(alpha: 0.10)
            : Colors.white;

    return Dismissible(
      key: Key(doc.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade400,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _listRef?.doc(doc.id).delete(),
      child: Container(
        color: rowColor,
        // IntrinsicHeight gives the Row a concrete height derived from the
        // tallest child, so the stretch-aligned left-edge stripe can fill
        // that height instead of collapsing to zero.
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hasDeal)
                Container(width: 4, color: const Color(0xFFA6CE39))
              else
                const SizedBox(width: 4),
            Expanded(
              child: InkWell(
                onTap: () => _toggleChecked(doc.id, isChecked),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28, height: 28,
                        child: Checkbox(
                          value: isChecked,
                          onChanged: (_) => _toggleChecked(doc.id, isChecked),
                          activeColor: const Color(0xFF0075C9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              qty > 1 ? "$displayName (x$qty)" : displayName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                decoration: isChecked ? TextDecoration.lineThrough : null,
                                color: isChecked ? Colors.grey : Colors.black87,
                              ),
                            ),
                            if (hasDeal) ...[
                              const SizedBox(height: 2),
                              // SAVE banner — the headline
                              Row(
                                children: [
                                  if (savings != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFA6CE39),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        "SAVE \$${savings.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontSize: 11, fontWeight: FontWeight.w800,
                                          color: Color(0xFF062245), letterSpacing: 0.3),
                                      ),
                                    ),
                                  if (savings != null) const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      "at $matchedVendor",
                                      style: const TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w600,
                                        color: Color(0xFF062245)),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 1),
                              // Price comparison line
                              Row(
                                children: [
                                  Text(
                                    "\$${matchedPrice.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87),
                                  ),
                                  if (matchedOriginal != null && matchedOriginal > matchedPrice) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      "\$${matchedOriginal.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        fontSize: 12, color: Colors.grey.shade500,
                                        decoration: TextDecoration.lineThrough),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!isChecked) ...[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () => _updateQty(doc.id, qty - 1),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(Icons.remove, size: 14, color: Colors.grey),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Text("$qty", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              ),
                              InkWell(
                                onTap: () => _updateQty(doc.id, qty + 1),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(Icons.add, size: 14, color: Color(0xFF0075C9)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.drag_handle, size: 18, color: Colors.grey.shade300),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
            Text("Sign in to use your Shopping List",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text("Your list syncs across devices and matches\nitems to active deals automatically.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, "/auth"),
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0075C9)),
              child: const Text("Sign In"),
            ),
          ],
        ),
      ),
    );
  }
}

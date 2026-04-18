// lib/screens/shopping_list_screen.dart
// Built-in shopping list with deal matching — replaces Out of Milk
// Items sync to Firestore per user. Matching deals highlight automatically.

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final _addController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  String? _uid;

  // Predefined quick-add items — common Texas mom grocery list
  static const List<String> _quickAddItems = [
    "Milk", "Eggs", "Bread", "Butter", "Chicken",
    "Ground Beef", "Rice", "Tortillas", "Cheese", "Bananas",
    "Coffee", "Cereal", "Pasta", "Tomatoes", "Onions",
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

  Future<void> _addItem(String name) async {
    if (name.trim().isEmpty || _listRef == null) return;
    final trimmed = name.trim();

    // Check for duplicate
    final existing = await _listRef!
        .where("name", isEqualTo: trimmed.toLowerCase())
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("\"$trimmed\" is already on your list")),
        );
      }
      return;
    }

    // Find matching deals
    final matchingDeal = await _findMatchingDeal(trimmed);

    await _listRef!.add({
      "name": trimmed.toLowerCase(),
      "displayName": trimmed,
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
      // Search deals where title contains the item name
      final snap = await _firestore.collection("deals").get();
      final lower = itemName.toLowerCase();
      for (final doc in snap.docs) {
        final data = doc.data();
        final title = (data["title"] ?? "").toString().toLowerCase();
        final desc = (data["description"] ?? "").toString().toLowerCase();
        if (title.contains(lower) || desc.contains(lower)) {
          return data;
        }
      }
    } catch (e) {
      debugPrint("[ShoppingList] Deal match error: $e");
    }
    return null;
  }

  Future<void> _toggleChecked(String docId, bool currentValue) async {
    await _listRef?.doc(docId).update({"checked": !currentValue});
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
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Clear")),
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping List"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: "Clear checked items",
            onPressed: _clearCheckedItems,
          ),
        ],
      ),
      body: user == null
          ? _buildSignInPrompt()
          : Column(
              children: [
                // ── Add Item Bar ──
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  color: Colors.grey.shade50,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _addController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (val) => _addItem(val),
                          decoration: InputDecoration(
                            hintText: "Add an item...",
                            prefixIcon: const Icon(Icons.add_shopping_cart),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _addItem(_addController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0075C9),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),

                // ── Quick Add Chips ──
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _quickAddItems.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          label: Text(
                            _quickAddItems[index],
                            style: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () => _addItem(_quickAddItems[index]),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      );
                    },
                  ),
                ),

                const Divider(height: 1),

                // ── Shopping List ──
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
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Add items above or tap the quick-add chips.\n"
                                  "We'll match your items to active deals!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final unchecked = docs.where((d) => !(d["checked"] ?? false)).toList();
                      final checked = docs.where((d) => (d["checked"] ?? false)).toList();

                      return ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: [
                          if (unchecked.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                              child: Text(
                                "To Buy (${unchecked.length})",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Color(0xFF0075C9),
                                ),
                              ),
                            ),
                            ...unchecked.map((doc) => _buildListTile(doc, false)),
                          ],
                          if (checked.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                              child: Text(
                                "Done (${checked.length})",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                            ...checked.map((doc) => _buildListTile(doc, true)),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildListTile(QueryDocumentSnapshot doc, bool isChecked) {
    final data = doc.data() as Map<String, dynamic>;
    final displayName = data["displayName"] ?? data["name"] ?? "";
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
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        decoration: BoxDecoration(
          color: isChecked ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: matchedDeal != null && !isChecked
              ? Border.all(color: const Color(0xFFA6CE39), width: 1.5)
              : Border.all(color: Colors.grey.shade200),
        ),
        child: ListTile(
          leading: Checkbox(
            value: isChecked,
            onChanged: (_) => _toggleChecked(doc.id, isChecked),
            activeColor: const Color(0xFF0075C9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          title: Text(
            displayName,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              decoration: isChecked ? TextDecoration.lineThrough : null,
              color: isChecked ? Colors.grey : Colors.black87,
            ),
          ),
          subtitle: matchedDeal != null && !isChecked
              ? Row(
                  children: [
                    const Text("🔥 ", style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Text(
                        "$matchedVendor — \$${(matchedPrice as num?)?.toStringAsFixed(2) ?? ''}",
                        style: const TextStyle(
                          color: Color(0xFF0075C9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (matchedOriginal != null)
                      Text(
                        " was \$${(matchedOriginal as num).toStringAsFixed(0)}",
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                  ],
                )
              : null,
          trailing: isChecked
              ? null
              : matchedDeal != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA6CE39),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "DEAL",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    )
                  : null,
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
              "Your list syncs across devices and matches items to active deals automatically.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, "/auth"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0075C9),
                foregroundColor: Colors.white,
              ),
              child: const Text("Sign In"),
            ),
          ],
        ),
      ),
    );
  }
}

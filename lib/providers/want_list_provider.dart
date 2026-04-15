// lib/providers/want_list_provider.dart

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "package:grabmeadeal_final/models/want_item.dart";

class WantListProvider extends ChangeNotifier {
  List<WantItem> _wants = [];
  bool _loading = false;
  String? _lastError;

  List<WantItem> get wants => List.unmodifiable(_wants);
  bool get loading => _loading;
  int get activeCount => _wants.where((w) => w.active).length;
  String? get lastError => _lastError;

  void clearError() {
    _lastError = null;
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = _uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("wants");
  }

  Future<void> loadWants() async {
    if (_uid == null) {
      _loading = false;
      notifyListeners();
      return;
    }
    _loading = true;
    notifyListeners();
    try {
      final snap = await _collection!
          .orderBy("createdAt", descending: true)
          .get();
      _wants = snap.docs
          .map((doc) => WantItem.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("[WantList] Load error: $e");
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> addWant({
    required String keyword,
    String? category,
    double? maxPrice,
  }) async {
    final uid = _uid;
    if (uid == null) {
      _lastError = "You must be signed in to add items to your Want List.";
      notifyListeners();
      return;
    }

    final want = WantItem(
      id: "",
      userId: uid,
      keyword: keyword.trim(),
      category: category,
      maxPrice: maxPrice,
      createdAt: DateTime.now(),
    );

    try {
      final doc = await _collection!.add(want.toMap());
      final saved = WantItem.fromMap(want.toMap(), doc.id);
      _wants.insert(0, saved);
      _lastError = null;
      notifyListeners();
    } catch (e, stack) {
      debugPrint("[WantList] Add error: $e");
      debugPrint("[WantList] Stack: $stack");
      _lastError = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeWant(String wantId) async {
    try {
      await _collection!.doc(wantId).delete();
      _wants.removeWhere((w) => w.id == wantId);
      notifyListeners();
    } catch (e) {
      debugPrint("[WantList] Remove error: $e");
    }
  }

  Future<void> toggleActive(WantItem want) async {
    try {
      await _collection!.doc(want.id).update({"active": !want.active});
      final index = _wants.indexWhere((w) => w.id == want.id);
      if (index != -1) {
        _wants[index] = want.copyWith(active: !want.active);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("[WantList] Toggle error: $e");
    }
  }
}

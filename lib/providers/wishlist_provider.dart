import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:grabmeadeal_final/models/deal.dart";

class WishlistProvider extends ChangeNotifier {
  final Set<String> _wishlistIds = <String>{};
  final List<Deal> _wishlistDeals = <Deal>[];

  Set<String> get wishlistIds => _wishlistIds;
  List<Deal> get wishlistDeals => _wishlistDeals;

  bool isWishlisted(String id) => _wishlistIds.contains(id);

  void toggleWishlist(Deal deal) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Will be handled by UI — _promptSignIn in DealCard
      return;
    }
    if (_wishlistIds.contains(deal.id)) {
      _wishlistIds.remove(deal.id);
      _wishlistDeals.removeWhere((Deal d) => d.id == deal.id);
    } else {
      _wishlistIds.add(deal.id);
      _wishlistDeals.add(deal);
    }
    notifyListeners();
  }

  void addToWishlist(Deal deal) {
    if (!_wishlistIds.contains(deal.id)) {
      _wishlistIds.add(deal.id);
      _wishlistDeals.add(deal);
      notifyListeners();
    }
  }

  void removeFromWishlist(Deal deal) {
    if (_wishlistIds.contains(deal.id)) {
      _wishlistIds.remove(deal.id);
      _wishlistDeals.removeWhere((Deal d) => d.id == deal.id);
      notifyListeners();
    }
  }

  void clearWishlist() {
    _wishlistIds.clear();
    _wishlistDeals.clear();
    notifyListeners();
  }
}

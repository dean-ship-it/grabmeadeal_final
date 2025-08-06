import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';

class WishlistProvider extends ChangeNotifier {
  final Set<String> _wishlistIds = {};
  final List<Deal> _wishlistDeals = [];

  Set<String> get wishlistIds => _wishlistIds;
  List<Deal> get wishlistDeals => _wishlistDeals;

  get ids => null;

  get toggleDeal => null;

  void toggleWishlist(Deal deal) {
    if (_wishlistIds.contains(deal.id)) {
      _wishlistIds.remove(deal.id);
      _wishlistDeals.removeWhere((d) => d.id == deal.id);
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
      _wishlistDeals.removeWhere((d) => d.id == deal.id);
      notifyListeners();
    }
  }

  void clearWishlist() {
    _wishlistIds.clear();
    _wishlistDeals.clear();
    notifyListeners();
  }
}

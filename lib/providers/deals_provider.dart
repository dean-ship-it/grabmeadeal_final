import 'package:flutter/foundation.dart';
import 'package:grabmeadeal_final/models/deal.dart';

class DealsProvider with ChangeNotifier {
  List<Deal> _deals = [];

  List<Deal> get deals => _deals;

  void setDeals(List<Deal> newDeals) {
    _deals = newDeals;
    notifyListeners();
  }

  void addDeal(Deal deal) {
    _deals.add(deal);
    notifyListeners();
  }

  void removeDeal(String dealId) {
    _deals.removeWhere((deal) => deal.id == dealId);
    notifyListeners();
  }

  void clearDeals() {
    _deals.clear();
    notifyListeners();
  }

  Deal? getDealById(String dealId) {
    try {
      return _deals.firstWhere((deal) => deal.id == dealId);
    } catch (e) {
      return null;
    }
  }
}

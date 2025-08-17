import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';

class DealProvider extends ChangeNotifier {
  List<Deal> _deals = <Deal>[];

  List<Deal> get deals => _deals;

  void setDeals(List<Deal> newDeals) {
    _deals = newDeals;
    notifyListeners();
  }

  void addDeal(Deal deal) {
    _deals.add(deal);
    notifyListeners();
  }

  void clearDeals() {
    _deals.clear();
    notifyListeners();
  }
}

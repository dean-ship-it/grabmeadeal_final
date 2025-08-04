import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/models/category.dart';

class ApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Deal>> fetchDeals() async {
    final snapshot = await _firestore.collection('deals').get();
    return snapshot.docs
        .map((doc) => Deal.fromFirestore(doc))
        .whereType<Deal>()
        .toList();
  }

  Future<List<Category>> fetchCategories() async {
    final snapshot = await _firestore.collection('categories').get();
    return snapshot.docs
        .map((doc) => Category.fromFirestore(doc))
        .whereType<Category>()
        .toList();
  }
}

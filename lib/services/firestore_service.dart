import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/deal.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetch deals filtered by subcategory
  Future<List<Deal>> getDealsBySubcategory(String subcategory) async {
    try {
      final snapshot = await _db
          .collection('deals')
          .where('subcategory', isEqualTo: subcategory)
          .get();

      return snapshot.docs
          .map((doc) => Deal.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching deals by subcategory: $e");
      return [];
    }
  }

  /// Search deals by keyword in title or description
  Future<List<Deal>> searchDealsByKeyword(String keyword) async {
    try {
      final snapshot = await _db
          .collection('deals')
          .where('keywords', arrayContains: keyword.toLowerCase())
          .get();

      return snapshot.docs
          .map((doc) => Deal.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error searching deals: $e");
      return [];
    }
  }
}

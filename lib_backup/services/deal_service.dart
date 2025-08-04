// lib/services/deal_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grabmeadeal_final/models/deal.dart';

class DealService {
  final _dealsRef = FirebaseFirestore.instance.collection('deals');

  Future<void> addDeal({
    required String title,
    required String description,
    required double price,
    required double originalPrice,
    required String imageUrl,
    required String vendor,
    required String category,
    required String link,
    required DateTime date,
  }) async {
    final newDeal = Deal(
      id: '',
      title: title,
      description: description,
      price: price,
      originalPrice: originalPrice,
      imageUrl: imageUrl,
      vendor: vendor,
      category: category,
      link: link,
      date: date,
    );

    await _dealsRef.add(newDeal.toMap());
  }

  Future<List> fetchAllDeals() async {
    final querySnapshot = await _dealsRef.get();
    return querySnapshot.docs.map((doc) => Deal.fromFirestore(doc)).toList();
  }
}

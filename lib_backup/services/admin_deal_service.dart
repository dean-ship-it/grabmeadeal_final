import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grabmeadeal_final/models/deal.dart';

class AdminDealService {
  final CollectionReference _dealsRef =
      FirebaseFirestore.instance.collection('deals');

  Future<void> uploadDeal(AdminDeal deal) async {
    try {
      await _dealsRef.add(deal.toMap());
      print('✅ Deal uploaded successfully');
    } catch (e) {
      print('❌ Error uploading deal: $e');
    }
  }
}

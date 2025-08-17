import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Set<String>> fetchWishlist(String userId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .get();

      return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.id).toSet();
    } catch (e) {
      print('Error fetching wishlist: $e');
      return <String>{};
    }
  }

  Future<void> addToWishlist(String userId, String dealId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .doc(dealId)
          .set(<String, dynamic>{'addedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      print('Error adding to wishlist: $e');
    }
  }

  Future<void> removeFromWishlist(String userId, String dealId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .doc(dealId)
          .delete();
    } catch (e) {
      print('Error removing from wishlist: $e');
    }
  }
}

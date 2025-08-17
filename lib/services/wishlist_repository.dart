import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches all wishlist items for a given userId.
  /// Each wishlist item is expected to contain:
  ///  - storeLat (double)
  ///  - storeLng (double)
  ///  - storeName (string)
  ///  - dealTitle (string)
  Future<List<Map<String, dynamic>>> fetchWishlist(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('wishlists')
          .doc(userId)
          .collection('items')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'storeLat': data['storeLat']?.toDouble() ?? 0.0,
          'storeLng': data['storeLng']?.toDouble() ?? 0.0,
          'storeName': data['storeName'] ?? 'Unknown Store',
          'dealTitle': data['dealTitle'] ?? 'Deal',
        };
      }).toList();
    } catch (e) {
      print('Error fetching wishlist: $e');
      return [];
    }
  }
}

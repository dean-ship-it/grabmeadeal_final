import 'package:cloud_firestore/cloud_firestore.dart';

class Store {

  Store({
    required this.id,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
  });

  factory Store.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    return Store(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Store',
      category: data['category'] ?? 'general',
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
    );
  }
  final String id;
  final String name;
  final String category;
  final double latitude;
  final double longitude;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

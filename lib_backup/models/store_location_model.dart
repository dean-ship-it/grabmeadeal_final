class StoreLocation {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String category;

  StoreLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.category,
  });

  factory StoreLocation.fromFirestore(Map<String, dynamic> data, String docId) {
    return StoreLocation(
      id: docId,
      name: data['name'] ?? 'Unknown Store',
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      category: data['category'] ?? 'General',
    );
  }
}

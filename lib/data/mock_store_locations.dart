
class StoreLocation {

  StoreLocation({
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
  });
  final String name;
  final String category;
  final double latitude;
  final double longitude;
}

final List<StoreLocation> mockStoreLocations = <StoreLocation>[
  StoreLocation(
    name: 'H-E-B Houston',
    category: 'Groceries',
    latitude: 29.7604,
    longitude: -95.3698,
  ),
  StoreLocation(
    name: 'Best Buy Galleria',
    category: 'Electronics',
    latitude: 29.7400,
    longitude: -95.4700,
  ),
  StoreLocation(
    name: 'Home Depot North Freeway',
    category: 'Home Improvement',
    latitude: 29.8702,
    longitude: -95.4085,
  ),
  StoreLocation(
    name: 'Target Midtown',
    category: 'General',
    latitude: 29.7425,
    longitude: -95.3770,
  ),
  StoreLocation(
    name: 'Costco Katy',
    category: 'Wholesale',
    latitude: 29.7858,
    longitude: -95.7943,
  ),
];

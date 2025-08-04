import 'package:geolocator/geolocator.dart';
import 'package:grabmeadeal_final/models/deal.dart';

class DealAlertService {
  final List<Deal> allDeals;
  final Set<String> wishlistIds;

  DealAlertService({
    required this.allDeals,
    required this.wishlistIds,
  });

  Future<List<Deal>> getNearbyWishlistDeals(Position userPosition) async {
    const double radiusInMeters = 5000; // 5 km radius

    return allDeals.where((deal) {
      final bool isInWishlist = wishlistIds.contains(deal.id);
      final bool hasLocation = deal.latitude != null && deal.longitude != null;

      if (!isInWishlist || !hasLocation) return false;

      final double distance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        deal.latitude!,
        deal.longitude!,
      );

      return distance <= radiusInMeters;
    }).toList();
  }
}

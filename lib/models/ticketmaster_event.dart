/// Event record from the Ticketmaster Discovery API.
///
/// Surfaces only the fields the Featured card renders. Raw API payload is
/// much richer — see https://developer.ticketmaster.com/products-and-docs/
class TicketmasterEvent {
  const TicketmasterEvent({
    required this.id,
    required this.name,
    required this.url,
    required this.imageUrl,
    this.venueName,
    this.city,
    this.stateCode,
    this.startAt,
    this.minPrice,
    this.maxPrice,
    this.segment,
  });

  /// Build from a single event object inside the Discovery API response.
  factory TicketmasterEvent.fromJson(Map<String, dynamic> json) {
    // Pick the widest landscape image we can find.
    final List<dynamic> images =
        (json["images"] as List<dynamic>? ?? <dynamic>[]);
    String bestImage = "";
    int bestWidth = 0;
    for (final dynamic img in images) {
      if (img is! Map) continue;
      final Map<dynamic, dynamic> m = img;
      final int w = (m["width"] as num? ?? 0).toInt();
      final int h = (m["height"] as num? ?? 0).toInt();
      if (w < h) continue; // prefer landscape
      if (w > bestWidth) {
        bestWidth = w;
        bestImage = (m["url"] as String?) ?? "";
      }
    }

    // Venue info lives under _embedded.venues[0].
    String? venueName;
    String? city;
    String? stateCode;
    final Map<String, dynamic>? embedded =
        json["_embedded"] as Map<String, dynamic>?;
    if (embedded != null) {
      final List<dynamic>? venues = embedded["venues"] as List<dynamic>?;
      if (venues != null && venues.isNotEmpty && venues.first is Map) {
        final Map<dynamic, dynamic> v = venues.first as Map<dynamic, dynamic>;
        venueName = v["name"] as String?;
        final Map<dynamic, dynamic>? cityMap =
            v["city"] as Map<dynamic, dynamic>?;
        city = cityMap?["name"] as String?;
        final Map<dynamic, dynamic>? stateMap =
            v["state"] as Map<dynamic, dynamic>?;
        stateCode = stateMap?["stateCode"] as String?;
      }
    }

    // Start date/time.
    DateTime? startAt;
    final Map<String, dynamic>? dates =
        json["dates"] as Map<String, dynamic>?;
    final Map<String, dynamic>? start =
        dates?["start"] as Map<String, dynamic>?;
    final String? dateStr = start?["localDate"] as String?;
    final String? timeStr = start?["localTime"] as String?;
    if (dateStr != null) {
      final String combined =
          timeStr != null ? "${dateStr}T$timeStr" : dateStr;
      startAt = DateTime.tryParse(combined);
    }

    // Price range.
    double? minPrice;
    double? maxPrice;
    final List<dynamic>? priceRanges = json["priceRanges"] as List<dynamic>?;
    if (priceRanges != null && priceRanges.isNotEmpty &&
        priceRanges.first is Map) {
      final Map<dynamic, dynamic> p =
          priceRanges.first as Map<dynamic, dynamic>;
      minPrice = (p["min"] as num?)?.toDouble();
      maxPrice = (p["max"] as num?)?.toDouble();
    }

    // Segment (Sports / Music / etc.)
    String? segment;
    final List<dynamic>? classifications =
        json["classifications"] as List<dynamic>?;
    if (classifications != null && classifications.isNotEmpty &&
        classifications.first is Map) {
      final Map<dynamic, dynamic> c =
          classifications.first as Map<dynamic, dynamic>;
      final Map<dynamic, dynamic>? segMap =
          c["segment"] as Map<dynamic, dynamic>?;
      segment = segMap?["name"] as String?;
    }

    return TicketmasterEvent(
      id: (json["id"] as String?) ?? "",
      name: (json["name"] as String?) ?? "",
      url: (json["url"] as String?) ?? "",
      imageUrl: bestImage,
      venueName: venueName,
      city: city,
      stateCode: stateCode,
      startAt: startAt,
      minPrice: minPrice,
      maxPrice: maxPrice,
      segment: segment,
    );
  }

  final String id;
  final String name;
  final String url;
  final String imageUrl;
  final String? venueName;
  final String? city;
  final String? stateCode;
  final DateTime? startAt;
  final double? minPrice;
  final double? maxPrice;
  final String? segment; // Sports, Music, Arts & Theatre, etc.
}

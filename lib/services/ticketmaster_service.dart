// Ticketmaster Discovery API client.
//
// Consumer Key ships with the build — Discovery keys are rate-limited
// (5000/day, 5 req/sec) and not authentication secrets. Safe to embed.
//
// One in-memory 30-minute cache per query signature keeps the request
// count trivial even under aggressive screen navigation.

import "dart:async";
import "dart:convert";

import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;

import "../models/ticketmaster_event.dart";

class TicketmasterService {
  static const String _consumerKey = "LFEQYPKUbdfLweTRPVJRCAGv03gGuUXX";
  static const String _baseHost = "app.ticketmaster.com";
  static const Duration _cacheTtl = Duration(minutes: 30);

  static final Map<String, _CacheEntry> _cache = <String, _CacheEntry>{};

  /// Fetch the first upcoming event with a usable image for the given state.
  /// Falls through the top 20 relevance-ranked results to find one with a
  /// landscape image. Returns null on any failure (caller should fall back).
  static Future<TicketmasterEvent?> fetchFeaturedEvent({
    String stateCode = "TX",
    String? classificationName,
  }) async {
    final List<TicketmasterEvent> events = await fetchEvents(
      stateCode: stateCode,
      classificationName: classificationName,
      size: 20,
    );
    for (final TicketmasterEvent e in events) {
      if (e.imageUrl.isNotEmpty) return e;
    }
    return null;
  }

  /// Fetch a page of events for a state. Caches 30 min per query signature.
  /// Returns an empty list on any failure (caller should show empty state).
  static Future<List<TicketmasterEvent>> fetchEvents({
    String stateCode = "TX",
    String? classificationName,
    int size = 40,
    String sort = "date,asc",
  }) async {
    final String cacheKey =
        "list:$stateCode:${classificationName ?? ''}:$size:$sort";
    final _CacheEntry? cached = _cache[cacheKey];
    if (cached != null && !cached.isExpired) {
      return cached.events;
    }

    try {
      final Map<String, String> params = <String, String>{
        "apikey": _consumerKey,
        "stateCode": stateCode,
        "size": size.clamp(1, 200).toString(),
        "sort": sort,
        if (classificationName != null) "classificationName": classificationName,
      };
      final Uri uri =
          Uri.https(_baseHost, "/discovery/v2/events.json", params);
      final http.Response resp = await http
          .get(uri)
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) {
        debugPrint(
          "[Ticketmaster] ${resp.statusCode}: ${resp.body.substring(0, resp.body.length.clamp(0, 200))}",
        );
        return <TicketmasterEvent>[];
      }
      final Map<String, dynamic> body =
          jsonDecode(resp.body) as Map<String, dynamic>;
      final Map<String, dynamic>? embedded =
          body["_embedded"] as Map<String, dynamic>?;
      final List<dynamic>? events = embedded?["events"] as List<dynamic>?;
      if (events == null || events.isEmpty) return <TicketmasterEvent>[];

      final List<TicketmasterEvent> parsed = <TicketmasterEvent>[];
      for (final dynamic raw in events) {
        if (raw is! Map) continue;
        parsed.add(
          TicketmasterEvent.fromJson(Map<String, dynamic>.from(raw)),
        );
      }
      _cache[cacheKey] =
          _CacheEntry.list(parsed, DateTime.now().add(_cacheTtl));
      return parsed;
    } catch (err) {
      debugPrint("[Ticketmaster] fetchEvents failed: $err");
      return <TicketmasterEvent>[];
    }
  }
}

class _CacheEntry {
  _CacheEntry.list(this.events, this.expiresAt);

  final List<TicketmasterEvent> events;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

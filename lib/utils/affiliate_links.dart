/// Affiliate-link wrapping for outbound URLs.
///
/// - Amazon: appends `tag=<associates-id>` (US Associates).
/// - eBay: routes through rover.ebay.com with our EPN campid.
/// - CJ: routes through anrdoezrs.net with our PID + the advertiser's AID.
///   Only hosts listed in [_cjAdvertisers] get wrapped — unknown hosts
///   pass through so we never emit an invalid click URL.
/// - Everything else: returned unchanged.
///
/// Account IDs are kept here (not env vars) because they are non-secret
/// and must ship with every build.
library;

const String _amazonAssociatesTag = "grabmeadeal-20";
const String _ebayCampaignId = "5339150078";
const String _ebayUsRotationId = "711-53200-19255-0";
const String _cjPublisherId = "101729609";

/// CJ approved advertisers: host → Advertiser ID (AID).
/// Add a new row when CJ approves a new program — wrapping activates
/// automatically for any URL on that host.
const Map<String, String> _cjAdvertisers = <String, String>{
  "choicehomewarranty.com": "4593144",
  "eastwood.com": "5396115",
  "healthlabs.com": "5214471",
  "lightingnewyork.com": "7345655",
  "mfimedical.com": "7227612",
  "russellstover.com": "4441453",
  // KISSusa / FALSCARA / ColorsandCare / imPRESSbeauty (AID 5551348) —
  // multi-brand program, domain(s) still TBD.
};

bool _isAmazonHost(String host) {
  final String h = host.toLowerCase();
  return h == "amazon.com" ||
      h.endsWith(".amazon.com") ||
      h == "amzn.to" ||
      h == "a.co";
}

bool _isEbayHost(String host) {
  final String h = host.toLowerCase();
  return h == "ebay.com" || h.endsWith(".ebay.com");
}

/// Returns the matched CJ advertiser's AID for a given host, or null if
/// the host isn't on an approved CJ program.
String? _cjAdvertiserIdFor(String host) {
  final String h = host.toLowerCase();
  // Exact match first.
  final String? exact = _cjAdvertisers[h];
  if (exact != null) return exact;
  // Allow www. and other subdomain prefixes.
  for (final MapEntry<String, String> entry in _cjAdvertisers.entries) {
    if (h.endsWith(".${entry.key}")) return entry.value;
  }
  return null;
}

String _wrapAmazon(Uri uri) {
  if (uri.queryParameters.containsKey("tag")) return uri.toString();
  final Map<String, String> params =
      Map<String, String>.from(uri.queryParameters)
        ..["tag"] = _amazonAssociatesTag;
  return uri.replace(queryParameters: params).toString();
}

String _wrapEbay(Uri uri, {String? customId}) {
  final Map<String, String> params = <String, String>{
    "mpre": uri.toString(),
    "campid": _ebayCampaignId,
    "toolid": "10001",
    if (customId != null && customId.isNotEmpty) "customid": customId,
  };
  return Uri.https("rover.ebay.com", "/rover/1/$_ebayUsRotationId/1", params)
      .toString();
}

String _wrapCj(Uri uri, String advertiserId, {String? customId}) {
  final Map<String, String> params = <String, String>{
    "url": uri.toString(),
    if (customId != null && customId.isNotEmpty) "sid": customId,
  };
  return Uri.https(
    "www.anrdoezrs.net",
    "/click-$_cjPublisherId-$advertiserId",
    params,
  ).toString();
}

/// Wrap a URL with the appropriate affiliate tracking.
/// Unrecognized hosts pass through untouched.
/// [customId] flows to the network's sub-ID field (eBay customid / CJ sid).
String wrapAffiliate(String url, {String? customId}) {
  if (url.isEmpty) return url;
  final Uri? uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme) return url;
  if (_isAmazonHost(uri.host)) return _wrapAmazon(uri);
  if (_isEbayHost(uri.host)) return _wrapEbay(uri, customId: customId);
  final String? cjAid = _cjAdvertiserIdFor(uri.host);
  if (cjAid != null) return _wrapCj(uri, cjAid, customId: customId);
  return url;
}

/// Build an Amazon search URL with our Associates tag.
String amazonSearchUrl(String query) {
  final String q = Uri.encodeQueryComponent(query);
  return "https://www.amazon.com/s?k=$q&tag=$_amazonAssociatesTag";
}

/// Build an eBay search URL routed through rover with our campid.
String ebaySearchUrl(String query, {String? customId}) {
  final String target =
      "https://www.ebay.com/sch/i.html?_nkw=${Uri.encodeQueryComponent(query)}";
  return _wrapEbay(Uri.parse(target), customId: customId);
}

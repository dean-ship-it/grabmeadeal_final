// Wraps a retailer URL in a Rakuten Advertising deeplink so click-throughs
// get credited to our publisher account (SID 4692019). Parallel to the
// Amazon Associates wrapper in amazon_affiliate.dart — same contract:
// pure function, no I/O, safe to call on every URL launch, pass-through
// for anything we don't recognize.
//
// Rakuten's click-tracking URL format:
//   https://click.linksynergy.com/deeplink?id=SID&mid=MID&murl=ENCODED_URL
// where SID identifies the publisher (us) and MID identifies the
// advertiser (the retailer). Both sides have to be approved before
// clicks are valid — there's no blanket approval.
//
// The _rakutenAdvertisers map is intentionally empty. As advertiser
// approvals come in from the Rakuten Publisher Dashboard, add a single
// line per retailer keyed by the retailer's primary host. Example:
//   'bestbuy.com': 37649,
// Host matching is case-insensitive and subdomain-aware (see the
// _matchHost helper below).

/// Our Rakuten publisher SID. Same value on every deeplink we generate
/// so commission always lands on the same account.
const int kRakutenPublisherSid = 4692019;

/// Approved Rakuten advertisers keyed by primary host. Add entries here
/// as the Rakuten Publisher Dashboard flips them to "Partnered".
///
/// Look up a retailer's MID by opening their card on the dashboard — the
/// header shows "MID 12345" right under the advertiser name.
const Map<String, int> _rakutenAdvertisers = <String, int>{
  // 'bestbuy.com': 0, // TODO: add MID once approved (Rakuten-confirmed)
  // 'lowes.com': 0,   // TODO: add MID once approved (Rakuten-confirmed)
};

/// Wrap a retailer URL in a Rakuten deeplink if we have an approved
/// partnership for that host. Returns the original URL unchanged if the
/// host isn't in our advertiser map, if the URL doesn't parse, or if
/// it's not an http(s) scheme.
String wrapRakutenDeeplink(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return url;
  if (uri.scheme != 'http' && uri.scheme != 'https') return url;

  final mid = _lookupMid(uri.host.toLowerCase());
  if (mid == null) return url;

  return 'https://click.linksynergy.com/deeplink'
      '?id=$kRakutenPublisherSid'
      '&mid=$mid'
      '&murl=${Uri.encodeComponent(url)}';
}

/// True if we have a Rakuten partnership for this URL's host. Exposed so
/// the caller can pick between affiliate networks without double-wrapping.
bool isRakutenPartner(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  return _lookupMid(uri.host.toLowerCase()) != null;
}

/// Look up the MID for a host, matching both the exact host and its
/// registrable domain (so 'www.bestbuy.com' still hits 'bestbuy.com').
int? _lookupMid(String host) {
  final direct = _rakutenAdvertisers[host];
  if (direct != null) return direct;
  // Strip a leading 'www.' — the common case for subdomain variance.
  if (host.startsWith('www.')) {
    return _rakutenAdvertisers[host.substring(4)];
  }
  return null;
}

// Wraps an Amazon URL with our Associates tracking tag so click-throughs
// get credited to the grabmeadeal-20 account. Required to convert the
// Associates provisional approval (reference_affiliate_accounts.md) into
// the 3 qualifying sales needed to unlock PA-API access.
//
// Pure function — no I/O, no state, safe to call on every URL launch.
// Non-Amazon URLs pass through unchanged.

/// US Amazon Associates tracking ID. Same tag on every outbound Amazon
/// link so commission always lands on the same account.
const String kAmazonAssociatesTag = 'grabmeadeal-20';

/// Amazon domains we'll tag. Kept narrow to avoid tagging non-US regional
/// storefronts (Amazon rejects cross-region tags, and our approval is US
/// only). `a.co` is Amazon's official US short-link domain.
const Set<String> _taggableHosts = {
  'amazon.com',
  'www.amazon.com',
  'smile.amazon.com',
  'a.co',
};

/// Add (or replace) the `tag` query parameter on any Amazon URL. Returns
/// the URL unchanged if the host isn't one we recognize, if the string
/// doesn't parse, or if it's not an http(s) scheme.
String addAmazonAffiliateTag(
  String url, {
  String tag = kAmazonAssociatesTag,
}) {
  final uri = Uri.tryParse(url);
  if (uri == null) return url;
  if (uri.scheme != 'http' && uri.scheme != 'https') return url;
  if (!_taggableHosts.contains(uri.host.toLowerCase())) return url;

  final params = Map<String, String>.from(uri.queryParameters);
  params['tag'] = tag;
  return uri.replace(queryParameters: params).toString();
}

import 'package:flutter_test/flutter_test.dart';
import 'package:grabmeadeal_final/services/rakuten_affiliate.dart';

void main() {
  group('wrapRakutenDeeplink — pass-through when no partnership exists', () {
    test('returns unchanged for non-partner host', () {
      const url = 'https://www.bestbuy.com/site/laptops';
      expect(wrapRakutenDeeplink(url), url);
    });

    test('returns unchanged for empty string', () {
      expect(wrapRakutenDeeplink(''), '');
    });

    test('returns unchanged for malformed URL', () {
      const url = 'http://[not a url';
      expect(wrapRakutenDeeplink(url), url);
    });

    test('does NOT wrap javascript: scheme (XSS protection)', () {
      const url = 'javascript:alert(1)';
      expect(wrapRakutenDeeplink(url), url);
    });

    test('does NOT wrap data: URI', () {
      const url = 'data:text/html,<script>alert(1)</script>';
      expect(wrapRakutenDeeplink(url), url);
    });

    test('does NOT wrap file: scheme', () {
      const url = 'file:///etc/passwd';
      expect(wrapRakutenDeeplink(url), url);
    });
  });

  group('isRakutenPartner — reads partnership state without side effects', () {
    test('returns false for non-partner host', () {
      expect(isRakutenPartner('https://www.bestbuy.com/'), isFalse);
    });

    test('returns false for malformed URL', () {
      expect(isRakutenPartner('http://[not a url'), isFalse);
    });

    test('returns false for empty string', () {
      expect(isRakutenPartner(''), isFalse);
    });
  });

  // Once real advertisers are added to _rakutenAdvertisers, add cases here
  // that mirror the amazon_affiliate_test.dart coverage — host match (bare
  // + www + uppercase), murl encoding, query-param preservation, and
  // idempotency (wrapping an already-wrapped URL should be a no-op since
  // click.linksynergy.com isn't in the advertiser map).
}

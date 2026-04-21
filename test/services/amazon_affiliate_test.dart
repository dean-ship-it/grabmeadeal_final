import 'package:flutter_test/flutter_test.dart';
import 'package:grabmeadeal_final/services/amazon_affiliate.dart';

void main() {
  group('addAmazonAffiliateTag — tags Amazon URLs', () {
    test('adds tag to bare amazon.com product URL', () {
      final result = addAmazonAffiliateTag('https://www.amazon.com/dp/B07123XYZ');
      expect(result, 'https://www.amazon.com/dp/B07123XYZ?tag=grabmeadeal-20');
    });

    test('adds tag when no subdomain (amazon.com)', () {
      final result = addAmazonAffiliateTag('https://amazon.com/dp/B07123XYZ');
      expect(Uri.parse(result).queryParameters['tag'], 'grabmeadeal-20');
    });

    test('adds tag to a.co short link', () {
      final result = addAmazonAffiliateTag('https://a.co/d/abc123');
      expect(Uri.parse(result).queryParameters['tag'], 'grabmeadeal-20');
    });

    test('adds tag to smile.amazon.com URL', () {
      final result = addAmazonAffiliateTag('https://smile.amazon.com/dp/B07123XYZ');
      expect(Uri.parse(result).queryParameters['tag'], 'grabmeadeal-20');
    });

    test('preserves existing query parameters', () {
      final result = addAmazonAffiliateTag(
        'https://www.amazon.com/dp/B07123XYZ?th=1&psc=1',
      );
      final params = Uri.parse(result).queryParameters;
      expect(params['tag'], 'grabmeadeal-20');
      expect(params['th'], '1');
      expect(params['psc'], '1');
    });

    test('replaces existing tag parameter (prevents a competitor stealing credit)', () {
      final result = addAmazonAffiliateTag(
        'https://www.amazon.com/dp/B07123XYZ?tag=someoneelse-20',
      );
      expect(Uri.parse(result).queryParameters['tag'], 'grabmeadeal-20');
    });

    test('preserves URL path', () {
      final result = addAmazonAffiliateTag(
        'https://www.amazon.com/Instant-Pot-Duo/dp/B07123XYZ',
      );
      expect(Uri.parse(result).path, '/Instant-Pot-Duo/dp/B07123XYZ');
    });

    test('preserves URL fragment', () {
      final result = addAmazonAffiliateTag(
        'https://www.amazon.com/dp/B07123XYZ#reviews',
      );
      expect(Uri.parse(result).fragment, 'reviews');
    });

    test('matches host case-insensitively', () {
      final result = addAmazonAffiliateTag('https://WWW.AMAZON.COM/dp/B07123XYZ');
      expect(Uri.parse(result).queryParameters['tag'], 'grabmeadeal-20');
    });

    test('is idempotent — tagging twice produces the same result', () {
      const url = 'https://www.amazon.com/dp/B07123XYZ';
      final once = addAmazonAffiliateTag(url);
      final twice = addAmazonAffiliateTag(once);
      expect(once, twice);
    });

    test('honours a custom tag override', () {
      final result = addAmazonAffiliateTag(
        'https://www.amazon.com/dp/B07123XYZ',
        tag: 'othertag-20',
      );
      expect(Uri.parse(result).queryParameters['tag'], 'othertag-20');
    });
  });

  group('addAmazonAffiliateTag — leaves non-Amazon URLs alone', () {
    test('passes Walmart URL through unchanged', () {
      const url = 'https://www.walmart.com/ip/123';
      expect(addAmazonAffiliateTag(url), url);
    });

    test('passes Target URL through unchanged', () {
      const url = 'https://www.target.com/p/123';
      expect(addAmazonAffiliateTag(url), url);
    });

    test('passes Poshmark URL through unchanged', () {
      const url = 'https://poshmark.com/listing/123';
      expect(addAmazonAffiliateTag(url), url);
    });

    test('does NOT tag amazon.co.uk (US-only Associates approval)', () {
      const url = 'https://www.amazon.co.uk/dp/B07123XYZ';
      expect(addAmazonAffiliateTag(url), url);
    });

    test('does NOT tag amazon.ca', () {
      const url = 'https://www.amazon.ca/dp/B07123XYZ';
      expect(addAmazonAffiliateTag(url), url);
    });

    test('does NOT tag amazon.de', () {
      const url = 'https://www.amazon.de/dp/B07123XYZ';
      expect(addAmazonAffiliateTag(url), url);
    });

    test('does NOT tag lookalike domain amazon.com.evil.com', () {
      const url = 'https://amazon.com.evil.com/dp/B07123XYZ';
      expect(addAmazonAffiliateTag(url), url);
    });
  });

  group('addAmazonAffiliateTag — rejects malformed or unsafe input', () {
    test('returns empty string unchanged', () {
      expect(addAmazonAffiliateTag(''), '');
    });

    test('returns unchanged when URL is unparseable gibberish', () {
      const url = 'http://[not a url';
      expect(addAmazonAffiliateTag(url), url);
    });

    test('does NOT tag javascript: scheme (XSS protection)', () {
      const url = 'javascript:alert(1)';
      expect(addAmazonAffiliateTag(url), url);
    });

    test('does NOT tag data: URI', () {
      const url = 'data:text/html,<script>alert(1)</script>';
      expect(addAmazonAffiliateTag(url), url);
    });

    test('does NOT tag file: scheme', () {
      const url = 'file:///etc/passwd';
      expect(addAmazonAffiliateTag(url), url);
    });
  });
}

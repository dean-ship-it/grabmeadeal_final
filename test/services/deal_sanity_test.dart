import 'package:flutter_test/flutter_test.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/services/deal_sanity.dart';

Deal _deal({
  required double price,
  double? originalPrice,
}) {
  return Deal(
    id: 't',
    title: 'Test Deal',
    description: '',
    category: 'food',
    subcategory: '',
    vendor: 'test',
    price: price,
    originalPrice: originalPrice,
    imageUrl: 'https://example.com/x.jpg',
    keywords: const [],
    createdAt: DateTime(2026),
  );
}

void main() {
  group('hasBelievableSavings — accepts realistic deals', () {
    test('accepts a modest grocery-style deal (\$40 → \$28, 30% off)', () {
      expect(
        hasBelievableSavings(_deal(price: 28, originalPrice: 40)),
        isTrue,
      );
    });

    test('accepts an exceptional but realistic deal (\$100 → \$25, 75% off)', () {
      expect(
        hasBelievableSavings(_deal(price: 25, originalPrice: 100)),
        isTrue,
      );
    });

    test('accepts a mid-range product hitting \$500 savings exactly', () {
      // \$1500 → \$1000 : \$500 savings, 33% off, original under \$2000 cap
      expect(
        hasBelievableSavings(_deal(price: 1000, originalPrice: 1500)),
        isTrue,
      );
    });
  });

  group('hasBelievableSavings — rejects scraper-noise pricing', () {
    test('rejects the \$88,863 savings case (huge MSRP, huge dollar gap)', () {
      // Mirrors the user-reported "Recommended for You" junk: an item with
      // original price in the tens of thousands and a huge absolute gap.
      expect(
        hasBelievableSavings(_deal(price: 9000, originalPrice: 97863)),
        isFalse,
      );
    });

    test('rejects the Poshmark \$1000 → \$53 style deal (95% off)', () {
      expect(
        hasBelievableSavings(_deal(price: 53, originalPrice: 1000)),
        isFalse,
      );
    });

    test('rejects a deal with originalPrice over the \$2000 cap', () {
      expect(
        hasBelievableSavings(_deal(price: 1500, originalPrice: 2500)),
        isFalse,
      );
    });

    test('rejects a deal with absolute savings over the \$500 cap', () {
      // \$1800 → \$1200 : \$600 savings — original is under \$2000, pct
      // is 33%, but absolute savings exceed the cap.
      expect(
        hasBelievableSavings(_deal(price: 1200, originalPrice: 1800)),
        isFalse,
      );
    });

    test('rejects a deal with discount over 75% even if cheap', () {
      // \$100 → \$10 : 90% off. Absolute savings fine, original fine, but
      // the percent alone is far past what legitimate sales produce.
      expect(
        hasBelievableSavings(_deal(price: 10, originalPrice: 100)),
        isFalse,
      );
    });
  });

  group('hasBelievableSavings — rejects missing or malformed pricing', () {
    test('rejects zero current price', () {
      expect(
        hasBelievableSavings(_deal(price: 0, originalPrice: 20)),
        isFalse,
      );
    });

    test('rejects negative current price', () {
      expect(
        hasBelievableSavings(_deal(price: -5, originalPrice: 20)),
        isFalse,
      );
    });

    test('rejects missing originalPrice', () {
      expect(
        hasBelievableSavings(_deal(price: 20, originalPrice: null)),
        isFalse,
      );
    });

    test('rejects originalPrice equal to price (no sale)', () {
      expect(
        hasBelievableSavings(_deal(price: 20, originalPrice: 20)),
        isFalse,
      );
    });

    test('rejects originalPrice below price (inverted)', () {
      expect(
        hasBelievableSavings(_deal(price: 30, originalPrice: 20)),
        isFalse,
      );
    });
  });
}

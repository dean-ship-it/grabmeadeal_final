// Shared sanity check for "is this deal's savings believable?"
//
// Used by every surface that shows a savings badge or picks a hero deal.
// When a scraper produces junk data (original price $97,000, current
// price $9,000, savings $88,000) we want ONE predicate that says no —
// so the hero auto-picker, the hero SAVE badge, and the grid tile
// "-XX%" badge all agree on what counts as a believable deal.
//
// Thresholds are tuned for a daily-deal aggregator serving grocery and
// household shoppers. If the app ever pivots to selling high-ticket
// electronics or luxury goods as heroes, these caps will need to move.

import 'package:grabmeadeal_final/models/deal.dart';

/// Hard dollar cap on hero/grid savings. A $500 saving on a daily deal
/// is already exceptional. Anything above this is almost always a
/// scraper pulling a stale "MSRP" off a product page.
const double kMaxBelievableSavingsDollars = 500.0;

/// Hard dollar cap on the original ("was") price. Nothing the app
/// features should have a four-figure MSRP — that's outside the
/// "stuff I'd buy anyway" framing.
const double kMaxBelievableOriginalPriceDollars = 2000.0;

/// Discount ceiling. 75% off is already unusually deep; the 90%-plus
/// range is where bad data lives (price = 1 cent placeholder, etc.).
const double kMaxBelievableDiscountPct = 0.75;

/// True when a deal's savings look real enough to show prominently.
/// Returns false for any of:
///   - non-positive current price (free items produce nonsensical pct)
///   - missing or non-positive originalPrice
///   - originalPrice not actually above price (no sale)
///   - originalPrice over the MSRP cap
///   - absolute savings over the cap
///   - discount percent over the cap
bool hasBelievableSavings(Deal d) {
  if (d.price <= 0) return false;
  final op = d.originalPrice;
  if (op == null || op <= d.price) return false;
  if (op > kMaxBelievableOriginalPriceDollars) return false;
  final savings = op - d.price;
  if (savings > kMaxBelievableSavingsDollars) return false;
  final pct = savings / op;
  if (pct > kMaxBelievableDiscountPct) return false;
  return true;
}

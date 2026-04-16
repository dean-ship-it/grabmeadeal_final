import 'package:flutter/material.dart';
import 'brand_colors.dart';

/// A ThemeExtension so you can access brand-specific
/// colors through Theme.of(context).extension<BrandColorScheme>().
@immutable
class BrandColorScheme extends ThemeExtension<BrandColorScheme> {

  const BrandColorScheme({
    required this.deepBlueShadow,
    required this.limeGreen,
    required this.oliveGreen,
  });
  final Color deepBlueShadow;
  final Color limeGreen;
  final Color oliveGreen;

  @override
  BrandColorScheme copyWith({
    Color? deepBlueShadow,
    Color? limeGreen,
    Color? oliveGreen,
  }) {
    return BrandColorScheme(
      deepBlueShadow: deepBlueShadow ?? this.deepBlueShadow,
      limeGreen: limeGreen ?? this.limeGreen,
      oliveGreen: oliveGreen ?? this.oliveGreen,
    );
  }

  @override
  BrandColorScheme lerp(ThemeExtension<BrandColorScheme>? other, double t) {
    if (other is! BrandColorScheme) return this;
    return BrandColorScheme(
      deepBlueShadow: Color.lerp(deepBlueShadow, other.deepBlueShadow, t)!,
      limeGreen: Color.lerp(limeGreen, other.limeGreen, t)!,
      oliveGreen: Color.lerp(oliveGreen, other.oliveGreen, t)!,
    );
  }
}

/// Default instance you can inject into your ThemeData.extensions
const BrandColorScheme brandColorScheme = BrandColorScheme(
  deepBlueShadow: BrandColors.deepBlueShadow,
  limeGreen: BrandColors.limeGreen,
  oliveGreen: BrandColors.oliveGreen,
);

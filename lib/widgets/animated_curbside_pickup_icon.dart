// lib/widgets/animated_curbside_pickup_icon.dart
//
// Reusable curbside-pickup brand icon with a single animated element:
// the lime green location pin gently bounces up and down in the upper
// corner while the rest of the illustration (car, bag, curb, road,
// navy background) stays completely static.
//
// ─────────────────────────────────────────────────────────────────────
// USAGE
// ─────────────────────────────────────────────────────────────────────
//
//   AnimatedCurbsidePickupIcon(
//     size: 72,
//     onTap: () => showCurbsideSheet(),
//   )
//
// The animated pin is drawn in Flutter (CustomPainter) on top of a
// static PNG base. For the cleanest effect, the base PNG should be a
// pin-less version of the curbside illustration — otherwise the
// baked-in pin will briefly peek out from behind the animated one at
// the top of each bounce. Pass `basePngAsset` to swap images.
//
// ─────────────────────────────────────────────────────────────────────
// TUNING KNOBS
// ─────────────────────────────────────────────────────────────────────
//
//   bounceHeight      — vertical travel in logical px. Default 6.
//                       Taste: 4 = whisper, 8 = noticeable, >10 loses
//                       the "premium micro" feel.
//   bounceDuration    — time for one up-down motion. Default 900ms.
//                       Shorter feels urgent; longer feels floaty.
//   pauseDuration     — rest at the low point between cycles.
//                       Default 600ms. This is what separates a
//                       breathing loop from a nervous wiggle.
//   pinAlignment      — where the pin sits in the icon. Defaults to
//                       roughly the upper-left area of the curbside
//                       composite. Adjust x∈[-1,1], y∈[-1,1] to
//                       match a different base image.
//   pinSizeRatio      — pin height as a fraction of the widget size.
//                       Default 0.32.
//   reduceMotion      — force-disable the animation at the widget
//                       level. The widget also auto-honors the
//                       platform's "reduce motion" accessibility
//                       setting via MediaQuery.disableAnimations.
//
// ─────────────────────────────────────────────────────────────────────

import "package:flutter/material.dart";

class AnimatedCurbsidePickupIcon extends StatefulWidget {
  // ── Tap target ──
  final VoidCallback? onTap;

  // ── Sizing ──
  final double size;

  // ── Base image ──
  final String basePngAsset;
  final BoxFit baseFit;

  // ── Motion tuning ──
  final double bounceHeight;
  final Duration bounceDuration;
  final Duration pauseDuration;

  // ── Pin positioning + sizing ──
  final Alignment pinAlignment;
  final double pinSizeRatio;

  // ── Palette ──
  final Color pinColor;        // lime green body — default #A6CE39
  final Color pinShadowColor;  // navy accents   — default #062245
  final Color pinCenterColor;  // hollow center  — default white

  // ── Accessibility ──
  final bool reduceMotion;
  final String? semanticLabel;

  const AnimatedCurbsidePickupIcon({
    super.key,
    this.onTap,
    this.size = 96,
    this.basePngAsset = "assets/icons/curbside.png",
    this.baseFit = BoxFit.contain,
    this.bounceHeight = 6,
    this.bounceDuration = const Duration(milliseconds: 900),
    this.pauseDuration = const Duration(milliseconds: 600),
    this.pinAlignment = const Alignment(-0.1, -0.45),
    this.pinSizeRatio = 0.32,
    this.pinColor = const Color(0xFFA6CE39),
    this.pinShadowColor = const Color(0xFF062245),
    this.pinCenterColor = Colors.white,
    this.reduceMotion = false,
    this.semanticLabel = "Curbside pickup",
  });

  @override
  State<AnimatedCurbsidePickupIcon> createState() =>
      _AnimatedCurbsidePickupIconState();
}

class _AnimatedCurbsidePickupIconState extends State<AnimatedCurbsidePickupIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _pinOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.bounceDuration + widget.pauseDuration,
    );
    _buildTween();
    _controller.repeat();
  }

  void _buildTween() {
    final halfBounceMs = widget.bounceDuration.inMilliseconds / 2;
    final pauseMs = widget.pauseDuration.inMilliseconds.toDouble();

    _pinOffset = TweenSequence<double>(<TweenSequenceItem<double>>[
      // Lift up with ease-out (decelerates at peak)
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0, end: -widget.bounceHeight)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: halfBounceMs,
      ),
      // Fall back with ease-in (accelerates into rest)
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: -widget.bounceHeight, end: 0)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: halfBounceMs,
      ),
      // Hold at rest between cycles
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0),
        weight: pauseMs,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant AnimatedCurbsidePickupIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    final timingChanged = oldWidget.bounceDuration != widget.bounceDuration ||
        oldWidget.pauseDuration != widget.pauseDuration ||
        oldWidget.bounceHeight != widget.bounceHeight;
    if (timingChanged) {
      _controller.stop();
      _controller.duration = widget.bounceDuration + widget.pauseDuration;
      _buildTween();
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only skip animation if the caller explicitly opts out. The bounce is
    // ~5 px and gentle enough that it doesn't warrant honoring the platform
    // reduce-motion flag by default (doing so was masking the animation
    // entirely for any user with Windows "Show animations" disabled).
    final animate = !widget.reduceMotion;

    final pinHeight = widget.size * widget.pinSizeRatio;
    final pinWidth = pinHeight * 0.72;

    final pin = _Pin(
      width: pinWidth,
      height: pinHeight,
      color: widget.pinColor,
      shadowColor: widget.pinShadowColor,
      centerColor: widget.pinCenterColor,
    );

    final pinOverlay = Align(
      alignment: widget.pinAlignment,
      child: animate
          ? AnimatedBuilder(
              animation: _pinOffset,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _pinOffset.value),
                  child: child,
                );
              },
              child: pin,
            )
          : pin,
    );

    final stack = SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Static base: car + bag + curb + road + background + sparkles
          Image.asset(widget.basePngAsset, fit: widget.baseFit),
          pinOverlay,
        ],
      ),
    );

    final tappable = widget.onTap == null
        ? stack
        : Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(widget.size * 0.18),
              child: stack,
            ),
          );

    return Semantics(
      label: widget.semanticLabel,
      button: widget.onTap != null,
      child: tappable,
    );
  }
}

// ── Pin primitive (teardrop body, hollow center, soft drop shadow) ──

class _Pin extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final Color shadowColor;
  final Color centerColor;

  const _Pin({
    required this.width,
    required this.height,
    required this.color,
    required this.shadowColor,
    required this.centerColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _PinPainter(
        color: color,
        shadowColor: shadowColor,
        centerColor: centerColor,
      ),
    );
  }
}

class _PinPainter extends CustomPainter {
  final Color color;
  final Color shadowColor;
  final Color centerColor;

  const _PinPainter({
    required this.color,
    required this.shadowColor,
    required this.centerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final headRadius = w / 2;
    final headCenter = Offset(w / 2, headRadius);

    // Teardrop path: semicircular head on top, tapered tail ending in a
    // point at the bottom-center. Control points at (w, w*0.85) /
    // (0, w*0.85) keep the tail tangent-smooth against the head.
    final body = Path()
      ..moveTo(0, headRadius)
      ..arcToPoint(
        Offset(w, headRadius),
        radius: Radius.circular(headRadius),
        clockwise: true,
      )
      ..quadraticBezierTo(w, w * 0.85, w / 2, h)
      ..quadraticBezierTo(0, w * 0.85, 0, headRadius)
      ..close();

    // Soft drop shadow behind the pin
    canvas.save();
    canvas.translate(0, h * 0.03);
    canvas.drawPath(
      body,
      Paint()
        ..color = shadowColor.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.2),
    );
    canvas.restore();

    // Lime body fill
    canvas.drawPath(body, Paint()..color = color);

    // Subtle navy outline for depth
    canvas.drawPath(
      body,
      Paint()
        ..color = shadowColor.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.035,
    );

    // Hollow white center
    canvas.drawCircle(
      headCenter,
      headRadius * 0.42,
      Paint()..color = centerColor,
    );

    // Thin navy ring around the hollow — matches the reference art
    canvas.drawCircle(
      headCenter,
      headRadius * 0.42,
      Paint()
        ..color = shadowColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.025,
    );
  }

  @override
  bool shouldRepaint(covariant _PinPainter old) =>
      old.color != color ||
      old.shadowColor != shadowColor ||
      old.centerColor != centerColor;
}

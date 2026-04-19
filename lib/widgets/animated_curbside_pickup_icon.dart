// lib/widgets/animated_curbside_pickup_icon.dart
//
// Reusable curbside-pickup brand icon with a single animated element:
// a 3D-illustrated location pin that gently bounces up and down over a
// static base scene (car + bag + curb + sky). Both layers are PNG so
// the pin and base share the same rendering style — no pasted-sticker
// look.
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
// The base PNG must be pin-less — the pin is a separate sprite layered
// on top. Pass `basePngAsset` / `pinPngAsset` to swap art.
//
// ─────────────────────────────────────────────────────────────────────
// TUNING KNOBS
// ─────────────────────────────────────────────────────────────────────
//
//   bounceHeight      — vertical travel in logical px. Default 6.
//                       Taste: 4 = whisper, 8 = noticeable, >10 loses
//                       the "premium micro" feel.
//   bounceDuration    — time for one up-down motion. Default 900ms.
//   pauseDuration     — rest at the low point between cycles.
//                       Default 600ms.
//   pinAlignment      — where the pin sits in the icon. x∈[-1,1],
//                       y∈[-1,1]. Default (-0.1, -0.45) — upper-
//                       center over the car.
//   pinSizeRatio      — pin height as a fraction of the widget size.
//                       Default 0.36.
//   reduceMotion      — force-disable the animation at the widget
//                       level.
//
// ─────────────────────────────────────────────────────────────────────

import "package:flutter/material.dart";

class AnimatedCurbsidePickupIcon extends StatefulWidget {
  // ── Tap target ──
  final VoidCallback? onTap;

  // ── Sizing ──
  final double size;

  // ── Base + pin images ──
  final String basePngAsset;
  final String pinPngAsset;
  final BoxFit baseFit;

  // ── Motion tuning ──
  final double bounceHeight;
  final Duration bounceDuration;
  final Duration pauseDuration;

  // ── Pin positioning + sizing ──
  final Alignment pinAlignment;
  final double pinSizeRatio;

  // ── Accessibility ──
  final bool reduceMotion;
  final String? semanticLabel;

  const AnimatedCurbsidePickupIcon({
    super.key,
    this.onTap,
    this.size = 96,
    this.basePngAsset = "assets/icons/curbside_base.png",
    this.pinPngAsset = "assets/icons/curbside_pin.png",
    this.baseFit = BoxFit.contain,
    this.bounceHeight = 6,
    this.bounceDuration = const Duration(milliseconds: 900),
    this.pauseDuration = const Duration(milliseconds: 600),
    this.pinAlignment = const Alignment(-0.1, -0.45),
    this.pinSizeRatio = 0.36,
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

    final pin = SizedBox(
      height: pinHeight,
      child: Image.asset(widget.pinPngAsset, fit: BoxFit.contain),
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


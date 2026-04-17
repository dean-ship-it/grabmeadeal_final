// lib/screens/puzzle_reward_screen.dart

import "dart:math";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:grabmeadeal_final/providers/puzzle_provider.dart";

// ── Brand colors for the 8 puzzle pieces ──
const _pieceColors = [
  Color(0xFF0075C9), // Electronics — primary blue
  Color(0xFF4E342E), // Furniture — warm brown
  Color(0xFF37474F), // Tools — steel grey
  Color(0xFF6A1B9A), // Gaming — purple
  Color(0xFFAD1457), // Beauty — magenta
  Color(0xFF2E7D32), // Pet Supplies — green
  Color(0xFFE65100), // Apparel — orange
  Color(0xFFC62828), // Automotive — red
];

const _lockedColor = Color(0xFF1A2744);
const _lockedBorder = Color(0xFF2A3D5E);

class PuzzleRewardScreen extends StatefulWidget {
  const PuzzleRewardScreen({super.key});

  @override
  State<PuzzleRewardScreen> createState() => _PuzzleRewardScreenState();
}

class _PuzzleRewardScreenState extends State<PuzzleRewardScreen>
    with TickerProviderStateMixin {
  late AnimationController _wheelController;
  late AnimationController _pulseController;
  late AnimationController _celebrationController;
  late Animation<double> _wheelAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _celebrationScale;
  bool _spinning = false;
  int _landedSegment = 0;
  bool _celebrationPlayed = false;

  @override
  void initState() {
    super.initState();

    _wheelController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _wheelAnimation = CurvedAnimation(
      parent: _wheelController,
      curve: Curves.easeOutCubic,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _celebrationScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
          parent: _celebrationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _wheelController.dispose();
    _pulseController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _checkCelebration(PuzzleProvider puzzle) {
    if (!_celebrationPlayed &&
        puzzle.progress != null &&
        puzzle.progress!.canSpin == true) {
      _celebrationPlayed = true;
      _celebrationController.forward();
    }
  }

  Future<void> _spinWheel() async {
    if (_spinning) return;
    setState(() => _spinning = true);

    final random = Random();
    _landedSegment = random.nextInt(8);

    _wheelController.reset();
    await _wheelController.animateTo(1.0,
        duration: const Duration(seconds: 4));

    if (!mounted) return;
    final puzzle = context.read<PuzzleProvider>();
    final prize = await puzzle.recordSpin(_landedSegment);

    if (!mounted) return;
    setState(() => _spinning = false);
    _showPrizeDialog(prize);
  }

  void _showPrizeDialog(String prize) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "\u{1F389} You Won!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              prize,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0075C9),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Verify your phone number to claim your prize!",
                textAlign: TextAlign.center),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, "/prize-claim", arguments: prize);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFA6CE39),
                foregroundColor: Colors.black,
              ),
              child: const Text("Claim My Prize",
                  style:
                      TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PuzzleProvider>(
      builder: (context, puzzle, _) {
        final progress = puzzle.progress;
        final pieces = PuzzleProvider.pieces;
        final unlockedCount = progress?.unlockedCategories.length ?? 0;
        final allComplete = progress?.canSpin == true;
        final unlockedSet = progress?.unlockedCategories ?? {};

        _checkCelebration(puzzle);

        return Scaffold(
          appBar: AppBar(
            title: const Text("Puzzle Rewards"),
            centerTitle: true,
            backgroundColor: const Color(0xFF0075C9),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF002B5E), Color(0xFF004A8D)],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  // ── Header ──
                  const Text(
                    "Buy deals in all 8 categories\nto complete the puzzle!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Puzzle Ring ──
                  AnimatedBuilder(
                    animation: Listenable.merge(
                        [_pulseController, _celebrationController]),
                    builder: (context, _) {
                      final scale =
                          allComplete ? _celebrationScale.value : 1.0;

                      return Transform.scale(
                        scale: scale,
                        child: SizedBox(
                          width: 320,
                          height: 320,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // The painted puzzle ring
                              CustomPaint(
                                size: const Size(320, 320),
                                painter: _PuzzleRingPainter(
                                  pieceCount: 8,
                                  unlockedSet: unlockedSet,
                                  categories: pieces
                                      .map((p) => p["category"]!)
                                      .toList(),
                                  colors: _pieceColors,
                                  pulseValue: _pulseAnimation.value,
                                ),
                              ),

                              // Emoji overlays on each piece
                              ...List.generate(pieces.length, (i) {
                                final angle =
                                    (2 * pi * i / pieces.length) - pi / 2;
                                const r = 105.0;
                                final x = r * cos(angle);
                                final y = r * sin(angle);
                                final cat = pieces[i]["category"]!;
                                final unlocked =
                                    unlockedSet.contains(cat);

                                return Transform.translate(
                                  offset: Offset(x, y),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        pieces[i]["icon"]!,
                                        style: TextStyle(
                                          fontSize: unlocked ? 30 : 22,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        pieces[i]["label"]!.split(" ").first,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: unlocked
                                              ? Colors.white
                                              : Colors.white
                                                  .withValues(alpha: 0.35),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),

                              // Center logo
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: allComplete
                                          ? const Color(0xFFA6CE39)
                                              .withValues(alpha: 0.6)
                                          : Colors.black
                                              .withValues(alpha: 0.4),
                                      blurRadius: allComplete ? 20 : 12,
                                      spreadRadius: allComplete ? 3 : 0,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset(
                                      "assets/logo/logo.png",
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) =>
                                          const Center(
                                        child: Text(
                                          "GMD",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 18,
                                            color: Color(0xFF0075C9),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // ── Progress ──
                  Text(
                    "$unlockedCount / 8 pieces",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: unlockedCount / 8,
                      backgroundColor: const Color(0xFF002244),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFA6CE39)),
                      minHeight: 10,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Spin or Status ──
                  if (allComplete && progress?.spinUsed != true) ...[
                    const Text(
                      "\u{1F389} Puzzle Complete!",
                      style: TextStyle(
                        color: Color(0xFFA6CE39),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: 280,
                      height: 280,
                      child: AnimatedBuilder(
                        animation: _wheelAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _wheelAnimation.value *
                                (2 * pi * 5 +
                                    _landedSegment * (2 * pi / 8)),
                            child: CustomPaint(
                              size: const Size(280, 280),
                              painter: _WheelPainter(
                                segments: PuzzleProvider.wheelSegments,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Spin button
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFA6CE39), Color(0xFF7A9A01)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFA6CE39)
                                  .withValues(alpha: 0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _spinning ? null : _spinWheel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            _spinning
                                ? "Spinning..."
                                : "\u{1F3B0} SPIN TO WIN!",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else if (progress?.spinUsed == true) ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              const Color(0xFFA6CE39).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text("\u{1F3C6} Prize Won!",
                              style: TextStyle(
                                  color: Color(0xFFA6CE39),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900)),
                          const SizedBox(height: 8),
                          Text(
                            progress?.prizeWon ?? "",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Text("\u{1F512}", style: TextStyle(fontSize: 36)),
                          SizedBox(height: 8),
                          Text(
                            "Complete all 8 puzzle pieces to unlock\nthe Spin to Win wheel!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Puzzle Ring Painter — draws 8 jigsaw-style arc pieces ────────────────────
// ─────────────────────────────────────────────────────────────────────────────

class _PuzzleRingPainter extends CustomPainter {
  final int pieceCount;
  final Set<String> unlockedSet;
  final List<String> categories;
  final List<Color> colors;
  final double pulseValue;

  const _PuzzleRingPainter({
    required this.pieceCount,
    required this.unlockedSet,
    required this.categories,
    required this.colors,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 8;
    final innerRadius = outerRadius * 0.42;
    final sweepAngle = 2 * pi / pieceCount;
    final gap = 0.04; // small gap between pieces

    for (int i = 0; i < pieceCount; i++) {
      final startAngle = (2 * pi * i / pieceCount) - pi / 2 + gap / 2;
      final sweep = sweepAngle - gap;
      final unlocked = unlockedSet.contains(categories[i]);

      final color = unlocked ? colors[i] : _lockedColor;

      // Draw the arc wedge
      final path = Path();
      // Outer arc
      path.arcTo(
        Rect.fromCircle(center: center, radius: outerRadius),
        startAngle,
        sweep,
        true,
      );
      // Line to inner arc end
      final innerEndAngle = startAngle + sweep;
      path.lineTo(
        center.dx + innerRadius * cos(innerEndAngle),
        center.dy + innerRadius * sin(innerEndAngle),
      );
      // Inner arc (reverse)
      path.arcTo(
        Rect.fromCircle(center: center, radius: innerRadius),
        innerEndAngle,
        -sweep,
        false,
      );
      path.close();

      // ── Shadow for unlocked pieces ──
      if (unlocked) {
        canvas.drawShadow(path, const Color(0xFFFFC107), 8, false);
      }

      // ── Fill ──
      final paint = Paint()
        ..style = PaintingStyle.fill;

      if (unlocked) {
        // Radial gradient for depth
        paint.shader = RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [
            color.withValues(alpha: 1.0),
            Color.lerp(color, Colors.black, 0.25)!,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
      } else {
        // Locked: muted with pulse opacity
        final alpha = 0.4 + (pulseValue * 0.2);
        paint.color = _lockedColor.withValues(alpha: alpha);
      }
      canvas.drawPath(path, paint);

      // ── Border ──
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = unlocked ? 2.5 : 1.0
        ..color = unlocked
            ? Colors.white.withValues(alpha: 0.8)
            : _lockedBorder;
      canvas.drawPath(path, borderPaint);

      // ── Tab nubs (jigsaw connector bumps) ──
      // Outer tab — bump outward at midpoint of outer arc
      final midAngle = startAngle + sweep / 2;
      final tabRadius = 7.0;
      final outerTabCenter = Offset(
        center.dx + (outerRadius + tabRadius * 0.4) * cos(midAngle),
        center.dy + (outerRadius + tabRadius * 0.4) * sin(midAngle),
      );
      canvas.drawCircle(
        outerTabCenter,
        tabRadius,
        Paint()
          ..color = unlocked ? color : _lockedColor.withValues(alpha: 0.6)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        outerTabCenter,
        tabRadius,
        Paint()
          ..color = unlocked
              ? Colors.white.withValues(alpha: 0.7)
              : _lockedBorder
          ..style = PaintingStyle.stroke
          ..strokeWidth = unlocked ? 2.0 : 1.0,
      );

      // Inner tab — bump inward toward center
      final innerTabCenter = Offset(
        center.dx + (innerRadius - tabRadius * 0.4) * cos(midAngle),
        center.dy + (innerRadius - tabRadius * 0.4) * sin(midAngle),
      );
      canvas.drawCircle(
        innerTabCenter,
        tabRadius * 0.7,
        Paint()
          ..color = unlocked ? color : _lockedColor.withValues(alpha: 0.6)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        innerTabCenter,
        tabRadius * 0.7,
        Paint()
          ..color = unlocked
              ? Colors.white.withValues(alpha: 0.6)
              : _lockedBorder
          ..style = PaintingStyle.stroke
          ..strokeWidth = unlocked ? 1.5 : 0.8,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PuzzleRingPainter old) =>
      old.unlockedSet != unlockedSet || old.pulseValue != pulseValue;
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Wheel Painter ────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────

class _WheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> segments;
  const _WheelPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * pi / segments.length;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < segments.length; i++) {
      final startAngle = i * segmentAngle - pi / 2;
      final paint = Paint()
        ..color = Color(segments[i]["color"] as int)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        paint,
      );

      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        borderPaint,
      );

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(startAngle + segmentAngle / 2);
      canvas.translate(radius * 0.6, 0);

      textPainter.text = TextSpan(
        text: segments[i]["label"] as String,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      );
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }

    canvas.drawCircle(center, 24, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

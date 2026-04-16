// lib/screens/puzzle_reward_screen.dart

import "dart:math";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:grabmeadeal_final/providers/puzzle_provider.dart";

class PuzzleRewardScreen extends StatefulWidget {
  const PuzzleRewardScreen({super.key});

  @override
  State<PuzzleRewardScreen> createState() => _PuzzleRewardScreenState();
}

class _PuzzleRewardScreenState extends State<PuzzleRewardScreen>
    with TickerProviderStateMixin {
  late AnimationController _wheelController;
  late AnimationController _pieceController;
  late Animation<double> _wheelAnimation;
  bool _spinning = false;
  int _landedSegment = 0;
  String? _prize;

  @override
  void initState() {
    super.initState();
    _wheelController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _pieceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _wheelAnimation = CurvedAnimation(
      parent: _wheelController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _wheelController.dispose();
    _pieceController.dispose();
    super.dispose();
  }

  Future<void> _spinWheel() async {
    if (_spinning) return;
    setState(() => _spinning = true);

    final random = Random();
    _landedSegment = random.nextInt(8);
    final targetAngle = (2 * pi * 5) +
        (_landedSegment * (2 * pi / 8));

    _wheelController.reset();
    await _wheelController.animateTo(
      1.0,
      duration: const Duration(seconds: 4),
    );

    if (!mounted) return;
    final puzzle = context.read<PuzzleProvider>();
    final prize = await puzzle.recordSpin(_landedSegment);

    if (!mounted) return;
    setState(() {
      _prize = prize;
      _spinning = false;
    });

    _showPrizeDialog(prize);
  }

  void _showPrizeDialog(String prize) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
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
            const Text(
              "Verify your phone number to claim your prize!",
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(
                  context,
                  "/prize-claim",
                  arguments: prize,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFA6CE39),
                foregroundColor: Colors.black,
              ),
              child: const Text(
                "Claim My Prize",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
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

        return Scaffold(
          appBar: AppBar(
            title: const Text("Puzzle Rewards"),
            centerTitle: true,
            backgroundColor: const Color(0xFF0075C9),
            foregroundColor: Colors.white,
          ),
          backgroundColor: const Color(0xFF004A8D),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                // ── Header ──
                const Text(
                  "Buy deals in all 8 categories\nto complete the puzzle!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 24),

                // ── Puzzle Circle ──
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Center Logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "GMD",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Color(0xFF0075C9),
                            ),
                          ),
                        ),
                      ),

                      // Puzzle Pieces in Circle
                      ...List.generate(pieces.length, (i) {
                        final angle = (2 * pi * i / pieces.length) - pi / 2;
                        const radius = 110.0;
                        final x = radius * cos(angle);
                        final y = radius * sin(angle);
                        final category = pieces[i]["category"]!;
                        final unlocked = progress?.unlockedCategories
                                .contains(category) ??
                            false;

                        return Transform.translate(
                          offset: Offset(x, y),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: unlocked
                                  ? const Color(0xFF5BBEFF)
                                  : Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: unlocked
                                    ? const Color(0xFFA6CE39)
                                    : Colors.white.withOpacity(0.3),
                                width: unlocked ? 3 : 1,
                              ),
                              boxShadow: unlocked
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFA6CE39)
                                            .withOpacity(0.6),
                                        blurRadius: 12,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  pieces[i]["icon"]!,
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: unlocked
                                        ? null
                                        : Colors.white.withOpacity(0.4),
                                  ),
                                ),
                                Text(
                                  pieces[i]["label"]!
                                      .split(" ")
                                      .first,
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                    color: unlocked
                                        ? Colors.black87
                                        : Colors.white.withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Progress ──
                Text(
                  "${progress?.unlockedCategories.length ?? 0} / 8 pieces unlocked",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 8),

                LinearProgressIndicator(
                  value: (progress?.unlockedCategories.length ?? 0) / 8,
                  backgroundColor: Colors.white24,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFFA6CE39)),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),

                const SizedBox(height: 32),

                // ── Spin Wheel or Locked Message ──
                if (progress?.canSpin == true) ...[
                  const Text(
                    "🎉 Puzzle Complete! Spin to Win!",
                    style: TextStyle(
                      color: const Color(0xFFA6CE39),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Spin Wheel
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
                            painter: _WheelPainter(
                              segments: PuzzleProvider.wheelSegments,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Spin Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _spinning ? null : _spinWheel,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFA6CE39),
                        foregroundColor: Colors.black,
                      ),
                      child: Text(
                        _spinning ? "Spinning..." : "🎰 SPIN TO WIN",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ] else if (progress?.spinUsed == true) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "🏆 Prize Won!",
                          style: TextStyle(
                            color: const Color(0xFFA6CE39),
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          progress?.prizeWon ?? "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      "Complete all 8 puzzle pieces to unlock the Spin to Win wheel!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Wheel Painter ─────────────────────────────────────────────────────────────

class _WheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> segments;
  const _WheelPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * pi / segments.length;
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

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

      // Border
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

      // Label
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
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    // Center circle
    canvas.drawCircle(
      center,
      24,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

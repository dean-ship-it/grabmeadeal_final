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
  late AnimationController _pulseController;
  late AnimationController _celebrationController;
  late Animation<double> _wheelAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _celebrationScale;
  late Animation<double> _celebrationOpacity;
  bool _spinning = false;
  int _landedSegment = 0;
  String? _prize;
  bool _celebrationPlayed = false;

  @override
  void initState() {
    super.initState();

    // Wheel spin
    _wheelController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _wheelAnimation = CurvedAnimation(
      parent: _wheelController,
      curve: Curves.easeOutCubic,
    );

    // Locked pieces pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Celebration animation
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _celebrationScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );
    _celebrationOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _celebrationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
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
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
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
        final unlockedCount = progress?.unlockedCategories.length ?? 0;
        final allComplete = progress?.canSpin == true;

        // Trigger celebration on completion
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
                colors: [Color(0xFF003A7A), Color(0xFF0075C9)],
              ),
            ),
            child: SingleChildScrollView(
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
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Puzzle Circle ──
                  AnimatedBuilder(
                    animation: allComplete
                        ? _celebrationController
                        : _pulseController,
                    builder: (context, child) {
                      final scale = allComplete
                          ? _celebrationScale.value
                          : 1.0;
                      final opacity = allComplete
                          ? _celebrationOpacity.value
                          : 1.0;

                      return Opacity(
                        opacity: opacity.clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: scale,
                          child: SizedBox(
                            width: 320,
                            height: 320,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer glow ring when complete
                                if (allComplete)
                                  Container(
                                    width: 300,
                                    height: 300,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFA6CE39)
                                              .withValues(alpha: 0.4),
                                          blurRadius: 30,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                  ),

                                // Center Logo
                                Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.35),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
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

                                // Puzzle Pieces
                                ...List.generate(pieces.length, (i) {
                                  final angle =
                                      (2 * pi * i / pieces.length) - pi / 2;
                                  const radius = 118.0;
                                  final x = radius * cos(angle);
                                  final y = radius * sin(angle);
                                  final category = pieces[i]["category"]!;
                                  final unlocked = progress
                                          ?.unlockedCategories
                                          .contains(category) ??
                                      false;

                                  return _buildPiece(
                                    x: x,
                                    y: y,
                                    icon: pieces[i]["icon"]!,
                                    label: pieces[i]["label"]!,
                                    unlocked: unlocked,
                                    index: i,
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // ── Progress ──
                  Text(
                    "$unlockedCount / 8 pieces unlocked",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: unlockedCount / 8,
                      backgroundColor: const Color(0xFF004A8D),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFA6CE39)),
                      minHeight: 10,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Spin Wheel or Status ──
                  if (allComplete && progress?.spinUsed != true) ...[
                    const Text(
                      "\u{1F389} Puzzle Complete! Spin to Win!",
                      style: TextStyle(
                        color: Color(0xFFA6CE39),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 20),

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

                    // Spin Button — gradient, full width, large
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
                          color: const Color(0xFFA6CE39).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "\u{1F3C6} Prize Won!",
                            style: TextStyle(
                              color: Color(0xFFA6CE39),
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
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
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            "\u{1F512}",
                            style: TextStyle(fontSize: 36),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Complete all 8 puzzle pieces to unlock the Spin to Win wheel!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.4,
                            ),
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

  Widget _buildPiece({
    required double x,
    required double y,
    required String icon,
    required String label,
    required bool unlocked,
    required int index,
  }) {
    final piece = Transform.translate(
      offset: Offset(x, y),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        width: unlocked ? 62 : 56,
        height: unlocked ? 72 : 66,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: unlocked ? 56 : 50,
              height: unlocked ? 56 : 50,
              decoration: BoxDecoration(
                color: unlocked
                    ? Colors.white
                    : const Color(0xFF002B5E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: unlocked
                      ? const Color(0xFFFFC107)
                      : Colors.white.withValues(alpha: 0.2),
                  width: unlocked ? 3 : 1,
                ),
                boxShadow: unlocked
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFC107)
                              .withValues(alpha: 0.6),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  icon,
                  style: TextStyle(
                    fontSize: unlocked ? 28 : 22,
                    color: unlocked ? null : Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.split(" ").first,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: unlocked
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );

    // Locked pieces get a subtle floating pulse animation
    if (!unlocked) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: child,
          );
        },
        child: piece,
      );
    }

    return piece;
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

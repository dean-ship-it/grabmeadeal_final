// lib/screens/puzzle_reward_screen.dart
//
// DOPAMINE MACHINE — Gambling psychology meets deal-hunting.
// Users NEVER lose. Every action = progress. Every piece = a rush.

import "dart:math";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:grabmeadeal_final/providers/puzzle_provider.dart";

// ── Vibrant piece colors — each category has a bold, distinct color ──
const _pieceColors = [
  Color(0xFF1565C0), // Electronics — electric blue
  Color(0xFF8D6E63), // Furniture — warm mocha
  Color(0xFF546E7A), // Tools — gunmetal
  Color(0xFF7B1FA2), // Gaming — vivid purple
  Color(0xFFD81B60), // Beauty — hot pink
  Color(0xFF43A047), // Pet Supplies — lush green
  Color(0xFFFF6F00), // Apparel — blazing orange
  Color(0xFFE53935), // Automotive — cherry red
];

const _lockedColor = Color(0xFF0D1B2A);

// ── Urgency messages — gets more intense as progress increases ──
const _urgencyMessages = <int, List<String>>{
  0: ["Start your puzzle journey!", "Every deal unlocks a piece \u{1F525}"],
  1: ["You're on the board!", "Keep the momentum going!"],
  2: ["2 down, 6 to go!", "You're building something big \u{1F4AA}"],
  3: ["Almost halfway!", "Don't stop now \u{1F525}\u{1F525}"],
  4: ["HALFWAY THERE!", "You can taste that prize \u{1F60B}"],
  5: ["Only 3 more pieces!", "The wheel is calling your name \u{1F3B0}"],
  6: ["SO CLOSE! Just 2 more!", "Your prize is waiting \u{1F4B0}\u{1F4B0}"],
  7: ["ONE. MORE. PIECE.", "This is YOUR moment \u{1F525}\u{1F525}\u{1F525}"],
  8: ["\u{1F389} PUZZLE COMPLETE!", "SPIN THAT WHEEL! \u{1F3B0}"],
};

class PuzzleRewardScreen extends StatefulWidget {
  const PuzzleRewardScreen({super.key});

  @override
  State<PuzzleRewardScreen> createState() => _PuzzleRewardScreenState();
}

class _PuzzleRewardScreenState extends State<PuzzleRewardScreen>
    with TickerProviderStateMixin {
  // Wheel spin
  late AnimationController _wheelController;
  late Animation<double> _wheelAnimation;

  // Shimmer on locked pieces
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  // Pulse glow on the ring
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Celebration bounce
  late AnimationController _celebrationController;
  late Animation<double> _celebrationScale;

  // Heartbeat for urgency text
  late AnimationController _heartbeatController;
  late Animation<double> _heartbeatAnimation;

  bool _spinning = false;
  int _landedSegment = 0;
  bool _celebrationPlayed = false;

  @override
  void initState() {
    super.initState();

    _wheelController = AnimationController(
        vsync: this, duration: const Duration(seconds: 4));
    _wheelAnimation = CurvedAnimation(
        parent: _wheelController, curve: Curves.easeOutCubic);

    _shimmerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat();
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
        CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut));

    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _celebrationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _celebrationScale = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(
            parent: _celebrationController, curve: Curves.elasticOut));

    _heartbeatController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _heartbeatAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(
            parent: _heartbeatController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _wheelController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _celebrationController.dispose();
    _heartbeatController.dispose();
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

    _landedSegment = Random().nextInt(8);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF0D1B2A),
        title: const Text(
          "\u{1F4B0} JACKPOT! \u{1F4B0}",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFFFFC107)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("YOU WON",
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 3)),
            const SizedBox(height: 8),
            Text(
              prize,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Verify your phone to claim \u{2192}",
                style: TextStyle(
                    color: Color(0xFFFFC107), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, "/prize-claim", arguments: prize);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("CLAIM MY PRIZE \u{1F3C6}",
                  style:
                      TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
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
        final msgs = _urgencyMessages[unlockedCount] ??
            _urgencyMessages[0]!;

        _checkCelebration(puzzle);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text("PUZZLE REWARDS",
                style: TextStyle(
                    fontWeight: FontWeight.w900, letterSpacing: 2)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
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
                colors: [
                  Color(0xFF0D1B2A),
                  Color(0xFF1B2838),
                  Color(0xFF0D1B2A),
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 40),
              child: Column(
                children: [
                  // ── Urgency Header — heartbeat pulse ──
                  AnimatedBuilder(
                    animation: _heartbeatAnimation,
                    builder: (context, _) {
                      final scale = unlockedCount >= 5
                          ? _heartbeatAnimation.value
                          : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: Column(
                          children: [
                            Text(
                              msgs[0],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: unlockedCount >= 6
                                    ? const Color(0xFFFFC107)
                                    : Colors.white,
                                fontSize: unlockedCount >= 6 ? 24 : 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: unlockedCount >= 7 ? 2 : 0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msgs[1],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: unlockedCount >= 5
                                    ? const Color(0xFFFFC107)
                                        .withValues(alpha: 0.8)
                                    : Colors.white54,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // ── Puzzle Ring ──
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _shimmerController,
                      _pulseController,
                      _celebrationController,
                    ]),
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
                              // Painted puzzle ring
                              CustomPaint(
                                size: const Size(320, 320),
                                painter: _PuzzleRingPainter(
                                  pieceCount: 8,
                                  unlockedSet: unlockedSet,
                                  categories: pieces
                                      .map((p) => p["category"]!)
                                      .toList(),
                                  colors: _pieceColors,
                                  shimmerValue: _shimmerAnimation.value,
                                  pulseValue: _pulseAnimation.value,
                                ),
                              ),

                              // Emoji + label overlays
                              ...List.generate(pieces.length, (i) {
                                final angle = (2 * pi * i / pieces.length) -
                                    pi / 2;
                                const r = 108.0;
                                final x = r * cos(angle);
                                final y = r * sin(angle);
                                final cat = pieces[i]["category"]!;
                                final unlocked = unlockedSet.contains(cat);

                                return Transform.translate(
                                  offset: Offset(x, y),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Emoji with optional glow
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: unlocked
                                            ? BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white
                                                    .withValues(alpha: 0.2),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: _pieceColors[i]
                                                        .withValues(
                                                            alpha: 0.6),
                                                    blurRadius: 12,
                                                  ),
                                                ],
                                              )
                                            : null,
                                        child: Center(
                                          child: Text(
                                            pieces[i]["icon"]!,
                                            style: TextStyle(
                                              fontSize:
                                                  unlocked ? 28 : 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        pieces[i]["label"]!
                                            .split(" ")
                                            .first,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: unlocked
                                              ? Colors.white
                                              : Colors.white.withValues(
                                                  alpha: 0.3),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),

                              // Center logo with pulsing glow
                              Container(
                                width: 82,
                                height: 82,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: allComplete
                                          ? Color.lerp(
                                              const Color(0xFFFFC107),
                                              const Color(0xFFFF6F00),
                                              _pulseAnimation.value)!
                                          : const Color(0xFF0075C9)
                                              .withValues(alpha: 0.4 +
                                                  _pulseAnimation.value *
                                                      0.3),
                                      blurRadius: allComplete
                                          ? 24 +
                                              _pulseAnimation.value * 12
                                          : 12,
                                      spreadRadius:
                                          allComplete ? 4 : 0,
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
                                        child: Text("GMD",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                                color:
                                                    Color(0xFF0075C9))),
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

                  const SizedBox(height: 24),

                  // ── Progress Bar — casino-style ──
                  _buildProgressBar(unlockedCount),

                  const SizedBox(height: 32),

                  // ── Milestone Badges ──
                  _buildMilestoneBadges(unlockedCount),

                  const SizedBox(height: 28),

                  // ── Spin or Status ──
                  if (allComplete &&
                      progress?.spinUsed != true) ...[
                    _buildSpinSection(),
                  ] else if (progress?.spinUsed == true) ...[
                    _buildPrizeWonSection(progress?.prizeWon ?? ""),
                  ] else ...[
                    _buildLockedSection(unlockedCount),
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

  // ── Progress Bar ──────────────────────────────────────────────────────────

  Widget _buildProgressBar(int count) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("$count / 8",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900)),
            Text(
              count == 8
                  ? "COMPLETE!"
                  : "${((count / 8) * 100).round()}%",
              style: TextStyle(
                color: count >= 6
                    ? const Color(0xFFFFC107)
                    : Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            // Background
            Container(
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF1A2744),
                borderRadius: BorderRadius.circular(7),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            // Fill with animated gradient
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              height: 14,
              width: (MediaQuery.of(context).size.width - 32) *
                  (count / 8).clamp(0.0, 1.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: count >= 6
                      ? [const Color(0xFFFFC107), const Color(0xFFFF6F00)]
                      : [const Color(0xFFA6CE39), const Color(0xFF7A9A01)],
                ),
                borderRadius: BorderRadius.circular(7),
                boxShadow: [
                  BoxShadow(
                    color: (count >= 6
                            ? const Color(0xFFFFC107)
                            : const Color(0xFFA6CE39))
                        .withValues(alpha: 0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Milestone Badges ──────────────────────────────────────────────────────

  Widget _buildMilestoneBadges(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _badge("STARTED", 1, count),
        _badge("HALFWAY", 4, count),
        _badge("ALMOST", 6, count),
        _badge("WINNER!", 8, count),
      ],
    );
  }

  Widget _badge(String label, int threshold, int current) {
    final achieved = current >= threshold;
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: achieved
                ? const Color(0xFFFFC107)
                : const Color(0xFF1A2744),
            border: Border.all(
              color: achieved
                  ? const Color(0xFFFFC107)
                  : Colors.white.withValues(alpha: 0.15),
              width: 2,
            ),
            boxShadow: achieved
                ? [
                    BoxShadow(
                      color: const Color(0xFFFFC107)
                          .withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: achieved
                ? const Icon(Icons.check, color: Colors.black, size: 20)
                : Text("$threshold",
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: achieved ? const Color(0xFFFFC107) : Colors.white30,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ── Spin Section ──────────────────────────────────────────────────────────

  Widget _buildSpinSection() {
    return Column(
      children: [
        // Wheel
        SizedBox(
          width: 280,
          height: 280,
          child: AnimatedBuilder(
            animation: _wheelAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _wheelAnimation.value *
                    (2 * pi * 5 + _landedSegment * (2 * pi / 8)),
                child: CustomPaint(
                  size: const Size(280, 280),
                  painter:
                      _WheelPainter(segments: PuzzleProvider.wheelSegments),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // SPIN button — pulsing, dangerous
        AnimatedBuilder(
          animation: _heartbeatAnimation,
          builder: (context, _) {
            return Transform.scale(
              scale: _spinning ? 1.0 : _heartbeatAnimation.value,
              child: SizedBox(
                width: double.infinity,
                height: 68,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFC107), Color(0xFFFF6F00)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFC107)
                            .withValues(alpha: 0.6),
                        blurRadius: 16,
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
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      _spinning
                          ? "SPINNING..."
                          : "\u{1F3B0} SPIN TO WIN! \u{1F3B0}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 12),
        Text(
          "Prizes: \$100 \u2022 \$150 \u2022 \$200 \u2022 \$300 \u2022 \$500 Gift Cards",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ── Prize Won ─────────────────────────────────────────────────────────────

  Widget _buildPrizeWonSection(String prize) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2744), Color(0xFF0D1B2A)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFC107).withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC107).withValues(alpha: 0.15),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text("\u{1F3C6}",
              style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          const Text("PRIZE CLAIMED",
              style: TextStyle(
                  color: Color(0xFFFFC107),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3)),
          const SizedBox(height: 8),
          Text(prize,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  // ── Locked Section ────────────────────────────────────────────────────────

  Widget _buildLockedSection(int count) {
    final remaining = 8 - count;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2744).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: count >= 5
              ? const Color(0xFFFFC107).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, _) {
              return Transform.scale(
                scale: 1.0 + _pulseAnimation.value * 0.05,
                child: const Text("\u{1F512}",
                    style: TextStyle(fontSize: 40)),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            remaining == 1
                ? "JUST 1 MORE PIECE!"
                : "$remaining pieces to go",
            style: TextStyle(
              color: count >= 5
                  ? const Color(0xFFFFC107)
                  : Colors.white,
              fontSize: count >= 5 ? 20 : 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Browse deals to unlock puzzle pieces.\nEvery category you shop = 1 piece closer to winning!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (count >= 4) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: count >= 6
                        ? const Color(0xFFFFC107)
                        : const Color(0xFFA6CE39),
                  ),
                  foregroundColor: count >= 6
                      ? const Color(0xFFFFC107)
                      : const Color(0xFFA6CE39),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  "BROWSE DEALS NOW \u{2192}",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: count >= 6 ? 16 : 14,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Puzzle Ring Painter ──────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────

class _PuzzleRingPainter extends CustomPainter {
  final int pieceCount;
  final Set<String> unlockedSet;
  final List<String> categories;
  final List<Color> colors;
  final double shimmerValue;
  final double pulseValue;

  const _PuzzleRingPainter({
    required this.pieceCount,
    required this.unlockedSet,
    required this.categories,
    required this.colors,
    required this.shimmerValue,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 12;
    final innerRadius = outerRadius * 0.40;
    final sweepAngle = 2 * pi / pieceCount;
    final gap = 0.05;

    for (int i = 0; i < pieceCount; i++) {
      final startAngle = (2 * pi * i / pieceCount) - pi / 2 + gap / 2;
      final sweep = sweepAngle - gap;
      final unlocked = unlockedSet.contains(categories[i]);

      // Build wedge path
      final path = Path();
      path.arcTo(
        Rect.fromCircle(center: center, radius: outerRadius),
        startAngle,
        sweep,
        true,
      );
      final innerEndAngle = startAngle + sweep;
      path.lineTo(
        center.dx + innerRadius * cos(innerEndAngle),
        center.dy + innerRadius * sin(innerEndAngle),
      );
      path.arcTo(
        Rect.fromCircle(center: center, radius: innerRadius),
        innerEndAngle,
        -sweep,
        false,
      );
      path.close();

      // Shadow
      if (unlocked) {
        canvas.drawShadow(path, colors[i], 10, false);
      }

      // Fill
      final paint = Paint()..style = PaintingStyle.fill;
      if (unlocked) {
        paint.shader = SweepGradient(
          center: Alignment.center,
          startAngle: startAngle,
          endAngle: startAngle + sweep,
          colors: [
            colors[i],
            Color.lerp(colors[i], Colors.white, 0.2)!,
            colors[i],
          ],
        ).createShader(
            Rect.fromCircle(center: center, radius: outerRadius));
      } else {
        // Locked with shimmer
        final shimmerPos = shimmerValue;
        final angleFraction = i / pieceCount;
        final shimmerHit =
            (shimmerPos - angleFraction).abs() < 0.3;

        paint.color = shimmerHit
            ? Color.lerp(_lockedColor, const Color(0xFF2A3D5E),
                (0.3 - (shimmerPos - angleFraction).abs()) / 0.3 * 0.6)!
            : _lockedColor.withValues(
                alpha: 0.5 + pulseValue * 0.15);
      }
      canvas.drawPath(path, paint);

      // Border
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = unlocked ? 2.5 : 1.0
        ..color = unlocked
            ? Colors.white.withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.08 + pulseValue * 0.05);
      canvas.drawPath(path, borderPaint);

      // Jigsaw tab nubs
      final midAngle = startAngle + sweep / 2;
      final tabR = 8.0;

      // Outer nub
      final outerNub = Offset(
        center.dx + (outerRadius + tabR * 0.3) * cos(midAngle),
        center.dy + (outerRadius + tabR * 0.3) * sin(midAngle),
      );
      canvas.drawCircle(
          outerNub,
          tabR,
          Paint()
            ..color =
                unlocked ? colors[i] : _lockedColor.withValues(alpha: 0.7)
            ..style = PaintingStyle.fill);
      canvas.drawCircle(
          outerNub,
          tabR,
          Paint()
            ..color = unlocked
                ? Colors.white.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.08)
            ..style = PaintingStyle.stroke
            ..strokeWidth = unlocked ? 2.0 : 0.8);

      // Inner nub
      final innerNub = Offset(
        center.dx + (innerRadius - tabR * 0.25) * cos(midAngle),
        center.dy + (innerRadius - tabR * 0.25) * sin(midAngle),
      );
      canvas.drawCircle(
          innerNub,
          tabR * 0.65,
          Paint()
            ..color =
                unlocked ? colors[i] : _lockedColor.withValues(alpha: 0.7)
            ..style = PaintingStyle.fill);
      canvas.drawCircle(
          innerNub,
          tabR * 0.65,
          Paint()
            ..color = unlocked
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.08)
            ..style = PaintingStyle.stroke
            ..strokeWidth = unlocked ? 1.5 : 0.5);
    }
  }

  @override
  bool shouldRepaint(covariant _PuzzleRingPainter old) =>
      old.unlockedSet != unlockedSet ||
      old.shimmerValue != shimmerValue ||
      old.pulseValue != pulseValue;
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
    final tp = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < segments.length; i++) {
      final start = i * segmentAngle - pi / 2;
      canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          start,
          segmentAngle,
          true,
          Paint()
            ..color = Color(segments[i]["color"] as int)
            ..style = PaintingStyle.fill);
      canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          start,
          segmentAngle,
          true,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(start + segmentAngle / 2);
      canvas.translate(radius * 0.6, 0);
      tp.text = TextSpan(
          text: segments[i]["label"] as String,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700));
      tp.layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
    canvas.drawCircle(center, 24, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

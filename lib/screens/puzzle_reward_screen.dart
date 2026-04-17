// lib/screens/puzzle_reward_screen.dart
//
// DOPAMINE MACHINE v3 — Real interlocking jigsaw pieces forming a circle.
// Each piece = a category. Locked = empty slot. Unlocked = snapped in.
// "Like gambling, but you NEVER lose."

import "dart:math";
import "dart:ui" as ui;
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:grabmeadeal_final/providers/puzzle_provider.dart";

// ── 8 vibrant piece colors ──
const _pieceColors = [
  Color(0xFF1565C0), // Electronics
  Color(0xFF6D4C41), // Furniture
  Color(0xFF455A64), // Tools
  Color(0xFF7B1FA2), // Gaming
  Color(0xFFD81B60), // Beauty
  Color(0xFF2E7D32), // Pet Supplies
  Color(0xFFEF6C00), // Apparel
  Color(0xFFC62828), // Automotive
];

// ── Urgency messages — escalate with progress ──
const _msgs = <int, List<String>>{
  0: ["Your puzzle awaits!", "Shop deals to unlock pieces"],
  1: ["Nice start!", "7 more pieces to your prize \u{1F3AF}"],
  2: ["Momentum building!", "Keep shopping \u{1F525}"],
  3: ["Almost halfway!", "You're on a streak \u{1F4AA}"],
  4: ["HALFWAY THERE!", "The prize is calling \u{1F60B}"],
  5: ["3 more pieces!", "So close you can feel it \u{1F525}\u{1F525}"],
  6: ["JUST 2 MORE!", "Don't stop now \u{1F4B0}"],
  7: ["ONE. MORE. PIECE.", "THIS IS YOUR MOMENT \u{1F525}\u{1F525}\u{1F525}"],
  8: ["PUZZLE COMPLETE!", "SPIN THE WHEEL! \u{1F3B0}"],
};

// ── DEMO MODE: set true to see fireworks, set false for production ──
const _kDemoMode = true;

class PuzzleRewardScreen extends StatefulWidget {
  const PuzzleRewardScreen({super.key});
  @override
  State<PuzzleRewardScreen> createState() => _PuzzleRewardScreenState();
}

class _PuzzleRewardScreenState extends State<PuzzleRewardScreen>
    with TickerProviderStateMixin {
  late AnimationController _wheelCtrl;
  late Animation<double> _wheelAnim;
  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _heartCtrl;
  late Animation<double> _heartAnim;
  late AnimationController _celebCtrl;
  late Animation<double> _celebScale;

  // Fireworks particle system
  late AnimationController _fireworksCtrl;
  final List<_Particle> _particles = [];
  final _rng = Random();

  bool _spinning = false;
  int _landedSeg = 0;
  bool _celebPlayed = false;
  bool _showFireworks = false;

  @override
  void initState() {
    super.initState();
    _wheelCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _wheelAnim = CurvedAnimation(parent: _wheelCtrl, curve: Curves.easeOutCubic);

    _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();
    _shimmerAnim = Tween<double>(begin: -0.5, end: 1.5).animate(
        CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _heartCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
    _heartAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
        CurvedAnimation(parent: _heartCtrl, curve: Curves.easeInOut));

    _celebCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _celebScale = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _celebCtrl, curve: Curves.elasticOut));

    _fireworksCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 4000));
    _fireworksCtrl.addListener(_updateParticles);
  }

  @override
  void dispose() {
    _wheelCtrl.dispose();
    _shimmerCtrl.dispose();
    _pulseCtrl.dispose();
    _heartCtrl.dispose();
    _celebCtrl.dispose();
    _fireworksCtrl.dispose();
    super.dispose();
  }

  void _maybeCelebrate(bool canSpin) {
    if (!_celebPlayed && canSpin) {
      _celebPlayed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _celebCtrl.forward();
        _launchFireworks();
      });
    }
  }

  // ── TEXAS FIREWORKS SYSTEM ──────────────────────────────────────────────

  static const _fireworkColors = [
    Color(0xFFFFC107), // gold
    Color(0xFFFF6F00), // amber
    Color(0xFFA6CE39), // lime
    Color(0xFFD81B60), // hot pink
    Color(0xFF42A5F5), // sky blue
    Color(0xFFFFFFFF), // white
    Color(0xFFFF5252), // red
    Color(0xFF7C4DFF), // purple
    Color(0xFF00E676), // neon green
    Color(0xFFFFD740), // bright gold
  ];

  void _launchFireworks() {
    setState(() => _showFireworks = true);
    _particles.clear();

    // Wave 1 — center burst (immediate)
    _spawnBurst(0.5, 0.45, 80, 6.0);

    // Wave 2 — left burst (delayed via velocity timing)
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _spawnBurst(0.3, 0.35, 60, 5.0);
    });

    // Wave 3 — right burst (delayed)
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _spawnBurst(0.7, 0.3, 60, 5.0);
    });

    // Wave 4 — big center finale
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) _spawnBurst(0.5, 0.4, 120, 7.0);
    });

    // Wave 5 — confetti rain from top
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _spawnConfetti(100);
    });

    _fireworksCtrl.reset();
    _fireworksCtrl.forward();

    // Clean up after show
    Future.delayed(const Duration(milliseconds: 4200), () {
      if (mounted) setState(() => _showFireworks = false);
    });
  }

  void _spawnBurst(double cx, double cy, int count, double speed) {
    for (int i = 0; i < count; i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      final v = (0.3 + _rng.nextDouble() * 0.7) * speed;
      _particles.add(_Particle(
        x: cx, y: cy,
        vx: cos(angle) * v * (0.8 + _rng.nextDouble() * 0.4),
        vy: sin(angle) * v * (0.8 + _rng.nextDouble() * 0.4),
        color: _fireworkColors[_rng.nextInt(_fireworkColors.length)],
        life: 0.6 + _rng.nextDouble() * 0.4,
        size: 2.0 + _rng.nextDouble() * 4.0,
        type: _rng.nextInt(3), // 0=circle, 1=star, 2=streak
      ));
    }
  }

  void _spawnConfetti(int count) {
    for (int i = 0; i < count; i++) {
      _particles.add(_Particle(
        x: _rng.nextDouble(),
        y: -0.05 - _rng.nextDouble() * 0.1,
        vx: (_rng.nextDouble() - 0.5) * 1.5,
        vy: 2.0 + _rng.nextDouble() * 3.0,
        color: _fireworkColors[_rng.nextInt(_fireworkColors.length)],
        life: 0.7 + _rng.nextDouble() * 0.3,
        size: 3.0 + _rng.nextDouble() * 5.0,
        type: 3, // confetti
      ));
    }
  }

  void _updateParticles() {
    if (!mounted) return;
    final dt = 0.016; // ~60fps
    for (final p in _particles) {
      p.x += p.vx * dt * 0.08;
      p.y += p.vy * dt * 0.08;
      p.vy += 0.8 * dt; // gravity
      p.vx *= 0.99; // drag
      p.life -= dt * 0.6;
    }
    _particles.removeWhere((p) => p.life <= 0);
    setState(() {});
  }

  Future<void> _spin() async {
    if (_spinning) return;
    setState(() => _spinning = true);
    _landedSeg = Random().nextInt(8);
    _wheelCtrl.reset();
    await _wheelCtrl.animateTo(1.0);
    if (!mounted) return;
    final prize = await context.read<PuzzleProvider>().recordSpin(_landedSeg);
    if (!mounted) return;
    setState(() => _spinning = false);
    _showWin(prize);
  }

  void _showWin(String prize) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF0D1B2A),
        title: const Text("\u{1F4B0} JACKPOT! \u{1F4B0}",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFFFFC107))),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("YOU WON", style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 4)),
          const SizedBox(height: 8),
          Text(prize, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8)),
            child: const Text("Verify phone to claim \u{2192}",
                style: TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.w600)),
          ),
        ]),
        actions: [
          SizedBox(
            width: double.infinity, height: 54,
            child: FilledButton(
              onPressed: () { Navigator.pop(ctx); Navigator.pushNamed(context, "/prize-claim", arguments: prize); },
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFFC107), foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text("CLAIM MY PRIZE \u{1F3C6}", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PuzzleProvider>(builder: (context, puzzle, _) {
      final progress = puzzle.progress;
      final pieces = PuzzleProvider.pieces;

      // Demo mode overrides
      final Set<String> unlocked;
      final int n;
      final bool complete;
      if (_kDemoMode) {
        unlocked = {"electronics", "furniture", "tools", "gaming",
                     "beauty", "petSupplies", "apparel", "automotive"};
        n = 8;
        complete = true;
      } else {
        unlocked = progress?.unlockedCategories ?? {};
        n = progress?.unlockedCategories.length ?? 0;
        complete = progress?.canSpin == true;
      }

      final m = _msgs[n] ?? _msgs[0]!;
      _maybeCelebrate(complete);

      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text("PUZZLE REWARDS", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
          centerTitle: true, backgroundColor: Colors.transparent, foregroundColor: Colors.white, elevation: 0,
        ),
        body: Stack(children: [
          // Main content
          Container(
          decoration: const BoxDecoration(gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1628), Color(0xFF162A4A), Color(0xFF0A1628)])),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              child: Column(children: [
                // ── Urgency Header ──
                AnimatedBuilder(animation: _heartAnim, builder: (_, __) {
                  return Transform.scale(scale: n >= 5 ? _heartAnim.value : 1.0,
                    child: Column(children: [
                      Text(m[0], textAlign: TextAlign.center, style: TextStyle(
                        color: n >= 6 ? const Color(0xFFFFC107) : Colors.white,
                        fontSize: n >= 7 ? 26 : n >= 4 ? 22 : 18,
                        fontWeight: FontWeight.w900, letterSpacing: n >= 7 ? 2 : 0)),
                      const SizedBox(height: 4),
                      Text(m[1], textAlign: TextAlign.center, style: TextStyle(
                        color: n >= 5 ? const Color(0xFFFFC107).withValues(alpha: 0.7) : Colors.white38,
                        fontSize: 13)),
                    ]));
                }),

                const SizedBox(height: 24),

                // ── PUZZLE CIRCLE ──
                AnimatedBuilder(
                  animation: Listenable.merge([_shimmerCtrl, _pulseCtrl, _celebCtrl]),
                  builder: (_, __) {
                    final sc = complete ? _celebScale.value : 1.0;
                    return Transform.scale(scale: sc, child: SizedBox(
                      width: 310, height: 310,
                      child: Stack(alignment: Alignment.center, children: [
                        // The jigsaw ring
                        CustomPaint(size: const Size(310, 310), painter: _JigsawRingPainter(
                          count: 8, unlocked: unlocked,
                          cats: pieces.map((p) => p["category"]!).toList(),
                          labels: pieces.map((p) => p["label"]!.split(" ").first).toList(),
                          icons: pieces.map((p) => p["icon"]!).toList(),
                          colors: _pieceColors,
                          shimmer: _shimmerAnim.value,
                          pulse: _pulseAnim.value,
                          allDone: complete,
                        )),
                        // Center logo — clean, polished
                        Container(
                          width: 86, height: 86,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: complete ? const Color(0xFFFFC107) : const Color(0xFF0075C9).withValues(alpha: 0.5),
                              width: complete ? 3 : 2),
                            boxShadow: [
                              // Inner depth shadow
                              BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3)),
                              // Outer glow
                              BoxShadow(
                                color: complete
                                    ? Color.lerp(const Color(0xFFFFC107), const Color(0xFFFF6F00), _pulseAnim.value)!.withValues(alpha: 0.6)
                                    : const Color(0xFF0075C9).withValues(alpha: 0.2 + _pulseAnim.value * 0.2),
                                blurRadius: complete ? 20 + _pulseAnim.value * 10 : 10,
                                spreadRadius: complete ? 4 : 0),
                            ],
                          ),
                          child: ClipOval(child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Image.asset("assets/logo/logo.png", fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Center(child: Text("GMD",
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0075C9))))),
                          )),
                        ),
                      ]),
                    ));
                  },
                ),

                const SizedBox(height: 20),

                // ── Progress ──
                _progressBar(n, context),

                const SizedBox(height: 20),

                // ── Milestones ──
                _milestones(n),

                const SizedBox(height: 28),

                // ── Spin / Status ──
                if (complete && (_kDemoMode || progress?.spinUsed != true)) _spinSection()
                else if (!_kDemoMode && progress?.spinUsed == true) _wonSection(progress?.prizeWon ?? "")
                else if (!complete) _lockedSection(n),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ),

          // ── FIREWORKS OVERLAY ──
          if (_showFireworks)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _FireworksPainter(particles: _particles),
                ),
              ),
            ),

          // ── SCREEN FLASH on celebration ──
          if (_showFireworks && _celebCtrl.value < 0.3)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _celebCtrl.value < 0.15 ? 0.7 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(color: Colors.white),
                ),
              ),
            ),
        ]),
      );
    });
  }

  Widget _progressBar(int n, BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width - 40;
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text("$n / 8 PIECES", style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1)),
        Text(n == 8 ? "COMPLETE!" : "${(n / 8 * 100).round()}%",
            style: TextStyle(color: n >= 6 ? const Color(0xFFFFC107) : Colors.white38, fontSize: 13, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 8),
      Stack(children: [
        Container(height: 12, decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A), borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)))),
        AnimatedContainer(duration: const Duration(milliseconds: 500), curve: Curves.easeOut,
          height: 12, width: w * (n / 8).clamp(0.0, 1.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: n >= 6
                ? [const Color(0xFFFFC107), const Color(0xFFFF6F00)]
                : [const Color(0xFFA6CE39), const Color(0xFF7A9A01)]),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [BoxShadow(color: (n >= 6 ? const Color(0xFFFFC107) : const Color(0xFFA6CE39)).withValues(alpha: 0.5), blurRadius: 8)])),
      ]),
    ]);
  }

  Widget _milestones(int n) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _badge("START", 1, n), _badge("HALF", 4, n), _badge("CLOSE", 6, n), _badge("WIN!", 8, n),
    ]);
  }

  Widget _badge(String label, int th, int cur) {
    final ok = cur >= th;
    return Column(children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(
        shape: BoxShape.circle, color: ok ? const Color(0xFFFFC107) : const Color(0xFF0D1B2A),
        border: Border.all(color: ok ? const Color(0xFFFFC107) : Colors.white.withValues(alpha: 0.1), width: 2),
        boxShadow: ok ? [BoxShadow(color: const Color(0xFFFFC107).withValues(alpha: 0.4), blurRadius: 8)] : []),
        child: Center(child: ok ? const Icon(Icons.check, color: Colors.black, size: 18)
            : Text("$th", style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 11, fontWeight: FontWeight.w700)))),
      const SizedBox(height: 3),
      Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700,
          color: ok ? const Color(0xFFFFC107) : Colors.white24, letterSpacing: 0.5)),
    ]);
  }

  Widget _spinSection() {
    return Column(children: [
      SizedBox(width: 270, height: 270, child: AnimatedBuilder(animation: _wheelAnim, builder: (_, __) {
        return Transform.rotate(angle: _wheelAnim.value * (2 * pi * 5 + _landedSeg * (2 * pi / 8)),
          child: CustomPaint(size: const Size(270, 270), painter: _WheelPainter(segments: PuzzleProvider.wheelSegments)));
      })),
      const SizedBox(height: 20),
      AnimatedBuilder(animation: _heartAnim, builder: (_, __) {
        return Transform.scale(scale: _spinning ? 1.0 : _heartAnim.value,
          child: SizedBox(width: double.infinity, height: 64,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF6F00)]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: const Color(0xFFFFC107).withValues(alpha: 0.5), blurRadius: 14, offset: const Offset(0, 4))]),
              child: ElevatedButton(
                onPressed: _spinning ? null : _spin,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                    foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                child: Text(_spinning ? "SPINNING..." : "\u{1F3B0} SPIN TO WIN! \u{1F3B0}",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
          ),
        );
      }),
      const SizedBox(height: 10),
      Text("Prizes: \$100 \u2022 \$150 \u2022 \$200 \u2022 \$300 \u2022 \$500",
          style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
    ]);
  }

  Widget _wonSection(String prize) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A2744), Color(0xFF0D1B2A)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.3), width: 2),
        boxShadow: [BoxShadow(color: const Color(0xFFFFC107).withValues(alpha: 0.12), blurRadius: 20)]),
      child: Column(children: [
        const Text("\u{1F3C6}", style: TextStyle(fontSize: 44)),
        const SizedBox(height: 6),
        const Text("PRIZE CLAIMED", style: TextStyle(color: Color(0xFFFFC107), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 3)),
        const SizedBox(height: 8),
        Text(prize, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
      ]),
    );
  }

  Widget _lockedSection(int n) {
    final rem = 8 - n;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: n >= 5 ? const Color(0xFFFFC107).withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.06))),
      child: Column(children: [
        AnimatedBuilder(animation: _pulseAnim, builder: (_, __) {
          return Transform.scale(scale: 1.0 + _pulseAnim.value * 0.04,
              child: const Text("\u{1F512}", style: TextStyle(fontSize: 36)));
        }),
        const SizedBox(height: 10),
        Text(rem == 1 ? "JUST 1 MORE PIECE!" : "$rem pieces to go",
            style: TextStyle(color: n >= 5 ? const Color(0xFFFFC107) : Colors.white, fontSize: n >= 5 ? 20 : 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text("Browse deals to unlock pieces.\nEvery category = 1 piece closer to winning!",
            textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12, height: 1.5)),
        if (n >= 3) ...[
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 46,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: n >= 6 ? const Color(0xFFFFC107) : const Color(0xFFA6CE39)),
                foregroundColor: n >= 6 ? const Color(0xFFFFC107) : const Color(0xFFA6CE39),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text("BROWSE DEALS NOW \u{2192}", style: TextStyle(fontWeight: FontWeight.w800, fontSize: n >= 6 ? 15 : 13)),
            ),
          ),
        ],
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// JIGSAW RING PAINTER — Draws 8 interlocking wedge pieces with tabs/notches
// ─────────────────────────────────────────────────────────────────────────────

class _JigsawRingPainter extends CustomPainter {
  final int count;
  final Set<String> unlocked;
  final List<String> cats, labels, icons;
  final List<Color> colors;
  final double shimmer, pulse;
  final bool allDone;

  const _JigsawRingPainter({
    required this.count, required this.unlocked, required this.cats,
    required this.labels, required this.icons, required this.colors,
    required this.shimmer, required this.pulse, required this.allDone,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);
    final outerR = size.width / 2 - 10;
    final innerR = outerR * 0.38;
    final sweep = 2 * pi / count;
    final gap = 0.045;
    final tabSize = 9.0;

    for (int i = 0; i < count; i++) {
      final sa = (2 * pi * i / count) - pi / 2 + gap / 2;
      final sw = sweep - gap;
      final isOpen = unlocked.contains(cats[i]);

      // Build wedge path with jigsaw tabs
      final path = _buildWedgePath(center, outerR, innerR, sa, sw, tabSize, i);

      if (isOpen) {
        // ── UNLOCKED: vibrant filled piece ──
        canvas.drawShadow(path, colors[i].withValues(alpha: 0.8), 8, false);

        // Gradient fill
        final paint = Paint()..style = PaintingStyle.fill;
        paint.shader = ui.Gradient.sweep(
          center,
          [colors[i], Color.lerp(colors[i], Colors.white, 0.15)!, colors[i]],
          [0.0, 0.5, 1.0],
          TileMode.clamp,
          sa, sa + sw,
        );
        canvas.drawPath(path, paint);

        // White border
        canvas.drawPath(path, Paint()
          ..style = PaintingStyle.stroke..strokeWidth = 2.5
          ..color = Colors.white.withValues(alpha: 0.8));

        // Category label on the piece
        _drawLabel(canvas, center, outerR, innerR, sa, sw, labels[i], true);
        // Emoji on the piece
        _drawEmoji(canvas, center, outerR, innerR, sa, sw, icons[i], true);
      } else {
        // ── LOCKED: empty slot with shimmer ──
        final shimDist = (shimmer - i / count).abs();
        final shimFactor = shimDist < 0.35 ? (0.35 - shimDist) / 0.35 : 0.0;

        // Ghost fill
        canvas.drawPath(path, Paint()
          ..style = PaintingStyle.fill
          ..color = Color.lerp(
              const Color(0xFF0D1B2A).withValues(alpha: 0.4 + pulse * 0.1),
              const Color(0xFF1E3A5F),
              shimFactor * 0.5)!);

        // Dashed-style border (solid but faint)
        canvas.drawPath(path, Paint()
          ..style = PaintingStyle.stroke..strokeWidth = 1.2
          ..color = Colors.white.withValues(alpha: 0.06 + shimFactor * 0.12 + pulse * 0.03));

        // Ghost label
        _drawLabel(canvas, center, outerR, innerR, sa, sw, labels[i], false);
        // Ghost emoji
        _drawEmoji(canvas, center, outerR, innerR, sa, sw, icons[i], false);
      }
    }
  }

  Path _buildWedgePath(Offset c, double oR, double iR, double sa, double sw, double tab, int idx) {
    final path = Path();
    final midAngle = sa + sw / 2;

    // Outer arc — with a tab bump at the midpoint
    path.arcTo(Rect.fromCircle(center: c, radius: oR), sa, sw / 2 - 0.06, true);
    // Tab outward
    final tabOut = Offset(c.dx + (oR + tab * 0.5) * cos(midAngle), c.dy + (oR + tab * 0.5) * sin(midAngle));
    final preTab = Offset(c.dx + oR * cos(midAngle - 0.04), c.dy + oR * sin(midAngle - 0.04));
    final postTab = Offset(c.dx + oR * cos(midAngle + 0.04), c.dy + oR * sin(midAngle + 0.04));
    path.quadraticBezierTo(preTab.dx, preTab.dy, tabOut.dx, tabOut.dy);
    path.quadraticBezierTo(postTab.dx, postTab.dy,
        c.dx + oR * cos(sa + sw / 2 + 0.06), c.dy + oR * sin(sa + sw / 2 + 0.06));
    // Rest of outer arc
    path.arcTo(Rect.fromCircle(center: c, radius: oR), sa + sw / 2 + 0.06, sw / 2 - 0.06, false);

    // Line to inner arc end
    final ie = sa + sw;
    path.lineTo(c.dx + iR * cos(ie), c.dy + iR * sin(ie));

    // Inner arc — with notch inward at midpoint
    path.arcTo(Rect.fromCircle(center: c, radius: iR), ie, -(sw / 2 - 0.06), false);
    // Notch inward
    final notchIn = Offset(c.dx + (iR - tab * 0.4) * cos(midAngle), c.dy + (iR - tab * 0.4) * sin(midAngle));
    final preNotch = Offset(c.dx + iR * cos(midAngle + 0.04), c.dy + iR * sin(midAngle + 0.04));
    final postNotch = Offset(c.dx + iR * cos(midAngle - 0.04), c.dy + iR * sin(midAngle - 0.04));
    path.quadraticBezierTo(preNotch.dx, preNotch.dy, notchIn.dx, notchIn.dy);
    path.quadraticBezierTo(postNotch.dx, postNotch.dy,
        c.dx + iR * cos(sa + sw / 2 - 0.06), c.dy + iR * sin(sa + sw / 2 - 0.06));
    path.arcTo(Rect.fromCircle(center: c, radius: iR), sa + sw / 2 - 0.06, -(sw / 2 - 0.06), false);

    path.close();
    return path;
  }

  void _drawLabel(Canvas canvas, Offset c, double oR, double iR, double sa, double sw, String label, bool lit) {
    final midA = sa + sw / 2;
    final labelR = (oR + iR) / 2 + 12;
    final pos = Offset(c.dx + labelR * cos(midA), c.dy + labelR * sin(midA));

    final tp = TextPainter(
      text: TextSpan(text: label, style: TextStyle(
        fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5,
        color: lit ? Colors.white : Colors.white.withValues(alpha: 0.2))),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  void _drawEmoji(Canvas canvas, Offset c, double oR, double iR, double sa, double sw, String emoji, bool lit) {
    final midA = sa + sw / 2;
    final emojiR = (oR + iR) / 2 - 8;
    final pos = Offset(c.dx + emojiR * cos(midA), c.dy + emojiR * sin(midA));

    final tp = TextPainter(
      text: TextSpan(text: emoji, style: TextStyle(fontSize: lit ? 24 : 18)),
      textDirection: TextDirection.ltr,
    )..layout();
    if (!lit) {
      canvas.saveLayer(Rect.fromCenter(center: pos, width: 40, height: 40), Paint()..colorFilter = const ColorFilter.mode(Color(0xFF1A2744), BlendMode.saturation));
    }
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    if (!lit) canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _JigsawRingPainter old) =>
      old.unlocked != unlocked || old.shimmer != shimmer || old.pulse != pulse;
}

// ─────────────────────────────────────────────────────────────────────────────
// PARTICLE — single firework/confetti particle
// ─────────────────────────────────────────────────────────────────────────────

class _Particle {
  double x, y, vx, vy, life, size;
  final Color color;
  final int type; // 0=circle, 1=star, 2=streak, 3=confetti

  _Particle({
    required this.x, required this.y,
    required this.vx, required this.vy,
    required this.color, required this.life,
    required this.size, required this.type,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// FIREWORKS PAINTER — renders all particles
// ─────────────────────────────────────────────────────────────────────────────

class _FireworksPainter extends CustomPainter {
  final List<_Particle> particles;
  const _FireworksPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final px = p.x * size.width;
      final py = p.y * size.height;
      final alpha = (p.life).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      switch (p.type) {
        case 0: // Circle spark
          canvas.drawCircle(Offset(px, py), p.size * alpha, paint);
          // Glow
          canvas.drawCircle(Offset(px, py), p.size * alpha * 2,
              Paint()..color = p.color.withValues(alpha: alpha * 0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
          break;
        case 1: // Star — draw a small cross
          final s = p.size * alpha;
          paint.strokeWidth = 1.5;
          paint.style = PaintingStyle.stroke;
          canvas.drawLine(Offset(px - s, py), Offset(px + s, py), paint);
          canvas.drawLine(Offset(px, py - s), Offset(px, py + s), paint);
          canvas.drawLine(Offset(px - s * 0.7, py - s * 0.7), Offset(px + s * 0.7, py + s * 0.7), paint);
          canvas.drawLine(Offset(px + s * 0.7, py - s * 0.7), Offset(px - s * 0.7, py + s * 0.7), paint);
          break;
        case 2: // Streak — trail line
          final trail = Offset(px - p.vx * 0.03 * size.width, py - p.vy * 0.03 * size.height);
          paint.strokeWidth = p.size * alpha * 0.5;
          paint.style = PaintingStyle.stroke;
          paint.strokeCap = StrokeCap.round;
          canvas.drawLine(trail, Offset(px, py), paint);
          break;
        case 3: // Confetti — small rectangles that rotate
          canvas.save();
          canvas.translate(px, py);
          canvas.rotate(p.vx * p.life * 10);
          final rect = Rect.fromCenter(center: Offset.zero,
              width: p.size * 1.5, height: p.size * 0.6);
          canvas.drawRect(rect, paint);
          canvas.restore();
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FireworksPainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// WHEEL PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _WheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> segments;
  const _WheelPainter({required this.segments});
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final sa = 2 * pi / segments.length;
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < segments.length; i++) {
      final a = i * sa - pi / 2;
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), a, sa, true,
          Paint()..color = Color(segments[i]["color"] as int)..style = PaintingStyle.fill);
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), a, sa, true,
          Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
      canvas.save(); canvas.translate(c.dx, c.dy); canvas.rotate(a + sa / 2); canvas.translate(r * 0.6, 0);
      tp.text = TextSpan(text: segments[i]["label"] as String, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700));
      tp.layout(); tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2)); canvas.restore();
    }
    canvas.drawCircle(c, 24, Paint()..color = Colors.white);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

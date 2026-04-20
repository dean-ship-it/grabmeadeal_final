// lib/screens/auth_gate.dart

import "package:flutter/material.dart";
import "package:grabmeadeal_final/screens/main_tab_controller.dart";

/// Plays a short branded splash animation on cold start, then hands off
/// to the main app. No login required to browse — auth is requested only
/// when the user takes an action that requires it.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  static const Duration _splashHold = Duration(milliseconds: 1500);
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(_splashHold, () {
      if (mounted) setState(() => _splashDone = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _splashDone
          ? const MainTabController()
          : const _SplashBody(),
    );
  }
}

class _SplashBody extends StatelessWidget {
  const _SplashBody();

  static const Color _navy = Color(0xFF062245);
  static const Color _gold = Color(0xFFF5C518);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _navy,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Logo — elastic grab entrance
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 900),
              curve: Curves.elasticOut,
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (BuildContext context, double value, Widget? child) {
                final double clamped = value.clamp(0.0, 1.0);
                return Opacity(
                  opacity: clamped,
                  child: Transform.scale(
                    scale: 0.5 + (value * 0.5),
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                "assets/logo/launcher_v2_cropped.png",
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            // Wordmark — delayed fade-in
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (BuildContext context, double value, Widget? child) {
                // Hold invisible until logo animation has settled.
                final double delayed = ((value - 0.45) / 0.55).clamp(0.0, 1.0);
                return Opacity(
                  opacity: delayed,
                  child: Transform.translate(
                    offset: Offset(0, 8 * (1 - delayed)),
                    child: child,
                  ),
                );
              },
              child: const Column(
                children: <Widget>[
                  Text(
                    "Grab Me A Deal",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Save on what you'd buy anyway",
                    style: TextStyle(
                      color: _gold,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

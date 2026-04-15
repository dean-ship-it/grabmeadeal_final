// lib/screens/auth_gate.dart

import "package:flutter/material.dart";
import "package:grabmeadeal_final/screens/main_tab_controller.dart";

/// Goes straight to the app — no login required to browse.
/// Auth is requested only when user takes an action that requires it.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainTabController();
  }
}

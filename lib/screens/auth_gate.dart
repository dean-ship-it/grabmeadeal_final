import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart" show kDebugMode;
import "package:flutter/material.dart";
import "package:grabmeadeal_final/routes/app_routes.dart";
import "package:grabmeadeal_final/screens/auth_screen.dart";

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // In debug mode, skip auth and go straight to home for easier preview/testing.
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const AuthScreen();
      },
    );
  }
}

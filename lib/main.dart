// lib/main.dart

import "dart:async";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:grabmeadeal_final/firebase_options.dart";
import "package:grabmeadeal_final/providers/puzzle_provider.dart";
import "package:grabmeadeal_final/providers/wishlist_provider.dart";
import "package:grabmeadeal_final/routes/app_routes.dart";
import "package:grabmeadeal_final/services/notification_service.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Ignore duplicate-app error — Firebase already initialized natively
    debugPrint("[Main] Firebase init: $e");
  }
  // Initialize notifications with timeout — never block UI
  try {
    await NotificationService.instance.initialize()
        .timeout(const Duration(seconds: 3));
  } catch (e) {
    debugPrint("[Main] Notification init skipped: $e");
  }
  runApp(const GrabMeADealApp());
}

class GrabMeADealApp extends StatelessWidget {
  const GrabMeADealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => PuzzleProvider()),
      ],
      child: MaterialApp(
        title: "Grab Me A Deal",
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.root,
        onGenerateRoute: AppRoutes.onGenerate,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0075C9),
            primary: const Color(0xFF0075C9),
            secondary: const Color(0xFFA6CE39),
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0075C9),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
      ),
    );
  }
}

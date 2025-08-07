import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const GrabMeADealApp());
}

class GrabMeADealApp extends StatelessWidget {
  const GrabMeADealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grab Me A Deal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const SplashScreen(),
    );
  }
}

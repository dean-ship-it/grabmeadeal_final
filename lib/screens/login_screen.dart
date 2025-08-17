import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Logo
              Image.asset(
                'assets/logo/logo.png',
                width: 150,
                height: 150,
                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // App Name
              Text(
                'Grab Me A Deal',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0075C9),
                    ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Discover local & national deals.\nSign in to get started!',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Google Sign-In Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in with Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0075C9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final user = await AuthService.signInWithGoogle();
                    if (user != null && context.mounted) {
                      Navigator.pushReplacementNamed(context, '/deals');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthService {
  static Future signInWithGoogle() async {}
}

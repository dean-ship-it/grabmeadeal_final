import 'package:grabmeadeal_final/models/user.dart';

class AuthService {
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  // Mock sign-in method (replace with Firebase Auth or your API)
  Future<AppUser?> signIn(String email, String password) async {
    // TODO: Implement real authentication logic
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    _currentUser = AppUser(
      uid: 'mock_uid',
      email: email,
      displayName: 'Sample User',
      photoUrl: null,
    );
    return _currentUser;
  }

  // Mock sign-out
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  // Mock sign-up (replace with Firebase Auth or your API)
  Future<AppUser?> signUp(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = AppUser(
      uid: 'mock_uid',
      email: email,
      displayName: 'Sample User',
      photoUrl: null,
    );
    return _currentUser;
  }
}

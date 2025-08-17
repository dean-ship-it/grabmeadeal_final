import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn();

  /// Stream of authentication state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Triggers the Google Sign-In flow
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _google.signIn();
    if (googleUser == null) {
      throw Exception('Sign-in aborted');
    }
    final googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  /// Signs out from both Firebase and Google
  Future<void> signOut() async {
    await _auth.signOut();
    await _google.signOut();
  }
}

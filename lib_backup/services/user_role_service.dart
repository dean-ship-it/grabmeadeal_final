import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRoleService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<UserRole?> fetchCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get(); // ✅ Use UID
    if (!doc.exists) return null;

    return UserRole.fromJson(doc.data()!);
  }

  Future<void> saveUserRoleIfNotExists({String role = 'user'}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid); // ✅ Use UID
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'role': role,
      });
    }
  }
}

class UserRole {
  static Future<UserRole?> fromJson(Map<String, dynamic> map) async {
    return null;
  }
}

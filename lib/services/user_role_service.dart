import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRoleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserRole?> fetchCurrentUserRole() async {
    final User? user = _auth.currentUser;
    if (user == null) return null;

    final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore.collection('users').doc(user.uid).get(); // ✅ Use UID
    if (!doc.exists) return null;

    return UserRole.fromJson(doc.data()!);
  }

  Future<void> saveUserRoleIfNotExists({String role = 'user'}) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    final DocumentReference<Map<String, dynamic>> docRef = _firestore.collection('users').doc(user.uid); // ✅ Use UID
    final DocumentSnapshot<Map<String, dynamic>> doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set(<String, dynamic>{
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

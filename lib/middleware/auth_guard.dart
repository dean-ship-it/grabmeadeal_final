// lib/middleware/auth_guard.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthGuard {
  static Future<bool> isAdmin() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final role = doc.data()?['role'];
    return role == 'admin';
  }
}

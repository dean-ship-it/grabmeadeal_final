import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/deal.dart';
import '../models/category.dart';
import 'main_tab_controller.dart';

class LiveDataScreen extends StatefulWidget {
  const LiveDataScreen({super.key});

  @override
  State<LiveDataScreen> createState() => _LiveDataScreenState();
}

class _LiveDataScreenState extends State<LiveDataScreen> {
  late final String _uid;
  late final DocumentReference<Map<String, dynamic>> _userDocRef;
  Set<String> _wishlistIds = <String>{};

  @override
  void initState() {
    super.initState();
    final User user = FirebaseAuth.instance.currentUser!;
    _uid = user.uid;
    _userDocRef = FirebaseFirestore.instance.collection('users').doc(_uid);
    _listenToWishlist();
  }

  void _listenToWishlist() {
    _userDocRef.snapshots().listen((DocumentSnapshot<Map<String, dynamic>> snap) {
      final Map<String, dynamic>? data = snap.data();
      final List<String> list = List<String>.from(data?['wishlistIds'] ?? <dynamic>[]);
      setState(() => _wishlistIds = list.toSet());
    });
  }

  void _handleWishlistToggle(Deal deal) {
    if (_wishlistIds.contains(deal.id)) {
      _userDocRef.update(<Object, Object?>{
        'wishlistIds': FieldValue.arrayRemove(<dynamic>[deal.id]),
      });
    } else {
      _userDocRef.set(<String, dynamic>{
        'wishlistIds': FieldValue.arrayUnion(<dynamic>[deal.id]),
      }, SetOptions(merge: true),);
    }
  }

  Future<void> _handleSkipToggle(Deal deal) async {
    await FirebaseFirestore.instance
        .collection('deals')
        .doc(deal.id)
        .update(<Object, Object?>{'skipped': true});
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot<Map<String, dynamic>>> categoriesStream = FirebaseFirestore.instance
        .collection('categories')
        .orderBy('name')
        .snapshots();

    final Stream<QuerySnapshot<Map<String, dynamic>>> dealsStream = FirebaseFirestore.instance
        .collection('deals')
        .orderBy('date', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: categoriesStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> catSnap) {
        if (catSnap.hasError) {
          return Scaffold(
            body: Center(child: Text('Error loading categories: ${catSnap.error}')),
          );
        }
        if (catSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final List<Category> categories =
            catSnap.data!.docs.map(Category.fromMap).toList();

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: dealsStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> dealSnap) {
            if (dealSnap.hasError) {
              return Scaffold(
                body: Center(child: Text('Error loading deals: ${dealSnap.error}')),
              );
            }
            if (dealSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final List<Deal> allDeals =
                dealSnap.data!.docs.map(Deal.fromMap).toList();
            final List<Deal> deals =
                allDeals.where((Deal d) => d.skipped != true).toList();
            final List<Deal> wishlistDeals =
                deals.where((Deal d) => _wishlistIds.contains(d.id)).toList();

            return MainTabController(
              deals: deals,
              wishlistIds: _wishlistIds,
              onWishlistToggle: _handleWishlistToggle,
              onSkipToggle: _handleSkipToggle,
              wishlistDeals: wishlistDeals,
              categories: categories,
            );
          },
        );
      },
    );
  }
}

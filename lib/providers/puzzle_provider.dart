// lib/providers/puzzle_provider.dart

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "package:grabmeadeal_final/models/puzzle_progress.dart";

class PuzzleProvider extends ChangeNotifier {
  PuzzleProgress? _progress;
  bool _loading = false;

  PuzzleProgress? get progress => _progress;
  bool get loading => _loading;

  static const List<Map<String, String>> pieces = [
    {"category": "electronics", "icon": "💻", "label": "Electronics"},
    {"category": "furniture", "icon": "🛋", "label": "Furniture"},
    {"category": "tools", "icon": "🛠", "label": "Tools"},
    {"category": "sports", "icon": "🏈", "label": "Sports"},
    {"category": "beauty", "icon": "💄", "label": "Beauty"},
    {"category": "petSupplies", "icon": "🐾", "label": "Pet Supplies"},
    {"category": "apparel", "icon": "👕", "label": "Apparel"},
    {"category": "automotive", "icon": "🚗", "label": "Automotive"},
  ];

  static const List<Map<String, dynamic>> wheelSegments = [
    {"label": "\$100 Gift Card", "value": 100, "color": 0xFF0075C9},
    {"label": "\$150 Gift Card", "value": 150, "color": 0xFFA6CE39},
    {"label": "\$200 Gift Card", "value": 200, "color": 0xFF5BBEFF},
    {"label": "\$300 Gift Card", "value": 300, "color": 0xFF004A8D},
    {"label": "\$500 Gift Card", "value": 500, "color": 0xFF7A9A01},
    {"label": "10% Off", "value": 10, "color": 0xFF0075C9},
    {"label": "15% Off", "value": 15, "color": 0xFFA6CE39},
    {"label": "20% Off", "value": 20, "color": 0xFF004A8D},
  ];

  Future<void> loadProgress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _loading = true;
    notifyListeners();
    try {
      final doc = await FirebaseFirestore.instance
          .collection("puzzle_progress")
          .doc(uid)
          .get();
      if (doc.exists) {
        var loaded = PuzzleProgress.fromMap(doc.data()!);
        // Migration: gaming piece retired 2026-04-19, replaced by sports.
        // Preserve the user's unlock count by swapping the key.
        if (loaded.unlockedCategories.contains("gaming")) {
          final migrated = {...loaded.unlockedCategories}
            ..remove("gaming")
            ..add("sports");
          loaded = loaded.copyWith(unlockedCategories: migrated);
          await FirebaseFirestore.instance
              .collection("puzzle_progress")
              .doc(uid)
              .set(loaded.toMap());
        }
        _progress = loaded;
      } else {
        _progress = PuzzleProgress.empty(uid);
      }
    } catch (e) {
      debugPrint("[Puzzle] Load error: $e");
      _progress = PuzzleProgress.empty(uid);
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> unlockCategory(String category) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    if (_progress == null) await loadProgress();
    if (_progress!.unlockedCategories.contains(category)) return;

    final newUnlocked = {..._progress!.unlockedCategories, category};
    final allRequired = PuzzleProgress.requiredCategories.toSet();
    final isComplete = allRequired.every(newUnlocked.contains);

    _progress = _progress!.copyWith(
      unlockedCategories: newUnlocked,
      puzzleComplete: isComplete,
      completedAt: isComplete ? DateTime.now() : null,
    );

    await FirebaseFirestore.instance
        .collection("puzzle_progress")
        .doc(uid)
        .set(_progress!.toMap());

    notifyListeners();
  }

  Future<String> recordSpin(int segmentIndex) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return "";
    final prize = wheelSegments[segmentIndex]["label"] as String;

    _progress = _progress!.copyWith(
      spinUsed: true,
      prizeWon: prize,
    );

    await FirebaseFirestore.instance
        .collection("puzzle_progress")
        .doc(uid)
        .set(_progress!.toMap());

    notifyListeners();
    return prize;
  }
}

// lib/models/puzzle_progress.dart

class PuzzleProgress {
  final String userId;
  final Set<String> unlockedCategories;
  final bool puzzleComplete;
  final bool spinUsed;
  final String? prizeWon;
  final DateTime? completedAt;

  const PuzzleProgress({
    required this.userId,
    required this.unlockedCategories,
    this.puzzleComplete = false,
    this.spinUsed = false,
    this.prizeWon,
    this.completedAt,
  });

  bool get canSpin => puzzleComplete && !spinUsed;

  static const List<String> requiredCategories = [
    "electronics",
    "furniture",
    "tools",
    "sports",
    "beauty",
    "petSupplies",
    "apparel",
    "automotive",
  ];

  factory PuzzleProgress.empty(String userId) => PuzzleProgress(
        userId: userId,
        unlockedCategories: {},
      );

  factory PuzzleProgress.fromMap(Map<String, dynamic> map) => PuzzleProgress(
        userId: map["userId"] ?? "",
        unlockedCategories: Set<String>.from(map["unlockedCategories"] ?? []),
        puzzleComplete: map["puzzleComplete"] ?? false,
        spinUsed: map["spinUsed"] ?? false,
        prizeWon: map["prizeWon"],
        completedAt: map["completedAt"] != null
            ? DateTime.parse(map["completedAt"])
            : null,
      );

  Map<String, dynamic> toMap() => {
        "userId": userId,
        "unlockedCategories": unlockedCategories.toList(),
        "puzzleComplete": puzzleComplete,
        "spinUsed": spinUsed,
        "prizeWon": prizeWon,
        "completedAt": completedAt?.toIso8601String(),
      };

  PuzzleProgress copyWith({
    Set<String>? unlockedCategories,
    bool? puzzleComplete,
    bool? spinUsed,
    String? prizeWon,
    DateTime? completedAt,
  }) =>
      PuzzleProgress(
        userId: userId,
        unlockedCategories:
            unlockedCategories ?? this.unlockedCategories,
        puzzleComplete: puzzleComplete ?? this.puzzleComplete,
        spinUsed: spinUsed ?? this.spinUsed,
        prizeWon: prizeWon ?? this.prizeWon,
        completedAt: completedAt ?? this.completedAt,
      );
}

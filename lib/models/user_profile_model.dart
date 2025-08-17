import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_profile_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final List<String> wishlist;
  final List<String> preferredCategories;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.wishlist = const [],
    this.preferredCategories = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  static final converter = FirestoreConverter<UserProfile>(
    fromFirestore: (snapshot, _) =>
        UserProfile.fromJson(snapshot.data()!..['uid'] = snapshot.id),
    toFirestore: (user, _) => user.toJson(),
  );
}

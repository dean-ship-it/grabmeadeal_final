import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Category {
  final String id;
  final String title;
  final String? description;
  final IconData? icon;
  final String? imageUrl;

  Category({
    required this.id,
    required this.title,
    this.description,
    this.icon,
    this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      icon: json['icon'] != null ? IconData(json['icon'], fontFamily: 'MaterialIcons') : null,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  String? get name => null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon?.codePoint,
        'imageUrl': imageUrl,
      };

  static fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {}
}

// lib/screens/categories_screen.dart

import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/widgets/category_tile.dart';
import 'package:grabmeadeal_final/models/category.dart';

class CategoriesScreen extends StatelessWidget {
  final List<Category> categories;
  final void Function(Category) onCategoryTap;

  const CategoriesScreen({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 3 / 2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryTile(
          category: category,
          onTap: () => onCategoryTap(category),
        );
      },
    );
  }
}

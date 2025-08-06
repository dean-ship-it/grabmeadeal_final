// lib/screens/categories_screen.dart

import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/category.dart';
import 'package:grabmeadeal_final/widgets/category_tile.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (ctx, index) {
            final category = categories[index];
            return CategoryTile(
              title: category.name,
              icon: category.icon,
              onTap: () => onCategoryTap(category),
            );
          },
        ),
      ),
    );
  }
}

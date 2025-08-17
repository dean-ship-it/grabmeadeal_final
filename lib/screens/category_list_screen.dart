import 'package:flutter/material.dart';
import '../models/category.dart';
import '../widgets/category_tile.dart';

class CategoryListScreen extends StatelessWidget {
  final List<Category> categories;
  final void Function(String) onCategoryTap;

  const CategoryListScreen({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Categories'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const Divider(height: 16),
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryTile(
            category: category,
            onTap: () => onCategoryTap(category.name),
          );
        },
      ),
    );
  }
}

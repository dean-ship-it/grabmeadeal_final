import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {

  const CategoryTile({super.key, required this.category});
  final String category;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/categoryDeals',
          arguments: category,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: Colors.lightBlueAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueGrey.shade200),
        ),
        alignment: Alignment.center,
        child: Text(
          category,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

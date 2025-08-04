// lib/widgets/wishlist_deal_card.dart

import 'package:flutter/material.dart';

class WishlistDealCard extends StatelessWidget {
  final String? title;
  final String? imageUrl;
  final String? vendor;

  const WishlistDealCard({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.vendor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: ListTile(
        leading: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
            : const Icon(Icons.image_not_supported),
        title: Text(title ?? 'No Title'),
        subtitle: Text(vendor ?? 'Unknown Vendor'),
      ),
    );
  }
}

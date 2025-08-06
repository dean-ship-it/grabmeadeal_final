// lib/widgets/wishlist_deal_tile.dart

import 'package:flutter/material.dart';

class WishlistDealTile extends StatelessWidget {
  final String? title;
  final String? vendor;
  final String? imageUrl;

  const WishlistDealTile({
    super.key,
    required this.title,
    required this.vendor,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
          : const Icon(Icons.image),
      title: Text(title ?? 'No title'),
      subtitle: Text(vendor ?? 'Unknown vendor'),
    );
  }
}

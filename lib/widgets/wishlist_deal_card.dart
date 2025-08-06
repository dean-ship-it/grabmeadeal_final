// lib/widgets/wishlist_deal_card.dart

import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';

class WishlistDealCard extends StatelessWidget {
  final String? title;
  final String? imageUrl;
  final String? vendor;

  const WishlistDealCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.vendor, required Deal deal, required bool isInWishlist, required Null Function() onTap, required void Function() onWishlistToggle,
  });

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

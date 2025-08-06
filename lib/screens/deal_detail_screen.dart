import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';

class DealDetailScreen extends StatelessWidget {
  final Deal deal;
  final bool isInWishlist;
  final void Function(Deal) onWishlistToggle;

  const DealDetailScreen({
    Key? key,
    required this.deal,
    required this.isInWishlist,
    required this.onWishlistToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(deal.title),
        actions: [
          IconButton(
            icon: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? Colors.red : null,
            ),
            onPressed: () => onWishlistToggle(deal),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(deal.imageUrl, height: 200),
            const SizedBox(height: 16),
            Text(
              deal.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              deal.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text('Price: \$${deal.price.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Vendor: ${deal.vendor}'),
            const SizedBox(height: 8),
            if (deal.location != null)
              Text('Location: ${deal.location!}'),
            const SizedBox(height: 8),
            Text('Category: ${deal.category}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Link out to the deal (future)
              },
              child: const Text('View Deal'),
            ),
          ],
        ),
      ),
    );
  }
}

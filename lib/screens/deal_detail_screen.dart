import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';

class DealDetailScreen extends StatelessWidget {
  final Deal deal;
  final bool isInWishlist;
  final VoidCallback onWishlistToggle;

  const DealDetailScreen({
    super.key,
    required this.deal,
    required this.isInWishlist,
    required this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(deal.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? Colors.red : Colors.white,
            ),
            onPressed: onWishlistToggle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deal Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                deal.imageUrl,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 220, color: Colors.grey[300]),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              deal.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Price & Vendor
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$${deal.price.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  deal.vendor,
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            const Text(
              "Description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              deal.description,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 20),

            // Category
            Row(
              children: [
                const Icon(Icons.category, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  deal.category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Buy Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart_checkout),
                label: const Text("Buy Now"),
                onPressed: () {
                  // Placeholder for redirect to vendor site
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Redirecting to vendor (placeholder)..."),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

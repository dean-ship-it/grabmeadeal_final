import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:grabmeadeal_final/models/deal.dart";
import "package:grabmeadeal_final/providers/wishlist_provider.dart";

class DealDetailScreen extends StatelessWidget {
  final Deal? deal;

  const DealDetailScreen({super.key, required this.deal});

  @override
  Widget build(BuildContext context) {
    if (deal == null) {
      return const Scaffold(
        body: Center(child: Text("Deal not found.")),
      );
    }

    final wishlist = context.watch<WishlistProvider>();
    final isInWishlist = wishlist.wishlistIds.contains(deal!.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(deal!.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? Colors.red : Colors.white,
            ),
            onPressed: () => wishlist.toggleWishlist(deal!),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                deal!.imageUrl,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 220, color: Colors.grey[300]),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              deal!.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$${deal!.price.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  deal!.vendor,
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(deal!.description, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.category, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  deal!.category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart_checkout),
                label: const Text("Buy Now"),
                onPressed: () {
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

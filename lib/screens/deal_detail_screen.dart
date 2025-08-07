import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:grabmeadeal_final/theme/app_theme.dart';

class DealDetailScreen extends StatelessWidget {
  final Deal deal;

  const DealDetailScreen({Key? key, required this.deal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(deal.title),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (deal.imageUrl.isNotEmpty)
              Center(
                child: CachedNetworkImage(
                  imageUrl: deal.imageUrl,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error),
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              deal.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Vendor: ${deal.vendor}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Category: ${deal.category}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Price: ${deal.price}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.limeGreen,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              deal.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Launch URL to purchase
                },
                icon: const Icon(Icons.shopping_cart_checkout),
                label: const Text('Buy Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.limeGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

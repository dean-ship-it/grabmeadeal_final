// lib/screens/deal_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _launchURL(BuildContext context) async {
    final uri = Uri.parse(deal.link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(deal.title),
        actions: [
          IconButton(
            icon: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
            ),
            onPressed: () => onWishlistToggle(deal),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (deal.imageUrl.isNotEmpty)
                Image.network(
                  deal.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 16),
              Text(
                deal.title,
                style: Theme.of(context).textTheme.headline6,
              ),
              if (deal.price != null) ...[
                const SizedBox(height: 8),
                Text(
                  '\$${deal.price}',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text('View Deal'),
                onPressed: () => _launchURL(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

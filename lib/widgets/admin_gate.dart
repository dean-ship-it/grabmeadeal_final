import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/category.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/screens/admin_upload_screen.dart';
import 'package:grabmeadeal_final/screens/admin_deal_uploader_screen.dart';

class AdminGate extends StatelessWidget {
  final List<Deal> allDeals;
  final List<Deal> wishlistDeals;
  final Set<String> wishlistIds;
  final List<Category> categories;
  final void Function(Deal) onWishlistToggle;

  const AdminGate({
    super.key,
    required this.allDeals,
    required this.wishlistDeals,
    required this.wishlistIds,
    required this.categories,
    required this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Tools')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('Upload Deals (Manual)'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminUploadScreen(
                    allDeals: allDeals,
                    wishlistDeals: wishlistDeals,
                    wishlistIds: wishlistIds,
                    categories: categories,
                    onWishlistToggle: onWishlistToggle,
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Upload Deals via JSON'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminDealUploaderScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

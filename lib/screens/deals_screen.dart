import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/services/firestore_service.dart';
import 'package:grabmeadeal_final/widgets/deal_card.dart';

class DealsScreen extends StatefulWidget {
  final Set<String> wishlistIds;
  final Function(Deal deal, bool isInWishlist) onWishlistToggle;

  const DealsScreen({
    super.key,
    required this.wishlistIds,
    required this.onWishlistToggle,
  });

  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Deals"),
      ),
      body: StreamBuilder<List<Deal>>(
        stream: _firestoreService.getDealsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading deals"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No deals available"));
          }

          final deals = snapshot.data!;

          return ListView.builder(
            itemCount: deals.length,
            itemBuilder: (context, index) {
              final deal = deals[index];
              final isInWishlist = widget.wishlistIds.contains(deal.id);

              return DealCard(
                deal: deal,
                isInWishlist: isInWishlist,
                onWishlistToggle: () {
                  widget.onWishlistToggle(deal, isInWishlist);
                },
                onTap: () {
                  // Navigate to deal details page
                  Navigator.pushNamed(
                    context,
                    '/dealDetail',
                    arguments: deal,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/screens/search_results_screen.dart';

class CustomSearchBar extends StatefulWidget {
  final List<Deal> results;
  final Set<String> wishlistIds;
  final void Function(Deal) onWishlistToggle;

  const CustomSearchBar({
    super.key,
    required this.results,
    required this.wishlistIds,
    required this.onWishlistToggle,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();

  void _handleSearch(String query) {
    final filtered = widget.results
        .where((deal) =>
            deal.title.toLowerCase().contains(query.toLowerCase()) ||
            deal.vendor.toLowerCase().contains(query.toLowerCase()))
        .toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(
          deals: filtered,
          wishlistIds: widget.wishlistIds,
          onWishlistToggle: widget.onWishlistToggle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _controller,
        onSubmitted: _handleSearch,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search deals...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

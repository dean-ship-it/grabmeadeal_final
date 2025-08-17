import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';

class CustomSearchBar extends StatefulWidget {
  final List<Deal> results;
  final Set<String> wishlistIds;
  final Function(Deal) onWishlistToggle;

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
    if (query.isEmpty) return;
    final filtered = widget.results
        .where((deal) =>
            deal.title.toLowerCase().contains(query.toLowerCase()) ||
            deal.description.toLowerCase().contains(query.toLowerCase()))
        .toList();

    Navigator.pushNamed(
      context,
      '/search-results',
      arguments: {'results': filtered},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search deals...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: _handleSearch,
      ),
    );
  }
}

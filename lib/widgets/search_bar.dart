import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/screens/search_results_screen.dart';

class CustomSearchBar extends StatefulWidget {
  final List<Deal> results;
  final Set<String> wishlistIds;
  final void Function(Deal) onWishlistToggle;
  final void Function(String) onSearch;

  const CustomSearchBar({
    super.key,
    required this.results,
    required this.wishlistIds,
    required this.onWishlistToggle,
    required this.onSearch,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();

  void _handleSearch() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      widget.onSearch(query);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchResultsScreen(
            searchQuery: query,
            results: widget.results,
            wishlistIds: widget.wishlistIds,
            onWishlistToggle: widget.onWishlistToggle,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search deals...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _handleSearch,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onSubmitted: (_) => _handleSearch(),
      ),
    );
  }
}

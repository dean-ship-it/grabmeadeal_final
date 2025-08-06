import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';
import 'package:grabmeadeal_final/screens/search_results_screen.dart';

class CustomSearchBar extends StatefulWidget {
  final List<Deal> results;
  final Set<String> wishlistIds;
  final Function(Deal) onWishlistToggle;

  const CustomSearchBar({
    super.key,
    required this.results,
    required this.wishlistIds,
    required this.onWishlistToggle, required Null Function(dynamic query) onSearch,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();

  void _submitSearch() {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(
          searchQuery: query,
          results: widget.results,
          wishlistIds: widget.wishlistIds,
          onWishlistToggle: widget.onWishlistToggle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        onSubmitted: (_) => _submitSearch(),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search for deals...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _submitSearch,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

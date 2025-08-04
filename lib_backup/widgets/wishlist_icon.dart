import 'package:flutter/material.dart';

class WishlistIcon extends StatelessWidget {
  final bool isInWishlist;
  final VoidCallback onPressed;

  const WishlistIcon({
    super.key,
    required this.isInWishlist,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isInWishlist ? Icons.favorite : Icons.favorite_border,
        color: isInWishlist ? Colors.red : Colors.grey,
      ),
      onPressed: onPressed,
    );
  }
}

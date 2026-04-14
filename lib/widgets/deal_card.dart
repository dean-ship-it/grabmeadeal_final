import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:grabmeadeal_final/models/deal.dart";

class DealCard extends StatelessWidget {
  final Deal deal;
  final bool isInWishlist;
  final VoidCallback onTap;
  final VoidCallback onWishlistToggle;

  const DealCard({
    super.key,
    required this.deal,
    required this.isInWishlist,
    required this.onTap,
    required this.onWishlistToggle,
  });

  Widget _imageFallback() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey.shade200,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey.shade400,
        size: 32,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: deal.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: deal.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => _imageFallback(),
                      )
                    : _imageFallback(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deal.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deal.vendor,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "\$${deal.price.toStringAsFixed(2)}",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (deal.originalPrice != null)
                      Text(
                        "Was \$${deal.originalPrice!.toStringAsFixed(2)}",
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isInWishlist ? Icons.favorite : Icons.favorite_border,
                  color: isInWishlist ? Colors.red : null,
                ),
                onPressed: onWishlistToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

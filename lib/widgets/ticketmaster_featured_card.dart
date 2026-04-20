// Featured card for a Ticketmaster event.
//
// Visual language matches HeroDealCard (gold border, lime CTA, 220px image)
// but swaps deal-specific bits for event semantics: segment chip in place of
// the "SAVE $X" badge, venue + date + price range in place of price.

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";

import "../models/ticketmaster_event.dart";

class TicketmasterFeaturedCard extends StatelessWidget {
  const TicketmasterFeaturedCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  final TicketmasterEvent event;
  final VoidCallback onTap;

  static const Color _gold = Color(0xFFF5C518);
  static const Color _navy = Color(0xFF062245);
  static const Color _lime = Color(0xFFA6CE39);

  String _formatPriceRange() {
    if (event.minPrice == null) return "";
    final NumberFormat fmt = NumberFormat.simpleCurrency(decimalDigits: 0);
    if (event.maxPrice == null || event.maxPrice == event.minPrice) {
      return "From ${fmt.format(event.minPrice)}";
    }
    return "${fmt.format(event.minPrice)} – ${fmt.format(event.maxPrice)}";
  }

  String _formatWhen() {
    if (event.startAt == null) return "";
    return DateFormat("EEE, MMM d · h:mm a").format(event.startAt!);
  }

  String _formatWhere() {
    final List<String> parts = <String>[
      if (event.venueName != null && event.venueName!.isNotEmpty)
        event.venueName!,
      if (event.city != null && event.city!.isNotEmpty) event.city!,
      if (event.stateCode != null && event.stateCode!.isNotEmpty)
        event.stateCode!,
    ];
    return parts.join(" · ");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _gold, width: 2.5),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _gold.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: event.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => _placeholder(),
                      errorWidget: (_, _, _) => _placeholder(),
                    ),
                  ),
                  // Segment chip (Sports, Music, etc.) — top right
                  if (event.segment != null && event.segment!.isNotEmpty)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[_gold, Color(0xFFD4A017)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          event.segment!.toUpperCase(),
                          style: const TextStyle(
                            color: _navy,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                  // "Tickets" ribbon — top left to signal the slot's purpose
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _navy,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "🎟 TICKETS",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      event.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _navy,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (_formatWhen().isNotEmpty)
                      Text(
                        _formatWhen(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    if (_formatWhere().isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        _formatWhere(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        if (_formatPriceRange().isNotEmpty)
                          Text(
                            _formatPriceRange(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: _navy,
                            ),
                          ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _lime,
                          foregroundColor: _navy,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "View Tickets",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.confirmation_num_outlined,
            size: 72, color: Colors.grey),
      ),
    );
  }
}

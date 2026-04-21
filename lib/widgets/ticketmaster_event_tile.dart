// Compact list tile for a Ticketmaster event — used in the Events screen.
//
// Horizontal layout: square image left, text stack right (name, date,
// venue + city, price range). Tap anywhere launches the ticket URL.

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";

import "../models/ticketmaster_event.dart";

class TicketmasterEventTile extends StatelessWidget {
  const TicketmasterEventTile({
    super.key,
    required this.event,
    required this.onTap,
  });

  final TicketmasterEvent event;
  final VoidCallback onTap;

  static const Color _navy = Color(0xFF062245);
  static const Color _gold = Color(0xFFF5C518);

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
    ];
    return parts.join(" · ");
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 110,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Image
              SizedBox(
                width: 110,
                height: 110,
                child: event.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: event.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => _placeholder(),
                        errorWidget: (_, _, _) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              // Text stack
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        event.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _navy,
                          height: 1.2,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (_formatWhen().isNotEmpty)
                            Text(
                              _formatWhen(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          if (_formatWhere().isNotEmpty)
                            Text(
                              _formatWhere(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          if (_formatPriceRange().isNotEmpty) ...<Widget>[
                            const SizedBox(height: 2),
                            Text(
                              _formatPriceRange(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: _navy,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Segment chip strip (right edge) — only if segment known
              if (event.segment != null && event.segment!.isNotEmpty)
                Container(
                  width: 6,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[_gold, Color(0xFFD4A017)],
                    ),
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
            size: 40, color: Colors.grey),
      ),
    );
  }
}

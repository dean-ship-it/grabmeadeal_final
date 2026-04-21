// lib/screens/events_screen.dart
//
// Events tab — live Ticketmaster Discovery feed, filtered to Texas by
// default. Segment filter chips (All / Sports / Music / Arts / Family)
// narrow the list without re-fetching (results are cached 30 min by the
// service). Tap launches the ticket URL through wrapAffiliate so the
// eventual affiliate layer slots in once Impact unblocks.

import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

import "../models/ticketmaster_event.dart";
import "../services/ticketmaster_service.dart";
import "../utils/affiliate_links.dart";
import "../widgets/ticketmaster_event_tile.dart";

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late Future<List<TicketmasterEvent>> _eventsFuture;
  String _segment = "All";

  static const List<String> _segments = <String>[
    "All",
    "Sports",
    "Music",
    "Arts & Theatre",
    "Family",
  ];

  @override
  void initState() {
    super.initState();
    _eventsFuture = TicketmasterService.fetchEvents(size: 50);
  }

  Future<void> _refresh() async {
    setState(() {
      _eventsFuture = TicketmasterService.fetchEvents(size: 50);
    });
    await _eventsFuture;
  }

  Future<void> _launchEvent(TicketmasterEvent e) async {
    final String wrapped =
        wrapAffiliate(e.url, customId: "app-events-tab");
    final Uri? uri = Uri.tryParse(wrapped);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  List<TicketmasterEvent> _filter(List<TicketmasterEvent> events) {
    if (_segment == "All") return events;
    return events
        .where((TicketmasterEvent e) =>
            (e.segment ?? "").toLowerCase() == _segment.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🎟 Events Near You"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
      body: Column(
        children: <Widget>[
          // Segment filter chips
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: _segments.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (BuildContext context, int i) {
                final String seg = _segments[i];
                final bool selected = seg == _segment;
                return ChoiceChip(
                  label: Text(seg),
                  selected: selected,
                  onSelected: (bool v) {
                    if (v) setState(() => _segment = seg);
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<TicketmasterEvent>>(
                future: _eventsFuture,
                builder: (BuildContext context,
                    AsyncSnapshot<List<TicketmasterEvent>> snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final List<TicketmasterEvent> all =
                      snap.data ?? <TicketmasterEvent>[];
                  if (all.isEmpty) return _emptyState();
                  final List<TicketmasterEvent> filtered = _filter(all);
                  if (filtered.isEmpty) return _emptyFilterState();
                  return ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (BuildContext context, int i) {
                      final TicketmasterEvent e = filtered[i];
                      return TicketmasterEventTile(
                        event: e,
                        onTap: () => _launchEvent(e),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return ListView(
      children: <Widget>[
        const SizedBox(height: 120),
        Center(
          child: Column(
            children: <Widget>[
              Icon(Icons.event_busy_outlined,
                  size: 72, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                "No events loaded.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Pull down to retry.",
                style:
                    TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _emptyFilterState() {
    return ListView(
      children: <Widget>[
        const SizedBox(height: 120),
        Center(
          child: Text(
            "No $_segment events nearby right now.",
            style:
                TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }
}

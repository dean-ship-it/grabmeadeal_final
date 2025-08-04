import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WhitelistVendorsScreen extends StatelessWidget {
  const WhitelistVendorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vendorsRef = FirebaseFirestore.instance
        .collection('vendorWhitelist')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Whitelisted Vendors')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: vendorsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error loading vendor whitelist'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No vendors have been whitelisted yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final vendorName = doc.id;
              final timestamp = (doc.data()['timestamp'] as Timestamp?)?.toDate();

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(vendorName),
                  subtitle: timestamp != null
                      ? Text('Whitelisted on ${timestamp.toLocal()}')
                      : const Text('No timestamp available'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

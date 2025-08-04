import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SkippedDealsScreen extends StatefulWidget {
  const SkippedDealsScreen({super.key});

  @override
  State<SkippedDealsScreen> createState() => _SkippedDealsScreenState();
}

class _SkippedDealsScreenState extends State<SkippedDealsScreen> {
  final Set<String> selectedIds = {};

  void toggleSelection(String docId) {
    setState(() {
      if (selectedIds.contains(docId)) {
        selectedIds.remove(docId);
      } else {
        selectedIds.add(docId);
      }
    });
  }

  void selectAll(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    setState(() {
      if (selectedIds.length == docs.length) {
        selectedIds.clear();
      } else {
        selectedIds.addAll(docs.map((doc) => doc.id));
      }
    });
  }

  Future<void> bulkDelete(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    final batch = FirebaseFirestore.instance.batch();
    for (var doc in docs) {
      if (selectedIds.contains(doc.id)) {
        batch.delete(doc.reference);
      }
    }
    await batch.commit();
    setState(() => selectedIds.clear());
  }

  Future<void> bulkPromote(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    final batch = FirebaseFirestore.instance.batch();
    for (var doc in docs) {
      if (selectedIds.contains(doc.id)) {
        final data = doc.data();
        final dealRef = FirebaseFirestore.instance.collection('deals').doc();
        batch.set(dealRef, data);
        batch.delete(doc.reference);
      }
    }
    await batch.commit();
    setState(() => selectedIds.clear());
  }

  Future<void> bulkWhitelist(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    final whitelistRef = FirebaseFirestore.instance.collection('vendorWhitelist');
    for (var doc in docs) {
      if (selectedIds.contains(doc.id)) {
        final vendor = doc.data()['vendor'];
        if (vendor != null) {
          await whitelistRef.doc(vendor).set({'timestamp': FieldValue.serverTimestamp()});
        }
      }
    }
    setState(() => selectedIds.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skipped Deals (Admin)'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('skippedDeals')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error loading skipped deals'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          return Column(
            children: [
              if (docs.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => selectAll(docs),
                        child: Text(selectedIds.length == docs.length ? 'Deselect All' : 'Select All'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: selectedIds.isEmpty ? null : () => bulkWhitelist(docs),
                        child: const Text('Whitelist Vendor'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: selectedIds.isEmpty ? null : () => bulkPromote(docs),
                        child: const Text('Move to Deals'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: selectedIds.isEmpty ? null : () => bulkDelete(docs),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: docs.isEmpty
                    ? const Center(child: Text('No skipped deals 🎉'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data();
                          final isSelected = selectedIds.contains(doc.id);

                          return GestureDetector(
                            onLongPress: () => toggleSelection(doc.id),
                            child: Card(
                              color: isSelected ? Colors.lightBlue.shade50 : null,
                              child: CheckboxListTile(
                                value: isSelected,
                                onChanged: (_) => toggleSelection(doc.id),
                                title: Text(data['title'] ?? 'Untitled'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Vendor: ${data['vendor'] ?? 'Unknown'}'),
                                    Text('Category: ${data['category'] ?? '—'}'),
                                    Text('Reason: ${data['reason'] ?? 'n/a'}'),
                                    if (data['timestamp'] != null)
                                      Text('Skipped: ${(data['timestamp'] as Timestamp).toDate()}'),
                                  ],
                                ),
                                secondary: data['imageUrl'] != null
                                    ? Image.network(
                                        data['imageUrl'],
                                        width: 50,
                                        height: 50,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                      )
                                    : const Icon(Icons.image_not_supported),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

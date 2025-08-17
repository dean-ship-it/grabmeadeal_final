import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('deals').get();

    final int totalDeals = snapshot.docs.length;
    final int skippedDeals = snapshot.docs
        .where((QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.data().containsKey('skipped') && doc['skipped'] == true)
        .length;

    final Map<String, int> categoryCounts = <String, int>{};
    final Map<String, int> skippedByVendor = <String, int>{};

    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      final Map<String, dynamic> data = doc.data();
      final category = data['category'] ?? 'Unknown';
      final vendor = data['vendor'] ?? 'Unknown';

      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;

      if (data['skipped'] == true) {
        skippedByVendor[vendor] = (skippedByVendor[vendor] ?? 0) + 1;
      }
    }

    return <String, dynamic>{
      'totalDeals': totalDeals,
      'skippedDeals': skippedDeals,
      'categoryCounts': categoryCounts,
      'skippedByVendor': skippedByVendor,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchDashboardData(),
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final Map<String, dynamic> data = snapshot.data!;
          final Map<String, int> categoryCounts = data['categoryCounts'] as Map<String, int>;
          final Map<String, int> skippedByVendor = data['skippedByVendor'] as Map<String, int>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Total Deals: ${data['totalDeals']}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Skipped Deals: ${data['skippedDeals']}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 24),
                const Text('Deals by Category', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                AspectRatio(
                  aspectRatio: 1.5,
                  child: PieChart(
                    PieChartData(
                      sections: categoryCounts.entries
                          .map((MapEntry<String, int> entry) => PieChartSectionData(
                                title: entry.key,
                                value: entry.value.toDouble(),
                                radius: 60,
                                titleStyle: const TextStyle(fontSize: 14),
                              ),)
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Top Skipped Vendors', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Column(
                  children: skippedByVendor.entries
                      .toList()
                      .sorted((a, b) => b.value.compareTo(a.value))
                      .take(5)
                      .map(
                        (entry) => ListTile(
                          title: Text(entry.key),
                          trailing: Text('${entry.value} skips'),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

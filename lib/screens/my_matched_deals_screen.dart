import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyMatchedDealsScreen extends StatefulWidget {
  const MyMatchedDealsScreen({super.key});

  @override
  State<MyMatchedDealsScreen> createState() => _MyMatchedDealsScreenState();
}

class _MyMatchedDealsScreenState extends State<MyMatchedDealsScreen> {
  List<DocumentSnapshot> _matchedDeals = <DocumentSnapshot<Object?>>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatchedDeals();
  }

  Future<void> _loadMatchedDeals() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('matchedDeals').get();
    if (!mounted) return;
    setState(() {
      _matchedDeals = snapshot.docs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Matched Deals')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _matchedDeals.length,
              itemBuilder: (BuildContext context, int index) {
                final Map<String, dynamic> deal = _matchedDeals[index].data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(deal['title'] ?? ''),
                  subtitle: Text(deal['description'] ?? ''),
                );
              },
            ),
    );
  }
}

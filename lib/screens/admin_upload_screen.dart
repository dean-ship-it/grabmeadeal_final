import 'package:flutter/material.dart';
import 'package:grabmeadeal_final/models/deal.dart';

class AdminUploadScreen extends StatelessWidget {
  final List<Deal> allDeals;

  const AdminUploadScreen({
    Key? key,
    required this.allDeals,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Upload Deals'),
      ),
      body: Center(
        child: Text(
          'Total deals available: ${allDeals.length}',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

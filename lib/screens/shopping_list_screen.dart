// lib/screens/shopping_list_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> _items = <String>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadList();
  }

  Future<void> _loadList() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('shoppingList')
        .get();

    setState(() {
      _items = snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.id).toList();
      _isLoading = false;
    });
  }

  Future<void> _addItem(String item) async {
    final User? user = _auth.currentUser;
    if (user == null || item.trim().isEmpty) return;

    final DocumentReference<Map<String, dynamic>> docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('shoppingList')
        .doc(item.trim().toLowerCase());

    await docRef.set(<String, dynamic>{'added': Timestamp.now()});

    setState(() {
      _items.add(item.trim().toLowerCase());
    });

    _controller.clear();
  }

  Future<void> _removeItem(String item) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    final DocumentReference<Map<String, dynamic>> docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('shoppingList')
        .doc(item);

    await docRef.delete();

    setState(() {
      _items.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Shopping List')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Add item...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _addItem(_controller.text),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String item = _items[index];
                      return ListTile(
                        title: Text(item),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeItem(item),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

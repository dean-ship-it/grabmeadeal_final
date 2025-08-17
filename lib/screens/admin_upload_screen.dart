import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUploadScreen extends StatefulWidget {
  const AdminUploadScreen({super.key});

  @override
  State<AdminUploadScreen> createState() => _AdminUploadScreenState();
}

class _AdminUploadScreenState extends State<AdminUploadScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _vendorController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  Future<void> uploadDeal() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('deals').add(<String, dynamic>{
          'title': _titleController.text,
          'description': _descriptionController.text,
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'vendor': _vendorController.text,
          'imageUrl': _imageUrlController.text,
          'category': _categoryController.text,
          'link': _linkController.text,
          'date': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deal uploaded successfully')),
        );

        _titleController.clear();
        _descriptionController.clear();
        _priceController.clear();
        _vendorController.clear();
        _imageUrlController.clear();
        _categoryController.clear();
        _linkController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload New Deal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (String? value) =>
                    value == null || value.isEmpty ? 'Enter title' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (String? value) =>
                    value == null || value.isEmpty ? 'Enter description' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (String? value) =>
                    value == null || value.isEmpty ? 'Enter price' : null,
              ),
              TextFormField(
                controller: _vendorController,
                decoration: const InputDecoration(labelText: 'Vendor'),
                validator: (String? value) =>
                    value == null || value.isEmpty ? 'Enter vendor' : null,
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (String? value) =>
                    value == null || value.isEmpty ? 'Enter image URL' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (String? value) =>
                    value == null || value.isEmpty ? 'Enter category' : null,
              ),
              TextFormField(
                controller: _linkController,
                decoration: const InputDecoration(labelText: 'Link'),
                validator: (String? value) =>
                    value == null || value.isEmpty ? 'Enter link' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: uploadDeal,
                child: const Text('Upload Deal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

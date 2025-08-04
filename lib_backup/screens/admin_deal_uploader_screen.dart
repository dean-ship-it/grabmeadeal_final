import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminDealUploaderScreen extends StatefulWidget {
  const AdminDealUploaderScreen({super.key});

  @override
  State<AdminDealUploaderScreen> createState() => _AdminDealUploaderScreenState();
}

class _AdminDealUploaderScreenState extends State<AdminDealUploaderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _vendorController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _affiliateUrlController = TextEditingController();
  bool _isFeatured = false;

  void _uploadDeal() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('deals').add({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'category': _categoryController.text,
          'vendor': _vendorController.text,
          'imageUrl': _imageUrlController.text,
          'affiliateUrl': _affiliateUrlController.text,
          'date': Timestamp.now(),
          'isFeatured': _isFeatured,
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deal uploaded successfully')),
        );
        _formKey.currentState!.reset();
        _titleController.clear();
        _descriptionController.clear();
        _categoryController.clear();
        _vendorController.clear();
        _imageUrlController.clear();
        _affiliateUrlController.clear();
        setState(() => _isFeatured = false);
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading deal: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Deal Uploader')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter title' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter description' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter category' : null,
              ),
              TextFormField(
                controller: _vendorController,
                decoration: const InputDecoration(labelText: 'Vendor'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter vendor' : null,
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter image URL' : null,
              ),
              TextFormField(
                controller: _affiliateUrlController,
                decoration: const InputDecoration(labelText: 'Affiliate URL'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter affiliate URL' : null,
              ),
              SwitchListTile(
                value: _isFeatured,
                onChanged: (val) => setState(() => _isFeatured = val),
                title: const Text('Feature this deal?'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadDeal,
                child: const Text('Upload Deal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

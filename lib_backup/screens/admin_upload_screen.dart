// lib/screens/admin_upload_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminUploadScreen extends StatefulWidget {
  const AdminUploadScreen({super.key});

  @override
  State<AdminUploadScreen> createState() => _AdminUploadScreenState();
}

class _AdminUploadScreenState extends State<AdminUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _vendorController = TextEditingController();
  final _categoryController = TextEditingController();
  final _linkController = TextEditingController();

  bool _isLoading = false;

  Future<void> _uploadDeal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final newDeal = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'originalPrice': double.tryParse(_originalPriceController.text) ?? 0.0,
        'imageUrl': _imageUrlController.text,
        'vendor': _vendorController.text,
        'category': _categoryController.text,
        'link': _linkController.text,
        'date': Timestamp.now(),
      };

      await FirebaseFirestore.instance.collection('deals').add(newDeal);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deal uploaded successfully')),
      );

      _formKey.currentState!.reset();
      _titleController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _originalPriceController.clear();
      _imageUrlController.clear();
      _vendorController.clear();
      _categoryController.clear();
      _linkController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Deal Upload')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField(_titleController, 'Title'),
              _buildField(_descriptionController, 'Description'),
              _buildField(_priceController, 'Price'),
              _buildField(_originalPriceController, 'Original Price'),
              _buildField(_imageUrlController, 'Image URL'),
              _buildField(_vendorController, 'Vendor'),
              _buildField(_categoryController, 'Category'),
              _buildField(_linkController, 'Link'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _uploadDeal,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Upload Deal'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (value) => value == null || value.isEmpty ? 'Enter $label' : null,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AdminDealForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController categoryController;
  final TextEditingController vendorController;
  final TextEditingController imageUrlController;
  final TextEditingController affiliateUrlController;
  final VoidCallback onSubmit;
  final bool isLoading;

  const AdminDealForm({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.categoryController,
    required this.vendorController,
    required this.imageUrlController,
    required this.affiliateUrlController,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField(titleController, 'Title'),
        _buildTextField(descriptionController, 'Description', maxLines: 2),
        _buildTextField(categoryController, 'Category'),
        _buildTextField(vendorController, 'Vendor'),
        _buildTextField(imageUrlController, 'Image URL'),
        _buildTextField(affiliateUrlController, 'Affiliate URL'),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: isLoading ? null : onSubmit,
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Upload Deal'),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

// Admin Deal Uploader — paste a product URL (Amazon or otherwise), tap
// "Auto-fill", Microlink fetches title/image/description, we apply our
// Amazon Associates tag to the outbound URL, operator fills in price +
// category, saves to Firestore. Goal: hands-on curation with minimal
// typing while we work toward the 3 sales that unlock PA-API.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/amazon_affiliate.dart';
import '../services/link_preview.dart';

class AdminDealUploaderScreen extends StatefulWidget {
  const AdminDealUploaderScreen({super.key});

  @override
  State<AdminDealUploaderScreen> createState() => _AdminDealUploaderScreenState();
}

class _AdminDealUploaderScreenState extends State<AdminDealUploaderScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _sourceUrlController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _vendorController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _affiliateUrlController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _originalPriceController = TextEditingController();
  bool _isFeatured = false;
  bool _isFetching = false;

  @override
  void dispose() {
    _sourceUrlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _vendorController.dispose();
    _imageUrlController.dispose();
    _affiliateUrlController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    super.dispose();
  }

  Future<void> _autoFillFromUrl() async {
    final url = _sourceUrlController.text.trim();
    if (url.isEmpty) return;

    setState(() => _isFetching = true);
    final preview = await fetchLinkPreview(url);
    if (!mounted) return;
    setState(() => _isFetching = false);

    if (preview == null || preview.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Couldn't fetch page preview. You can still fill the form manually.",
          ),
        ),
      );
      return;
    }

    setState(() {
      if (preview.title.isNotEmpty) _titleController.text = preview.title;
      if (preview.description.isNotEmpty) {
        _descriptionController.text = preview.description;
      }
      if (preview.imageUrl.isNotEmpty) {
        _imageUrlController.text = preview.imageUrl;
      }
      if (preview.publisher.isNotEmpty && _vendorController.text.isEmpty) {
        _vendorController.text = preview.publisher;
      }
      // Tag Amazon URLs with our Associates ID; non-Amazon URLs unchanged.
      _affiliateUrlController.text = addAmazonAffiliateTag(url);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Filled from page metadata. Add price + category, then upload.")),
    );
  }

  void _uploadDeal() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final price = double.tryParse(_priceController.text.trim()) ?? 0;
      final originalRaw = _originalPriceController.text.trim();
      final originalPrice =
          originalRaw.isEmpty ? null : double.tryParse(originalRaw);

      await FirebaseFirestore.instance.collection('deals').add(<String, dynamic>{
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _categoryController.text.trim(),
        'vendor': _vendorController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'dealUrl': _affiliateUrlController.text.trim(),
        'priceCurrent': price,
        if (originalPrice != null) 'originalPrice': originalPrice,
        'createdAt': Timestamp.now(),
        'isFeatured': _isFeatured,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deal uploaded successfully')),
      );
      _formKey.currentState!.reset();
      _sourceUrlController.clear();
      _titleController.clear();
      _descriptionController.clear();
      _categoryController.clear();
      _vendorController.clear();
      _imageUrlController.clear();
      _affiliateUrlController.clear();
      _priceController.clear();
      _originalPriceController.clear();
      setState(() => _isFeatured = false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading deal: $e')),
      );
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
            children: <Widget>[
              // Paste a URL → Microlink pre-fills the form below.
              TextFormField(
                controller: _sourceUrlController,
                decoration: const InputDecoration(
                  labelText: 'Product URL (Amazon, etc.)',
                  hintText: 'https://www.amazon.com/dp/...',
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isFetching ? null : _autoFillFromUrl,
                  icon: _isFetching
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isFetching ? 'Fetching…' : 'Auto-fill from URL'),
                ),
              ),
              const Divider(height: 32),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (String? value) =>
                    value == null || value.isEmpty ? 'Enter title' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (String? value) =>
                    value == null || value.isEmpty ? 'Enter category' : null,
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
                controller: _affiliateUrlController,
                decoration: const InputDecoration(
                  labelText: 'Affiliate/Deal URL',
                  helperText: 'Amazon URLs get tag=grabmeadeal-20 automatically',
                ),
                validator: (String? value) =>
                    value == null || value.isEmpty ? 'Enter deal URL' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price (USD)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (String? value) {
                        final v = double.tryParse((value ?? '').trim());
                        if (v == null || v <= 0) return 'Enter price > 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _originalPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Original (optional)',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                value: _isFeatured,
                onChanged: (bool val) => setState(() => _isFeatured = val),
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

// lib/services/barcode_lookup.dart
// UPC -> product name resolver. Hits Open Food Facts (free, no auth) for
// grocery items; returns null if the barcode isn't in their catalog so the
// caller can fall back to the raw digits.

import "dart:convert";
import "package:http/http.dart" as http;

Future<String?> lookupProductName(String barcode) async {
  final uri = Uri.parse("https://world.openfoodfacts.org/api/v2/product/$barcode.json");
  try {
    final response = await http.get(uri).timeout(const Duration(seconds: 6));
    if (response.statusCode != 200) return null;
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body["status"] != 1) return null;
    final product = body["product"] as Map<String, dynamic>?;
    if (product == null) return null;
    final name = (product["product_name"] as String?)?.trim();
    final brand = (product["brands"] as String?)?.trim().split(",").first.trim();
    if (name == null || name.isEmpty) return null;
    if (brand != null && brand.isNotEmpty && !name.toLowerCase().contains(brand.toLowerCase())) {
      return "$brand $name";
    }
    return name;
  } catch (_) {
    return null;
  }
}

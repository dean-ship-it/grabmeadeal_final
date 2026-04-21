// Fetches page metadata from a URL via Microlink's free API so the admin
// deal uploader can auto-fill title/image/description from an Amazon URL
// with one tap. Free tier: 50 req/min, 100 req/day, no API key needed.
//
// Docs: https://microlink.io/docs/api/getting-started/overview
//
// Microlink itself pulls OG / Twitter / JSON-LD metadata from the target
// page. It doesn't reliably extract Amazon prices (those render via JS),
// so price entry stays manual — but title/image/description are solid.

import "dart:convert";

import "package:http/http.dart" as http;

/// What we managed to pull off the page. Any field can be empty.
class LinkPreview {
  final String title;
  final String description;
  final String imageUrl;
  final String publisher;

  const LinkPreview({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.publisher,
  });

  bool get isEmpty =>
      title.isEmpty && description.isEmpty && imageUrl.isEmpty;
}

/// Fetch a preview of [url] via Microlink. Returns null on network error
/// or non-"success" response. Caller decides how to surface failures.
Future<LinkPreview?> fetchLinkPreview(String url) async {
  final endpoint =
      Uri.parse("https://api.microlink.io/?url=${Uri.encodeComponent(url)}");
  final http.Response resp;
  try {
    resp = await http.get(endpoint).timeout(const Duration(seconds: 15));
  } catch (_) {
    return null;
  }
  if (resp.statusCode != 200) return null;

  final decoded = jsonDecode(resp.body);
  if (decoded is! Map) return null;
  if (decoded["status"] != "success") return null;

  final data = decoded["data"];
  if (data is! Map) return null;

  final image = data["image"];
  final imageUrl = image is Map ? (image["url"] as String? ?? "") : "";

  return LinkPreview(
    title: (data["title"] as String? ?? "").trim(),
    description: (data["description"] as String? ?? "").trim(),
    imageUrl: imageUrl.trim(),
    publisher: (data["publisher"] as String? ?? "").trim(),
  );
}

class AdminDeal {
  final String title;
  final String description;
  final String category;
  final String vendor;
  final String imageUrl;
  final String affiliateUrl;
  final DateTime date;
  final bool isFeatured;

  AdminDeal({
    required this.title,
    required this.description,
    required this.category,
    required this.vendor,
    required this.imageUrl,
    required this.affiliateUrl,
    required this.date,
    required this.isFeatured,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'vendor': vendor,
      'imageUrl': imageUrl,
      'affiliateUrl': affiliateUrl,
      'date': date,
      'isFeatured': isFeatured,
    };
  }
}

// lib/models/deal_category.dart

enum DealCategory {
  grocery(label: "Grocery",         icon: "🛒"),
  electronics(label: "Electronics", icon: "📱"),
  gaming(label: "Gaming",          icon: "🎮"),
  tools(label: "Tools",            icon: "🔧"),
  furniture(label: "Furniture",     icon: "🛋️"),
  automotive(label: "Automotive",   icon: "🚗"),
  beauty(label: "Beauty",          icon: "💄"),
  apparel(label: "Apparel",        icon: "👗"),
  petSupplies(label: "Pet Supplies", icon: "🐾"),
  homeGoods(label: "Home Goods",    icon: "🏠"),
  fitness(label: "Fitness",         icon: "💪");

  const DealCategory({required this.label, required this.icon});

  final String label;
  final String icon;
}

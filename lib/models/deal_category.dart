// lib/models/deal_category.dart

enum DealCategory {
  grocery(label: "Grocery",       icon: "🛒"),
  electronics(label: "Electronics", icon: "📱"),
  fashion(label: "Fashion",       icon: "👗"),
  home(label: "Home",             icon: "🏠"),
  beauty(label: "Beauty",         icon: "💄"),
  sports(label: "Sports",         icon: "⚽"),
  toys(label: "Toys",             icon: "🧸"),
  automotive(label: "Automotive", icon: "🚗"),
  travel(label: "Travel",         icon: "✈️"),
  food(label: "Food",             icon: "🍔");

  const DealCategory({required this.label, required this.icon});

  final String label;
  final String icon;
}

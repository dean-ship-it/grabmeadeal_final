// lib/models/deal_category.dart
//
// Order = popularity descending, based on general deal-app search volume /
// engagement benchmarks (2026-04-19). Banner layout shows the first 11 in
// a 6+5 grid; positions 12-15 land in the "More" tab. Revisit this ordering
// once real user analytics are available to replace general benchmarks with
// measured click-through rates per category.

enum DealCategory {
  electronics(label: "Electronics", icon: "📱", asset: "assets/category_icons/electronics.png"),
  apparel(label: "Apparel",        icon: "👗", asset: "assets/category_icons/apparel.png"),
  travel(label: "Travel",           icon: "✈️", asset: "assets/category_icons/travel.png"),
  beauty(label: "Beauty",          icon: "💄", asset: "assets/category_icons/beauty.png"),
  food(label: "Food",               icon: "🍔", asset: "assets/category_icons/food.png"),
  grocery(label: "Grocery",         icon: "🛒", asset: "assets/category_icons/grocery.png"),
  homeGoods(label: "Home Goods",    icon: "🏠", asset: "assets/category_icons/home_goods.png"),
  furniture(label: "Furniture",     icon: "🛋️", asset: "assets/category_icons/furniture.png"),
  healthWellness(label: "Health & Wellness", icon: "💊", asset: "assets/category_icons/health_wellness.png"),
  petSupplies(label: "Pet Supplies", icon: "🐾", asset: "assets/category_icons/pet_supplies.png"),
  sports(label: "Sports",           icon: "🏈", asset: "assets/category_icons/sports.png"),
  automotive(label: "Automotive",   icon: "🚗", asset: "assets/category_icons/automotive.png"),
  tools(label: "Tools",            icon: "🔧", asset: "assets/category_icons/tools.png"),
  insurance(label: "Insurance",     icon: "🛡️", asset: "assets/category_icons/insurance.png"),
  energy(label: "Energy",           icon: "⚡", asset: "assets/category_icons/energy.png");

  const DealCategory({required this.label, required this.icon, required this.asset});

  final String label;
  final String icon;
  final String asset;
}

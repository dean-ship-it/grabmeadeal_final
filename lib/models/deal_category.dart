// lib/models/deal_category.dart

enum DealCategory {
  grocery(label: "Grocery",         icon: "🛒", asset: "assets/category_icons/grocery.png"),
  electronics(label: "Electronics", icon: "📱", asset: "assets/category_icons/electronics.png"),
  gaming(label: "Gaming",          icon: "🎮", asset: "assets/category_icons/gaming.png"),
  tools(label: "Tools",            icon: "🔧", asset: "assets/category_icons/tools.png"),
  furniture(label: "Furniture",     icon: "🛋️", asset: "assets/category_icons/furniture.png"),
  automotive(label: "Automotive",   icon: "🚗", asset: "assets/category_icons/automotive.png"),
  beauty(label: "Beauty",          icon: "💄", asset: "assets/category_icons/beauty.png"),
  apparel(label: "Apparel",        icon: "👗", asset: "assets/category_icons/apparel.png"),
  petSupplies(label: "Pet Supplies", icon: "🐾", asset: "assets/category_icons/pet_supplies.png"),
  homeGoods(label: "Home Goods",    icon: "🏠", asset: "assets/category_icons/home_goods.png"),
  food(label: "Food",               icon: "🍔", asset: "assets/category_icons/food.png"),
  insurance(label: "Insurance",     icon: "🛡️", asset: "assets/category_icons/insurance.png"),
  energy(label: "Energy",           icon: "⚡", asset: "assets/category_icons/energy.png"),
  sports(label: "Sports",           icon: "🏈", asset: "assets/category_icons/sports.png"),
  travel(label: "Travel",           icon: "✈️", asset: "assets/category_icons/travel.png"),
  healthWellness(label: "Health & Wellness", icon: "💊", asset: "assets/category_icons/health_wellness.png");

  const DealCategory({required this.label, required this.icon, required this.asset});

  final String label;
  final String icon;
  final String asset;
}

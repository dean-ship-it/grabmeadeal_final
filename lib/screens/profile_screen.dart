import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Header
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage("assets/images/profile_placeholder.png"),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              "Guest User",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          // Options
          Card(
            child: ListTile(
              leading: const Icon(Icons.favorite, color: Colors.redAccent),
              title: const Text("Wishlist"),
              subtitle: const Text("View and manage your saved deals"),
              onTap: () {
                Navigator.pushNamed(context, '/wishlist');
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications, color: Colors.blueAccent),
              title: const Text("Notifications"),
              subtitle: const Text("Manage your alerts and preferences"),
              onTap: () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text("Settings"),
              subtitle: const Text("App preferences and account settings"),
              onTap: () {
                // Placeholder for settings
              },
            ),
          ),
          const SizedBox(height: 20),

          // Logout Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
            icon: const Icon(Icons.logout),
            label: const Text("Log Out"),
            onPressed: () {
              // Placeholder: Add logout functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Logged out (placeholder)")),
              );
            },
          ),
        ],
      ),
    );
  }
}

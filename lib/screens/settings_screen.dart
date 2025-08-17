// lib/screens/settings_screen.dart
//
// A tidy, self-contained Settings screen that:
// - Toggles general notifications and promo notifications (local state)
// - Toggles geofence alerts and requests location permissions via geolocator
// - Opens your notification tester screen (if routed)
// - Offers Sign Out (FirebaseAuth)
// - Reset to defaults + About dialog
//
// Notes:
// - This screen stores toggles in memory (no persistence). If you want these
//   to persist, we can add SharedPreferences later.
// - The "Open Notification Tester" assumes a named route '/notifications' is
//   registered. If not, the action fails gracefully with a SnackBar.

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _promoNotificationsEnabled = false;
  bool _geofenceAlertsEnabled = false;

  Future<bool> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location services are disabled. Turning geofence alerts off.',
            ),
          ),
        );
      }
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Location permission is required for geofence alerts.',
            ),
            action: SnackBarAction(
              label: 'Open Settings',
              onPressed: () {
                Geolocator.openAppSettings();
              },
            ),
          ),
        );
      }
      return false;
    }

    // Permission granted
    return true;
  }

  Future<void> _toggleGeofence(bool value) async {
    if (value) {
      final ok = await _ensureLocationPermission();
      if (!ok) {
        setState(() => _geofenceAlertsEnabled = false);
        return;
      }
    }
    setState(() => _geofenceAlertsEnabled = value);
  }

  void _openNotificationTester() {
    // Tries to push the named route. If it's missing, show a helpful SnackBar.
    try {
      Navigator.of(context).pushNamed('/notifications');
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notification tester route not found. Add a route for /notifications.',
          ),
        ),
      );
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed out.')),
      );
      Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign out failed: $e')),
      );
    }
  }

  void _resetDefaults() {
    setState(() {
      _notificationsEnabled = true;
      _promoNotificationsEnabled = false;
      _geofenceAlertsEnabled = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings reset to defaults.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontWeight: FontWeight.w600);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0075c9),
        foregroundColor: Colors.white,
        elevation: 1.5,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 6),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Text('Notifications', style: titleStyle),
          ),
          SwitchListTile.adaptive(
            title: const Text('Enable notifications'),
            subtitle:
                const Text('Deal alerts, reminders, and important messages'),
            value: _notificationsEnabled,
            onChanged: (v) {
              setState(() => _notificationsEnabled = v);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    v
                        ? 'Notifications enabled.'
                        : 'Notifications disabled.',
                  ),
                ),
              );
            },
          ),
          SwitchListTile.adaptive(
            title: const Text('Promotional notifications'),
            subtitle: const Text('Occasional promos and partner offers'),
            value: _promoNotificationsEnabled,
            onChanged: (v) {
              setState(() => _promoNotificationsEnabled = v);
            },
          ),
          SwitchListTile.adaptive(
            title: const Text('Geofence deal alerts'),
            subtitle: const Text('Notify me about wishlist deals nearby'),
            value: _geofenceAlertsEnabled,
            onChanged: _toggleGeofence,
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Open Notification Tester'),
            subtitle: const Text('Send a sample alert to verify settings'),
            onTap: _openNotificationTester,
          ),
          ListTile(
            leading: const Icon(Icons.settings_applications_outlined),
            title: const Text('System app settings'),
            subtitle: const Text('Manage permissions in system settings'),
            onTap: () {
              Geolocator.openAppSettings();
            },
          ),
          const Divider(height: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: Text('Account', style: titleStyle),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Sign out'),
            onTap: _signOut,
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Reset to defaults'),
            onTap: _resetDefaults,
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Grab Me A Deal'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Grab Me A Deal',
                applicationVersion: '1.0.0',
                applicationIcon: const FlutterLogo(),
                children: const [
                  SizedBox(height: 8),
                  Text(
                    'Save time and money with smarter, cleaner deal discovery.',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

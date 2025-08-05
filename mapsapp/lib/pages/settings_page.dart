import 'package:flutter/material.dart';
import 'package:mapsapp/management/token_manager.dart';
import 'package:mapsapp/pages/login_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _handleLogout(BuildContext context) async {
    await TokenManager.clearToken();

    // Navigate to LoginPage and remove all previous routes (so user can't go back)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),

          // User Info Tile
          ListTile(
            leading: const Icon(Icons.person, size: 30),
            title: const Text(
              'User Info',
              style: TextStyle(fontSize: 18),
            ),
            subtitle: const Text(
                'Muhammadhsamir11@gmail.com'), // Replace with actual user info later
            onTap: () {},
          ),

          const Divider(),

          // Logout Button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mapsapp/management/token_manager.dart';
import 'package:mapsapp/pages/login_page.dart';
import 'package:provider/provider.dart';
import 'package:mapsapp/management/theme_manager.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _handleLogout(BuildContext context) async {
    await TokenManager.clearToken();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeManager = Provider.of<ThemeManager>(context);
    final isDark = themeManager.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        title: Text(
          'Settings',
          style: theme.appBarTheme.titleTextStyle ??
              TextStyle(color: theme.colorScheme.onSurface),
        ),
        iconTheme: theme.appBarTheme.iconTheme ??
            IconThemeData(color: theme.colorScheme.onSurface),
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
            subtitle: const Text('Muhammadhsamir11@gmail.com'),
            onTap: () {},
          ),

          const Divider(),

          // Dark Mode Toggle
          SwitchListTile(
            secondary: const Icon(Icons.brightness_6),
            title: const Text(
              'Dark Mode',
              style: TextStyle(fontSize: 18),
            ),
            value: isDark,
            onChanged: (value) => themeManager.toggleTheme(value),
          ),

          const Divider(),

          // Logout
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

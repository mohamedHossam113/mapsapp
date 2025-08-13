import 'package:flutter/material.dart';
import 'package:mapsapp/generated/l10n.dart';
import 'package:mapsapp/management/token_manager.dart';
import 'package:mapsapp/pages/login_page.dart';
import 'package:provider/provider.dart';
import 'package:mapsapp/management/theme_manager.dart';

import '../management/language_management.dart'; // Add this import

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

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).select_Language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                title: const Text('English'),
                onTap: () {
                  Provider.of<LanguageManager>(context, listen: false)
                      .changeLanguage(const Locale('en'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Text('🇸🇦', style: TextStyle(fontSize: 24)),
                title: const Text('العربية'),
                onTap: () {
                  Provider.of<LanguageManager>(context, listen: false)
                      .changeLanguage(const Locale('ar'));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(S.of(context).cancel),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        title: Text(
          S.of(context).settings, // Use localized string
          style: theme.appBarTheme.titleTextStyle ??
              TextStyle(color: theme.colorScheme.onSurface),
        ),
        iconTheme: theme.appBarTheme.iconTheme ??
            IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: Consumer2<ThemeManager, LanguageManager>(
        builder: (context, themeManager, languageManager, child) {
          final isDark = themeManager.themeMode == ThemeMode.dark;

          return ListView(
            children: [
              const SizedBox(height: 20),

              // User Info Tile
              ListTile(
                leading: const Icon(Icons.person, size: 30),
                title: Text(
                  S.of(context).User_info,
                  style: const TextStyle(fontSize: 18),
                ),
                subtitle: const Text('Muhammadhsamir11@gmail.com'),
                onTap: () {},
              ),

              const Divider(),

              // Language Selection
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(
                  S.of(context).language,
                  style: const TextStyle(fontSize: 18),
                ),
                subtitle: Text(
                  languageManager.isArabic ? 'العربية' : 'English',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showLanguageDialog(context),
              ),

              const Divider(),

              // Dark Mode Toggle
              SwitchListTile(
                secondary: const Icon(Icons.brightness_6),
                title: Text(
                  S.of(context).dark_mode,
                  style: const TextStyle(fontSize: 18),
                ),
                value: isDark,
                onChanged: (value) {
                  themeManager.toggleTheme(value);
                },
              ),

              const Divider(),

              // Logout
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  S.of(context).logout,
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                ),
                onTap: () => _handleLogout(context),
              ),
            ],
          );
        },
      ),
    );
  }
}

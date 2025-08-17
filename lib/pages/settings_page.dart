import 'package:flutter/material.dart';
import 'package:mapsapp/generated/l10n.dart';
import 'package:mapsapp/management/token_manager.dart';
import 'package:mapsapp/pages/login_page.dart';
import 'package:provider/provider.dart';
import 'package:mapsapp/management/theme_manager.dart';
import '../management/language_management.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  bool get _isSafe => mounted && !_isDisposed;

  void _handleLogout() async {
    if (!_isSafe) return;

    try {
      // Show loading indicator
      if (_isSafe) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _getLocalizedText(context, 'logging_out', 'Logging out...')),
          ),
        );
      }

      await TokenManager.clearToken();

      // Check if still mounted before navigation
      if (_isSafe) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      print('Logout error: $e');
      // Force navigation even if context issues occur
      if (mounted) {
        try {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        } catch (navError) {
          print('Navigation error during logout: $navError');
        }
      }
    }
  }

  void _showLanguageDialog() {
    if (!_isSafe) return;

    // Cache all needed values BEFORE showing the dialog
    final selectLanguageText =
        _getLocalizedText(context, 'select_Language', 'Select Language');
    final cancelText = _getLocalizedText(context, 'cancel', 'Cancel');

    try {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          // Use Consumer to access LanguageManager safely within dialog
          return Consumer<LanguageManager>(
            builder: (dialogContext, languageManager, child) {
              return AlertDialog(
                title: Text(selectLanguageText),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading:
                          const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                      title: const Text('English'),
                      onTap: () {
                        try {
                          languageManager.changeLanguage(const Locale('en'));
                          Navigator.of(dialogContext).pop();
                        } catch (e) {
                          print('Language change error (EN): $e');
                          Navigator.of(dialogContext).pop();
                        }
                      },
                    ),
                    ListTile(
                      leading:
                          const Text('🇸🇦', style: TextStyle(fontSize: 24)),
                      title: const Text('العربية'),
                      onTap: () {
                        try {
                          languageManager.changeLanguage(const Locale('ar'));
                          Navigator.of(dialogContext).pop();
                        } catch (e) {
                          print('Language change error (AR): $e');
                          Navigator.of(dialogContext).pop();
                        }
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(cancelText),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      print('Show language dialog error: $e');
    }
  }

  // Helper method to safely get localized text
  String _getLocalizedText(BuildContext context, String key, String fallback) {
    try {
      final s = S.of(context);
      switch (key) {
        case 'settings':
          return s.settings;
        case 'User_info':
          return s.User_info;
        case 'language':
          return s.language;
        case 'dark_mode':
          return s.dark_mode;
        case 'logout':
          return s.logout;
        case 'select_Language':
          return s.select_Language;
        case 'cancel':
          return s.cancel;
        case 'logging_out':
          return 'Logging out...'; // Add this to your localization files
        default:
          return fallback;
      }
    } catch (e) {
      print('Localization error for key $key: $e');
      return fallback;
    }
  }

  // Safe method to get theme manager
  ThemeManager? _getThemeManager(BuildContext context) {
    try {
      return Provider.of<ThemeManager>(context, listen: false);
    } catch (e) {
      print('ThemeManager access error: $e');
      return null;
    }
  }

  // Safe method to get language manager
  LanguageManager? _getLanguageManager(BuildContext context) {
    try {
      return Provider.of<LanguageManager>(context, listen: false);
    } catch (e) {
      print('LanguageManager access error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSafe) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Cache theme and localized texts at the beginning
    final theme = Theme.of(context);
    final settingsText = _getLocalizedText(context, 'settings', 'Settings');

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        title: Text(
          settingsText,
          style: theme.appBarTheme.titleTextStyle ??
              TextStyle(color: theme.colorScheme.onSurface),
        ),
        iconTheme: theme.appBarTheme.iconTheme ??
            IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: Builder(
        builder: (builderContext) {
          try {
            return Consumer2<ThemeManager, LanguageManager>(
              builder: (consumerContext, themeManager, languageManager, child) {
                // Null safety checks
                final isDark = themeManager.themeMode == ThemeMode.dark;

                // Cache all localized texts
                final userInfoText =
                    _getLocalizedText(builderContext, 'User_info', 'User Info');
                final languageText =
                    _getLocalizedText(builderContext, 'language', 'Language');
                final darkModeText =
                    _getLocalizedText(builderContext, 'dark_mode', 'Dark Mode');
                final logoutText =
                    _getLocalizedText(builderContext, 'logout', 'Logout');

                return ListView(
                  children: [
                    const SizedBox(height: 20),

                    // User Info Tile
                    ListTile(
                      leading: const Icon(Icons.person, size: 30),
                      title: Text(
                        userInfoText,
                        style: const TextStyle(fontSize: 18),
                      ),
                      subtitle: const Text('Muhammadhsamir11@gmail.com'),
                      onTap: () {
                        // Add user info functionality here if needed
                      },
                    ),

                    const Divider(),

                    // Language Selection
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(
                        languageText,
                        style: const TextStyle(fontSize: 18),
                      ),
                      subtitle: Text(
                        (languageManager.isArabic) ? 'العربية' : 'English',
                        style: TextStyle(
                          color: Theme.of(builderContext)
                              .textTheme
                              .bodySmall
                              ?.color,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        if (_isSafe) {
                          _showLanguageDialog();
                        }
                      },
                    ),

                    const Divider(),

                    // Dark Mode Toggle
                    SwitchListTile(
                        secondary: const Icon(Icons.brightness_6),
                        title: Text(
                          darkModeText,
                          style: const TextStyle(fontSize: 18),
                        ),
                        value: isDark,
                        onChanged: (value) {
                          try {
                            if (_isSafe) {
                              themeManager.toggleTheme(value);
                              // Ensure we stay on the same page
                              setState(() {});
                            }
                          } catch (e) {
                            print('Theme toggle error: $e');
                          }
                        }),

                    const Divider(),

                    // Logout
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        logoutText,
                        style: const TextStyle(fontSize: 18, color: Colors.red),
                      ),
                      onTap: () {
                        if (_isSafe) {
                          _handleLogout();
                        }
                      },
                    ),
                  ],
                );
              },
            );
          } catch (e) {
            print('Settings page build error: $e');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Settings temporarily unavailable'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

// Extension to add null safety to LanguageManager
extension LanguageManagerNullSafe on LanguageManager? {
  bool? get isArabic {
    if (this == null) return null;
    try {
      return this!.currentLocale.languageCode == 'ar';
    } catch (e) {
      print('LanguageManager.isArabic error: $e');
      return false;
    }
  }

  bool? get isEnglish {
    if (this == null) return null;
    try {
      return this!.currentLocale.languageCode == 'en';
    } catch (e) {
      print('LanguageManager.isEnglish error: $e');
      return true; // Default to English
    }
  }
}

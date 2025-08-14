import 'package:flutter/material.dart';
import 'package:mapsapp/generated/l10n.dart';
import 'package:mapsapp/pages/devices_page.dart';
import 'package:mapsapp/pages/settings_page.dart';
import 'custom_googlemaps.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    CustomGooglemaps(),
    DevicesPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navBarTheme = theme.bottomNavigationBarTheme;

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
            navBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        selectedItemColor:
            navBarTheme.selectedItemColor ?? theme.colorScheme.primary,
        unselectedItemColor:
            navBarTheme.unselectedItemColor ?? theme.unselectedWidgetColor,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_filled),
            label: S.of(context).home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.directions_car_filled_sharp),
            label: S.of(context).devices,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: S.of(context).settings,
          ),
        ],
      ),
    );
  }
}

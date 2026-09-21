import 'package:flutter/material.dart';
import 'package:homeroleplay/lib/screens/dashboard_screen.dart';
import 'package:homeroleplay/lib/screens/download_data_screen.dart';
import 'package:homeroleplay/lib/screens/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const DownloadDataScreen(), // Halaman download preset grafik/data
    const SettingsScreen(),    // Halaman pengatur/settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // SIDEBAR CUSTOM
          Container(
            width: 70,
            color: const Color(0xFF0F172A),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Logo / Home Icon
                IconButton(
                  icon: Icon(Icons.home, color: _currentIndex == 0 ? Colors.cyan : Colors.white54),
                  onPressed: () => setState(() => _currentIndex = 0),
                ),
                const SizedBox(height: 15),
                // Download Data Icon
                IconButton(
                  icon: Icon(Icons.download, color: _currentIndex == 1 ? Colors.cyan : Colors.white54),
                  onPressed: () => setState(() => _currentIndex = 1),
                ),
                const SizedBox(height: 15),
                // Settings Icon
                IconButton(
                  icon: Icon(Icons.settings, color: _currentIndex == 2 ? Colors.cyan : Colors.white54),
                  onPressed: () => setState(() => _currentIndex = 2),
                ),
              ],
            ),
          ),
          
          // AREA KONTEN UTAMA (BERUBAH SESUAI INDEX)
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }
}
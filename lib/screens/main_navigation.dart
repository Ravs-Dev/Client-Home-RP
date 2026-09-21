import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
// import 'servers_screen.dart'; // Komentari jika filenya belum dibuat
import 'settings_screen.dart';
import '../widgets/sidebar.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 1;

  final List<Widget> _pages = [
    const DashboardScreen(),
    // Ganti ServersScreen() sementara dengan Widget biasa
    const Center(
      child: Text("Halaman Server (Dalam Pengembangan)", style: TextStyle(color: Colors.white)),
    ),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Row(
        children: [
          Sidebar(
            selectedIndex: _currentIndex,
            onItemSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
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
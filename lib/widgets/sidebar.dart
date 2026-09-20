import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Lebar sidebar: 42px untuk mobile, 220px untuk desktop
    final sidebarWidth = isMobile ? 42.0 : 220.0;

    return Container(
      width: sidebarWidth,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(
          right: BorderSide(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),

          // Logo Area - Menggunakan Gambar Logo Asli
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 6.0 : 20.0),
            child: Container(
              padding: EdgeInsets.all(isMobile ? 5 : 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
                ),
                borderRadius: BorderRadius.circular(isMobile ? 8 : 16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00B4D8).withOpacity(0.3),
                    blurRadius: isMobile ? 4 : 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isMobile ? 4 : 8),
                // GANTI PATH INI SESUAI DENGAN LOKASI LOGO KAMU DI PUBSPEC.YAML
                child: Image.asset(
                  'assets/flutter_assets/assets/logo.webp',
                  width: isMobile ? 22 : 40,
                  height: isMobile ? 22 : 40,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback jika gambar tidak ditemukan, kembali ke ikon stik
                    return Icon(
                      Icons.sports_esports_rounded,
                      color: Colors.white,
                      size: isMobile ? 20 : 32,
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Menu Items
          _buildMenuItem(
            icon: Icons.home_rounded,
            label: "Home",
            index: 0,
            isMobile: isMobile,
          ),
          _buildMenuItem(
            icon: Icons.dashboard_rounded,
            label: "Dashboard",
            index: 1,
            isMobile: isMobile,
          ),
          _buildMenuItem(
            icon: Icons.dns_rounded,
            label: "Servers",
            index: 2,
            isMobile: isMobile,
          ),
          _buildMenuItem(
            icon: Icons.settings_rounded,
            label: "Settings",
            index: 3,
            isMobile: isMobile,
          ),

          const Spacer(),

          // Footer Version (hanya untuk desktop)
          if (!isMobile) ...[
            const Divider(color: Colors.white10, height: 1),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.info_outline, color: Colors.white54, size: 14),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Client v", style: TextStyle(color: Colors.white54, fontSize: 9)),
                      Text("1.0.0", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isMobile,
  }) {
    final isSelected = selectedIndex == index;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 4.0 : 12.0,
        vertical: 3.0,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onItemSelected(index),
          borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.all(isMobile ? 10.0 : 14.0),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(colors: [Color(0xFF00B4D8), Color(0xFF0077B6)])
                  : null,
              color: isSelected ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: const Color(0xFF00B4D8).withOpacity(0.3),
                  blurRadius: isMobile ? 4 : 8,
                  offset: const Offset(0, 2),
                ),
              ]
                  : null,
            ),
            child: isMobile
                ? Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white54,
              size: 20,
            )
                : Row(
              children: [
                Icon(icon, color: isSelected ? Colors.white : Colors.white54, size: 20),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
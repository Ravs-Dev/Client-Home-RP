import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Simulasi data game
  double _health = 85.0;
  double _armor = 50.0;
  String _money = "\$00000500";
  int _ping = 45;
  String _time = "14:30";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. LATAR BELAKANG (Simulasi Tampilan Game)
          Positioned.fill(
            child: Image.asset(
              'assets/flutter_assets/assets/bg/home_hood.webp', // Ganti dengan screenshot game jika ada
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.grey[800]); // Fallback jika gambar tidak ada
              },
            ),
          ),

          // 2. HUD ATAS (Uang, Health, Armor, Ping, Waktu)
          Positioned(
            top: 40,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Uang
                Text(
                  _money,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
                const SizedBox(height: 8),
                // Health & Armor Bars
                Row(
                  children: [
                    _buildStatBar(Icons.favorite, Colors.red, _health),
                    const SizedBox(width: 8),
                    _buildStatBar(Icons.shield, Colors.blue, _armor),
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            top: 40,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: Colors.black54,
              child: Text(
                "Ping: $_ping ms | $_time",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),

          // 3. CHAT BOX (Kiri Bawah)
          Positioned(
            left: 20,
            bottom: 140,
            child: Container(
              width: 250,
              height: 100,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("[00:00] {FFFFFF}Selamat datang di HomeRoleplay!", style: TextStyle(color: Colors.white, fontSize: 12)),
                  Text("[00:01] {00B4D8}[INFO] {FFFFFF}Gunakan /help untuk bantuan.", style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ),

          // 4. KONTROL KIRI: JOYSTICK VISUAL
          Positioned(
            left: 30,
            bottom: 30,
            child: GestureDetector(
              onPanUpdate: (details) {
                // Di sini nanti logika untuk menggerakkan joystick
                // (Membutuhkan custom widget joystick yang kompleks)
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                  color: Colors.black.withOpacity(0.2),
                ),
                child: const Center(
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white70,
                  ),
                ),
              ),
            ),
          ),

          // 5. KONTROL KANAN: TOMBOL AKSI
          Positioned(
            right: 30,
            bottom: 30,
            child: Column(
              children: [
                // Tombol Masuk Kendaraan / Aksi
                _buildActionButton(Icons.directions_car, "MASUK", Colors.blueAccent),
                const SizedBox(height: 15),
                Row(
                  children: [
                    // Tombol Lari
                    _buildActionButton(Icons.directions_run, "LARI", Colors.orange),
                    const SizedBox(width: 15),
                    // Tombol Tembak / Aksi Utama
                    _buildActionButton(Icons.radio_button_checked, "TEMBAK", Colors.redAccent, size: 70),
                  ],
                ),
              ],
            ),
          ),

          // 6. TOMBOL KELUAR DARI GAME (Untuk kembali ke Launcher)
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 16),
                label: const Text("KELUAR KE LAUNCHER"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk Bar Health/Armor
  Widget _buildStatBar(IconData icon, Color color, double value) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Container(
          width: 100,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(5),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value / 100,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper untuk Tombol Aksi
  Widget _buildActionButton(IconData icon, String label, Color color, {double size = 55}) {
    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) {
            // Logika saat tombol ditekan
            print("Tombol $label ditekan");
          },
          onTapUp: (_) {
            // Logika saat tombol dilepas
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.6),
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            ),
            child: Icon(icon, color: Colors.white, size: size * 0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black, blurRadius: 2)]),
        ),
      ],
    );
  }
}
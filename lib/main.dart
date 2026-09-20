import 'package:flutter/material.dart';
import '../pages/preset_page.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("HomeRoleplay Client"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Logo & Banner
                      Column(
                        children: [
                          Icon(Icons.gamepad, size: screenHeight * 0.12, color: Colors.blueAccent),
                          const SizedBox(height: 10),
                          const Text(
                            "SA-MP Mobile Launcher",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            "HomeRoleplay Community",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),

                      // Daftar Tombol Aksi Utama
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Tombol Main Game
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () {
                              // Panggil intent / logika buka game SA-MP
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Membuka Game SA-MP...")),
                              );
                            },
                            icon: const Icon(Icons.play_arrow, color: Colors.white),
                            label: const Text(
                              "MAIN GAME",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Tombol Navigasi ke Pilihan Preset Data/Grafik
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const PresetPage()),
                              );
                            },
                            icon: const Icon(Icons.file_download),
                            label: const Text(
                              "DOWNLOAD DATA / GRAFIK",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
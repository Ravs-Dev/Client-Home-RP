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
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // 1. Gambar Latar Belakang
          Positioned.fill(
            child: Image.asset(
              'assets/flutter_assets/assets/bg/home_calm.webp',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: const Color(0xFF0F172A)),
            ),
          ),
          // 2. Overlay Gelap
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.65),
            ),
          ),
          // 3. Konten Utama
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints:
                    BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Column(
                            children: [
                              Icon(
                                Icons.gamepad,
                                size: screenHeight * 0.10,
                                color: const Color(0xFF00B4D8),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "SA-MP Mobile Launcher",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                "HomeRoleplay Community",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // BOX RULES KOTA (PERATURAN WARGA BARU)
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B).withOpacity(0.85),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF00B4D8).withOpacity(0.4),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.gavel_rounded,
                                      color: Color(0xFF00B4D8),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "RULES KOTA - WARGA BARU",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  color: Colors.white24,
                                  height: 20,
                                ),
                                _buildRuleItem("1. Hormati sesama warga & ikuti alur Roleplay (In-Character)."),
                                _buildRuleItem("2. Dilarang Deathmatch (DM), Car Ramming (CR), dan Powergaming (PG)."),
                                _buildRuleItem("3. Dilarang melakukan OOC Insult atau menggunakan program ilegal / cheat."),
                                _buildRuleItem("4. Wajib menggunakan Nickname RP dengan format Nama_Belakang."),
                                _buildRuleItem("5. Patuhi instruksi Admin/Helper saat berada di area khusus."),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Tombol "DOWNLOAD DATA / GRAFIK"
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: const BorderSide(color: Colors.white54),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PresetPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.file_download, color: Colors.white),
                            label: const Text(
                              "DOWNLOAD DATA / GRAFIK",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget pendukung untuk baris peraturan
  static Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          height: 1.3,
        ),
      ),
    );
  }
}
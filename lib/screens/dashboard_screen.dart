import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../widgets/server_card.dart';
import '../widgets/server_detail_panel.dart';
import '../services/server_query_service.dart';
import '../screens/main_navigation.dart';
import '../models/app_config.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Data Server
  final String serverName = "HomeRoleplay SA-MP";
  final String serverIp = "165.101.181";
  final int serverPort = 7001;
  final String playerNickname = "Player";

  void _onPlayButtonPressed() {
    // Arahkan ke Loading Screen terlebih dahulu
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameLoadingScreen(
          ip: serverIp,
          port: serverPort,
          nickname: playerNickname,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PANEL KIRI & TENGAH (Dashboard & Main Content)
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "DASHBOARD",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Selamat datang, $playerNickname!",
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                      const SizedBox(height: 12),

                      // SERVER CARD (Tombol Play dipindah ke ATAS / BERSATU DI ATAS)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0EA5E9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.dns, color: Colors.white, size: 20),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          serverName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "IP: $serverIp:$serverPort",
                                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // TOMBOL MASUK KOTA (Di Atas Card & Kelihatan Jelas)
                                ElevatedButton.icon(
                                  onPressed: _onPlayButtonPressed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0EA5E9),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
                                  label: const Text(
                                    "MASUK KOTA",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white10, height: 16),
                            Row(
                              children: const [
                                Icon(Icons.circle, color: Colors.green, size: 10),
                                SizedBox(width: 4),
                                Text("ONLINE", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                                SizedBox(width: 12),
                                Text("Players: 0/50", style: TextStyle(color: Colors.white60, fontSize: 10)),
                                SizedBox(width: 12),
                                Text("Ping: 38 ms", style: TextStyle(color: Colors.white60, fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // TRAILER CARD
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.movie, color: Color(0xFF0EA5E9), size: 16),
                                SizedBox(width: 6),
                                Text(
                                  "TRAILER",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 100,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Icon(Icons.play_circle_fill, color: Color(0xFF0EA5E9), size: 36),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // PANEL KANAN (Informasi Kota - Font & Padding Dikecilkan)
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "INFORMASI KOTA",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12, // Dikecilkan dari sebelumnya
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Divider(color: Colors.white10, height: 12),
                        _buildInfoRow("Nickname", playerNickname),
                        _buildInfoRow("Gamemode", "Home Beta"),
                        _buildInfoRow("Versi SA-MP", "0.3.7-R2"),
                        _buildInfoRow("Fast Connect", "Non-aktif"),
                        _buildInfoRow("FPS Counter", "Aktif"),
                        _buildInfoRow("Status Server", "Online", isStatus: true),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper untuk membuat baris Informasi Kota yang rapi & kecil
  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
          Text(
            value,
            style: TextStyle(
              color: isStatus ? Colors.greenAccent : Colors.white,
              fontSize: 10, // Font dikecilkan agar pas di panel
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LOADING SCREEN (Memeriksa data, mengekstrak, lalu masuk ke game)
// ---------------------------------------------------------------------------
class GameLoadingScreen extends StatefulWidget {
  final String ip;
  final int port;
  final String nickname;

  const GameLoadingScreen({
    Key? key,
    required this.ip,
    required this.port,
    required this.nickname,
  }) : super(key: key);

  @override
  State<GameLoadingScreen> createState() => _GameLoadingScreenState();
}

class _GameLoadingScreenState extends State<GameLoadingScreen> {
  static const platform = MethodChannel('com.homeroleplay.client/game');
  String statusMessage = "Memeriksa berkas game...";
  double progress = 0.2;

  @override
  void initState() {
    super.initState();
    _startGameProcess();
  }

  Future<void> _startGameProcess() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        statusMessage = "Memuat data game & mengonfigurasi...";
        progress = 0.6;
      });

      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        statusMessage = "Menghubungkan ke server ${widget.ip}:${widget.port}...";
        progress = 1.0;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      // Memanggil method native Android untuk membuka game GTASA / SA-MP
      await platform.invokeMethod('launchGame', {
        'ip': widget.ip,
        'port': widget.port,
        'nickname': widget.nickname,
      });

      if (mounted) {
        Navigator.pop(context); // Tutup loading screen jika kembali dari game
      }
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() {
          statusMessage = "Gagal memuat game: ${e.message}";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF0EA5E9)),
              const SizedBox(height: 20),
              Text(
                statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white10,
                color: const Color(0xFF0EA5E9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
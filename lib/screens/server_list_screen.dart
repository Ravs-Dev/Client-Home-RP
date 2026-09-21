import 'package:flutter/material.dart';
import '../widgets/server_card.dart';
import '../services/server_query_service.dart';
import '../models/app_config.dart';

class ServerListScreen extends StatefulWidget {
  const ServerListScreen({super.key});

  @override
  State<ServerListScreen> createState() => _ServerListScreenState();
}

class _ServerListScreenState extends State<ServerListScreen> {
  bool _isFetching = true;
  bool _isFavorite = true;

  ServerStatus _serverStatus = ServerStatus(
    isOnline: true,
    players: 0,
    maxPlayers: 50,
    ping: 0,
    hostname: "HomeRoleplay",
    gamemode: "Home Roleplay",
    version: "0.3.7-R2",
    isMaintenance: false,
    isStorm: false,
  );

  @override
  void initState() {
    super.initState();
    _fetchServerData();
  }

  Future<void> _fetchServerData() async {
    setState(() => _isFetching = true);
    final status = await ServerQueryService.fetchServerStatus();
    if (mounted) {
      setState(() {
        _serverStatus = status;
        _isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Stack(
        children: [
          // Latar Belakang Utama
          Positioned.fill(
            child: Image.asset(
              'assets/flutter_assets/assets/bg/splash_lowrider.webp',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF0F172A)),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.65)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Title & Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "SERVER LIST",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 18 : 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${AppConfig.serverIp}:${AppConfig.serverPort}",
                              style: TextStyle(color: Colors.white70, fontSize: isSmallScreen ? 11 : 14),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: _isFavorite ? Colors.amber : Colors.white54,
                              size: isSmallScreen ? 20 : 26,
                            ),
                            tooltip: "Simpan ke Favorit",
                            onPressed: () {
                              setState(() => _isFavorite = !_isFavorite);
                            },
                          ),
                          IconButton(
                            icon: _isFetching
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                            tooltip: "Refresh Status",
                            onPressed: _fetchServerData,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Kartu Server Utama HomeRoleplay
                  ServerCard(
                    serverName: "HomeRoleplay",
                    ip: AppConfig.serverIp,
                    port: AppConfig.serverPort,
                    playerCount: "${_serverStatus.players}/${_serverStatus.maxPlayers}",
                    ping: "${_serverStatus.ping} ms",
                    isOnline: _serverStatus.isOnline,
                    onConnect: () {
                      Navigator.pushNamed(context, '/video');
                    },
                  ),

                  const SizedBox(height: 16),

                  // Panel Informasi Tambahan & Fitur Server
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.verified_user_rounded, color: const Color(0xFF00B4D8), size: isSmallScreen ? 16 : 20),
                            const SizedBox(width: 8),
                            Text(
                              "FITUR SERVER",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 12 : 14,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Colors.white12),
                        const SizedBox(height: 8),

                        _buildFeatureItem(
                          Icons.speed_rounded,
                          "Performa Tinggi",
                          "Dedicated server dengan proteksi Anti-DDoS",
                          isSmallScreen,
                        ),
                        _buildFeatureItem(
                          Icons.mic_rounded,
                          "Voice Chat 3D",
                          "Onin Voice Chat proximity untuk komunikasi",
                          isSmallScreen,
                        ),
                        _buildFeatureItem(
                          Icons.security_rounded,
                          "Anti-Cheat",
                          "Sistem pemantauan manipulasi game",
                          isSmallScreen,
                        ),
                        _buildFeatureItem(
                          Icons.update_rounded,
                          "Versi",
                          "SA-MP ${_serverStatus.version}",
                          isSmallScreen,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description, bool isSmall) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmall ? 6.0 : 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isSmall ? 6 : 8),
            decoration: BoxDecoration(
              color: const Color(0xFF00B4D8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF00B4D8), size: isSmall ? 16 : 20),
          ),
          SizedBox(width: isSmall ? 10 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmall ? 12 : 14,
                  ),
                ),
                SizedBox(height: isSmall ? 2 : 3),
                Text(
                  description,
                  style: TextStyle(color: Colors.white54, fontSize: isSmall ? 10 : 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
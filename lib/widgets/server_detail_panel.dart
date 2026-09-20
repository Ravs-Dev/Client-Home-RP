import 'package:flutter/material.dart';
import '../main.dart';
import '../services/server_query_service.dart';

class ServerDetailPanel extends StatelessWidget {
  final ServerStatus status;

  const ServerDetailPanel({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "INFORMASI KOTA",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 16),

          // Row Data Dinamis
          _buildInfoRow("Nickname", AppConfig.nickname),
          _buildInfoRow("Gamemode", status.gamemode),
          _buildInfoRow("Versi SA-MP", status.version),
          _buildInfoRow("Fast Connect", AppConfig.fastConnect ? "Aktif" : "Non-aktif"),
          _buildInfoRow("FPS Counter", AppConfig.fpsCounter ? "Aktif" : "Non-aktif"),
          _buildInfoRow("Status Server", status.isOnline ? "Online" : "Offline"),
          _buildInfoRow("Pemain Online", "${status.players}/${status.maxPlayers}"),
          _buildInfoRow("Ping / Latensi", "${status.ping} ms"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
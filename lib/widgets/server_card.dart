import 'package:flutter/material.dart';

class ServerCard extends StatelessWidget {
  final String serverName;
  final String ip;
  final int port;
  final String playerCount;
  final String ping;
  final bool isOnline;
  final VoidCallback onConnect;

  const ServerCard({
    super.key,
    required this.serverName,
    required this.ip,
    required this.port,
    required this.playerCount,
    required this.ping,
    required this.isOnline,
    required this.onConnect,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B4D8).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.dns_rounded, color: Color(0xFF00B4D8), size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serverName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "IP: $ip:$port",
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: isOnline ? Colors.greenAccent : Colors.redAccent,
                        size: 9,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOnline ? "ONLINE" : "OFFLINE",
                        style: TextStyle(
                          color: isOnline ? Colors.greenAccent : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text("Players: $playerCount", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      const SizedBox(width: 12),
                      Text("Ping: $ping", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B4D8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
            label: const Text("MASUK KOTA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: onConnect,
          ),
        ],
      ),
    );
  }
}
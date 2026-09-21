import 'dart:async'; // ← TAMBAHKAN INI (untuk TimeoutException)
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:homeroleplay/models/app_config.dart';
import '../main.dart';

class ServerStatus {
  final bool isOnline;
  final int players;
  final int maxPlayers;
  final int ping;
  final String hostname;
  final String gamemode;
  final String version;
  final bool isMaintenance;
  final bool isStorm;

  ServerStatus({
    required this.isOnline,
    required this.players,
    required this.maxPlayers,
    required this.ping,
    required this.hostname,
    required this.gamemode,
    required this.version,
    required this.isMaintenance,
    required this.isStorm,
  });
}

class ServerQueryService {
  static const MethodChannel _channel = MethodChannel('homeroleplay/server');

  static Future<ServerStatus> fetchServerStatus() async {
    final String ip = AppConfig.serverIp;
    final int port = AppConfig.serverPort;

    try {
      final Map<dynamic, dynamic> result = await _channel
          .invokeMethod('queryServer', {
        'host': ip,
        'port': port,
        'timeoutMs': 3000,
      }).timeout(const Duration(seconds: 5)); // ← Timeout 5 detik

      return ServerStatus(
        isOnline: result['online'] ?? false,
        players: result['players'] ?? 0,
        maxPlayers: result['maxPlayers'] ?? 0,
        ping: result['ping'] ?? 999,
        hostname: result['hostname'] ?? 'Unknown Server',
        gamemode: result['gamemode'] ?? '-',
        version: result['version'] ?? '-',
        isMaintenance: result['maintenance'] ?? false,
        isStorm: result['storm'] ?? false,
      );

    } on TimeoutException catch (_) {
      debugPrint("Query server timeout");
      return _getFallbackStatus(isOnline: false, reason: "Timeout");
    } on PlatformException catch (e) {
      debugPrint("Gagal melakukan query ke server: ${e.message}");
      return _getFallbackStatus(isOnline: false, reason: "Gagal terhubung");
    } catch (e) {
      debugPrint("Error tidak dikenal saat query: $e");
      return _getFallbackStatus(isOnline: false, reason: "Error");
    }
  }

  static ServerStatus _getFallbackStatus({
    required bool isOnline,
    String reason = "Offline",
  }) {
    return ServerStatus(
      isOnline: isOnline,
      players: 0,
      maxPlayers: 100, // ← Hardcode 100 (hapus AppConfig.maxPlayersFallback)
      ping: 0,
      hostname: isOnline ? "HomeRoleplay" : "Server $reason",
      gamemode: "-",
      version: "-",
      isMaintenance: false,
      isStorm: false,
    );
  }
}
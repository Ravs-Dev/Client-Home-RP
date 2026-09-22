import 'package:flutter/services.dart';
import '../services/samp_settings_service.dart';
import '../config/server_config.dart';

class GameController {
  static const platform = MethodChannel('com.example.homeroleplay/game');

  static Future<void> launchGame(String playerNickname) async {
    // 1. Simpan konfigurasi ke settings.ini di Android/data
    await SampSettingsService.saveSampSettings(
      nickname: playerNickname.isEmpty ? "Player" : playerNickname,
      ip: ServerConfig.serverIp,
      port: int.parse(ServerConfig.serverPort),
    );

    // 2. Panggil Native Android untuk menjalankan Game
    try {
      await platform.invokeMethod('launchGame');
    } on PlatformException catch (e) {
      print("Gagal membuka game: ${e.message}");
    }
  }
}
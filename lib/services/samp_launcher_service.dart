import 'package:flutter/foundation.dart';
import 'package:android_intent_plus/android_intent.dart';
import '../main.dart';

class SamPLauncherService {
  // Package name untuk SA-MP Client yang umum
  static const List<String> _sampPackages = [
    'com.alexeyg.samp', // SA-MP Launcher by AlexeyG
    'com.samp.mobile', // SA-MP Mobile
    'io.gunther.samp', // SA-MP Client lain
    // Tambahkan package name SA-MP client lainnya jika ada
  ];

  static Future<bool> launchGame({
    required String ip,
    required int port,
    required String username,
  }) async {
    try {
      // Coba launch dengan package name yang tersedia
      for (final packageName in _sampPackages) {
        try {
          final intent = AndroidIntent(
            action: 'android.intent.action.VIEW',
            package: packageName,
            data: 'samp://$ip:$port?name=${Uri.encodeComponent(username)}',
          );

          await intent.launch();
          debugPrint('Berhasil launch SA-MP dari package: $packageName');
          return true;
        } catch (e) {
          debugPrint('Gagal launch package $packageName: $e');
          // Lanjut ke package berikutnya
        }
      }

      // Jika semua package gagal, coba dengan URI scheme umum
      try {
        final intent = AndroidIntent(
          action: 'android.intent.action.VIEW',
          data: 'samp://$ip:$port',
        );
        await intent.launch();
        debugPrint('Berhasil launch dengan URI scheme');
        return true;
      } catch (e) {
        debugPrint('Gagal launch dengan URI scheme: $e');
      }

      return false;
    } catch (e) {
      debugPrint('Error saat launch SA-MP: $e');
      return false;
    }
  }

  static Future<bool> isSampInstalled() async {
    for (final packageName in _sampPackages) {
      try {
        final intent = AndroidIntent(
          action: 'android.intent.action.MAIN',
          package: packageName,
        );
        // Jika tidak throw error, berarti package ada
        return true;
      } catch (_) {
        continue;
      }
    }
    return false;
  }
}
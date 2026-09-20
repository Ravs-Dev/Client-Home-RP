import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

import 'screens/home_screen.dart';
import 'screens/server_list_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/video_screen.dart';

// Config State Global Aplikasi (Dedicated IP & User Info)
class AppConfig {
  static String nickname = "Player_Name";
  static String serverIp = "165.101.18.181";
  static int serverPort = 7001;
  static bool fastConnect = true;
  static bool fpsCounter = false;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Kunci layar ke Landscape ala Launcher Game
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const HomeRoleplayApp());
  });
}

class HomeRoleplayApp extends StatelessWidget {
  const HomeRoleplayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeRoleplay Launcher',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0EA5E9),
          surface: Color(0xFF1E293B),
        ),
      ),
      home: const HomeScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/servers': (context) => const ServerListScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/video': (context) => const VideoScreen(),
      },
    );
  }
}

// ==========================================
// FUNGSI PELUNCUR GAME SA-MP CLIENT
// ==========================================
Future<void> launchSAMPGame(BuildContext context) async {
  final String sampData = "samp://${AppConfig.serverIp}:${AppConfig.serverPort}?name=${AppConfig.nickname}";
  final Uri sampUri = Uri.parse(sampData);

  // 1. Coba via URL Launcher (Universal Scheme)
  try {
    if (await canLaunchUrl(sampUri)) {
      await launchUrl(sampUri, mode: LaunchMode.externalApplication);
      return;
    }
  } catch (e) {
    debugPrint("Scheme launch error: $e");
  }

  // 2. Fallback via Android Intent di Perangkat Android
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    final List<String> clientPackages = [
      "ru.unisamp_mobile.game",
      "com.samp.mobile",
      "com.nv.sampmobile",
      "com.rockstargames.gtasa",
      "com.br.top.samp",
    ];

    bool launched = false;
    for (String packageName in clientPackages) {
      try {
        final AndroidIntent intent = AndroidIntent(
          action: 'android.intent.action.VIEW',
          data: sampData,
          package: packageName,
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        );

        await intent.launch();
        launched = true;
        break;
      } catch (e) {
        debugPrint("Gagal membuka package $packageName: $e");
      }
    }

    if (launched) return;
  }

  // 3. Notifikasi jika gagal / jika berjalan di Chrome Web
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            kIsWeb
                ? "Fitur Masuk Kota hanya berfungsi di APK Android (Bukan Browser Web)!"
                : "Gagal membuka SA-MP Client. Pastikan APK SA-MP Client sudah terpasang!"
        ),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
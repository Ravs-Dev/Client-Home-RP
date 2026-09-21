import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Import file project kamu
import 'package:homeroleplay/screens/main_navigation.dart';
import 'screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // PAKSA ORIENTASI KE LANDSCAPE (16:9)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home Roleplay Launcher',
      theme: ThemeData.dark(),
      home: const MainNavigationScreen(),
    );
  }
}
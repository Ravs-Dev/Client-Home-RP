import 'package:flutter/material.dart';
import 'screens/main_screen.dart'; // Mengarah ke lib/screens/main_screen.dart

void main() {
  // Memastikan binding Flutter diinisialisasi dengan benar sebelum aplikasi berjalan
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeRoleplay Launcher',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          elevation: 0,
        ),
      ),
      home: const MainScreen(), // Membuka MainScreen saat aplikasi pertama kali dijalankan
    );
  }
}
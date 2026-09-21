class AppConfig {
  // Gunakan 'static' TANPA 'final' / 'const' agar nilainya bisa diubah di halaman Settings
  static String nickname = 'Player';
  static bool fastConnect = false;
  static bool fpsCounter = true;

  static const String serverIp = '165.101.18.181';
  static const int serverPort = 7001;

  static const String dataSampUrl = 'https://github.com/Ravs-Dev/Client-Home-RP/releases/download/v1.0.0/data_samp.zip';
  static const String dataGangsterUrl = 'https://github.com/Ravs-Dev/Client-Home-RP/releases/download/v1.0.0/data_gangster.zip';
}
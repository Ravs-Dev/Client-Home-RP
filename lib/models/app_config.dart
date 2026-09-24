class AppConfig {
  // 1. Konfigurasi Server & Download (Properti Statis / Const)
  static const String serverIp = "165.101.18.1";
  static const int serverPort = 7001;

  static const String urlDataSamp =
      "https://github.com/Ravs-Dev/Client-Home-RP/releases/download/v1.0.0/data_samp.zip";
  static const String urlDataGangster =
      "https://github.com/Ravs-Dev/Client-Home-RP/releases/download/v1.0.0/data_gangster.zip";

  // 2. Konfigurasi Pengguna (Variabel Dinamis yang Dibutuhkan oleh Settings Screen)
  static String nickname = "Player";
  static bool fastConnect = false;
  static bool fpsCounter = true;
}
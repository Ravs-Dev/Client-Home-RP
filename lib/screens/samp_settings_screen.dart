import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/app_config.dart';

class SampSettingsService {
  static Future<void> writeSettings(String nickname) async {
    try {
      final Directory? extDir = await getExternalStorageDirectory();
      if (extDir == null) return;

      final Directory sampDir = Directory('${extDir.path}/SAMP');
      if (!await sampDir.exists()) {
        await sampDir.create(recursive: true);
      }

      final File iniFile = File('${sampDir.path}/settings.ini');
      final String content = '''
        [client]
        name = ${nickname.isEmpty ? "Player" : nickname}
        host = ${AppConfig.serverIp}
        port = ${AppConfig.serverPort}
        fpslimit = 60
        frame-limiter = 0
        ''';

      await iniFile.writeAsString(content);
    } catch (e) {
      print("Gagal menulis settings.ini: $e");
    }
  }
}
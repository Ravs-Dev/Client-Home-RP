import 'package:flutter/material.dart';
import '../main.dart'; // Pastikan path ini sesuai dengan struktur projectmu
import '../widgets/sidebar.dart';
import '../models/app_config.dart'; // BENAR

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 3;

  // --- 1. PROFIL ---
  late TextEditingController _ucpNameController;

  // --- 2. AUDIO & VOICE ---
  bool _voiceChatEnabled = true;
  bool _voice3D = true;
  bool _pushToTalk = false;
  double _voiceVolume = 90.0;
  double _bgmVolume = 70.0;
  double _sfxVolume = 85.0;

  // --- 3. GRAFIK ---
  String _graphicsQuality = "Tinggi";
  double _drawDistance = 75.0;
  bool _shadowsEnabled = true;
  bool _reflectionsEnabled = true;
  bool _antiAliasing = false;

  // --- 4. PERFORMA & SISTEM ---
  bool _fastConnect = true;
  bool _autoReconnect = true;
  String _targetFps = "60 FPS";
  bool _dataSaver = false;

  // --- 5. TAMPILAN (HUD) ---
  bool _fpsCounter = true;
  bool _showPing = true;
  bool _vibrationEnabled = true;
  double _chatScale = 100.0;

  @override
  void initState() {
    super.initState();
    _ucpNameController = TextEditingController(text: AppConfig.nickname);
    _fastConnect = AppConfig.fastConnect;
    _fpsCounter = AppConfig.fpsCounter;
  }

  @override
  void dispose() {
    _ucpNameController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0: Navigator.pushReplacementNamed(context, '/home'); break;
      case 1: Navigator.pushReplacementNamed(context, '/dashboard'); break;
      case 2: Navigator.pushReplacementNamed(context, '/servers'); break;
      case 3: break; // Tetap di settings
    }
  }

  void _saveSettings() {
    setState(() {
      AppConfig.nickname = _ucpNameController.text.trim().isEmpty ? "Player" : _ucpNameController.text.trim();
      AppConfig.fastConnect = _fastConnect;
      AppConfig.fpsCounter = _fpsCounter;
      // Tambahkan penyimpanan variabel lain di sini jika diperlukan
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text("Pengaturan berhasil disimpan!", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: const Color(0xFF00B4D8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // --- WIDGET HELPER UNTUK TAMPILAN YANG RAPI ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: const Color(0xFF00B4D8)),
          const SizedBox(width: 10),
          Text(title.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitch(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      value: value,
      activeColor: const Color(0xFF00B4D8),
      activeTrackColor: const Color(0xFF00B4D8).withOpacity(0.3),
      onChanged: onChanged,
    );
  }

  Widget _buildSlider(String title, double value, double min, double max, Function(double) onChanged, String suffix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            Text("${value.toInt()}$suffix", style: const TextStyle(color: Color(0xFF00B4D8), fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF00B4D8),
            inactiveTrackColor: Colors.white10,
            thumbColor: const Color(0xFF00B4D8),
            overlayColor: const Color(0xFF00B4D8).withOpacity(0.2),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Row(
        children: [
          Sidebar(selectedIndex: _selectedIndex, onItemSelected: _onItemTapped),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(32.0),
              children: [
                const Text("PENGATURAN", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const Text("Sesuaikan pengalaman bermain SA-MP kamu", style: TextStyle(color: Colors.white54, fontSize: 14),),
                const SizedBox(height: 24),

                // 1. PROFIL
                _buildSectionTitle("Profil Karakter"),
                _buildCard([
                  TextField(
                    controller: _ucpNameController,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: "Nama UCP / Nickname",
                      hintText: "Contoh: John_Doe",
                      labelStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.account_circle, color: Color(0xFF00B4D8)),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00B4D8), width: 2)),
                    ),
                  ),
                ]),

                // 2. AUDIO & VOICE
                _buildSectionTitle("Audio & Onin Voice Chat"),
                _buildCard([
                  _buildSwitch("Aktifkan Voice Chat", "Komunikasi suara real-time dengan pemain lain", _voiceChatEnabled, (v) => setState(() => _voiceChatEnabled = v)),
                  const Divider(color: Colors.white10),
                  _buildSwitch("Spatial 3D Audio", "Suara mengikuti arah dan jarak karakter", _voice3D, (v) => setState(() => _voice3D = v)),
                  _buildSwitch("Mode Push To Talk (PTT)", "Tekan tombol mic untuk berbicara (Hemat bandwidth)", _pushToTalk, (v) => setState(() => _pushToTalk = v)),
                  const SizedBox(height: 12),
                  _buildSlider("Volume Voice", _voiceVolume, 0, 100, (v) => setState(() => _voiceVolume = v), "%"),
                  _buildSlider("Volume Musik (BGM)", _bgmVolume, 0, 100, (v) => setState(() => _bgmVolume = v), "%"),
                  _buildSlider("Volume Efek (SFX)", _sfxVolume, 0, 100, (v) => setState(() => _sfxVolume = v), "%"),
                ]),

                // 3. GRAFIK
                _buildSectionTitle("Grafik & Visual"),
                _buildCard([
                  DropdownButtonFormField<String>(
                    value: _graphicsQuality,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Kualitas Preset Grafik",
                      labelStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: ["Rendah (Hemat Baterai)", "Sedang", "Tinggi", "Ultra (HD)"].map((q) => DropdownMenuItem(value: q, child: Text(q))).toList(),
                    onChanged: (val) => setState(() => _graphicsQuality = val!),
                  ),
                  const SizedBox(height: 16),
                  _buildSlider("Jarak Pandang (Draw Distance)", _drawDistance, 20, 100, (v) => setState(() => _drawDistance = v), "%"),
                  const Divider(color: Colors.white10),
                  _buildSwitch("Bayangan Dinamis", "Tampilkan bayangan real-time pada objek", _shadowsEnabled, (v) => setState(() => _shadowsEnabled = v)),
                  _buildSwitch("Refleksi Kendaraan", "Efek kilau cat mobil dan genangan air", _reflectionsEnabled, (v) => setState(() => _reflectionsEnabled = v)),
                  _buildSwitch("Anti-Aliasing", "Menghaluskan tepi objek yang bergerigi", _antiAliasing, (v) => setState(() => _antiAliasing = v)),
                ]),

                // 4. PERFORMA & SISTEM
                _buildSectionTitle("Performa & Sistem"),
                _buildCard([
                  _buildSwitch("Fast Connect Mode", "Lewati pesan verifikasi saat masuk server", _fastConnect, (v) => setState(() => _fastConnect = v)),
                  _buildSwitch("Auto Reconnect", "Sambung kembali otomatis jika koneksi terputus", _autoReconnect, (v) => setState(() => _autoReconnect = v)),
                  _buildSwitch("Hemat Data (Data Saver)", "Kurangi penggunaan data untuk tekstur jarak jauh", _dataSaver, (v) => setState(() => _dataSaver = v)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _targetFps,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Batas Maksimal FPS",
                      labelStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: ["30 FPS", "60 FPS", "90 FPS", "120 FPS (Uncapped)"].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                    onChanged: (val) => setState(() => _targetFps = val!),
                  ),
                ]),

                // 5. TAMPILAN (HUD)
                _buildSectionTitle("Tampilan & HUD"),
                _buildCard([
                  _buildSwitch("Tampilkan FPS Counter", "Indikator performa frame per detik", _fpsCounter, (v) => setState(() => _fpsCounter = v)),
                  _buildSwitch("Tampilkan Indikator Ping", "Status latensi jaringan di pojok layar", _showPing, (v) => setState(() => _showPing = v)),
                  _buildSwitch("Getar (Vibration)", "Aktifkan getaran saat menerima notifikasi penting", _vibrationEnabled, (v) => setState(() => _vibrationEnabled = v)),
                  const SizedBox(height: 16),
                  _buildSlider("Skala Ukuran Chat", _chatScale, 50, 150, (v) => setState(() => _chatScale = v), "%"),
                ]),

                const SizedBox(height: 40),

                // TOMBOL SIMPAN
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B4D8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                      shadowColor: const Color(0xFF00B4D8).withOpacity(0.4),
                    ),
                    icon: const Icon(Icons.save_rounded, size: 24),
                    label: const Text("SIMPAN PERUBAHAN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ),
                const SizedBox(height: 32), // Spacer bawah agar tidak mepet
              ],
            ),
          ),
        ],
      ),
    );
  }
}
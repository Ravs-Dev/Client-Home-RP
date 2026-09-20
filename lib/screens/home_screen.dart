import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../widgets/sidebar.dart';
import '../services/server_query_service.dart';
import '../services/asset_extractor.dart'; // ← PERBAIKAN: Ganti download_service dengan asset_extractor

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  // State untuk Manajemen Grafik Lokal (Bukan Download)
  bool _isDataReady = false;
  bool _isChoosingGraphics = false;
  bool _isExtracting = false;
  double _extractProgress = 0.0;
  String _selectedGraphicsType = '';

  ServerStatus _status = ServerStatus(
    isOnline: false,
    players: 0,
    maxPlayers: 0,
    ping: 0,
    hostname: "HomeRoleplay",
    gamemode: "-",
    version: "-",
    isMaintenance: false,
    isStorm: false,
  );

  @override
  void initState() {
    super.initState();
    _initializeApp(); // ← PERBAIKAN: Cek status ekstraksi lokal
    _refreshServerStatus();
  }

  // === PERBAIKAN 1: Cek apakah data sudah diekstrak dari assets ===
  Future<void> _initializeApp() async {
    final hasChosen = await AssetExtractor.getGraphicsChoice();
    final isExtracted = await AssetExtractor.isDataExtracted();

    if (mounted) {
      if (hasChosen == null || !isExtracted) {
        // Belum pernah pilih atau belum diekstrak
        setState(() => _isChoosingGraphics = true);
      } else {
        // Sudah siap
        setState(() => _isDataReady = true);
      }
    }
  }

  // === PERBAIKAN 2: Fungsi untuk menangani pilihan dan ekstraksi ===
  void _handleGraphicsSelection(String type) async {
    setState(() {
      _isChoosingGraphics = false;
      _isExtracting = true;
      _selectedGraphicsType = type;
      _extractProgress = 0.0;
    });

    // Simpan pilihan user
    await AssetExtractor.saveGraphicsChoice(type);

    // Ekstrak file dari dalam APK (TANPA INTERNET)
    final success = await AssetExtractor.extractGraphicsData(
      type,
      onProgress: (progress) {
        if (mounted) {
          setState(() => _extractProgress = progress);
        }
      },
    );

    if (mounted) {
      setState(() {
        _isExtracting = false;
        _isDataReady = success;
      });

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal mengekstrak data. Pastikan file ZIP ada di folder assets/data/"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshServerStatus() async {
    setState(() => _isLoading = true);
    final status = await ServerQueryService.fetchServerStatus();
    if (mounted) {
      setState(() {
        _status = status;
        _isLoading = false;
      });
    }
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal membuka link: $url")),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0: break;
      case 1: Navigator.pushReplacementNamed(context, '/dashboard'); break;
      case 2: Navigator.pushReplacementNamed(context, '/servers'); break;
      case 3: Navigator.pushReplacementNamed(context, '/settings'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Tampilkan Layar Pilihan Grafik (Jika belum pilih)
    if (_isChoosingGraphics) {
      return _buildGraphicsSelectionScreen();
    }

    // 2. Tampilkan Layar Progress Ekstraksi (Sedang proses)
    if (_isExtracting) {
      return _buildExtractingScreen();
    }

    // 3. Fallback jika data belum siap
    if (!_isDataReady) {
      return _buildGraphicsSelectionScreen();
    }

    // 4. Tampilkan Home Screen Normal (Jika sudah siap)
    return _buildNormalHomeScreen();
  }

  // ==========================================
  // WIDGET: LAYAR PILIHAN GRAFIK
  // ==========================================
  Widget _buildGraphicsSelectionScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.folder_zip_rounded, color: Color(0xFF00B4D8), size: 64),
                const SizedBox(height: 16),
                const Text(
                  "Pilih Paket Grafik",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "File akan disiapkan secara otomatis dari aplikasi.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 32),

                _buildGraphicsCard(
                  title: "Grafik Biasa",
                  desc: "Ringan & Stabil. Cocok untuk HP spesifikasi standar.",
                  icon: Icons.battery_saver_rounded,
                  color: Colors.green,
                  onTap: () => _handleGraphicsSelection('biasa'),
                ),
                const SizedBox(height: 16),
                _buildGraphicsCard(
                  title: "Grafik Gangster (HD)",
                  desc: "Tekstur HD & ENB. Cocok untuk HP spesifikasi tinggi.",
                  icon: Icons.flash_on_rounded,
                  color: const Color(0xFF00B4D8),
                  onTap: () => _handleGraphicsSelection('gangster'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGraphicsCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET: LAYAR PROSES EKSTRAKSI
  // ==========================================
  Widget _buildExtractingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _selectedGraphicsType == 'gangster' ? Icons.flash_on_rounded : Icons.battery_saver_rounded,
                color: const Color(0xFF00B4D8),
                size: 64,
              ),
              const SizedBox(height: 24),
              Text(
                "Menyiapkan Paket ${_selectedGraphicsType == 'gangster' ? 'Gangster' : 'Biasa'}...", textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 8),
              const Text(
                "Mengekstrak file dari dalam aplikasi...",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _extractProgress,
                  minHeight: 10,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00B4D8)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "${(_extractProgress * 100).toInt()}%",
                style: const TextStyle(color: Color(0xFF00B4D8), fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET: HOME SCREEN NORMAL
  // ==========================================
  Widget _buildNormalHomeScreen() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    final bool isMaint = _status.isMaintenance;
    final bool isOn = _status.isOnline;
    final Color statusColor = isMaint ? Colors.orangeAccent : (isOn ? Colors.greenAccent : Colors.redAccent);
    final String statusText = isMaint ? "SERVER MAINTENANCE" : (isOn ? "SERVER ONLINE" : "SERVER OFFLINE");

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/flutter_assets/assets/bg/home_hood.webp',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              Container(color: Color(0xFF0F172A)),
            ),
          ),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.7))),
          SafeArea(
            child: Row(
              children: [
                Sidebar(selectedIndex: _selectedIndex, onItemSelected: _onItemTapped),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16.0 : 32.0, vertical: 24.0),
                    child: isSmallScreen
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(isSmallScreen),
                        const SizedBox(height: 16),
                        _buildServerInfo(statusColor, statusText, isSmallScreen),
                        const SizedBox(height: 20),
                        _buildActionButtons(isSmallScreen),
                        const SizedBox(height: 24),
                        _buildStatsPanel(isSmallScreen),
                      ],
                    )
                        : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(isSmallScreen),
                              const SizedBox(height: 16),
                              _buildServerInfo(statusColor, statusText, isSmallScreen),
                              const SizedBox(height: 20),
                              _buildActionButtons(isSmallScreen),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: _buildStatsPanel(isSmallScreen),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================
  Widget _buildHeader(bool isSmall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "HomeRoleplay",
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmall ? 24 : 34,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            height: 1.1,
          ),
        ),
        const Text(
          "SA-MP ROLEPLAY CLIENT",
          style: TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }

  Widget _buildServerInfo(Color statusColor, String statusText, bool isSmall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.circle, color: statusColor, size: isSmall ? 7 : 8),
            const SizedBox(width: 6),
            Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: isSmall ? 10 : 11,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "${AppConfig.serverIp}:${AppConfig.serverPort}",
          style: TextStyle(
            color: Colors.white70,
            fontSize: isSmall ? 11 : 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isSmall) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildActionButton(
          icon: Icons.play_arrow_rounded,
          label: "MASUK SERVER",
          color: const Color(0xFF00B4D8),
          onPressed: () => Navigator.pushNamed(context, '/video'),
        ),
        _buildActionButton(
          icon: Icons.refresh_rounded,
          label: "REFRESH",
          color: const Color(0xFF1E293B),
          isLoading: _isLoading,
          onPressed: _refreshServerStatus,
        ),
        _buildActionButton(
          icon: Icons.forum_rounded,
          label: "DISCORD",
          color: const Color(0xFF5865F2),
          onPressed: () => _openUrl("https://discord.gg/s4ZKX8vgcv"),
        ),
        _buildActionButton(
          icon: Icons.language_rounded,
          label: "WEBSITE",
          color: Colors.transparent,
          isOutlined: true,
          onPressed: () => _openUrl("https://home-roleplay.vercel.app/"),
        ),
      ],
    );
  }

  Widget _buildStatsPanel(bool isSmall) {
    return Column(
      children: [
        _StatWidgetTile(
          icon: Icons.people_alt_rounded,
          title: "PLAYERS",
          value: "${_status.players}/${_status.maxPlayers}",
          isSmall: isSmall,
        ),
        _StatWidgetTile(
          icon: Icons.wifi_rounded,
          title: "PING",
          value: "${_status.ping} ms",
          isSmall: isSmall,
        ),
        _StatWidgetTile(
          icon: Icons.sports_esports_rounded,
          title: "GAMEMODE",
          value: _status.gamemode,
          isSmall: isSmall,
        ),
        _StatWidgetTile(
          icon: Icons.info_outline_rounded,
          title: "VERSION",
          value: _status.version,
          isSmall: isSmall,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    bool isOutlined = false,
    bool isLoading = false,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? Colors.transparent : color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isOutlined ? const BorderSide(color: Colors.white30) : BorderSide.none,
        ),
        elevation: 0,
      ),
      icon: isLoading
          ? const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      )
          : Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
      ),
      onPressed: isLoading ? null : onPressed,
    );
  }
}

// ==========================================
// WIDGET STATISTIK
// ==========================================
class _StatWidgetTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isSmall;

  const _StatWidgetTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 12 : 16,
        vertical: isSmall ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00B4D8), size: isSmall ? 16 : 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: isSmall ? 9 : 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmall ? 12 : 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
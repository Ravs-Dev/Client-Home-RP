import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../main.dart';
import '../widgets/sidebar.dart';
import '../widgets/server_card.dart';
import '../widgets/server_detail_panel.dart';
import '../services/server_query_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 1;
  late VideoPlayerController _trailerController;
  bool _isTrailerInitialized = false;

  // State Data Dynamic Server - PERBAIKAN: Tambahkan parameter yang hilang
  bool _isFetchingServer = true;
  ServerStatus _serverStatus = ServerStatus(
    isOnline: true,
    players: 0,
    maxPlayers: 50,
    ping: 0,
    hostname: "HomeRoleplay",
    gamemode: "Home Roleplay",
    version: "0.3.7-R2",
    isMaintenance: false,
    isStorm: false,
  );

  @override
  void initState() {
    super.initState();
    _fetchServerData();

    // Memuat video trailer server dari assets
    _trailerController = VideoPlayerController.asset('assets/intro.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _isTrailerInitialized = true);
          _trailerController.setLooping(true);
          _trailerController.setVolume(0.5);
          _trailerController.play();
        }
      }).catchError((error) {
        debugPrint("Gagal memuat trailer video: $error");
      });
  }

  Future<void> _fetchServerData() async {
    setState(() => _isFetchingServer = true);
    final status = await ServerQueryService.fetchServerStatus();
    if (mounted) {
      setState(() {
        _serverStatus = status;
        _isFetchingServer = false;
      });
    }
  }

  @override
  void dispose() {
    _trailerController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/servers');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/flutter_assets/assets/bg/splash_lowrider.webp',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF0F172A)),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),
          SafeArea(
            child: Row(
              children: [
                Sidebar(
                  selectedIndex: _selectedIndex,
                  onItemSelected: _onItemTapped,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 12.0 : 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "DASHBOARD",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isSmallScreen ? 18 : 22,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Selamat datang, ${AppConfig.nickname}!",
                                    style: TextStyle(color: Colors.white70, fontSize: isSmallScreen ? 11 : 14),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                              onPressed: _fetchServerData,
                              tooltip: "Refresh Status",
                              padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 20),

                        Expanded(
                          child: isSmallScreen
                              ? _buildMobileLayout(isSmallScreen)
                              : _buildDesktopLayout(isSmallScreen),
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

  // Layout untuk HP (Vertikal)
  Widget _buildMobileLayout(bool isSmall) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ServerCard(
            serverName: "HomeRoleplay",
            ip: AppConfig.serverIp,
            port: AppConfig.serverPort,
            playerCount: "${_serverStatus.players}/${_serverStatus.maxPlayers}",
            ping: "${_serverStatus.ping} ms",
            isOnline: _serverStatus.isOnline,
            onConnect: () {
              Navigator.pushNamed(context, '/video');
            },
          ),
          SizedBox(height: isSmall ? 12 : 16),
          _buildVideoTrailer(isSmall),
          SizedBox(height: isSmall ? 12 : 16),
          SizedBox(
            height: 200,
            child: ServerDetailPanel(status: _serverStatus),
          ),
        ],
      ),
    );
  }

  // Layout untuk Desktop/Tablet (Horizontal)
  Widget _buildDesktopLayout(bool isSmall) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ServerCard(
                  serverName: "HomeRoleplay SA-MP",
                  ip: AppConfig.serverIp,
                  port: AppConfig.serverPort,
                  playerCount: "${_serverStatus.players}/${_serverStatus.maxPlayers}",
                  ping: "${_serverStatus.ping} ms",
                  isOnline: _serverStatus.isOnline,
                  onConnect: () {
                    Navigator.pushNamed(context, '/video');
                  },
                ),
                SizedBox(height: isSmall ? 12 : 16),
                _buildVideoTrailer(isSmall),
              ],
            ),
          ),
        ),
        SizedBox(width: isSmall ? 12 : 16),
        Expanded(
          flex: 1,
          child: ServerDetailPanel(status: _serverStatus),
        ),
      ],
    );
  }

  // Widget Video Trailer
  Widget _buildVideoTrailer(bool isSmall) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: EdgeInsets.all(isSmall ? 12.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.movie_creation_rounded, color: const Color(0xFF00B4D8), size: isSmall ? 16 : 20),
                  SizedBox(width: isSmall ? 6 : 8),
                  Text(
                    "TRAILER",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmall ? 12 : 14,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  _trailerController.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: const Color(0xFF00B4D8),
                  size: isSmall ? 24 : 28,
                ),
                onPressed: () {
                  setState(() {
                    _trailerController.value.isPlaying
                        ? _trailerController.pause()
                        : _trailerController.play();
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: isSmall ? 8 : 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: isSmall ? 160 : 220,
              width: double.infinity,
              color: Colors.black,
              child: _isTrailerInitialized
                  ? AspectRatio(
                aspectRatio: _trailerController.value.aspectRatio,
                child: VideoPlayer(_trailerController),
              )
                  : const Center(
                child: CircularProgressIndicator(color: Color(0xFF00B4D8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
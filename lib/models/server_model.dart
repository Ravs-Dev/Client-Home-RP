class ServerStatus {
  final bool online;
  final bool maintenance;
  final bool storm;

  final String hostname;
  final String address;

  final int players;
  final int maxPlayers;
  final int ping;

  final String gamemode;
  final String language;
  final String serverType;
  final String version;
  final String weather;
  final String worldTime;
  final String error;

  const ServerStatus({
    required this.online,
    required this.maintenance,
    required this.storm,
    required this.hostname,
    required this.address,
    required this.players,
    required this.maxPlayers,
    required this.ping,
    required this.gamemode,
    required this.language,
    required this.serverType,
    required this.version,
    required this.weather,
    required this.worldTime,
    this.error = '',
  });

  factory ServerStatus.offline({
    required String address,
    String error = '',
  }) {
    return ServerStatus(
      online: false,
      maintenance: false,
      storm: false,
      hostname: 'Server Offline',
      address: address,
      players: 0,
      maxPlayers: 0,
      ping: 0,
      gamemode: '-',
      language: '-',
      serverType: '-',
      version: '-',
      weather: '-',
      worldTime: '-',
      error: error,
    );
  }

  factory ServerStatus.unsupported({
    required String address,
  }) {
    return ServerStatus(
      online: false,
      maintenance: false,
      storm: false,
      hostname: 'Android Required',
      address: address,
      players: 0,
      maxPlayers: 0,
      ping: 0,
      gamemode: '-',
      language: '-',
      serverType: '-',
      version: '-',
      weather: '-',
      worldTime: '-',
      error: 'Query UDP tersedia di Android.',
    );
  }

  factory ServerStatus.fromMap(Map<dynamic, dynamic> map) {
    return ServerStatus(
      online: map['online'] == true,
      maintenance: map['maintenance'] == true,
      storm: map['storm'] == true,

      hostname: '${map['hostname'] ?? '-'}',
      address: '${map['address'] ?? '-'}',

      players: (map['players'] as num?)?.toInt() ?? 0,
      maxPlayers: (map['maxPlayers'] as num?)?.toInt() ?? 0,
      ping: (map['ping'] as num?)?.toInt() ?? 0,

      gamemode: '${map['gamemode'] ?? '-'}',
      language: '${map['language'] ?? '-'}',
      serverType: '${map['serverType'] ?? '-'}',
      version: '${map['version'] ?? '-'}',

      weather: '${map['weather'] ?? '-'}',
      worldTime: '${map['worldTime'] ?? '-'}',

      error: '${map['error'] ?? ''}',
    );
  }
}
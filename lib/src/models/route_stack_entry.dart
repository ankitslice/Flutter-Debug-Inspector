import 'map_codec.dart';

class RouteStackEntry {
  const RouteStackEntry({
    required this.routeName,
    required this.action,
    required this.timestampMs,
    required this.engineName,
  });

  final String routeName;
  final String action;
  final int timestampMs;
  final String engineName;

  factory RouteStackEntry.fromMap(Map<String, dynamic> map) {
    return RouteStackEntry(
      routeName: map['routeName'] as String? ?? '',
      action: map['action'] as String? ?? '',
      timestampMs: asInt(map['timestampMs']) ?? 0,
      engineName: map['engineName'] as String? ?? '',
    );
  }
}

import 'map_codec.dart';

enum ChannelTraceDirection { send, receive, broadcast }

class ChannelMessageRecord {
  const ChannelMessageRecord({
    required this.id,
    required this.timestampMs,
    required this.engineName,
    required this.channelName,
    this.channelInstanceId,
    required this.direction,
    required this.method,
    this.argsSummary,
    this.responseTimeMs,
  });

  final int id;
  final int timestampMs;
  final String engineName;
  final String channelName;
  final int? channelInstanceId;
  final ChannelTraceDirection direction;
  final String method;
  final String? argsSummary;
  final int? responseTimeMs;

  factory ChannelMessageRecord.fromMap(Map<String, dynamic> map) {
    final dir = map['direction'] as String? ?? 'SEND';
    return ChannelMessageRecord(
      id: asInt(map['id']) ?? 0,
      timestampMs: asInt(map['timestampMs']) ?? 0,
      engineName: map['engineName'] as String? ?? '',
      channelName: map['channelName'] as String? ?? '',
      channelInstanceId: asInt(map['channelInstanceId']),
      direction: _parseDirection(dir),
      method: map['method'] as String? ?? '',
      argsSummary: map['argsSummary'] as String?,
      responseTimeMs: asInt(map['responseTimeMs']),
    );
  }

  static ChannelTraceDirection _parseDirection(String raw) {
    switch (raw.toUpperCase()) {
      case 'RECEIVE':
        return ChannelTraceDirection.receive;
      case 'BROADCAST':
        return ChannelTraceDirection.broadcast;
      default:
        return ChannelTraceDirection.send;
    }
  }
}

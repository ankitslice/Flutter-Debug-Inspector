import 'map_codec.dart';

enum FlutterDebugWarningType { performance, lifecycle, state }

enum FlutterDebugSeverity { low, medium, high }

class DebugWarningRecord {
  const DebugWarningRecord({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    this.engineName,
    required this.timestampMs,
  });

  final String id;
  final FlutterDebugWarningType type;
  final FlutterDebugSeverity severity;
  final String message;
  final String? engineName;
  final int timestampMs;

  factory DebugWarningRecord.fromMap(Map<String, dynamic> map) {
    return DebugWarningRecord(
      id: map['id'] as String? ?? '',
      type: _parseType(map['type'] as String?),
      severity: _parseSeverity(map['severity'] as String?),
      message: map['message'] as String? ?? '',
      engineName: map['engineName'] as String?,
      timestampMs: asInt(map['timestampMs']) ?? 0,
    );
  }

  static FlutterDebugWarningType _parseType(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'LIFECYCLE':
        return FlutterDebugWarningType.lifecycle;
      case 'STATE':
        return FlutterDebugWarningType.state;
      default:
        return FlutterDebugWarningType.performance;
    }
  }

  static FlutterDebugSeverity _parseSeverity(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'HIGH':
        return FlutterDebugSeverity.high;
      case 'LOW':
        return FlutterDebugSeverity.low;
      default:
        return FlutterDebugSeverity.medium;
    }
  }
}

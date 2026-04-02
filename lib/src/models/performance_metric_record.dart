import 'map_codec.dart';

class PerformanceMetricRecord {
  const PerformanceMetricRecord({
    required this.timestampMs,
    this.engineName,
    required this.kind,
    required this.value,
    this.detail,
  });

  final int timestampMs;
  final String? engineName;
  final String kind;
  final double value;
  final String? detail;

  factory PerformanceMetricRecord.fromMap(Map<String, dynamic> map) {
    return PerformanceMetricRecord(
      timestampMs: asInt(map['timestampMs']) ?? 0,
      engineName: map['engineName'] as String?,
      kind: map['kind'] as String? ?? '',
      value: asDouble(map['value']),
      detail: map['detail'] as String?,
    );
  }
}

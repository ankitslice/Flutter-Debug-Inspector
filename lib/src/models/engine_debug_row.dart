import 'map_codec.dart';

class EngineDebugRow {
  const EngineDebugRow({
    required this.name,
    required this.engineState,
    required this.fragmentLifecycle,
    this.fragmentClass,
    required this.createdAtMs,
    this.dartExecutorHash,
  });

  final String name;
  final String engineState;
  final String fragmentLifecycle;
  final String? fragmentClass;
  final int createdAtMs;
  final int? dartExecutorHash;

  factory EngineDebugRow.fromMap(Map<String, dynamic> map) {
    return EngineDebugRow(
      name: map['name'] as String? ?? '',
      engineState: map['engineState'] as String? ?? '',
      fragmentLifecycle: map['fragmentLifecycle'] as String? ?? '',
      fragmentClass: map['fragmentClass'] as String?,
      createdAtMs: asInt(map['createdAtMs']) ?? 0,
      dartExecutorHash: asInt(map['dartExecutorHash']),
    );
  }
}

import 'channel_message_record.dart';
import 'debug_warning_record.dart';
import 'engine_debug_row.dart';
import 'map_codec.dart';
import 'performance_metric_record.dart';
import 'route_stack_entry.dart';

class FlutterDebugUiState {
  const FlutterDebugUiState({
    required this.engines,
    required this.channelMessages,
    required this.performanceMetrics,
    required this.warnings,
    required this.routeStacks,
    required this.routeHistory,
    required this.isOnL0Page,
    this.lastL0ChangeMs,
    required this.isHybridApp,
  });

  final List<EngineDebugRow> engines;
  final List<ChannelMessageRecord> channelMessages;
  final List<PerformanceMetricRecord> performanceMetrics;
  final List<DebugWarningRecord> warnings;
  final Map<String, List<String>> routeStacks;
  final List<RouteStackEntry> routeHistory;
  final bool isOnL0Page;
  final int? lastL0ChangeMs;
  final bool isHybridApp;

  factory FlutterDebugUiState.empty() => const FlutterDebugUiState(
        engines: [],
        channelMessages: [],
        performanceMetrics: [],
        warnings: [],
        routeStacks: {},
        routeHistory: [],
        isOnL0Page: true,
        lastL0ChangeMs: null,
        isHybridApp: false,
      );

  factory FlutterDebugUiState.fromMap(dynamic raw) {
    final map = decodeStringKeyMap(raw);
    final enginesRaw = map['engines'];
    final engines = enginesRaw is List
        ? enginesRaw
            .map((e) => EngineDebugRow.fromMap(decodeStringKeyMap(e)))
            .toList()
        : <EngineDebugRow>[];

    final msgRaw = map['channelMessages'];
    final messages = msgRaw is List
        ? msgRaw
            .map((e) => ChannelMessageRecord.fromMap(decodeStringKeyMap(e)))
            .toList()
        : <ChannelMessageRecord>[];

    final perfRaw = map['performanceMetrics'];
    final perf = perfRaw is List
        ? perfRaw
            .map((e) => PerformanceMetricRecord.fromMap(decodeStringKeyMap(e)))
            .toList()
        : <PerformanceMetricRecord>[];

    final warnRaw = map['warnings'];
    final warns = warnRaw is List
        ? warnRaw
            .map((e) => DebugWarningRecord.fromMap(decodeStringKeyMap(e)))
            .toList()
        : <DebugWarningRecord>[];

    final stacksRaw = map['routeStacks'];
    final stacks = <String, List<String>>{};
    if (stacksRaw is Map) {
      stacksRaw.forEach((k, v) {
        if (v is List) {
          stacks[k.toString()] =
              v.map((e) => e?.toString() ?? '').toList();
        }
      });
    }

    final histRaw = map['routeHistory'];
    final hist = histRaw is List
        ? histRaw
            .map((e) => RouteStackEntry.fromMap(decodeStringKeyMap(e)))
            .toList()
        : <RouteStackEntry>[];

    return FlutterDebugUiState(
      engines: engines,
      channelMessages: messages,
      performanceMetrics: perf,
      warnings: warns,
      routeStacks: stacks,
      routeHistory: hist,
      isOnL0Page: asBool(map['isOnL0Page'], fallback: true),
      lastL0ChangeMs: asInt(map['lastL0ChangeMs']),
      isHybridApp: asBool(map['isHybridApp']),
    );
  }
}

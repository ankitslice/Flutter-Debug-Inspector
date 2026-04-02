import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../debug_inspector_plugin.dart';

/// Subscribes to frame timings and reports slow frames and first-frame latency.
class FrameTimingCollector {
  FrameTimingCollector({
    this.engineName,
    this.slowFrameThresholdMs = 16,
  }) {
    _firstFrameStart = DateTime.now();
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_firstFrameReported && _firstFrameStart != null) {
        _firstFrameReported = true;
        final elapsed =
            DateTime.now().difference(_firstFrameStart!).inMilliseconds;
        FlutterDebugInspectorPlugin.reportFirstFrame(
          elapsedMs: elapsed,
          engineName: engineName,
        );
      }
    });
  }

  final String? engineName;
  final int slowFrameThresholdMs;

  DateTime? _firstFrameStart;
  bool _firstFrameReported = false;

  void _onTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      final totalMs = timing.totalSpan.inMilliseconds;
      if (totalMs > slowFrameThresholdMs) {
        FlutterDebugInspectorPlugin.reportSlowFrame(
          frameTimeMs: totalMs.toDouble(),
          engineName: engineName,
        );
      }
    }
  }

  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
  }
}

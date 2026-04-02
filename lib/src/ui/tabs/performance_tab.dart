import 'package:flutter/material.dart';

import '../../models/debug_ui_state.dart';
import '../../models/performance_metric_record.dart';
import '../inspector_theme.dart';
import '../widgets/section_header.dart';

class PerformanceTab extends StatelessWidget {
  const PerformanceTab({super.key, required this.state});

  final FlutterDebugUiState state;

  @override
  Widget build(BuildContext context) {
    final slow = state.performanceMetrics
        .where((m) => m.kind == 'slow_frame_ms')
        .toList();
    final first = state.performanceMetrics
        .where((m) => m.kind == 'first_frame_ms')
        .toList();
    final life = state.performanceMetrics
        .where((m) => m.kind == 'dart_lifecycle')
        .toList();
    final l0 = state.performanceMetrics
        .where((m) => m.kind == 'l0_status')
        .toList();
    final routes = state.performanceMetrics
        .where((m) => m.kind == 'route')
        .toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const SectionHeader('SUMMARY'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _SummaryCard(
                title: 'Slow frames',
                value: '${slow.length}',
                color: InspectorColors.accentOrange,
              ),
              const SizedBox(width: 8),
              _SummaryCard(
                title: 'First frame',
                value: first.isEmpty ? '—' : '${first.first.value.toInt()} ms',
                color: InspectorColors.accentGreen,
              ),
              const SizedBox(width: 8),
              _SummaryCard(
                title: 'L0',
                value: state.isOnL0Page ? 'ON' : 'OFF',
                color: InspectorColors.accentBlue,
              ),
            ],
          ),
        ),
        const SectionHeader('SLOW FRAMES'),
        ..._listOrPlaceholder(slow, _metricTile),
        const SectionHeader('FIRST FRAME'),
        ..._listOrPlaceholder(first, _metricTile),
        const SectionHeader('LIFECYCLE'),
        ..._listOrPlaceholder(life, _metricTile),
        const SectionHeader('L0 CHANGES'),
        ..._listOrPlaceholder(l0, _metricTile),
        const SectionHeader('ROUTES (METRICS)'),
        ..._listOrPlaceholder(routes, _metricTile),
      ],
    );
  }

  static List<Widget> _listOrPlaceholder(
    List<PerformanceMetricRecord> items,
    Widget Function(PerformanceMetricRecord) builder,
  ) {
    if (items.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            'No entries',
            style: TextStyle(color: InspectorColors.textMuted, fontSize: 13),
          ),
        ),
      ];
    }
    return items.map(builder).toList();
  }

  static Widget _metricTile(PerformanceMetricRecord m) {
    return ListTile(
      dense: true,
      title: Text(
        m.kind,
        style: const TextStyle(color: InspectorColors.textPrimary, fontSize: 14),
      ),
      subtitle: Text(
        [
          if (m.engineName != null) m.engineName,
          if (m.detail != null && m.detail!.isNotEmpty) m.detail,
          if (m.value != 0) m.value.toString(),
        ].whereType<String>().join(' · '),
        style: const TextStyle(color: InspectorColors.textMuted, fontSize: 11),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: InspectorColors.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: InspectorColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: InspectorColors.textMuted,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

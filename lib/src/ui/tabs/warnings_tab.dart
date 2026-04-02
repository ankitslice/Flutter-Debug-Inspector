import 'package:flutter/material.dart';

import '../../models/debug_ui_state.dart';
import '../../models/debug_warning_record.dart';
import '../inspector_theme.dart';
import '../widgets/section_header.dart';

class WarningsTab extends StatefulWidget {
  const WarningsTab({super.key, required this.state});

  final FlutterDebugUiState state;

  @override
  State<WarningsTab> createState() => _WarningsTabState();
}

class _WarningsTabState extends State<WarningsTab> {
  FlutterDebugSeverity? _severity;

  @override
  Widget build(BuildContext context) {
    var list = widget.state.warnings;
    if (_severity != null) {
      list = list.where((w) => w.severity == _severity).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              _chip('ALL', null),
              _chip('HIGH', FlutterDebugSeverity.high),
              _chip('MEDIUM', FlutterDebugSeverity.medium),
              _chip('LOW', FlutterDebugSeverity.low),
            ],
          ),
        ),
        const SectionHeader('WARNINGS'),
        Expanded(
          child: list.isEmpty
              ? const Center(
                  child: Text(
                    'No warnings',
                    style: TextStyle(color: InspectorColors.textMuted),
                  ),
                )
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) => _WarningCard(list[i]),
                ),
        ),
      ],
    );
  }

  Widget _chip(String label, FlutterDebugSeverity? sev) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _severity == sev,
        onSelected: (_) => setState(() => _severity = sev),
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard(this.w);

  final DebugWarningRecord w;

  @override
  Widget build(BuildContext context) {
    final sevColor = _severityColor(w.severity);
    final typeIcon = _typeIcon(w.type);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(typeIcon.icon, color: typeIcon.color, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: sevColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          w.severity.name.toUpperCase(),
                          style: TextStyle(
                            color: sevColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _time(w.timestampMs),
                        style: const TextStyle(
                          color: InspectorColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    w.message,
                    style: const TextStyle(
                      color: InspectorColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  if (w.engineName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        w.engineName!,
                        style: const TextStyle(
                          color: InspectorColors.textSecond,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _severityColor(FlutterDebugSeverity s) {
    switch (s) {
      case FlutterDebugSeverity.high:
        return InspectorColors.accentRed;
      case FlutterDebugSeverity.medium:
        return InspectorColors.accentYellow;
      case FlutterDebugSeverity.low:
        return InspectorColors.accentBlue;
    }
  }

  static ({IconData icon, Color color}) _typeIcon(FlutterDebugWarningType t) {
    switch (t) {
      case FlutterDebugWarningType.lifecycle:
        return (
          icon: Icons.sync_problem_rounded,
          color: InspectorColors.accentOrange,
        );
      case FlutterDebugWarningType.state:
        return (
          icon: Icons.warning_amber_rounded,
          color: InspectorColors.accentYellow,
        );
      case FlutterDebugWarningType.performance:
        return (
          icon: Icons.speed_rounded,
          color: InspectorColors.accentRed,
        );
    }
  }

  static String _time(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}:'
        '${d.second.toString().padLeft(2, '0')}';
  }
}

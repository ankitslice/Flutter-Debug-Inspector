import 'package:flutter/material.dart';

import '../../models/debug_ui_state.dart';
import '../../models/engine_debug_row.dart';
import '../inspector_theme.dart';
import '../widgets/engine_diagram.dart';
import '../widgets/section_header.dart';
import '../widgets/status_badge.dart';

class EnginesTab extends StatefulWidget {
  const EnginesTab({super.key, required this.state});

  final FlutterDebugUiState state;

  @override
  State<EnginesTab> createState() => _EnginesTabState();
}

class _EnginesTabState extends State<EnginesTab> {
  final Set<String> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final engines = widget.state.engines;
    if (engines.isEmpty) {
      return const Center(
        child: Text(
          'No Flutter engines registered.\n'
          'Hybrid apps should call the Android registry when engines are created.',
          textAlign: TextAlign.center,
          style: TextStyle(color: InspectorColors.textMuted, fontSize: 14),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: engines.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const SectionHeader('ACTIVE ENGINES');
        }
        final row = engines[index - 1];
        final expanded = _expanded.contains(row.name);
        return _EngineCard(
          row: row,
          expanded: expanded,
          onToggle: () {
            setState(() {
              if (expanded) {
                _expanded.remove(row.name);
              } else {
                _expanded.add(row.name);
              }
            });
          },
        );
      },
    );
  }
}

class _EngineCard extends StatelessWidget {
  const _EngineCard({
    required this.row,
    required this.expanded,
    required this.onToggle,
  });

  final EngineDebugRow row;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        color: InspectorColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        row.name,
                        style: const TextStyle(
                          color: InspectorColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    StatusBadge(
                      label: row.engineState,
                      color: InspectorColors.accentGreen,
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(
                      label: row.fragmentLifecycle,
                      color: InspectorColors.accentOrange,
                    ),
                    Icon(
                      expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: InspectorColors.textMuted,
                    ),
                  ],
                ),
                if (row.fragmentClass != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    row.fragmentClass!,
                    style: const TextStyle(
                      color: InspectorColors.textSecond,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (expanded) EngineDiagram(row: row),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

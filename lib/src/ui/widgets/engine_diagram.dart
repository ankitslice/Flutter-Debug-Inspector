import 'package:flutter/material.dart';

import '../../models/engine_debug_row.dart';
import '../inspector_theme.dart';

/// Simple object graph: Fragment → MethodChannel → DartExecutor → FlutterEngine.
class EngineDiagram extends StatelessWidget {
  const EngineDiagram({super.key, required this.row});

  final EngineDebugRow row;

  @override
  Widget build(BuildContext context) {
    final nodes = <String>[
      row.fragmentClass ?? 'Fragment',
      'MethodChannel',
      'DartExecutor${row.dartExecutorHash != null ? ' #${row.dartExecutorHash}' : ''}',
      'FlutterEngine (${row.name})',
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < nodes.length; i++) ...[
            _NodeCard(text: nodes[i]),
            if (i < nodes.length - 1) const _ArrowDown(),
          ],
        ],
      ),
    );
  }
}

class _ArrowDown extends StatelessWidget {
  const _ArrowDown();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: Icon(
          Icons.arrow_downward_rounded,
          size: 18,
          color: InspectorColors.textMuted,
        ),
      ),
    );
  }
}

class _NodeCard extends StatelessWidget {
  const _NodeCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: InspectorColors.bgCardAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: InspectorColors.divider),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: InspectorColors.textPrimary,
          fontSize: 13,
        ),
      ),
    );
  }
}

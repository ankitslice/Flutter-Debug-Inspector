import 'package:flutter/material.dart';

import '../../models/debug_ui_state.dart';
import '../../models/route_stack_entry.dart';
import '../inspector_theme.dart';
import '../widgets/section_header.dart';

class NavStackTab extends StatelessWidget {
  const NavStackTab({super.key, required this.state});

  final FlutterDebugUiState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const SectionHeader('ROUTE STACKS'),
        if (state.routeStacks.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No route data yet. Add DebugNavigatorObserver to MaterialApp.',
              style: TextStyle(color: InspectorColors.textMuted),
            ),
          )
        else
          ...state.routeStacks.entries.map(
            (e) => _StackSection(engineName: e.key, routes: e.value),
          ),
        const SectionHeader('HISTORY'),
        if (state.routeHistory.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Navigation events will appear here.',
              style: TextStyle(color: InspectorColors.textMuted, fontSize: 13),
            ),
          )
        else
          ...state.routeHistory.map(_HistoryTile.new),
      ],
    );
  }
}

class _StackSection extends StatelessWidget {
  const _StackSection({required this.engineName, required this.routes});

  final String engineName;
  final List<String> routes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            engineName,
            style: const TextStyle(
              color: InspectorColors.accentBlue,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          ...routes.asMap().entries.map((e) {
            final isTop = e.key == routes.length - 1;
            return _RoutePill(name: e.value, highlighted: isTop);
          }),
        ],
      ),
    );
  }
}

class _RoutePill extends StatelessWidget {
  const _RoutePill({required this.name, required this.highlighted});

  final String name;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final bg = highlighted
        ? InspectorColors.accentGreen.withValues(alpha: 0.12)
        : InspectorColors.bgCardAlt;
    final border = highlighted
        ? InspectorColors.accentGreen.withValues(alpha: 0.6)
        : InspectorColors.divider;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(
            highlighted ? Icons.place_rounded : Icons.layers_outlined,
            size: 18,
            color: highlighted
                ? InspectorColors.accentGreen
                : InspectorColors.textMuted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name.isEmpty ? '(unnamed)' : name,
              style: TextStyle(
                color: highlighted
                    ? InspectorColors.textPrimary
                    : InspectorColors.textSecond,
                fontWeight: highlighted ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile(this.entry);

  final RouteStackEntry entry;

  @override
  Widget build(BuildContext context) {
    final sym = _actionSymbol(entry.action);
    return ListTile(
      dense: true,
      leading: Text(
        sym.glyph,
        style: TextStyle(color: sym.color, fontSize: 18),
      ),
      title: Text(
        entry.routeName.isEmpty ? entry.action : entry.routeName,
        style: const TextStyle(color: InspectorColors.textPrimary, fontSize: 14),
      ),
      subtitle: Text(
        '${entry.engineName} · ${_formatTime(entry.timestampMs)}',
        style: const TextStyle(color: InspectorColors.textMuted, fontSize: 11),
      ),
    );
  }

  static String _formatTime(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}:'
        '${d.second.toString().padLeft(2, '0')}';
  }

  static ({String glyph, Color color}) _actionSymbol(String action) {
    switch (action) {
      case 'pop':
        return (glyph: '↑', color: InspectorColors.accentOrange);
      case 'replace':
        return (glyph: '⇄', color: InspectorColors.accentBlue);
      default:
        return (glyph: '↓', color: InspectorColors.accentGreen);
    }
  }
}

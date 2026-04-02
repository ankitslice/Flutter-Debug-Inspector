import 'package:flutter/material.dart';

import '../../models/channel_message_record.dart';
import '../../models/debug_ui_state.dart';
import '../inspector_theme.dart';
import '../widgets/section_header.dart';

class MessagesTab extends StatefulWidget {
  const MessagesTab({super.key, required this.state});

  final FlutterDebugUiState state;

  @override
  State<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  _DirFilter _dir = _DirFilter.all;
  String? _engineFilter;

  @override
  Widget build(BuildContext context) {
    final engines = widget.state.channelMessages
        .map((m) => m.engineName)
        .toSet()
        .toList()
      ..sort();

    var list = widget.state.channelMessages;
    if (_dir != _DirFilter.all) {
      list = list.where((m) {
        switch (_dir) {
          case _DirFilter.all:
            return true;
          case _DirFilter.send:
            return m.direction == ChannelTraceDirection.send;
          case _DirFilter.receive:
            return m.direction == ChannelTraceDirection.receive;
          case _DirFilter.broadcast:
            return m.direction == ChannelTraceDirection.broadcast;
        }
      }).toList();
    }
    if (_engineFilter != null) {
      list = list.where((m) => m.engineName == _engineFilter).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              _chip('All', _DirFilter.all),
              _chip('Sending', _DirFilter.send),
              _chip('Receiving', _DirFilter.receive),
              _chip('Broadcast', _DirFilter.broadcast),
            ],
          ),
        ),
        if (engines.length > 1)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All engines'),
                    selected: _engineFilter == null,
                    onSelected: (_) => setState(() => _engineFilter = null),
                  ),
                ),
                ...engines.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(e, overflow: TextOverflow.ellipsis),
                      selected: _engineFilter == e,
                      onSelected: (_) => setState(() => _engineFilter = e),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SectionHeader('CHANNEL MESSAGES'),
        Expanded(
          child: list.isEmpty
              ? const Center(
                  child: Text(
                    'No messages recorded.\n'
                    'Hybrid apps: instrument MethodChannel on Android.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: InspectorColors.textMuted),
                  ),
                )
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) => _MessageTile(list[i]),
                ),
        ),
      ],
    );
  }

  Widget _chip(String label, _DirFilter f) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _dir == f,
        onSelected: (_) => setState(() => _dir = f),
      ),
    );
  }
}

enum _DirFilter { all, send, receive, broadcast }

class _MessageTile extends StatefulWidget {
  const _MessageTile(this.m);

  final ChannelMessageRecord m;

  @override
  State<_MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<_MessageTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.m;
    final dir = _dirVisual(m.direction);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => setState(() => _open = !_open),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    dir.symbol,
                    style: TextStyle(
                      color: dir.color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      m.method,
                      style: const TextStyle(
                        color: InspectorColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (m.responseTimeMs != null)
                    Text(
                      '${m.responseTimeMs} ms',
                      style: const TextStyle(
                        color: InspectorColors.accentYellow,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${m.channelName}'
                '${m.channelInstanceId != null ? ' #${m.channelInstanceId}' : ''} · ${m.engineName}',
                style: const TextStyle(
                  color: InspectorColors.textMuted,
                  fontSize: 11,
                ),
              ),
              if (_open && m.argsSummary != null) ...[
                const SizedBox(height: 8),
                Text(
                  m.argsSummary!,
                  style: const TextStyle(
                    color: InspectorColors.textSecond,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static ({String symbol, Color color}) _dirVisual(ChannelTraceDirection d) {
    switch (d) {
      case ChannelTraceDirection.send:
        return (symbol: '→', color: InspectorColors.accentGreen);
      case ChannelTraceDirection.receive:
        return (symbol: '←', color: InspectorColors.accentBlue);
      case ChannelTraceDirection.broadcast:
        return (symbol: '⇶', color: InspectorColors.accentPurple);
    }
  }
}

import 'package:flutter/material.dart';

import '../debug_inspector_plugin.dart';
import '../models/debug_ui_state.dart';
import 'inspector_theme.dart';
import 'tabs/engines_tab.dart';
import 'tabs/messages_tab.dart';
import 'tabs/nav_stack_tab.dart';
import 'tabs/performance_tab.dart';
import 'tabs/warnings_tab.dart';

/// Live debug dashboard backed by [FlutterDebugInspectorPlugin.stateStream].
class DebugInspectorScreen extends StatelessWidget {
  const DebugInspectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: inspectorDarkTheme(),
      child: StreamBuilder<FlutterDebugUiState>(
        stream: FlutterDebugInspectorPlugin.stateStream,
        builder: (context, snapshot) {
          final state = snapshot.data ?? FlutterDebugUiState.empty();
          final hybrid = state.isHybridApp;
          final tabCount = hybrid ? 5 : 4;

          return DefaultTabController(
            key: ValueKey<bool>(hybrid),
            length: tabCount,
            child: Builder(
              builder: (context) {
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Flutter Inspector'),
                    actions: [
                      IconButton(
                        tooltip: 'Clear session',
                        onPressed: () =>
                            FlutterDebugInspectorPlugin.clearSession(),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                    bottom: TabBar(
                      isScrollable: true,
                      tabs: [
                        if (hybrid) const Tab(text: 'Engines'),
                        const Tab(text: 'Nav Stack'),
                        const Tab(text: 'Messages'),
                        const Tab(text: 'Perf'),
                        const Tab(text: 'Warnings'),
                      ],
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      if (hybrid) EnginesTab(state: state),
                      NavStackTab(state: state),
                      MessagesTab(state: state),
                      PerformanceTab(state: state),
                      WarningsTab(state: state),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

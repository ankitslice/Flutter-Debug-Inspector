import 'package:flutter/widgets.dart';

import '../debug_inspector_plugin.dart';

/// Reports [Navigator] transitions to the native debug registry.
class DebugNavigatorObserver extends NavigatorObserver {
  DebugNavigatorObserver({this.engineName});

  final String? engineName;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    FlutterDebugInspectorPlugin.reportRouteChange(
      action: 'push',
      from: previousRoute?.settings.name,
      to: route.settings.name,
      engineName: engineName,
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    FlutterDebugInspectorPlugin.reportRouteChange(
      action: 'pop',
      from: route.settings.name,
      to: previousRoute?.settings.name,
      engineName: engineName,
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    FlutterDebugInspectorPlugin.reportRouteChange(
      action: 'replace',
      from: oldRoute?.settings.name,
      to: newRoute?.settings.name,
      engineName: engineName,
    );
  }
}

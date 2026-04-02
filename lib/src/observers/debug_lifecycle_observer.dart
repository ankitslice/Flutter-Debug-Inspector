import 'package:flutter/widgets.dart';

import '../debug_inspector_plugin.dart';

/// Reports app lifecycle changes to the native debug registry.
class DebugLifecycleObserver with WidgetsBindingObserver {
  DebugLifecycleObserver({this.engineName}) {
    WidgetsBinding.instance.addObserver(this);
  }

  final String? engineName;

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    FlutterDebugInspectorPlugin.reportLifecycleChange(
      state: state.name,
      engineName: engineName,
    );
  }
}

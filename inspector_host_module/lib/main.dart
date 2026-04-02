import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debug_inspector/flutter_debug_inspector.dart';

/// Keep debug observers alive for the module lifetime.
final List<Object?> _inspectorKeepAlive = [];

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    FlutterDebugInspectorPlugin.setInspectorActive(active: true);
    _inspectorKeepAlive
      ..clear()
      ..add(FrameTimingCollector())
      ..add(DebugLifecycleObserver());
  }

  runApp(const InspectorHostApp());
}

/// Flutter module for embedding in a native Android app.
///
/// Routes:
/// * `/` — small shell with a button to open the inspector
/// * `/inspector` — full [DebugInspectorScreen] (use as [FlutterActivity] initial route)
class InspectorHostApp extends StatelessWidget {
  const InspectorHostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Debug Inspector',
      navigatorObservers: [
        if (kDebugMode) DebugNavigatorObserver(),
      ],
      initialRoute: '/',
      routes: {
        '/': (_) => const _HostShell(),
        '/inspector': (_) => const DebugInspectorScreen(),
      },
    );
  }
}

class _HostShell extends StatelessWidget {
  const _HostShell();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inspector host')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Flutter module is running. Open the inspector UI or use '
                'initialRoute /inspector from Android.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/inspector');
                },
                icon: const Icon(Icons.bug_report_outlined),
                label: const Text('Open debug inspector'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debug_inspector/flutter_debug_inspector.dart';

/// Holds debug-only observers for the lifetime of the isolate.
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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Debug Inspector Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorObservers: [
        if (kDebugMode) DebugNavigatorObserver(),
      ],
      initialRoute: '/',
      routes: {
        '/': (_) => const _HomePage(),
        '/second': (_) => const _SecondPage(),
      },
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  int _tapCount = 0;
  DateTime? _lastTap;

  void _onTap() {
    final now = DateTime.now();
    if (_lastTap == null ||
        now.difference(_lastTap!) > const Duration(milliseconds: 500)) {
      _tapCount = 0;
    }
    _lastTap = now;
    _tapCount++;
    if (_tapCount >= 3) {
      _tapCount = 0;
      if (!mounted) return;
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => const DebugInspectorScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspector example'),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: kDebugMode ? _onTap : null,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Debug: triple-tap anywhere to open the inspector.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/second');
                  },
                  child: const Text('Push route /second'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondPage extends StatelessWidget {
  const _SecondPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second')),
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Pop'),
        ),
      ),
    );
  }
}

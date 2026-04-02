import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_debug_inspector/flutter_debug_inspector.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getSnapshot returns UI state map', (WidgetTester tester) async {
    final state = await FlutterDebugInspectorPlugin.getSnapshot();
    expect(state.engines, isEmpty);
    expect(state.isHybridApp, isFalse);
  });
}

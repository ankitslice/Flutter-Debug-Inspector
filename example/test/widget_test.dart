import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_debug_inspector_example/main.dart';

void main() {
  testWidgets('Home page shows triple-tap hint', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.textContaining('triple-tap'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:inspector_host_module/main.dart';

void main() {
  testWidgets('Host shell renders', (WidgetTester tester) async {
    await tester.pumpWidget(const InspectorHostApp());
    expect(find.textContaining('Flutter module'), findsOneWidget);
    expect(find.text('Open debug inspector'), findsOneWidget);
  });
}

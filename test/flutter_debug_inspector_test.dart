import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_debug_inspector/flutter_debug_inspector.dart';

void main() {
  test('FlutterDebugUiState.fromMap parses empty map', () {
    final s = FlutterDebugUiState.fromMap(<String, dynamic>{});
    expect(s.engines, isEmpty);
    expect(s.channelMessages, isEmpty);
    expect(s.isHybridApp, isFalse);
  });

  test('FlutterDebugUiState.fromMap parses nested snapshot', () {
    final s = FlutterDebugUiState.fromMap(<String, dynamic>{
      'engines': [
        <String, dynamic>{
          'name': 'e1',
          'engineState': 'ACTIVE',
          'fragmentLifecycle': 'NONE',
          'createdAtMs': 1,
        },
      ],
      'isHybridApp': true,
    });
    expect(s.engines, hasLength(1));
    expect(s.engines.first.name, 'e1');
    expect(s.isHybridApp, isTrue);
  });
}

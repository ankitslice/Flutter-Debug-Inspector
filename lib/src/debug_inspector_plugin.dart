import 'package:flutter/services.dart';

import 'models/debug_ui_state.dart';

/// Method and event channel names must match [FlutterDebugContracts] on Android.
class FlutterDebugInspectorPlugin {
  FlutterDebugInspectorPlugin._();

  static const MethodChannel _methodChannel =
      MethodChannel('com.example.flutter_debug_inspector/methods');
  static const EventChannel _eventChannel =
      EventChannel('com.example.flutter_debug_inspector/events');

  /// Stream of UI state updates from the native registry (active while the event stream is listened to).
  static Stream<FlutterDebugUiState> get stateStream =>
      _eventChannel.receiveBroadcastStream().map(FlutterDebugUiState.fromMap);

  static Future<void> reportSlowFrame({
    required double frameTimeMs,
    String? engineName,
  }) async {
    await _methodChannel.invokeMethod<void>('onSlowFrame', <String, dynamic>{
      'frameTimeMs': frameTimeMs,
      if (engineName != null) 'engineName': engineName,
    });
  }

  static Future<void> reportFirstFrame({
    required int elapsedMs,
    String? engineName,
  }) async {
    await _methodChannel
        .invokeMethod<void>('onFirstFrameRendered', <String, dynamic>{
      'elapsedMs': elapsedMs,
      if (engineName != null) 'engineName': engineName,
    });
  }

  static Future<void> reportRouteChange({
    required String action,
    String? from,
    String? to,
    String? engineName,
  }) async {
    await _methodChannel.invokeMethod<void>('onRouteChange', <String, dynamic>{
      'action': action,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      if (engineName != null) 'engineName': engineName,
    });
  }

  static Future<void> reportLifecycleChange({
    required String state,
    String? engineName,
  }) async {
    await _methodChannel
        .invokeMethod<void>('onLifecycleChange', <String, dynamic>{
      'state': state,
      if (engineName != null) 'engineName': engineName,
    });
  }

  static Future<void> clearSession() async {
    await _methodChannel.invokeMethod<void>('clearSession');
  }

  static Future<bool> isHybridApp() async {
    final v = await _methodChannel.invokeMethod<bool>('isHybridApp');
    return v ?? false;
  }

  static Future<void> setInspectorActive({required bool active}) async {
    await _methodChannel
        .invokeMethod<void>('setInspectorActive', <String, dynamic>{
      'active': active,
    });
  }

  static Future<FlutterDebugUiState> getSnapshot() async {
    final raw = await _methodChannel.invokeMethod<dynamic>('getSnapshot');
    return FlutterDebugUiState.fromMap(raw);
  }
}

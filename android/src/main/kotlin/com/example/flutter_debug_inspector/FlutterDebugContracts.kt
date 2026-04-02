package com.example.flutter_debug_inspector

/**
 * Contracts for Flutter ↔ Native communication.
 *
 * The plugin exposes:
 *   - MethodChannel: "com.example.flutter_debug_inspector/methods"
 *   - EventChannel: "com.example.flutter_debug_inspector/events"
 */
object FlutterDebugContracts {

    const val METHOD_CHANNEL_NAME = "com.example.flutter_debug_inspector/methods"
    const val EVENT_CHANNEL_NAME = "com.example.flutter_debug_inspector/events"

    const val METRIC_ON_SLOW_FRAME = "onSlowFrame"
    const val METRIC_ON_FIRST_FRAME = "onFirstFrameRendered"
    const val METRIC_ON_LIFECYCLE = "onLifecycleChange"
    const val METRIC_ON_ROUTE_CHANGE = "onRouteChange"

    const val METHOD_GET_SNAPSHOT = "getSnapshot"
    const val METHOD_CLEAR_SESSION = "clearSession"
    const val METHOD_SET_ACTIVE = "setInspectorActive"
    const val METHOD_IS_HYBRID_APP = "isHybridApp"

    const val METHOD_ON_ENGINE_CREATED = "onEngineCreated"
    const val METHOD_ON_ENGINE_CONFIGURED = "onEngineConfigured"
    const val METHOD_ON_ENGINE_DESTROYED = "onEngineDestroyed"
    const val METHOD_ON_FRAGMENT_DESTROYED = "onFragmentDestroyed"
    const val METHOD_RECORD_CHANNEL_SEND = "recordChannelSend"
    const val METHOD_RECORD_CHANNEL_RECEIVE = "recordChannelReceive"
    const val METHOD_RECORD_BROADCAST = "recordBroadcast"
}

package com.example.flutter_debug_inspector

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

/**
 * EventChannel.StreamHandler that streams FlutterDebugRegistry snapshots to Flutter.
 */
class DebugEventStreamHandler : EventChannel.StreamHandler {

    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        FlutterDebugRegistry.setEventSink { snapshot ->
            mainHandler.post {
                eventSink?.success(snapshot)
            }
        }
        FlutterDebugRegistry.setInspectorSessionActive(true)
    }

    override fun onCancel(arguments: Any?) {
        FlutterDebugRegistry.setInspectorSessionActive(false)
        FlutterDebugRegistry.setEventSink(null)
        eventSink = null
    }
}

package com.example.flutter_debug_inspector

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Flutter plugin entry point.
 */
class FlutterDebugInspectorPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventStreamHandler: DebugEventStreamHandler? = null

    private val defaultEngineName = "default"

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(
            binding.binaryMessenger,
            FlutterDebugContracts.METHOD_CHANNEL_NAME
        )
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(
            binding.binaryMessenger,
            FlutterDebugContracts.EVENT_CHANNEL_NAME
        )
        eventStreamHandler = DebugEventStreamHandler()
        eventChannel.setStreamHandler(eventStreamHandler)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        eventStreamHandler = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            FlutterDebugContracts.METRIC_ON_SLOW_FRAME,
            FlutterDebugContracts.METRIC_ON_FIRST_FRAME,
            FlutterDebugContracts.METRIC_ON_LIFECYCLE,
            FlutterDebugContracts.METRIC_ON_ROUTE_CHANGE -> {
                val engineName = call.argument<String>("engineName") ?: defaultEngineName
                FlutterDebugRegistry.onFlutterDebugMetric(engineName, call.method, call.arguments)
                result.success(null)
            }

            FlutterDebugContracts.METHOD_GET_SNAPSHOT -> {
                val snapshot = FlutterDebugRegistry.getSnapshot()
                result.success(snapshot.toMap())
            }

            FlutterDebugContracts.METHOD_CLEAR_SESSION -> {
                FlutterDebugRegistry.clearSession()
                result.success(null)
            }

            FlutterDebugContracts.METHOD_SET_ACTIVE -> {
                val active = call.argument<Boolean>("active") ?: false
                FlutterDebugRegistry.setInspectorSessionActive(active)
                result.success(null)
            }

            FlutterDebugContracts.METHOD_IS_HYBRID_APP -> {
                result.success(FlutterDebugRegistry.isHybridApp)
            }

            FlutterDebugContracts.METHOD_ON_ENGINE_CREATED -> {
                val name = call.argument<String>("engineName")
                    ?: return result.error("INVALID", "Missing engineName", null)
                val dartHash = call.argument<Int>("dartExecutorHash")
                FlutterDebugRegistry.onEngineCreated(name, dartHash)
                result.success(null)
            }

            FlutterDebugContracts.METHOD_ON_ENGINE_CONFIGURED -> {
                val name = call.argument<String>("engineName")
                    ?: return result.error("INVALID", "Missing engineName", null)
                val fragment = call.argument<String>("fragmentClass")
                val dartHash = call.argument<Int>("dartExecutorHash")
                FlutterDebugRegistry.onEngineConfigured(name, fragment, dartHash)
                result.success(null)
            }

            FlutterDebugContracts.METHOD_ON_ENGINE_DESTROYED -> {
                val name = call.argument<String>("engineName")
                    ?: return result.error("INVALID", "Missing engineName", null)
                FlutterDebugRegistry.onEngineDestroyed(name)
                result.success(null)
            }

            FlutterDebugContracts.METHOD_ON_FRAGMENT_DESTROYED -> {
                val name = call.argument<String>("engineName")
                    ?: return result.error("INVALID", "Missing engineName", null)
                FlutterDebugRegistry.onFragmentDestroyed(name)
                result.success(null)
            }

            FlutterDebugContracts.METHOD_RECORD_CHANNEL_SEND -> {
                val engineName = call.argument<String>("engineName") ?: defaultEngineName
                val channelName = call.argument<String>("channelName") ?: ""
                val channelInstanceId = call.argument<Int>("channelInstanceId")
                val method = call.argument<String>("method") ?: ""
                val args = call.argument<Any>("arguments")
                val elapsedMs = call.argument<Long>("elapsedMs")

                if (elapsedMs != null) {
                    FlutterDebugRegistry.recordChannelSendCompleted(
                        engineName,
                        channelName,
                        channelInstanceId,
                        method,
                        args,
                        elapsedMs
                    )
                } else {
                    FlutterDebugRegistry.recordChannelSend(
                        engineName,
                        channelName,
                        channelInstanceId,
                        method,
                        args
                    )
                }
                result.success(null)
            }

            FlutterDebugContracts.METHOD_RECORD_CHANNEL_RECEIVE -> {
                val engineName = call.argument<String>("engineName") ?: defaultEngineName
                val channelName = call.argument<String>("channelName") ?: ""
                val channelInstanceId = call.argument<Int>("channelInstanceId")
                val method = call.argument<String>("method") ?: ""
                val args = call.argument<Any>("arguments")
                FlutterDebugRegistry.recordChannelReceive(
                    engineName,
                    channelName,
                    channelInstanceId,
                    method,
                    args
                )
                result.success(null)
            }

            FlutterDebugContracts.METHOD_RECORD_BROADCAST -> {
                val channelName = call.argument<String>("channelName") ?: ""
                val method = call.argument<String>("method") ?: ""
                val args = call.argument<Any>("arguments")
                val targets = call.argument<List<String>>("targetEngineNames") ?: emptyList()
                FlutterDebugRegistry.recordBroadcast(channelName, method, args, targets)
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    companion object {
        @JvmStatic
        val registry: FlutterDebugRegistry = FlutterDebugRegistry
    }
}

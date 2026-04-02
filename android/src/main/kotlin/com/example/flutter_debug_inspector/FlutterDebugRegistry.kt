package com.example.flutter_debug_inspector

import java.util.ArrayDeque
import java.util.UUID
import java.util.concurrent.atomic.AtomicLong

/**
 * In-memory debug hub for Flutter embedding.
 * Thread-safe; snapshots can be fetched from any thread.
 */
object FlutterDebugRegistry {

    private const val MAX_MESSAGES = 100
    private const val MAX_METRICS = 100
    private const val MAX_WARNINGS = 80

    private val idSeq = AtomicLong(1L)

    private val lock = Any()
    private val engines = mutableMapOf<String, EngineEntry>()
    private val messages = ArrayDeque<ChannelMessageRecord>(MAX_MESSAGES + 1)
    private val metrics = ArrayDeque<PerformanceMetricRecord>(MAX_METRICS + 1)
    private val warnings = ArrayDeque<DebugWarningRecord>(MAX_WARNINGS + 1)
    private val recentWarningKeys = ArrayDeque<String>(40)
    private val routeStacks = mutableMapOf<String, MutableList<String>>()
    private val routeHistory = ArrayDeque<RouteStackEntry>(60)

    @Volatile
    private var isOnL0Page: Boolean = true

    @Volatile
    private var lastL0ChangeMs: Long? = null

    @Volatile
    private var inspectorSessionActive: Boolean = false

    @Volatile
    var isHybridApp: Boolean = false

    private var eventSink: ((Map<String, Any?>) -> Unit)? = null

    private data class EngineEntry(
        var engineState: String,
        var fragmentLifecycle: String,
        var fragmentClass: String?,
        val createdAtMs: Long,
        var dartExecutorHash: Int?
    )

    fun isTracingEnabled(): Boolean = inspectorSessionActive

    fun setInspectorSessionActive(active: Boolean) {
        inspectorSessionActive = active
        if (active) emitSnapshot()
    }

    fun setEventSink(sink: ((Map<String, Any?>) -> Unit)?) {
        eventSink = sink
        if (sink != null && inspectorSessionActive) {
            emitSnapshot()
        }
    }

    private fun enabled(): Boolean = isTracingEnabled()

    private fun pushMessage(record: ChannelMessageRecord) {
        synchronized(lock) {
            while (messages.size >= MAX_MESSAGES) messages.removeFirst()
            messages.addLast(record)
        }
        emitSnapshot()
    }

    private fun pushMetric(record: PerformanceMetricRecord) {
        synchronized(lock) {
            while (metrics.size >= MAX_METRICS) metrics.removeFirst()
            metrics.addLast(record)
        }
        emitSnapshot()
    }

    private fun pushWarning(record: DebugWarningRecord) {
        synchronized(lock) {
            while (warnings.size >= MAX_WARNINGS) warnings.removeFirst()
            warnings.addLast(record)
        }
        emitSnapshot()
    }

    private fun emitSnapshot() {
        if (!enabled()) return
        val snapshot = buildSnapshotLocked()
        eventSink?.invoke(snapshot.toMap())
    }

    private fun buildSnapshotLocked(): FlutterDebugUiState {
        synchronized(lock) {
            val engineRows = engines.map { (name, e) ->
                FlutterEngineDebugRow(
                    name = name,
                    engineState = e.engineState,
                    fragmentLifecycle = e.fragmentLifecycle,
                    fragmentClass = e.fragmentClass,
                    createdAtMs = e.createdAtMs,
                    dartExecutorHash = e.dartExecutorHash
                )
            }.sortedBy { it.name }
            return FlutterDebugUiState(
                engines = engineRows,
                channelMessages = messages.toList().asReversed(),
                performanceMetrics = metrics.toList().asReversed(),
                warnings = warnings.toList().asReversed(),
                routeStacks = routeStacks.mapValues { it.value.toList() },
                routeHistory = routeHistory.toList().asReversed(),
                isOnL0Page = isOnL0Page,
                lastL0ChangeMs = lastL0ChangeMs,
                isHybridApp = isHybridApp
            )
        }
    }

    fun getSnapshot(): FlutterDebugUiState = buildSnapshotLocked()

    fun refresh() {
        if (!enabled()) return
        emitSnapshot()
    }

    fun onEngineCreated(engineName: String, dartExecutorHash: Int?) {
        if (!enabled()) return
        synchronized(lock) {
            engines[engineName] = EngineEntry(
                engineState = "ACTIVE",
                fragmentLifecycle = "NONE",
                fragmentClass = null,
                createdAtMs = System.currentTimeMillis(),
                dartExecutorHash = dartExecutorHash
            )
        }
        emitSnapshot()
    }

    fun onEngineConfigured(engineName: String, fragmentSimpleName: String?, dartExecutorHash: Int?) {
        if (!enabled()) return
        synchronized(lock) {
            val existing = engines[engineName]
            if (existing != null) {
                existing.fragmentLifecycle = "CONFIGURED"
                existing.fragmentClass = fragmentSimpleName
                existing.dartExecutorHash = dartExecutorHash ?: existing.dartExecutorHash
            } else {
                engines[engineName] = EngineEntry(
                    engineState = "ACTIVE",
                    fragmentLifecycle = "CONFIGURED",
                    fragmentClass = fragmentSimpleName,
                    createdAtMs = System.currentTimeMillis(),
                    dartExecutorHash = dartExecutorHash
                )
            }
        }
        emitSnapshot()
    }

    fun onFragmentDestroyed(engineName: String) {
        if (!enabled()) return
        synchronized(lock) {
            engines[engineName]?.fragmentLifecycle = "FRAGMENT_DESTROYED"
        }
        emitSnapshot()
    }

    fun onEngineDestroyed(engineName: String) {
        if (!enabled()) return
        synchronized(lock) {
            engines.remove(engineName)
        }
        emitSnapshot()
    }

    fun markEngineState(engineName: String, state: String) {
        if (!enabled()) return
        synchronized(lock) {
            engines[engineName]?.engineState = state
        }
        emitSnapshot()
    }

    fun onL0PageStatusChanged(wasL0: Boolean, isL0: Boolean) {
        if (!enabled()) return
        isOnL0Page = isL0
        lastL0ChangeMs = System.currentTimeMillis()
        pushMetric(
            PerformanceMetricRecord(
                timestampMs = lastL0ChangeMs!!,
                engineName = null,
                kind = "l0_status",
                value = if (isL0) 1.0 else 0.0,
                detail = "wasL0=$wasL0 -> isL0=$isL0"
            )
        )
    }

    fun recordChannelReceive(
        engineName: String,
        channelName: String,
        channelInstanceId: Int?,
        method: String,
        arguments: Any?
    ) {
        if (!enabled()) return
        pushMessage(
            ChannelMessageRecord(
                id = idSeq.getAndIncrement(),
                timestampMs = System.currentTimeMillis(),
                engineName = engineName,
                channelName = channelName,
                channelInstanceId = channelInstanceId,
                direction = ChannelTraceDirection.RECEIVE,
                method = method,
                argsSummary = summarizeArgs(arguments),
                responseTimeMs = null
            )
        )
    }

    fun recordChannelSend(
        engineName: String,
        channelName: String,
        channelInstanceId: Int?,
        method: String,
        arguments: Any?
    ) {
        if (!enabled()) return
        pushMessage(
            ChannelMessageRecord(
                id = idSeq.getAndIncrement(),
                timestampMs = System.currentTimeMillis(),
                engineName = engineName,
                channelName = channelName,
                channelInstanceId = channelInstanceId,
                direction = ChannelTraceDirection.SEND,
                method = method,
                argsSummary = summarizeArgs(arguments),
                responseTimeMs = null
            )
        )
    }

    fun recordChannelSendCompleted(
        engineName: String,
        channelName: String,
        channelInstanceId: Int?,
        method: String,
        arguments: Any?,
        elapsedMs: Long
    ) {
        if (!enabled()) return
        WarningsEngine.onSlowChannelReply(engineName, method, elapsedMs)
        pushMessage(
            ChannelMessageRecord(
                id = idSeq.getAndIncrement(),
                timestampMs = System.currentTimeMillis(),
                engineName = engineName,
                channelName = channelName,
                channelInstanceId = channelInstanceId,
                direction = ChannelTraceDirection.SEND,
                method = method,
                argsSummary = summarizeArgs(arguments),
                responseTimeMs = elapsedMs
            )
        )
    }

    fun recordBroadcast(
        channelName: String,
        method: String,
        arguments: Any?,
        targetEngineNames: List<String>
    ) {
        if (!enabled()) return
        val targets = targetEngineNames.joinToString(",")
        pushMessage(
            ChannelMessageRecord(
                id = idSeq.getAndIncrement(),
                timestampMs = System.currentTimeMillis(),
                engineName = targets.ifEmpty { "all" },
                channelName = channelName,
                channelInstanceId = null,
                direction = ChannelTraceDirection.BROADCAST,
                method = method,
                argsSummary = summarizeArgs(arguments),
                responseTimeMs = null
            )
        )
    }

    fun onFlutterDebugMetric(engineName: String, method: String, arguments: Any?) {
        if (!enabled()) return
        when (method) {
            FlutterDebugContracts.METRIC_ON_SLOW_FRAME -> {
                val ms = (arguments as? Map<*, *>)?.get("frameTimeMs") as? Number
                val v = ms?.toDouble() ?: return
                pushMetric(
                    PerformanceMetricRecord(
                        timestampMs = System.currentTimeMillis(),
                        engineName = engineName,
                        kind = "slow_frame_ms",
                        value = v,
                        detail = null
                    )
                )
                WarningsEngine.onSlowFrame(engineName, v)
            }
            FlutterDebugContracts.METRIC_ON_FIRST_FRAME -> {
                val elapsed = (arguments as? Map<*, *>)?.get("elapsedMs") as? Number
                val e = elapsed?.toLong() ?: return
                pushMetric(
                    PerformanceMetricRecord(
                        timestampMs = System.currentTimeMillis(),
                        engineName = engineName,
                        kind = "first_frame_ms",
                        value = e.toDouble(),
                        detail = null
                    )
                )
                WarningsEngine.onFirstFrameDelayed(engineName, e)
            }
            FlutterDebugContracts.METRIC_ON_LIFECYCLE -> {
                WarningsEngine.onFastFrame(engineName)
                val state = (arguments as? Map<*, *>)?.get("state")?.toString()
                pushMetric(
                    PerformanceMetricRecord(
                        timestampMs = System.currentTimeMillis(),
                        engineName = engineName,
                        kind = "dart_lifecycle",
                        value = 0.0,
                        detail = state
                    )
                )
            }
            FlutterDebugContracts.METRIC_ON_ROUTE_CHANGE -> {
                WarningsEngine.onFastFrame(engineName)
                val action = (arguments as? Map<*, *>)?.get("action")?.toString() ?: ""
                val from = (arguments as? Map<*, *>)?.get("from")?.toString()
                val to = (arguments as? Map<*, *>)?.get("to")?.toString()

                synchronized(lock) {
                    val stack = routeStacks.getOrPut(engineName) { mutableListOf() }
                    when (action) {
                        "push" -> to?.let { stack.add(it) }
                        "pop" -> if (stack.isNotEmpty()) stack.removeAt(stack.lastIndex)
                        "replace" -> {
                            if (stack.isNotEmpty()) stack.removeAt(stack.lastIndex)
                            to?.let { stack.add(it) }
                        }
                    }
                    while (routeHistory.size >= 50) routeHistory.removeFirst()
                    routeHistory.addLast(
                        RouteStackEntry(
                            routeName = to ?: from ?: action,
                            action = action,
                            timestampMs = System.currentTimeMillis(),
                            engineName = engineName
                        )
                    )
                }
                pushMetric(
                    PerformanceMetricRecord(
                        timestampMs = System.currentTimeMillis(),
                        engineName = engineName,
                        kind = "route",
                        value = 0.0,
                        detail = "$action $from -> $to"
                    )
                )
            }
            else -> {
                pushMetric(
                    PerformanceMetricRecord(
                        timestampMs = System.currentTimeMillis(),
                        engineName = engineName,
                        kind = method,
                        value = 0.0,
                        detail = arguments?.toString()
                    )
                )
            }
        }
    }

    fun addWarning(
        type: FlutterDebugWarningType,
        severity: FlutterDebugSeverity,
        message: String,
        engineName: String?
    ) {
        if (!enabled()) return
        val dedupeKey = "${engineName.orEmpty()}|$message"
        synchronized(lock) {
            if (recentWarningKeys.contains(dedupeKey)) return
            recentWarningKeys.addLast(dedupeKey)
            while (recentWarningKeys.size > 30) recentWarningKeys.removeFirst()
        }
        pushWarning(
            DebugWarningRecord(
                id = UUID.randomUUID().toString(),
                type = type,
                severity = severity,
                message = message,
                engineName = engineName,
                timestampMs = System.currentTimeMillis()
            )
        )
    }

    fun notifyOutboundInvokeChecks(
        engineName: String,
        method: String,
        isAdded: Boolean,
        hasActivity: Boolean,
        hasNavigated: Boolean
    ) {
        if (!enabled()) return
        if (!isAdded || !hasActivity) {
            addWarning(
                FlutterDebugWarningType.LIFECYCLE,
                FlutterDebugSeverity.HIGH,
                "invokeMethod('$method') while fragment not attached",
                engineName
            )
        }
        if (!hasNavigated) {
            addWarning(
                FlutterDebugWarningType.LIFECYCLE,
                FlutterDebugSeverity.MEDIUM,
                "invokeMethod('$method') before Flutter UI displayed (may race setup)",
                engineName
            )
        }
    }

    fun clearSession() {
        synchronized(lock) {
            messages.clear()
            metrics.clear()
            warnings.clear()
            recentWarningKeys.clear()
            routeStacks.clear()
            routeHistory.clear()
        }
        WarningsEngine.clear()
        emitSnapshot()
    }

    private fun summarizeArgs(arguments: Any?): String? {
        if (arguments == null) return null
        val s = arguments.toString()
        return if (s.length > 240) s.take(240) + "…" else s
    }
}

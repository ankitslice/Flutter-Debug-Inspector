package com.example.flutter_debug_inspector

import java.util.concurrent.ConcurrentHashMap

/**
 * Derives higher-level warnings from raw metrics (slow frames, slow channel replies, etc.).
 */
internal object WarningsEngine {

    private val consecutiveSlowFramesByEngine = ConcurrentHashMap<String, Int>()

    fun onSlowFrame(engineName: String?, frameTimeMs: Double) {
        val key = engineName.orEmpty().ifEmpty { "default" }
        val next = (consecutiveSlowFramesByEngine[key] ?: 0) + 1
        consecutiveSlowFramesByEngine[key] = next
        when {
            next == 3 -> FlutterDebugRegistry.addWarning(
                type = FlutterDebugWarningType.PERFORMANCE,
                severity = FlutterDebugSeverity.HIGH,
                message = "Jank: 3 consecutive slow frames (last ${"%.1f".format(frameTimeMs)}ms)",
                engineName = engineName
            )
            next == 1 -> FlutterDebugRegistry.addWarning(
                type = FlutterDebugWarningType.PERFORMANCE,
                severity = FlutterDebugSeverity.LOW,
                message = "Slow frame: ${"%.1f".format(frameTimeMs)}ms",
                engineName = engineName
            )
        }
    }

    fun onFastFrame(engineName: String?) {
        val key = engineName.orEmpty().ifEmpty { "default" }
        consecutiveSlowFramesByEngine[key] = 0
    }

    fun resetSlowFrameStreak(engineName: String?) {
        val key = engineName.orEmpty().ifEmpty { "default" }
        consecutiveSlowFramesByEngine[key] = 0
    }

    fun onFirstFrameDelayed(engineName: String?, elapsedMs: Long) {
        if (elapsedMs > 2000) {
            FlutterDebugRegistry.addWarning(
                type = FlutterDebugWarningType.PERFORMANCE,
                severity = FlutterDebugSeverity.HIGH,
                message = "First frame took ${elapsedMs}ms",
                engineName = engineName
            )
        }
    }

    fun onSlowChannelReply(engineName: String?, method: String, elapsedMs: Long) {
        if (elapsedMs > 500) {
            FlutterDebugRegistry.addWarning(
                type = FlutterDebugWarningType.PERFORMANCE,
                severity = FlutterDebugSeverity.MEDIUM,
                message = "Slow channel reply: '$method' took ${elapsedMs}ms",
                engineName = engineName
            )
        }
    }

    fun clear() {
        consecutiveSlowFramesByEngine.clear()
    }
}

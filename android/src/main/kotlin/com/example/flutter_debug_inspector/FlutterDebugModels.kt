package com.example.flutter_debug_inspector

enum class ChannelTraceDirection {
    SEND,
    RECEIVE,
    BROADCAST
}

enum class FlutterDebugSeverity {
    LOW,
    MEDIUM,
    HIGH
}

enum class FlutterDebugWarningType {
    PERFORMANCE,
    LIFECYCLE,
    STATE
}

data class FlutterEngineDebugRow(
    val name: String,
    val engineState: String,
    val fragmentLifecycle: String,
    val fragmentClass: String?,
    val createdAtMs: Long,
    val dartExecutorHash: Int?
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "name" to name,
        "engineState" to engineState,
        "fragmentLifecycle" to fragmentLifecycle,
        "fragmentClass" to fragmentClass,
        "createdAtMs" to createdAtMs,
        "dartExecutorHash" to dartExecutorHash
    )
}

data class ChannelMessageRecord(
    val id: Long,
    val timestampMs: Long,
    val engineName: String,
    val channelName: String,
    val channelInstanceId: Int?,
    val direction: ChannelTraceDirection,
    val method: String,
    val argsSummary: String?,
    val responseTimeMs: Long?
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "id" to id,
        "timestampMs" to timestampMs,
        "engineName" to engineName,
        "channelName" to channelName,
        "channelInstanceId" to channelInstanceId,
        "direction" to direction.name,
        "method" to method,
        "argsSummary" to argsSummary,
        "responseTimeMs" to responseTimeMs
    )
}

data class PerformanceMetricRecord(
    val timestampMs: Long,
    val engineName: String?,
    val kind: String,
    val value: Double,
    val detail: String?
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "timestampMs" to timestampMs,
        "engineName" to engineName,
        "kind" to kind,
        "value" to value,
        "detail" to detail
    )
}

data class DebugWarningRecord(
    val id: String,
    val type: FlutterDebugWarningType,
    val severity: FlutterDebugSeverity,
    val message: String,
    val engineName: String?,
    val timestampMs: Long
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "id" to id,
        "type" to type.name,
        "severity" to severity.name,
        "message" to message,
        "engineName" to engineName,
        "timestampMs" to timestampMs
    )
}

data class RouteStackEntry(
    val routeName: String,
    val action: String,
    val timestampMs: Long,
    val engineName: String
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "routeName" to routeName,
        "action" to action,
        "timestampMs" to timestampMs,
        "engineName" to engineName
    )
}

data class FlutterDebugUiState(
    val engines: List<FlutterEngineDebugRow>,
    val channelMessages: List<ChannelMessageRecord>,
    val performanceMetrics: List<PerformanceMetricRecord>,
    val warnings: List<DebugWarningRecord>,
    val routeStacks: Map<String, List<String>>,
    val routeHistory: List<RouteStackEntry>,
    val isOnL0Page: Boolean,
    val lastL0ChangeMs: Long?,
    val isHybridApp: Boolean
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "engines" to engines.map { it.toMap() },
        "channelMessages" to channelMessages.map { it.toMap() },
        "performanceMetrics" to performanceMetrics.map { it.toMap() },
        "warnings" to warnings.map { it.toMap() },
        "routeStacks" to routeStacks,
        "routeHistory" to routeHistory.map { it.toMap() },
        "isOnL0Page" to isOnL0Page,
        "lastL0ChangeMs" to lastL0ChangeMs,
        "isHybridApp" to isHybridApp
    )
}

package com.example.flutter_debug_inspector

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.mockito.Mockito
import kotlin.test.Test

internal class FlutterDebugInspectorPluginTest {
    @Test
    fun onMethodCall_getSnapshot_returnsMap() {
        val plugin = FlutterDebugInspectorPlugin()
        val call = MethodCall(FlutterDebugContracts.METHOD_GET_SNAPSHOT, null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)
        Mockito.verify(mockResult).success(Mockito.any())
    }
}

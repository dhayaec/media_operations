package com.dhayanandhan.media_operations

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class MediaOperationsPlugin : MethodCallHandler {
    private val channelName = "media_operations"
    private val utility = Utility(channelName)
    private var ffmpegCommander: FFmpegCommander? = null

    companion object {
        private lateinit var reg: Registrar
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "media_operations")
            channel.setMethodCallHandler(MediaOperationsPlugin())
            reg = registrar
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        initFfmpegCommanderIfNeeded()

        when (call.method) {
            "getPlatformVersion" -> {
                val osVersion = "Android ${android.os.Build.VERSION.RELEASE} and ${android.os.Build.VERSION.SDK_INT}"
                result.success(osVersion)
            }
            "getMediaInfo" -> {
                val path = call.argument<String>("path")!!
                var info = utility.getMediaInfoJson(reg.context(), path)
                result.success(info.toString())
            }
            "splitVideo" -> {
                val commands = call.argument<ArrayList<String>>("commands")!!
                val path = call.argument<String>("path")!!
                ffmpegCommander?.execFFmpegBinary(commands, path, result, reg.messenger())
            }
            else -> result.notImplemented()
        }
    }

    private fun initFfmpegCommanderIfNeeded() {
        if (ffmpegCommander == null) {
            ffmpegCommander = FFmpegCommander(reg.context(), channelName)
        }
    }
}

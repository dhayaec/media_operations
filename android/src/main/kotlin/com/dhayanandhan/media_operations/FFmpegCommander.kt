package com.dhayanandhan.media_operations

import android.content.Context
import io.flutter.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import nl.bravobit.ffmpeg.ExecuteBinaryResponseHandler
import nl.bravobit.ffmpeg.FFmpeg
import nl.bravobit.ffmpeg.FFtask
import java.io.File


class FFmpegCommander(private val context: Context, private val channelName: String) {

    private var ffTask: FFtask? = null
    private val utility = Utility(channelName)
    private var totalTime: Long = 0
    private val TAG = "MEDIA_OPERATIONS"

    fun execFFmpegBinary(command: ArrayList<String>, path: String, result: MethodChannel.Result,
                         messenger: BinaryMessenger) {

        val ffmpeg = FFmpeg.getInstance(context)

        if (!ffmpeg.isSupported) {
            return result.error(channelName, "$TAG Error",
                    "ffmpeg isn't supported this platform")
        }

        val dir = context.getExternalFilesDir("media_operations")

        if (dir != null && !dir.exists()) dir.mkdirs()

        val file = File(dir, path.substring(path.lastIndexOf("/")))

        utility.deleteFile(file)

        val array = arrayOfNulls<String>(command.size)
        command.toArray(array)

        try {

            this.ffTask = ffmpeg.execute(array, object : ExecuteBinaryResponseHandler() {
                override fun onFailure(s: String?) {
                    Log.d(TAG, "FAILED with output : " + s!!)
                }

                override fun onSuccess(s: String?) {
                    // Log.d(TAG, "SUCCESS with output : " + s!!)

                }

                override fun onProgress(s: String?) {
                    // Log.d(TAG, "Started command : ffmpeg $command")

                    // Log.d(TAG, "progress : $s")
                    notifyProgress("$s", messenger)

                }

                override fun onStart() {
                    // Log.d(TAG, "Started command : ffmpeg $command")
                }

                override fun onFinish() {
                    // Log.d(TAG, "Finished command : ffmpeg $command")
                    result.success(file.absolutePath)
                    totalTime = 0
                }
            })
        } catch (e: Exception) {
            result.error(e.message, "$TAG Error", "Already running")
        }

    }

    private fun notifyProgress(message: String, messenger: BinaryMessenger) {
        if ("Duration" in message) {
            val reg = Regex("""Duration: ((\d{2}:){2}\d{2}\.\d{2}).*""")
            val totalTimeStr = message.replace(reg, "$1")
            totalTime = utility.timeStrToTimestamp(totalTimeStr.trim())
        }

        if ("frame=" in message) {
            try {
                val reg = Regex("""frame.*time=((\d{2}:){2}\d{2}\.\d{2}).*""")
                val totalTimeStr = message.replace(reg, "$1")
                val time = utility.timeStrToTimestamp(totalTimeStr.trim())
                MethodChannel(messenger, channelName)
                        .invokeMethod("updateProgress", ((time / totalTime) * 100).toString())
            } catch (e: Exception) {
                print(e.stackTrace)
            }
        }

        MethodChannel(messenger, channelName).invokeMethod("updateProgress", message)
    }
}
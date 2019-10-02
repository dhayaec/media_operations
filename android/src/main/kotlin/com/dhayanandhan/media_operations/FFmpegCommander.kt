package com.dhayanandhan.media_operations

import android.content.Context
import nl.bravobit.ffmpeg.ExecuteBinaryResponseHandler
import nl.bravobit.ffmpeg.FFmpeg
import nl.bravobit.ffmpeg.FFtask

class FFmpegCommander(private val context: Context, private val channelName: String) {
    private var stopCommand = false
    private var ffTask: FFtask? = null
    private val utility = Utility(channelName)
    private var totalTime: Long = 0

}
package com.dhayanandhan.media_operations_example

import android.os.Build
import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import android.view.WindowManager
import android.view.ViewTreeObserver

class MainActivity : FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    //make transparent status bar
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      window.statusBarColor = 0x00000000
    }
    GeneratedPluginRegistrant.registerWith(this)
    //Remove full screen flag after load
    val vto = flutterView.viewTreeObserver
    vto.addOnGlobalLayoutListener(object : ViewTreeObserver.OnGlobalLayoutListener {
      override fun onGlobalLayout() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
          flutterView.viewTreeObserver.removeOnGlobalLayoutListener(this)
        }
        window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
      }
    })
  }
}

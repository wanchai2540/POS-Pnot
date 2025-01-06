package com.example.pos

import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val channel = "hardware_button_channel"
    private val scanBuffer = StringBuilder()


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (event != null) {
            val scannedData = scanBuffer.toString()
            scanBuffer.clear();
            sendToFlutter(scannedData);
            // val unicodeChar = event.unicodeChar;
            // if(keyCode == KeyEvent.KEYCODE_ENTER){
            //     val scannedData = scanBuffer.toString()
            //     scanBuffer.clear();
            //     sendToFlutter(scannedData);
            // }else if(unicodeChar > 0){
            //     scanBuffer.append(unicodeChar.toChar())
            // }
        }
        return super.onKeyDown(keyCode, event)
    }

    private fun sendToFlutter(event: String) {
        val messenger = flutterEngine?.dartExecutor?.binaryMessenger
        if (messenger != null) {
            MethodChannel(messenger, channel).invokeMethod("onBarcodeScanned", event)
        } else {
            println("Error: Flutter engine is not initialized.")
        }
    }
}
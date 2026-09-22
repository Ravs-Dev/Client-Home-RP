package com.example.homeroleplay

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.homeroleplay/channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "openNvidia") {
                try {
                    // Contoh pemanggilan Intent jika membuka aplikasi eksternal (misal paket NVIDIA)
                    val intent = packageManager.getLaunchIntentForPackage("com.nvidia.nvidia-package-name")
                    if (intent != null) {
                        intent.putExtra("key", "value")
                        startActivity(intent)
                        result.success(true)
                    } else {
                        result.error("UNAVAILABLE", "Aplikasi tidak ditemukan", null)
                    }
                } catch (e: Exception) {
                    result.error("ERROR", e.localizedMessage, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
package com.abbasisoft.billing

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PublicStoragePlugin.CHANNEL,
        ).setMethodCallHandler { call, result ->
            PublicStoragePlugin.handle(applicationContext, call, result)
        }
    }
}

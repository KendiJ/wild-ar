package com.example.wild_ar

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "com.example.wild_ar/ar_core_view",
            WildArViewFactory(flutterEngine.dartExecutor.binaryMessenger)
        )
    }
}

package com.manymath.camera_control_flutter_example

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    // The NDK Camera2 API has no way to request the runtime CAMERA permission;
    // it must be granted from the Java/Kotlin layer. Request it on startup so
    // the FFI backend's enumerate/open succeed once the user grants it.
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)
            != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.CAMERA),
                1001,
            )
        }
    }
}

package com.example.wild_ar

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.SurfaceTexture
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.hardware.camera2.*
import android.opengl.*
import android.os.Handler
import android.os.HandlerThread
import android.view.MotionEvent
import android.view.Surface
import android.view.TextureView
import android.view.View
import android.widget.FrameLayout
import androidx.core.content.ContextCompat
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import io.flutter.FlutterInjector
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer

class WildArPlatformView(
    private val context: Context,
    messenger: BinaryMessenger,
    viewId: Int,
    creationParams: Map<String, Any?>?
) : PlatformView, MethodChannel.MethodCallHandler, SensorEventListener {

    private val channel = MethodChannel(messenger, "com.example.wild_ar/ar_channel_$viewId")
    private val rootContainer = FrameLayout(context)
    
    // Two TextureViews: ZERO SurfaceView conflict on Samsung A12!
    private val cameraTextureView = TextureView(context)
    private val videoGlTextureView = TextureView(context)

    private val exoPlayer: ExoPlayer = ExoPlayer.Builder(context).build()
    private val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    private val rotationSensor: Sensor? = sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)

    private var cameraThread: HandlerThread? = null
    private var cameraHandler: Handler? = null
    private var cameraDevice: CameraDevice? = null
    private var captureSession: CameraCaptureSession? = null

    private var eglRenderer: EglChromaVideoRenderer? = null

    init {
        channel.setMethodCallHandler(this)
        startCameraThread()

        // 1. Bottom Layer: Live Rear Camera via TextureView
        cameraTextureView.surfaceTextureListener = object : TextureView.SurfaceTextureListener {
            override fun onSurfaceTextureAvailable(surface: SurfaceTexture, width: Int, height: Int) {
                openRearCamera(surface)
            }
            override fun onSurfaceTextureSizeChanged(surface: SurfaceTexture, width: Int, height: Int) {}
            override fun onSurfaceTextureDestroyed(surface: SurfaceTexture): Boolean = true
            override fun onSurfaceTextureUpdated(surface: SurfaceTexture) {}
        }

        // 2. Top Layer: Transparent TextureView for OpenGL Chroma-Key Video
        videoGlTextureView.isOpaque = false
        videoGlTextureView.surfaceTextureListener = object : TextureView.SurfaceTextureListener {
            override fun onSurfaceTextureAvailable(surface: SurfaceTexture, width: Int, height: Int) {
                eglRenderer = EglChromaVideoRenderer(surface, width, height) { videoSurface ->
                    rootContainer.post {
                        exoPlayer.setVideoSurface(videoSurface)
                    }
                }.also { it.start() }
            }
            override fun onSurfaceTextureSizeChanged(surface: SurfaceTexture, width: Int, height: Int) {
                eglRenderer?.updateSize(width, height)
            }
            override fun onSurfaceTextureDestroyed(surface: SurfaceTexture): Boolean {
                eglRenderer?.stopRenderer()
                eglRenderer = null
                return true
            }
            override fun onSurfaceTextureUpdated(surface: SurfaceTexture) {}
        }

        rootContainer.addView(
            cameraTextureView,
            FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT)
        )
        rootContainer.addView(
            videoGlTextureView,
            FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT)
        )

        // 3. Prepare Local Asset Video (migration1.mp4)
        exoPlayer.repeatMode = Player.REPEAT_MODE_ALL
        exoPlayer.volume = 1.0f
        loadLocalVideo("assets/videos/migration1.mp4")

        // 4. Tap anywhere on road to spawn wildlife immediately
        rootContainer.setOnTouchListener { v, event ->
            if (event.action == MotionEvent.ACTION_DOWN) {
                val normX = (event.x / v.width.toFloat()) * 2f - 1f
                val normY = 1f - (event.y / v.height.toFloat()) * 2f
                eglRenderer?.placeAnchor(normX, normY)
                if (!exoPlayer.isPlaying) {
                    exoPlayer.play()
                }
                channel.invokeMethod("onAnchorPlaced", null)
                true
            } else {
                false
            }
        }

        rotationSensor?.let {
            sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_GAME)
        }
    }

    private fun startCameraThread() {
        cameraThread = HandlerThread("WildArCameraThread").also { it.start() }
        cameraHandler = Handler(cameraThread!!.looper)
    }

    private fun stopCameraThread() {
        cameraThread?.quitSafely()
        cameraThread = null
        cameraHandler = null
    }

    private fun loadLocalVideo(flutterAssetPath: String) {
        val lookupKey = FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(flutterAssetPath)
        val assetUri = "asset:///$lookupKey"
        exoPlayer.setMediaItem(MediaItem.fromUri(assetUri))
        exoPlayer.prepare()
    }

    @SuppressLint("MissingPermission")
    private fun openRearCamera(surfaceTexture: SurfaceTexture) {
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
            channel.invokeMethod("onError", "Camera permission not granted")
            return
        }
        try {
            val manager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
            val cameraId = manager.cameraIdList.firstOrNull { id ->
                manager.getCameraCharacteristics(id)
                    .get(CameraCharacteristics.LENS_FACING) == CameraCharacteristics.LENS_FACING_BACK
            } ?: manager.cameraIdList.first()

            surfaceTexture.setDefaultBufferSize(1280, 720)
            val previewSurface = Surface(surfaceTexture)

            manager.openCamera(cameraId, object : CameraDevice.StateCallback() {
                override fun onOpened(camera: CameraDevice) {
                    cameraDevice = camera
                    val requestBuilder = camera.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW).apply {
                        addTarget(previewSurface)
                        set(CaptureRequest.CONTROL_AF_MODE, CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_PICTURE)
                    }
                    camera.createCaptureSession(
                        listOf(previewSurface),
                        object : CameraCaptureSession.StateCallback() {
                            override fun onConfigured(session: CameraCaptureSession) {
                                captureSession = session
                                session.setRepeatingRequest(requestBuilder.build(), null, cameraHandler)
                                rootContainer.post {
                                    channel.invokeMethod("onPlaneDetected", null)
                                }
                            }
                            override fun onConfigureFailed(session: CameraCaptureSession) {}
                        },
                        cameraHandler
                    )
                }
                override fun onDisconnected(camera: CameraDevice) { camera.close() }
                override fun onError(camera: CameraDevice, error: Int) { camera.close() }
            }, cameraHandler)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type == Sensor.TYPE_ROTATION_VECTOR) {
            val rotMatrix = FloatArray(16)
            SensorManager.getRotationMatrixFromVector(rotMatrix, event.values)
            eglRenderer?.updateOrientation(rotMatrix)
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "clearAnchors" -> {
                eglRenderer?.clearAnchor()
                exoPlayer.pause()
                result.success(null)
            }
            "configureScene", "updateChromaKey" -> result.success(null)
            else -> result.notImplemented()
        }
    }

    override fun getView(): View = rootContainer

    override fun dispose() {
        channel.setMethodCallHandler(null)
        sensorManager.unregisterListener(this)
        eglRenderer?.stopRenderer()
        eglRenderer = null
        captureSession?.close()
        cameraDevice?.close()
        stopCameraThread()
        exoPlayer.setVideoSurface(null)
        exoPlayer.release()
    }

    // --- DEDICATED EGL14 + OPENGL ES 2.0 CHROMA-KEY RENDER THREAD FOR TEXTUREVIEW ---
    private class EglChromaVideoRenderer(
        private val outputSurfaceTexture: SurfaceTexture,
        @Volatile private var width: Int,
        @Volatile private var height: Int,
        private val onVideoSurfaceReady: (Surface) -> Unit
    ) : Thread("EglChromaVideoRenderer") {

        @Volatile private var running = true
        @Volatile private var isAnchorPlaced = true // Visible immediately on center of road!
        @Volatile private var anchorX = 0f
        @Volatile private var anchorY = -0.2f
        private var initialYaw: Float? = null
        @Volatile private var yawDelta = 0f
        @Volatile private var pitchDelta = 0f

        fun placeAnchor(normX: Float, normY: Float) {
            anchorX = normX * 0.65f
            anchorY = normY * 0.65f
            initialYaw = null
            isAnchorPlaced = true
        }

        fun clearAnchor() {
            isAnchorPlaced = false
        }

        fun updateSize(w: Int, h: Int) {
            width = w
            height = h
        }

        fun updateOrientation(rotMatrix: FloatArray) {
            val orientation = FloatArray(3)
            SensorManager.getOrientation(rotMatrix, orientation)
            val yaw = orientation[0]
            val pitch = orientation[1]
            if (initialYaw == null) initialYaw = yaw
            yawDelta = (yaw - (initialYaw ?: yaw)) * 0.7f
            pitchDelta = (pitch + 1.1f) * 0.35f
        }

        fun stopRenderer() {
            running = false
            interrupt()
        }

        override fun run() {
            val eglDisplay = EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY)
            val version = IntArray(2)
            EGL14.eglInitialize(eglDisplay, version, 0, version, 1)

            val attribList = intArrayOf(
                EGL14.EGL_RED_SIZE, 8,
                EGL14.EGL_GREEN_SIZE, 8,
                EGL14.EGL_BLUE_SIZE, 8,
                EGL14.EGL_ALPHA_SIZE, 8,
                EGL14.EGL_RENDERABLE_TYPE, EGL14.EGL_OPENGL_ES2_BIT,
                EGL14.EGL_NONE
            )
            val configs = arrayOfNulls<EGLConfig>(1)
            val numConfigs = IntArray(1)
            EGL14.eglChooseConfig(eglDisplay, attribList, 0, configs, 0, 1, numConfigs, 0)

            val contextAttribs = intArrayOf(EGL14.EGL_CONTEXT_CLIENT_VERSION, 2, EGL14.EGL_NONE)
            val eglContext = EGL14.eglCreateContext(eglDisplay, configs[0], EGL14.EGL_NO_CONTEXT, contextAttribs, 0)
            val eglSurface = EGL14.eglCreateWindowSurface(eglDisplay, configs[0], outputSurfaceTexture, intArrayOf(EGL14.EGL_NONE), 0)
            EGL14.eglMakeCurrent(eglDisplay, eglSurface, eglSurface, eglContext)

            val textures = IntArray(1)
            GLES20.glGenTextures(1, textures, 0)
            val oesTexId = textures[0]
            GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, oesTexId)
            GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR)
            GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR)

            val videoInputSurfaceTexture = SurfaceTexture(oesTexId)
            val videoInputSurface = Surface(videoInputSurfaceTexture)
            onVideoSurfaceReady(videoInputSurface)

            val vShaderCode = """
                uniform mat4 uMVPMatrix;
                attribute vec4 aPosition;
                attribute vec2 aTexCoord;
                varying vec2 vTexCoord;
                void main() {
                    gl_Position = uMVPMatrix * aPosition;
                    vTexCoord = aTexCoord;
                }
            """.trimIndent()

            val fShaderCode = """
                #extension GL_OES_EGL_image_external : require
                precision mediump float;
                varying vec2 vTexCoord;
                uniform samplerExternalOES sTexture;
                void main() {
                    vec4 color = texture2D(sTexture, vTexCoord);
                    vec2 centered = (vTexCoord - vec2(0.5, 0.54)) * vec2(1.0, 1.25);
                    float edgeMask = 1.0 - smoothstep(0.32, 0.50, length(centered));
                    float luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));
                    float skyDiff = distance(color.rgb, vec3(0.62, 0.72, 0.80));
                    float chromaAlpha = smoothstep(0.15, 0.33, skyDiff);
                    if (vTexCoord.y < 0.35 && luma > 0.65) {
                        chromaAlpha *= smoothstep(0.85, 0.55, luma);
                    }
                    float finalAlpha = edgeMask * chromaAlpha;
                    if (finalAlpha < 0.03) discard;
                    gl_FragColor = vec4(color.rgb * finalAlpha, finalAlpha);
                }
            """.trimIndent()

            val program = GLES20.glCreateProgram().also {
                GLES20.glAttachShader(it, compileShader(GLES20.GL_VERTEX_SHADER, vShaderCode))
                GLES20.glAttachShader(it, compileShader(GLES20.GL_FRAGMENT_SHADER, fShaderCode))
                GLES20.glLinkProgram(it)
            }

            val quadVertices: FloatBuffer = ByteBuffer.allocateDirect(20 * 4)
                .order(ByteOrder.nativeOrder()).asFloatBuffer().apply {
                    put(floatArrayOf(
                        -0.9f, -0.5f, 0f, 0f, 1f,
                         0.9f, -0.5f, 0f, 1f, 1f,
                        -0.9f,  0.5f, 0f, 0f, 0f,
                         0.9f,  0.5f, 0f, 1f, 0f
                    ))
                    position(0)
                }

            val projMatrix = FloatArray(16)
            val viewMatrix = FloatArray(16)
            val modelMatrix = FloatArray(16)
            val tempMatrix = FloatArray(16)
            val mvpMatrix = FloatArray(16)

            GLES20.glEnable(GLES20.GL_BLEND)
            GLES20.glBlendFunc(GLES20.GL_ONE, GLES20.GL_ONE_MINUS_SRC_ALPHA)

            while (running && !isInterrupted) {
                try {
                    videoInputSurfaceTexture.updateTexImage()
                } catch (_: Exception) {}

                GLES20.glViewport(0, 0, width, height)
                GLES20.glClearColor(0f, 0f, 0f, 0f)
                GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT)

                if (isAnchorPlaced && height > 0) {
                    val ratio = width.toFloat() / height.toFloat()
                    Matrix.frustumM(projMatrix, 0, -ratio, ratio, -1f, 1f, 1.5f, 20f)
                    Matrix.setLookAtM(viewMatrix, 0, 0f, 0f, 0f, 0f, 0f, -1f, 0f, 1f, 0f)

                    Matrix.setIdentityM(modelMatrix, 0)
                    Matrix.translateM(modelMatrix, 0, anchorX - yawDelta, anchorY + pitchDelta, -2.2f)
                    Matrix.rotateM(modelMatrix, 0, -10f, 1f, 0f, 0f)

                    Matrix.multiplyMM(tempMatrix, 0, viewMatrix, 0, modelMatrix, 0)
                    Matrix.multiplyMM(mvpMatrix, 0, projMatrix, 0, tempMatrix, 0)

                    GLES20.glUseProgram(program)
                    val posHandle = GLES20.glGetAttribLocation(program, "aPosition")
                    val texHandle = GLES20.glGetAttribLocation(program, "aTexCoord")
                    val mvpHandle = GLES20.glGetUniformLocation(program, "uMVPMatrix")

                    quadVertices.position(0)
                    GLES20.glVertexAttribPointer(posHandle, 3, GLES20.GL_FLOAT, false, 20, quadVertices)
                    GLES20.glEnableVertexAttribArray(posHandle)

                    quadVertices.position(3)
                    GLES20.glVertexAttribPointer(texHandle, 2, GLES20.GL_FLOAT, false, 20, quadVertices)
                    GLES20.glEnableVertexAttribArray(texHandle)

                    GLES20.glUniformMatrix4fv(mvpHandle, 1, false, mvpMatrix, 0)
                    GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
                    GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, oesTexId)

                    GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4)
                }

                EGL14.eglSwapBuffers(eglDisplay, eglSurface)
                try { sleep(16) } catch (_: InterruptedException) { break }
            }

            videoInputSurface.release()
            videoInputSurfaceTexture.release()
            GLES20.glDeleteTextures(1, intArrayOf(oesTexId), 0)
            GLES20.glDeleteProgram(program)
            EGL14.eglMakeCurrent(eglDisplay, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_CONTEXT)
            EGL14.eglDestroySurface(eglDisplay, eglSurface)
            EGL14.eglDestroyContext(eglDisplay, eglContext)
            EGL14.eglTerminate(eglDisplay)
        }

        private fun compileShader(type: Int, source: String): Int {
            return GLES20.glCreateShader(type).also {
                GLES20.glShaderSource(it, source)
                GLES20.glCompileShader(it)
            }
        }
    }
}

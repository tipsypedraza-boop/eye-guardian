package com.eyeguardian

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.google.android.gms.location.ActivityRecognition
import com.google.android.gms.location.ActivityRecognitionResult
import com.google.android.gms.location.DetectedActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MotionPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "eye_guardian/motion")
        channel.setMethodCallHandler(this)
        companion.channel = channel
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startActivityTracking" -> {
                val intent = Intent(context, ActivityReceiver::class.java)
                val pi = PendingIntent.getBroadcast(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE)
                ActivityRecognition.getClient(context).requestActivityUpdates(10_000L, pi)
                result.success(null)
            }
            "stopActivityTracking" -> {
                val intent = Intent(context, ActivityReceiver::class.java)
                val pi = PendingIntent.getBroadcast(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE)
                ActivityRecognition.getClient(context).removeActivityUpdates(pi)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        var channel: MethodChannel? = null
    }
}

class ActivityReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (!ActivityRecognitionResult.hasResult(intent)) return
        val result = ActivityRecognitionResult.extractResult(intent) ?: return
        val activity = result.mostProbableActivity
        when (activity.type) {
            DetectedActivity.WALKING, DetectedActivity.RUNNING ->
                MotionPlugin.channel?.invokeMethod("onWalking", null)
            DetectedActivity.STILL ->
                MotionPlugin.channel?.invokeMethod("onStationary", null)
        }
    }
}

package com.ssafy.homealone

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import io.flutter.plugin.common.MethodChannel
import android.media.AudioManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import android.content.Context

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.ssafy.homealone/sound"
    lateinit var mAudioManager: AudioManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        GeneratedPluginRegistrant.registerWith(FlutterEngine(this))
        MethodChannel(flutterEngine?.getDartExecutor()?.getBinaryMessenger()!!, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sosSoundSetting") {
                sosSoundSetting()
                result.success("success")
            } else {
                result.notImplemented()
            }
        }
    }

    private fun sosSoundSetting(): String {
        mAudioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager;
        mAudioManager.setMode(AudioManager.MODE_NORMAL);
        mAudioManager.stopBluetoothSco();
        mAudioManager.setBluetoothScoOn(false);
        mAudioManager.setSpeakerphoneOn(true);
        return "success"
    }
}

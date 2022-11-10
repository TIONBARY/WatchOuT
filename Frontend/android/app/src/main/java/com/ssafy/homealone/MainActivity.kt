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
    lateinit var s: String

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        GeneratedPluginRegistrant.registerWith(FlutterEngine(this))
        MethodChannel(flutterEngine?.getDartExecutor()?.getBinaryMessenger()!!, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sosSoundSetting") {
                s = sosSoundSetting()
                result.success(s)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun sosSoundSetting(): String {
        mAudioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager;
        if (mAudioManager.isBluetoothA2dpOn()) {
            mAudioManager.stopBluetoothSco();
            mAudioManager.setBluetoothScoOn(false);
            mAudioManager.setSpeakerphoneOn(true);
            mAudioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
            return "bluetooth"
        }
        if(mAudioManager.isWiredHeadsetOn()){
            mAudioManager.setWiredHeadsetOn(false);
            mAudioManager.setSpeakerphoneOn(true);
            mAudioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
            return "wired headset on"
        }
        return "success"
    }
}

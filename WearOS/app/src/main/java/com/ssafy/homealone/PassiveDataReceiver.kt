/*
 * Copyright 2021 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.ssafy.homealone

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.google.android.gms.tasks.Tasks
import com.google.android.gms.tasks.Task
import androidx.health.services.client.data.DataType
import androidx.health.services.client.data.HrAccuracy
import androidx.health.services.client.data.PassiveMonitoringUpdate
import com.google.android.gms.wearable.Wearable
import com.google.android.gms.wearable.CapabilityClient
import com.google.android.gms.wearable.CapabilityInfo
import com.google.android.gms.wearable.Node


import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.runBlocking
import javax.inject.Inject

private const val HEART_RATE_CAPABILITY_NAME = "heart_rate_bpm"

private fun setupHeartRateTranscription() {
    val capabilityInfo: CapabilityInfo = Tasks.await(
        Wearable.getCapabilityClient(context)
            .getCapability(
                HEART_RATE_CAPABILITY_NAME,
                CapabilityClient.FILTER_REACHABLE
            )
    )
    // capabilityInfo has the reachable nodes with the transcription capability
    updateTranscriptionCapability(capabilityInfo)
}

private var transcriptionNodeId: String? = null

private fun updateTranscriptionCapability(capabilityInfo: CapabilityInfo) {
    transcriptionNodeId = pickBestNodeId(capabilityInfo.nodes)
}

private fun pickBestNodeId(nodes: Set<Node>): String? {
    // Find a nearby node or pick one arbitrarily
    return nodes.firstOrNull { it.isNearby }?.id ?: nodes.firstOrNull()?.id
}

const val HEART_TRANSCRIPTION_MESSAGE_PATH = "/heart_transcription"

private fun requestTranscription(BPM_data: ByteArray) {
    transcriptionNodeId?.also { nodeId ->
        val sendTask: Task<*> = Wearable.getMessageClient(context).sendMessage(
            nodeId,
            HEART_TRANSCRIPTION_MESSAGE_PATH,
            BPM_data
        ).apply {
            addOnSuccessListener {

            }
            addOnFailureListener {

            }
        }
    }
}

/**
 * Receives heart rate updates passively and saves it to the repository.
 */
@AndroidEntryPoint
class PassiveDataReceiver : BroadcastReceiver() {

    @Inject
    lateinit var repository: PassiveDataRepository

    override fun onReceive(context: Context, intent: Intent) {
        val state = PassiveMonitoringUpdate.fromIntent(intent) ?: return
        // Get the most recent heart rate measurement.
        val latestDataPoint = state.dataPoints
            // dataPoints can have multiple types (e.g. if the app registered for multiple types).
            .filter { it.dataType == DataType.HEART_RATE_BPM }
            // where accuracy information is available, only show readings that are of medium or
            // high accuracy. (Where accuracy information isn't available, show the reading if it is
            // a positive value).
            .filter {
                it.accuracy == null ||
                setOf(
                    HrAccuracy.SensorStatus.ACCURACY_MEDIUM,
                    HrAccuracy.SensorStatus.ACCURACY_HIGH
                ).contains((it.accuracy as HrAccuracy).sensorStatus)
            }
            .filter {
                it.value.asDouble() > 0
            }
            // HEART_RATE_BPM is a SAMPLE type, so start and end times are the same.
            .maxByOrNull { it.endDurationFromBoot }
        // If there were no data points, the previous function returns null.
            ?: return

        val latestHeartRate = latestDataPoint.value.asDouble() // HEART_RATE_BPM is a Float type.
        Log.d(TAG, "마지막 심박수 데이터를 백그라운드에서 가져왔습니다: $latestHeartRate")
        setupHeartRateTranscription()
        print("찍기 $latestHeartRate")
        requestTranscription(latestHeartRate as ByteArray)
        runBlocking {
            repository.storeLatestHeartRate(latestHeartRate)
        }
    }
}

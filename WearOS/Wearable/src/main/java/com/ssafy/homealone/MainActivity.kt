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

import android.Manifest
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.isVisible
import androidx.lifecycle.lifecycleScope
import com.google.android.gms.wearable.*
import com.ssafy.homealone.databinding.ActivityMainBinding
import dagger.hilt.android.AndroidEntryPoint
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.ObjectInputStream
import java.io.ObjectOutputStream


/**
 * Activity displaying the app UI. Notably, this binds data from [MainViewModel] to views on screen,
 * and performs the permission check when enabling passive data.
 */
@AndroidEntryPoint
class MainActivity : AppCompatActivity() {
    private val dataClient by lazy { Wearable.getDataClient(this) }
    private val messageClient by lazy { Wearable.getMessageClient(this) }
    private val capabilityClient by lazy { Wearable.getCapabilityClient(this) }
    private val nodeClient by lazy { Wearable.getNodeClient(this) }
    private val channelName = "watch_connectivity"

    private lateinit var binding: ActivityMainBinding
    private lateinit var permissionLauncher: ActivityResultLauncher<String>

    private val viewModel: MainViewModel by viewModels()

    private val clientDataViewModel by viewModels<ClientDataViewModel>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

//        데이터 전송 관련
//        setContent {
//            MainApp(
//                events = clientDataViewModel.events,
//                image = clientDataViewModel.image,
//                onQueryOtherDevicesClicked = ::onQueryOtherDevicesClicked,
//                onQueryMobileCameraClicked = ::onQueryMobileClicked
//            )
//        }

//       심박수 정보 관련
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        permissionLauncher =
            registerForActivityResult(ActivityResultContracts.RequestPermission()) { result ->
                when (result) {
                    true -> {
                        Log.i(TAG, "Body sensors permission granted")
                        viewModel.togglePassiveData(true)
                    }
                    false -> {
                        Log.i(TAG, "Body sensors permission not granted")
                        viewModel.togglePassiveData(false)
                    }
                }
            }

        binding.enablePassiveData.setOnCheckedChangeListener { _, isChecked ->
            if (isChecked) {
                // Make sure we have the necessary permission first.
                permissionLauncher.launch(Manifest.permission.BODY_SENSORS)
            } else {
                viewModel.togglePassiveData(false)
            }
        }

        // Bind viewmodel state to the UI.
        lifecycleScope.launchWhenStarted {
            viewModel.uiState.collect {
                updateViewVisiblity(it)
            }
        }
        lifecycleScope.launchWhenStarted {
            viewModel.latestHeartRate.collect {
                binding.lastMeasuredValue.text = it.toString()
            }
        }
        lifecycleScope.launchWhenStarted {
            viewModel.passiveDataEnabled.collect {
                binding.enablePassiveData.isChecked = it
            }
        }
    }

    private fun updateViewVisiblity(uiState: UiState) {
        (uiState is UiState.Startup).let {
            binding.progress.isVisible = it
        }
        // These views are visible when heart rate capability is not available.
        (uiState is UiState.HeartRateNotAvailable).let {
            binding.brokenHeart.isVisible = it
            binding.notAvailable.isVisible = it
        }
        // These views are visible when the capability is available.
        (uiState is UiState.HeartRateAvailable).let {
            binding.enablePassiveData.isVisible = it
            binding.lastMeasuredLabel.isVisible = it
            binding.lastMeasuredValue.isVisible = it
            binding.heart.isVisible = it
        }
    }

//    private fun onQueryOtherDevicesClicked() {
//        lifecycleScope.launch {
//            try {
//                val nodes = getCapabilitiesForReachableNodes()
//                    .filterValues { "mobile" in it || "wear" in it }.keys
//                displayNodes(nodes)
//            } catch (cancellationException: CancellationException) {
//                throw cancellationException
//            } catch (exception: Exception) {
//                Log.d(TAG, "Querying nodes failed: $exception")
//            }
//        }
//    }
//
//    private fun onQueryMobileClicked() {
//        lifecycleScope.launch {
//            try {
//                val nodes = getCapabilitiesForReachableNodes()
//                    .filterValues { "mobile" in it }.keys
//                displayNodes(nodes)
//            } catch (cancellationException: CancellationException) {
//                throw cancellationException
//            } catch (exception: Exception) {
//                Log.d(TAG, "Querying nodes failed: $exception")
//            }
//        }
//    }

    /**
     * Collects the capabilities for all nodes that are reachable using the [CapabilityClient].
     *
     * [CapabilityClient.getAllCapabilities] returns this information as a [Map] from capabilities
     * to nodes, while this function inverts the map so we have a map of [Node]s to capabilities.
     *
     * This form is easier to work with when trying to operate upon all [Node]s.
     */
//    private suspend fun getCapabilitiesForReachableNodes(): Map<Node, Set<String>> =
//        capabilityClient.getAllCapabilities(CapabilityClient.FILTER_REACHABLE)
//            .await()
//            // Pair the list of all reachable nodes with their capabilities
//            .flatMap { (capability, capabilityInfo) ->
//                capabilityInfo.nodes.map { it to capability }
//            }
//            // Group the pairs by the nodes
//            .groupBy(
//                keySelector = { it.first },
//                valueTransform = { it.second }
//            )
//            // Transform the capability list for each node into a set
//            .mapValues { it.value.toSet() }
//
//    private fun displayNodes(nodes: Set<Node>) {
//        val message = if (nodes.isEmpty()) {
//            getString(R.string.no_device)
//        } else {
//            getString(R.string.connected_nodes, nodes.joinToString(", ") { it.displayName })
//        }
//
//        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
//    }

    override fun onResume() {
        super.onResume()
        dataClient.addListener(clientDataViewModel)
        messageClient.addListener(clientDataViewModel)
        capabilityClient.addListener(
            clientDataViewModel,
            Uri.parse("wear://"),
            CapabilityClient.FILTER_REACHABLE
        )
    }

    override fun onPause() {
        super.onPause()
        dataClient.removeListener(clientDataViewModel)
        messageClient.removeListener(clientDataViewModel)
        capabilityClient.removeListener(clientDataViewModel)
    }

    companion object {
        private const val TAG = "MainActivity"
        private val channelName = "watch_connectivity"

        //데이터 업데이트
        fun sendHeartRateData(dataClient: DataClient, data: Any) {
            val eventData = objectToBytes(mutableMapOf(Pair("HEART_RATE", data.toString().trim())))
            val dataItem = PutDataRequest.create("/$channelName")
            dataItem.data = eventData
            dataClient.putDataItem(dataItem)
                .addOnSuccessListener { Log.d("데이터 전송 성공", data.toString()) }
                .addOnFailureListener {  Log.e("데이터 전송 실패", it.message.toString()) }
        }

        // 메세지 전송
        private fun sendMessage(nodeClient: NodeClient, messageClient: MessageClient, message: String) {
            Log.d("메세지", message)
            val messageData = objectToBytes(mutableMapOf(Pair("HEART_RATE", message)))

            Log.d("메세지 전송", objectFromBytes(messageData).toString())
            nodeClient.connectedNodes.addOnSuccessListener { nodes ->
                nodes.forEach {
                    messageClient.sendMessage(it.id, channelName, messageData)

//                messageClient.sendMessage(it.id, "/$channelName", messageData)
                }
            }
        }

        private fun objectFromBytes(bytes: ByteArray): Any {
            val bis = ByteArrayInputStream(bytes)
            val ois = ObjectInputStream(bis)
            return ois.readObject()
        }

        private fun objectToBytes(`object`: Any): ByteArray {
            val baos = ByteArrayOutputStream()
            val oos = ObjectOutputStream(baos)
            oos.writeObject(`object`)
            return baos.toByteArray()
        }
    }
}

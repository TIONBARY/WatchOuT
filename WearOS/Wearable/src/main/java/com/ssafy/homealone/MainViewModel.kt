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

import android.util.Log
import androidx.health.services.client.data.DataTypeAvailability
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject
import kotlinx.coroutines.flow.*

/**
 * Holds most of the interaction logic and UI state for the app.
 */
@HiltViewModel
class MainViewModel @Inject constructor(
    private val healthServicesManager: HealthServicesManager
) : ViewModel() {
    private val _uiState = MutableStateFlow<UiState>(UiState.Startup)
    val uiState: StateFlow<UiState> = _uiState

    private val _heartRateAvailable = MutableStateFlow(DataTypeAvailability.UNKNOWN)
//    val heartRateAvailable: StateFlow<DataTypeAvailability> = _heartRateAvailable

    private val _heartRateBpm = MutableStateFlow(0.0)
    val heartRateBpm: StateFlow<Double> = _heartRateBpm

    init {
        // Check that the device has the heart rate capability and progress to the next state
        // accordingly.
        viewModelScope.launch {
            _uiState.value = if (healthServicesManager.hasHeartRateCapability()) {
                UiState.HeartRateAvailable
            } else {
                UiState.HeartRateNotAvailable
            }
        }
    }

    suspend fun lastHeartRate() {
        healthServicesManager.heartRateMeasureFlow().cancellable().collectLatest {
            when (it) {
                is MeasureMessage.MeasureAvailabilty -> {
                    Log.d(TAG, "측정 가능: ${it.availability}")
                    _heartRateAvailable.value = it.availability
                }
                is MeasureMessage.MeasureData -> {
                    val bpm = it.data.last().value.asDouble()
                    Log.d(TAG, "심박수 : $bpm")
                    _heartRateBpm.value = bpm
                }
            }

        }
    }

    // 심박수 지속적으로 체크
//    suspend fun measureHeartRate() {
//        healthServicesManager.heartRateMeasureFlow().cancellable().collect {
//            when (it) {
//                is MeasureMessage.MeasureAvailabilty -> {
//                    Log.d(TAG, "Availability changed: ${it.availability}")
//                    _heartRateAvailable.value = it.availability
//                }
//                is MeasureMessage.MeasureData -> {
//                    val bpm = it.data.last().value.asDouble()
//                    Log.d(TAG, "Data update: $bpm")
//                    _heartRateBpm.value = bpm
//                }
//            }
//        }
//    }
}

sealed class UiState {
    object Startup : UiState()
    object HeartRateAvailable : UiState()
    object HeartRateNotAvailable : UiState()
}

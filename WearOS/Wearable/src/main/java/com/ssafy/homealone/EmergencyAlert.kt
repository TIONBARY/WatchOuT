package com.ssafy.homealone
import android.content.Context
import android.graphics.Bitmap
import android.os.Bundle
import android.os.PersistableBundle
import androidx.appcompat.app.AppCompatActivity
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.*
import androidx.wear.compose.material.dialog.Alert

class EmergencyAlert: AppCompatActivity() {

    @Composable
    fun Open() {
        val openDialog = remember { mutableStateOf(true) }
        if (openDialog.value) {
            Alert(
                icon = {
                    Icon(
                        painter = painterResource(id = R.drawable.common_full_open_on_phone),
                        contentDescription = "alarm",
                        modifier = Modifier
                            .size(24.dp)
                            .wrapContentSize(align = Alignment.Center),
                    )
                },
                title = { Text("이상 상황입니다!", textAlign = TextAlign.Center) },
                negativeButton = {
                    Button(
                        colors = ButtonDefaults.secondaryButtonColors(),
                        onClick = {
                            /* Do something e.g. navController.popBackStack()*/
                        }) {
                        Text("아니오")
                    }
                },
                positiveButton = {
                    Button(onClick = {
                        /* Do something e.g. navController.popBackStack()*/
                    }) { Text("예") }
                },
                contentPadding =
                PaddingValues(start = 10.dp, end = 10.dp, top = 24.dp, bottom = 32.dp),
            ) {
                Text(
                    text = "현재 심박수가 비정상적입니다. " +
                        "(알림을 보고싶지 않으시다면 스와이프 하세요.)",
                    textAlign = TextAlign.Center
                )
            }
        }
    }
}

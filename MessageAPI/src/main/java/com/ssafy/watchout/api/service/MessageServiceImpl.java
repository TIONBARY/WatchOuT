package com.ssafy.watchout.api.service;

import java.io.IOError;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.HashMap;
import java.util.Objects;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.google.gson.Gson;
import com.ssafy.watchout.api.domain.dto.MessageRequestDto;
import com.ssafy.watchout.api.domain.dto.TokenDto;

import okhttp3.MultipartBody;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

@Service
public class MessageServiceImpl implements MessageService {

	private static final String SMS_OAUTH_TOKEN_URL = "https://sms.gabia.com/oauth/token"; // ACCESS TOKEN 발급 API URL
																							// 입니다.
	private static final String SMS_SEND_URL = "https://sms.gabia.com/api/send/mms"; // SMS 발송 API URL입니다.
	
	private static final String sender = "01090319389";
	
	@Value("${open-api.sms-id}")
	String smsId;
	
	@Value("${open-api.api-key}")
	String apiKey;
	
	@Override
	public TokenDto authorize() throws IOException {
		String authValue = Base64.getEncoder()
				.encodeToString(String.format("%s:%s", smsId, apiKey).getBytes(StandardCharsets.UTF_8)); // Authorization
																											// // 입력할
																											// 값입니다.

		// 사용자 인증 API 를 호출합니다.
		OkHttpClient client = new OkHttpClient();

		RequestBody requestBody = new MultipartBody.Builder().setType(MultipartBody.FORM)
				.addFormDataPart("grant_type", "client_credentials").build();

		Request request = new Request.Builder().url(SMS_OAUTH_TOKEN_URL).post(requestBody)
				.addHeader("Content-Type", "application/x-www-form-urlencoded")
				.addHeader("Authorization", "Basic " + authValue).addHeader("cache-control", "no-cache").build();

		// Response 를 key, value 로 확인하실 수 있습니다.
		Response response = client.newCall(request).execute();
		HashMap<String, String> result = new Gson().fromJson(Objects.requireNonNull(response.body()).string(),
				HashMap.class);
		for (String key : result.keySet()) {
			System.out.printf("%s: %s%n", key, result.get(key));
		}
		TokenDto token = TokenDto.builder().accessToken(result.get("access_token")).build();
		System.out.println(token.getAccessToken());
		return token;
	}

	@Override
	public void sendMessage(String accessToken, MessageRequestDto requestDto) throws IOException {
		String authValue = Base64.getEncoder()
				.encodeToString(String.format("%s:%s", smsId, accessToken).getBytes(StandardCharsets.UTF_8)); // Authorization

		// SMS 발송 API 를 호출합니다.
		OkHttpClient client = new OkHttpClient();
		
		StringBuilder receiversToStringBuilder = new StringBuilder();
		for (String receiver : requestDto.getReceivers()) {
			receiversToStringBuilder.append(receiver).append(",");
		}
		receiversToStringBuilder.setLength(receiversToStringBuilder.length()-1);
		String receiversToString = receiversToStringBuilder.toString();
		RequestBody requestBody = new MultipartBody.Builder().setType(MultipartBody.FORM)
				.addFormDataPart("phone", receiversToString) // 수신번호를 입력해 주세요. (수신번호가 두 개 이상인 경우 ',' 를 이용하여입력합니다.
																	// ex) 01011112222,01033334444)
				.addFormDataPart("callback", sender) // 발신번호를 입력해 주세요.
				.addFormDataPart("message", requestDto.getMessage()) // SMS 내용을 입력해 주세요.
				.addFormDataPart("refkey", "WATCH_OUT") // 발송 결과 조회를 위한 임의의 랜덤 키 값을 입력해 주세요.
				.build();

		Request request = new Request.Builder().url(SMS_SEND_URL).post(requestBody)
				.addHeader("Content-Type", "application/x-www-form-urlencoded")
				.addHeader("Authorization", "Basic " + authValue).addHeader("cache-control", "no-cache").build();

		Response response = client.newCall(request).execute();

		// Response 를 key, value 로 확인하실 수 있습니다.
		HashMap<String, String> result = new Gson().fromJson(Objects.requireNonNull(response.body()).string(),
				HashMap.class);
		for (String key : result.keySet()) {
			System.out.printf("%s: %s%n", key, result.get(key));
		}
		if (!"200".equals(result.get("code").toString())) {
			throw new IOException(result.get("message") != null ? result.get("message") : "메세지 전송 실패");
		}

	}

}

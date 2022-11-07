package com.ssafy.watchout.api.service;

import java.io.File;
import java.io.IOError;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Objects;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.cglib.core.CollectionUtils;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.google.gson.Gson;
import com.ssafy.watchout.api.domain.dto.MMSMessageRequestDto;
import com.ssafy.watchout.api.domain.dto.MessageRequestDto;
import com.ssafy.watchout.api.domain.dto.ReportPhotoDto;
import com.ssafy.watchout.api.domain.dto.TokenDto;

import okhttp3.MultipartBody;
import okhttp3.MultipartBody.Builder;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

@Service
public class MessageServiceImpl implements MessageService {

	private static final String SMS_OAUTH_TOKEN_URL = "https://sms.gabia.com/oauth/token"; // ACCESS TOKEN 발급 API URL
																							// 입니다.
	private static final String LMS_SEND_URL = "https://sms.gabia.com/api/send/lms"; // SMS 발송 API URL입니다.

	private static final String MMS_SEND_URL = "https://sms.gabia.com/api/send/mms";

	private static final String SENDER = "01090319389";

	private static final String REF_KEY = "WATCH_OUT";

	private static final String SUBJECT = "Watch Out 메세지";

	@Value("${open-api.sms-id}")
	String smsId;

	@Value("${open-api.api-key}")
	String apiKey;

	@Override
	public TokenDto authorize() throws IOException {
		String authValue = Base64.getEncoder()
				.encodeToString(String.format("%s:%s", smsId, apiKey).getBytes(StandardCharsets.UTF_8));

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
		receiversToStringBuilder.setLength(receiversToStringBuilder.length() - 1);
		String receiversToString = receiversToStringBuilder.toString();
		RequestBody requestBody = new MultipartBody.Builder().setType(MultipartBody.FORM)
				.addFormDataPart("phone", receiversToString) // 수신번호를 입력해 주세요. (수신번호가 두 개 이상인 경우 ',' 를 이용하여입력합니다.
																// ex) 01011112222,01033334444)
				.addFormDataPart("callback", SENDER) // 발신번호를 입력해 주세요.
				.addFormDataPart("message", requestDto.getMessage()) // SMS 내용을 입력해 주세요.
				.addFormDataPart("refkey", REF_KEY + LocalDateTime.now().toString()) // 발송 결과 조회를 위한 임의의 랜덤 키 값을 입력해
																						// 주세요.
				.addFormDataPart("subject", SUBJECT).build();

		Request request = new Request.Builder().url(LMS_SEND_URL).post(requestBody)
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

	@Override
	public void sendMMSMessage(String accessToken, MMSMessageRequestDto requestDto) throws Exception {
		List<ReportPhotoDto> fileList = parseFileInfo(requestDto.getFiles());
		String authValue = Base64.getEncoder()
				.encodeToString(String.format("%s:%s", smsId, accessToken).getBytes(StandardCharsets.UTF_8));

		// MMS 발송 API 를 호출합니다.
		OkHttpClient client = new OkHttpClient();
		StringBuilder receiversToStringBuilder = new StringBuilder();
		for (String receiver : requestDto.getReceivers()) {
			receiversToStringBuilder.append(receiver).append(",");
		}
		receiversToStringBuilder.setLength(receiversToStringBuilder.length() - 1);
		String receiversToString = receiversToStringBuilder.toString();
		Builder requestBodyBuilder = new MultipartBody.Builder().setType(MultipartBody.FORM)
				.addFormDataPart("phone", receiversToString).addFormDataPart("callback", SENDER) // 발신번호를 입력해 주세요.
				.addFormDataPart("message", requestDto.getMessage()) // MMS 내용을 입력해 주세요.
				.addFormDataPart("refkey", REF_KEY + LocalDateTime.now().toString()) // 발송 결과 조회를 위한 임의의 랜덤 키를 입력해 주세요.
				.addFormDataPart("subject", SUBJECT) // MMS 제목을 입력해 주세요.
				.addFormDataPart("image_cnt", requestDto.getFiles().size() + "") // 이미지 첨부 개수를 입력해 주세요. (최대 3개까지 첨부
																					// 가능합니다.)
		;
		for (int i = 0; i < fileList.size(); i++) {
			ReportPhotoDto file = fileList.get(i);
			requestBodyBuilder.addFormDataPart("images" + i, file.getOrigFileName(),
					RequestBody.create(new File(file.getFilePath()), MultipartBody.FORM));
		}
		RequestBody requestBody = requestBodyBuilder.build();
		Request request = new Request.Builder().url(MMS_SEND_URL).post(requestBody)
				.addHeader("Authorization", "Basic " + authValue).build();

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

	public List<ReportPhotoDto> parseFileInfo(List<MultipartFile> multipartFiles) throws Exception {
		List<ReportPhotoDto> fileList = new ArrayList<>();
		// 전달되어 온 파일이 존재할 경우
		if (!multipartFiles.isEmpty()) {
			// 파일명을 업로드 한 날짜로 변환하여 저장
			LocalDateTime now = LocalDateTime.now();
			DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyyMMdd");
			String current_date = now.format(dateTimeFormatter);

			// 프로젝트 디렉터리 내의 저장을 위한 절대 경로 설정
			// 경로 구분자 File.separator 사용
			String absolutePath = new File("").getAbsolutePath() + File.separator + File.separator;

			// 파일을 저장할 세부 경로 지정
			String path = "images" + File.separator + current_date;
			File file = new File(path);

			// 디렉터리가 존재하지 않을 경우
			if (!file.exists()) {
				boolean mkdirSuccess = file.mkdirs();

				// 디렉터리 생성에 실패했을 경우
				if (!mkdirSuccess)
					System.out.println("file: make directory was not successful");
			}

			// 다중 파일 처리
			for (MultipartFile multipartFile : multipartFiles) {

				// 파일의 확장자 추출
				String originalFileExtension = ".jpg";
				String contentType = multipartFile.getContentType();
				System.out.println(contentType);

				// 파일명 중복 피하고자 나노초까지 얻어와 지정
				String new_file_name = System.nanoTime() + originalFileExtension;

				// 파일 DTO 생성
				ReportPhotoDto photoDto = ReportPhotoDto.builder().origFileName(multipartFile.getOriginalFilename())
						.filePath(path + File.separator + new_file_name).fileSize(multipartFile.getSize()).build();

				// 생성 후 리스트에 추가
				fileList.add(photoDto);

				// 업로드 한 파일 데이터를 지정한 파일에 저장
				file = new File(absolutePath + path + File.separator + new_file_name);
				multipartFile.transferTo(file);

				// 파일 권한 설정(쓰기, 읽기)
				file.setWritable(true);
				file.setReadable(true);
			}
		}

		return fileList;
	}
}

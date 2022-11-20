package com.ssafy.watchout.api.controller;

import java.io.IOException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.ssafy.watchout.api.domain.dto.BaseResponseDto;
import com.ssafy.watchout.api.domain.dto.MMSMessageRequestDto;
import com.ssafy.watchout.api.domain.dto.MessageRequestDto;
import com.ssafy.watchout.api.domain.dto.TokenDto;
import com.ssafy.watchout.api.service.MessageService;

@RestController
@CrossOrigin("*")
@RequestMapping("/api/message")
public class MessageController {
	
	@Autowired
	private MessageService messageService;
	
	@PostMapping
	public ResponseEntity<BaseResponseDto> sendMessage(@RequestBody MessageRequestDto requestDto) throws IOException {
		TokenDto token = messageService.authorize();
		String accessToken = token.getAccessToken();
		try {
			messageService.sendMessage(accessToken, requestDto);
			return ResponseEntity.status(200).body(BaseResponseDto.of(200, "Success"));
		} catch (IOException e){
			return ResponseEntity.status(400).body(BaseResponseDto.of(400, e.getMessage()));
		}
		
		
	}
	
	@PostMapping("/mms")
	public ResponseEntity<BaseResponseDto> sendMMSMessage(@RequestPart(value = "message") MMSMessageRequestDto requestDto,
			@RequestPart(value = "files", required = false) List<MultipartFile> files) throws Exception {
		TokenDto token = messageService.authorize();
		String accessToken = token.getAccessToken();
		try {
			requestDto.setFiles(files);
			messageService.sendMMSMessage(accessToken, requestDto);
			return ResponseEntity.status(200).body(BaseResponseDto.of(200, "Success"));
		} catch (IOException e){
			return ResponseEntity.status(400).body(BaseResponseDto.of(400, e.getMessage()));
		}
	}
}

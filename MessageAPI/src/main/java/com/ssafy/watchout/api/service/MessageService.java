package com.ssafy.watchout.api.service;

import java.io.IOException;

import com.ssafy.watchout.api.domain.dto.MessageRequestDto;
import com.ssafy.watchout.api.domain.dto.TokenDto;

public interface MessageService {
	TokenDto authorize() throws IOException;
	void sendMessage(String accessToken, MessageRequestDto requestDto) throws IOException;
}

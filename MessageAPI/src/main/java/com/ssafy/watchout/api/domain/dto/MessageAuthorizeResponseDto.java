package com.ssafy.watchout.api.domain.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MessageAuthorizeResponseDto extends BaseResponseDto {
	
	private TokenDto tokenDto;
	
	public MessageAuthorizeResponseDto(Integer statusCode, String message, TokenDto tokenDto) {
		super(statusCode, message);
		this.tokenDto = tokenDto;
	}
	
	public static MessageAuthorizeResponseDto of(Integer statusCode, String message, TokenDto tokenDto) {
		MessageAuthorizeResponseDto body = new MessageAuthorizeResponseDto(statusCode, message, tokenDto);
		return body;
	}

}

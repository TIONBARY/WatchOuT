package com.ssafy.watchout.api.domain.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class BaseResponseDto {
	
	Integer statusCode = null;
	String message = null;
	
	public BaseResponseDto(Integer statusCode, String message){
		this.statusCode = statusCode;
		this.message = message;
	}
	
	public static BaseResponseDto of(Integer statusCode, String message) {
		BaseResponseDto body = new BaseResponseDto(statusCode, message);
		return body;
	}
}
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
public class ReportPhotoDto {
    private String origFileName; // 원본 파일명
    private String filePath;  // 파일 저장 경로
    private Long fileSize;
}

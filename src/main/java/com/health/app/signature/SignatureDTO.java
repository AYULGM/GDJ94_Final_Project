package com.health.app.signature;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class SignatureDTO {
    // user_signatures
    private Long signatureId;
    private Long userId;
    private Long fileId;
    private Long createUser;
    private LocalDateTime createDate;
    private Boolean useYn;
    private Boolean isPrimary;

    // 요청: 캔버스 base64
    private String signBase64; 

    // attachments 저장용
    private String storageKey;  
    private String originalName; 
    private String contentType; 
    private Long fileSize;    

    // 응답 
    private String imageUrl; 
}

package com.health.app.branch;

import java.time.LocalDateTime;
import lombok.Data;

@Data
public class BranchHistoryDTO {

    private String createDate;   // 변경일시
    private String historyType;          // STATUS_CHANGE / UPDATE
    private String changeField;          // 변경 항목
    private String beforeValue;          // 변경 전
    private String afterValue;           // 변경 후
    private String reason;               // 변경 사유
    private String createUserName;        // 처리자 이름
}

package com.health.app.notices;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class NoticeDTO {

    private Long noticeId;

    private String title;
    private String content;

    private String noticeType;     // NT001...
    private String targetType;     // TT001/TT002
    private String categoryCode;

    private Boolean isPinned;
    private String status;

    private Long writerId;
    private Long viewCount;

    private LocalDateTime createDate;
    private Long updateUser;
    private LocalDateTime updateDate;

    private Boolean useYn;

    private LocalDateTime publishStartDate;
    private LocalDateTime publishEndDate;

    // targetType=TT002 일 때만 사용 (지점 대상)
    private List<Long> branchIds;
}

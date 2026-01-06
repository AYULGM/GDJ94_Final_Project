package com.health.app.inbound;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class InboundRequestItemDto {

    private Long inboundRequestItemId;
    private Long inboundRequestId;

    private Long productId;
    private Long quantity;
    private Long unitPrice;

    private String lineMemo;

    private Long createUser;
    private LocalDateTime createDate;
    private Long updateUser;
    private LocalDateTime updateDate;

    private Integer useYn;

    // 조회용 join 필드
    private String productName;
}

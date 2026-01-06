package com.health.app.settlements;

/**
 * 정산 상태 Enum
 */
public enum SettlementStatus {
    PENDING("대기"),
    CONFIRMED("확정"),
    CANCELLED("취소");

    private final String description;

    SettlementStatus(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}

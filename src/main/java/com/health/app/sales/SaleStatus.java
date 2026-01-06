package com.health.app.sales;

/**
 * 매출 상태 Enum
 */
public enum SaleStatus {
    COMPLETED("완료"),
    CANCELLED("취소");

    private final String description;

    SaleStatus(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}

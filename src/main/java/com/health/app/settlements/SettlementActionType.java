package com.health.app.settlements;

/**
 * 정산 이력 액션 타입 Enum
 */
public enum SettlementActionType {
    CREATE("생성"),
    CONFIRM("확정"),
    CANCEL("취소"),
    UPDATE("수정");

    private final String description;

    SettlementActionType(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}

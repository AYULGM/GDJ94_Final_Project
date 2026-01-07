package com.health.app.expenses;

/**
 * 지출 카테고리 Enum
 */
public enum ExpenseCategory {
    LABOR("인건비"),
    RENT("임차료"),
    UTILITY("유틸리티"),
    MARKETING("마케팅"),
    ETC("기타");

    private final String description;

    ExpenseCategory(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}

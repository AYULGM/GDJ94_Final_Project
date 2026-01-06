package com.health.app.inbound;

import lombok.Getter;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
public class InboundRequestFormDto {

    private String vendorName;
    private String title;
    private String memo;

    // 다품목
    private List<InboundRequestItemDto> items = new ArrayList<>();

    /** 전자결재 extTxt6에 넣을 JSON 유사 문자열 */
    public String buildItemsJsonLikeText() {
        StringBuilder sb = new StringBuilder();
        sb.append("[");
        for (int i = 0; i < items.size(); i++) {
            InboundRequestItemDto it = items.get(i);
            sb.append("{")
                    .append("\"productId\":").append(it.getProductId()).append(",")
                    .append("\"quantity\":").append(it.getQuantity()).append(",")
                    .append("\"unitPrice\":").append(it.getUnitPrice() == null ? "null" : it.getUnitPrice()).append(",")
                    .append("\"lineMemo\":\"").append(it.getLineMemo() == null ? "" : it.getLineMemo().replace("\"", "'")).append("\"")
                    .append("}");
            if (i < items.size() - 1) sb.append(",");
        }
        sb.append("]");
        return sb.toString();
    }
}

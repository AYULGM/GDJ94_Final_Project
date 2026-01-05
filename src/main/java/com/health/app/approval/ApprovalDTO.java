package com.health.app.approval;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Setter
@Getter
@ToString
public class ApprovalDTO {
	private Long docId;
	private String docNo;
	private String typeCode;
	private String formCode;
	private String statusCode;
	private Long drafterId;
	private Long branchId;
}

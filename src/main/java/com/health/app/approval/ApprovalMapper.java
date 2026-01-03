package com.health.app.approval;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ApprovalMapper {

    // documents
    int insertDocument(ApprovalDraftDTO dto);

    // versions
    int insertDocumentVersion(ApprovalDraftDTO dto);

    // ext
    int insertDocumentExt(ApprovalDraftDTO dto);

    // documents.current_doc_ver_id 업데이트
    int updateCurrentVersion(ApprovalDraftDTO dto);

    // ✅ userId로 branchId 조회 (NOT NULL 대응용)
    Long selectBranchIdByUserId(@Param("userId") Long userId);
}

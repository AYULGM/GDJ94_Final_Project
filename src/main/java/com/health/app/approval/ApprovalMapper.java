package com.health.app.approval;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ApprovalMapper {

    // ===== documents =====
    int insertDocument(ApprovalDraftDTO dto);

    // ===== versions =====
    int insertDocumentVersion(ApprovalDraftDTO dto);

    // ===== ext =====
    int insertDocumentExt(ApprovalDraftDTO dto);

    // ===== documents.current_doc_ver_id 업데이트 =====
    int updateCurrentVersion(ApprovalDraftDTO dto);

    // ✅ userId로 branchId 조회 (NOT NULL 대응용)
    Long selectBranchIdByUserId(@Param("userId") Long userId);

    /** docVerId 기준으로 결재선 전체 삭제 */
    int deleteLinesByDocVerId(@Param("docVerId") Long docVerId);

    /** 결재선 1건 insert */
    int insertLine(ApprovalLineDTO line);

    /** docVerId 기준 결재선 조회 */
    List<ApprovalLineDTO> selectLinesByDocVerId(@Param("docVerId") Long docVerId);
}

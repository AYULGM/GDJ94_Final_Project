package com.health.app.approval;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ApprovalMapper {

	/* ==================================================
	 * 기안자 문서함(내가 기안한 문서 목록)
	 * ================================================== */
	List<ApprovalMyDocRowDTO> selectMyDocs(@Param("drafterId") Long drafterId);

    /* ==================================================
     * 문서/버전/확장 저장
     * ================================================== */
    int insertDocument(ApprovalDraftDTO dto);
    int insertDocumentVersion(ApprovalDraftDTO dto);
    int insertDocumentExt(ApprovalDraftDTO dto);
    int updateCurrentVersion(ApprovalDraftDTO dto);

    Long selectBranchIdByUserId(@Param("userId") Long userId);

    /* ==================================================
     * 결재선 저장/조회
     * ================================================== */
    int deleteLinesByDocVerId(@Param("docVerId") Long docVerId);
    int insertLine(ApprovalLineDTO line);
    List<ApprovalLineDTO> selectLinesByDocVerId(@Param("docVerId") Long docVerId);

    /* ==================================================
     * 결재자 트리
     * ================================================== */
    List<Map<String, Object>> selectHeadOfficeApprovers();
    List<Map<String, Object>> selectBranchApprovers();
    List<Map<String, Object>> selectBranches();

    /* ==================================================
     * 결재 요청(상신)
     * ================================================== */
    Long selectDrafterIdByDocVerId(@Param("docVerId") Long docVerId);
    int countLinesByDocVerId(@Param("docVerId") Long docVerId);
    String selectDocStatusByDocVerId(@Param("docVerId") Long docVerId);

    int updateDocumentStatusByDocVerId(@Param("docVerId") Long docVerId,
                                       @Param("statusCode") String statusCode,
                                       @Param("updateUser") Long updateUser);

    int updateVersionStatusByDocVerId(@Param("docVerId") Long docVerId,
                                      @Param("verStatusCode") String verStatusCode,
                                      @Param("updateUser") Long updateUser);

    int updateAllLinesStatusByDocVerId(@Param("docVerId") Long docVerId,
                                       @Param("lineStatusCode") String lineStatusCode,
                                       @Param("updateUser") Long updateUser);

    int updateFirstLineToPending(@Param("docVerId") Long docVerId,
                                 @Param("lineStatusCode") String lineStatusCode,
                                 @Param("updateUser") Long updateUser);

    /* ==================================================
     * 받은 결재함
     * ================================================== */
    List<ApprovalInboxRowDTO> selectMyInbox(@Param("approverId") Long approverId);

    /* ==================================================
     * (기존) 결재 처리용 메서드들
     *  - 아래 processDecision 방식으로 갈 거면 유지/삭제 선택 가능
     * ================================================== */
    ApprovalDocHeaderDTO selectDocHeaderByDocVerId(@Param("docVerId") Long docVerId);

    ApprovalLineDTO selectMyPendingLine(@Param("docVerId") Long docVerId,
                                        @Param("userId") Long userId);

    int approveMyLine(@Param("docVerId") Long docVerId,
                      @Param("userId") Long userId,
                      @Param("comment") String comment,
                      @Param("signatureFileId") Long signatureFileId,
                      @Param("updateUser") Long updateUser);

    int rejectMyLine(@Param("docVerId") Long docVerId,
                     @Param("userId") Long userId,
                     @Param("comment") String comment,
                     @Param("signatureFileId") Long signatureFileId,
                     @Param("updateUser") Long updateUser);

    int promoteNextLineToPending(@Param("docVerId") Long docVerId,
                                 @Param("nextSeq") Long nextSeq,
                                 @Param("updateUser") Long updateUser);

    int existsNextLine(@Param("docVerId") Long docVerId,
                       @Param("nextSeq") Long nextSeq);

    /* ==================================================
     * 결재 전용 상품
     * ================================================== */
    List<ApprovalProductDTO> selectProductsByBranch(@Param("branchId") Long branchId);

    /* ==================================================
     * 출력(프린트)
     * ================================================== */
    ApprovalPrintDTO selectPrintHeader(@Param("docVerId") Long docVerId);

    VacationPrintDTO selectVacationPrint(@Param("docVerId") Long docVerId);

    List<ApprovalPrintLineDTO> selectPrintLines(@Param("docVerId") Long docVerId);

    /* ==================================================
     * processDecision() 방식 (현재 대기 라인 → 승인/반려 → 다음 라인)
     * ================================================== */
    Long selectCurrentPendingLineId(@Param("docVerId") Long docVerId);

    // ✅ 서명/업데이트유저/결재일시까지 같이 업데이트하도록 확장
    int updateLineStatusByLineId(@Param("lineId") Long lineId,
                                 @Param("statusCode") String statusCode,
                                 @Param("comment") String comment,
                                 @Param("signatureFileId") Long signatureFileId,
                                 @Param("updateUser") Long updateUser);

    // ✅ 다음 결재자 pending 처리 시 updateUser 반영
    int updateNextLineToPending(@Param("docVerId") Long docVerId,
                                @Param("pendingCode") String pendingCode,
                                @Param("updateUser") Long updateUser);
    
    ApprovalDocDetailDTO selectDocDetail(@Param("docVerId") Long docVerId);

    List<ApprovalLineViewDTO> selectLinesForDetail(@Param("docVerId") Long docVerId);

    int canRecallDoc(@Param("docVerId") Long docVerId, @Param("userId") Long userId);

    int approveMyTurn(@Param("docVerId") Long docVerId,
	            @Param("userId") Long userId,
	            @Param("comment") String comment);
	
	int rejectMyTurn(@Param("docVerId") Long docVerId,
	           @Param("userId") Long userId,
	           @Param("comment") String comment);
	
	int activateNextApprover(@Param("docVerId") Long docVerId);
	
	int updateDocStatusByDocVerId(@Param("docVerId") Long docVerId,
	                        @Param("statusCode") String statusCode);
	
	int existsWaitingLine(@Param("docVerId") Long docVerId);

}

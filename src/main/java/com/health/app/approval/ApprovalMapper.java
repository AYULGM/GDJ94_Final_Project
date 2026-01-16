package com.health.app.approval;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ApprovalMapper {

    // 초안 조회
    ApprovalDraftDTO selectDraftByDocVerId(@Param("docVerId") Long docVerId);

    // 초안 수정(버전/확장)
    int updateDocumentVersionByDocVerId(ApprovalDraftDTO dto);
    int updateDocumentExtByDocVerId(ApprovalDraftDTO dto);

    // 기안자 문서함
    List<ApprovalMyDocRowDTO> selectMyDocs(@Param("drafterId") Long drafterId);

    // 문서/버전/확장 저장
    int insertDocument(ApprovalDraftDTO dto);
    int insertDocumentVersion(ApprovalDraftDTO dto);
    int insertDocumentExt(ApprovalDraftDTO dto);
    int updateCurrentVersion(ApprovalDraftDTO dto);

    // 사용자 지점 조회
    Long selectBranchIdByUserId(@Param("userId") Long userId);

    // 결재선 저장/조회
    int deleteLinesByDocVerId(@Param("docVerId") Long docVerId);
    int insertLine(ApprovalLineDTO line);
    List<ApprovalLineDTO> selectLinesByDocVerId(@Param("docVerId") Long docVerId);

    // 결재자 트리
    List<Map<String, Object>> selectHeadOfficeApprovers();
    List<Map<String, Object>> selectBranchApprovers();
    List<Map<String, Object>> selectBranches();

    // 결재 요청(상신)
    Long selectDrafterIdByDocVerId(@Param("docVerId") Long docVerId);
    int countLinesByDocVerId(@Param("docVerId") Long docVerId);
    String selectDocStatusByDocVerId(@Param("docVerId") Long docVerId);

    int updateDocumentStatusByDocVerId(@Param("docVerId") Long docVerId,
                                       @Param("statusCode") String statusCode,
                                       @Param("updateUser") Long updateUser);

    int updateVersionStatusByDocVerId(@Param("docVerId") Long docVerId,
            @Param("verStatusCode") String verStatusCode);


    int updateAllLinesStatusByDocVerId(@Param("docVerId") Long docVerId,
                                       @Param("lineStatusCode") String lineStatusCode,
                                       @Param("updateUser") Long updateUser);

    int updateFirstLineToPending(@Param("docVerId") Long docVerId,
                                 @Param("lineStatusCode") String lineStatusCode,
                                 @Param("updateUser") Long updateUser);

    // 받은 결재함
    List<ApprovalInboxRowDTO> selectMyInbox(@Param("approverId") Long approverId);

    // 결재 전용 상품
    List<ApprovalProductDTO> selectProductsByBranch(@Param("branchId") Long branchId);

    // 출력(프린트)
    VacationPrintDTO selectVacationPrint(@Param("docVerId") Long docVerId);
    ApprovalExtPrintDTO selectExtPrint(@Param("docVerId") Long docVerId);
    List<ApprovalPrintLineDTO> selectPrintLines(@Param("docVerId") Long docVerId);

    // 상세 페이지
    ApprovalDocDetailDTO selectDocDetail(@Param("docVerId") Long docVerId);
    List<ApprovalLineViewDTO> selectLinesForDetail(@Param("docVerId") Long docVerId);

    // 회수 가능 여부
    int canRecallDoc(@Param("docVerId") Long docVerId,
                     @Param("userId") Long userId);

    // 다음 결재자 활성화
    int activateNextApprover(@Param("docVerId") Long docVerId);

    // 문서 상태 업데이트
    int updateDocStatusByDocVerId(@Param("docVerId") Long docVerId,
                                  @Param("statusCode") String statusCode);

    // 대기 라인 존재 여부
    int existsWaitingLine(@Param("docVerId") Long docVerId);

    // 내 차례 승인/반려
    int approveMyTurn(@Param("docVerId") Long docVerId,
                      @Param("userId") Long userId,
                      @Param("comment") String comment,
                      @Param("signatureFileId") Long signatureFileId);

    int rejectMyTurn(@Param("docVerId") Long docVerId,
                     @Param("userId") Long userId,
                     @Param("comment") String comment,
                     @Param("signatureFileId") Long signatureFileId);

    // 사용자 조직 정보
    Map<String, Object> selectUserOrg(@Param("userId") Long userId);
    
    String selectTypeCodeByDocVerId(@Param("docVerId") Long docVerId);
    
    int autoApproveAllLines(@Param("docVerId") Long docVerId,
            @Param("updateUser") Long updateUser,
            @Param("comment") String comment);
    
    
    
    
 // 존재 확인
    int existsDocVersion(@org.apache.ibatis.annotations.Param("docVerId") Long docVerId);
    int existsDocumentByCurrentVer(@org.apache.ibatis.annotations.Param("docVerId") Long docVerId);

    String selectVerStatusByDocVerId(@Param("docVerId") Long docVerId);

    
}

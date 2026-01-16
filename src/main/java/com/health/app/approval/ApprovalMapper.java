package com.health.app.approval;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ApprovalMapper {

    // 초안 조회 (문서 + 버전 + 확장)
    ApprovalDraftDTO selectDraftByDocVerId(@Param("docVerId") Long docVerId);

    // 초안 수정 (버전 테이블)
    int updateDocumentVersionByDocVerId(ApprovalDraftDTO dto);

    // 초안 수정 (확장 테이블)
    int updateDocumentExtByDocVerId(ApprovalDraftDTO dto);

    // 기안자가 작성한 문서 목록
    List<ApprovalMyDocRowDTO> selectMyDocs(@Param("drafterId") Long drafterId);

    // 문서 헤더 저장
    int insertDocument(ApprovalDraftDTO dto);

    // 문서 버전 저장
    int insertDocumentVersion(ApprovalDraftDTO dto);

    // 문서 확장 저장
    int insertDocumentExt(ApprovalDraftDTO dto);

    // 현재 버전 갱신
    int updateCurrentVersion(ApprovalDraftDTO dto);

    // 사용자 지점 조회
    Long selectBranchIdByUserId(@Param("userId") Long userId);

    // 결재선 전체 삭제
    int deleteLinesByDocVerId(@Param("docVerId") Long docVerId);

    // 결재선 추가
    int insertLine(ApprovalLineDTO line);

    // 결재선 조회
    List<ApprovalLineDTO> selectLinesByDocVerId(@Param("docVerId") Long docVerId);

    // 본사 결재자 목록
    List<Map<String, Object>> selectHeadOfficeApprovers();

    // 지점 결재자 목록
    List<Map<String, Object>> selectBranchApprovers();

    // 지점 목록
    List<Map<String, Object>> selectBranches();

    // 문서 기안자 조회
    Long selectDrafterIdByDocVerId(@Param("docVerId") Long docVerId);

    // 결재선 개수
    int countLinesByDocVerId(@Param("docVerId") Long docVerId);

    // 문서 상태 조회
    String selectDocStatusByDocVerId(@Param("docVerId") Long docVerId);

    // 문서 상태 변경
    int updateDocumentStatusByDocVerId(@Param("docVerId") Long docVerId,
                                       @Param("statusCode") String statusCode,
                                       @Param("updateUser") Long updateUser);

    // 버전 상태 변경
    int updateVersionStatusByDocVerId(@Param("docVerId") Long docVerId,
            @Param("verStatusCode") String verStatusCode);


    // 결재선 상태 일괄 변경
    int updateAllLinesStatusByDocVerId(@Param("docVerId") Long docVerId,
                                       @Param("lineStatusCode") String lineStatusCode,
                                       @Param("updateUser") Long updateUser);

    // 첫 결재자 활성화
    int updateFirstLineToPending(@Param("docVerId") Long docVerId,
                                 @Param("lineStatusCode") String lineStatusCode,
                                 @Param("updateUser") Long updateUser);

    // 받은 결재함
    List<ApprovalInboxRowDTO> selectMyInbox(@Param("approverId") Long approverId);

    // 지점별 상품 조회
    List<ApprovalProductDTO> selectProductsByBranch(@Param("branchId") Long branchId);

    // 출력(프린트)
    VacationPrintDTO selectVacationPrint(@Param("docVerId") Long docVerId);
    ApprovalExtPrintDTO selectExtPrint(@Param("docVerId") Long docVerId);
    List<ApprovalPrintLineDTO> selectPrintLines(@Param("docVerId") Long docVerId);


    // 문서 상세
    ApprovalDocDetailDTO selectDocDetail(@Param("docVerId") Long docVerId);

    // 상세 결재선
    List<ApprovalLineViewDTO> selectLinesForDetail(@Param("docVerId") Long docVerId);

    // 회수 가능 여부
    int canRecallDoc(@Param("docVerId") Long docVerId,
                     @Param("userId") Long userId);

    // 다음 결재자 활성화
    int activateNextApprover(@Param("docVerId") Long docVerId);

    // 문서 상태 업데이트 (단순)
    int updateDocStatusByDocVerId(@Param("docVerId") Long docVerId,
                                  @Param("statusCode") String statusCode);

    // 대기 중 결재자 존재 여부
    int existsWaitingLine(@Param("docVerId") Long docVerId);

    // 내 차례 승인
    int approveMyTurn(@Param("docVerId") Long docVerId,
                      @Param("userId") Long userId,
                      @Param("comment") String comment,
                      @Param("signatureFileId") Long signatureFileId);

    // 내 차례 반려
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

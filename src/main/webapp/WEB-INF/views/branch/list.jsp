<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<jsp:include page="../includes/admin_header.jsp" />

<!-- Main content -->
<section class="content">
    <div class="container-fluid">

        <div class="row">
            <div class="col-12">

                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">지점 목록</h3>
                    </div>
                    
                    <a href="./register" class="btn btn-primary">
					    지점 등록
					</a>

                    <div class="card-body">
                        <table class="table table-bordered table-hover">
                            <thead>
                                <tr>
                                    <th style="width: 100px">지점번호</th>
                                    <th>지점명</th>
                                    <th>담당자</th>
                                    <th>연락처</th>
                                    <th>운영시간</th>
                                    <th style="width: 100px">상태</th>
                                </tr>
                            </thead>

                            <tbody>
                                <c:forEach var="b" items="${branchList}" varStatus="status">
                                    <tr>
                                        <td>${b.branchId}</td>
                                        <td>
                                            <a href="/branch/detail?branchId=${b.branchId}">
                                                ${b.branchName}
                                            </a>
                                        </td>
                                        <td>${b.managerName}</td>
                                        <td>${b.managerPhone}</td>
                                        <td>${b.operatingHours}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${b.statusCode eq 'BS001'}">
                                                    <span class="badge bg-success">운영중</span>
                                                </c:when>
                                                <c:when test="${b.statusCode eq 'BS002'}">
                                                    <span class="badge bg-danger">폐점</span>
                                                </c:when>
                                                <c:when test="${b.statusCode eq 'BS003'}">
                                                    <span class="badge bg-warning">영업중지</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary">알수없음</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>

                                <c:if test="${empty branchList}">
                                    <tr>
                                        <td colspan="6" class="text-center">
                                            등록된 지점이 없습니다.
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </div>

    </div>
</section>

<jsp:include page="../includes/admin_footer.jsp" />

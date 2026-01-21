<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>

<!--begin::Sidebar-->
<aside class="app-sidebar bg-body-secondary shadow" data-bs-theme="dark">
  <div class="sidebar-brand">
    <a href="<c:url value='/statistics'/>" class="brand-link">
      <img
              src="<c:url value='/img/doge.jpg'/>"
              alt="AdminLTE Logo"
              class="brand-image opacity-75 shadow"
      />
      <span class="brand-text fw-light">Health On Company</span>
    </a>
  </div>

  <div class="sidebar-wrapper">
    <nav class="mt-2">

      <ul class="nav sidebar-menu flex-column" data-accordion="false" id="navigation">

        <li class="nav-item">
          <a href="<c:url value='/statistics'/>" class="nav-link">
            <i class="nav-icon bi bi-speedometer"></i>
            <p>Dash Board</p>
          </a>
        </li>

        <sec:authorize access="hasAnyRole('GRANDMASTER','MASTER','ADMIN')">
          <li class="nav-item">
            <a href="<c:url value='/branch/list'/>" class="nav-link">
              <i class="nav-icon bi bi-building"></i>
              <p>지점 관리</p>
            </a>
          </li>
        </sec:authorize>

        <sec:authorize access="hasAnyRole('GRANDMASTER','MASTER','ADMIN')">
          <li class="nav-item">
            <a href="<c:url value='/userManagement/list'/>" class="nav-link">
              <i class="nav-icon bi bi-people"></i>
              <p>사용자 관리</p>
            </a>
          </li>
        </sec:authorize>

        <li class="nav-item">
          <a href="<c:url value='/notices'/>" class="nav-link">
            <i class="nav-icon bi bi-bell"></i>
            <p>공지사항</p>
          </a>
        </li>
		
		<!-- 전자결재 -->
        <li class="nav-item">
          <a href="#" class="nav-link" data-lte-toggle="treeview">
            <i class="nav-icon bi bi-file-earmark-check"></i>
            <p>
              전자 결재
              <i class="nav-arrow bi bi-chevron-right"></i>
            </p>
          </a>

          <ul class="nav nav-treeview">
            <li class="nav-item">
              <a href="<c:url value='/approval/list'/>" class="nav-link">
                <p>결재 목록</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="<c:url value='/approval/signature'/>" class="nav-link">
                <p>서명창</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="<c:url value='/approval/inbox'/>" class="nav-link">
                <p>결재함</p>
              </a>
            </li>
          </ul>
        </li>
		
        <li class="nav-item">
          <a href="<c:url value='/inventory'/>" class="nav-link">
            <i class="nav-icon bi bi-box-seam"></i>
            <p>재고 현황</p>
          </a>
        </li>

        <!--  1) 발주요청(지점 → 본사) : 지점(CAPTAIN/CREW)만 노출 -->
        <sec:authorize access="hasAnyRole('CAPTAIN','CREW')">
          <li class="nav-item">
            <a href="#" class="nav-link" data-lte-toggle="treeview">
              <i class="nav-icon bi bi-inboxes"></i>
              <p>
                발주요청
                <i class="nav-arrow bi bi-chevron-right"></i>
              </p>
            </a>

            <ul class="nav nav-treeview">
              <li class="nav-item">
                <!--  변경: 기존 /inbound -> /purchase/orders -->
				<a href="<c:url value='/purchase/orders?docType=PO'/>" class="nav-link">
				  <p>발주요청서 목록</p>
				</a>

              </li>
            </ul>
          </li>
        </sec:authorize>

        <!--  2) 구매요청/발주(본사 → 외부) : 본사 권한만 노출 -->
        <sec:authorize access="hasAnyRole('GRANDMASTER','MASTER','ADMIN')">
          <li class="nav-item">
            <a href="#" class="nav-link" data-lte-toggle="treeview">
              <i class="nav-icon bi bi-truck"></i>
              <p>
                구매/발주
                <i class="nav-arrow bi bi-chevron-right"></i>
              </p>
            </a>

            <ul class="nav nav-treeview">
              <li class="nav-item">
                <a href="<c:url value='/approval/form'/>?entry=buy2" class="nav-link">
                  <p>구매요청서 작성</p>
                </a>
              </li>

              <!-- ✅ 변경: 목록을 1개로 통합 (구매요청서/발주서가 같은 /purchase/orders를 보니까) -->
              <li class="nav-item">
                <a href="<c:url value='/purchase/orders'/>" class="nav-link">
                  <p>구매/발주 목록</p>
                </a>
              </li>

              <!-- ❌ 삭제(중복): 발주서 목록 메뉴 제거
              <li class="nav-item">
                <a href="<c:url value='/purchase/orders'/>" class="nav-link">
                  <p>발주서 목록</p>
                </a>
              </li>
              -->

              <li class="nav-item">
                <a href="<c:url value='/audit'/>" class="nav-link">
                  <p>감사 로그</p>
                </a>
              </li>
            </ul>
          </li>
        </sec:authorize>

        <!-- 일정 관리 Treeview -->
        <li class="nav-item">
          <a href="#" class="nav-link" data-lte-toggle="treeview">
            <i class="nav-icon bi bi-calendar-event"></i>
            <p>
              캘린더
              <i class="nav-arrow bi bi-chevron-right"></i>
            </p>
          </a>
          <ul class="nav nav-treeview">
            <li class="nav-item">
              <a href="<c:url value='/schedules'/>?filter=all" class="nav-link schedule-filter" data-scope="all">
                <p>전체 일정</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="<c:url value='/schedules'/>?filter=my" class="nav-link schedule-filter" data-scope="PERSONAL">
                <p>내 일정</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="<c:url value='/schedules'/>?filter=dept" class="nav-link schedule-filter" data-scope="DEPARTMENT">
                <p>부서 일정</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="<c:url value='/schedules'/>?filter=company" class="nav-link schedule-filter" data-scope="COMPANY">
                <p>전사 일정</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="<c:url value='/schedules/manage'/>" class="nav-link">
                <p>일정 관리</p>
              </a>
            </li>
          </ul>
        </li>

        <!-- 매출·지출 통계 -->
        <li class="nav-item">
          <a href="#" class="nav-link" data-lte-toggle="treeview">
            <i class="nav-icon bi bi-bar-chart"></i>
            <p>
              매출·지출 통계
              <i class="nav-arrow bi bi-chevron-right"></i>
            </p>
          </a>
          <ul class="nav nav-treeview">
            <li class="nav-item">
              <a href="<c:url value='/statistics/sales'/>" class="nav-link">
                <p>매출 통계</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="<c:url value='/statistics/expenses'/>" class="nav-link">
                <p>지출 통계</p>
              </a>
            </li>
          </ul>
        </li>

        <!-- 정산 관리 -->
        <li class="nav-item">
          <a href="#" class="nav-link" data-lte-toggle="treeview">
            <i class="nav-icon bi bi-calculator"></i>
            <p>
              정산 관리
              <i class="nav-arrow bi bi-chevron-right"></i>
            </p>
          </a>
          <ul class="nav nav-treeview">
            <li class="nav-item">
              <a href="<c:url value='/sales'/>" class="nav-link">
                <p>매출 관리</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="<c:url value='/expenses'/>" class="nav-link">
                <p>지출 관리</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="<c:url value='/statistics/comparison'/>" class="nav-link">
                <p>손익 비교</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="<c:url value='/settlements/confirm'/>" class="nav-link">
                <p>정산 확정</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="<c:url value='/settlements'/>" class="nav-link">
                <p>정산 내역 조회</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="<c:url value='/settlements/history'/>" class="nav-link">
                <p>정산 처리 이력</p>
              </a>
            </li>
          </ul>
        </li>

      </ul>
    </nav>
  </div>
</aside>
<!--end::Sidebar-->

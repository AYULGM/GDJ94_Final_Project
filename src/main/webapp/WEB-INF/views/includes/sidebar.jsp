<%@ taglib prefix="c" uri="jakarta.tags.core"%>
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
      <span class="brand-text fw-light">AdminLTE 4</span>
    </a>
  </div>

  <div class="sidebar-wrapper">
    <nav class="mt-2">

      <!-- ✅ sidebar-menu는 반드시 1개만 -->
      <ul
        class="nav sidebar-menu flex-column"
        data-accordion="false"
        role="navigation"
        id="navigation"
      >

        <li class="nav-item">
          <a href="<c:url value='/statistics'/>" class="nav-link">
            <i class="nav-icon bi bi-speedometer"></i>
            <p>Dash Board</p>
          </a>
        </li>

        <li class="nav-item">
          <a href="<c:url value='/branch/list'/>" class="nav-link">
            <i class="nav-icon bi bi-building"></i>
            <p>지점 관리</p>
          </a>
        </li>

        <li class="nav-item">
          <a href="<c:url value='/userManagement/list'/>" class="nav-link">
            <i class="nav-icon bi bi-people"></i>
            <p>사용자 관리</p>
          </a>
        </li>

        <li class="nav-item">
          <a href="<c:url value='/notices'/>" class="nav-link">
            <i class="nav-icon bi bi-bell"></i>
            <p>공지사항</p>
          </a>
        </li>

        <li class="nav-item">
          <a href="<c:url value='/inventory'/>" class="nav-link">
            <i class="nav-icon bi bi-box-seam"></i>
            <p>재고 관리</p>
          </a>
        </li>
        <!-- ========================= -->
        <!--  구매/입고 (통합) -->
        <!-- ========================= -->
        <li class="nav-item">
          <a href="#" class="nav-link" data-lte-toggle="treeview">
            <i class="nav-icon bi bi-truck"></i>
            <p>
              구매/입고
              <i class="nav-arrow bi bi-chevron-right"></i>
            </p>
          </a>

          <ul class="nav nav-treeview">
            <!--  문서유형은 AT003 하나만 -->
            <li class="nav-item">
              <a href="<c:url value='/approval/form'/>?typeCode=AT003&formCode=DF005" class="nav-link">
                <p>구매요청서/발주서 작성</p>
              </a>
            </li>

            <!--  시스템 목록 화면이 있으면 연결, 없으면 일단 빼도 됨 -->
            <li class="nav-item">
              <a href="<c:url value='/inbound'/>" class="nav-link">
                <p>구매요청서/발주서 목록</p>
              </a>
            </li>
          </ul>
        </li>


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
                <a href="#" class="nav-link" id="sidebar-add-event">
                    <i class="nav-icon bi bi-plus-circle"></i>
                    <p>일정 등록</p>
                </a>
            </li>
            <li class="nav-item">
                <a href="<c:url value='/schedules/manage'/>" class="nav-link">
                    <i class="nav-icon bi bi-list-task"></i>
                    <p>일정 관리</p>
                </a>
            </li>
                      </ul>
        </li>

        <!-- ✅ 전자결재 Treeview (여기만 toggle) -->
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
              <a href="/approval/list" class="nav-link">
                <p>결재 목록</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="/approval/form" class="nav-link">
                <p>결재 작성</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="/approval/signature" class="nav-link">
                <p>서명창</p>
              </a>
            </li>
			<li class="nav-item">
              <a href="/approval/line?docVerId=3" class="nav-link">
                <p>결재 라인</p>
              </a>
            </li>
            <li class="nav-item">
              <a href="/approval/inbox" class="nav-link">
                <p>기안함</p>
              </a>
            </li>
          </ul>
        </li>

        <!-- 매출·지출 통계 Treeview -->
        <li class="nav-item">
          <a href="#" class="nav-link" data-lte-toggle="treeview">
            <i class="nav-icon bi bi-bar-chart"></i>
            <p>
              매출·지출 통계
              <i class="nav-arrow bi bi-chevron-right"></i>
            </p>
          </a>
          <ul class="nav nav-treeview">
            <!-- 매출 통계 -->
            <li class="nav-item">
              <a href="#" class="nav-link" data-lte-toggle="treeview">
                <i class="bi bi-graph-up"></i>
                <p>
                  매출 통계
                  <i class="nav-arrow bi bi-chevron-right"></i>
                </p>
              </a>
              <ul class="nav nav-treeview">
                <li class="nav-item">
                  <a href="<c:url value='/statistics/sales/by-branch'/>" class="nav-link">
                    <p>지점별</p>
                  </a>
                </li>
                <li class="nav-item">
                  <a href="<c:url value='/statistics/sales/by-category'/>" class="nav-link">
                    <p>항목별</p>
                  </a>
                </li>
                <li class="nav-item">
                  <a href="<c:url value='/statistics/sales/by-period'/>" class="nav-link">
                    <p>기간별</p>
                  </a>
                </li>
              </ul>
            </li>
            <!-- 지출 통계 -->
            <li class="nav-item">
              <a href="#" class="nav-link" data-lte-toggle="treeview">
                <i class="bi bi-graph-down"></i>
                <p>
                  지출 통계
                  <i class="nav-arrow bi bi-chevron-right"></i>
                </p>
              </a>
              <ul class="nav nav-treeview">
                <li class="nav-item">
                  <a href="<c:url value='/statistics/expenses/by-branch'/>" class="nav-link">
                    <p>지점별</p>
                  </a>
                </li>
                <li class="nav-item">
                  <a href="<c:url value='/statistics/expenses/by-category'/>" class="nav-link">
                    <p>항목별</p>
                  </a>
                </li>
                <li class="nav-item">
                  <a href="<c:url value='/statistics/expenses/by-period'/>" class="nav-link">
                    <p>기간별</p>
                  </a>
                </li>
              </ul>
            </li>
          </ul>
        </li>

        <!-- 정산 관리 Treeview -->
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
                <p>정산 대상 매출 (매출보고서)</p>
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
                <p>정산 이력 로그</p>
              </a>
            </li>
          </ul>
        </li>

        <!-- 지출 관리 -->
        <li class="nav-item">
          <a href="<c:url value='/expenses'/>" class="nav-link">
            <i class="nav-icon bi bi-wallet2"></i>
            <p>지출 관리</p>
          </a>
        </li>

      </ul>
    </nav>
  </div>
</aside>
<!--end::Sidebar-->

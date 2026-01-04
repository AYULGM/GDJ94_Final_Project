<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!--begin::Sidebar-->
<aside class="app-sidebar bg-body-secondary shadow" data-bs-theme="dark">
  <div class="sidebar-brand">
    <a href="<c:url value='/'/>" class="brand-link">
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
          <a href="<c:url value='/'/>" class="nav-link">
            <i class="nav-icon bi bi-speedometer"></i>
            <p>Dashboard</p>
          </a>
        </li>

        <li class="nav-item">
          <a href="<c:url value='/branches'/>" class="nav-link">
            <i class="nav-icon bi bi-building"></i>
            <p>지점 관리</p>
          </a>
        </li>

        <li class="nav-item">
          <a href="<c:url value='/users'/>" class="nav-link">
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

        <!-- 일정 관리 Treeview -->
        <li class="nav-item menu-open">
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
              <a href="/approval/line" class="nav-link">
                <p>결재 라인</p>
              </a>
            </li>
          </ul>
        </li>

        <li class="nav-item">
          <a href="<c:url value='/statistics'/>" class="nav-link">
            <i class="nav-icon bi bi-bar-chart"></i>
            <p>통계</p>
          </a>
        </li>

      </ul>
    </nav>
  </div>
</aside>
<!--end::Sidebar-->

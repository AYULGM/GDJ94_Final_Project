<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<!doctype html>
<html lang="ko">
  <!--begin::Head-->
  <head>
	<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
	<%@ taglib prefix="c" uri="jakarta.tags.core"%>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>AdminLTE v4 | Dashboard</title>

    <!--begin::Fonts-->
    <link
      rel="stylesheet"
      href="https://cdn.jsdelivr.net/npm/@fontsource/source-sans-3@5.0.12/index.css"
      integrity="sha256-tXJfXfp6Ewt1ilPzLDtQnJV4hclT9XuaZUKyUvmyr+Q="
      crossorigin="anonymous"
      media="print"
      onload="this.media='all'"
    />
    <!--end::Fonts-->

    <!--begin::Third Party Plugin(OverlayScrollbars)-->
    <link
      rel="stylesheet"
      href="https://cdn.jsdelivr.net/npm/overlayscrollbars@2.11.0/styles/overlayscrollbars.min.css"
      crossorigin="anonymous"
    />
    <!--end::Third Party Plugin(OverlayScrollbars)-->

    <!--begin::Third Party Plugin(Bootstrap Icons)-->
    <link
      rel="stylesheet"
      href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css"
      crossorigin="anonymous"
    />
    <!--end::Third Party Plugin(Bootstrap Icons)-->

    <!--begin::Required Plugin(AdminLTE)-->
    <link rel="stylesheet" href="<c:url value='/css/adminlte.min.css'/>" />
    <!--end::Required Plugin(AdminLTE)-->

    <!-- apexcharts -->
    <link
      rel="stylesheet"
      href="https://cdn.jsdelivr.net/npm/apexcharts@3.37.1/dist/apexcharts.css"
      integrity="sha256-4MX+61mt9NVvvuPjUWdUdyfZfxSB1/Rf9WtqRHgG5S0="
      crossorigin="anonymous"
    />

    <!-- jsvectormap -->
    <link
      rel="stylesheet"
      href="https://cdn.jsdelivr.net/npm/jsvectormap@1.5.3/dist/css/jsvectormap.min.css"
      integrity="sha256-+uGLJmmTKOqBr+2E6KDYs/NRsHxSkONXFHUL0fy2O/4="
      crossorigin="anonymous"
    />
  </head>
  <!--end::Head-->

  <!--begin::Body-->
  <body class="layout-fixed sidebar-expand-lg sidebar-open bg-body-tertiary">
    <!--begin::App Wrapper-->
    <div class="app-wrapper">
      <!--begin::Header-->
      <nav class="app-header navbar navbar-expand bg-body">
        <div class="container-fluid">
          <ul class="navbar-nav">
            <li class="nav-item">
              <a class="nav-link" data-lte-toggle="sidebar" href="#" role="button">
                <i class="bi bi-list"></i>
              </a>
            </li>
            <li class="nav-item d-none d-md-block"><a href="<c:url value='/'/>" class="nav-link">Home</a></li>
          </ul>

          <ul class="navbar-nav ms-auto">
              
            <!-- Notifications -->
            <li class="nav-item dropdown" id="notification-dropdown">
              <a class="nav-link" data-bs-toggle="dropdown" href="#" role="button" aria-expanded="false" id="notification-toggle">
                <i class="bi bi-bell-fill"></i>
                <span class="navbar-badge badge text-bg-warning" id="notification-badge" style="display: none;">0</span>
              </a>
              <div class="dropdown-menu dropdown-menu-lg dropdown-menu-end" id="notification-menu" style="max-height: 400px; overflow-y: auto;">
                <span class="dropdown-item dropdown-header">
                  <span id="notification-count-text">0</span> 개의 알림
                  <button class="btn btn-sm btn-link float-end" id="mark-all-read-btn" style="display: none;">모두 읽음</button>
                </span>
                <div class="dropdown-divider"></div>
                <div id="notification-list">
                  <div class="dropdown-item text-center text-secondary">알림이 없습니다</div>
                </div>
                <div class="dropdown-divider"></div>
                <a href="#" class="dropdown-item dropdown-footer" id="view-all-notifications">모든 알림 보기</a>
              </div>
            </li>


            <li class="nav-item dropdown user-menu">
              <a href="#" class="nav-link dropdown-toggle" data-bs-toggle="dropdown" role="button" aria-expanded="false">
                <img
                  src="<c:url value='/img/doge.jpg'/>"
                  class="user-image rounded-circle shadow"
                  alt="User Image"
                />
                <span class="d-none d-md-inline">
				    <sec:authentication property="principal.name"/>
				</span>
              </a>
              <ul class="dropdown-menu dropdown-menu-lg dropdown-menu-end">
                <li class="user-header text-bg-primary">
                  <img
                    src="<c:url value='/img/doge.jpg'/>"
                    class="rounded-circle shadow"
                    alt="User Image"
                  />
                  <p>
                     <sec:authentication property="principal.name"/>
					 <small>안녕하세요</small>
                  </p>
                </li>
<!--                 <li class="user-body">
                  <div class="row">
                    <div class="col-4 text-center"><a href="#">Followers</a></div>
                    <div class="col-4 text-center"><a href="#">Sales</a></div>
                    <div class="col-4 text-center"><a href="#">Friends</a></div>
                  </div>
                </li> 
-->
                <li class="user-body">
                  <a href="/users/mypage" class="btn btn-default btn-flat">My page</a>
                  <a href="<c:url value='/logout'/>" class="btn btn-default btn-flat float-end">Sign out</a>
                </li>
              </ul>
            </li>
          </ul>
        </div>
      </nav>
      <!--end::Header-->

      <!--begin::Sidebar-->
	  <jsp:include page="./sidebar.jsp" />

      <!--begin::App Main-->
      <main class="app-main">
        <div class="app-content-header">
          <div class="container-fluid">
            <div class="row">
              <div class="col-sm-6"><h3 class="mb-0">${pageTitle}</h3></div>
              <div class="col-sm-6">
                <ol class="breadcrumb float-sm-end">
                  <li class="breadcrumb-item"><a href="<c:url value='/'/>">Home</a></li>
                  <li class="breadcrumb-item active" aria-current="page">${pageTitle}</li>
                </ol>
              </div>
            </div>
          </div>
        </div>

        <div class="app-content">
          <div class="container-fluid">
            <!-- 여기부터 각 페이지 컨텐츠 -->

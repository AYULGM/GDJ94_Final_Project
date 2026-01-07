          </div>
          <!--end::Container-->
        </div>
        <!--end::App Content-->
      </main>
      <!--end::App Main-->

      <!--begin::Footer-->
      <footer class="app-footer">
        <div class="float-end d-none d-sm-inline">Anything you want</div>
        <strong>
          Copyright &copy; 2014-2025&nbsp;
          <a href="https://adminlte.io" class="text-decoration-none">AdminLTE.io</a>.
        </strong>
        All rights reserved.
      </footer>
      <!--end::Footer-->
    </div>
    <!--end::App Wrapper-->

    <!--begin::Script-->

    <!-- jQuery (Needed for some AdminLTE components and our custom script) -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>

    <!-- OverlayScrollbars -->
    <script
      src="https://cdn.jsdelivr.net/npm/overlayscrollbars@2.11.0/browser/overlayscrollbars.browser.es6.min.js"
      crossorigin="anonymous"
    ></script>

    <!-- Bootstrap 5 (bundle: Popper 포함 / dropdown 안정화) -->
    <script
      src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"
      crossorigin="anonymous"
    ></script>

	<!-- AdminLTE -->
	<script src="/js/adminlte.min.js"></script>

    <!-- OverlayScrollbars Configure (ReferenceError 방지) -->
    <script>
      const SELECTOR_SIDEBAR_WRAPPER = '.sidebar-wrapper';
      const Default = {
        scrollbarTheme: 'os-theme-light',
        scrollbarAutoHide: 'leave',
        scrollbarClickScroll: true,
      };

      document.addEventListener('DOMContentLoaded', function () {
        const sidebarWrapper = document.querySelector(SELECTOR_SIDEBAR_WRAPPER);

        if (
          sidebarWrapper &&
          typeof OverlayScrollbarsGlobal !== 'undefined' &&
          OverlayScrollbarsGlobal.OverlayScrollbars
        ) {
          OverlayScrollbarsGlobal.OverlayScrollbars(sidebarWrapper, {
            scrollbars: {
              theme: Default.scrollbarTheme,
              autoHide: Default.scrollbarAutoHide,
              clickScroll: Default.scrollbarClickScroll,
            },
          });
        }
      });
    </script>

    <!-- 알림 시스템 -->
    <script src="/js/notifications.js"></script>
    <script>
      // 알림 클라이언트 초기화
      document.addEventListener('DOMContentLoaded', function() {

        // notificationClient가 정의되어 있는지 확인
        if (typeof notificationClient === 'undefined') {
          return;
        }


        // GlobalControllerAdvice에서 전달된 실제 로그인 사용자 ID 사용
        const currentUserId = ${currentUserId != null ? currentUserId : 'null'};
        const contextPath = '${pageContext.request.contextPath}';

        // 로그인하지 않은 경우 초기화하지 않음
        if (currentUserId === null) {
          return;
        }

        // 알림 클라이언트 초기화
        notificationClient.init(currentUserId, contextPath);

        // 브라우저 알림 권한 요청
        notificationClient.requestNotificationPermission();

        // 새 알림 수신 시 콜백 (선택 사항)
        notificationClient.onNewNotification(function(notification) {
          // 필요시 추가 UI 업데이트 로직
        });

      });
    </script>
    <!--end::Script-->
  </body>
</html>

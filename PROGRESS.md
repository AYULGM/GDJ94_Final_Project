# 프로세스 진행현황

## 프로젝트 개요

이 프로젝트는 건강 관련 애플리케이션을 관리하기 위한 Spring Boot 웹 애플리케이션입니다. Java와 Maven으로 구축되었으며, 데이터 저장을 위해 MariaDB 데이터베이스를 사용합니다. 애플리케이션은 MVC(Model-View-Controller) 패턴을 따르며, 뷰 계층에는 JSP(JavaServer Pages)를 사용하고, Spring MVC가 요청-응답 주기를 처리합니다.

### 주요 기술

*   **백엔드:** Spring Boot, Spring MVC, Spring Security (현재 비활성화됨)
*   **데이터베이스:** MariaDB
*   **데이터 접근:** MyBatis
*   **뷰:** JSP, JSTL
*   **빌드 도구:** Maven
*   **언어:** Java 21


**참고:** 제공된 파일에는 데이터베이스 연결 세부 정보가 완전히 구성되어 있지 않습니다. 올바른 데이터베이스 URL, 사용자 이름 및 암호로 `application.properties` 또는 `application-dev.properties` 파일을 구성해야 할 수 있습니다.

## 개발 컨벤션

*   **테스팅:** `src/test/java` 디렉토리에 테스트 클래스가 있는 것으로 보아 단위 및 통합 테스트가 개발 프로세스의 일부입니다.
*   **뷰:** JSP 파일은 `src/main/webapp/WEB-INF/views`에 있습니다.
*   **컨트롤러:** Spring MVC 컨트롤러는 `com.health.app` 아래의 해당 패키지에 있습니다.

---

## 진행 상황 (Progress)

### 2025-12-26: 공용 첨부파일 (FL) 기능 기본 구현 완료

`CODING_PLAN.md`의 "1주차" 마일스톤에 따라 공용 첨부파일 기능의 핵심 CRUD 및 연동 로직을 구현했습니다. 이 기능은 다른 모듈(공지사항, 전자결재 등)에서 재사용될 수 있도록 공통 모듈로 설계되었습니다.

#### **주요 구현 내용**
1.  **파일 업로드/다운로드**:
    *   로컬 파일 시스템에 파일을 저장하고, 고유 ID(`fileId`)를 통해 파일을 조회하고 다운로드하는 기능을 구현했습니다.
    *   `application-dev.properties`의 `app.upload.base` 설정을 참조하여 유연한 파일 저장 경로를 지원합니다.

2.  **데이터베이스 연동**:
    *   `attachments` 테이블과 매핑되는 `Attachment.java` 엔티티를 생성했습니다.
    *   `attachment_links` 테이블과 매핑되는 `AttachmentLink.java` 엔티티를 생성했습니다.
    *   `JpaRepository`를 사용하여 `attachments` 및 `attachment_links` 테이블의 CRUD 작업을 처리합니다.

3.  **서비스 로직 구현 (`FileService`)**:
    *   `storeFile()`: 파일을 저장하고 `attachments` 테이블에 정보를 기록한 후, `fileId`를 반환합니다.
    *   `linkFileToEntity()`: `fileId`와 다른 엔티티 정보(타입, ID)를 받아 `attachment_links` 테이블에 연결 정보를 생성합니다.
    *   `deleteAttachment()`: `attachments` 테이블의 `use_yn` 컬럼을 `false`로 변경하여 파일을 논리적으로 삭제합니다.

#### **생성 및 수정된 주요 파일**
*   **Controller**: `src/main/java/com/health/app/files/FileController.java`
*   **Service**: `src/main/java/com/health/app/files/FileService.java`
*   **Entity**: `src/main/java/com/health.app/attachments/Attachment.java`
*   **Entity**: `src/main/java/com.health.app/attachments/AttachmentLink.java`
*   **Repository**: `src/main/java/com/health.app/attachments/AttachmentRepository.java`
*   **Repository**: `src/main/java/com.health.app/attachments/AttachmentLinkRepository.java`
*   **View**: `src/main/webapp/WEB-INF/views/files/upload.jsp`
*   **Configuration**: `pom.xml` (`spring-boot-starter-data-jpa` 의존성 추가)
*   **Configuration**: `.gitignore` (`sql/` 디렉토리 제외 설정)

#### **다음 작업 계획**
*   "일정 관리 (SC)" 기능 구현 시작
*   다른 기능(공지사항 등) 개발 시 `FileService` 연동 테스트

---

## 🛠 주요 트러블 슈팅 (Troubleshooting)

### 1️⃣ `JpaRepository` 메서드 미정의 에러  
(`save()`, `findById()` 등 인식 불가)

- **문제**  
  `AttachmentRepository`에서 `JpaRepository`의 기본 메서드(`save`, `findById` 등)를 찾을 수 없다는 컴파일 에러 발생

- **원인**  
  `pom.xml`에 `spring-boot-starter-data-jpa` 의존성이 누락되어  
  Spring Data JPA 기능이 활성화되지 않음  
  (초기 분석 과정에서 의존성 누락 확인)

- **해결**  
  - `pom.xml`에 `spring-boot-starter-data-jpa` 의존성 추가  
  - Maven 프로젝트 재빌드 (`clean → install`) 수행  
  - JPA 관련 라이브러리 정상 로딩 확인

---

### 2️⃣ `FileService.loadFileAsResource()` 인자 타입 불일치

- **문제**  
  `FileController`에서  
  `FileService.loadFileAsResource()` 호출 시  
  `Long` 타입 대신 `String` 타입을 전달하여 컴파일 에러 발생

- **원인**  
  `FileService`의 `loadFileAsResource()` 메서드 시그니처가  
  `Long fileId`를 인자로 받도록 변경되었으나,  
  `FileController`의 호출 코드가 함께 수정되지 않음  

- **해결**  
  `FileController.downloadFile()` 메서드에서  
  `fileService.loadFileAsResource(Long fileId)` 형태로  
  인자 타입을 일치시키도록 수정

---

### 3️⃣ Maven 명령어 실행 환경 문제

- **문제**  
  `mvn clean install` 실행 시  
  `"명령어를 찾을 수 없습니다"` 에러 발생

- **원인**  
  - Maven이 시스템 PATH에 등록되지 않았거나  
  - IDE 내부 터미널 환경에서 `mvn` 명령어 실행이 제한됨

- **해결**  
  CLI 대신 IDE에서 제공하는 Maven 빌드 기능 사용  
  - Maven 프로젝트 `Reimport`  
  - `clean`, `install` 작업을 IDE UI를 통해 수행

---

### 2025-12-29: 일정 관리 (SC) 기능 개발 계획 수립

`CODING_PLAN.md`의 "일정 관리" 요구사항과 추가 논의된 내용을 바탕으로 상세 개발 계획을 수립했습니다.

#### **주요 기능 명세**
1.  **일정 구분**:
    *   개인(`PERSONAL`), 부서(`DEPARTMENT`), 전사(`COMPANY`) 일정으로 구분하고, UI에서 각각 다른 색상으로 표시합니다.
    *   전사 일정은 `MASTER` 권한, 부서 일정은 `ADMIN` 권한 사용자만 생성할 수 있습니다.

2.  **일정 생성**:
    *   일정 등록 시 **참석자 지정**이 가능합니다.
    *   참석자들의 기존 일정을 조회하여 **실시간으로 충돌 여부를 확인**하고, 가능한 시간을 안내합니다.
    *   일정 확정 시, 모든 참석자의 캘린더에 해당 일정이 자동으로 추가됩니다.

3.  **부가 기능**:
    *   일정에 **파일 첨부** 기능을 포함합니다. (`FileService` 연동)
    *   반복 일정(매주/매월) 설정 기능을 제공합니다.
    *   일정 등록/변경 시 관련자에게 알림을 발송합니다. (`NotificationService` 연동)

4.  **UI/UX 개선**:
    *   사이드바 메뉴(`전체`, `내`, `부서`, `전사`)를 통해 캘린더에 표시될 일정을 필터링합니다.
    *   캘린더 하단에 오늘 또는 선택한 날짜의 일정 목록을 리스트 형태로 제공하고, 추가 필터링 옵션(오늘/이번 주, 유형별)을 둡니다.
    *   별도의 '일정 관리' 페이지에서 내가 생성한 일정 목록을 관리(수정, 삭제, 상태 변경)할 수 있습니다.

#### **개발 순서 계획**
*   **1단계 (기본 골격)**: `Schedule` 엔티티 및 기본 CRUD API 구현, 캘린더 연동 및 색상 구분 표시
*   **2단계 (일정 등록 고도화)**: `ScheduleAttendee` 엔티티 추가, 참석자 지정 및 실시간 충돌 확인 기능 구현
*   **3단계 (부가 기능)**: 파일 첨부 및 반복 일정 기능 구현
*   **4단계 (관리 기능)**: '일정 관리' 페이지 및 관련 기능 구현
*   **5단계 (사용자 경험 개선)**: 캘린더 하단 리스트 뷰 및 필터링 기능 구현
*   **6단계 (최종 연동)**: 알림 서비스 연동

### 2025-12-29: 일정 관리 (SC) 기능 기반 클래스 생성 완료

상세 개발 계획에 따라, MyBatis 기반의 데이터 처리를 위한 기반 클래스 및 설정 파일 생성을 완료했습니다.

#### **주요 구현 내용**
1.  **데이터베이스 스키마 수정 (`VITALCORE.sql`)**:
    *   `calendar_events` 테이블에 `location`, `status_code`, `department_code` 등 상세 기능 구현을 위한 컬럼을 추가하고 주석을 보강했습니다.
    *   일정 참석자 관리를 위한 `schedule_attendees` 테이블을 새로 추가했습니다.
    *   테이블 간의 관계 설정을 위한 외래 키(FK) 제약 조건을 추가했습니다.

2.  **기반 클래스 생성 (`com.health.app.schedules` 패키지)**:
    *   **Enum (3개)**: `ScheduleType`, `ScheduleStatus`, `AttendanceStatus`
    *   **DTO (2개)**: `CalendarEventDto`, `ScheduleAttendeeDto`
    *   **MyBatis 매퍼 인터페이스 (2개)**: `CalendarEventMapper`, `ScheduleAttendeeMapper`
    *   **MyBatis XML 매퍼 파일 (2개)**: `CalendarEventMapper.xml`, `ScheduleAttendeeMapper.xml`

#### **다음 작업 계획**
*   **서비스(Service) 계층 구현**: `ScheduleService` 클래스를 생성하여 오늘 만든 매퍼들을 이용한 비즈니스 로직을 구현합니다.
*   **컨트롤러(Controller) 수정**: `ScheduleController`에 `ScheduleService`를 주입하고, FullCalendar 연동을 위한 RESTful API 엔드포인트를 구현합니다.
---

### 2025-12-30: 일정 관리 (SC) 기능 구현 및 리팩토링 진행 상황

#### **주요 구현 내용**

*   **기본 일정 등록 기능 구현**:
    *   `ScheduleService.java`: `createCalendarEvent` 메소드 추가 (기본 필드, `allDay`/`repeating` 기본값 설정).
    *   `ScheduleController.java`: `POST /schedules/events` 엔드포인트 추가.
    *   `view.jsp`: 일정 등록 모달 UI, `FormData`를 통한 데이터/파일 전송 로직 구현.
*   **사이드바 메뉴 및 캘린더 필터링**:
    *   `sidebar.jsp`: 일정 관련 메뉴 (`전체 일정`, `내 일정`, `부서 일정`, `전사 일정`, `일정 등록`, `일정 관리`) 구조 개편.
    *   `schedules.js`: `currentScope` 변수를 이용한 필터링 로직 구현, `scope` 파라미터로 이벤트 조회.
    *   `ScheduleController.java`: `getEvents` 메소드에 `scope` 파라미터 처리 로직 추가.
*   **캘린더 하단 일정 리스트**:
    *   `view.jsp`: 캘린더 하단에 일정 목록을 표시하는 `div` 영역 추가.
    *   `schedules.js`: `updateEventList` 함수를 통해 선택된 날짜의 이벤트를 목록으로 표시. (다중일정 포함, 시간/종일 표시)
*   **참석자 이름 검색 기능 구현**:
    *   **리팩토링**: `users` 패키지와의 분리를 위해 `UserSearchDto`, `UserMapper.java`, `UserMapper.xml`을 `com.health.app.schedules.search` 패키지로 이동 및 `AttendeeSearchDto`, `AttendeeSearchMapper.java`, `AttendeeSearchMapper.xml`로 이름 변경. `UserController.java` 원복.
    *   **백엔드**: `ScheduleController.java`에 `AttendeeSearchMapper` 주입 및 `GET /schedules/users/search` 엔드포인트 추가. `ScheduleService.java`에 `getUsersByIds` 메소드 추가.
    *   **프론트엔드**: `schedules.js`에 이름 검색, 결과 표시, 참석자 선택/제거 로직 구현 및 백엔드 API 연동.
*   **파일 첨부 기능 연동**:
    *   `view.jsp`: `FormData`를 통한 파일 첨부 UI 연동.
    *   `ScheduleController.java`: `POST /schedules/events` 메소드에서 `List<MultipartFile>`을 `@RequestPart`로 받도록 수정.
    *   `ScheduleService.java`: `createCalendarEvent` 메소드에 파일 저장 및 일정 연결 로직 추가.
*   **'일정 관리' 페이지 구현**:
    *   **페이지 구조**: `manage.jsp` 및 `ScheduleController.java`에 `GET /schedules/manage` 엔드포인트 추가 (404 오류 해결).
    *   **데이터 표시**: 로그인한 사용자(임시 `1L`)가 생성한 일정 목록을 `manage.jsp` 테이블에 표시.
    *   **일정 삭제 기능**:
        *   `AttachmentLinkRepository.java`: `logicalDeleteByEntityTypeAndEntityId` 메소드 추가.
        *   `ScheduleAttendeeMapper.java/xml`: `deleteAttendeesByEventId` 메소드 추가.
        *   `ScheduleService.java`: `deleteCalendarEvent` 메소드 추가 (일정, 참석자, 파일 링크 논리적 삭제).
        *   `ScheduleController.java`: `POST /schedules/events/{eventId}/delete` 엔드포인트 추가.
        *   `manage.jsp`: 삭제 버튼 핸들러 (확인, API 호출, UI 업데이트).
    *   **일정 조회 (수정을 위한)**: `ScheduleService.java`에 `getEventById` 메소드 추가. `ScheduleController.java`에 `GET /schedules/events/{eventId}` 엔드포인트 추가.
*   **모달 UI 개선**:
    *   `view.jsp`: 일정 등록 모달의 'X' 버튼 제거, '취소' 버튼 `data-bs-dismiss="modal"`로 수정.
    *   `sidebar.jsp`: '일정 설정' 메뉴 제거 (스코프 변경).

#### **주요 트러블슈팅 및 리팩토링**

*   **JSP EL 파싱 오류 해결**: `view.jsp` 내 인라인 JavaScript에서 발생하는 `jakarta.el.ELException` 오류 해결을 위해 `schedules.js`로 JavaScript 코드를 분리하고, `view.jsp`가 이를 참조하도록 리팩토링.
*   **jQuery `$ is not defined` 오류 해결**: `admin_footer.jsp`에 jQuery CDN 추가.
*   **`Column 'is_all_day' cannot be null` 오류 해결**: `ScheduleService.java`에서 `allDay`, `repeating` 필드의 `null` 값에 대한 기본값 설정.
*   **`Cannot convert LocalDateTime to java.util.Date` 오류 해결**: `CalendarEventMapper.xml`의 `resultMap`에서 `LocalDateTime` 필드들에 `javaType="java.time.LocalDateTime" jdbcType="TIMESTAMP"`를 명시하여 매핑 오류 해결. `manage.jsp`에서 `fn:replace`를 사용하여 `LocalDateTime` 문자열을 원하는 형식으로 출력.

---

### 2025-12-30: 일정 관리 (SC) 기능 구현 및 리팩토링 진행 상황

#### **주요 구현 내용**

*   **기본 일정 등록 기능 구현**:
    *   `ScheduleService.java`: `createCalendarEvent` 메소드 추가 (기본 필드, `allDay`/`repeating` 기본값 설정).
    *   `ScheduleController.java`: `POST /schedules/events` 엔드포인트 추가.
    *   `view.jsp`: 일정 등록 모달 UI, `FormData`를 통한 데이터/파일 전송 로직 구현.
*   **사이드바 메뉴 및 캘린더 필터링**:
    *   `sidebar.jsp`: 일정 관련 메뉴 (`전체 일정`, `내 일정`, `부서 일정`, `전사 일정`, `일정 등록`, `일정 관리`) 구조 개편.
    *   `schedules.js`: `currentScope` 변수를 이용한 필터링 로직 구현, `scope` 파라미터로 이벤트 조회.
    *   `ScheduleController.java`: `getEvents` 메소드에 `scope` 파라미터 처리 로직 추가.
*   **캘린더 하단 일정 리스트**:
    *   `view.jsp`: 캘린더 하단에 일정 목록을 표시하는 `div` 영역 추가.
    *   `schedules.js`: `updateEventList` 함수를 통해 선택된 날짜의 이벤트를 목록으로 표시. (다중일정 포함, 시간/종일 표시)
*   **참석자 이름 검색 기능 구현**:
    *   **리팩토링**: `users` 패키지와의 분리를 위해 `UserSearchDto`, `UserMapper.java`, `UserMapper.xml`을 `com.health.app.schedules.search` 패키지로 이동 및 `AttendeeSearchDto`, `AttendeeSearchMapper.java`, `AttendeeSearchMapper.xml`로 이름 변경. `UserController.java` 원복.
    *   **백엔드**: `ScheduleController.java`에 `AttendeeSearchMapper` 주입 및 `GET /schedules/users/search` 엔드포인트 추가. `ScheduleService.java`에 `getUsersByIds` 메소드 추가.
    *   **프론트엔드**: `schedules.js`에 이름 검색, 결과 표시, 참석자 선택/제거 로직 구현 및 백엔드 API 연동.
*   **파일 첨부 기능 연동**:
    *   `view.jsp`: `FormData`를 통한 파일 첨부 UI 연동.
    *   `ScheduleController.java`: `POST /schedules/events` 메소드에서 `List<MultipartFile>`을 `@RequestPart`로 받도록 수정.
    *   `ScheduleService.java`: `createCalendarEvent` 메소드에 파일 저장 및 일정 연결 로직 추가.
*   **'일정 관리' 페이지 구현**:
    *   **페이지 구조**: `manage.jsp` 및 `ScheduleController.java`에 `GET /schedules/manage` 엔드포인트 추가 (404 오류 해결).
    *   **데이터 표시**: 로그인한 사용자(임시 `1L`)가 생성한 일정 목록을 `manage.jsp` 테이블에 표시.
    *   **일정 삭제 기능**:
        *   `AttachmentLinkRepository.java`: `logicalDeleteByEntityTypeAndEntityId` 메소드 추가.
        *   `ScheduleAttendeeMapper.java/xml`: `deleteAttendeesByEventId` 메소드 추가.
        *   `ScheduleService.java`: `deleteCalendarEvent` 메소드 추가 (일정, 참석자, 파일 링크 논리적 삭제).
        *   `ScheduleController.java`: `POST /schedules/events/{eventId}/delete` 엔드포인트 추가.
        *   `manage.jsp`: 삭제 버튼 핸들러 (확인, API 호출, UI 업데이트).
    *   **일정 조회 (수정을 위한)**: `ScheduleService.java`에 `getEventById` 메소드 추가. `ScheduleController.java`에 `GET /schedules/events/{eventId}` 엔드포인트 추가.
*   **모달 UI 개선**:
    *   `view.jsp`: 일정 등록 모달의 'X' 버튼 제거, '취소' 버튼 `data-bs-dismiss="modal"`로 수정.
    *   `sidebar.jsp`: '일정 설정' 메뉴 제거 (스코프 변경).

#### **주요 트러블슈팅 및 리팩토링**

*   **JSP EL 파싱 오류 해결**: `view.jsp` 내 인라인 JavaScript에서 발생하는 `jakarta.el.ELException` 오류 해결을 위해 `schedules.js`로 JavaScript 코드를 분리하고, `view.jsp`가 이를 참조하도록 리팩토링.
*   **jQuery `$ is not defined` 오류 해결**: `admin_footer.jsp`에 jQuery CDN 추가.
*   **`Column 'is_all_day' cannot be null` 오류 해결**: `ScheduleService.java`에서 `allDay`, `repeating` 필드의 `null` 값에 대한 기본값 설정.
*   **`Cannot convert LocalDateTime to java.util.Date` 오류 해결**: `CalendarEventMapper.xml`의 `resultMap`에서 `LocalDateTime` 필드들에 `javaType="java.time.LocalDateTime" jdbcType="TIMESTAMP"`를 명시하여 매핑 오류 해결. `manage.jsp`에서 `fn:replace`를 사용하여 `LocalDateTime` 문자열을 원하는 형식으로 출력.

### 2025-12-31: 일정 관리 (SC) 기능 추가 구현 및 주요 트러블슈팅

`CODING_PLAN.md` 및 `PROGRESS.md`의 "일정 관리" 요구사항을 기반으로 다음과 같은 기능 구현 및 문제 해결을 진행했습니다.

#### **주요 구현 내용**

*   **일정 수정 기능 추가**:
    *   `ScheduleService.java`에 `updateCalendarEvent` 메서드를 구현하고, `ScheduleController.java`에 `PUT /schedules/events` 엔드포인트를 추가하여 일정 수정 기능을 완성했습니다.
    *   `CalendarEventDto`에 참석자 상세 정보(`List<AttendeeSearchDto> attendees`) 필드를 추가하고, `ScheduleAttendeeMapper.java` 및 `ScheduleAttendeeMapper.xml`에 참석자 상세 정보를 조회하는 `selectAttendeesByEventId` 쿼리를 구현했습니다. 이를 통해 `ScheduleService.getEventById`에서 이벤트와 함께 참석자 정보를 로드할 수 있도록 했습니다.
    *   `manage.jsp`에 "수정" 버튼 클릭 시 이벤트 정보를 불러와 모달을 채우고 수정할 수 있는 프론트엔드 로직을 구현했습니다.
*   **고급 회의 생성 기능 (시간 충돌 확인 및 추천) 구현**:
    *   `ScheduleService.java`에 `checkTimeConflicts` 메서드를 구현하고, `TimeConflictException` 사용자 정의 예외를 정의하여 참석자들의 일정 중 충돌이 발생하는지 확인하는 백엔드 로직을 추가했습니다.
    *   `CalendarEventMapper.xml`에 `selectConflictingEventsForAttendee` 쿼리를 추가하여 특정 참석자의 충돌 일정을 효율적으로 조회할 수 있도록 했습니다.
    *   `ScheduleController.java`의 `createEvent` 및 `updateEvent` 메서드에 `TimeConflictException`을 처리하는 로직을 추가하여 충돌 발생 시 `HttpStatus.CONFLICT (409)` 상태 코드와 함께 충돌 상세 정보를 반환하도록 했습니다.
    *   `schedules.js`에 백엔드에서 반환하는 충돌 정보를 파싱하고 사용자에게 상세한 알림 메시지로 표시하는 프론트엔드 로직을 구현했습니다.
*   **JavaScript 모듈화 및 견고성 향상 (리팩토링)**:
    *   `schedules.js` 코드를 가독성과 유지보수성을 높이기 위해 `initAttendeeSearch()`, `initFullCalendar()`, `initEventModalLogic()`, `initManagePageLogic()` 등의 페이지별 초기화 함수로 분리했습니다.
    *   `DOMContentLoaded` 이벤트 리스너 내에서 각 페이지의 DOM 요소 존재 여부에 따라 해당 초기화 함수를 조건부로 호출하도록 변경하여 스크립트의 견고성을 높였습니다.

#### **주요 트러블슈팅 및 해결 과정**

1.  **일정 삭제/수정 요청 404 오류 (`No static resource ...wrwnwtat`)**:
    *   **문제**: `manage.jsp`에서 일정 삭제/수정 요청 시 브라우저 개발자 도구의 Request URL에 `//delete` 또는 `//1`과 같이 `eventId`가 누락되거나, `wrwnwtat`와 같은 알 수 없는 문자열이 붙어 404 `No static resource` 오류가 발생했습니다. `console.log` 상으로는 `eventId`가 올바르게 전달되는 것으로 보였으나, 실제 네트워크 요청 URL은 달랐습니다.
    *   **진단**: 초기에는 `contextPath` 변수 처리 문제로 의심했으나, `console.log` 확인 결과 `eventId` 자체는 올바르게 인식되고 있었고, `contextPath` 사용 여부와 상관없이 URL이 잘못 구성되는 현상이 발생했습니다. 이는 JavaScript가 URL을 구성한 후 HTTP 요청이 보내지기 전, 혹은 서버의 어떤 레이어에서 URL이 변조되거나 잘못 해석되는 것으로 판단되었습니다.
    *   **해결**: `manage.jsp`에서 삭제 및 수정 URL을 `contextPath` 없이 절대 경로(`deleteUrl = `/schedules/events/${eventId}/delete`;`와 같이)로 명시적으로 구성하도록 수정했습니다. 이 조치 이후 삭제 기능이 정상 작동하기 시작했습니다. (URL 문제에 대한 최종 원인 분석은 추가 네트워크 분석이 필요할 수 있습니다.)
2.  **`AttachmentLinkRepository cannot be resolved to a type` 컴파일 오류**:
    *   **문제**: `ScheduleService.java`에서 `AttachmentLinkRepository` 클래스를 찾을 수 없다는 컴파일 오류가 발생했습니다.
    *   **원인**: `ScheduleService.java`에서 `AttachmentLinkRepository`에 대한 import 문이 누락되었습니다.
    *   **해결**: `ScheduleService.java`에 `import com.health.app.attachments.AttachmentLinkRepository;` import 문을 추가하여 해결했습니다.
3.  **`schedules.js` JavaScript 런타임 오류 (`TypeError: Cannot read properties of null`)**:
    *   **문제**: `schedules.js`가 로드되는 페이지(`manage.jsp`)에 해당 DOM 요소(`attendeeSearch`, `calendar` 등)가 존재하지 않아 `document.getElementById`가 `null`을 반환하고, 이어서 `addEventListener`나 FullCalendar 초기화 시 `TypeError`가 발생했습니다. 이로 인해 스크립트 실행이 중단되어 버튼이 클릭되지 않는 문제가 발생했습니다.
    *   **원인**: `schedules.js`가 여러 JSP 페이지에서 공용으로 사용되면서, 페이지별로 존재 여부가 다른 DOM 요소에 대한 접근 시 예외 처리가 미흡했습니다. 특히 `manage.jsp`에는 `eventModal`과 캘린더 관련 요소가 없었습니다.
    *   **해결**:
        *   `manage.jsp`에 `view.jsp`에 있던 `eventModal` HTML 구조를 복사하여 추가했습니다.
        *   `schedules.js`를 모듈화하여 `initAttendeeSearch()`, `initFullCalendar()`, `initEventModalLogic()`, `initManagePageLogic()`과 같은 함수로 분리했습니다. 각 초기화 함수는 해당 DOM 요소가 페이지에 실제로 존재하는 경우에만 실행되도록 조건부 로직을 추가했습니다. 이는 스크립트의 견고성과 재사용성을 크게 향상시켰습니다.
4.  **일정 수정 시 `SQLSyntaxErrorException: Table 'user03.departments' doesn't exist`**:
    *   **문제**: 일정 수정 시 참석자 상세 정보를 가져오는 쿼리(`ScheduleAttendeeMapper.xml`의 `selectAttendeesByEventId`)가 `departments` 테이블을 참조했으나, 해당 테이블이 데이터베이스에 존재하지 않아 SQL 오류가 발생했습니다.
    *   **원인**: 데이터베이스 스키마에 `departments` 테이블이 누락되었거나, 참석자 상세 정보에 부서 정보가 필수적이지 않았습니다.
    *   **해결**: `ScheduleAttendeeMapper.xml`의 `selectAttendeesByEventId` 쿼리에서 `LEFT JOIN departments d` 및 `d.name as department_name` 부분을 제거하고, `attendeeSearchResultMap`에서도 `departmentName` 매핑을 제거했습니다. 이는 부서 이름 없이 참석자 정보만 조회하도록 하여 즉각적인 SQL 오류를 해결했습니다. (향후 부서 정보가 필요하면 `departments` 테이블 생성 및 재연결 필요)
5.  **이미지 리소스 404 오류**:
    *   **문제**: `user1-128x128.jpg`, `AdminLTELogo.png` 등 이미지 파일 로드 시 404 오류가 발생했습니다.
    *   **원인**: 해당 이미지 파일들이 `src/main/resources/static` 경로에 존재하지 않았습니다.
    *   **해결**: 이미지 파일들을 `src/main/resources/static` 또는 그 하위 디렉토리에 배치하고, `admin_header.jsp` 등에서 올바른 경로로 참조하도록 해야 합니다. (현재 코드 수정으로 직접 해결되지는 않았으며, 사용자에게 가이드 제공 예정)

#### **남아있는 작업 / 다음 단계 (TODO List)**

1.  **일정 수정 기능 최종 확인**: 현재 `manage.jsp`에 모달 HTML이 추가되고 SQL 오류가 해결되었으므로, "수정" 버튼 클릭 시 모달이 올바르게 열리고 데이터가 채워지는지 확인해야 합니다. 저장 기능까지 테스트하여 최종적으로 작동하는지 확인합니다.
2.  **`wrwnwtat` 오류 최종 확인**: 삭제/수정 URL 문제 (`//delete` 및 `wrwnwtat` 접미사)가 완전히 해결되었는지 네트워크 탭을 통해 최종 확인이 필요합니다. (현재까지의 수정으로 해결되었을 것으로 예상되나, 재확인 필요)
3.  **이미지 리소스 404 오류 해결**: 이미지 파일들을 프로젝트의 정적 리소스 경로에 배치하고, HTML에서 올바르게 참조하도록 수정해야 합니다.
4.  **TODO List (기존):**
    *   권한 제어 기능 구현 (로그인 기능 구현 후 진행 예정)
    *   캘린더 하단 리스트 고급 필터링
    *   반복 일정 기능 구현
    *   알림 설정 기능 구현

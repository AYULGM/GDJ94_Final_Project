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

---

### 2026-01-02: 일정 수정 기능 안정화 및 상세보기 모달 구현

일정 수정 기능의 다양한 NULL 필드 오류를 해결하고, 사용자 경험 개선을 위한 상세보기 모달을 구현했습니다.

#### **주요 구현 내용**

*   **일정 상세보기 모달 구현**:
    *   `view.jsp`에 새로운 읽기 전용 상세보기 모달(`eventDetailModal`)을 추가했습니다.
    *   깔끔한 Bootstrap 그리드 레이아웃으로 모든 일정 정보를 표시하도록 구현했습니다.
    *   일정 유형과 상태를 색상 배지(badge)로 시각화했습니다.
    *   **첨부파일 다운로드 기능**: "참고 파일" 섹션에 첨부파일 목록을 표시하고, 각 파일에 다운로드 아이콘과 링크를 제공했습니다.
    *   파일 크기를 자동으로 포맷(B, KB, MB, GB)하는 `formatFileSize()` 유틸리티 함수를 구현했습니다.
    *   하단에 "수정" 및 "삭제" 버튼을 추가하여 상세보기에서 바로 편집/삭제할 수 있도록 했습니다.

*   **FullCalendar 이벤트 클릭 핸들러 추가**:
    *   `schedules.js`의 `initFullCalendar()` 함수에 `eventClick` 콜백을 추가하여 캘린더에서 일정 클릭 시 상세보기 모달이 자동으로 표시되도록 구현했습니다.
    *   `showEventDetail(eventId)` 함수를 생성하여 서버에서 일정 상세 정보를 가져와 모달에 표시하는 로직을 구현했습니다.

*   **UI 개선**:
    *   **사이드바 캘린더 메뉴 기본 닫힘 설정**: `sidebar.jsp`의 캘린더 메뉴 항목에서 `menu-open` 클래스를 제거하여 페이지 로드 시 메뉴가 기본적으로 닫혀있도록 변경했습니다.
    *   **일정 관리 페이지 등록 버튼 추가**: `manage.jsp`의 카드 헤더에 "일정 등록" 버튼을 추가하여 일정 관리 페이지에서도 새 일정을 등록할 수 있도록 개선했습니다.

#### **주요 트러블슈팅 및 해결 과정**

1.  **`Column 'status_code' cannot be null` SQL 무결성 제약 조건 위반**:
    *   **문제**: 일정 수정 시 `status_code` 컬럼이 NULL이어서 데이터베이스 무결성 제약 조건 오류가 발생했습니다.
    *   **원인**: 일정 수정 모달에 상태 코드를 선택하는 필드가 없었고, JavaScript에서도 `statusCode` 값을 전송하지 않았습니다.
    *   **해결**:
        *   `manage.jsp`와 `view.jsp`의 모달 폼에 상태 선택 드롭다운(`eventStatus`)을 추가했습니다. (옵션: SCHEDULED, COMPLETED, CANCELLED)
        *   `schedules.js`의 `eventData` 객체에 `statusCode: document.getElementById('eventStatus').value` 필드를 추가했습니다.
        *   새 일정 등록 시 기본값을 `SCHEDULED`로 설정하고, 수정 시에는 기존 값을 로드하도록 구현했습니다.

2.  **`Column 'is_all_day' cannot be null` SQL 무결성 제약 조건 위반**:
    *   **문제**: 일정 수정 시 `is_all_day` 컬럼이 NULL이어서 오류가 발생했습니다.
    *   **원인**: 일정 모달에 종일 여부를 선택하는 체크박스가 없었고, JavaScript에서도 `allDay` 값을 전송하지 않았습니다.
    *   **해결**:
        *   `manage.jsp`와 `view.jsp`의 모달 폼에 종일 체크박스(`eventAllDay`)를 추가했습니다.
        *   `schedules.js`의 `eventData` 객체에 `allDay: document.getElementById('eventAllDay').checked` 필드를 추가했습니다.
        *   새 일정 등록 시 기본값을 `false`로 설정하고, 수정 시에는 기존 값을 로드하도록 구현했습니다.

3.  **`Column 'use_yn' cannot be null` SQL 무결성 제약 조건 위반**:
    *   **문제**: 일정 수정 시 `use_yn` 컬럼이 NULL이어서 오류가 발생했습니다.
    *   **원인**: `use_yn`은 삭제 여부를 나타내는 플래그로, 사용자 입력 필드가 아니라 서버에서 관리해야 하는 값이지만 JavaScript에서 전송되지 않았습니다.
    *   **해결**: `schedules.js`의 `eventData` 객체에 `useYn: true`를 추가하여 항상 활성 상태로 전송하도록 했습니다.

4.  **`Column 'create_user'/'update_user' cannot be null` (CalendarEvent 관련)**:
    *   **문제**: 일정 등록/수정 시 `createUser` 또는 `updateUser` 필드가 NULL이어서 오류가 발생했습니다.
    *   **원인**: 사용자 인증 기능이 구현되지 않아 현재 로그인한 사용자 ID를 가져올 수 없었고, JavaScript에서도 해당 값을 전송하지 않았습니다.
    *   **해결**: 임시로 하드코딩된 사용자 ID(`1`)를 사용하도록 `schedules.js`를 수정했습니다.
        *   신규 등록 시: `createUser: 1`
        *   수정 시: `updateUser: 1`
        *   향후 로그인 기능 구현 시 세션에서 실제 사용자 ID를 가져오도록 수정 필요합니다.

5.  **`not-null property references a null or transient value: com.health.app.attachments.AttachmentLink.createUser`**:
    *   **문제**: 일정 수정 시 파일을 첨부할 때 `AttachmentLink` 엔티티의 `createUser` 필드가 NULL이어서 Hibernate 오류가 발생했습니다.
    *   **원인**: `ScheduleService.java`의 `updateCalendarEvent` 메서드에서 첨부파일 링크를 생성할 때 `calendarEvent.getCreateUser()`를 사용했는데, 수정 모드에서는 `createUser`가 `null`이었습니다.
    *   **해결**: `ScheduleService.java`의 198번 라인을 수정하여 일정 수정 시 첨부파일 링크를 생성할 때 `calendarEvent.getUpdateUser()`를 사용하도록 변경했습니다.
        ```java
        // 변경 전
        fileService.linkFileToEntity(fileId, "CALENDAR_EVENT", calendarEvent.getEventId(), "reference", calendarEvent.getCreateUser());

        // 변경 후
        fileService.linkFileToEntity(fileId, "CALENDAR_EVENT", calendarEvent.getEventId(), "reference", calendarEvent.getUpdateUser());
        ```

#### **생성 및 수정된 주요 파일**

*   **View**: `src/main/webapp/WEB-INF/views/schedules/view.jsp` (상세보기 모달 추가)
*   **View**: `src/main/webapp/WEB-INF/views/schedules/manage.jsp` (상태/종일 필드 추가, 일정 등록 버튼 추가)
*   **View**: `src/main/webapp/WEB-INF/views/includes/sidebar.jsp` (캘린더 메뉴 기본 닫힘 설정)
*   **JavaScript**: `src/main/resources/static/js/schedules.js` (필수 필드 추가, 상세보기 로직, eventClick 핸들러)
*   **Service**: `src/main/java/com/health/app/schedules/ScheduleService.java` (첨부파일 링크 생성 시 updateUser 사용)

#### **다음 작업 계획 (상세 TODO List)**

##### 🔴 **높은 우선순위 (핵심 기능)**

1.  **일정 첨부파일 조회 API 구현** ⭐ 최우선!
    *   **현재 상태**: 상세보기 모달에서 첨부파일 목록이 표시되지 않음 (`event.attachments`가 항상 비어있음)
    *   **필요 작업**:
        *   `ScheduleService.getEventById()` 메서드에서 첨부파일 목록 조회 로직 추가
        *   `AttachmentLinkRepository`를 사용하여 `CALENDAR_EVENT` 타입의 첨부파일 조회
        *   `CalendarEventDto`의 `attachments` 필드에 첨부파일 정보 매핑
    *   **관련 파일**: `ScheduleService.java`, `CalendarEventDto.java`, `AttachmentLinkRepository.java`

2.  **로그인/인증 기능 구현**
    *   **현재 상태**: 모든 사용자 ID가 하드코딩된 `1L` 사용 중
    *   **필요 작업**:
        *   Spring Security 설정 활성화 및 구성
        *   로그인 페이지 및 세션 관리
        *   `createUser`, `updateUser`, `ownerUserId` 등을 실제 로그인 사용자 ID로 설정
    *   **영향 범위**: 전체 애플리케이션 (공지사항, 전자결재 등 모든 모듈)

3.  **부서 정보 연동**
    *   **현재 상태**: `departments` 테이블이 없어서 부서 일정 생성 및 참석자 부서명 표시 불가
    *   **필요 작업**:
        *   `departments` 테이블 생성 (DDL)
        *   `users` 테이블과 부서 연결 (FK 추가)
        *   `AttendeeSearchMapper.xml`에 부서 정보 조인 쿼리 재추가
    *   **영향 범위**: 부서 일정, 참석자 정보 표시

##### 🟡 **중간 우선순위 (사용자 경험 개선)**

4.  **첨부파일 관리 기능 개선**
    *   **현재 상태**: 파일 추가만 가능, 삭제/수정 불가
    *   **필요 작업**:
        *   일정 수정 모달에 기존 첨부파일 목록 표시
        *   각 파일별 삭제 버튼 추가
        *   `ScheduleService.updateCalendarEvent()`에서 파일 삭제 처리 로직 추가
    *   **UX 개선**: 사용자가 첨부파일을 더 쉽게 관리할 수 있음

5.  **캘린더 하단 리스트 고급 필터링**
    *   **현재 상태**: 날짜별 일정만 표시
    *   **필요 작업**:
        *   오늘/이번 주/이번 달 탭 또는 버튼 추가
        *   일정 유형별(개인/부서/전사) 필터 드롭다운 추가
        *   `schedules.js`에 필터링 로직 구현
    *   **UX 개선**: 사용자가 원하는 일정을 빠르게 찾을 수 있음

6.  **일정 상태 관리 개선**
    *   **필요 작업**:
        *   자동 상태 변경: 지난 일정을 자동으로 `COMPLETED`로 변경 (스케줄러 또는 조회 시)
        *   일정 관리 페이지에서 상태별 필터링 기능 추가
        *   상태 변경 이력 관리 (선택 사항)

##### 🟢 **낮은 우선순위 (부가 기능)**

7.  **반복 일정 기능**
    *   **필요 작업**:
        *   매주/매월 반복 패턴 설정 UI 추가
        *   `repeat_info` 컬럼에 반복 규칙 JSON 저장
        *   반복 일정 생성 로직 구현
        *   반복 일정 수정 시 전체/개별 선택 옵션
    *   **기술 고려**: iCal RRULE 표준 활용 검토

8.  **알림 설정 기능**
    *   **필요 작업**:
        *   일정 시작 N분 전 알림 설정 UI
        *   `NotificationService` 연동
        *   이메일/푸시 알림 발송 (스케줄러 사용)
    *   **의존성**: 알림 서비스 구현 필요

9.  **일정 가져오기/내보내기**
    *   **필요 작업**:
        *   iCal (.ics) 형식 지원
        *   다른 캘린더 서비스 연동 (Google Calendar API 등)
    *   **비즈니스 가치**: 기존 일정 데이터 마이그레이션

10. **참석자 응답 기능**
    *   **필요 작업**:
        *   참석자가 일정 초대에 수락/거절/보류 선택
        *   `schedule_attendees.acceptance_status` 업데이트 API
        *   일정 상세보기에서 참석 현황 표시
    *   **UX 개선**: 회의 참석 여부 확인 가능

##### 🔧 **기술 부채 & 리팩토링**

11. **이미지 리소스 404 오류 해결**
    *   **문제**: AdminLTE 템플릿 이미지 파일 누락
    *   **해결**: `src/main/resources/static` 경로에 이미지 파일 추가 및 경로 확인

12. **서버 측 권한 체크 로직 구현**
    *   **현재 상태**: `// TODO: 권한 확인 로직 추가 필요` 주석만 존재
    *   **필요 작업**:
        *   일정 삭제/수정 시 소유자 확인
        *   부서 일정 생성 권한 체크 (`ADMIN` 권한)
        *   전사 일정 생성 권한 체크 (`MASTER` 권한)
    *   **보안**: 무단 수정/삭제 방지

13. **에러 처리 개선**
    *   **필요 작업**:
        *   사용자 친화적인 에러 메시지 (현재는 기술적 오류 메시지 그대로 노출)
        *   프론트엔드 validation 강화 (날짜 형식, 필수 필드 등)
        *   백엔드 로깅 개선 (에러 추적 용이)

---

##### 🎯 **추천 작업 순서**

**1단계** (이번 주 우선 작업):
1.  첨부파일 조회 API 구현 ← **가장 먼저!**
2.  첨부파일 삭제 기능 추가
3.  이미지 리소스 404 해결

**2단계** (다음 주):
4.  로그인/인증 기능 구현
5.  부서 정보 연동
6.  권한 체크 로직 구현

**3단계** (이후 단계적 개선):
7.  캘린더 필터링 고급 기능
8.  반복 일정 기능
9.  알림 기능

---

### 2026-01-03: 일정 첨부파일 조회/삭제 및 상태 관리 개선

1단계 우선 작업들을 완료하고, 사용자 경험을 크게 개선했습니다.

#### **주요 구현 내용**

##### **1. 일정 첨부파일 조회 API 구현** ⭐ 최우선 작업 완료

*   **AttachmentLinkRepository 개선**:
    *   `findAttachmentsByEntityTypeAndEntityId()` 메서드 추가
    *   JOIN 쿼리를 사용하여 AttachmentLink와 Attachment를 한 번에 효율적으로 조회
    *   `useYn = true`인 활성 첨부파일만 조회하며, `sortOrder`로 정렬
    *   파일: `AttachmentLinkRepository.java:29-30`

*   **CalendarEventDto 확장**:
    *   `List<Attachment> attachments` 필드 추가
    *   일정 조회 시 첨부파일 정보를 함께 전달
    *   파일: `CalendarEventDto.java:40`

*   **ScheduleService 자동 로딩**:
    *   `getEventById()` 메서드 수정
    *   일정 조회 시 참석자 정보와 함께 첨부파일 목록을 자동으로 로드
    *   파일: `ScheduleService.java:150-153`

*   **프론트엔드 버그 수정**:
    *   `schedules.js`에서 잘못된 필드명(`file.fileName`)과 URL 경로 수정
    *   `file.originalName` 사용 및 올바른 다운로드 경로(`/files/download/${file.fileId}`) 적용
    *   파일: `schedules.js:523-524`

##### **2. 첨부파일 삭제 기능 구현**

*   **UI 개선**:
    *   `view.jsp`와 `manage.jsp`의 일정 수정 모달에 "기존 첨부파일" 섹션 추가
    *   각 파일마다 삭제 버튼 표시 (파일명, 크기, 삭제 버튼이 깔끔하게 정렬)
    *   파일: `view.jsp:95-99`, `manage.jsp:130-134`

*   **프론트엔드 로직**:
    *   전역 변수 `filesToDelete` 배열 추가로 삭제할 파일 ID 추적
    *   `renderExistingAttachments()` 함수 구현:
        *   기존 첨부파일 목록 표시
        *   삭제 버튼 클릭 시 UI에서 즉시 제거 및 삭제 목록에 추가
    *   모달 열기 시 자동으로 기존 첨부파일 로드
    *   저장 버튼 클릭 시 `filesToDelete` 배열을 FormData에 추가하여 서버로 전송
    *   파일: `schedules.js:5`, `schedules.js:566-610`, `schedules.js:323-328`

*   **백엔드 처리**:
    *   `ScheduleController.updateEvent()`: `filesToDelete` 파라미터 추가
    *   `ScheduleService.updateCalendarEvent()`: 삭제할 파일 목록 순회하며 `FileService.deleteAttachment()` 호출
    *   논리적 삭제 처리 (`use_yn = false`)
    *   파일: `ScheduleController.java:97`, `ScheduleService.java:198-203`

##### **3. 일정 상태 관리 개선**

*   **자동 상태 업데이트 (백엔드)**:
    *   `CalendarEventMapper`에 `updatePastEventsToCompleted()` 메서드 추가
    *   SQL 쿼리: 종료 시간이 지난 `SCHEDULED` 일정을 자동으로 `COMPLETED`로 변경
    *   `ScheduleService.getCalendarEvents()` 및 `getEventsByOwner()`에서 조회 전 자동 실행
    *   동작 방식: 사용자가 캘린더나 일정 관리 페이지에 접속할 때마다 자동으로 지난 일정 상태 업데이트
    *   파일: `CalendarEventMapper.java:24`, `CalendarEventMapper.xml:140-148`, `ScheduleService.java:54`, `ScheduleService.java:122`

*   **상태별 필터링 (프론트엔드)**:
    *   `manage.jsp`에 필터 버튼 그룹 추가: 전체 / 예정 / 완료 / 취소
    *   각 테이블 행에 `data-status` 속성 추가
    *   `schedules.js`에 필터링 로직 구현: 버튼 클릭 시 선택된 상태만 표시, 나머지 숨김
    *   파일: `manage.jsp:23-38`, `manage.jsp:55`, `schedules.js:474-496`

#### **생성 및 수정된 주요 파일**

**백엔드**:
*   `AttachmentLinkRepository.java` (첨부파일 조회 메서드 추가)
*   `CalendarEventDto.java` (attachments 필드 추가)
*   `ScheduleService.java` (첨부파일 로딩, 삭제 처리, 자동 상태 업데이트)
*   `ScheduleController.java` (filesToDelete 파라미터 추가)
*   `CalendarEventMapper.java` (자동 상태 업데이트 메서드)
*   `CalendarEventMapper.xml` (상태 업데이트 SQL 쿼리)

**프론트엔드**:
*   `view.jsp` (기존 첨부파일 섹션, 상태 필드)
*   `manage.jsp` (기존 첨부파일 섹션, 상태 필터 버튼)
*   `schedules.js` (첨부파일 표시/삭제 로직, 상태 필터링 로직)

#### **다음 작업 계획 (업데이트된 TODO List)**

##### 🟢 **간단한 작업** (빠르게 완료 가능)

1.  **이미지 리소스 404 오류 해결**
    *   AdminLTE 템플릿 이미지 파일 추가
    *   콘솔 에러 정리

2.  **캘린더 하단 리스트 고급 필터링**
    *   오늘/이번 주/이번 달 탭 추가
    *   일정 유형별 드롭다운 필터

##### 🟡 **중간 우선순위**

3.  **반복 일정 기능**
    *   매주/매월 반복 패턴 설정 UI 추가
    *   `repeat_info` 컬럼에 반복 규칙 JSON 저장
    *   반복 일정 생성 로직 구현

4.  **알림 설정 기능**
    *   일정 시작 N분 전 알림 설정 UI
    *   `NotificationService` 연동
    *   이메일/푸시 알림 발송

##### 🔴 **높은 우선순위** (대규모 작업)

5.  **로그인/인증 기능 구현**
    *   모든 사용자 ID가 하드코딩된 `1L` 사용 중
    *   Spring Security 설정 활성화 및 구성
    *   로그인 페이지 및 세션 관리
    *   영향 범위: 전체 애플리케이션

6.  **부서 정보 연동**
    *   `departments` 테이블이 없어서 부서 일정 생성 및 참석자 부서명 표시 불가
    *   `departments` 테이블 생성 (DDL)
    *   `users` 테이블과 부서 연결 (FK 추가)

7.  **서버 측 권한 체크 로직 구현**
    *   일정 삭제/수정 시 소유자 확인
    *   부서 일정 생성 권한 체크 (`ADMIN` 권한)
    *   전사 일정 생성 권한 체크 (`MASTER` 권한)

---

### 2026-01-03: 알림(Notification) 시스템 구현 완료 및 일정 파트 연동

`CODING_PLAN.md`의 알림 요구사항에 따라 실시간 알림 시스템을 완전히 구현하고, 일정 파트와의 연동을 완료했습니다.

#### **주요 구현 내용**

##### **1. 알림 백엔드 핵심 구조 구현 (100% 완료)**

*   **엔티티 설계**:
    *   `Notification.java` - 알림 본문 정보 저장 (`notifications` 테이블 매핑)
    *   `NotificationRecipient.java` - 수신자 및 읽음 상태 관리 (`notification_recipients` 테이블 매핑)
    *   `NotificationType.java` - 알림 타입 Enum (일정, 공지, 정산, 파일, 시스템 알림)
    *   파일: `src/main/java/com/health/app/notifications/`

*   **데이터 접근 계층**:
    *   `NotificationRepository.java` - 알림 조회, 읽지 않은 알림 개수 쿼리
    *   `NotificationRecipientRepository.java` - 수신자 관리, 읽음 처리 쿼리
    *   JPQL을 사용한 효율적인 조인 쿼리 구현

*   **비즈니스 로직 (`NotificationService.java`)**:
    *   `send()` 메서드 - 알림 생성 + 수신자 추가 + 저장 + WebSocket 실시간 푸시까지 원스톱 처리
    *   `getNotificationsByUserId()` - 특정 사용자의 알림 목록 조회 (최신순)
    *   `getUnreadCount()` - 읽지 않은 알림 개수 조회
    *   `markAsRead()` - 특정 알림 읽음 처리
    *   `markAllAsRead()` - 모든 알림 일괄 읽음 처리
    *   파일: `NotificationService.java:43-126`

##### **2. REST API 엔드포인트 구현 (`NotificationController.java`)**

*   `GET /api/notifications` - 알림 목록 조회
*   `GET /api/notifications/unread-count` - 읽지 않은 알림 개수 조회
*   `POST /api/notifications/{notifId}/read` - 특정 알림 읽음 처리
*   `POST /api/notifications/read-all` - 모든 알림 읽음 처리
*   현재 임시로 `currentUserId = 1L` 사용 (로그인 기능 구현 후 세션 연동 필요)

##### **3. WebSocket 실시간 알림 시스템**

*   **WebSocket 설정 (`WebSocketConfig.java`)**:
    *   WebSocket 엔드포인트 `/ws/notifications` 등록
    *   모든 출처 허용 (개발 단계, 프로덕션에서는 제한 필요)

*   **실시간 푸시 핸들러 (`NotificationWebSocketHandler.java`)**:
    *   사용자별 WebSocket 세션 관리 (`ConcurrentHashMap` 사용)
    *   한 사용자가 여러 탭/디바이스에서 동시 접속 지원 (`CopyOnWriteArrayList`)
    *   URL 쿼리 파라미터로 사용자 인증 (`?userId=1`)
    *   `pushNotification()` 메서드로 특정 사용자들에게 실시간 알림 전송
    *   파일: `NotificationWebSocketHandler.java:73-91`

*   **의존성 확인**:
    *   `pom.xml`에 `spring-boot-starter-websocket` 의존성 이미 추가됨 (pom.xml:80-84)

##### **4. 프론트엔드 알림 클라이언트 (`notifications.js`)**

*   **NotificationClient 클래스 구현**:
    *   WebSocket 연결 및 자동 재연결 로직 (최대 10회 시도, 5초 간격)
    *   실시간 알림 수신 및 핸들러
    *   브라우저 푸시 알림 표시 (권한 요청 기능 포함)
    *   읽지 않은 알림 배지 자동 업데이트
    *   HTTP API를 통한 알림 목록 조회/읽음 처리

*   **주요 메서드**:
    *   `init(userId, contextPath)` - 클라이언트 초기화 및 연결 시작
    *   `connect()` - WebSocket 연결 수립
    *   `handleNewNotification(notification)` - 새 알림 수신 처리
    *   `loadUnreadCount()` - 읽지 않은 알림 개수 로드 및 배지 업데이트
    *   `markAsRead(notifId)` - 특정 알림 읽음 처리
    *   `markAllAsRead()` - 모든 알림 읽음 처리
    *   파일: `notifications.js:1-214`

##### **5. UI 구현 (`admin_header.jsp`)**

*   **헤더 알림 드롭다운 추가**:
    *   종 아이콘 (`bi bi-bell-fill`) 및 읽지 않은 알림 개수 배지
    *   알림 목록 드롭다운 (최대 높이 400px, 스크롤 가능)
    *   "모두 읽음" 버튼 및 "모든 알림 보기" 링크
    *   알림 목록 표시 영역 (`#notification-list`)
    *   파일: `admin_header.jsp:120-137`

##### **6. 일정 파트와 알림 연동 완료**

*   **ScheduleService에 NotificationService 주입**:
    *   생성자 주입 방식으로 `NotificationService` 의존성 추가
    *   파일: `ScheduleService.java:37, 40, 46`

*   **일정 등록 시 알림 발송**:
    *   `createCalendarEvent()` 메서드에서 참석자들에게 `EVENT_CREATED` 알림 발송
    *   알림 제목: "새로운 일정: [일정 제목]"
    *   알림 메시지: 일정 시작/종료 시간 포함
    *   파일: `ScheduleService.java:115-133`

*   **일정 수정 시 알림 발송**:
    *   `updateCalendarEvent()` 메서드에서 참석자들에게 `EVENT_UPDATED` 알림 발송
    *   알림 제목: "일정 수정: [일정 제목]"
    *   알림 메시지: 수정된 일정 시작/종료 시간 포함
    *   파일: `ScheduleService.java:275-293`

*   **일정 취소 시 알림 발송**:
    *   `deleteCalendarEvent()` 메서드에서 삭제 전 이벤트 정보 및 참석자 조회
    *   참석자들에게 `EVENT_CANCELLED` 알림 발송
    *   알림 제목: "일정 취소: [일정 제목]"
    *   알림 메시지: 취소된 일정 시작 예정 시간 포함
    *   파일: `ScheduleService.java:159-194`

#### **생성된 주요 파일**

**백엔드**:
*   `src/main/java/com/health/app/notifications/Notification.java`
*   `src/main/java/com/health/app/notifications/NotificationRecipient.java`
*   `src/main/java/com/health/app/notifications/NotificationType.java`
*   `src/main/java/com/health/app/notifications/NotificationRepository.java`
*   `src/main/java/com/health/app/notifications/NotificationRecipientRepository.java`
*   `src/main/java/com/health/app/notifications/NotificationService.java`
*   `src/main/java/com/health/app/notifications/NotificationController.java`
*   `src/main/java/com/health/app/notifications/WebSocketConfig.java`
*   `src/main/java/com/health/app/notifications/NotificationWebSocketHandler.java`

**프론트엔드**:
*   `src/main/resources/static/js/notifications.js`

**수정된 파일**:
*   `src/main/webapp/WEB-INF/views/includes/admin_header.jsp` (알림 드롭다운 UI 추가)
*   `src/main/java/com/health/app/schedules/ScheduleService.java` (알림 연동)
*   `pom.xml` (WebSocket 의존성)

#### **다음 작업 계획 (업데이트된 TODO List)**

##### 🔴 **높은 우선순위** (알림 시스템 완성)

1.  **알림 클라이언트 초기화 스크립트 추가**
    *   `admin_footer.jsp`에 NotificationClient 초기화 코드 추가
    *   페이지 로드 시 자동으로 WebSocket 연결
    *   브라우저 알림 권한 요청

2.  **알림 목록 표시 로직 구현**
    *   알림 드롭다운에서 실제 알림 데이터 표시
    *   알림 클릭 시 읽음 처리 및 관련 페이지로 이동
    *   알림 타입별 아이콘 및 스타일 적용

3.  **로그인/인증 기능 구현**
    *   모든 사용자 ID가 하드코딩된 `1L` 사용 중
    *   Spring Security 설정 활성화 및 구성
    *   로그인 페이지 및 세션 관리
    *   NotificationController에서 실제 로그인 사용자 ID 사용
    *   영향 범위: 전체 애플리케이션

##### 🟢 **간단한 작업** (빠르게 완료 가능)

4.  **이미지 리소스 404 오류 해결**
    *   AdminLTE 템플릿 이미지 파일 추가
    *   콘솔 에러 정리

5.  **캘린더 하단 리스트 고급 필터링**
    *   오늘/이번 주/이번 달 탭 추가
    *   일정 유형별 드롭다운 필터

##### 🟡 **중간 우선순위**

6.  **반복 일정 기능**
    *   매주/매월 반복 패턴 설정 UI 추가
    *   `repeat_info` 컬럼에 반복 규칙 JSON 저장
    *   반복 일정 생성 로직 구현

7.  **일정 알림 고급 기능**
    *   일정 시작 N분 전 알림 설정 UI
    *   스케줄러를 사용한 예약 알림 발송
    *   이메일 알림 통합 (선택 사항)

8.  **부서 정보 연동**
    *   `departments` 테이블이 없어서 부서 일정 생성 및 참석자 부서명 표시 불가
    *   `departments` 테이블 생성 (DDL)
    *   `users` 테이블과 부서 연결 (FK 추가)

9.  **서버 측 권한 체크 로직 구현**
    *   일정 삭제/수정 시 소유자 확인
    *   부서 일정 생성 권한 체크 (`ADMIN` 권한)
    *   전사 일정 생성 권한 체크 (`MASTER` 권한)

---

### 2026-01-05: 알림 시스템 프론트엔드 완성 및 정산/통계 기능 계획 수립

알림 시스템의 백엔드(2026-01-03 완성)에 이어 프론트엔드 UI 연동을 완료하여 실시간 알림 시스템을 100% 완성했습니다.

#### **주요 구현 내용**

##### **1. 알림 클라이언트 초기화 스크립트 추가** ✅

*   **파일**: `admin_footer.jsp`
*   **구현 내용**:
    *   `notifications.js` 스크립트 로드
    *   페이지 로드 시(`DOMContentLoaded`) 자동으로 `notificationClient` 초기화
    *   WebSocket 연결 자동 수립 (`ws://localhost/ws/notifications?userId=1`)
    *   브라우저 알림 권한 자동 요청 (`Notification.requestPermission()`)
    *   새 알림 수신 시 콜백 함수 등록
    *   디버깅을 위한 상세 로그 추가

*   **코드 예시** (admin_footer.jsp:70-105):
    ```jsp
    <script src="/js/notifications.js"></script>
    <script>
      document.addEventListener('DOMContentLoaded', function() {
        const currentUserId = 1; // TODO: 로그인 기능 구현 후 변경
        const contextPath = '${pageContext.request.contextPath}';

        notificationClient.init(currentUserId, contextPath);
        notificationClient.requestNotificationPermission();
      });
    </script>
    ```

##### **2. 알림 목록 표시 로직 구현** ✅

*   **파일**: `notifications.js`
*   **구현 메서드**:

    *   `renderNotifications(notifications)` - 알림 목록 UI 렌더링
        *   알림 목록을 드롭다운에 동적 생성
        *   읽지 않은 알림은 밝은 배경 (`bg-light`) 및 "New" 배지 표시
        *   각 알림에 클릭 이벤트 핸들러 등록

    *   `getNotificationIcon(notifType)` - 알림 타입별 아이콘 반환
        *   `EVENT_CREATED`: 🟢 `bi bi-calendar-plus text-success` (초록색 캘린더)
        *   `EVENT_UPDATED`: 🔵 `bi bi-calendar-event text-primary` (파란색 캘린더)
        *   `EVENT_CANCELLED`: 🔴 `bi bi-calendar-x text-danger` (빨간색 캘린더)
        *   `ANNOUNCEMENT`: 🔵 `bi bi-megaphone text-info` (확성기)
        *   `SETTLEMENT`: 🟡 `bi bi-cash-coin text-warning` (동전)
        *   `FILE_UPLOAD`: ⚫ `bi bi-file-earmark-arrow-up text-secondary` (파일)
        *   `SYSTEM`: ⚫ `bi bi-gear text-dark` (톱니바퀴)

    *   `formatNotificationTime(timestamp)` - 사용자 친화적 시간 표시
        *   1분 미만: "방금 전"
        *   1시간 미만: "N분 전"
        *   24시간 미만: "N시간 전"
        *   7일 미만: "N일 전"
        *   7일 이상: "YYYY-MM-DD" 형식

    *   `setupEventHandlers()` - UI 이벤트 핸들러 설정
        *   알림 드롭다운 클릭 시 알림 목록 자동 로드
        *   "모두 읽음" 버튼 클릭 시 전체 알림 읽음 처리 후 목록 갱신

    *   `updateUnreadBadge(count)` - 읽지 않은 알림 개수 배지 업데이트 (개선)
        *   헤더 배지 (`notification-badge`) 표시/숨김
        *   드롭다운 헤더의 알림 개수 텍스트 업데이트
        *   "모두 읽음" 버튼 표시/숨김 (읽지 않은 알림이 없으면 숨김)

    *   `handleNewNotification(notification)` - 새 알림 수신 처리 (개선)
        *   읽지 않은 알림 개수 자동 업데이트
        *   브라우저 푸시 알림 표시
        *   **드롭다운이 열려있는 경우 알림 목록 자동 갱신** (실시간 반영)
        *   커스텀 콜백 실행

*   **알림 클릭 동작**:
    1.  읽지 않은 알림인 경우 `markAsRead(notifId)` 호출하여 읽음 처리
    2.  UI 즉시 업데이트 (배경색 제거, "New" 배지 제거)
    3.  `relatedUrl`이 있는 경우 해당 페이지로 이동

*   **init() 메서드 개선**:
    *   초기화 시 `setupEventHandlers()` 자동 호출하여 UI 이벤트 바인딩

##### **3. 전역 스코프 문제 해결** ✅

*   **문제**: `notificationClient is not defined` 에러 발생
*   **원인**: `notifications.js`에서 `const notificationClient`로 선언하여 일부 환경에서 전역 스코프로 인식되지 않음
*   **해결**: `notifications.js:366-369`
    ```javascript
    // 전역 인스턴스 생성 (window 객체에 명시적으로 할당)
    window.notificationClient = new NotificationClient();

    // 하위 호환성을 위해 const도 유지
    const notificationClient = window.notificationClient;
    ```

#### **생성 및 수정된 주요 파일**

*   **JavaScript**: `src/main/resources/static/js/notifications.js`
    *   `renderNotifications()` 메서드 추가 (193-251)
    *   `getNotificationIcon()` 메서드 추가 (253-269)
    *   `formatNotificationTime()` 메서드 추가 (271-294)
    *   `setupEventHandlers()` 메서드 추가 (296-321)
    *   `updateUnreadBadge()` 메서드 개선 (170-191)
    *   `handleNewNotification()` 메서드 개선 (85-103)
    *   `init()` 메서드에 `setupEventHandlers()` 호출 추가 (22-28)
    *   전역 스코프 명시적 할당 (366-369)

*   **View**: `src/main/webapp/WEB-INF/views/includes/admin_footer.jsp`
    *   `notifications.js` 스크립트 로드 추가 (70)
    *   알림 클라이언트 초기화 코드 추가 (71-105)
    *   디버깅 로그 및 에러 체크 로직 추가

#### **주요 트러블슈팅 및 해결 과정**

1.  **`notificationClient is not defined` 에러**:
    *   **문제**: `admin_footer.jsp`의 초기화 스크립트에서 `notificationClient`를 찾을 수 없음
    *   **진단**: `const` 선언이 일부 환경에서 전역 스코프로 노출되지 않음
    *   **해결**: `window.notificationClient`로 명시적 할당하여 전역 변수로 만듦

2.  **일정 삭제 시 알림이 발송되지 않는 문제**:
    *   **문제**: 일정 삭제 후 알림 아이콘에 배지가 표시되지 않음
    *   **원인**: 삭제한 일정에 **참석자가 없었음**
    *   **설명**: `ScheduleService.deleteCalendarEvent()` 178번 라인의 조건문 `if (!attendeeIds.isEmpty() && event != null)`에 의해 참석자가 없으면 알림이 발송되지 않음 (정상 동작)
    *   **해결**: 참석자가 포함된 일정을 생성하여 테스트해야 함을 사용자에게 안내

3.  **한글 깨짐 문제 (콘솔 로그)**:
    *   **문제**: 브라우저 콘솔에 한글이 `ìë¦¼` 같은 형태로 깨져 보임
    *   **원인**: JSP 파일의 문자 인코딩 설정 또는 브라우저 콘솔 인코딩 문제
    *   **영향**: 기능상 문제 없음, 표시만 깨짐
    *   **상태**: 기능 동작에는 영향 없어 추후 개선 예정

#### **현재 알림 시스템 완성도**

##### ✅ **100% 완성된 기능**

1.  **백엔드 (2026-01-03 완성)**:
    *   ✅ `NotificationService` - 알림 생성/조회/읽음 처리
    *   ✅ `NotificationController` - REST API 엔드포인트
    *   ✅ `NotificationWebSocketHandler` - 실시간 WebSocket 푸시
    *   ✅ DB 엔티티 및 Repository
    *   ✅ 일정 파트 연동 (일정 생성/수정/삭제 시 자동 알림 발송)

2.  **프론트엔드 (2026-01-05 완성)**:
    *   ✅ WebSocket 클라이언트 자동 연결 및 재연결
    *   ✅ 페이지 로드 시 자동 초기화
    *   ✅ 읽지 않은 알림 개수 배지 실시간 업데이트
    *   ✅ 알림 목록 드롭다운 표시
    *   ✅ 알림 타입별 아이콘 및 색상 구분
    *   ✅ 사용자 친화적 시간 표시 ("방금 전", "N분 전" 등)
    *   ✅ 알림 클릭 시 읽음 처리 및 페이지 이동
    *   ✅ "모두 읽음" 버튼 기능
    *   ✅ 브라우저 푸시 알림 (권한 허용 시)
    *   ✅ 실시간 알림 수신 및 UI 자동 갱신

##### ⚠️ **제약 사항**

*   **사용자 ID 하드코딩**: 현재 `userId=1`로 고정됨 (로그인 기능 구현 후 세션에서 실제 사용자 ID 사용 필요)
*   **relatedUrl 미구현**: 일부 알림 타입(공지사항, 정산 등)의 관련 페이지 URL이 아직 설정되지 않음 (해당 기능 구현 시 추가 필요)

#### **테스트 가이드**

##### **기본 테스트 (WebSocket 연결 확인)**

1.  서버 실행 후 브라우저에서 `http://localhost:8080` 접속
2.  F12 → Console 탭 확인
3.  예상 로그:
    ```
    ========== 알림 시스템 초기화 시작 ==========
    notificationClient 확인됨: NotificationClient {...}
    사용자 ID: 1
    Context Path:
    WebSocket 연결 시도: ws://localhost/ws/notifications?userId=1
    WebSocket 연결 성공
    ========== 알림 시스템 초기화 완료 ==========
    ```

##### **실시간 알림 테스트 (일정 등록)**

1.  일정 등록 페이지에서 새 일정 생성
2.  **중요**: 참석자에 본인(userId=1) 추가
3.  저장 후 확인:
    *   헤더 종 아이콘에 빨간 배지 (1) 표시
    *   콘솔에 "알림 수신:", "새 알림 도착:" 메시지
    *   브라우저 푸시 알림 팝업 (권한 허용 시)
4.  종 아이콘 클릭:
    *   드롭다운에 "새로운 일정: [제목]" 알림 표시
    *   🟢 초록색 캘린더 아이콘
    *   "New" 배지
5.  알림 클릭:
    *   배경색 회색 → 흰색 변경
    *   "New" 배지 사라짐
    *   읽지 않은 알림 개수 감소

##### **일정 수정/삭제 알림 테스트**

*   일정 수정 시: 🔵 파란색 "일정 수정: [제목]" 알림
*   일정 삭제 시: 🔴 빨간색 "일정 취소: [제목]" 알림

---

#### **다음 작업 계획 (업데이트된 TODO List)**

##### 🔴 **높은 우선순위**

1.  **로그인/인증 기능 구현** ⭐ 최우선!
    *   현재 상태: 모든 사용자 ID가 하드코딩된 `1L` 사용 중
    *   필요 작업:
        *   Spring Security 설정 활성화 및 구성
        *   로그인 페이지 및 세션 관리
        *   `NotificationController`, `ScheduleService` 등에서 실제 로그인 사용자 ID 사용
    *   영향 범위: 전체 애플리케이션 (일정, 알림, 정산 등)

2.  **정산 및 통계 (Settlement & Statistics) 기능 구현** ⭐ 신규!
    *   현재 상태: DB 스키마만 존재, 백엔드/프론트엔드 미구현
    *   구현 범위 (옵션 2 - 핵심 통계 포함):
        *   매출(Sales) CRUD
        *   지출(Expenses) CRUD
        *   정산(Settlements) 생성 및 조회
        *   지점별 매출/지출 통계
        *   기간별 매출/지출 통계
        *   정산 확정 처리
    *   기술 스택:
        *   백엔드: Spring Data JPA 또는 MyBatis
        *   프론트엔드: 기존 AdminLTE 템플릿 활용
        *   차트: ApexCharts (이미 템플릿에 포함됨)
    *   예상 소요 시간: 4-5시간
    *   상세 계획:

        **Phase 1: 기반 구조 생성 (1시간)**
        *   Entity/DTO 클래스 생성
            *   `Sale.java`, `SaleItem.java`
            *   `Expense.java`
            *   `Settlement.java`
            *   각 DTO 클래스
        *   Repository/Mapper 인터페이스 생성
            *   `SaleRepository.java`, `SaleMapper.java`
            *   `ExpenseRepository.java`, `ExpenseMapper.java`
            *   `SettlementRepository.java`, `SettlementMapper.java`
        *   MyBatis XML 매퍼 파일 생성 (통계 쿼리용)

        **Phase 2: 매출 CRUD 구현 (1.5시간)**
        *   `SaleService.java` 생성
            *   `createSale()` - 매출 등록
            *   `getSaleById()` - 매출 조회
            *   `updateSale()` - 매출 수정
            *   `deleteSale()` - 매출 삭제 (논리적 삭제)
            *   `getSalesByBranch()` - 지점별 매출 목록
        *   `SaleController.java` 생성
            *   `POST /api/sales` - 매출 등록
            *   `GET /api/sales/{id}` - 매출 조회
            *   `PUT /api/sales/{id}` - 매출 수정
            *   `DELETE /api/sales/{id}` - 매출 삭제
            *   `GET /api/sales` - 매출 목록 (필터: 지점, 기간)
        *   JSP 페이지 생성
            *   `sales/list.jsp` - 매출 목록
            *   `sales/form.jsp` - 매출 등록/수정 폼 (모달)

        **Phase 3: 지출 CRUD 구현 (1시간)**
        *   `ExpenseService.java` 생성 (매출과 유사한 구조)
        *   `ExpenseController.java` 생성
        *   JSP 페이지 생성
            *   `expenses/list.jsp`
            *   `expenses/form.jsp`

        **Phase 4: 통계 기능 구현 (1-1.5시간)**
        *   `StatisticsService.java` 생성
            *   `getSalesByBranch(fromDate, toDate)` - 지점별 매출 통계
            *   `getExpensesByBranch(fromDate, toDate)` - 지점별 지출 통계
            *   `getSalesByPeriod(fromDate, toDate, groupBy)` - 기간별 매출 (일/월/년)
            *   `getExpensesByPeriod(fromDate, toDate, groupBy)` - 기간별 지출
            *   `getSalesVsExpenses(fromDate, toDate)` - 매출 vs 지출 비교
        *   `StatisticsController.java` 생성
            *   `GET /api/statistics/sales/by-branch` - 지점별 매출 통계 API
            *   `GET /api/statistics/sales/by-period` - 기간별 매출 통계 API
            *   (지출도 동일한 구조)
        *   JSP 페이지 생성
            *   `statistics/dashboard.jsp` - 통계 대시보드 (차트 포함)

        **Phase 5: 정산 기능 구현 (1시간)**
        *   `SettlementService.java` 생성
            *   `createSettlement(branchId, fromDate, toDate)` - 정산 생성 (자동 집계)
            *   `confirmSettlement(settlementId)` - 정산 확정
            *   `getSettlementById(settlementId)` - 정산 조회
            *   `getSettlements(branchId, fromDate, toDate)` - 정산 목록
        *   `SettlementController.java` 생성
        *   JSP 페이지 생성
            *   `settlements/list.jsp` - 정산 목록
            *   `settlements/detail.jsp` - 정산 상세

3.  **부서 정보 연동**
    *   `departments` 테이블 생성 (DDL)
    *   `users` 테이블과 부서 연결 (FK 추가)
    *   일정 파트 부서 일정 기능 활성화

##### 🟢 **간단한 작업**

4.  **이미지 리소스 404 오류 해결**
    *   AdminLTE 템플릿 이미지 파일 추가 (`user1-128x128.jpg`, `AdminLTELogo.png` 등)
    *   `src/main/resources/static` 경로에 배치

5.  **캘린더 하단 리스트 고급 필터링**
    *   오늘/이번 주/이번 달 탭 추가
    *   일정 유형별 드롭다운 필터

##### 🟡 **중간 우선순위**

6.  **반복 일정 기능**
    *   매주/매월 반복 패턴 설정 UI 추가
    *   `repeat_info` 컬럼에 반복 규칙 JSON 저장
    *   반복 일정 생성 로직 구현

7.  **일정 알림 고급 기능**
    *   일정 시작 N분 전 알림 설정 UI
    *   스케줄러를 사용한 예약 알림 발송

8.  **서버 측 권한 체크 로직 구현**
    *   일정 삭제/수정 시 소유자 확인
    *   부서 일정 생성 권한 체크 (`ADMIN` 권한)
    *   전사 일정 생성 권한 체크 (`MASTER` 권한)

---

##### 🎯 **추천 작업 순서 (다음 단계)**

**즉시 착수 가능 (출근 전):**
1.  정산/통계 기능 구현 Phase 1-3 (기반 구조 + 매출/지출 CRUD)
2.  기본 통계 쿼리 작성

**추후 진행:**
3.  로그인/인증 기능 구현 (우선순위 최상위이나 시간 소요가 많음)
4.  정산/통계 Phase 4-5 (통계 대시보드 + 정산 기능)
5.  부서 정보 연동

---

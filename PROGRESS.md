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
*   **Entity**: `src/main/java/com/health.app/attachments/AttachmentLink.java`
*   **Repository**: `src/main/java/com/health.app/attachments/AttachmentRepository.java`
*   **Repository**: `src/main/java/com/health.app/attachments/AttachmentLinkRepository.java`
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
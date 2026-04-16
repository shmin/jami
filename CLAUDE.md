# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

**Jami** — 업무용 데이터화에 특화된 모바일 메신저 앱.
일반 메신저와의 차별점: 대화 내용의 아카이빙, 전문 검색, AI 기반 요약/분류 기능.

## 기술 스택

| 영역 | 기술 |
|------|------|
| 모바일 앱 | Flutter (iOS + Android) |
| 인증 | Firebase Auth |
| 실시간 메시지 | Firebase Firestore |
| 파일 저장 | Firebase Storage |
| 서버리스 로직 | Firebase Cloud Functions (Node.js) |
| AI 기능 | Claude API (대화 요약, 스마트 검색) |
| 상태 관리 | Riverpod |
| 로컬 검색 | Firestore 복합 인덱스 + Algolia (확장 시) |

## 주요 명령어

```bash
# 의존성 설치
flutter pub get

# 앱 실행 (디버그)
flutter run

# 특정 디바이스 지정 실행
flutter run -d <device_id>

# 전체 테스트 실행
flutter test

# 단일 테스트 파일 실행
flutter test test/features/chat/chat_repository_test.dart

# 빌드 (Android)
flutter build apk --release

# 빌드 (iOS)
flutter build ios --release

# 린트
flutter analyze

# 코드 포맷
dart format lib/

# Firebase 에뮬레이터 실행 (로컬 개발)
firebase emulators:start

# Cloud Functions 배포
firebase deploy --only functions
```

## 프로젝트 구조

```
lib/
├── main.dart                  # 앱 진입점, Firebase 초기화
├── core/
│   ├── constants/             # 앱 전역 상수 (색상, 폰트, API 엔드포인트)
│   ├── theme/                 # 앱 테마 정의
│   └── utils/                 # 공통 유틸 함수
├── features/                  # 기능 단위 모듈 (아래 참고)
│   ├── auth/
│   ├── chat/
│   ├── archive/
│   └── ai/
├── models/                    # 데이터 모델 (Firestore 직렬화 포함)
├── services/
│   ├── firebase/              # Firestore, Storage, Auth 래퍼
│   └── ai/                    # Claude API 클라이언트
└── widgets/                   # 앱 전역 공용 위젯
```

각 feature 폴더 구조:
```
features/<name>/
├── screens/      # UI 화면
├── widgets/      # 해당 기능 전용 위젯
├── providers/    # Riverpod 상태 관리
└── repository/   # Firebase 데이터 접근 레이어
```

## 아키텍처 원칙

### 레이어 구조
```
Screen → Provider (Riverpod) → Repository → Firebase / AI Service
```
- **Screen**: UI 렌더링만 담당, 비즈니스 로직 없음
- **Provider**: 상태 관리 및 비즈니스 로직
- **Repository**: Firebase/외부 API 호출을 추상화, 테스트 가능하도록 인터페이스 분리
- **Service**: Firebase SDK, Claude API 등 외부 서비스 직접 호출

### Firestore 데이터 모델
```
users/{userId}
  └─ profile, settings

chats/{chatId}
  ├─ metadata (participants, lastMessage, createdAt)
  └─ messages/{messageId}
       ├─ content, senderId, timestamp, type
       └─ archived: bool, tags: [], summary: string (AI 생성)

archives/{userId}/items/{itemId}
  └─ messageRef, tags, note, createdAt
```

### 핵심 기능 구현 포인트

**실시간 메시지**
- `Firestore.collection('chats').snapshots()` 스트림을 Riverpod `StreamProvider`로 구독
- 메시지 전송은 낙관적 업데이트(Optimistic Update) 적용

**아카이빙**
- 메시지 롱프레스 → archive 컬렉션에 참조 저장
- 태그, 메모 추가 가능
- 아카이브 뷰에서 태그/날짜/채팅방 기준 필터링

**검색**
- Firestore 복합 인덱스로 기본 검색 구현
- 본문 전문 검색이 필요해지면 Algolia 확장

**AI 요약 (Claude API)**
- Cloud Functions에서 Claude API 호출 (API 키를 클라이언트에 노출하지 않기 위해)
- 트리거: 아카이브 저장 시 or 사용자 수동 요청
- 결과는 해당 message 또는 archive 문서의 `summary` 필드에 저장

## 개발 환경 설정

1. Flutter SDK 설치 (stable 채널)
2. Firebase CLI 설치: `npm install -g firebase-tools`
3. `firebase login` 후 프로젝트 연결
4. `google-services.json` (Android), `GoogleService-Info.plist` (iOS) 를 각 플랫폼 폴더에 배치
   - 이 파일들은 `.gitignore`에 포함 — 팀원과는 별도로 공유
5. `flutter pub get`

## 코딩 컨벤션

- 파일명: `snake_case.dart`
- 클래스명: `PascalCase`
- Provider 명: `~Provider` 또는 `~Notifier` suffix
- Repository 인터페이스는 abstract class로 정의, Firebase 구현체는 `Firebase~Repository`로 명명
- Firestore 문서 매핑은 모델 클래스의 `fromMap` / `toMap` 메서드로 일관되게 처리
- `lib/` 외부(예: Cloud Functions)는 TypeScript 사용

## 주의사항

- `google-services.json`, `GoogleService-Info.plist`, `.env` 파일은 절대 커밋하지 않음
- Claude API 키는 반드시 Cloud Functions 환경변수로만 관리 (`firebase functions:config:set`)
- Firestore 보안 규칙(`firestore.rules`)은 항상 인증된 사용자만 본인 데이터에 접근하도록 유지

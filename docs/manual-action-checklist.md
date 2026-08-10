# 사용자 수동 작업 체크리스트

- 최초 작성일: 2026-08-07
- 상태: `active_trigger_list`
- 목적: Codex가 직접 완료할 수 없는 화면 조작·계정·외부 신청·실제 참여자 작업을 필요한 시점에만 사용자에게 요청한다.

## 운영 원칙

- 아래 항목은 지금 즉시 수행할 작업 목록이 아니다.
- Trigger가 오기 전에는 `deferred_manual`로 유지하며, Codex가 할 수 있는 Desk research·검증 설계·문서 작업을 먼저 진행한다.
- 사용자가 수행하기 전에는 완료나 검증으로 기록하지 않는다.
- 실제 Form URL·ID, `researchCode`, 참여자 응답, 복구 수단 값은 공개 저장소에 기록하지 않는다.

## 후속 외부 사용자 검증 수동 Trigger

Gate 1 Founder scope는 통과했으며 아래 작업은 제품 설계의 현재 선행조건이 아니다. 외부 참여자 모집·연락·응답 수집, 공개 Beta 또는 시장 수요 주장 중 가장 먼저 도래하는 시점 전에 사용자가 외부 검증을 명시적으로 승인한 뒤 세 단계의 차단 시점에 맞춰 최소 항목만 재개한다.

### 1단계 — 외부 모집물에 전용 Email 주소 게시·사용 전

| 수동 작업 | 작업 상태 | 근거 상태 | 완료 증거 |
| --- | --- | --- | --- |
| Google 국외 처리 고지 법적 충분성 검토 | `deferred_manual` | `specialist_review_required` | 검토 주체·검토일·사용 승인 문안 버전 |
| 철회 Email 송수신·Spam·회신·영구 삭제 시험 | `deferred_manual` | `configured_not_tested` | 시험일·통과 여부만 기록 |
| 2단계 인증 또는 Passkey·복구 수단 확인 | `deferred_manual` | `not_verified` | 값 자체가 아닌 켜짐·확인 여부 |
| 모집 채널·보상·진행자·일정 승인 | `deferred_manual` | `decision_not_made` | 승인된 운영값 |

### 2단계 — Form A Link 전달·응답 수집 전

| 수동 작업 | 작업 상태 | 근거 상태 | 완료 증거 |
| --- | --- | --- | --- |
| Form A 최종 문안·설정 재점검 | `deferred_manual` | `partial_user_verified` | 소유자 1명, 공동편집자 0명, Drive 제한, 응답 설정 Checklist |
| Form A의 Sheet·Add-on·Offline·동기화·Mail client 없음 확인 | `deferred_manual` | Sheet 없음만 확인, 나머지 `not_verified` | 항목별 통과 여부 |
| Form A 가상 응답 Dry-run | `deferred_manual` | `not_verified` | 거부·부적격·적격 분기, 제출·개별 삭제·재조회 결과 |
| Wave ID·보관 Anchor와 자료별 예정 삭제일 계산 | `deferred_manual` | `not_verified` | 수집 전 `waveRetentionAnchorDate` 고정. 동의 거부 즉시, 부적격 판정 +7일, 적격 미참여 확정/모집 종료 중 이른 날 +7일, Interview 참여 `min(Interview일 +90일, Anchor +30일, 실제 조기 종료·중단일 +30일)` 검산 |

### 3단계 — 첫 Interview 전

| 수동 작업 | 작업 상태 | 근거 상태 | 완료 증거 |
| --- | --- | --- | --- |
| Form B 생성·연구자 전용 접근 설정 | `deferred_manual` | `not_verified` | 구조화 필드, 소유 계정 제한, 공동편집자 0명 |
| Form B의 Sheet·Add-on·Offline·동기화·Mail client 없음 확인 | `deferred_manual` | `not_verified` | 항목별 통과 여부 |
| Form B 가상 Note 제출·삭제 Dry-run | `deferred_manual` | `not_verified` | 제출·개별 삭제·재조회 결과 |

### 실제 연구 실행

| 수동 작업 | 작업 상태 | 재개 조건 | 완료 증거 |
| --- | --- | --- | --- |
| 2명 Pilot Interview | `deferred_manual` | 사용자가 후속 외부 사용자 검증을 명시적으로 승인하고 1~3단계 통과 | 비식별 집계, Script 문제와 반증 결과 |
| Main Interview | `planned` | Pilot Script·운영 결과를 검토하고 별도 승인 | 실제 표본 수, 비식별 집계와 가설별 반증 결과 |

Form A는 2026-08-06에 지정 계정 소유, 공동편집자 0명, 편집자 일반 접근 제한, 미게시, 응답 0건, Sheet 미연결 상태를 화면에서 확인했다. 질문 구조와 다섯 분기 미리보기는 사용자가 정상 동작을 확인했다. 최종 문안, 수정 요청한 일부 응답 설정, 계정 보호, Form B와 Dry-run은 검증 완료로 간주하지 않는다.

## Gate 2 실호출 Trigger

2026-08-10 사용자가 Phase 1 개발용 API 4건의 활용신청, Secret 비노출 로드와 Contract smoke를 승인했다. [활용신청 가이드](./provider-application-guide.md)에 따라 신청하되, 14일 Canary 실행환경·예산과 운영계정·Traffic 상향·기관 문의·제품 코드는 별도 승인 전 진행하지 않는다.

| 수동 작업 | 작업 상태 | 근거 상태 | 완료가 필요한 시점 | 완료 증거 |
| --- | --- | --- | --- | --- |
| 공공데이터 API 활용신청 | `done` | `applications_4_of_4_approved`; 모두 2026-08-10~2028-08-10, 실제 승인 Traffic `not_verified` | 완료 | 신청 대상·용도·승인일 |
| 인증키 발급·비밀 저장 | `done` | Decoding 형태 정규화·DPAPI Import·C-12 `pass` | 완료 | 값 비출력 |
| 첫 Contract smoke | `blocked` | 세 Sentinel C-01 `pass`; AirKorea 대기오염 Run 9는 HTTP 200·Provider `00`·Item 1개·핵심 Field 3개 관찰, 원본 C-01 `fail`; Live 응답표·공식 Sample과 첨부 v1.4 필드표의 `stationName` 계약 충돌, Freshness `not_evaluated`; Retry 0, C-12·Plan·Security `pass`, 누적 10회 | 같은 이유의 재호출 없이 Schema 충돌 처리·기관 문의 여부와 다음 Contract 범위·Plan·Hash·실호출 결정을 먼저 고정 | Sanitized Manifest·Canonical Plan Hash·C-12·공식 문서 대조 결과만 기록 |
| 운영계정·Traffic 상향 신청 | `deferred_manual` | `approval_not_requested` | 실제 배포 필요량이 근거로 확인된 뒤 | 승인량·조건·유효기간 |
| AirKorea 위치 관련 절차 적용 여부 문의 | `deferred_manual` | `external_answer_required` | AirKorea를 Production Provider로 확정하기 전 | 기관 서면 답변 또는 전문 검토 |
| AirKorea 응답 Schema 충돌 문의 | `deferred_manual` | [문의 초안](./airkorea-schema-inquiry-draft.md) `draft_not_sent` | 사용자가 외부 제출을 명시적으로 승인한 뒤 | 답변일·답변기관·공식 판정만 공개 기록 |
| License 불명확 항목의 제공기관·전문가 확인 | `deferred_manual` | `external_answer_required` | 해당 Provider를 제품 기본 경로로 채택하기 전 | 답변 원문 보관 위치와 판정만 공개 기록 |

인증키 저장 완료 상태는 현재 작업 PC에만 적용된다. 다른 PC에서는 DPAPI CLIXML을 복사하지 말고, 그 PC의 안전한 Prompt로 다시 입력한 뒤 Import와 C-12를 확인한다.

## 별도 승인 없이는 계속 하지 않는 작업

- 원격 Push 또는 PR 생성
- 외부 배포와 유료 Resource 생성
- 공개 Web Push 발송
- 운영 API 활용신청·Traffic 상향 신청
- Git 전역 설정 또는 PowerShell 실행 정책 변경
- 실제 참여자 모집·연락·보상 지급

## Codex 알림 규칙

- 다음 단계가 이 Checklist의 수동 작업 없이는 진행 불가능해질 때만 사용자에게 요청한다.
- 한 번에 필요한 최소 항목과 이유·완료 기준을 제시한다.
- 아직 필요하지 않은 수동 항목을 선행 작업처럼 요구하지 않는다.

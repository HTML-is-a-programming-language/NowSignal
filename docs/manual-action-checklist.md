# 사용자 수동 작업 체크리스트

- 최초 작성일: 2026-08-07
- 상태: `active_trigger_list`
- 목적: Codex가 직접 완료할 수 없는 화면 조작·계정·외부 신청·실제 참여자 작업을 필요한 시점에만 사용자에게 요청한다.

## 운영 원칙

- 아래 항목은 지금 즉시 수행할 작업 목록이 아니다.
- Trigger가 오기 전에는 `deferred_manual`로 유지하며, Codex가 할 수 있는 Desk research·검증 설계·문서 작업을 먼저 진행한다.
- 사용자가 수행하기 전에는 완료나 검증으로 기록하지 않는다.
- 실제 Form URL·ID, `researchCode`, 참여자 응답, 복구 수단 값은 공개 저장소에 기록하지 않는다.

## 실제 Pilot 모집을 승인할 때

| 수동 작업 | 현재 상태 | 완료가 필요한 시점 | 완료 증거 |
| --- | --- | --- | --- |
| Form A 최종 문안·설정 재점검 | `partial` | 모집 Link 전달 전 | 소유자 1명, 공동편집자 0명, Drive 제한, 응답 설정 Checklist |
| Form B 생성·연구자 전용 접근 설정 | `deferred_manual` | 첫 Interview 전 | 구조화 필드, 소유 계정 제한, 공동편집자 0명 |
| 2단계 인증 또는 Passkey·복구 수단 확인 | `deferred_manual` | 모집 Link 전달 전 | 값 자체가 아닌 켜짐·확인 여부 |
| Google 국외 처리 고지 법적 충분성 검토 | `deferred_manual_specialist` | 실제 참여자에게 동의 문안 제시 전 | 검토 주체·검토일·사용 승인 문안 버전 |
| Form A/B 가상 응답 Dry-run | `deferred_manual` | 실제 응답 수집 전 | 분기·제출·개별 삭제·재조회 결과와 식별정보 없는 건수 |
| Sheet·Add-on·Offline·동기화·Mail client 없음 확인 | `deferred_manual` | 실제 응답 수집 전 | 항목별 통과 여부 |
| 철회 Email 송수신·Spam·회신·영구 삭제 시험 | `deferred_manual` | 모집 안내 게시 전 | 시험일·통과 여부만 기록 |
| 모집 채널·보상·진행자·일정 승인 | `deferred_manual_decision` | 모집 시작 전 | 승인된 운영값 |
| 2명 Pilot과 Main Interview 수행 | `deferred_manual_participant_work` | Gate 1 실제 증거가 필요할 때 | 비식별 집계와 반증 결과 |

Form A는 2026-08-06에 지정 계정 소유, 공동편집자 0명, 편집자 일반 접근 제한, 미게시, 응답 0건, Sheet 미연결 상태를 화면에서 확인했다. 질문 구조와 다섯 분기 미리보기는 사용자가 정상 동작을 확인했다. 최종 문안, 수정 요청한 일부 응답 설정, 계정 보호, Form B와 Dry-run은 검증 완료로 간주하지 않는다.

## 실제 API 호출 검증을 승인할 때

| 수동 작업 | 현재 상태 | 완료가 필요한 시점 | 완료 증거 |
| --- | --- | --- | --- |
| 공공데이터 API 활용신청 | `deferred_manual_approval` | 인증키 기반 smoke test 전 | 신청 대상·용도·승인일 |
| 인증키 발급·비밀 저장 | `deferred_manual_secret` | 최초 실호출 전 | 환경변수 이름과 로드 성공 여부만 기록, 값은 기록 금지 |
| 운영계정·Traffic 상향 신청 | `deferred_manual_approval` | 실제 배포 필요량이 근거로 확인된 뒤 | 승인량·조건·유효기간 |
| AirKorea 위치 관련 절차 적용 여부 문의 | `deferred_manual_external_contact` | AirKorea를 배포 Provider로 확정하기 전 | 기관 서면 답변 또는 전문 검토 |
| License 불명확 항목의 제공기관·전문가 확인 | `deferred_manual_external_contact` | 해당 Provider를 제품 기본 경로로 채택하기 전 | 답변 원문 보관 위치와 판정만 공개 기록 |

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

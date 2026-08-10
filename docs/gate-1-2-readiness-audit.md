# Gate 1·2 비코드 준비 상태 감사

- 감사일: 2026-08-07 (Asia/Seoul)
- 후속 결정 반영일: 2026-08-07 (DL-013)
- 후속 공식 페이지 재확인: 2026-08-09. KMA Locale 호출량 충돌 해소, 실제 승인량과 AirKorea 운영 가능 여부는 계속 `not_verified`
- 후속 실행 반영일: 2026-08-10, Contract smoke Run 9까지
- 문서 상태: `updated_after_run_9`
- 감사 범위: Gate 1 연구 준비, Gate 2 Public Data 검증 준비, 수동 Trigger, 상태·근거·로컬 Link 정합성
- 최초 감사 제외 범위: 제품 코드, Google Forms 추가 조작, 참여자 모집·연락, API 활용신청·키 입력·실호출, 기관 문의, Production 승인. 이후 API 활용승인·Secret 상태·Sanitized 실호출 결과만 후속 반영
- 근거 원칙: 문서·화면 부분 확인과 실제 참여자·API 실행 증거를 분리하며, 실행하지 않은 결과는 `not_verified` 또는 `not_run`으로 유지한다.

## 1. 결론

| Gate | Gate Workflow | 비코드 준비 | 실행 Evidence | 현재 판단 |
| --- | --- | --- | --- | --- |
| Gate 1 Founder Problem Fit | `done` | `complete_for_founder_scope` | 창업자 자기보고 7개 패턴 `founder_lived_experience_n1`; 외부 Interview 0건 | DL-013에 따라 `passed_for_founder_scope`. 시장 수요는 `not_verified` |
| Gate 2 Public Data Feasibility | `in_progress` | `blocked_pending_official_schema_conflict_resolution_and_next_network_scope_decision` | DPAPI Import·C-12 `pass`; KMA 두 Provider·AirKorea 측정소 C-01 `pass`; AirKorea 대기오염 Run 9는 HTTP 200·Provider `00`·Item 1개·핵심 Field 3개 관찰, 원본 C-01 `fail`; Live 응답표·공식 Sample과 첨부 v1.4 필드표의 `stationName` 계약 충돌, Freshness `not_evaluated`; 누적 10회, Offline Validator 25/25 통과, 나머지 오류 Contract·Canary `not_run` | Run 6의 504·Run 7의 Local Validator 오류·Run 9 원본 실패를 보존하고 문서 충돌을 Provider 위반이나 통과로 단정하지 않음. 전체 Contract·권리 조건·Canary 확인 전 최종 통과 불가 |
| Gate 3 Product Design | `blocked` | 해당 없음 | 없음 | Gate 2 필수 Provider 가능성 확인과 Gate 3 설계 승인 전 진입 금지 |

초기 감사 당시 Gate 1은 외부 Interview 전 통과 불가였으나, 사용자의 후속 결정으로 [창업자 문제 근거](./founder-problem-evidence.md)를 별도 기록해 Founder scope에서만 통과했다. 이는 시장 수요 검증이나 제품 가능성 검증을 뜻하지 않는다. 지금 사용자에게 요구할 Google Forms 작업은 없다.

## 2. 상태 축

문서 간 합성 상태의 의미가 섞이지 않도록 다음 축을 분리한다.

| 축 | 예시 | 의미 |
| --- | --- | --- |
| Workflow | `done`, `in_progress`, `planned`, `deferred_manual`, `blocked` | 작업의 현재 진행 상태 |
| Evidence | `not_verified`, `not_run`, `partial_user_verified`, `configured_not_tested` | 어떤 근거까지 실제로 확보했는지 |
| Founder evidence | `founder_lived_experience_n1` | 창업자 자기보고에만 적용하며 외부 사용자에게 일반화하지 않음 |
| Gate decision | `passed_for_founder_scope`, `in_progress`, `blocked`, 향후 `passed` 또는 `rejected` | Gate 전체 판단과 적용 범위 |
| Provider result | `data`, `valid_empty`, `unavailable`, `not_fetched` | 호출 결과 존재 여부. License 차단 시 호출하지 않음 |
| Provider quality | `fresh`, `delayed`, `stale`, `partial`, `conflicting` | 존재하는 데이터의 품질 |
| License | `usable`, `license_blocked`, `license_review_expired` | 제품 사용 권리 상태 |

`deferred_manual`은 사용자가 지금 해야 한다는 뜻이 아니라 Trigger 전까지 실행하지 않는다는 뜻이다. `not_run`은 실행 이력이고 둘은 동시에 참일 수 있다.

## 3. 정리한 불일치

| ID | 발견 | 정리 결과 |
| --- | --- | --- |
| A-01 | Form A 부분 확인과 Form B 미생성을 “두 Form 미검증”으로 합쳐 표시 | Form A는 Workflow `deferred_manual`·Evidence `partial_user_verified`, Form B는 `deferred_manual`·`not_verified`로 분리 |
| A-02 | 외부 모집물의 Email 사용, Form A 전달, 첫 Interview 전 차단 작업의 시점이 섞임 | 외부 사용자 검증 수동 작업을 3단계 Trigger로 분리하고 단계별 완료 증거 명시 |
| A-03 | Form A 실제 문항의 가능한 시간대·삭제/철회 확인이 Protocol 최소수집 목록에 빠짐 | Screening 목록·수집 Inventory·동의 안내와 Build sheet를 동일하게 맞춤 |
| A-04 | 필수 동의 거부·부적격·적격 미참여 응답의 삭제 기한 표현이 섞임 | 동의 거부는 즉시, 부적격은 판정일 +7일, 적격 미선정·미참여는 확정일/모집 종료 중 이른 날 +7일, Interview 참여는 `min(Interview일 +90일, waveRetentionAnchorDate +30일, 실제 Wave 조기 종료·중단일 +30일)`로 통일 |
| A-05 | Pilot 직접 인용 금지와 포트폴리오·가설 문서의 직접 인용 계획이 충돌 | Pilot은 비식별 요약만 사용하고 직접 인용은 별도 동의를 받은 후속 연구로 제한 |
| A-06 | API 활용신청이 `blocked`와 `deferred_manual`로 다르게 표시 | 명시적 실호출 Trigger 전 Workflow를 `deferred_manual`로 통일 |
| A-07 | `valid_empty`, `unavailable`, License 차단이 하나의 Provider 상태 계약에서 일관되게 표현되지 않음 | 결과·품질·License 축을 분리하고 Catalog·Runbook·Fail-closed 문서를 맞춤 |
| A-08 | KMA 10,000회/일과 AirKorea 500회/일이 확정 quota처럼 보이면서 다른 곳에서는 충돌·공유 범위 미확인으로 기록 | 2026-08-09 Live 상세에서 KMA 한·영문 10,000회/일은 일치했고 AirKorea 사용자 지원 API는 계정별 개발 500회/일을 명시했다. 실제 승인량·Reset 시각은 `not_verified`로 유지하고 더 낮은 보수적 실검증 상한과 Canary 예산을 별도로 표시 |
| A-09 | 실제 Gate 2 통과 전 작업을 “Gate 2 이후”라고 표시 | Phase 1 Gate 2 실검증과 후속 Production·Phase 차단 조건을 분리 |
| A-10 | Provider Runbook 상단 `not_run`과 Preconditions의 `deferred_manual`이 모순처럼 보임 | 실행 이력 `not_run`과 현재 Workflow `deferred_manual`을 분리 |
| A-11 | 초기 Provider 후보 목록이 현재 Phase·상용 판정을 반영하지 않음 | Decision Log에 Phase 1 범위와 MOIS·TourAPI·외부 지오코더·Push의 후속 범위를 기록 |
| A-12 | Canary 전 합격 기준 고정과 Canary 후 Freshness 정책 확정이 같은 Threshold처럼 표현됨 | `pre_registered_acceptance_criteria`와 `production_policy_threshold`를 분리하고 소급 변경 금지 |
| A-13 | Contract·Canary 기술 통과와 AirKorea 권리 조건을 포함한 최종 Gate 2 통과가 섞임 | Technical provider pass와 최종 Gate 2 pass를 분리하고 AirKorea 유지·제외 분기 명시 |
| A-14 | 후속 결정에서 외부 Interview를 Gate 1 선행조건에서 제외하면 Gate 상태와 연구 보관기한 기준이 과거 시점에 묶임 | DL-013으로 Founder scope 통과와 외부 일반화 `not_verified`를 분리하고, 수집 전 고정하는 `waveRetentionAnchorDate`와 실제 조기 종료일을 보관 상한으로 사용 |
| A-15 | AirKorea Live 응답표·공식 Sample은 `stationName`을 응답에서 생략하지만 같은 첨부 v1.4 필드표는 필수로 표시 | Run 9 원본 C-01 실패를 보존하고, 핵심 Field 관찰 성공과 `conflicting_official_schema`를 분리. 같은 요청을 반복하지 않고 기관 확인과 다음 Contract 범위를 별도 결정 |

## 4. Link 감사

- 실제 상대 Markdown Link의 대상 파일은 모두 존재한다.
- `docs/07-system-architecture.md`, `docs/08-agent-workflow.md`, `docs/10-data-normalization.md`, `docs/11-alert-policy.md`, `docs/12-location-privacy.md`는 [Decision Log](./14-decision-log.md)에 `planned`로 표시한 예정 산출물이다. 아직 파일이 없고 Markdown Link로 만들지 않았으므로 현재 깨진 Link가 아니다.
- 실행 문서의 코드 텍스트 경로는 실제 상대 Link로 바꿨다.
- 기상청 API허브 격자 안내는 좌표 변환 공식만 참고하며 공공데이터포털 Provider의 인증·Quota·약관 근거로 사용하지 않는다.

## 5. 재개 조건

### 후속 외부 사용자 검증

외부 참여자 모집·연락·응답 수집, 공개 Beta 또는 시장 수요 주장 중 가장 먼저 도래하는 시점 전에 사용자가 후속 검증을 명시적으로 승인할 때만 다음 순서로 재개한다.

1. 외부 모집 안내에 전용 Email 주소를 게시·사용하기 전 법적 고지, Email 시험, 계정 보호와 운영값 확인
2. Form A Link 전달 전 최종 설정·외부 연동·분기·삭제일 Dry-run
3. 첫 Interview 전 Form B 생성·접근 제한·제출/삭제 Dry-run

### Gate 2

사용자는 2026-08-10 Phase 1 개발 활용신청과 제한된 Contract 실호출을 승인했고 Run 9까지의 실행을 완료했다. 키 값은 Chat·문서·Screenshot·Git에 남기지 않는다. AirKorea 대기오염은 HTTP 200·Provider `00`·핵심 Field를 관찰했지만 `stationName`에 관한 공식 자료가 충돌한다. 같은 이유로 재호출하지 않고 기관 확인 여부와 다음 Contract 범위·Plan·Hash·실호출을 별도로 결정한다. Contract 전체와 Canary가 실제 Evidence를 만들기 전에는 Gate 2를 통과시키지 않는다.

### Trigger가 없을 때

- Google Forms를 게시하거나 Form B를 만들지 않는다.
- 참여자를 모집·연락하거나 응답을 수집하지 않는다.
- API를 신청·호출하거나 외부 기관에 문의하지 않는다.
- Gate 2 통과와 Gate 3 설계 승인 전에는 제품 코드를 작성하지 않는다.

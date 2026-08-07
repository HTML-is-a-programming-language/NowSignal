# NowSignal AI 작업 목록

- 기준일: 2026-08-07 (Asia/Seoul)
- 현재 단계: Gate 0 완료, Gate 1·2 비코드 준비 감사 완료. 실제 문제·Provider 검증은 `not_verified`이며 Trigger 전 수동 작업은 유예
- Workflow·Gate 상태: `done`, `in_progress`, `planned`, `deferred_manual`, `blocked`
- Evidence 상태: `not_verified`, `not_run` 또는 근거 종류를 나타내는 문서별 세부값. [비코드 준비 감사](./docs/gate-1-2-readiness-audit.md)의 상태 축을 따른다.
- 근거 원칙: 실행·관찰·인터뷰로 확인하지 않은 결과는 성과로 기록하지 않는다.

## 작업 분리 원칙

- Google Forms, 계정 보안, Email 송수신, 실제 참여자 모집·Interview처럼 사용자 화면·판단이 필요한 작업은 실제 실행 직전까지 `deferred_manual`로 둔다.
- `deferred_manual`은 완료나 검증을 뜻하지 않으며, 해당 작업이 필요한 Trigger가 오면 `docs/manual-action-checklist.md`를 기준으로 사용자에게 알린다.
- 이 수동 작업들은 실제 참여자 데이터를 수집하기 전에는 필수지만, Desk research·검증 설계·문서 정합성 작업을 막지는 않는다.
- Gate 1·2 통과 전 제품 코드는 계속 작성하지 않는다.

## Gate 현황

| Gate | 상태 | 통과 조건 | 현재 증거 | 다음 판단 |
| --- | --- | --- | --- | --- |
| Gate 0 환경 확인 | `done` | 저장소, Git, Node, package manager, 환경변수 이름, 덮어쓰기 위험 확인 | GitHub 공개 저장소·권한 확인, 작업 브랜치 Push와 upstream SHA 일치 검증, Node 및 package manager 버전 확인 | Git·PowerShell의 로컬 제약은 명령별 우회 유지 |
| Gate 1 문제 검증 | `in_progress` | 목표 직무 공고, 사용자 가설, 인터뷰, 기존 대안, 성공 지표를 실제 근거로 검토 | Desk research, 인터뷰 계획, Consent Protocol v1.1, Form A 부분 설정, [비코드 준비 감사](./docs/gate-1-2-readiness-audit.md) | 문서 준비는 완료. 실제 문제 증거 수집을 승인할 때 단계별 Privacy Preflight를 재개하며 Interview 전에는 Gate 통과 금지 |
| Gate 2 Public Data Feasibility | `in_progress` | API, License, Traffic, Freshness, Coverage, Failure mode, Adapter 적합성 검증 | 공식 문서 기반 조사표·License Register·실검증 Runbook·fail-closed 초안·[비코드 준비 감사](./docs/gate-1-2-readiness-audit.md) | 비코드 실행 명세는 준비됨. 인증키 Contract·Canary와 이용조건 확인 전에는 Gate 통과 금지 |
| Gate 3 Product Design | `blocked` | PRD, Journey, MVP, 제외 범위, Wireframe | 없음 | Gate 1 핵심 가설 판단과 Gate 2 필수 Provider 가능성 확인 필요 |
| Gate 4 Data Foundation | `planned` | Fetch, Validation, Normalization, Cache, Attribution, Freshness | 없음 | Gate 2 통과 후 시작 |
| Gate 5 Activity Optimizer | `planned` | Score, Best Window, Hard Block, Alternatives, Algorithm Version | 없음 | Gate 4 후 시작 |
| Gate 6 Agent Briefing | `planned` | Correlation, Explanation, Evidence, Verification, Trace | 없음 | Gate 5 후 시작 |
| Gate 7 Local Opportunities | `planned` | Event, Indoor/Outdoor, Hours, Distance, Alternative | 없음 | Phase 1 검증 후 시작 |
| Gate 8 Proactive Alerts | `planned` | Change Detection, Policy, Web Push, Deduplication, Feedback | 없음 | 알림 가치 가설 검증 후 시작 |
| Gate 9 Evaluation | `planned` | Historical data, Scenario, Cost, Latency, Safety, Reliability | 없음 | 실행 전 수치 기록 금지 |
| Gate 10 User Validation | `planned` | Usability, Beta, Feedback, Improvement, Revalidation | 없음 | 실제 참여자만 기록 |
| Gate 11 Portfolio | `planned` | README, Architecture, Demo, Case Study, Evidence 연결 | 없음 | 검증된 증거만 사용 |

## Gate 0 — 완료 내역

- [x] `done` 작업 디렉터리와 파일 존재 여부 확인
- [x] `done` Git branch/status 및 커밋 유무 확인
- [x] `done` Node, Corepack, pnpm, npm 버전 확인
- [x] `done` 환경변수 **이름만** 점검하고 값은 수집하지 않음
- [x] `done` 기존 **로컬** 파일이 없어 현재 문서와의 덮어쓰기 충돌이 없음을 확인
- [x] `done` GitHub에서 원격이 검증 당시 빈 공개 저장소이고 기본 branch 이름이 `main`임을 확인한 뒤, `docs/gate-0-2-foundation` Push와 local/upstream SHA `5459cdbd961d1259fe05d80e9e02072e34a50f3c` 일치 확인
- [ ] `planned` Git `dubious ownership`의 지속 해결 방식을 사용자와 결정
- [ ] `planned` PowerShell 실행 정책을 바꾸지 않고 `.cmd` 실행을 표준 명령으로 문서화

## Gate 1 — 문제 검증

### 문서와 Desk research

- [x] `done` 프로젝트 Charter 초안 작성
- [x] `done` 문제·사용자·가치 가설을 검증 가능한 문장으로 분해
- [x] `done` 인터뷰 대상, 질문, 동의, 기록, 중단 기준 초안 작성
- [x] `done` 기존 대안과 비교 관찰 계획 작성
- [x] `done` 성공 지표의 정의·측정식·데이터 출처 초안 작성
- [x] `done` 목표 직무 공고 3건을 회사 공식 채용 페이지 또는 공식 ATS에서 확인하고 확인일·URL·역량·Gap 기록. 작은 표본이며 시장 주장 아님을 명시
- [x] `done` Pilot Interview 참여자 모집 기준의 Privacy·편향·권력관계 위험 검토
- [x] `done` 연구 데이터 최소수집·분리·접근·보관·삭제·철회 기준과 Consent 핵심 문안 v1.1 작성
- [x] `done` 공개 저장소에 연구 원자료가 staging되는 것을 줄이는 `.gitignore` 방어 규칙 추가
- [x] `done` 개인정보 처리 주체 `NowSignal`, 철회 Email, 대면 1:1·무녹음 Pilot 방식을 사용자 확인값으로 반영
- [x] `done` Google Forms Cloud-only 운영 방식과 두 Form의 Build sheet·삭제 Runbook 작성

### 실제 검증 — 명시적 Pilot Trigger에서 재개

- [ ] `deferred_manual` Form A 생성·소유권·공동편집자 0명·Drive 제한·미게시·응답 0건·Sheet 미연결은 부분 확인. 질문 구조와 5개 분기 미리보기는 사용자 확인, 최종 문안·설정 재점검은 남음
- [ ] `deferred_manual` Form B 생성·소유권·접근 제한·구조화 필드 설정 — 첫 Interview가 확정된 뒤 3단계에서 재개
- [ ] `deferred_manual` 전용 계정 2단계 인증 또는 Passkey와 복구 수단 확인 — 실제 Pilot 모집 전 필수
- [ ] `deferred_manual` Form A/B의 Email·파일·결과 요약·응답 수정·Draft 저장과 Add-on·Offline·동기화·Mail client 상태 최종 점검
- [ ] `deferred_manual` Google 국외 처리 고지와 별도 동의 문안의 법적 충분성 검토 — 실제 참여자에게 문안을 제시하기 전 필수
- [ ] `deferred_manual` 1단계에서 철회 Email 송수신·Spam 분류·영구 삭제 시험
- [ ] `deferred_manual` 2단계에서 Form A 가상 분기·제출·개별 삭제·재조회와 예정 삭제일 계산
- [ ] `deferred_manual` 3단계에서 Form B 가상 Note 제출·개별 삭제·재조회
- [ ] `deferred_manual` 사용자의 실제 문제 증거 수집 승인과 단계별 Preflight 통과 후 2명 Pilot 문제 인터뷰 수행
- [ ] `planned` Pilot Script·운영 결과 검토 후 Main Problem Interview를 별도 승인·수행
- [ ] `deferred_manual` 구조화 Interview Note Form에 실제 관찰을 기록하고 직접 인용을 수집하지 않았는지 확인
- [ ] `planned` 문제 인터뷰 후 Gate 3에서 저충실도 Prototype 범위를 승인한 뒤 Raw Data UI 대 Action Brief UI 비교 과제 설계·수행
- [ ] `deferred_manual` 실제 Interview 근거로 가설별 evidence count·반증 사례와 Gate 3 진입 여부 결정

## Gate 2 — Public Data Feasibility

### 공식 문서 조사

- [x] `done` 기상청 날씨·특보 후보 API 조사
- [x] `done` 한국환경공단 AirKorea 대기질 후보 API 조사
- [x] `done` 행정안전부 긴급재난문자 후보 API 조사
- [x] `done` 한국관광공사 TourAPI 후보 조사
- [x] `done` VWorld geocoding 후보 조사
- [x] `done` 각 후보의 License, 공개 Traffic, Freshness, Coverage, Failure mode 기록
- [x] `done` `WeatherProvider`, `AirQualityProvider`, `SafetyAlertProvider`, `LocalEventProvider`, `GeocodingProvider` 적합성 매핑
- [x] `done` Product License Register 초안 작성
- [x] `done` Phase 1 Provider 실검증 Runbook·Evidence 규격·`not_run` 결과표 작성
- [x] `done` stale·delayed·partial·conflicting·unavailable·License 차단의 fail-closed 판단 초안 작성 — Gate 3 승인 전까지 `draft_not_approved`
- [x] `done` 2026-08-07 KMA 한국어·영문 Locale 호출량 표시 충돌 확인, 낮은 값 우선 원칙 기록

### Phase 1 실제 API·법적 검증 — 아직 수행하지 않음

| 작업 | Workflow | Evidence | 재개 조건 |
| --- | --- | --- | --- |
| API 활용신청 및 인증키 발급 | `deferred_manual` | `approval_not_requested` | 사용자의 명시적 실호출 승인 |
| 정상·오류·Rate Limit Contract 검증 | `deferred_manual` | `not_run` | 승인된 키를 안전하게 로드한 뒤 |
| 14일 관측·발표 지연·Coverage 측정 | `deferred_manual` | `not_run` | 사전 합격 기준·호출 예산·실행환경 승인 뒤 |
| AirKorea 제3유형 파생 설명·Cache·표시 및 위치 관련 조건 확인 | `deferred_manual` | `not_verified` | Gate 2 최종 판정 전 서면 확인 또는 전문 검토 |
| Provider별 장애·누락·시간대·중복 fixture 확보 | `deferred_manual` | `not_run` | Contract smoke와 실제 사건 관찰 시 |

### Production·후속 Phase 검증

- [ ] `planned` 행정안전부 긴급재난문자 제4유형의 상업 서비스 사용 가능 범위 확인 — 별도 이용허락 전 상용 차단
- [ ] `planned` TourAPI item별 이미지 License와 attribution을 런타임에 보존할 방법 확인 — Phase 3 진입 전
- [ ] `planned` VWorld geocoding 결과 저장 금지 조건과 위치 최소화 설계의 양립성 확인 — 외부 지오코더 채택 재심의 시
- [ ] `planned` `NotificationProvider`는 Web Push 표준과 브라우저 권한 정책을 Gate 8에서 별도 검토

## 코드 작성 전 승인 조건

다음 항목이 충족되기 전에는 제품 코드를 작성하지 않는다.

1. Gate 1 가설 중 최소 하나가 실제 인터뷰/관찰로 계속 검증할 가치가 있다고 판단될 것.
2. Decision Log에서 확정한 최종 Phase 1 필수 Provider의 이용조건이 제품 배포 방식과 양립한다고 확인할 것.
3. 인증키 발급 또는 운영계정 신청이 필요하면 사용자에게 먼저 승인을 받을 것.
4. `delayed`, `stale`, 영향 있는 `partial`, `conflicting`, `valid_empty`, `unavailable`, License 차단을 포함한 전체 Fail-closed Matrix를 문서로 합의할 것.
5. 정확한 위치를 저장하지 않는 데이터 흐름을 Gate 3·4 설계에 반영할 것.

## 명시적 승인 없이는 하지 않는 작업

- 원격 Push 또는 PR 생성
- 외부 배포
- 유료 Resource 생성
- 공개 Web Push 발송
- 운영 API 활용신청·Traffic 상향 신청
- Git 전역 설정 또는 PowerShell 실행 정책 변경

## 비코드 준비 완료 내역

1. `done` 수동 작업을 [사용자 수동 작업 체크리스트](./docs/manual-action-checklist.md)로 분리하고 Google Forms를 실제 문제 증거 수집 Trigger까지 유예했다.
2. `done` 인증키 없이 작성 가능한 [Provider 실호출 검증 Runbook](./docs/provider-validation-runbook.md), 증거 형식과 보수적 Canary 호출 예산을 준비했다.
3. `done` 전체 Provider 상태 축과 [Fail-closed 판단 초안](./docs/provider-fail-closed-draft.md)을 맞추고 `draft_not_approved`로 유지했다.
4. `done` [Gate 1·2 비코드 준비 감사](./docs/gate-1-2-readiness-audit.md)에서 상태·근거·Link·단계 경계를 대조했다.

## 현재 다음 Trigger

- 지금 사용자가 수행할 필수 작업은 없다.
- Gate 1을 재개하려면 사용자가 실제 문제 증거 수집을 명시적으로 승인한다. 그때 [수동 작업 체크리스트](./docs/manual-action-checklist.md)의 1단계부터 최소 항목만 안내한다.
- Gate 2를 재개하려면 사용자가 API 실호출을 명시적으로 승인한다. 그때 활용신청·Secret 입력의 최소 항목만 안내한다.
- 둘 중 어느 Trigger도 오지 않으면 Gate 상태와 `not_verified` 증거를 유지하고 제품 코드를 작성하지 않는다.

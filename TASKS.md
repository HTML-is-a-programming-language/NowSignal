# NowSignal AI 작업 목록

- 기준일: 2026-08-05 (Asia/Seoul)
- 현재 단계: Gate 0 완료, Gate 1·2 준비 및 검증 진행 중
- 상태 표기: `done`, `in_progress`, `planned`, `blocked`, `not_verified`
- 근거 원칙: 실행·관찰·인터뷰로 확인하지 않은 결과는 성과로 기록하지 않는다.

## Gate 현황

| Gate | 상태 | 통과 조건 | 현재 증거 | 다음 판단 |
| --- | --- | --- | --- | --- |
| Gate 0 환경 확인 | `done` | 저장소, Git, Node, package manager, 환경변수 이름, 덮어쓰기 위험 확인 | GitHub 공개 저장소·권한 확인, 작업 브랜치 Push와 upstream SHA 일치 검증, Node 및 package manager 버전 확인 | Git·PowerShell의 로컬 제약은 명령별 우회 유지 |
| Gate 1 문제 검증 | `in_progress` | 목표 직무 공고, 사용자 가설, 인터뷰, 기존 대안, 성공 지표를 실제 근거로 검토 | Desk research, 인터뷰 계획, 연구 데이터·Consent Protocol v1.0 | Privacy Preflight와 실제 참여자 Interview 전에는 통과 금지 |
| Gate 2 Public Data Feasibility | `in_progress` | API, License, Traffic, Freshness, Coverage, Failure mode, Adapter 적합성 검증 | 공식 문서 기반 조사표와 Product License Register | 인증키 기반 smoke test 및 이용조건 재확인 전에는 조건부 |
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
- [x] `done` 연구 데이터 최소수집·분리·접근·보관·삭제·철회 기준과 Consent 핵심 문안 v1.0 작성
- [x] `done` 공개 저장소에 연구 원자료가 staging되는 것을 줄이는 `.gitignore` 방어 규칙 추가

### 실제 검증 — 아직 수행하지 않음

- [ ] `blocked` 실제 처리 주체·철회 채널·Interview 도구·private 저장소 보호조치·접근자·삭제 모의 실행을 Privacy Preflight로 확인
- [ ] `not_verified` 참여 동의 후 문제 인터뷰 수행
- [ ] `not_verified` 가명처리된 비공개 Note에 실제 관찰을 기록하고 공개 인용의 별도 승인 여부 확인
- [ ] `not_verified` Raw Data UI 대 Action Brief UI 비교 과제 수행
- [ ] `not_verified` 가설별 evidence count와 반증 사례 정리
- [ ] `not_verified` 문제 지속 여부와 Gate 3 진입 여부 결정

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

### 실제 API·법적 검증 — 아직 수행하지 않음

- [ ] `blocked` API 활용신청 및 인증키 발급 — 사용자의 명시적 승인 필요
- [ ] `not_verified` 각 API의 정상 응답, 오류 응답, Rate Limit을 실제 호출로 확인
- [ ] `not_verified` 관측·발표 지연 분포를 반복 측정해 freshness threshold 결정
- [ ] `not_verified` 행정안전부 긴급재난문자 제4유형의 상업 서비스 사용 가능 범위 확인
- [ ] `not_verified` AirKorea 제3유형 데이터의 파생 설명·Cache·표시 방식 확인
- [ ] `not_verified` TourAPI item별 이미지 License와 attribution을 런타임에 보존할 방법 확인
- [ ] `not_verified` VWorld geocoding 결과 저장 금지 조건과 위치 최소화 설계의 양립성 확인
- [ ] `not_verified` Provider별 장애·누락·시간대·중복 fixture 확보 가능성 확인
- [ ] `planned` `NotificationProvider`는 Web Push 표준과 브라우저 권한 정책을 Gate 8에서 별도 검토

## 코드 작성 전 승인 조건

다음 항목이 충족되기 전에는 제품 코드를 작성하지 않는다.

1. Gate 1 가설 중 최소 하나가 실제 인터뷰/관찰로 계속 검증할 가치가 있다고 판단될 것.
2. 날씨와 대기질 필수 Provider의 이용조건이 제품 배포 방식과 양립한다고 확인할 것.
3. 인증키 발급 또는 운영계정 신청이 필요하면 사용자에게 먼저 승인을 받을 것.
4. stale/conflicting/unavailable 상태의 fail-closed 기준을 문서로 합의할 것.
5. 정확한 위치를 저장하지 않는 데이터 흐름을 Gate 3·4 설계에 반영할 것.

## 명시적 승인 없이는 하지 않는 작업

- 원격 Push 또는 PR 생성
- 외부 배포
- 유료 Resource 생성
- 공개 Web Push 발송
- 운영 API 활용신청·Traffic 상향 신청
- Git 전역 설정 또는 PowerShell 실행 정책 변경

## 다음 작업 제안

1. 실제 처리 주체와 비공개 철회 연락처를 정하고, Interview 도구·처리 위치·private 저장소 암호화·접근권한을 확인한다.
2. 모집 채널·보상·진행자·Pilot 일정을 승인하고 삭제·철회 모의 실행 후 2명 Pilot을 모집한다.
3. API 활용신청 승인 여부를 결정한다. 승인 전에는 문서 조사까지만 유지한다.
4. Gate 1의 실제 문제 증거와 Gate 2의 API smoke test가 확보되면 Gate 3 PRD와 wireframe을 작성한다.

## 제안 커밋 분리

- `문서: 사용자 연구 데이터 처리 기준 확정`
- `문서: 파일럿 인터뷰 운영값과 실행 준비 기록`
- `문서: 공개데이터 API 실호출 검증 기록`

# NowSignal AI 프로젝트 헌장

- 문서 상태: `working_draft`
- 최초 작성일: 2026-08-05
- 최종 갱신일: 2026-08-07
- 현재 Gate: Gate 1 문제 검증·Gate 2 Public Data Feasibility 병행 (`in_progress`)
- 근거 원칙: 실제 조사·인터뷰·실험 결과가 없는 항목은 `hypothesis`, `planned`, `not_verified` 중 하나로 표시한다.

## 1. 프로젝트 정의

NowSignal AI는 사용자의 현재 위치 또는 직접 선택한 지역과 현재 시간에 맞는 공식 공개 데이터를 결합해, 오늘의 행동 시점·준비물·피해야 할 시간·대안을 근거와 함께 제시하는 Proactive Local Intelligence Agent다.

이 정의는 제품 방향에 대한 `hypothesis`이며 사용자 수요가 검증됐다는 뜻이 아니다. 2026-08-05 현재 실제 사용자 인터뷰, Prototype Usability Test, Beta, 운영 지표는 모두 `not_verified`다.

## 2. 해결하려는 문제

초기 문제 진술은 다음과 같다.

> 날씨·대기질·공식 안전정보·주변 상황을 여러 화면에서 확인한 뒤 외출, 운동, 산책, 빨래, 세차 또는 나들이 시간을 정하는 사용자는 정보를 행동 결정으로 바꾸는 데 반복적인 비교와 판단을 해야 할 수 있다.

- 상태: `hypothesis`
- 확인된 사용자 발언: 없음 (`not_verified`)
- 확인된 문제 빈도·심각도: 없음 (`not_verified`)
- 확인 방법: 문제 인터뷰, 현재 대안 관찰, Raw Data UI와 Action Brief UI 비교, 실사용 Beta

## 3. 대상 사용자와 Job-to-be-Done

특정 직업·연령·전문가 집단이 아니라 다음 행동을 실제로 수행하는 일반 사용자를 초기 검증 대상으로 삼는다.

- 날씨나 대기질을 확인한 뒤 외출 시각을 정한다.
- 산책, 달리기, 자전거, 아이와 외출, 반려동물 산책, 빨래 건조, 세차, 야외 촬영 또는 가까운 나들이 시간을 조정한다.
- 공식 특보나 급격한 조건 변화가 있으면 계획을 바꾼다.

핵심 Job-to-be-Done은 `hypothesis`다.

> 오늘 특정 활동을 하려 할 때, 흩어진 최신 정보를 직접 해석하는 부담을 줄이고, 근거를 확인할 수 있는 실행 가능한 시간과 대안을 선택하고 싶다.

대상 사용자 세분화와 우선순위는 [문제 가설](./02-problem-hypotheses.md)과 [사용자 인터뷰 및 모집 계획](./03-user-interviews.md)에서 다루며, 인터뷰 전에는 확정하지 않는다. [목표 직무 분석](./01-target-job-analysis.md)은 사용자 세분화가 아니라 이 프로젝트가 보여줄 직무 역량의 근거다.

## 4. 가치 제안

### 사용자 가치 가설

- `hypothesis`: 회원가입이나 개인 계정 연결 없이 첫 방문에서 지역 기반 Brief를 확인하면 입력 부담이 낮아진다.
- `hypothesis`: 원시 수치보다 활동별 Best Time Window, 피해야 할 시간, 준비물, 대안을 먼저 보여주면 의사결정 시간이 줄어든다.
- `hypothesis`: 출처, 관측·발표 시각, 데이터 상태를 함께 보여주면 사용자가 추천의 적용 가능성을 판단하기 쉬워진다.
- `hypothesis`: 행동에 영향을 주는 큰 변화만 알리면 반복 알림의 불필요함을 줄일 수 있다.
- `hypothesis`: 위치 권한을 거부해도 지역을 직접 선택할 수 있으면 핵심 가치가 유지된다.

### 차별화 가설

NowSignal AI의 의도된 차별화는 단순한 날씨 표시나 LLM 요약이 아니라 다음 순서에 있다.

1. 공식 공개 데이터 수집
2. 일반 코드에 의한 Schema·단위·시간대·좌표·Freshness 검증
3. 일반 TypeScript 코드에 의한 활동별 Score와 Hard Block 계산
4. Agent에 의한 제한된 상관관계 분석·설명·검증
5. 사용자에게 Evidence와 불확실성 표시

이 차별화가 실제 사용자 선택 이유가 되는지는 `not_verified`다.

## 5. 제품 원칙

다음 원칙은 기능보다 우선한다.

1. Value before input
2. No account required
3. Official data before AI
4. Deterministic calculation before language generation
5. Evidence before recommendation
6. Freshness before completeness
7. Fail closed on stale or missing data
8. User-controlled location
9. Minimal notifications
10. No fabricated metrics
11. No safety-critical decision solely by LLM
12. AI must not override official alerts

## 6. 범위

### 초기 제품 범위

- Browser Geolocation과 지역 수동 선택
- 기상 실황·예보, 대기질, 공식 안전정보의 Provider Adapter
- 발표·관측·유효 시각과 데이터 상태 표시
- Today Brief, Activity Timeline, Best Time Windows, Important Changes
- 우산·마스크·옷차림 등 일반적인 준비 안내
- 활동별 Score, Hard Block, 대안
- Evidence Drawer와 Data Freshness
- 로그인 없는 사용
- 사용자가 명시적으로 동의한 경우에만 Web Push

구현 및 검증 상태는 현재 `not_verified`다.

### 명시적 제외 범위

- Gmail·이메일·Google Calendar·연락처 연동
- 사용자 문서·사진·PDF 업로드
- 금융계좌, 문자, 카카오톡, 브라우저 전체 기록 수집
- Desktop 전체 제어 또는 다른 계정 데이터 수집
- 의학적 진단, 치료·약 복용 조언, 개인별 안전 단정
- LLM이 날씨·대기질·활동 점수 또는 공식 경보를 임의로 변경하는 기능
- 광고용 위치 Profile과 이동 경로 생성
- 초기 단계의 LangGraph, Temporal, Vector DB, RAG 기본 도입

RAG·Vector DB·Durable Workflow Framework는 실제 요구가 관찰되고 ADR이 승인되기 전까지 제외한다.

## 7. 성공 지표 정의

아래는 지표의 정의와 측정 계획이다. 현재 값과 Baseline은 모두 `not_verified`이며, 목표값은 Baseline 관찰 전까지 확정하지 않는다.

| 지표 | 정의 | 측정 방법 | 현재 상태 |
| --- | --- | --- | --- |
| `first_value_without_account_rate` | 회원가입 없이 유효한 첫 Brief를 본 세션 / 유효한 첫 방문 세션 | 익명 세션 이벤트. 정확한 좌표는 Analytics에 포함하지 않음 | `not_verified` |
| `decision_task_completion_rate` | 정해진 과제에서 활동 시각 또는 대안을 선택한 과제 / 유효 과제 | Moderated Usability Test의 과제 기록과 사전 정의 Rubric | `not_verified` |
| `decision_time_seconds` | 과제 제시부터 사용자가 선택을 확정할 때까지의 시간 | Raw Data UI와 Action Brief UI를 순서 균형화해 측정하고 중앙값·분포 보고 | `not_verified` |
| `recommendation_action_rate` | 노출된 추천 중 사용자가 실행 또는 계획 반영으로 표시한 추천 / 피드백 가능한 추천 | Beta의 선택적 피드백. 자기보고임을 함께 기록 | `not_verified` |
| `evidence_check_rate` | Evidence Drawer를 연 추천 / Evidence를 제공한 추천 | 제품 이벤트. 높거나 낮음 자체를 성공으로 단정하지 않고 신뢰·이해도 인터뷰와 함께 해석 | `not_verified` |
| `user_correction_rate` | 사용자가 사실 또는 추천 오류로 표시한 Brief / 피드백된 Brief | 오류 유형과 원본 Provider snapshot을 함께 검토 | `not_verified` |
| `unsupported_claim_rate` | 근거 필드로 추적할 수 없는 사실 주장 / 검토한 사실 주장 | 고정 Eval dataset과 사람 검토 Rubric | `not_verified` |
| `data_freshness_compliance` | Provider별 유효시간 정책을 충족한 출력 / 검사한 출력 | 자동 Eval과 Trace의 `observedAt`, `fetchedAt`, `validUntil` 검사 | `not_verified` |
| `official_alert_preservation_rate` | 공식 원문·기관·시각·지역·지침을 변형 없이 보존한 경보 / 검사한 공식 경보 | Fixture 비교와 화면 순서 Test | `not_verified` |
| `alert_precision` | 사용자 행동에 영향을 준 것으로 확인된 알림 / 전송된 알림 | Beta 피드백과 사전 정의 Alert Policy 판정. 자기보고 한계 기록 | `not_verified` |
| `alert_recall` | 사전 정의된 알림 필요 변화 중 실제 알림된 변화 / 알림 필요 변화 | 역사·합성 시나리오 Backtest | `not_verified` |
| `duplicate_notification_rate` | Deduplication key와 유효기간이 같은 중복 알림 / 전송된 알림 | Notification log의 익명 식별자와 정책 버전 검사 | `not_verified` |
| `location_denial_task_completion_rate` | 위치 권한을 거부한 뒤 지역 수동 선택으로 핵심 과제를 끝낸 참여자 / 해당 과제를 받은 참여자 | Playwright와 Usability Test | `not_verified` |
| `average_latency` | 요청 시작부터 표시 가능한 Brief 응답까지의 시간 | Server trace로 p50·p95를 분리 보고 | `not_verified` |
| `cost_per_brief` | 측정 기간의 Provider·모델·인프라 변동비 / 생성된 유효 Brief | 비용 원장과 Trace ID 결합. 무료 한도도 별도 표기 | `not_verified` |

### 지표 해석 원칙

- 목표값은 실제 Baseline과 위험 수준을 확인한 후 Decision Log에 기록한다.
- 평균만 보고하지 않고 표본 수, 기간, p50·p95 또는 분포, 누락·제외 기준을 함께 남긴다.
- 인터뷰 진술, Prototype 행동, Beta 행동, 역사 데이터 Backtest를 서로 대체 가능한 증거로 취급하지 않는다.
- Analytics에는 정확한 위도·경도, 이동 경로, 자유서술 원문을 보내지 않는다.
- 실행하지 않은 측정은 `not_verified`로 유지한다.

## 8. 검증 단계와 Gate 1 종료 조건

Gate 1 문서 작업은 다음 조건을 충족하면 완료 후보가 된다. 이는 제품 문제의 검증 완료가 아니라 검증 준비 완료를 뜻한다.

- 목표 직무 공고의 1차 출처, 확인일, 요구 역량, 프로젝트 연결과 Gap이 기록돼 있다.
- 사용자·문제·가치 가설이 반증 가능한 형태로 기록돼 있다.
- 현재 대안과 전환 비용을 확인할 질문이 준비돼 있다.
- 참여자 모집 기준, 동의 방식, 인터뷰 Script, 기록 Schema가 준비돼 있다.
- 성공 지표의 분자·분모 또는 계산 방식, 데이터 출처, 해석 한계가 정의돼 있다.
- 실제 인터뷰 수, 사용자 반응, 만족도, 제품 성과는 아직 `not_verified`로 표시돼 있다.

인터뷰 실행 전에는 Gate 1을 “문제 검증 완료”라고 부르지 않는다.

## 9. 중단·축소·전환 조건

다음 조건은 `planned` 검토 조건이며 발생 사실이 아니다.

- 참여자가 현재 대안으로 충분히 빠르고 확신 있게 결정하며 통합 Brief의 추가 가치를 설명하지 못한다.
- 데이터 Freshness·License·Coverage 제약으로 핵심 활동의 안전한 시간 추천을 지속적으로 생성할 수 없다.
- 위치정보 최소화와 No account 원칙을 지키면서 핵심 경험을 제공할 수 없다.
- Action Brief가 Raw Data UI보다 결정 품질 또는 시간을 개선하지 못하거나 오히려 과신을 유발한다.
- Minimal notifications 정책으로 유용한 변화를 포착할 수 없거나 알림 피로가 반복 관찰된다.

이 경우 범위를 특정 활동·지역·시간대로 축소하거나, “추천” 대신 검증된 정보 비교 도구로 전환한다.

## 10. 증거 상태와 변경 규칙

- `hypothesis`: 검증할 주장
- `planned`: 실행하기로 한 조사·실험·구현
- `not_verified`: 아직 증거가 없는 상태
- `insufficient_evidence`: 일부 자료는 있으나 결론을 내리기 부족함
- `validated`: 사전 정의한 방법과 기준을 충족한 실제 증거가 있음
- `rejected`: 실제 증거가 가설을 지지하지 않음

`validated` 또는 `rejected`로 변경할 때는 날짜, 표본, 방법, 원자료 위치, 분석 한계, 변경한 제품 결정을 함께 기록한다.

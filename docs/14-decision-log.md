# Decision Log

- 기준일: 2026-08-05 (Asia/Seoul)
- 상태: 초기 결정. 구현·사용자 검증 결과에 따라 재검토한다.
- 원칙: 이 문서는 선택의 이유와 포기한 장점을 함께 남긴다. `planned` 또는 `not_verified`인 선택은 확정 성과가 아니다.

## DL-001 — 프로젝트 주제

- 날짜: 2026-08-05
- 상황: 자료 업로드나 개인 계정 연결 없이 첫 방문에서 가치를 제공하는 AI-Native 일반 사용자 제품이 필요하다.
- 선택지: 범용 챗봇, 개인 계정 연동형 assistant, 단순 날씨 dashboard, 공식 공개데이터 기반 local intelligence agent.
- 선택: `NowSignal AI`, 즉 공식 공개데이터에 근거해 오늘의 행동 시간과 준비를 안내하는 Proactive Local Intelligence Agent.
- 선택 이유: 입력 전 가치, 검증 가능한 외부 사실, 결정 지원이라는 세 요구를 동시에 시험할 수 있다.
- 장점: 출처·freshness·오류를 제품 경험에 직접 연결할 수 있고 실제 행동 결정으로 가치 가설을 검증할 수 있다.
- 단점: 여러 Provider의 품질과 License에 의존하며 지역·시간 정규화가 어렵다.
- 포기한 장점: 계정 연동에서 얻는 높은 개인화와 범용 대화 인터페이스의 넓은 질의 범위.
- 위험: 사용자가 이미 날씨 앱으로 충분하다고 느낄 수 있다.
- 검증 방법: 문제 인터뷰, 대안 관찰, Raw Data UI와 Action Brief UI 비교, 역사 데이터 backtest.
- 재검토 조건: 실제 인터뷰에서 행동 시간 결정 문제가 반복적으로 관찰되지 않거나 공식 데이터로 핵심 결정을 지원할 수 없을 때.
- 관련 코드·문서: `docs/00-project-charter.md`, `docs/02-problem-hypotheses.md`

## DL-002 — 로그인 없는 기본 사용

- 날짜: 2026-08-05
- 상황: 첫 가치 확인 전에 회원가입을 요구하면 zero-input 원칙과 충돌한다.
- 선택지: 필수 계정, anonymous session 후 선택 계정, 완전한 local-only 사용.
- 선택: 기본 브리핑은 계정 없이 제공하고, 초기 범위에서는 개인 계정 연동을 제외한다.
- 선택 이유: 입력·동의 비용을 최소화하고 공개데이터만으로 가치가 있는지 먼저 검증하기 위함이다.
- 장점: onboarding 마찰과 수집 개인정보가 줄어든다.
- 단점: 기기 간 동기화, 장기 개인화, subscription 복구가 제한된다.
- 포기한 장점: 계정 기반 이력과 cross-device preference.
- 위험: local storage 삭제 시 설정과 피드백 상태가 사라질 수 있다.
- 검증 방법: 첫 브리핑 도달률, 위치 거부 후 지역 선택 완료율, 계정 요구 없이 수행 가능한 usability task.
- 재검토 조건: 실제 beta에서 기기 간 동기화가 핵심 이탈 원인으로 확인될 때만 선택 계정을 별도 ADR로 검토한다.
- 관련 코드·문서: `docs/00-project-charter.md`, `docs/03-user-interviews.md`

## DL-003 — 사용자 제어 위치와 최소화

- 날짜: 2026-08-05
- 상황: 지역 기반 정보에는 위치가 필요하지만 정확한 이동 정보를 장기 저장할 이유는 없다.
- 선택지: 정확한 GPS 상시 저장, 요청 시 GPS 사용 후 grid/행정구역 축소, 수동 지역만 지원.
- 선택: 브라우저 동의 시 일회성 위치를 사용하고 서버 경계 전에 기상 grid 또는 행정구역 수준으로 축소한다. 거부 시 수동 지역 선택을 동일 기능으로 제공한다.
- 선택 이유: 기능에 필요한 최소 정밀도와 사용자 통제를 함께 확보한다.
- 장점: 장기 위치 추적 위험과 analytics 유출 위험을 낮춘다.
- 단점: 경계 지역의 측정소·행정구역 선택이 부정확할 수 있다.
- 포기한 장점: 이동 경로 기반 자동 전환과 초정밀 주변 추천.
- 위험: geocoding 결과 저장 제한, 좌표 경계, 브라우저 권한 차이가 설계를 복잡하게 한다.
- 검증 방법: 위치 미동의 journey, 좌표 경계 test, network payload와 analytics event의 정밀 좌표 부재 확인.
- 재검토 조건: grid 수준으로 핵심 품질을 낼 수 없다는 측정 증거가 있을 때만 더 높은 정밀도를 별도 동의와 함께 검토한다.
- 관련 코드·문서: `docs/12-location-privacy.md` (`planned`), `docs/09-public-data-catalog.md`

## DL-004 — LLM과 일반 코드의 경계

- 날짜: 2026-08-05
- 상황: 날씨·대기질 수치와 공식 경보를 LLM이 계산하거나 바꾸면 재현성과 안전성이 약해진다.
- 선택지: LLM 중심 계산, 규칙/코드 중심 계산 후 LLM 설명, LLM 완전 제외.
- 선택: fetch, schema validation, normalization, freshness, conflict detection, score와 hard block은 deterministic TypeScript로 처리한다. LLM은 구조화된 사실과 점수를 설명하며 값을 변경하지 못한다.
- 선택 이유: 계산을 testable하고 versioned하게 유지하면서 자연어 설명의 효용만 검증하기 위함이다.
- 장점: 재현성, auditability, fail-closed test가 가능하다.
- 단점: 활동별 규칙을 직접 설계하고 보정해야 한다.
- 포기한 장점: LLM이 새로운 상황을 즉시 유연하게 해석하는 범위.
- 위험: 규칙이 과도하게 단순하거나 지역 맥락을 놓칠 수 있다.
- 검증 방법: activity score unit test, LLM malformed output guardrail test, unsupported claim eval.
- 재검토 조건: deterministic feature로 표현할 수 없는 반복적 사용자 요구가 실제 증거로 나타날 때.
- 관련 코드·문서: `docs/08-agent-workflow.md` (`planned`), `docs/10-data-normalization.md` (`planned`)

## DL-005 — 초기 workflow 및 retrieval 범위

- 날짜: 2026-08-05
- 상황: 초기 분석 Run은 짧고 공식 API 응답과 작은 상태로 구성될 예정이다.
- 선택지: Cron/Queue/PostgreSQL, LangGraph, Temporal, RAG/Vector DB.
- 선택: 초기에는 Cron·Queue·PostgreSQL 상태를 사용하고 LangGraph, Temporal, RAG, Vector DB를 도입하지 않는다.
- 선택 이유: 현재 요구에는 durable human approval이나 장시간 replay, 비정형 문서 검색이 확인되지 않았다.
- 장점: 의존성·운영비·failure surface가 작다.
- 단점: 복잡한 재개·backfill 요구가 생기면 재설계 비용이 든다.
- 포기한 장점: graph 시각화, durable replay, semantic retrieval의 사전 확보.
- 위험: 알림 pipeline이 예상보다 장시간·다단계가 될 수 있다.
- 검증 방법: 실제 Run latency, retry, idempotency, queue backlog를 측정한다.
- 재검토 조건: 장시간 실행, 세밀한 재개, 복잡한 승인, 대규모 비정형 지식 검색이 실제 요구로 확인될 때.
- 관련 코드·문서: `docs/07-system-architecture.md` (`planned`), `docs/08-agent-workflow.md` (`planned`)

## DL-006 — 공식 경보와 제한적 License 데이터 표시

- 날짜: 2026-08-05
- 상황: 공식 안전 메시지는 의미 변경이 위험하며 일부 데이터는 변경금지·상업적 이용금지 조건을 가진다.
- 선택지: AI 요약만 표시, AI 요약 후 원문, 공식 원문 우선 후 분리된 부가 설명, 해당 Provider 제외.
- 선택: 공식 원문·기관·시각·지역·공식 행동지침을 먼저 표시하고 AI 설명은 명확히 분리한다. License가 제품 배포와 양립하지 않으면 해당 Provider를 기본 제품에서 제외한다.
- 선택 이유: 공식 경보 보존과 License 준수를 기능 완성도보다 우선하기 위함이다.
- 장점: 원문 보존과 source attribution을 명확히 검증할 수 있다.
- 단점: 화면이 길어지고 특정 안전 데이터가 제품에서 제외될 수 있다.
- 포기한 장점: 간결한 단일 문장 브리핑.
- 위험: 행정안전부 긴급재난문자 제4유형은 상업적 제품과 충돌할 가능성이 있어 현재 `not_verified`다.
- 검증 방법: Product License Register 검토, 공식 기관 문의 또는 법률 검토, official-alert preservation eval.
- 재검토 조건: 이용조건 변경 또는 공식적인 별도 이용허락 확보 시.
- 관련 코드·문서: `docs/product-license-register.md`, `docs/09-public-data-catalog.md`, `docs/11-alert-policy.md` (`planned`)

## DL-007 — 공개데이터 Provider 선택 상태

- 날짜: 2026-08-05
- 상황: Phase 1과 이후 단계에 Weather, AirQuality, SafetyAlert, LocalEvent, Geocoding Provider가 필요하다.
- 선택지: 단일 상업 API, 여러 비공식 source, 기관별 공식 API.
- 선택: 기상청, 한국환경공단 AirKorea, 행정안전부, 한국관광공사 TourAPI, 국토교통부 VWorld를 **후보 Provider**로 둔다. 이는 구현 확정이 아니라 Gate 2 검증 대상이다.
- 선택 이유: 공식 source와 attribution을 우선하면서 각 domain의 authoritative source를 분리하기 위함이다.
- 장점: source provenance와 domain별 failure를 분명히 표시할 수 있다.
- 단점: 인증, quota, schema, License가 서로 달라 adapter와 운영이 복잡하다.
- 포기한 장점: 단일 API 계약과 통합 quota.
- 위험: 제3·제4유형 License, 결과 저장 제한, 운영계정 심의, 장애 시 데이터 공백.
- 검증 방법: 공식 문서 확인, 사용자 승인 후 API contract smoke test, License 재확인, Provider별 장애 fixture.
- 재검토 조건: 상업적 이용 불가, 필수 freshness 미달, 전국 coverage 부족, 운영 quota 확보 실패 시.
- 관련 코드·문서: `docs/09-public-data-catalog.md`, `docs/product-license-register.md`

## DL-008 — 사용자 연구 데이터의 최소 수집과 기한부 보관

- 날짜: 2026-08-05
- 상황: 실제 참여자 모집 전에 공개 Git 저장소와 OneDrive 작업공간으로 연락처·동의 증빙·참여자별 Note가 유입되지 않도록 저장·접근·보관·삭제·철회 기준을 정해야 한다.
- 선택지: 녹음과 원문을 장기 보관, 별도 동의 녹음과 가명처리 Note를 기한부 보관, Pilot에서 녹음 없이 최소 구조화 Note만 보관.
- 선택: Pilot은 녹음·화면 Capture 없이 구조화 Note만 작성한다. 원자료는 공개 저장소·OneDrive·LLM·자동 전사 도구에서 제외하고 보호조치를 확인한 별도 private 저장소에 유형별로 분리한다. 기본 접근자는 프로젝트 책임자 1명이다. 불적격 Screening은 7일, 연락처·ID 연결표는 Interview·보상 종료 후 14일, 후속 연락 목록은 최대 90일, 참여자별 Note·Consent는 Interview 후 90일 또는 Gate 1 결정 후 30일 중 먼저 도래한 때 삭제한다. 공개 인용은 정확한 문구·맥락·채널을 제시한 별도 승인 없이는 사용하지 않는다.
- 선택 이유: 작은 표본의 지역·활동·시각 조합도 재식별될 수 있으므로 원문 재검토 편의보다 최소수집, 공개 저장소 노출 방지와 실질적인 철회 이행 가능성을 우선한다.
- 장점: 수집·보유 범위와 사고 영향이 작아지고, 참여자가 선택 동의와 철회 범위를 이해하기 쉬우며, 가상의 익명성을 주장하지 않는다.
- 단점: 녹음 없이 작성한 Note는 축어 재확인과 독립 Coding의 재현성이 낮고, 연결키 파기 후에는 특정 참여자의 삭제 요청을 집계 결과에 반영할 수 없다.
- 포기한 장점: 음성·원문 장기 보관에서 얻는 높은 분석 재현성과 사후 직접 인용 후보 탐색.
- 위험: 장치 암호화·ACL을 확인하지 않은 private 경로, Interview 도구의 외부·국외 처리, 우발적 화면 노출, Backup 사본과 작은 소집단의 간접 식별 위험이 남는다. 실제 처리 주체와 철회 연락처도 아직 운영값이 정해지지 않았다.
- 검증 방법: 첫 참여자 모집 전 실제 처리 주체·도구·처리 위치·접근자·저장소 보호조치를 기록하고, 가상 데이터로 삭제·철회 모의 실행과 Git ignore/staging 검사를 수행한다.
- 재검토 조건: Main Interview에서 음성 확인 필요성이 증거로 나타나거나, 연구자가 늘거나, 저장·회의 도구·법적 요구·연구 범위가 달라질 때.
- 관련 코드·문서: `docs/03-user-interviews.md`, `TASKS.md`, `.gitignore`

## 다음 Decision Log 예정 항목

- 활동별 score 공식과 algorithm version
- Agent 수와 역할, model routing
- Cache TTL과 stale threshold
- 알림 영향도·deduplication 기준
- UI Library와 evidence-first information architecture
- 배포 구조와 observability 경계
- 외부 오픈소스의 도입·제외 판단

# 목표 직무 공고 분석

- 문서 상태: `working_draft`
- 최초 작성일: 2026-08-05
- 최종 갱신일: 2026-08-05
- 조사 기준일: 2026-08-05 (Asia/Seoul)
- 표본 범위: 회사 공식 Careers 페이지 또는 공식 Careers 페이지에서 연결한 ATS의 현재 접근 가능한 대표 공고 3건

## 1. 목적과 해석 한계

이 문서는 NowSignal AI가 포트폴리오로 증명하려는 역량을 현재 공개된 목표 직무의 요구와 연결한다. 검색 포털, 채용 요약 사이트, 블로그의 재게시 글은 근거로 사용하지 않는다.

현재 표본은 3건뿐이며 회사·지역·직급이 서로 다르다. 따라서 아래 내용은 시장 전체의 채용 경향이나 채용 가능성을 증명하지 않는다. 공고 원문에서 확인한 내용은 `verified_primary_source`, 프로젝트와의 연결 해석은 `hypothesis`, 아직 구현·운영 증거가 없는 역량은 `not_verified`로 구분한다.

## 2. 목표 역할 가설

NowSignal AI가 우선 연결할 목표 역할은 다음과 같다.

| 역할 | 포트폴리오에서 보여줄 문제 | 상태 |
| --- | --- | --- |
| AI-Native Product Engineer | 모호한 사용자 문제를 데이터·Agent·UI가 결합된 제품으로 정의하고 end-to-end로 전달 | `hypothesis` |
| AI Agent Engineer | Tool 경계, Schema, Trace, Eval, Guardrail을 갖춘 제한된 Agent workflow 설계 | `hypothesis` |
| Data Engineer | 공식 공개 데이터의 Fetch, Validation, Normalization, Freshness, 실패 복구 | `hypothesis` |
| Evaluation Engineer | 제품·Agent 품질을 반증 가능한 지표, dataset, scenario, regression으로 운영 | `hypothesis` |
| Privacy Engineer | 위치정보 최소화, 보존·삭제, 목적 제한, Audit 가능한 데이터 흐름 | `hypothesis` |
| Tech Lead | 선택지와 Trade-off를 ADR로 남기고 제품·데이터·안전 경계를 일관되게 운영 | `hypothesis` |

Privacy Engineer, QA Engineer, UX Engineer, Technical Writer 역량도 프로젝트에 필요하지만, 이번 3건 표본만으로 별도 목표 직무 수요를 주장하지 않는다 (`not_verified`).

## 3. 확인한 공식 공고

### 3.1 Toss — AI Engineer (Platform)

- 공고 URL: [Toss Careers — AI Engineer (Platform)](https://toss.im/career/job-detail?job_id=7646941003)
- 확인일: 2026-08-05
- 접근 상태: 공고 본문과 지원 진입점 확인 (`verified_primary_source`)
- 소속·고용형태: Toss, 정규직 (`verified_primary_source`)

공고에서 확인한 요구 역량을 요약하면 다음과 같다.

- LLM, RAG, Agent를 실제 문제에 적용하고 Prompt·Tool·Context 구성 기반을 설계하는 역량
- 실험 단계의 Agent를 안정적인 serving·운영 흐름으로 정리하는 역량
- Agent 성능과 품질을 정량 평가하는 기반을 만드는 역량
- 구조화되지 않은 문제를 시스템 문제로 정의하고 여러 팀이 재사용할 플랫폼과 일관된 사용자 경험으로 만드는 역량
- 다양한 LLM Provider 선택·운영, 장애·성능·리소스 최적화 경험

NowSignal AI와의 연결은 다음과 같다 (`hypothesis`).

- 제한된 Tool과 Zod Schema를 가진 Agent, deterministic scoring과 LLM 설명의 경계
- Trace 기반 Verification, scenario Eval, malformed output·Tool failure Guardrail
- Provider Adapter와 실패·Freshness 상태를 숨기지 않는 사용자 경험
- 기능 목적, 설계 선택, 측정 결과를 코드·Test·Decision Log로 연결하는 포트폴리오

현재 Gap은 다음과 같다.

- 실제 production serving, 다중 팀 플랫폼화, 치명적 장애 대응, 성능·비용 최적화 결과는 `not_verified`다.
- 다중 LLM Provider routing은 설계·운영 증거가 없다 (`not_verified`).
- RAG·Vector Search는 초기 제품 문제에 필요하다는 근거가 없으므로 의도적으로 제외한다. 공고 Keyword를 맞추기 위해 도입하지 않고, 제외 이유와 재검토 조건을 ADR로 증명한다 (`planned`).

### 3.2 OpenAI — Product Engineer, Enterprise AI Platform

- 공고 URL: [OpenAI Careers — Product Engineer, Enterprise AI Platform](https://openai.com/careers/product-engineer-enterprise-ai-platform-san-francisco/)
- 확인일: 2026-08-05
- 접근 상태: OpenAI Careers의 공고 본문과 지원 진입점 확인 (`verified_primary_source`)
- 조직·근무지: Finance, San Francisco (`verified_primary_source`)

공고에서 확인한 요구 역량을 요약하면 다음과 같다.

- 사용자와 직접 문제를 발견한 뒤 UX, frontend, backend service, data model, workflow, integration, rollout, 측정, production support까지 end-to-end로 소유하는 역량
- React·TypeScript interface, Python service·API, relational database를 넘나드는 product engineering 역량
- Retry, idempotency, human approval, audit log, observability, replay, backfill을 포함한 durable·agentic workflow 설계
- AI model·Tool·Agent가 실제 가치를 만드는 곳에만 적용하고 validation, evaluation, human review, operational safeguard를 두는 판단
- Testing, monitoring, incident response, security review를 통한 production 품질과 재사용 가능한 component 설계

NowSignal AI와의 연결은 다음과 같다 (`hypothesis`).

- 문제 Interview에서 시작해 PWA UX, Provider API, PostgreSQL state, Agent workflow, Eval까지 연결하는 end-to-end 범위
- React·TypeScript 기반 Today Brief와 Evidence Drawer, 일반 코드와 Agent의 명시적 경계
- Queue의 Retry·idempotency, Trace·observability, human-readable failure state, Alert deduplication
- AI를 모든 단계에 넣지 않고 데이터 Validation·Score를 deterministic code에 남기는 제품 판단

현재 Gap은 다음과 같다.

- 공고는 5년 이상의 professional software engineering과 production software 이력을 요구한다. 이 개인 프로젝트만으로 해당 경력 요건을 충족했다고 주장할 수 없다 (`not_verified`).
- 실제 rollout, production support, incident response, 여러 내부 system integration 결과는 없다 (`not_verified`).
- 공고가 다루는 Python·Temporal·enterprise system integration은 초기 프로젝트의 TypeScript·짧은 Cron/Queue Run 범위와 다르다. 실제 장기 실행 요구가 나타나기 전에는 Temporal을 Keyword 목적으로 도입하지 않는다 (`planned`).
- 실제 사용자 discovery, 측정 개선, 재사용 가능한 component 증거는 앞으로 실행해야 한다 (`not_verified`).

### 3.3 Anthropic — Research Engineer, Model Evaluations

- 회사 공식 목록: [Anthropic Careers — Jobs](https://www.anthropic.com/careers/jobs?lang=us)
- 공고 URL: [Anthropic 공식 ATS — Research Engineer, Model Evaluations](https://job-boards.greenhouse.io/anthropic/jobs/5198255008)
- 확인일: 2026-08-05
- 접근 상태: Anthropic Careers에서 연결된 현재 공고 본문과 지원 Form 확인 (`verified_primary_source`)
- 근무지: Remote-Friendly(출장 필요), San Francisco 또는 New York City (`verified_primary_source`)

공고에서 확인한 요구 역량을 요약하면 다음과 같다.

- 모호한 AI capability를 명확하고 방어 가능한 metric과 evaluation task로 변환하는 역량
- reasoning, agentic behavior, knowledge, safety에 대한 Eval 설계·실행
- 신뢰성 있는 Eval execution infrastructure, dashboard, observability, experiment tracking
- 이상 결과가 모델·harness·data·infrastructure 중 어디서 발생했는지 진단하는 역량
- dataset sourcing·curation·processing, 통계와 실험 설계, 비전문가에게 결과를 설명하는 역량

NowSignal AI와의 연결은 다음과 같다 (`hypothesis`).

- Unsupported claim, Source attribution, Freshness, Conflict detection, Official alert preservation을 명시적 metric으로 정의
- 역사 데이터와 합성 scenario의 분리, deterministic scorer와 사람 Rubric의 경계
- Agent prompt·Tool·model 변경에 따른 regression, Trace 기반 원인 분석
- Eval 결과와 한계를 이해 가능한 문서·dashboard로 연결

현재 Gap은 다음과 같다.

- 분산 Eval infrastructure, live training checkpoint, 대규모 model health monitoring 경험은 `not_verified`다.
- 공고는 Python과 모델 capability Eval을 중심으로 하지만 초기 프로젝트는 TypeScript와 제품 행동·데이터 신뢰성 Eval을 중심으로 한다. 이 차이는 숨기지 않는다.
- 통계적 검정, inter-rater reliability, 충분한 dataset 규모는 설계·실행 전이므로 `not_verified`다.

## 4. 제한된 표본에서 관찰한 연결 주제

다음은 3건 표본 안에서의 해석일 뿐 시장 통계가 아니다 (`limited_sample`, `not_market_claim`).

- 기술 Keyword 자체보다 문제 정의, architecture 선택 근거, end-to-end ownership을 설명할 증거가 중요하게 나타난다.
- Agent·AI 기능은 Eval, observability, 운영 안정성, data pipeline과 분리해서 보여주기 어렵다.
- 제품 품질을 숫자로 말하려면 metric 정의, 실행 infrastructure, 원인 진단, 실제 운영 맥락이 함께 필요하다.
- 안전·권한 요구는 validation, human review, audit log, observability 같은 실행 가능한 control과 함께 다뤄진다.
- 대규모 production·distributed system 경험은 현재 개인 프로젝트만으로 대체할 수 없는 명확한 Gap이다.

## 5. 포트폴리오 증거 계획

아래 결과물은 모두 `planned`이며 실제 파일·Test·Trace가 만들어지기 전에는 성취로 주장하지 않는다.

| 역량 | 만들 증거 | 합격 증거 조건 | 현재 상태 |
| --- | --- | --- | --- |
| 문제 정의 | 인터뷰 원자료, 가설 변경 이력, PRD | 실제 참여자·방법·반증 결과와 제품 결정이 연결됨 | `not_verified` |
| Agent engineering | Zod I/O, Tool allowlist, Trace, timeout·cost limit, Guardrail Test | 실패 scenario를 포함한 실행 가능한 Test와 Trace | `not_verified` |
| Data engineering | Provider contract, Normalization, Freshness, Cache, Retry | contract·failure·stale·conflict Test와 관측 가능한 상태 | `not_verified` |
| Evaluation | dataset, scenario, scorer, result report | 실행 명령, sample count, version, 실제 결과와 한계 | `not_verified` |
| Privacy engineering | data inventory, flow, retention·deletion control, location minimization Test | 정확한 좌표 비보존과 삭제·철회가 코드·Test로 추적됨 | `not_verified` |
| Tech leadership | ADR, Trade-off, risk register, 재검토 조건 | 선택하지 않은 대안과 포기한 장점까지 기록 | `not_verified` |
| Product engineering | PWA UX, Evidence Drawer, error/freshness UI | E2E Test와 실제 Usability 결과가 연결됨 | `not_verified` |

## 6. 후속 공고 조사 계획

현재 3건으로 직무 분석을 확정하지 않는다. 다음 조사는 `planned`다.

### 수집 목표

- 동일한 시점에 접근 가능한 공식 공고 최소 12건을 작업 표본으로 만든다. 이 숫자는 조사 운영을 위한 계획값이며 시장 규모가 아니다.
- AI-Native Product/Agent, Data/ML Platform, Evaluation/QA, Privacy/Security 역할을 각각 포함한다.
- 한국 근무 공고와 글로벌 공고를 분리해 location·seniority 차이를 해석한다.
- 같은 회사의 유사 공고가 표본을 지배하지 않도록 회사별 비중을 기록한다.

### 포함·제외 규칙

- 포함: 회사 공식 Careers 도메인 또는 해당 페이지가 직접 연결한 ATS에서 본문과 현재 지원 진입점을 확인할 수 있는 공고
- 제외: 검색 결과 snippet만 있는 공고, 채용 포털 재게시, 개인 블로그 요약, 종료·오류 페이지, 로그인 없이는 본문을 확인할 수 없는 페이지
- 동적 페이지로 본문을 검증할 수 없으면 URL만 `not_verified` 후보 목록에 남기고 역량 분석에는 포함하지 않는다.
- 각 공고에 회사, 직무명, URL, 확인일, 근무지, seniority, 필수·우대 역량, 운영 책임, Eval·Privacy 요구, 프로젝트 연결, Gap을 기록한다.

### 분석 방법

1. 공고 원문에서 요구 역량을 문장 단위로 coding한다.
2. `product`, `agent`, `data`, `eval`, `reliability`, `privacy`, `leadership`, `communication` theme으로 분류한다.
3. 명시적 요구와 분석자의 추론을 분리한다.
4. 역할·지역·seniority별 빈도를 분리하고 작은 표본 수를 항상 함께 표기한다.
5. 공고 재확인일을 기록하고 삭제·변경된 공고는 역사적 snapshot으로 오인하지 않도록 `closed_or_changed`로 표시한다.
6. 프로젝트 범위와 무관한 기술은 Keyword 채우기 목적으로 도입하지 않고 Gap 또는 제외 근거로 남긴다.

### 갱신 주기

- Gate 3 시작 전 1회 재확인 (`planned`)
- Portfolio Gate 시작 전 전체 URL과 공고 상태 재확인 (`planned`)
- 이력서 문구 작성 시 해당 주장과 연결된 공고·프로젝트 증거가 여전히 유효한지 재검토 (`planned`)

## 7. 현재 결론

- 3건의 1차 출처 공고는 접근해 요구 역량을 확인했다 (`verified_primary_source`).
- NowSignal AI가 이 역량을 실제로 증명했다는 결론은 아직 없다 (`not_verified`).
- 현재 가장 큰 공통 증거 Gap은 production 운영, 규모, 실제 장애 대응, 실제 사용자 결과, 실행된 Eval 수치다.
- 따라서 다음 단계의 목적은 기술 목록을 늘리는 것이 아니라 사용자 문제에서 시작해 architecture, reliability, evaluation, privacy, 측정 결과를 추적 가능한 증거로 만드는 것이다 (`planned`).

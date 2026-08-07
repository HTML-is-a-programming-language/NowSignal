# Decision Log

- 최초 기준일: 2026-08-05 (Asia/Seoul)
- 최종 갱신일: 2026-08-07
- 상태: 초기 결정. 구현·사용자 검증 결과에 따라 재검토한다.
- 원칙: 이 문서는 선택의 이유와 포기한 장점을 함께 남긴다. `planned` 또는 `not_verified`인 선택은 확정 성과가 아니다.
- 경로 표기: 뒤에 `planned`가 붙은 경로는 아직 파일이 없는 예정 산출물이며 현재 Markdown Link가 아니다.

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
- 검증 방법: 창업자 문제 기록, Provider 실검증, 후속 문제 인터뷰, Raw Data UI와 Action Brief UI 비교, 역사 데이터 backtest.
- 재검토 조건: 창업자 경험의 핵심 문제를 공식 데이터로 지원할 수 없거나 후속 외부 검증에서 반복 문제와 제품 가치가 반증될 때.
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
- 위험: 행정안전부 긴급재난문자는 제3·제4유형 표시가 충돌하며 현재 엄격 해석상 `blocked_for_commercial`이다. 별도 이용허락 전에는 호출·구현·활성화하지 않는다.
- 검증 방법: Product License Register 검토, 공식 기관 문의 또는 법률 검토, official-alert preservation eval.
- 재검토 조건: 이용조건 변경 또는 공식적인 별도 이용허락 확보 시.
- 관련 코드·문서: `docs/product-license-register.md`, `docs/09-public-data-catalog.md`, `docs/11-alert-policy.md` (`planned`)

## DL-007 — 공개데이터 Provider 선택 상태

- 상태: 초기 후보 목록은 유지하되 Phase별 현재 판정은 DL-012가 대체함
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

- 상태: 최소수집·보유기간 원칙은 유지하며, 로컬 private 저장과 Pilot 후속 연락 부분은 DL-010이 대체함
- 날짜: 2026-08-05
- 상황: 실제 참여자 모집 전에 공개 Git 저장소와 OneDrive 작업공간으로 연락처·동의 증빙·참여자별 Note가 유입되지 않도록 저장·접근·보관·삭제·철회 기준을 정해야 한다.
- 선택지: 녹음과 원문을 장기 보관, 별도 동의 녹음과 가명처리 Note를 기한부 보관, Pilot에서 녹음 없이 최소 구조화 Note만 보관.
- 초기 선택(대체된 저장·후속 연락 부분 포함): Pilot은 녹음·화면 Capture 없이 구조화 Note만 작성한다. 원자료는 공개 저장소·OneDrive·LLM·자동 전사 도구에서 제외하고 보호조치를 확인한 별도 private 저장소에 유형별로 분리한다. 기본 접근자는 프로젝트 책임자 1명이다. 불적격 Screening은 7일, 연락처·ID 연결표는 Interview·보상 종료 후 14일, 후속 연락 목록은 최대 90일, 참여자별 Note·Consent는 Interview 후 90일 또는 Gate 1 결정 후 30일 중 먼저 도래한 때 삭제한다. 공개 인용은 정확한 문구·맥락·채널을 제시한 별도 승인 없이는 사용하지 않는다.
- 선택 이유: 작은 표본의 지역·활동·시각 조합도 재식별될 수 있으므로 원문 재검토 편의보다 최소수집, 공개 저장소 노출 방지와 실질적인 철회 이행 가능성을 우선한다.
- 장점: 수집·보유 범위와 사고 영향이 작아지고, 참여자가 선택 동의와 철회 범위를 이해하기 쉬우며, 가상의 익명성을 주장하지 않는다.
- 단점: 녹음 없이 작성한 Note는 축어 재확인과 독립 Coding의 재현성이 낮고, 연결키 파기 후에는 특정 참여자의 삭제 요청을 집계 결과에 반영할 수 없다.
- 포기한 장점: 음성·원문 장기 보관에서 얻는 높은 분석 재현성과 사후 직접 인용 후보 탐색.
- 위험: 초기 로컬 방식에는 장치 암호화·ACL, Backup 사본과 작은 소집단의 간접 식별 위험이 있었다. 저장 방식은 DL-010으로 대체했으며, 철회 Email 송수신과 Google Forms 운영 설정은 아직 검증 전이다.
- 검증 방법: 첫 참여자 모집 전 실제 처리 주체·도구·처리 위치·접근자·저장소 보호조치를 기록하고, 가상 데이터로 삭제·철회 모의 실행과 Git ignore/staging 검사를 수행한다.
- 재검토 조건: Main Interview에서 음성 확인 필요성이 증거로 나타나거나, 연구자가 늘거나, 저장·회의 도구·법적 요구·연구 범위가 달라질 때.
- 관련 코드·문서: `docs/03-user-interviews.md`, `TASKS.md`, `.gitignore`

## DL-009 — Pilot Interview 진행 방식

- 상태: 대면 1:1·무녹음 원칙은 유지하며, Note 저장 방식은 DL-010으로 갱신함
- 날짜: 2026-08-05
- 상황: Pilot 2건은 질문의 유도성·시간·이해도와 화면 흐름 관찰을 확인하면서 외부 회의·녹화·전사 Service에 참여자 정보를 추가로 처리시키지 않는 방식이 필요하다.
- 선택지: 대면 1:1 Interview, 음성 전화, Google Meet 같은 원격 화상회의.
- 선택: Pilot은 약 40~50분의 대면 1:1 Interview로 진행한다. 녹음하지 않고, 참여자가 동의하면 자신의 기기를 직접 조작해 화면을 보여주며, 연구자는 소유자 전용 Google Form에 구조화 Note를 직접 작성한다.
- 선택 이유: Pilot의 목적은 지역 대표성 확보가 아니라 Script와 운영 절차 점검이다. 대면 방식은 화면과 행동 순서를 관찰하면서 회의·녹화·전사 Provider를 추가하지 않고 Note만 구조화해 남길 수 있다.
- 장점: 화면 맥락과 비언어적 혼란을 관찰하기 쉽고, 참여자의 회의 계정·설치 장벽과 녹화 범위가 작다.
- 단점: 이동·장소 조율 비용이 들고, 가까운 생활권의 참여자로 표본이 편중될 수 있으며 Note 입력에는 Network가 필요하다.
- 포기한 장점: 원격 모집의 지역 다양성, 일정 유연성, 이동 비용 절감.
- 위험: 연구자와 가까운 관계의 참여자가 거절하기 어려울 수 있고, 공공장소에서는 대화나 화면이 노출될 수 있으며, 무녹음 Note는 축어 재현성이 낮다. Network 장애나 Google 계정 접근 문제도 진행을 중단시킬 수 있다.
- 검증 방법: 조용하고 비공개인 장소, 권력관계 제외, Consent 재확인, 40~50분 소요시간, 질문 누락·유도성, 우발 노출과 Redaction, Form 제출·삭제를 Pilot별로 기록한다.
- 재검토 조건: Main Interview에서 대면 방식이 지역 다양성·모집 가능성·일정에 실질적인 장애라는 증거가 생길 때. 원격 전환 시 회의 Provider와 국외 처리 가능성을 검토하고 Consent를 개정한다.
- 관련 코드·문서: `docs/03-user-interviews.md`, `TASKS.md`, [Google Meet 보안·개인정보 안내](https://support.google.com/meet/answer/9852160), [Google 개인정보처리방침](https://policies.google.com/privacy?hl=ko)

## DL-010 — Google Forms 기반 연구 원자료 Cloud-only 운영

- 날짜: 2026-08-05
- 상황: Pilot 원자료를 암호화되지 않은 C: Drive나 OneDrive 작업공간에 남기지 않으면서 디지털로 동의·Screening·구조화 Note를 수집하고 개별 철회를 처리할 방법이 필요하다.
- 선택지: 로컬 private 폴더, 종이 기록, Google Forms, 별도 연구 Repository 또는 Survey SaaS.
- 선택: 동의·Screening Form과 연구자 전용 구조화 Interview Note Form을 `html.programming.language@gmail.com` 계정이 소유한다. 이름·Email은 Form에서 수집하지 않고 무작위 `researchCode`로 연결한다. 응답 Sheet, Download, Drive·Gmail Offline, Drive 동기화, Mail client, 공동편집자, Add-on·Script와 외부 AI 연동을 두지 않는다.
- 선택 이유: 별도 로컬 원자료 파일을 만들지 않으면서 필드를 제한하고 Code 단위로 개별 응답을 삭제할 수 있다. 사용자가 Google Forms 방식을 명시적으로 선택했다.
- 장점: 종이·로컬 파일 없이 수집할 수 있고, Form A와 B의 목적을 분리하며, 적은 Pilot 표본에서는 응답별 삭제를 직접 확인할 수 있다.
- 단점: Google 계정과 Network에 의존하고 Forms 화면 안에서만 분석해야 한다. Google은 전 세계 Server 처리와 Browser Cache 사용 가능성을 밝히므로 “특정 기기에 흔적이 전혀 없음”을 보장할 수 없다.
- 포기한 장점: 로컬 암호화 Repository의 완전한 Schema 제어, Offline Interview, CSV·Notebook을 이용한 빠른 Coding.
- 위험: 계정 탈취, 공동편집·공유 설정 오류, 실수로 연결한 Sheet, 국외 처리 고지 불충분, Browser 임시 흔적, Google Backup 삭제 지연이 남는다.
- 검증 방법: 두 Form의 소유권·2단계 인증·공유·Draft·Sheet·Offline 설정을 확인하고, 가상 `researchCode`로 제출·개별 삭제·재조회와 철회 Email 송수신·영구 삭제를 시험한다. 실제 URL·응답은 공개 증거로 남기지 않는다.
- 재검토 조건: 공동 연구자·녹음·원격 Interview를 추가하거나, Google Forms 외 도구를 사용하거나, Google의 처리 위치·보관·공유 정책이 달라질 때.
- 관련 코드·문서: `docs/03-user-interviews.md`, `docs/google-forms-pilot-runbook.md`, `TASKS.md`, [Google Forms 응답 관리](https://support.google.com/docs/answer/139706?hl=ko), [Google 데이터 보관·삭제 정책](https://policies.google.com/technologies/retention?hl=ko), [개인정보 보호법 제28조의8](https://www.law.go.kr/lsLinkCommonInfo.do?chrClsCd=010202&lsJoLnkSeq=1029334953)

## DL-011 — 외부 수동 작업의 Just-in-time 재개

- 상태: 수동 작업의 Just-in-time 원칙은 유지하며, Gate 1 재개 시점은 DL-013이 대체함

- 날짜: 2026-08-07
- 상황: Google Forms 완성, 계정 보호, 실제 참여자 모집, API 활용신청·키 발급과 기관 문의는 사용자의 화면 조작·판단·외부 제출이 필요하지만, 제품 정의 전부터 모두 완료할 필요는 없다.
- 선택지: 모든 외부 수동 작업을 즉시 선행, 작업마다 수시 요청, Codex가 완료 가능한 비코드 준비를 먼저 끝내고 명시적 Trigger에서 최소 수동 작업만 재개.
- 선택: Form A는 부분 확인 상태로 미게시 유지하고 Form B·계정·법적 검토·Dry-run은 실제 Pilot 증거 수집 승인 시 단계별로 재개한다. API 신청·키 입력·기관 문의는 실호출 또는 Production 판정 Trigger까지 `deferred_manual`로 둔다.
- 선택 이유: 아직 필요하지 않은 계정·법적·참여자 작업을 강요하지 않으면서도, 실행 직전 차단 조건과 완료 증거를 잃지 않기 위함이다.
- 장점: 제품 코드 없이 문서·Runbook·Fail-closed 준비를 끝낼 수 있고, 사용자는 필요한 시점에 최소 작업만 수행한다.
- 단점: 외부 사용자 증거와 Gate 2 실호출 증거는 Trigger 전까지 `not_verified` 또는 `not_run`이며 시장 검증과 Gate 2를 통과할 수 없다.
- 포기한 장점: Form·키·외부 답변을 미리 확보해 실행 전환 시간을 줄이는 것.
- 위험: `deferred_manual`을 완료로 오해하거나 부분 확인된 Form A를 게시할 수 있다.
- 검증 방법: Workflow 상태와 근거 상태를 분리하고, 각 Trigger의 차단 시점·완료 증거를 Checklist로 대조한다.
- 재검토 조건: 외부 참여자 모집·연락·응답 수집, 공개 Beta 또는 시장 수요 주장 중 가장 먼저 도래하는 시점 전 후속 검증이나 API 실호출을 사용자가 명시적으로 승인할 때.
- 관련 문서: [사용자 수동 작업 체크리스트](./manual-action-checklist.md), [Google Forms Pilot 운영 설계서](./google-forms-pilot-runbook.md), [Provider 실검증 Runbook](./provider-validation-runbook.md), [Gate 1·2 비코드 준비 감사](./gate-1-2-readiness-audit.md)

## DL-012 — Phase 1 Provider 범위 재판정

- 날짜: 2026-08-07
- 상황: 초기 후보 목록은 Phase와 배포 조건이 다른 Provider를 함께 나열해, 현재 검증 범위와 상용 차단 범위가 불명확했다.
- 선택: Phase 1 실검증은 공공데이터포털의 기상청 단기예보·기상특보와 AirKorea 측정소·대기오염정보로 제한한다. AirKorea는 개발 검증 후보지만 Production은 권리·위치 관련 조건 확인 전 차단한다. 행정안전부 긴급재난문자는 별도 이용허락 전 상용 차단, TourAPI는 Phase 3, Web Push는 Phase 4, 외부 지오코더는 기본 경로에서 제외한다.
- 선택 이유: 실제로 다음 검증에 필요한 Provider와 이후 후보를 분리하고, License가 불명확한 데이터를 조용히 기본 경로에 넣지 않기 위함이다.
- 장점: Runbook·Quota·Evidence 범위가 작아지고 Provider·Fallback 경계를 명확히 할 수 있다.
- 단점: 초기 제품의 안전 알림은 날씨 특보에 한정되고 비기상 재난·행사·Push는 제공하지 못한다.
- 포기한 장점: 첫 Phase부터 모든 지역 정보와 재난 알림을 통합하는 넓은 범위.
- 위험: AirKorea 조건이 해소되지 않으면 필수 대기질 Provider가 없어 Phase 1 범위를 더 줄여야 한다.
- 검증 방법: 인증키 Contract smoke, 14일 Canary, 발급 시점 약관 Snapshot과 Provider별 서면 확인.
- 재검토 조건: Founder scope의 우선 활동이 달라지거나 Provider 이용조건·Coverage·Quota가 바뀔 때.
- 관련 문서: [공공 데이터 카탈로그](./09-public-data-catalog.md), [Product License Register](./product-license-register.md), [Provider 실검증 Runbook](./provider-validation-runbook.md)

## DL-013 — 창업자 문제 근거로 Gate 1 범위 전환

- 날짜: 2026-08-07
- 상황: 제품 책임자가 본인이 겪은 불편에서 NowSignal을 시작했으므로 외부 Interview를 제품 탐색의 즉시 선행조건으로 두지 않고 다음 비코드 작업으로 진행하기로 했다.
- 선택지: 외부 문제 Interview 전까지 Gate 1 차단 유지, 가상 사용자 증거로 대체, 창업자 자기보고를 범위가 제한된 실제 근거로 기록하고 외부 검증을 후속 단계로 이동.
- 선택: 창업자 자기보고 7개 패턴을 `founder_lived_experience_n1`로 기록한다. Gate 1은 시장 검증이 아니라 Founder Problem Fit으로 재정의해 `passed_for_founder_scope`로 판단하고, 외부 수요·빈도·심각도·전환 의향은 `not_verified`로 유지한다.
- 초기 범위: 가까운 외출·산책·러닝의 당일 시각 결정에 필요한 강수·기온·습도·미세먼지·초미세먼지와 준비 정보를 우선한다. 세차·빨래는 후속 활동 규칙, 여행·등산·캠핑·침수·도로·인파·CCTV는 별도 Provider 검토 뒤 확장한다.
- 선택 이유: 가상의 인터뷰를 만들지 않고 실제 창업자 문제에서 탐색을 시작하면서도 n=1 근거를 시장 수요로 과장하지 않기 위함이다.
- 장점: Google Forms와 외부 모집을 제품 설계의 즉시 차단 조건에서 제외하고, 실제 불편에 맞춰 Gate 2 Provider 범위를 좁힐 수 있다.
- 단점: 사용자·연구자·제작자가 같아 확인 편향이 크고 외부 사용자가 같은 문제를 겪는지 알 수 없다.
- 포기한 장점: 구현 전에 독립 표본으로 문제 빈도·대안·전환 비용을 반증할 기회.
- 위험: 창업자 취향에 과적합하거나 Founder scope 통과를 시장 검증으로 잘못 표현할 수 있다.
- 검증 방법: 창업자 기록에는 출처·범위·미확인 필드를 표시하고 외부 지표를 계산하지 않는다. 외부 참여자 모집·연락·응답 수집, 공개 Beta 또는 시장 수요 주장 중 가장 먼저 도래하는 시점 전에 명시적 승인을 받고 기존 Interview Protocol을 재개한다.
- 연구 보관기한 변경: Gate 1 결정일이 후속 Interview보다 앞서므로 수집 전에 `waveRetentionAnchorDate`를 고정하고, 참여자의 Screening·Consent·Note는 `min(Interview일 +90일, Anchor +30일, 실제 Wave 종료·중단일 +30일(더 이른 경우))`로 계산한다. Gmail 대화는 해당 사람의 연락 목적 종료일(문의 처리 완료, 필수 동의 거부 확인, 부적격 판정, 미선정·미참여 확정, Interview·보상 완료 또는 철회 처리 완료) +14일로 계산한다. DL-008의 `Gate 1 결정일 +30일` 기준은 이 결정이 대체한다.
- 코드 경계: Gate 1 전환은 제품 코드 승인이 아니다. Gate 2 통과와 Gate 3 설계 승인 전에는 제품 코드를 작성하지 않는다.
- 재검토 조건: 외부 참여자 모집·연락·응답 수집, 공개 Beta·출시·홍보, 시장 수요 주장, 유료 운영 확대, 창업자 경험에 없는 활동·지역 확장 또는 Provider 조건으로 핵심 범위를 지원할 수 없을 때.
- 관련 문서: [창업자 문제 근거](./founder-problem-evidence.md), [프로젝트 헌장](./00-project-charter.md), [문제 가설](./02-problem-hypotheses.md), [사용자 인터뷰 및 모집 계획](./03-user-interviews.md), `TASKS.md`

## 다음 Decision Log 예정 항목

- 활동별 score 공식과 algorithm version
- Agent 수와 역할, model routing
- Cache TTL과 stale threshold
- 알림 영향도·deduplication 기준
- UI Library와 evidence-first information architecture
- 배포 구조와 observability 경계
- 외부 오픈소스의 도입·제외 판단

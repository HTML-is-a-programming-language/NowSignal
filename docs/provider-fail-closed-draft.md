# Provider Fail-closed 판단 초안

- 최초 작성일: 2026-08-07
- 문서 상태: `draft_ready_for_gate_3_review_not_approved`
- 구현 상태: `not_started`
- 목적: Provider 데이터가 오래됐거나 불완전·충돌·차단됐을 때 확정적 행동 추천을 만들지 않는 공통 판단안을 Gate 3 합의 전에 준비한다.
- 공통 계약: [공공 데이터 카탈로그](./09-public-data-catalog.md) 2.2
- 실행 검증: [Phase 1 Provider 실검증 Runbook](./provider-validation-runbook.md)

이 문서는 제품 설계를 확정하지 않는다. [문서화된 Founder scope](./founder-problem-evidence.md)와 실제 Contract·Freshness 결과를 기준으로 Gate 3에서 승인해야 하며, 그 전에는 제품 코드에 반영하지 않는다.

## 1. 입력 상태 축

결과 존재 여부, 데이터 품질, 응답 Contract와 License 판정을 한 문자열로 합치지 않는다.

### 데이터 품질 (`qualityStatus`)

| 상태 | 의미 |
| --- | --- |
| `fresh` | 필요한 원 필드가 있고 승인된 Age·유효기간 안에 있음 |
| `delayed` | 아직 참고 가능한 범위지만 예상 최신 발행·관측보다 늦음 |
| `stale` | 승인된 Age 또는 유효기간을 넘음 |
| `partial` | 응답은 있으나 추천에 필요한 필드 일부가 누락됨 |
| `conflicting` | 같은 지역·유효시각의 공식 값이 충돌함 |

### 결과 종류·Contract·License

| 축·상태 | 의미 |
| --- | --- |
| `resultKind=data` | 데이터가 있으며 `qualityStatus`를 함께 판정함 |
| `resultKind=valid_empty` | 성공 응답이며 해당 Provider 범위에서 대상 데이터가 없음 |
| `resultKind=unavailable` | 인증·권한·Quota·Timeout·Backend·Parsing 실패로 사용할 수 없음 |
| `contractStatus=verified` | 적용 중인 공식 응답 계약과 관찰 Schema가 일치함 |
| `contractStatus=conflicting_official_schema` | 공식 상세·첨부·Sample 사이에 필수 Field 정의가 충돌해 단일 계약을 확정할 수 없음 |
| `contractStatus=not_verified` | 실제 응답 또는 적용 공식 계약을 아직 대조하지 않음 |
| `licenseStatus=license_blocked`, `resultKind=not_fetched` | 이용·변경·저장·표시 권리가 해소되지 않아 Provider 호출·제품 사용을 차단함 |
| `licenseStatus=license_review_expired`, `resultKind=not_fetched` | 마지막 License 검토가 허용 기간을 지나 Provider 호출·제품 사용을 중단함 |

`fetchedAt`은 관측·발표시각을 대체하지 않는다. Provider 시각이 없으면 Fresh로 추정하지 않고 `partial` 또는 `unavailable` 후보로 둔다.

### 1.1 결정 우선순위

아래 순서는 Gate 3 검토용 고정 초안이다. 한 단계가 차단이면 뒤 단계의 점수·Fallback으로 이를 해제하지 않는다. 정의되지 않은 상태의 기본값은 허용이 아니라 `block`이다.

| 순서 | 검사 | 통과 조건 | 실패·미확인 시 결과 |
| ---: | --- | --- | --- |
| 1 | License | `licenseStatus=usable`, 검토기한 유효, 해당 연산이 Product License Register에서 허용됨 | `resultKind=not_fetched`, 표시·Score·LLM 입력·Cache 차단 |
| 2 | Contract | 적용 공식 계약이 단일하고 `contractStatus=verified` | `conflicting_official_schema` 또는 `not_verified`; Score·Best Window 차단, 개발 Evidence만 분리 표시 |
| 3 | Result | `resultKind=data` 또는 `resultKind=valid_empty`이고 오류 Class가 없음 | `unavailable` 또는 `not_fetched`; Score 차단, 조용한 Provider 전환 금지 |
| 4 | Quality | `fresh`, 또는 Gate 3에서 명시적으로 허용한 제한적 `delayed` 또는 `partial` | `stale` 또는 `conflicting`은 차단. 미승인 `delayed`·`partial`도 차단 |
| 5 | Activity field role | 해당 활동의 모든 `hard_block`·`score_required` 입력이 존재하고 승인된 Threshold·단위를 사용 | 활동별 Score·Best Window 차단; 누락을 0 또는 중립값으로 보정 금지 |
| 6 | Recommendation | Hard block이 없고 근거 Provider·시각·지역·License·Algorithm version을 표시 가능 | 설명 또는 수동 확인 행동만 제공; 확정 추천 금지 |

`valid_empty`는 순서 3을 통과할 수 있지만 Provider별 의미를 먼저 적용한다. KMA 날씨 특보의 `valid_empty`는 날씨 특보 없음일 뿐 전체 재난 안전이 아니며, AirKorea 필수 관측의 `valid_empty`는 대기질 근거 부재이므로 순서 5에서 차단한다.

## 2. 제안 출력 정책

| 입력 | 정보 표시 | 활동 Score·Best Window | 사용자 행동 문구 | Cache 사용 |
| --- | --- | --- | --- | --- |
| `fresh` | Source·시각·지역과 표시 | 다른 필수 Provider도 유효할 때만 허용 | 근거와 불확실성 포함 | 원 시각 유지 |
| `delayed` | 지연 Label과 Age를 표시 | 기본 금지, 검증 후 제한적 허용 재심의 | 최신 확인 행동을 우선 | 마지막 성공값 재타임스탬프 금지 |
| `stale` | 과거 정보임을 명시할 때만 참고 표시 | 금지 | 새로고침·공식 Source 확인 제시 | 새 데이터처럼 표시 금지 |
| `partial` | 있는 필드와 누락 영향을 구분 | 누락 필드가 활동 판정에 필요하면 금지 | 누락 없는 범위만 설명 | 원본과 누락 목록 보존 |
| `conflicting` | 충돌 Source·시각을 함께 표시 | 금지 | 공식 Source 직접 확인 제시 | 임의 평균·다수결 금지 |
| `unavailable` | 장애·다시 시도 시점 표시 | 금지 | 수동 확인·재시도 제공 | 오래된 Cache로 조용히 대체 금지 |
| `valid_empty` | Provider 범위를 함께 표시 | “안전”으로 확대 해석 금지 | 예: 날씨 특보 없음은 비기상 재난 없음이 아님 | Empty 결과 시각 보존 |
| `conflicting_official_schema` | 개발 Evidence에는 충돌한 공식 근거와 관찰 Field만 분리 표시 | 금지 | 공식 문서 확인 또는 제공기관 확인 필요 | 단일 Schema로 정규화·재가공 금지 |
| `license_blocked` | 제품 데이터로 표시하지 않음 | 금지 | 승인된 대체 Source가 있을 때만 명시적 제공 | 저장·Model 입력 금지 |
| `license_review_expired` | 제품 데이터로 표시하지 않음 | 금지 | 최신 이용조건 재검토 필요 표시 | 재검토 전 Cache 제공 금지 |

## 3. 결합 상태 제안

1. 활동 판정에 필수인 Weather와 Air Quality 중 하나가 `resultKind=unavailable|not_fetched`이거나 `qualityStatus=stale|conflicting`이거나 `contractStatus=conflicting_official_schema|not_verified`이면 통합 Score와 Best Window를 생성하지 않는다.
2. `partial`은 누락 필드가 해당 활동의 Hard block·Score에 쓰이는지 먼저 확인한다. 영향 분석이 없으면 보수적으로 추천을 중단한다.
3. Provider 상태를 단순 평균하지 않는다. 공식 특보 같은 Hard block은 일반 점수보다 우선한다.
4. 공식 특보가 활성이라면 원문·기관·발표·발효시각을 NowSignal 설명보다 먼저 표시한다.
5. 특보 없음이나 대기질 결측을 0점 위험으로 변환하지 않는다.
6. KMA 기상특보의 `valid_empty`는 날씨·대기질 활동 판정 자체를 막지 않지만 “모든 재난 안전”으로 확대하지 않는다.
7. 필수 AirKorea 측정값의 `valid_empty`는 대기질 근거 부재이므로 통합 Score와 Best Window를 막는다.

### 3.1 Founder 활동별 입력 역할 검토표

이 표는 Threshold나 점수 공식을 정하지 않는다. Gate 3에서 각 `candidate`를 승인·제외하고 단위·임계값·우선순위를 고정하기 전에는 모두 추천 생성에 사용할 수 없다.

| Provider 입력 | 외출 | 산책 | 러닝 | 현재 역할 상태 | 미확인·누락 처리 |
| --- | --- | --- | --- | --- | --- |
| KMA 활성 기상특보·대상지역·발효시각 | `hard_block_candidate` | `hard_block_candidate` | `hard_block_candidate` | 경보 종류별 차단 범위·강도 `not_approved` | 공식 특보가 활성인데 의미 매핑이 없으면 추천 차단. 특보 없음은 비기상 재난 안전으로 확대 금지 |
| KMA 강수 형태·강수량·강수확률 | `score_required_candidate` | `hard_block_or_score_candidate` | `hard_block_or_score_candidate` | 시간 Horizon·Threshold `not_approved` | 필수 Category 누락·단위 불명·Stale이면 추천 차단 |
| KMA 기온·습도·풍속 | `score_required_candidate` | `score_required_candidate` | `hard_block_or_score_candidate` | 체감·위험 Threshold와 활동별 가중치 `not_approved` | 값 누락을 쾌적 또는 0 위험으로 보정 금지 |
| AirKorea PM10·PM2.5 원 수치·등급·관측시각 | `hard_block_or_score_candidate` | `hard_block_or_score_candidate` | `hard_block_or_score_candidate` | 제3유형 파생 허용·Schema·Threshold `not_verified` | 둘 중 하나라도 결측이거나 관측 Age·측정소 Context가 미확인이면 추천 차단 |
| AirKorea O3 | `informational_candidate` | `informational_candidate` | `informational_candidate` | Founder 핵심 범위 밖, 별도 기준 전 Score 사용 금지 | 값은 원형 보존 가능하지만 추천 결론에 사용 금지 |
| AirKorea 지역·일 단위 예보 | `informational_candidate` | `informational_candidate` | `informational_candidate` | 시간대별 관측 대체 금지 | 시간대별 Best Window 근거로 사용 금지 |

Gate 3 승인 항목은 활동별로 `hard_block`, `score_required`, `informational`, `excluded` 중 정확히 하나가 되어야 한다. `candidate` 또는 `not_approved`가 하나라도 남아 있으면 해당 활동의 제품 Score는 비활성이다.

## 4. Fallback 제안

- Fallback은 Provider 이름, 전환 이유, 전환시각, 원 Provider 상태를 사용자와 Trace에 남긴다.
- License·범위가 다른 Provider를 동등한 대체물로 표시하지 않는다.
- KMA 기상특보는 행정안전부 긴급재난문자의 대체가 아니다.
- AirKorea 인접 측정소는 원 측정소와 거리·관측시각을 표시하고 보간하지 않는다.
- 승인되지 않은 외부 날씨 API로 자동 전환하지 않는다.

## 5. Cache 제안

- 마지막 성공 응답의 `observedAt`, `issuedAt`, `fetchedAt`, Provider와 License를 유지한다.
- Cache Hit 시 새 `fetchedAt`을 부여해 새 응답처럼 보이게 하지 않는다.
- 원본, 정규화 값, 파생 판정, AI 설명을 분리한다.
- License review가 만료되거나 저장 금지 조건이 생기면 Cache를 제공하지 않고 삭제 절차 대상으로 보낸다.

## 6. 승인 전 해결할 질문

- 활동별 필수 Weather·Air Quality 필드와 Hard block은 무엇인가?
- `delayed` 상태에서 제한적으로 허용할 정보 표시와 금지할 추천은 무엇인가?
- Canary 시작 전에 고정할 `pre_registered_acceptance_criteria`는 무엇이며, 14일 결과 뒤 어떤 표본·계절 한계를 명시해 `production_policy_threshold`를 승인할 것인가?
- 사용자에게 Source 충돌·Fallback·마지막 성공시각을 어떤 UI 우선순위로 표시할 것인가?
- 공식 특보와 일반 Weather가 충돌할 때 UI·알림·기록 우선순위는 무엇인가?

이 질문과 [Provider 실검증](./provider-validation-runbook.md)이 Founder scope에 맞게 해결되기 전에는 전체 Fail-closed Matrix를 `approved`로 바꾸거나 제품 코드를 작성하지 않는다.

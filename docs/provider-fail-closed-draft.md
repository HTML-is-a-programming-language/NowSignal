# Provider Fail-closed 판단 초안

- 최초 작성일: 2026-08-07
- 문서 상태: `draft_not_approved`
- 구현 상태: `not_started`
- 목적: Provider 데이터가 오래됐거나 불완전·충돌·차단됐을 때 확정적 행동 추천을 만들지 않는 공통 판단안을 Gate 3 합의 전에 준비한다.

이 문서는 제품 설계를 확정하지 않는다. 실제 Contract·Freshness 결과와 사용자 문제 증거가 생긴 뒤 승인해야 하며, 그 전에는 제품 코드에 반영하지 않는다.

## 1. 입력 상태

| 상태 | 의미 |
| --- | --- |
| `fresh` | 필요한 원 필드가 있고 승인된 Age·유효기간 안에 있음 |
| `delayed` | 아직 참고 가능한 범위지만 예상 최신 발행·관측보다 늦음 |
| `stale` | 승인된 Age 또는 유효기간을 넘음 |
| `partial` | 응답은 있으나 추천에 필요한 필드 일부가 누락됨 |
| `conflicting` | 같은 지역·유효시각의 공식 값 또는 License 판정이 충돌함 |
| `unavailable` | 인증·권한·Quota·Timeout·Backend·Parsing 실패로 사용할 수 없음 |
| `valid_empty` | 성공 응답이며 해당 Provider 범위에서 대상 데이터가 없음 |
| `license_blocked` | 기술적으로 응답 가능해도 이용·변경·저장·표시 권리가 해소되지 않음 |

`fetchedAt`은 관측·발표시각을 대체하지 않는다. Provider 시각이 없으면 Fresh로 추정하지 않고 `partial` 또는 `unavailable` 후보로 둔다.

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
| `license_blocked` | 제품 데이터로 표시하지 않음 | 금지 | 승인된 대체 Source가 있을 때만 명시적 제공 | 저장·Model 입력 금지 |

## 3. 결합 상태 제안

1. 활동 판정에 필수인 Weather와 Air Quality 중 하나가 `stale`, `conflicting`, `unavailable`, `license_blocked`이면 통합 Score와 Best Window를 생성하지 않는다.
2. `partial`은 누락 필드가 해당 활동의 Hard block·Score에 쓰이는지 먼저 확인한다. 영향 분석이 없으면 보수적으로 추천을 중단한다.
3. Provider 상태를 단순 평균하지 않는다. 공식 특보 같은 Hard block은 일반 점수보다 우선한다.
4. 공식 특보가 활성이라면 원문·기관·발표·발효시각을 NowSignal 설명보다 먼저 표시한다.
5. 특보 없음이나 대기질 결측을 0점 위험으로 변환하지 않는다.

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
- Provider별 Threshold는 14일 Canary에서 어떤 표본·계절 한계로 확정할 것인가?
- 사용자에게 Source 충돌·Fallback·마지막 성공시각을 어떤 UI 우선순위로 표시할 것인가?
- 공식 특보와 일반 Weather가 충돌할 때 UI·알림·기록 우선순위는 무엇인가?

이 질문과 Gate 1 실제 문제 증거가 해결되기 전에는 문서 상태를 `approved`로 바꾸거나 제품 코드를 작성하지 않는다.

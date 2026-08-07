# Phase 1 Provider 실검증 Runbook

- 최초 작성일: 2026-08-07
- 문서 상태: `ready_for_manual_prerequisites`
- 실행 이력: `not_run`
- 현재 진행 상태: `deferred_manual`
- 범위: 기상청 단기예보, 기상청 기상특보, AirKorea 대기오염정보·측정소정보
- 비범위: 제품 코드, 운영계정 승인, Production 적합성 확정, 행정안전부 긴급재난문자, TourAPI, 외부 지오코더, Web Push. 로컬 좌표→KMA 격자 변환과 측정소 선택 알고리즘은 Gate 4 설계·테스트 대상이며 이 Provider 실호출 Runbook이 검증 완료로 대신하지 않는다.
- 관련 문서: [창업자 문제 근거와 초기 범위](./founder-problem-evidence.md), [공공 데이터 카탈로그](./09-public-data-catalog.md), [Product License Register](./product-license-register.md), [Provider Fail-closed 판단 초안](./provider-fail-closed-draft.md), [사용자 수동 작업](./manual-action-checklist.md)

이 Runbook은 인증키를 받은 뒤 동일한 방법으로 Contract·오류·Freshness를 검증하기 위한 실행 명세다. 아직 API를 호출하지 않았으므로 아래 결과와 수치는 모두 계획이며, 실행 전에는 `verified`로 바꾸지 않는다.

## 1. Provider·Endpoint 범위

| Provider ID | 공식 상세 | 우선 검증 Endpoint | 보수적 실검증 상한 | 개발·License 판정 | 실행 이력 |
| --- | --- | --- | --- | --- | --- |
| `kma-data-go-kr-vilage-fcst` | [API 15084084](https://www.data.go.kr/data/15084084/openapi.do) | `/getUltraSrtNcst`, 초단기예보·단기예보 상세기능 | 10,000회/일과 승인 화면 중 더 낮은 값 | `approved_for_dev` | `not_run` |
| `kma-data-go-kr-weather-warning` | [API 15000415](https://www.data.go.kr/data/15000415/openapi.do) | `/getWthrWrnList`, 통보문·현황 상세기능 | 10,000회/일과 승인 화면 중 더 낮은 값 | `approved_for_dev` | `not_run` |
| `airkorea-air-measurement` | [API 15073861](https://www.data.go.kr/data/15073861/openapi.do) | 측정소별 실시간 측정, `/getMinuDustFrcstDspth` | 두 AirKorea API 합산 500회/일 | 개발 `approved_for_dev`, 운영 `conditional_for_production` | `not_run` |
| `airkorea-station` | [API 15073877](https://www.data.go.kr/data/15073877/openapi.do) | `/getMsrstnList`, 근접 측정소 상세기능 | 두 AirKorea API 합산 500회/일 | 개발 `approved_for_dev`, 운영 `conditional_for_production` | `not_run` |

2026-08-07 확인 시 KMA 두 API의 영문 Locale 상세에는 한국어 상세보다 큰 호출량이 표시됐다. 실행 예산은 더 낮은 한국어 상세의 10,000회/일을 사용하고, 실제 승인 화면의 호출량을 확인하기 전 `quota_conflicting_not_verified`로 둔다. AirKorea 두 API가 500회를 공유하는지 각각 적용하는지도 승인 화면에서 확인한다.

기상청 API허브는 별도 계정·키·약관·Quota를 쓰므로 이 Runbook의 공공데이터포털 Provider와 혼합하지 않는다.

## 2. 실행 전 수동 Preconditions

아래 항목은 지금 수행하지 않는다. 사용자가 API 실호출을 승인할 때 [수동 작업 체크리스트](./manual-action-checklist.md)에 따라 요청한다.

- [ ] 대상 API별 개발 활용신청·승인 상태 확인
- [ ] 발급 시점 상세 페이지·약관·승인 호출량을 식별정보와 키를 가린 Evidence로 보관
- [ ] 키를 로컬 Secret store 또는 환경변수에 입력하고 값은 Chat·문서·명령 출력·Git에 남기지 않음
- [ ] KST·UTC가 정확한 실행 환경 확인
- [ ] 항상 켜진 14일 Canary 실행 환경과 호출 예산 승인
- [ ] 정확 GPS가 아닌 고정 KMA 격자, 시·도, 공개 측정소 Test target 확정

Preconditions 중 하나라도 충족되지 않으면 현재 진행 상태는 `deferred_manual`이며 실제 호출을 시도하지 않는다. `not_run`은 실행 이력, `deferred_manual`은 현재 Workflow 상태다.

## 3. Evidence 규격

실행 도구는 원 응답을 공개 저장소에 그대로 저장하지 않는다. Sanitization 후 다음 Manifest만 공개 가능한 Evidence로 남긴다.

```yaml
runId: provider-date-sequence
providerId: kma-data-go-kr-vilage-fcst
endpoint: getUltraSrtNcst
evaluatedAt: null
fetchedAt: null
request:
  secretRemoved: true
  publicParameters: {}
response:
  httpStatus: null
  providerResultCode: null
  providerResultMessageClass: null
  sanitizedSha256: null
time:
  observedAt: null
  issuedAt: null
  validFrom: null
  validUntil: null
location:
  exactGpsStored: false
  publicGridOrStation: null
result:
  kind: null
  qualityStatus: null
  errorClass: null
  missingRequiredFields: []
license:
  registerId: null
  status: null
  attributionPresent: false
review:
  verdict: not_run
  reviewedAt: null
  reviewerRole: null
```

### 공개 저장 금지

- API key 원문·부분값·Encoded 값
- key가 들어간 URL, `curl` history, stdout, Screenshot
- 계정명, 활용신청 번호, 개인 Email·전화번호
- 정확 GPS와 사용자의 상세 위치
- Sanitization 전 원 응답

필요한 원 Evidence는 공개 저장소 밖의 승인된 위치에 두고, 공개 문서에는 Hash·날짜·판정만 남긴다.

## 4. 공통 Contract Smoke Test

| ID | Test | 기대 판정 |
| --- | --- | --- |
| `C-01` | 유효한 키와 최소 정상 Parameter로 JSON 요청 | HTTP와 Provider code를 분리 기록하고 Schema 검증으로 이동 |
| `C-02` | 같은 의미의 XML·JSON 응답 구조 비교 | 필드 의미가 같고 Parser 차이를 기록 |
| `C-03` | 키 누락 | `auth_error`, 재시도 금지, key Log 없음 |
| `C-04` | 무효 키 | `auth_error`, 재발급을 자동 시도하지 않음 |
| `C-05` | 활용 미승인·권한 거부 | `permission_denied`, 사용자 수동 조치로 전환 |
| `C-06` | 잘못된 Parameter·형식 | `invalid_request`, 재시도 금지 |
| `C-07` | 존재하지 않거나 폐기된 Endpoint | `endpoint_invalid`, 다른 Provider로 자동 전환 금지 |
| `C-08` | 정상 빈 결과 | `valid_empty`와 장애를 구분 |
| `C-09` | Timeout·기관 Backend 실패 | 제한된 Backoff 후 `unavailable` |
| `C-10` | 초당·일일 호출량 초과 | 실제 Quota를 고의 소진하지 않고 관찰 또는 Sanitized fixture로 검증 |
| `C-11` | 필수 Source·License·Attribution 추출 | 하나라도 없으면 Contract fail |
| `C-12` | Secret Redaction 검사 | URL·stdout·fixture·Git diff에 key 흔적 0건 |

공공데이터포털의 Provider error code와 HTTP status는 서로 대체하지 않는다. HTTP 200 안의 오류 payload도 실패로 분류한다.

## 5. Provider별 의미 검증

### 5.1 KMA 단기예보

- `baseDate/baseTime`과 `fcstDate/fcstTime`을 분리한다.
- 요청 `nx/ny`와 응답 격자가 일치하는지 확인한다.
- 실황 `category`, `obsrValue`와 예보 Category·단위를 원문 그대로 보존한다.
- 제품에 필요한 Category 일부가 빠지면 0이나 정상값으로 보정하지 않고 `partial`로 판정한다.
- 최신 유효 발행본, 이전 발행본, 유효기간이 지난 발행본을 구분한다.
- 초기 가정은 실황 Age 90분 이내 `fresh`, 90분 초과 3시간 이내 `delayed`, 3시간 초과 `stale`이지만 공식 SLA로 표현하지 않는다.
- KMA가 제공하지 않은 정확도나 지역 대표성을 추정하지 않는다.

### 5.2 KMA 기상특보

- 특보 없음은 날씨 특보 범위의 `valid_empty`이며 “모든 재난이 안전함”으로 표시하지 않는다.
- 발표기관, 발표·발효·해제시각, 대상지역, 원문·Source를 보존한다.
- 활성·해제·정정·중복 발표를 ID·발표시각으로 연결한다.
- 원문과 NowSignal 설명을 분리하며 공식 원문을 먼저 표시하는 Contract를 검사한다.
- 구 API 또는 행정안전부 API로 조용히 Fallback하지 않는다.

### 5.3 AirKorea

- 측정소 조회 결과와 측정값을 안정된 측정소 식별자·명칭으로 연결한다.
- 측정소, 관측시각, PM10·PM2.5·O3 원 수치·공식 등급·단위를 보존한다.
- `null`, 결측기호, 점검·정비 상태를 0으로 바꾸지 않고 `partial` 또는 `unavailable`로 판정한다.
- 인접 측정소 Fallback은 측정소와 거리를 명시하고 보간하지 않는다.
- 초기 가정은 관측 Age 2시간 이내 `fresh`, 2~4시간 `delayed`, 4시간 초과 `stale`이지만 14일 측정 후 재검토한다.
- 예보는 05·11·17·23시 발표와 유효일을 분리하고, O3 계절 조건을 적용한다.
- 공공누리 제3유형 원본과 단위변환·거리·활동 판정 같은 파생층을 분리한다.
- Production에서는 위치 관련 절차와 파생·AI·Cache 범위의 서면 확인 전 차단한다.

## 6. 14일 Freshness Canary 계획

실행 전 Provider별 일일 호출 예산표를 먼저 작성한다. 계획 호출량은 승인 화면의 더 낮은 호출량을 넘지 않으며 장애 조사·수동 재검증 Reserve를 남긴다.

### 6.1 인증키 없이 확정 가능한 보수적 예산 초안

아래는 고정 공개 Test target만 쓰는 검증 부하다. 실제 제품 Traffic 용량 산정이 아니며, 승인 화면·Endpoint 호출 단위·응답 Schema를 확인한 뒤 더 낮아질 수 있다. `ceil`은 올림이다.

| Quota Pool | 기본 호출 계산 | 조사·Retry Reserve 포함 일일 Cap | 보수적 상한 대비 | 실행 전 확인 |
| --- | ---: | ---: | ---: | --- |
| KMA 단기예보 | 3개 기능 × 2개 고정 격자 × 24회 = 144 | `ceil(144 × 1.2) = 173` | 10,000 기준 1.73% | 기능별 요청 1회가 한 호출인지, 승인량·리셋 시각 |
| KMA 기상특보 | 전국 목록 1개 × 5분 간격 288회 | 348 (상세·정정·오류 조사 Reserve 60) | 10,000 기준 3.48% | 목록 응답의 상세 호출 필요량, 승인량·리셋 시각 |
| AirKorea 두 API 합산 | 측정소 2회 + 2개 측정소 × 24회 + 예보 4회 = 54 | 100 (Contract·Retry·결측 조사 포함) | 공유 500 가정 기준 20% | 두 API quota 공유 여부, 측정소·예보 호출 단위, 리셋 시각 |

Reserve는 고의 Rate Limit·Quota 소진 시험에 쓰지 않는다. 첫날 Contract smoke도 해당 일일 Cap 안에서 수행한다. 실제 승인 상한이 이 표보다 낮거나 호출 단위가 예상보다 크면 target·주기를 줄여 새 예산표를 승인하기 전 Canary를 시작하지 않는다.

### 6.2 수집 항목

매 호출에서 다음 값을 분리 기록한다.

- `evaluatedAt`
- `fetchedAt`
- Provider의 `observedAt` 또는 `issuedAt`
- `validFrom`, `validUntil`
- 응답 성공·유효 빈 결과·결측·오류 Class
- Grid·시도·측정소 같은 축소 지역 식별자
- 당일 누적 호출량

14일 종료 시 Provider·Endpoint·지역별로 다음을 집계한다.

- 응답 성공률과 유효 빈 결과 비율
- 관측·발표 Age의 p50·p95·p99
- Polling 횟수와 구분한 고유 발표 회차별 최신본 도착률·발표 지연
- 결측·`partial`·`unavailable` 비율
- 지역 Coverage와 특정 측정소 의존도
- 사용 호출량과 승인량 대비 비율

Canary 시작 전에는 표본 성공률·Age·필수 필드·Coverage에 대한 `pre_registered_acceptance_criteria`를 고정하고 소급 변경하지 않는다. 14일이 끝나기 전에는 실제 제품의 `production_policy_threshold`를 확정하지 않는다. 후자는 공식 SLA가 아니라 관찰 표본에 근거한 제품 정책이며 계절·장애·지역 한계를 함께 기록한다.

### 6.3 Founder scope 사전 합격 기준 초안 v1

- 기준 상태: `draft_ready_for_contract_lock`
- 적용 범위: 가까운 외출·산책·러닝의 당일 시각 결정
- 목적: Gate 2 기술 검증의 사전 판정 기준. Provider의 공식 SLA나 Production 정책이 아니다.

Contract smoke 뒤 Canary 시작 전 다음을 `canaryPlanId`와 SHA-256으로 고정한다.

1. Endpoint, 같은 두 시·도 안에서 각각 짝지은 KMA 격자·AirKorea 공개 측정소, 호출 주기, 고유 발표 회차와 예상 호출 수. 두 지역은 수도권 1곳과 비수도권 1곳으로 고정
2. Endpoint별 실제 Category code·Schema와 아래 필수 의미 필드의 매핑
3. 공식 문서의 발표 예정시각과 Founder의 당일 활동 결정에 필요한 시간 민감도를 근거로 Canary 전에 정한 내부 Engineering 허용 도착 지연. 허용 지연을 Provider 공식 SLA로 표현하거나 Canary 관찰값으로 소급 설정하지 않음
4. 분모와 제외 규칙. 시작 후 누락 호출·Provider 오류·점검을 분모에서 빼지 않고, 계획 변경은 새 버전과 재시작으로 처리
5. 예보 Coverage의 예상 Slot 집합. KMA는 `(Endpoint, targetGrid, issuedCycle)`별 최신본에서 해당 격자의 첫 6시간·12시간 `유효시각 × 필수 Category` Cell, AirKorea는 `(Endpoint, targetRegion, issuedCycle)`별 `공식 유효일 × PM10·PM2.5` Cell을 시작 전에 고정. 한 격자 Poll을 다른 격자의 Cell과 비교하지 않음
6. Fixture의 출처 Class와 C-01~C-12 중 허용할 `not_applicable` Case
7. AirKorea 수동 Pair의 `targetGrid` 중심과 측정소 사이 내부 최대 허용 거리 `stationMaxDistanceKm`와 근거. 거리 초과 또는 기준 안의 측정소 부재는 해당 지역 Coverage fail이며 더 먼 측정소로 조용히 대체하지 않음

Contract smoke는 실제 Category code·Schema 매핑과 위 잠금값을 채우기 위한 절차다. 응답을 본 뒤 현재 표의 필수 의미 필드, 95%·90% 합격률, 6시간·12시간 Horizon, 두 지역 설계를 약화할 수 없다. 변경이 필요하면 Founder scope와 Decision Log에 별도 범위 축소 근거를 남기고 새 기준 Version·Hash로 Canary를 처음부터 다시 시작한다.

| 대상 | 고정 분모 | 필수 의미 필드·행동 | 14일 기술 합격 기준 초안 |
| --- | --- | --- | --- |
| KMA 초단기실황 | 고정 격자별 계획 Poll | 관측시각, 격자, 강수 형태·1시간 강수량, 기온, 습도, 풍속, Source·단위 | 계획 Poll 중 `data`이고 필수 필드가 모두 있으며 관측 Age가 90분 이내인 **사용 가능 표본 비율** 95% 이상 |
| KMA 초단기예보 | 고정 격자별 계획 Poll과 고유 발표 회차 | 발표·유효시각, 격자, 강수 형태·양, 기온, 습도, 풍속, Source·단위 | 계획 Poll 중 최신 `data`이고 필수 필드가 모두 있으며 첫 6시간 예상 Cell Coverage가 100%인 사용 가능 표본 비율 95% 이상. 고유 발표 회차 중 그 최신본이 잠금된 허용 지연 안에 도착한 비율 95% 이상 |
| KMA 단기예보 | 고정 격자별 계획 Poll과 고유 발표 회차 | 발표·유효시각, 격자, 강수 형태·양·확률, 기온, 습도, 풍속, Source·단위 | 계획 Poll 중 최신 `data`이고 필수 필드가 모두 있으며 첫 12시간 예상 Cell Coverage가 100%인 사용 가능 표본 비율 95% 이상. 고유 발표 회차 중 그 최신본이 잠금된 허용 지연 안에 도착한 비율 95% 이상 |
| KMA 기상특보 | 계획 Poll과 관찰된 고유 발표 | 발표기관, 발표·발효·해제시각, 대상지역, 원문, 활성·해제·정정 연결, `valid_empty` | 계획 Poll 중 `data|valid_empty`인 비율 95% 이상이며 오류는 성공으로 세지 않음. 출처가 확인된 실제 Sanitized 응답 또는 공식 Sample로 활성·해제·정정 Contract가 모두 pass. 실제 발표가 있으면 필수 필드 완전성 100%, 없으면 Live event latency는 `not_observed`이고 제한부 판정만 허용. 비기상 재난 안전으로 오해시키는 변환 0건 |
| AirKorea 측정소 | 두 고정 지역에 수동으로 미리 지정한 공개 측정소 | 측정소 식별자·명칭, 시·도 수준 지역, 공개 좌표 기반 거리 | `stationMaxDistanceKm` 이내 Pair의 Contract 연결 100%, 거리 초과·다른 측정소 보간 0건. 기준 안의 측정소가 없으면 지역 Coverage fail. Gate 2는 수동 연결만 검증하며 자동 측정소 선택 정확도는 Gate 4 범위 |
| AirKorea 관측 | 공개 측정소별 계획 Poll | 관측시각, PM10·PM2.5 원 수치·등급·단위, 측정소와 Fallback 사유 | 계획 Poll 중 `data`이고 PM10·PM2.5 필드가 모두 있으며 관측 Age가 2시간 이내인 사용 가능 표본 비율 90% 이상. 결측을 0으로 변환한 사례 0건 |
| AirKorea 예보 | 대상 지역별 고유 05·11·17·23시 발표 회차 | 발표시각, 유효일·지역, PM10·PM2.5 예보와 Source | 고유 발표 회차 중 최신 `data`가 잠금된 허용 지연 안에 도착하고 모든 예상 Cell과 필수 필드를 갖춘 사용 가능 회차 비율 90% 이상 |
| 공통 Contract·보안 | C-01~C-12의 사전 고정 Case와 전체 계획 호출 | 예상 Verdict, 실제 호출 또는 허용된 Fixture 근거, Source·License·Attribution, Secret Redaction | 아래 필수 Case가 모두 `pass`이고 미해결 `fail|not_observed` 0건. 계획 호출 실행률 95% 이상, Source·License·Attribution 유실·API key·정확 GPS 누출·설명 없는 자동 Provider 전환 각각 0건 |

개별 `data` 성공률·완전성·Age·Coverage도 진단 지표로 각각 보고하되, 서로 다른 표본의 독립 비율을 조합해 합격시키지 않는다. 위 **사용 가능 표본·회차 비율**의 분자는 같은 표본이 성공, 필수 필드, Age 또는 허용 지연, Coverage 조건을 동시에 만족한 경우만 센다. `valid_empty`가 허용되지 않는 대상의 빈 결과, `partial`, `delayed|stale`, 인증·권한·Timeout·Backend 오류와 계획 누락 호출은 모두 해당 고정 분모의 실패다.

예보 Cell Coverage는 `수신한 예상 Cell 수 / 사전 고정한 전체 예상 Cell 수`로 계산한다. 한 회차가 표의 사용 가능 조건을 만족하려면 그 회차 Coverage가 100%여야 하며, 전체 합격률은 이 조건을 만족한 계획 Poll 또는 고유 발표 회차의 비율이다. 예상 Cell 집합이나 지역을 결과를 본 뒤 줄이지 않는다.

Fixture 출처는 다음 세 Class로 구분하고 Evidence manifest에 기록한다.

- `provider_observed_sanitized`: 실제 Provider 응답에서 Secret·개인정보를 제거하고 Hash를 남긴 자료
- `provider_official_sample`: Provider 공식 문서·Sample에 출처 URL·확인일·Hash를 남긴 자료
- `synthetic_classifier_fixture`: 내부에서 만든 오류·경계값 자료. C-09·C-10의 Fail-closed 분기 확인에만 쓰며 Provider Schema·필드·실제 오류 행동의 Contract 근거로 쓰지 않음

C-01·C-03·C-04·C-06·C-07·C-11·C-12는 모든 Provider에서 필수다. C-05의 Provider Family는 2절 표의 Provider ID 단위이며 각 ID에서 1회 이상 검증한다. C-08은 KMA 기상특보와 공식적으로 유효 빈 결과가 가능한 Endpoint에서 필수다. `not_applicable`은 C-02에서 Provider가 XML·JSON 중 한 형식을 공식 지원하지 않는 경우와 C-08에서 유효 빈 결과 의미가 없는 Endpoint에만 허용하며, 사유와 공식 근거를 Canary 전에 잠근다. C-09·C-10은 통제된 오류 주입 또는 `synthetic_classifier_fixture`로 Client의 Fail-closed 판정을 필수 검증하되 Provider 자체 행동을 검증했다고 주장하지 않는다.

O3는 수집 시 원 수치·등급·단위를 보존하고 결측을 숨기지 않지만, 사용자가 보고한 핵심 미세먼지 문제는 PM10·PM2.5이므로 Founder scope의 Gate 2 차단 필드에서는 제외한다. O3를 제품 결론에 사용하려면 별도 필수 기준을 먼저 추가한다. 성공한 `data` Payload의 필수 필드 누락만 `partial`이며 인증·권한·Timeout·Backend 오류는 `unavailable` 또는 해당 오류 Class로 둔다.

AirKorea 관측은 현재 상태, 예보는 지역·일 단위 배경으로만 검증한다. 이를 시간대별 대기질 최적 시각으로 해석하지 않으며, 초기 시간대 순위는 KMA 기상 조건과 AirKorea의 제한된 시간 해상도를 분리해 표시해야 한다.

이 합격 수치는 작은 고정 표본의 Engineering 판단 기준일 뿐 시장 품질이나 전국 가용성을 증명하지 않는다. 특정 Provider 장애나 공식 점검으로 미달하면 실패를 숨기지 않고 원인·기간을 기록하며, 범위 축소나 Canary 연장은 새 Decision으로 남긴다.

## 7. Pass·Block 기준

### Contract pass

- 정상·오류·빈 결과가 구분된다.
- ProviderEnvelope의 Source·시각·지역·단위·License·Attribution 매핑 근거가 남는다.
- 필수 원 필드가 누락되면 명시적으로 fail 또는 `partial`이 된다.
- Secret·정확 GPS 누출이 0건이다.
- Fallback Provider와 사유가 명시되며 조용한 전환이 없다.

### Canary 측정 완료

- 14개 연속 달력일을 포함하고 계획 호출의 95% 이상이 실행된다. 계획 점검이나 실행환경 장애는 원인·시간을 기록하며, 설명 없는 6시간 초과 공백이 있으면 측정을 연장한다.
- Age p50·p95·p99, 성공·유효 빈 결과·결측, 지역 Coverage, 호출량 Evidence가 있다.
- Secret·정확 GPS 누출은 0건이고 일일 호출량은 승인 상한의 80% 이하를 유지한다.

### Technical provider pass

- Contract pass와 Canary 측정 완료를 모두 충족한다.
- 필요한 필드·Age·Coverage의 `pre_registered_acceptance_criteria`는 [Founder scope](./founder-problem-evidence.md)에 맞춰 6.3의 초안 v1을 작성했다. Contract smoke 뒤 `canaryPlanId`·Hash·Category 매핑·발표 허용 지연을 고정해 상태를 `fixed_before_canary`로 바꾸기 전에는 Canary를 시작하거나 Technical pass를 판정하지 않는다.
- 사전 기준을 만족하지 못하면 기술 통과로 표시하지 않고 Provider·범위 축소 또는 중단을 Decision Log에 기록한다.
- KMA 기상특보의 실제 발표가 14일 동안 없으면 Endpoint 판정은 `pass_with_live_event_latency_not_observed`로만 기록한다. 실제 발표·정정·해제의 도착 지연이 검증된 것처럼 무제한 `pass` 또는 Freshness `verified`로 표시하지 않으며, 실제 Event가 생기면 즉시 재측정한다.
- 완료 결과로 `production_policy_threshold`를 승인할 수 있지만, 이를 과거 Canary 합격 판정에 소급 적용하지 않는다.

### Gate 2 최종 pass

- Decision Log에서 확정한 최종 Phase 1 필수 Provider가 모두 Technical provider pass를 충족한다. 미세먼지를 포함한 Founder scope 때문에 현재 필수 범위는 KMA와 AirKorea다. AirKorea 제외는 대기질 결론을 제거하는 별도 범위 축소 Decision 없이는 허용하지 않는다.
- 기상특보가 `pass_with_live_event_latency_not_observed`이면 최종 Gate 2 판정은 `passed_with_kma_warning_live_latency_not_observed`로만 기록하고 Owner, 실제 Event 재검증 Trigger와 누락·지연 시 Fail-closed 동작을 남긴다. 이를 숨긴 무제한 `passed` 표기는 금지한다.
- AirKorea를 필수 Provider로 유지한다면 제3유형 원본과 파생 설명·Cache·AI 입력, 위치 관련 절차의 적용 범위를 서면 확인 또는 전문 검토로 해소한다.
- AirKorea 조건을 해소하지 못하면 AirKorea와 대기질 결론을 Phase 1에서 제거하는 범위 축소를 Founder scope 문서와 Decision Log에 먼저 반영한다. 축소 승인도, 조건 해소도 없으면 Gate 2를 통과시키지 않는다.

### Production block

- KMA도 활용신청 시점 조건 Snapshot과 Attribution 검증 전 Production Release를 통과하지 않는다.
- AirKorea는 Gate 2에서 권리·위치 적용 범위를 해소해도 실제 운영계정 승인, 발급 시점 조건 Snapshot과 Attribution·원본/파생 분리 Test 전에는 Production을 차단한다.
- 행정안전부 긴급재난문자는 별도 이용허락 전 호출·구현·활성화 범위가 아니다.

## 8. 실행 결과표

| Provider | Contract Evidence | 오류 Evidence | 14일 Canary Evidence | License Evidence | License Decision | Workflow |
| --- | --- | --- | --- | --- | --- | --- |
| KMA 단기예보 | `not_run` | `not_run` | `not_run` | `not_verified` | `approved_for_dev` | `deferred_manual` |
| KMA 기상특보 | `not_run` | `not_run` | `not_run` | `not_verified` | `approved_for_dev` | `deferred_manual` |
| AirKorea 측정소·관측·예보 | `not_run` | `not_run` | `not_run` | `not_verified` | `conditional_for_production` | `deferred_manual` |

결과표는 실제 Evidence가 생긴 항목만 바꾼다. 활용신청이나 키 발급만으로 Contract 또는 Freshness를 통과 처리하지 않는다.

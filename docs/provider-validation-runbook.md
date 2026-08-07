# Phase 1 Provider 실검증 Runbook

- 최초 작성일: 2026-08-07
- 문서 상태: `ready_for_manual_prerequisites`
- 실행 상태: `not_run`
- 범위: 기상청 단기예보, 기상청 기상특보, AirKorea 대기오염정보·측정소정보
- 비범위: 제품 코드, 운영계정 승인, Production 적합성 확정, 행정안전부 긴급재난문자, TourAPI, 외부 지오코더, Web Push
- 관련 문서: [공공 데이터 카탈로그](./09-public-data-catalog.md), [Product License Register](./product-license-register.md), [사용자 수동 작업](./manual-action-checklist.md)

이 Runbook은 인증키를 받은 뒤 동일한 방법으로 Contract·오류·Freshness를 검증하기 위한 실행 명세다. 아직 API를 호출하지 않았으므로 아래 결과와 수치는 모두 계획이며, 실행 전에는 `verified`로 바꾸지 않는다.

## 1. Provider·Endpoint 범위

| Provider ID | 공식 상세 | 우선 검증 Endpoint | 개발 호출량 표시 | 현재 판정 |
| --- | --- | --- | --- | --- |
| `kma-data-go-kr-vilage-fcst` | [API 15084084](https://www.data.go.kr/data/15084084/openapi.do) | `/getUltraSrtNcst`, 초단기예보·단기예보 상세기능 | 한국어 상세 10,000회/일 | `approved_for_dev_not_run` |
| `kma-data-go-kr-weather-warning` | [API 15000415](https://www.data.go.kr/data/15000415/openapi.do) | `/getWthrWrnList`, 통보문·현황 상세기능 | 한국어 상세 10,000회/일 | `approved_for_dev_not_run` |
| `airkorea-air-measurement` | [API 15073861](https://www.data.go.kr/data/15073861/openapi.do) | 측정소별 실시간 측정, `/getMinuDustFrcstDspth` | 500회/일 | `approved_for_dev_not_run` |
| `airkorea-station` | [API 15073877](https://www.data.go.kr/data/15073877/openapi.do) | `/getMsrstnList`, 근접 측정소 상세기능 | 500회/일 | `approved_for_dev_not_run` |

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

Preconditions 중 하나라도 충족되지 않으면 실행 상태는 `deferred_manual`이며 실제 호출을 시도하지 않는다.

## 3. Evidence 규격

실행 도구는 원 응답을 공개 저장소에 그대로 저장하지 않는다. Sanitization 후 다음 Manifest만 공개 가능한 Evidence로 남긴다.

```yaml
runId: provider-date-sequence
providerId: kma-data-go-kr-vilage-fcst
endpoint: getUltraSrtNcst
fetchedAt: 0000-00-00T00:00:00+09:00
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
quality:
  missingRequiredFields: []
  status: not_run
license:
  registerId: null
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

매 호출에서 다음 값을 분리 기록한다.

- `fetchedAt`
- Provider의 `observedAt` 또는 `issuedAt`
- `validFrom`, `validUntil`
- 응답 성공·유효 빈 결과·결측·오류 Class
- Grid·시도·측정소 같은 축소 지역 식별자
- 당일 누적 호출량

14일 종료 시 Provider·Endpoint·지역별로 다음을 집계한다.

- 응답 성공률과 유효 빈 결과 비율
- 관측·발표 Age의 p50·p95·p99
- 결측·`partial`·`unavailable` 비율
- 지역 Coverage와 특정 측정소 의존도
- 사용 호출량과 승인량 대비 비율

14일이 끝나기 전에는 Freshness threshold를 확정하지 않는다. 공식 SLA가 아닌 관찰 표본이며 계절·장애·지역 한계를 함께 기록한다.

## 7. Pass·Block 기준

### Contract pass

- 정상·오류·빈 결과가 구분된다.
- ProviderEnvelope의 Source·시각·지역·단위·License·Attribution 매핑 근거가 남는다.
- 필수 원 필드가 누락되면 명시적으로 fail 또는 `partial`이 된다.
- Secret·정확 GPS 누출이 0건이다.
- Fallback Provider와 사유가 명시되며 조용한 전환이 없다.

### Freshness pass

- 14일 Canary가 중단 없이 완료된다.
- Age p50·p95·p99, 결측, Coverage, 호출량 Evidence가 있다.
- 결과를 근거로 Threshold와 Polling 예산을 재심의한다.

### Production block

- KMA도 활용신청 시점 조건 Snapshot과 Attribution 검증 전 Production Release를 통과하지 않는다.
- AirKorea는 개발 Contract·Freshness가 통과해도 운영계정, 위치 관련 절차, 제3유형 파생·AI·Cache 확인 전 차단한다.
- 행정안전부 긴급재난문자는 별도 이용허락 전 호출·구현·활성화 범위가 아니다.

## 8. 실행 결과표

| Provider | Contract | 오류 분류 | 14일 Canary | License release | 최종 상태 |
| --- | --- | --- | --- | --- | --- |
| KMA 단기예보 | `not_run` | `not_run` | `not_run` | `not_verified` | `deferred_manual` |
| KMA 기상특보 | `not_run` | `not_run` | `not_run` | `not_verified` | `deferred_manual` |
| AirKorea 측정소·관측·예보 | `not_run` | `not_run` | `not_run` | `conditional_for_production` | `deferred_manual` |

결과표는 실제 Evidence가 생긴 항목만 바꾼다. 활용신청이나 키 발급만으로 Contract 또는 Freshness를 통과 처리하지 않는다.

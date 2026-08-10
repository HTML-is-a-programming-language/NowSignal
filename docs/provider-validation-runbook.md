# Phase 1 Provider 실검증 Runbook

- 최초 작성일: 2026-08-07
- 문서 상태: `execution_in_progress`
- 실행 이력: `attempted_ten_runs`
- 현재 진행 상태: `blocked_pending_remaining_contract_c11_canary_and_airkorea_response` — Run 10에서 KMA 초단기예보·단기예보 C-01을 통과했다. AirKorea 공식 Schema 답변, 남은 Contract Case, 엄격한 C-11, 14일 Canary는 미완료다.
- 사용자 승인: 2026-08-10, Phase 1 개발용 API 활용신청·제한된 실호출, AirKorea Schema 충돌 문의 제출과 Run 10 KMA 예보 최대 2회 검증. 운영계정·Traffic 상향·제품 코드는 비범위
- 범위: 기상청 단기예보, 기상청 기상특보, AirKorea 대기오염정보·측정소정보
- 비범위: 제품 코드, 운영계정 승인, Production 적합성 확정, 행정안전부 긴급재난문자, TourAPI, 외부 지오코더, Web Push. 로컬 좌표→KMA 격자 변환과 측정소 선택 알고리즘은 Gate 4 설계·테스트 대상이며 이 Provider 실호출 Runbook이 검증 완료로 대신하지 않는다.
- 관련 문서: [창업자 문제 근거와 초기 범위](./founder-problem-evidence.md), [공공 데이터 카탈로그](./09-public-data-catalog.md), [Product License Register](./product-license-register.md), [C-11 ProviderEnvelope Evidence 명세](./provider-c11-envelope-evidence-spec.md), [Gate 2 Evidence Matrix](./gate-2-evidence-matrix.md), [Provider Fail-closed 판단 초안](./provider-fail-closed-draft.md), [사용자 수동 작업](./manual-action-checklist.md), [개발 활용신청 가이드](./provider-application-guide.md)

이 Runbook은 인증키를 받은 뒤 동일한 방법으로 Contract·오류·Freshness를 검증하기 위한 실행 명세다. 2026-08-10까지 열 개 Run ID를 사용했고 실제 호출은 보수적으로 12회 계상했다. KMA 단기예보 조회서비스의 정상 Endpoint 3개, KMA 특보 목록과 AirKorea 측정소 목록 C-01은 통과했다. Run 10은 KMA 초단기예보·단기예보에서 HTTP 200·Provider `00`·필수 Schema와 핵심 Category를 확인했다. 다만 C-11은 Capture만 수행하고 엄격한 결합을 `not_evaluated`로 유지한다. AirKorea 대기오염 Run 9 원본 C-01 `fail`과 공식 Schema `conflicting_official_schema`도 보존한다. Freshness·품질, 나머지 오류 Contract와 Canary는 미평가다. 아래에서 명시적으로 실행 결과라고 표시하지 않은 수치는 계속 계획이다.

## 1. Provider·Endpoint 범위

| Provider ID | 공식 상세 | 우선 검증 Endpoint | 보수적 실검증 상한 | 개발·License 판정 | 실행 이력 |
| --- | --- | --- | --- | --- | --- |
| `kma-data-go-kr-vilage-fcst` | [API 15084084](https://www.data.go.kr/data/15084084/openapi.do) | `/getUltraSrtNcst`, `/getUltraSrtFcst`, `/getVilageFcst` | 10,000회/일과 승인 화면 중 더 낮은 값 | `approved_for_dev` | 실황 `c01_pass_run_3`; 초단기·단기예보 `c01_pass_run_10` |
| `kma-data-go-kr-weather-warning` | [API 15000415](https://www.data.go.kr/data/15000415/openapi.do) | `/getWthrWrnList`, 통보문·현황 상세기능 | 10,000회/일과 승인 화면 중 더 낮은 값 | `approved_for_dev` | `c01_pass_run_5` |
| `airkorea-air-measurement` | [API 15073861](https://www.data.go.kr/data/15073861/openapi.do) | `/getMsrstnAcctoRltmMesureDnsty`, `/getMinuDustFrcstDspth` | 두 AirKorea API 합산 500회/일 | 개발 `approved_for_dev`, 운영 `conditional_for_production` | Run 6 `failed_c01_http_504_body_unobserved`; Run 7 `http_200_provider_00_c01_fail_local_validator`; Run 8 `preflight_abort_network0`; Run 9 원본 `c01_fail_station_name_missing`, 사후판정 `core_observation_consistent_with_live_table_and_sample_schema_conflict_open` |
| `airkorea-station` | [API 15073877](https://www.data.go.kr/data/15073877/openapi.do) | `/getMsrstnList`, 근접 측정소 상세기능 | 두 AirKorea API 합산 500회/일 | 개발 `approved_for_dev`, 운영 `conditional_for_production` | `c01_pass_run_5` |

2026-08-09 Live 상세 재확인에서 KMA 두 API의 [한국어](https://www.data.go.kr/data/15084084/openapi.do)·[영문](https://www.data.go.kr/en/data/15084084/openapi.do) 페이지는 개발 10,000회/일로 일치했고 기상특보도 [한국어](https://www.data.go.kr/data/15000415/openapi.do)·[영문](https://www.data.go.kr/en/data/15000415/openapi.do) 페이지가 같은 값을 표시했다. 과거 Locale 충돌 기록은 해소됐지만 실제 발급 화면의 승인량과 Reset 시각은 계속 `not_verified`다. AirKorea 두 API도 한·영문 개발 500회/일은 일치하고 [공공데이터포털 사용자 지원 API](https://www.data.go.kr/data/15075624/openapi.do)는 계정별 개발 500회/일을 명시하므로 두 API 합산 500회의 보수적 예산을 유지한다. 다만 영문 페이지는 상단의 운영 수동 심의와 선택된 상세기능의 운영 불가 표시가 내부에서 충돌한다. 실제 발급 화면의 승인량·Reset 시각과 운영 가능 여부는 승인 화면·기관 확인 전 `not_verified`로 유지한다.

기상청 API허브는 별도 계정·키·약관·Quota를 쓰므로 이 Runbook의 공공데이터포털 Provider와 혼합하지 않는다.

## 2. 실행 전 수동 Preconditions

사용자가 2026-08-10 개발용 API 활용신청·실호출을 승인했다. 아래 항목을 [수동 작업 체크리스트](./manual-action-checklist.md)에 따라 순서대로 수행하되, 운영계정·Traffic 상향·제품 코드는 별도 승인 전 진행하지 않는다.

- [x] 대상 API별 개발 활용신청·승인 상태 확인 — 4건 모두 승인, 2026-08-10~2028-08-10
- [ ] 발급 시점 상세 페이지·약관·승인 호출량을 식별정보와 키를 가린 Evidence로 보관
- [ ] 발급 후 승인 화면과 사용자 지원 API의 `getSvckeyDalyStats`로 실제 계정별 승인량·사용량·Reset 기준을 확인
- [x] 현재 작업 PC에서 키를 `%LOCALAPPDATA%\NowSignal\Secrets\data-go-kr.clixml`에 Windows 사용자 범위 DPAPI CLIXML로 저장하고 같은 사용자 컨텍스트에서 Import 가능 여부만 확인 — 값 비출력
- [x] KST·UTC가 정확한 실행 환경 확인 — Windows 실행 시각 `+09:00`, Project 기준 `Asia/Seoul`
- [ ] 항상 켜진 14일 Canary 실행 환경과 호출 예산 승인
- [x] 정확 GPS가 아닌 고정 KMA 격자, 시·도, 공개 측정소 Test target 확정 — `nx=60`, `ny=127`, 서울·종로구 공개 Test target

대상 API의 개발 활용승인과 Secret 안전 로드 전에는 실제 호출을 시도하지 않는다. 네 활용신청과 같은 사용자 Context의 Secret Import는 완료됐지만 실제 승인 Traffic, 전체 Contract, 14일 Canary는 아직 확인되지 않았다.

DPAPI CLIXML은 Git·OneDrive 동기화 대상이 아니며 다른 PC나 다른 Windows 사용자로 옮겨 복호화하는 용도가 아니다. 다른 PC에서 이어갈 때는 해당 PC의 안전한 Prompt로 값을 다시 입력해 그 PC 사용자 범위 Secret을 만든 뒤 Import·C-12를 새로 확인한다.

## 3. Evidence 규격

실행 도구는 원 응답을 공개 저장소에 그대로 저장하지 않는다. Sanitization 후 다음 Manifest만 공개 가능한 Evidence로 남긴다.

```yaml
runId: provider-date-sequence
providerId: kma-data-go-kr-vilage-fcst
endpoint: getUltraSrtNcst
evaluatedAt: null
fetchedAt: null
request:
  secretRemoved: null
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
  missingRequiredFields: null
license:
  registerId: null
  status: null
  attributionPresent: null
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
| `C-11` | [사전등록 명세](./provider-c11-envelope-evidence-spec.md)에 따른 필수 Source·시각·지역·단위·License·Attribution 추출 | 하나라도 없거나 Binding이 미검증이면 Contract fail |
| `C-12` | Secret Redaction 검사 | URL·stdout·fixture·Git diff에 key 흔적 0건 |

공공데이터포털의 Provider error code와 HTTP status는 서로 대체하지 않는다. HTTP 200 안의 오류 payload도 실패로 분류한다.

C-11의 문서·Manifest·Assertion 형식은 `offline_spec_ready`다. KMA 예보 3개 Endpoint의 queryless `sourceUrl`과 제1유형 일반증서 `license.termsUrl`은 `verified`지만, 엄격한 Null·단위·License scope·Attribution·Layer Assertion은 미완료다. Run 10 예보 2개 C-11은 Capture-only `not_evaluated`, 실황과 나머지 Provider는 `not_run`이며 실제 C-11 `pass`는 없다. 정적 License·공식 Sample·C-01 성공을 실제 결합 `pass`로 대체하지 않는다.

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
| AirKorea 두 API 합산 | 측정소 2회 + 2개 측정소 × 24회 + 예보 4회 = 54 | 100 (Contract·Retry·결측 조사 포함) | 공개 계정별 500 기준 20% | 실제 승인량·Reset 시각, 측정소·예보 호출 단위 |

Reserve는 고의 Rate Limit·Quota 소진 시험에 쓰지 않는다. 첫날 Contract smoke도 해당 일일 Cap 안에서 수행한다. 실제 승인 상한이 이 표보다 낮거나 호출 단위가 예상보다 크면 target·주기를 줄여 새 예산표를 승인하기 전 Canary를 시작하지 않는다.

#### 6.1.1 첫날 Contract smoke 고정 계획

- `contractSmokePlanId`: `contract-smoke-20260810-v1`
- 고정 시각: 2026-08-10 01:28 KST
- 계획 상태: `run_1_failed_and_stopped`
- Secret: 공공데이터포털 일반 인증키 Decoding 값을 Windows 사용자 범위 DPAPI CLIXML로 로드. 값·일부·Encoded 변형은 출력·저장 금지
- 실행: 직렬, 요청 간 2초, Timeout 15초, Retry 0, Parallel 0, Redirect 0
- 호출 계획: 정상 C-01 10회 + Provider ID 4개 × 오류 C-06·C-07·C-03·C-04 4회 = 26회
- 첫날 Hard cap: 전체 30회, AirKorea 두 API 합산 12회
- 비범위: C-02 XML 비교, C-05 운영 권한, 실제 Quota 소진 C-10, 14일 Canary

외부 호출 전에 C-12 로컬 검사를 먼저 수행한다. 저장소·환경변수·출력 예정 문자열에서 Decoding 키 원문과 1회 URL-encoded 변형이 각각 0건이고 Secret 경로가 Repository·OneDrive 밖일 때만 네 Sentinel을 순서대로 1회씩 호출한다.

| 순서 | Provider | Endpoint | 공개 Parameter |
| ---: | --- | --- | --- |
| 1 | KMA 단기예보 | `/getUltraSrtNcst` | `pageNo=1`, `numOfRows=10`, `dataType=JSON`, `base_date=20260810`, `base_time=0000`, `nx=60`, `ny=127` |
| 2 | KMA 기상특보 | `/getWthrWrnList` | `pageNo=1`, `numOfRows=10`, `dataType=JSON`, `fromTmFc=20260810`, `toTmFc=20260810`; `stnId` 생략 |
| 3 | AirKorea 측정소 | `/getMsrstnList` | `returnType=json`, `numOfRows=10`, `pageNo=1`, `addr=서울`, `stationName=종로구` |
| 4 | AirKorea 대기오염 | `/getMsrstnAcctoRltmMesureDnsty` | `returnType=json`, `numOfRows=1`, `pageNo=1`, `stationName=종로구`, `dataTerm=DAILY`, `ver=1.3` |

Sentinel 네 건이 모두 인증·권한·TLS·Redirect·Schema 차단 없이 통과한 경우에만 다음 정상 Endpoint를 각 1회 호출한다.

| Provider | Endpoint | 공개 Parameter |
| --- | --- | --- |
| KMA 단기예보 | `/getUltraSrtFcst` | `pageNo=1`, `numOfRows=100`, `dataType=JSON`, `base_date=20260810`, `base_time=0030`, `nx=60`, `ny=127` |
| KMA 단기예보 | `/getVilageFcst` | `pageNo=1`, `numOfRows=200`, `dataType=JSON`, `base_date=20260809`, `base_time=2300`, `nx=60`, `ny=127` |
| KMA 기상특보 | `/getWthrWrnMsg` | 목록과 같은 날짜·Pagination Parameter. 정상 빈 결과는 허용하지만 전문 Schema는 `not_observed` 유지 |
| KMA 기상특보 | `/getPwnStatus` | `pageNo=1`, `numOfRows=10`, `dataType=JSON` |
| AirKorea 측정소 | `/getNearbyMsrstnList` | `returnType=json`, `tmX=200089`, `tmY=453946`; `ver` 생략 |
| AirKorea 대기오염 | `/getMinuDustFrcstDspth` | `returnType=json`, `numOfRows=10`, `pageNo=1`, `searchDate=2026-08-09`; `InformCode` 생략 |

위 정상 10회가 모두 끝난 뒤에만 Provider ID별로 C-06 → C-07 → C-03 → C-04를 1회씩 실행한다. C-06은 단기예보 `base_date=202608XX`, 특보 `pageNo=NaN`, 대기측정 `stationName` 누락, 근접측정소 `tmX=NaN`을 사용한다. C-07은 각 공식 Service base의 `/__nowsignal_contract_missing__`, C-03은 정상 Parameter에서 키 완전 생략, C-04는 실제 키와 무관한 고정 Synthetic invalid key를 사용한다. 실제 Quota를 고의 소진하지 않는다.

다음 중 하나면 후속 호출을 즉시 중단한다.

- Sentinel의 인증·권한 거부, TLS 실패 또는 Redirect
- 응답이 JSON으로 해석되지 않거나 HTTP와 Provider code를 분리할 수 없음
- Secret 원문·Encoded 변형이 stdout, 저장 파일, Git diff 또는 예외 출력에 1건 이상 검출
- 실제 호출 수가 계획 또는 Hard cap을 초과할 위험

공개 Evidence에는 Plan ID, Case, Provider ID, Endpoint path, 공개 Parameter, HTTP status, Provider code·message class, item count, 정렬한 필드명·Type signature, 공개 Category·Code 집합, 시각, 공개 Grid·측정소, 누락 필드, License ID, Attribution 존재 여부, Sanitized projection SHA-256, 호출 순번·Duration과 판정만 남긴다. 원 응답, Full URL, 특보 제목·전문, 대기수치, Exception 원문과 Screenshot은 저장하지 않는다. 이 고정 시각 Parameter는 Contract 확인용이며 Freshness 근거로 사용하지 않는다.

#### 6.1.2 첫 실행 결과

- `runId`: `contract-smoke-20260810-r1`
- 실행일: 2026-08-10 KST
- C-12: `pass` — Repository 원문 0건, Repository 1회 URL-encoded 변형 0건, 환경변수 원문 0건, 환경변수 encoded 변형 0건, Secret 경로 Repository·OneDrive 밖
- C-01 순서 1: `/getUltraSrtNcst`, HTTP 403, `System.Net.WebException`, 136ms, Retry 0
- 판정: `http_forbidden_unclassified`; 응답 Body·Provider result code·message는 관찰·보관하지 못했고 Schema도 `not_observed`
- C-11: 정적 License 사전검토와 별개로 실제 응답 결합은 `not_observed_due_c01_failure`
- 전역 중단: 나머지 정상 9회와 오류 16회, 합계 25회는 `not_run_due_global_stop`; Canary도 `not_run`
- Secret: 원문·일부·encoded 변형과 Full URL을 출력·보관하지 않았고 요청 후 메모리 참조를 제거

사후 로컬 형상 검사에서 저장된 Secret이 `%xx`를 포함한 사전 Encoding 값으로 판정됐고 Decoding 예약문자는 관찰되지 않았다. PowerShell GET Hashtable은 값을 다시 URL-encode하므로 이중 인코딩이 403의 유력 원인이지만, 응답 Body를 관찰하지 못했으므로 Provider가 반환한 정확한 오류 원인은 확정하지 않는다. 기존 Run은 Retry 0 원칙에 따라 닫고, 올바른 Decoding 키 저장·C-12 재검사·공개 요청 명세 대조 후 새 `runId`로만 Sentinel을 재개한다.

무호출 진단에서 System proxy, proxy 환경변수, 활성 VPN 유사 Adapter와 PowerShell Transcript 정책은 모두 검출되지 않았고 Verbose·Debug 기본값도 출력 억제 상태였다. PowerShell 5.1의 합성 요청에서는 Decoding형 값이 정확히 1회 인코딩되고 GET Body 없이 Query로 전송되는 것을 확인했다. 다만 현재 KMA 상세의 `ServiceKey` 표기와 공공데이터포털 Gateway 가이드·동일 Endpoint 공식 지원 답변의 `serviceKey` 표기가 충돌한다. 첫 Run은 uppercase를 사용했으므로 새 Run은 기존 Hashtable을 수정하지 않고 lowercase `serviceKey`를 첫 항목으로 둔 새 Ordered Hashtable을 사용해 이 변수를 제거한다. HTTP 403만으로 key case·이중 인코딩·승인 직후 동기화 지연 중 하나를 확정하지 않는다.

#### 6.1.3 Run 2 사전등록

- `planId`: `contract-smoke-20260810-v2`
- `parentPlanId`: `contract-smoke-20260810-v1`; Run 1 결과는 수정하거나 덮어쓰지 않음
- `runId`: `contract-smoke-20260810-r2`
- 고정 시각: 2026-08-10 01:42 KST
- 공개 명세 SHA-256: `a21dae58f7b392779ffd12b7a55268eb084866546d4d9e56fd404295e90ab994`
- Secret 상태: 일반 인증키 Decoding 형태·DPAPI Import 확인, 교체 후 C-12 원문·encoded 흔적 각 0건, Repository·OneDrive 밖
- 첫 요청: KMA 단기예보 `/getUltraSrtNcst`, C-01, v1과 동일한 공개 Parameter
- 변경점: fresh Ordered Hashtable의 첫 항목을 lowercase `serviceKey`로 고정. 키 값은 공개 명세와 Hash에 포함하지 않음
- 통제: HTTPS, Timeout 15초, Response 2 MiB 상한, Retry 0, Parallel 0, Redirect 0, `-Verbose`·`-Debug`·Transcript 금지
- 누적 호출: Run 1의 1회를 포함해 첫 Sentinel 뒤 당일 2회. 첫날 전체 Hard cap 30회 유지
- 판정: HTTP·Provider code·JSON Schema를 분리해 Sanitized metadata만 출력. 다시 403이거나 인증·권한·TLS·Redirect·Schema 차단이면 즉시 중단

공공데이터포털 [공식 지원 답변](https://www.data.go.kr/bbs/qna/selectQna.do?qnaId=QNA_0000000000058342)은 활용신청 후 인증키 동기화에 적어도 10분이 걸릴 수 있다고 안내하고, [동일 KMA Endpoint 답변](https://www.data.go.kr/bbs/qna/selectQna.do?qnaId=QNA_0000000000038393)은 제공기관별 시간이 다르며 재발급은 가급적 피하라고 안내한다. 이는 고정 SLA가 아니므로 Run 결과 없이 동기화 지연을 원인으로 확정하지 않는다.

#### 6.1.4 Run 2 실행 결과

- 실행시각: 2026-08-10 01:45:46 KST
- C-01 순서 1: `/getUltraSrtNcst`, HTTP 401, `System.Net.WebException`, 132ms, Retry 0
- 판정: `http_unauthorized_unclassified`; 응답 Body·Provider result code·message는 관찰·보관하지 못했고 Schema도 `not_observed`
- 전역 중단: Run 2에서 다른 Provider와 Endpoint는 호출하지 않음. 당일 실제 외부 호출 누적 2회
- 호출 후 C-12: Repository·환경변수의 원문·encoded 흔적 각 0건으로 `pass`
- 해석 제한: Encoding 키 문제는 제거됐지만 HTTP 401만으로 포털 키–승인 연결 불일치와 제공기관 동기화 미완료를 구분할 수 없음
- 재개 조건: 재발급 없이 포털 API 미리보기와 승인 상세에서 같은 일반 인증키의 연결 상태를 확인하고, 미리보기 성공·실패를 구분해 기록한 뒤 새 Plan·Run을 고정

#### 6.1.5 포털 미리보기 진단

- 확인일: 2026-08-10 KST
- 포털 미리보기 관찰: KMA `/getUltraSrtNcst`가 XML `resultCode=10`과 `최근 1일 간의 자료만 제공합니다.`를 반환
- 제한부 판정: 인증 오류가 아니라 날짜 범위 Validation까지 도달했다는 점에서 포털 미리보기의 키가 받아들여졌다고 추론한다. 정상 Data·JSON Schema·필수 필드는 여전히 `not_observed`

#### 6.1.6 Run 3 사전등록

- 고정시각: 2026-08-10 02:24 KST
- Secret 상태: 입력값을 Decoding 형태로 정규화하고 Windows 사용자 범위 DPAPI Import 확인. C-12 Repository·환경변수 원문·encoded 흔적 각 0건
- `planId`: `contract-smoke-20260810-v3`
- `parentPlanId`: `contract-smoke-20260810-v2`; 이전 실패 기록 유지
- `runId`: `contract-smoke-20260810-r3`
- 공개 명세 SHA-256: `f2a799d2f9ab0c1100c8bc44f82f3bb1586df1eb970e765a1e5c254e8d13049e`
- 첫 요청: KMA `/getUltraSrtNcst`, `pageNo=1`, `numOfRows=10`, `dataType=JSON`, `base_date=20260810`, `base_time=0200`, `nx=60`, `ny=127`
- 직렬화 변경: 브라우저 미리보기와 같이 Decoding 값을 `[Uri]::EscapeDataString`으로 정확히 1회 변환해 lowercase `serviceKey` Query를 직접 구성. Full URI는 출력·보관하지 않음
- 통제: HTTPS, Timeout 15초, Response 2 MiB 상한, Retry 0, Parallel 0, Redirect 0, `-Verbose`·`-Debug`·Transcript 금지
- 판정: Sentinel 1회만 실행. 다시 인증·권한·TLS·Redirect·Schema 오류면 즉시 중단

#### 6.1.7 Run 3 실행 결과

- 실행시각: 2026-08-10 02:28:33 KST
- KMA 단기예보 C-01: HTTP 200, Provider code `00`, `success`, Item 8개, 124ms, Retry 0, `pass`
- Field signature: `baseDate:String`, `baseTime:String`, `category:String`, `nx:Int32`, `ny:Int32`, `obsrValue:String`
- Category set: `PTY`, `REH`, `RN1`, `T1H`, `UUU`, `VEC`, `VVV`, `WSD`
- Sanitized projection SHA-256: `bfe3a30b17e133e353bf89da5ba5dc2d30b28ca2d4827a18ade1f123fafd512e`
- 응답 크기: 908 bytes. 원 응답·관측값·Full URI는 저장하지 않음
- 호출 후 C-12: Repository·환경변수의 원문·encoded 흔적 각 0건으로 `pass`
- 범위 제한: `/getUltraSrtNcst` C-01 하나만 통과했으며 다른 Endpoint, 오류 Case, C-11 결합, Canary는 아직 통과하지 않음

#### 6.1.8 Run 4 나머지 Sentinel 사전등록

- 고정시각: 2026-08-10 02:29 KST
- `planId`: `contract-smoke-20260810-v4`
- `parentPlanId`: `contract-smoke-20260810-v3`
- `runId`: `contract-smoke-20260810-r4`
- 공개 명세 SHA-256: `ef1761d16bf903fb142f1b3d5a9515a040ebe890c4362243b20dae8654772297`
- 순서 1: KMA 기상특보 `/getWthrWrnList`, `pageNo=1`, `numOfRows=10`, `dataType=JSON`, `fromTmFc=20260810`, `toTmFc=20260810`
- 순서 2: AirKorea 측정소 `/getMsrstnList`, `returnType=json`, `numOfRows=10`, `pageNo=1`, `addr=서울`, `stationName=종로구`
- 순서 3: AirKorea 대기오염 `/getMsrstnAcctoRltmMesureDnsty`, `returnType=json`, `numOfRows=1`, `pageNo=1`, `stationName=종로구`, `dataTerm=DAILY`, `ver=1.3`
- 통제: 직접 Query 1회 encoding, 직렬, 요청 간 2초, Timeout 15초, Response 2 MiB 상한, Retry 0, Redirect 0
- 중단: 한 건이라도 인증·권한·TLS·Redirect·Schema 오류면 후속 Sentinel을 호출하지 않음

#### 6.1.9 Run 4 실행 결과와 Run 5 사전등록

- Run 4 첫 실행은 PowerShell Parser 오류로 외부 호출 0건
- 구문 수정 실행은 KMA 특보 첫 요청의 응답 처리 Helper에서 `CommandNotFoundException`이 발생해 응답 판정을 만들지 못함. 요청 전송 여부를 보수적으로 1회로 계상하고 `attempted_result_not_observed_due_local_handler_error`로 닫음
- Run 4의 AirKorea 두 Sentinel은 `not_run_due_global_stop`; Retry 0 원칙에 따라 같은 Run을 재개하지 않음
- 사후 Offline 합성 응답으로 같은 Helper 오류를 재현했고, Repository key 흔적 0건으로 C-12 `pass`
- 당일 보수적 누적 호출량: 4회
- `planId`: `contract-smoke-20260810-v5`
- `parentPlanId`: `contract-smoke-20260810-v4`
- `runId`: `contract-smoke-20260810-r5`
- 고정시각: 2026-08-10 02:34 KST
- 공개 명세 SHA-256: `a3b417d7a92ff8d2972307464eef51f2596c226c891ba01e641cbb96893089c8`
- 대상과 공개 Parameter: Run 4의 세 Sentinel과 동일
- 변경점: 각 Sentinel을 별도 Process로 실행하고, 실제 호출 전 동일 Sanitizer를 합성 응답으로 통과시킨 뒤 진행
- 통제와 중단 조건: 직접 Query 1회 encoding, Timeout 15초, Response 2 MiB, Retry 0, Redirect 0. 실패 시 다음 Sentinel 미실행

#### 6.1.10 Run 5 실행 결과

- KMA 기상특보 `/getWthrWrnList`: 2026-08-10 02:35:39 KST, HTTP 200, Provider `00`, Item 2개, 113ms, `pass`
- KMA 기상특보 Field signature: `stnId:String`, `title:String`, `tmFc:Int64`, `tmSeq:Int32`
- KMA 기상특보 Sanitized projection SHA-256: `1097bdcd75c72d4e693d667bed2118310deb92ddcaa290dc5ac0e0eb1ce83509`
- AirKorea 측정소 `/getMsrstnList`: 2026-08-10 02:36:20 KST, HTTP 200, Provider `00`, Item 1개, 107ms, `pass`
- AirKorea 측정소 Field signature: `addr:String`, `dmX:String`, `dmY:String`, `item:String`, `mangName:String`, `stationName:String`, `year:String`
- AirKorea 측정소 Sanitized projection SHA-256: `de265aaf0a60aa5bd2b16ec8b5fc41eee5ab759f1c05380d33fb387db9cf84b6`
- AirKorea 대기오염 `/getMsrstnAcctoRltmMesureDnsty`: 2026-08-10 02:37:10 KST, HTTP status·Provider code·Body 미관찰, `System.Management.Automation.MethodInvocationException`, 5,086ms, `transport_or_parse_error`, `fail`
- Retry 0 원칙에 따라 Run 5 종료. 당일 보수적 누적 호출량 7회
- 호출 후 C-12: Repository·환경변수 원문·encoded 흔적 각 0건으로 `pass`
- 범위 제한: KMA 두 Provider와 AirKorea 측정소 C-01만 통과. AirKorea 대기오염 C-01, 나머지 정상 Endpoint, 오류 Case, C-11, Canary는 미통과

#### 6.1.11 Run 6 AirKorea 대기오염 사전등록

- 무호출 진단: `apis.data.go.kr` DNS 해석, HTTPS Scheme·예상 Host, System proxy 없음, 공개 Query encoding round-trip 모두 통과
- Offline 합성 진단: `MethodInvocationException`의 Inner exception을 최대 5단계까지 안전하게 분류하는 Handler 통과
- `planId`: `contract-smoke-20260810-v6`
- `parentPlanId`: `contract-smoke-20260810-v5`
- `runId`: `contract-smoke-20260810-r6`
- 고정시각: 2026-08-10 02:49 KST
- 공개 명세 Canonical JSON(UTF-8, 줄바꿈 없음):

```json
{"planId":"contract-smoke-20260810-v6","parentPlanId":"contract-smoke-20260810-v5","runId":"contract-smoke-20260810-r6","fixedAt":"2026-08-10T02:49:00+09:00","scheme":"https","host":"apis.data.go.kr","endpointPath":"/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty","method":"GET","parameters":[["returnType","json"],["numOfRows","1"],["pageNo","1"],["stationName","종로구"],["dataTerm","DAILY"],["ver","1.3"]],"keyParameter":"serviceKey","keyEncoding":"decode_then_EscapeDataString_once","transport":"HttpWebRequest","sentinelCalls":1,"retry":0,"parallel":0,"redirect":0,"timeoutSeconds":15,"readWriteTimeoutSeconds":15,"responseLimitBytes":2097152,"automaticDecompression":["GZip","Deflate"],"keepAlive":false,"preCallCount":7,"hardCap":30,"prePostC12":true,"c12Scope":["tracked","untracked","environment"],"processIsolation":true,"exceptionMaxDepth":5,"exceptionPolicy":"preserve_first_WebException_and_deepest_class","output":"sanitized_allowlist_only"}
```

- 공개 명세 SHA-256: `d270545f6b95161ae72bbf681bfdc4fa9c5ce3ddc4a8265ed6ec2a2b39a75d2e`
- 요청: `/getMsrstnAcctoRltmMesureDnsty`, Run 5와 같은 공개 Parameter
- 변경점: 외부 호출·직렬화는 바꾸지 않고 오류 발생 시 Inner exception의 Class·WebExceptionStatus·HTTP status만 Sanitized 출력
- 통제: HTTPS, Sentinel 1회, 병렬 0, Timeout·ReadWriteTimeout 15초, Stream read 2 MiB 상한, Retry 0, Redirect 0, 당일 보수적 기존 호출 7회·Hard cap 30회
- C-12: 호출 전후에 추적·미추적 파일과 환경변수에서 원문·1회 encoded 형태를 내부 비교하고 Count만 출력한다.
- 출력 Allowlist: 실행 단계, HTTP status, Provider code·Message class, Item count, Field name·type, Null field, 응답 Byte 수, Sanitized projection SHA-256, 예외 Class·Depth·잘림 여부·WebExceptionStatus, 소요시간, 호출 수, C-12 Count·판정만 허용한다. Full URL·키·원 응답·예외 원문·Stack trace·Header는 출력하지 않는다.

#### 6.1.12 Run 6 실행 결과와 무호출 판정

- 격리 실행 Context의 DPAPI Import 사전점검은 `CryptographicException`으로 종료됐고 외부 호출은 0건이었다. 같은 Windows 사용자 Context에서 값 비출력 Import를 다시 확인한 뒤 사전등록 Run 6을 실행했다.
- 실행시각: 2026-08-10 02:53:39 KST
- Plan·Run·공개 명세: `contract-smoke-20260810-v6`, `contract-smoke-20260810-r6`, SHA-256 `d270545f6b95161ae72bbf681bfdc4fa9c5ce3ddc4a8265ed6ec2a2b39a75d2e`
- 요청 단계에서 HTTP 504를 5,390ms에 수신했다. 외부 호출 1건, Retry 0, Redirect 0이며 Run은 즉시 종료했다.
- Sanitized 예외 분류: Outer `System.Management.Automation.MethodInvocationException`, 첫 WebException·Root `System.Net.WebException`, Inner depth 1, Chain 잘림 없음, `WebExceptionStatus=ProtocolError`
- Provider code와 Body는 `not_observed`. 원 응답·Full URL·Header·예외 원문은 저장하지 않았다.
- C-12: 호출 전후 각각 추적·미추적 파일과 환경변수의 원문·1회 encoded Count가 모두 0으로 `pass`
- 당일 보수적 누적 호출량: 8회. Run 6 Plan conformance는 `pass`, AirKorea 대기오염 `C-01=fail`, `rootCause=unclassified`

Sanitized 실행 Manifest Canonical JSON(UTF-8, 줄바꿈 없음):

```json
{"runId":"contract-smoke-20260810-r6","evaluatedAt":"2026-08-10T02:53:39+09:00","planSha256":"d270545f6b95161ae72bbf681bfdc4fa9c5ce3ddc4a8265ed6ec2a2b39a75d2e","networkCalls":1,"phase":"send","endpointPath":"/getMsrstnAcctoRltmMesureDnsty","httpStatus":504,"providerCode":null,"bodyStatus":"not_observed","schemaStatus":"not_observed","outerErrorClass":"System.Management.Automation.MethodInvocationException","rootErrorClass":"System.Net.WebException","innerDepth":1,"chainTruncated":false,"webExceptionStatus":"ProtocolError","durationMs":5390,"retry":0,"redirect":0,"c12Pre":{"rawRepo":0,"encodedRepo":0,"rawEnv":0,"encodedEnv":0},"c12Post":{"rawRepo":0,"encodedRepo":0,"rawEnv":0,"encodedEnv":0},"secretReferencesCleared":true,"rawResponseStored":false,"fullUrlStored":false,"resultKind":"unavailable","errorClass":"http_504_gateway_timeout_origin_unclassified","planConformance":"pass","c01":"fail","c09":"not_run","c10":"not_run","runClosed":true,"cumulativeCalls":8}
```

- Sanitized 실행 Manifest SHA-256: `93f814f3613a6afad82243b01a17cec36b199065e9f711704b9b9fad3fd0d68f`
- 결과 분류: `http_504_gateway_timeout_origin_unclassified`. HTTP 504가 Client Timeout 15초보다 먼저 반환됐지만, 공공데이터포털 Gateway와 제공기관 Backend 중 원인은 확정하지 않는다. 인증·Parameter·Schema 실패 또는 Endpoint 폐기로 분류하지 않는다.
- Offline 교차검증: Canonical JSON의 GET·HTTPS·Host·Operation·공개 Parameter와 실행 명세가 일치하고 SHA-256 재계산도 일치했다. 같은 Host의 AirKorea 측정소 Sentinel이 앞서 HTTP 200으로 통과했으므로 PC 전체 네트워크나 공통 인증 문제보다 이 Operation의 Route·Backend 가설이 상대적으로 높지만 확정 Evidence는 아니다.
- Offline 합성 504 분류 Fixture는 `MethodInvocationException` → `WebException`, Depth 1, `ProtocolError`를 원문 없이 정확히 분류해 `pass`했다.
- 공식 근거: [AirKorea API 오류 정의](https://www.data.go.kr/data/15073861/openapi.do)는 기관 API·Gateway 연계 실패 또는 응답 대기 초과를 `SERVICETIMEOUT_ERROR(05)`로 설명하며, [공공데이터포털 오류 안내](https://www.data.go.kr/data/15124045/fileData.do)도 Backend 연결 실패·응답 미수신을 별도 분류한다. 현재 오류 Body가 관찰되지 않았으므로 공식 code `05`를 실제 관찰값으로 소급 기록하지 않는다.
- 2026-08-10 공식 공지·오류신고 읽기 전용 확인에서 이 Operation의 현행 장애 공지는 발견하지 못했다. 공지 부재를 정상 Evidence로 쓰지 않는다. [동일 Operation의 과거 504 공식 Q&A](https://www.data.go.kr/bbs/qna/selectQna.do?qnaId=QNA_0000000000053524)는 제공기관 연계 장애 선례일 뿐 현재 원인의 직접 증거가 아니다.
- 무호출 검토 결과: 공개 명세·Hash·Manifest 연결, 504 Classifier, 2 MiB Stream 상한, 예외 출력 Allowlist, C-12 범위가 확인됐다. 기존 Process가 종료돼 Response Header는 `not_observed`로 유지하며 복구를 시도하지 않는다.
- 다음 단계: 새 Plan·Hash·Run의 재개 여부를 결정한다. 포털 미리보기와 Sentinel 재실행은 각각 실제 호출 1건으로 계산한다.

#### 6.1.13 Run 7 AirKorea 대기오염 로컬 Sentinel 사전등록

- 사용자 결정: 2026-08-10, Run 6 무호출 검토 후 브라우저 미리보기가 아닌 로컬 Sentinel 1회 재개
- 공식 사전점검: 현행 Endpoint·Parameter 계약 변경 없음. 2026-08-10 서울·전 서비스 점검 공지는 관찰되지 않았고, 활성 충북권역 데이터 미수신 공지는 종로구 Run의 직접 차단 근거가 아니다. 공지 부재는 정상 보증이 아니다.
- `planId`: `contract-smoke-20260810-v7`
- `parentPlanId`: `contract-smoke-20260810-v6`
- `parentRunId`: `contract-smoke-20260810-r6`
- `runId`: `contract-smoke-20260810-r7`
- 고정시각: 2026-08-10 07:38:37 KST
- Run 6 Plan SHA-256: `d270545f6b95161ae72bbf681bfdc4fa9c5ce3ddc4a8265ed6ec2a2b39a75d2e`
- Run 6 Manifest SHA-256: `93f814f3613a6afad82243b01a17cec36b199065e9f711704b9b9fad3fd0d68f`

Run 7 공개 명세 Canonical JSON(UTF-8, 줄바꿈 없음):

```json
{"planId":"contract-smoke-20260810-v7","parentPlanId":"contract-smoke-20260810-v6","parentRunId":"contract-smoke-20260810-r6","parentPlanSha256":"d270545f6b95161ae72bbf681bfdc4fa9c5ce3ddc4a8265ed6ec2a2b39a75d2e","parentManifestSha256":"93f814f3613a6afad82243b01a17cec36b199065e9f711704b9b9fad3fd0d68f","parentOutcome":"c01_fail_http_504_origin_unclassified","resumptionReason":"owner_selected_local_sentinel_after_run_6_offline_review","ownerApproval":"explicit_run_7_approval_received","runId":"contract-smoke-20260810-r7","fixedAt":"2026-08-10T07:38:37+09:00","budgetDate":"2026-08-10","budgetTimezone":"Asia/Seoul","scheme":"https","host":"apis.data.go.kr","endpointPath":"/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty","method":"GET","requestBody":"none","parameters":[["returnType","json"],["numOfRows","1"],["pageNo","1"],["stationName","종로구"],["dataTerm","DAILY"],["ver","1.3"]],"keyParameter":"serviceKey","queryParameterOrder":["serviceKey","returnType","numOfRows","pageNo","stationName","dataTerm","ver"],"keySource":"windows_current_user_dpapi_external_to_repo","sameUserSidRequired":true,"secretPathOutsideRepoAndOneDriveRequired":true,"keyEncoding":"decode_then_EscapeDataString_once","serviceKeyCountRequired":1,"keyRoundTripRequired":true,"transport":"HttpWebRequest","executionMode":"local_sentinel","sentinelCalls":1,"networkCallUpperBound":1,"networkCallSiteUpperBound":1,"retry":0,"parallel":0,"redirect":0,"timeoutSeconds":15,"readWriteTimeoutSeconds":15,"responseLimitBytes":2097152,"automaticDecompression":["GZip","Deflate"],"keepAlive":false,"preCallCount":8,"expectedPostCallCount":9,"hardCap":30,"prePostC12":true,"c12Scope":["tracked","untracked","environment"],"c12Representations":["raw","url_encoded_once"],"c12ScanErrorsMustBeZero":true,"abortOnC12NonZero":true,"processIsolation":true,"exceptionMaxDepth":5,"exceptionPolicy":"preserve_first_WebException_and_deepest_class","consoleOutput":"single_sanitized_json_allowlist_only","rawResponseStorage":false,"fullUrlStorage":false,"successCriteria":"http200_provider00_json_items_required_schema","requiredSchema":["stationName","dataTime","pm10Value","pm25Value"],"stopAfterFirstAttempt":true}
```

- Run 7 공개 명세 SHA-256: `c49c9dc18a9af71ac16b64278d47c359bc978d60924d7ac594a885f3cb80b268`
- 전제: 현재 KST 예산일 2026-08-10, 사전 보수적 누적 8회, DPAPI 동일 사용자·파일 소유자 SID 일치, Secret 경로 Repository·OneDrive 밖, Query `serviceKey` 1개·정확히 1회 Encoding·내부 Round-trip 일치
- 통제: HTTPS, 외부 호출 상한 1, 병렬 0, Timeout·ReadWriteTimeout 15초, Stream read 2 MiB 상한, Retry 0, Redirect 0, Hard cap 30
- C-12: 호출 전후 추적·미추적 파일과 환경변수의 원문·1회 encoded Count와 Scan error가 모두 0일 때만 보안 통과
- C-01 통과: HTTP 200, Provider `00`, JSON Envelope·Item 1개 이상, `stationName`·`dataTime`·`pm10Value`·`pm25Value` Field 관찰. 값 결측·Freshness는 별도 품질 판정
- 중단: 사전조건 불일치면 호출 0건, 요청 후 어떤 성공·실패에도 두 번째 호출 없음

#### 6.1.14 Run 7 실행 결과

- 실행시각: 2026-08-10 07:42:37 KST
- Plan·Run: `contract-smoke-20260810-v7`, `contract-smoke-20260810-r7`
- Plan SHA-256: `c49c9dc18a9af71ac16b64278d47c359bc978d60924d7ac594a885f3cb80b268`
- 외부 호출 1건에서 HTTP 200과 Provider `resultCode=00`을 777ms에 관찰했다. Retry 0, Redirect 0이며 Run은 종료했다.
- 통과 범위: 해당 시점 DNS·TLS·Endpoint 도달, 인증키·활용권한, 공개 Parameter 수용, JSON Header Parse, Provider 정상 Header
- 미통과 범위: Data Body·Item 개수·필수 Field·결측·Freshness·품질. `phase=parse`에서 `System.Management.Automation.PropertyNotFoundException`이 발생해 Schema는 `not_observed`
- 판정: Transport·Provider Header `pass`, Local Validator `fail`, Provider Contract `not_evaluable`, `C-01=fail`, `resultKind=unavailable`
- Plan·Security conformance `pass`. 동일 사용자·Secret 경로 범위·1회 Encoding·Query key 1개·내부 Round-trip 사전조건이 모두 참이었고 C-12 사전·사후 원문·1회 encoded Count와 Scan error는 모두 0이었다.
- 당일 보수적 누적 호출량: 9회. Run 6의 HTTP 504 이력은 유지하며 Run 7의 HTTP 200·`00`을 안정성·Canary 통과로 확대하지 않는다.

Sanitized 실행 Manifest Canonical JSON(UTF-8, 줄바꿈 없음):

```json
{"planId":"contract-smoke-20260810-v7","runId":"contract-smoke-20260810-r7","parentRunId":"contract-smoke-20260810-r6","evaluatedAt":"2026-08-10T07:42:37+09:00","planSha256":"c49c9dc18a9af71ac16b64278d47c359bc978d60924d7ac594a885f3cb80b268","networkCalls":1,"phase":"parse","endpointPath":"/getMsrstnAcctoRltmMesureDnsty","httpStatus":200,"providerCode":"00","providerHeaderStatus":"observed_success","jsonHeaderParse":"pass","dataBodyStatus":"not_evaluated","schemaStatus":"not_observed","exceptionClass":"System.Management.Automation.PropertyNotFoundException","failureOrigin":"local_validator","resultKind":"unavailable","errorClass":"local_schema_validator_cardinality_error_confirmed_offline","providerContractVerdict":"not_evaluable","durationMs":777,"retry":0,"redirect":0,"preflight":{"planHashMatch":true,"budgetDateMatch":true,"timezoneMatch":true,"sameUserOwnerSid":true,"secretOutsideRepo":true,"secretOutsideOneDrive":true,"keyRoundTrip":true,"serviceKeyCount":1,"pass":true},"c12Pre":{"rawRepo":0,"encodedRepo":0,"rawEnv":0,"encodedEnv":0,"scanErrors":0},"c12Post":{"rawRepo":0,"encodedRepo":0,"rawEnv":0,"encodedEnv":0,"scanErrors":0},"securityControls":"pass","secretReferencesCleared":true,"rawResponseStored":false,"fullUrlStored":false,"planConformance":"pass","c01":"fail","c09":"not_run","c10":"not_run","runClosed":true,"cumulativeCalls":9}
```

- Sanitized 실행 Manifest SHA-256: `959dc9086f1a1e9398a670d622310721adb30fc66e963dfd81b5725d3b657c03`
- Manifest 의미: 이 Canonical Record는 Run 종료 후 Offline 진단까지 마친 시점에 작성됐다. Runtime 직접 관찰값은 `phase=parse`와 `PropertyNotFoundException`이며, `errorClass=...confirmed_offline`은 사후 진단 분류다. `dataBodyStatus=not_evaluated`는 Item·Required schema Evidence가 완결되지 않아 공개 상태 축에서 `not_observed`로 취급한다는 뜻이다.

#### 6.1.15 Run 7 Local Validator Offline 수정 검증

- 원인 재현: Windows PowerShell 5.1 StrictMode에서 누락 Field Pipeline 결과가 0개 또는 1개일 때 배열 강제 변환 없이 `.Count`를 읽어 `PropertyNotFoundException` 발생
- 수정: 누락 Field 결과를 `@(...)`로 정규화한 뒤 Count 판정. Property 직접 참조 전 존재 여부를 확인하고 Header·Body·Items·Required schema·Quality 단계를 분리
- Fixture: 정상 단일·Wrapper·복수 Item, 빈·Null·누락 Items, Body 누락, 네 Required field 각각 누락, PM 값 Null·결측기호, Provider 비정상 code, Malformed JSON의 15건
- 결과: 기대 판정 15/15 일치, 미처리 예외 0건, 동일 입력 반복 결과 동일, 외부 호출 0건
- Validator ID: `air-measurement-validator-v2-offline`
- Fixture descriptor SHA-256: `f76b0ff3d405b16f9f7893e3d300f2fd704711e3358b800f98a20ec797b7f4cf`
- Result projection SHA-256: `87b518df0c7325432534b7d2d6cf912a040f308d813b2f6e028145291cf05d62`
- 준비 중 발생한 Harness Parser·명령 별칭 오류는 모두 외부 호출 0건이었고 최종 Evidence에 포함하지 않았다.
- 당시 판정: Offline Validator 수정 검증 `pass`. 이 시점에는 Run 8을 별도 사용자 결정과 새 Plan·Hash 전에는 실행하지 않는 것으로 잠갔고, 이후 해당 결정·사전등록에 따라 Run 8·9를 진행했다.

#### 6.1.16 Run 8 AirKorea 대기오염 로컬 Sentinel 사전등록

- 사용자 결정: 2026-08-10, Offline Validator 수정 검증 뒤 다음 작업 계속 진행 요청으로 로컬 Sentinel 1회 재개
- 실행 도구: 실행 당시 `scripts/validation/run8-airkorea-contract-smoke.ps1`. 이후 동일 검증 도구는 [공용 경로](../scripts/validation/airkorea-contract-smoke.ps1)로 이동했다. 제품 코드가 아니며 Secret을 포함하지 않는 공개 검증 Artifact다.
- 정적 감사: Windows PowerShell 5.1 Parser 오류 0건, `GetResponse` 호출 지점 1개, 별도 Network Cmdlet·Retry·Redirect·파일 쓰기·동적 실행 0건. Script는 UTF-8 BOM·CR·비 ASCII Byte가 없는 LF 기반 공개 파일이다.
- Offline 사전검증: 25개 Fixture 모두 기대 판정과 일치, 미처리 예외 0건, Network 0건. 기존 15개 Schema Fixture에 Envelope·Header·Code 누락과 Fresh·Delayed·Stale·Future·시각 파싱 불가·측정소 불일치·결측 품질 분기를 추가했다. Run 7 수정 검증 Hash는 부모 Evidence로 보존하고 저장형 Script 자체의 Fixture·결과 Hash를 별도로 고정했다.
- 공식 사전점검: API `15073861`의 2026-06-30 계약과 종로구 요청 Parameter는 Run 7 뒤 변경되지 않았다. 2026-08-10 15:00 KST까지의 충북권역 데이터 미수신 공지는 서울 종로구를 직접 대상으로 하지 않으며, 서울·전 서비스 점검 공지 미관찰은 정상 보증으로 쓰지 않는다.

Run 8 public plan canonical json(UTF-8, 줄바꿈 없음):

```json
{"planId":"contract-smoke-20260810-v8","parentPlanId":"contract-smoke-20260810-v7","parentRunId":"contract-smoke-20260810-r7","parentPlanSha256":"c49c9dc18a9af71ac16b64278d47c359bc978d60924d7ac594a885f3cb80b268","parentManifestSha256":"959dc9086f1a1e9398a670d622310721adb30fc66e963dfd81b5725d3b657c03","parentOutcome":"c01_fail_local_validator_provider_contract_not_evaluable","resumptionReason":"owner_requested_continuation_after_offline_validator_fix","ownerApproval":"explicit_next_work_continuation_received","runId":"contract-smoke-20260810-r8","fixedAt":"2026-08-10T08:12:19+09:00","budgetDate":"2026-08-10","budgetTimezone":"Asia/Seoul","scriptPath":"scripts/validation/run8-airkorea-contract-smoke.ps1","scriptSha256":"b1cd46e3972d1aed0e08a006aeaeb97fa927b029d7a25344d5bba788b65e4448","scriptEncoding":"utf8_no_bom_lf_ascii_compatible","scriptHashMode":"raw_file_bytes","validatorId":"air-measurement-validator-v2-offline","parentValidatorFixtureDescriptorSha256":"f76b0ff3d405b16f9f7893e3d300f2fd704711e3358b800f98a20ec797b7f4cf","parentValidatorResultProjectionSha256":"87b518df0c7325432534b7d2d6cf912a040f308d813b2f6e028145291cf05d62","validatorFixtureCount":25,"validatorFixtureDescriptorSha256":"fb77f81a621fe77f6bd5672f4366e060781bc6e1fbac869b9c9a870621b4fd13","validatorResultProjectionSha256":"71c0037a02245ecc7cd006eddb01cdefeecd0b042be3a35968efe0ae6e803a09","officialContract":{"apiId":"15073861","checkedAt":"2026-08-10T07:55:18+09:00","detailUrl":"https://www.data.go.kr/data/15073861/openapi.do","publishedModifiedDate":"2026-06-30","contractChangedSinceRun7":false,"june30SidoNameChangeApplies":false},"officialNoticeCaveat":{"url":"https://www.airkorea.or.kr/web/board/1/1237/?pMENU_NO=143","windowKst":"2026-08-07T15:00:00+09:00/2026-08-10T15:00:00+09:00","scope":"chungbuk_measurement_data_nonreceipt","targetRegion":"서울 종로구","targetDirectlyAffected":false,"allServiceOrSeoulMaintenanceObserved":false,"noticeAbsenceIsNotHealthEvidence":true},"scheme":"https","host":"apis.data.go.kr","endpointPath":"/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty","method":"GET","requestBody":"none","parameters":[["returnType","json"],["numOfRows","1"],["pageNo","1"],["stationName","종로구"],["dataTerm","DAILY"],["ver","1.3"]],"keyParameter":"serviceKey","queryParameterOrder":["serviceKey","returnType","numOfRows","pageNo","stationName","dataTerm","ver"],"keySource":"windows_current_user_dpapi_external_to_repo","sameUserSidRequired":true,"secretPathOutsideRepoAndOneDriveRequired":true,"secretNoReparseRequired":true,"keyEncoding":"decode_then_EscapeDataString_once","serviceKeyCountRequired":1,"keyRoundTripRequired":true,"transport":"HttpWebRequest","executionMode":"local_sentinel","sentinelCalls":1,"networkCallUpperBound":1,"networkCallSiteUpperBound":1,"retry":0,"parallel":0,"redirect":0,"timeoutSeconds":15,"readWriteTimeoutSeconds":15,"responseLimitBytes":2097152,"automaticDecompression":["GZip","Deflate"],"keepAlive":false,"preCallCount":9,"expectedPostCallCount":10,"hardCap":30,"prePostC12":true,"c12Scope":["tracked","untracked","environment"],"c12Representations":["raw","url_encoded_once"],"c12ScanErrorsMustBeZero":true,"abortOnC12NonZero":true,"processIsolation":true,"exceptionMaxDepth":5,"exceptionPolicy":"preserve_first_WebException_and_deepest_class","consoleOutput":"single_sanitized_json_allowlist_only","rawResponseStorage":false,"fullUrlStorage":false,"successCriteria":"http200_provider00_json_items_required_schema","requiredSchema":["stationName","dataTime","pm10Value","pm25Value"],"qualityCriteria":{"stationNameMustEqual":"종로구","dataTimeTimezone":"Asia/Seoul","requiredNonMissingValues":["pm10Value","pm25Value"],"missingRepresentations":[null,"","-"],"missingValueImputation":"forbidden","freshMaxAgeMinutes":120,"delayedMaxAgeMinutes":240,"olderThan240Minutes":"stale","unparseableOrFutureDataTime":"not_fresh"},"scopeLimits":["official_grades_not_evaluated","units_not_evaluated","o3_not_evaluated","canary_not_evaluated"],"stopAfterFirstAttempt":true}
```

- Run 8 public plan SHA-256: `35cb9bdeb0d3531a4f0ce63673eca385f384d80804e9e95df8cb93aab32b9c20`
- Script SHA-256: `b1cd46e3972d1aed0e08a006aeaeb97fa927b029d7a25344d5bba788b65e4448`
- C-01과 품질 판정을 분리한다. HTTP 200·Provider `00`·JSON Envelope/Body·Item 1개 이상·네 필수 Property·미처리 예외 0건이 C-01 조건이며, 종로구 일치·KST 시각·PM10·PM2.5 값·Age는 별도 품질 판정이다. 결측은 0으로 보정하지 않는다.
- 실행 전 Plan·Script·부모 Hash, Endpoint·Parameter, 호출 상한, DPAPI 동일 사용자·경로, 1회 Encoding, C-12, Budget를 모두 다시 검증한다. 하나라도 불일치하면 Network 0건으로 종료한다.

#### 6.1.17 Run 8 사전검사 종료 결과

- 실행시각: 2026-08-10 08:35:15 KST
- Plan·Run: `contract-smoke-20260810-v8`, `contract-smoke-20260810-r8`
- 결과: Network 0건, Retry·Redirect 0, C-01·C-09·C-10 `not_run`, 당일 누적 9회 유지
- 원인: Secret 파일 자체나 소유자 불일치가 아니라, Reparse ancestry를 검사하는 로컬 코드가 `FileInfo.Parent`를 참조해 `PropertyNotFoundException`으로 중단됐다. 따라서 출력의 `sameUserOwnerSid=false`는 검사 실패가 아니라 해당 단계 미도달이며 Secret Import·복호화와 API 호출은 수행되지 않았다.
- 판정: `preflight_aborted_path_traversal_validator_error_network0`. 같은 Plan을 수정해 재실행하지 않고 실패를 보존한 뒤 새 Plan·Run으로 분리한다.

Run 8 Sanitized preflight Manifest Canonical JSON(UTF-8, 줄바꿈 없음):

```json
{"planId":"contract-smoke-20260810-v8","runId":"contract-smoke-20260810-r8","parentRunId":"contract-smoke-20260810-r7","evaluatedAt":"2026-08-10T08:35:15+09:00","phase":"plan_preflight","networkCalls":0,"endpointPath":"/getMsrstnAcctoRltmMesureDnsty","httpStatus":null,"providerCode":null,"providerHeaderStatus":"not_observed","jsonHeaderParse":"not_observed","dataBodyStatus":"not_observed","schemaStatus":"not_observed","outerErrorClass":"System.Management.Automation.PropertyNotFoundException","rootErrorClass":"System.Management.Automation.PropertyNotFoundException","innerDepth":0,"chainTruncated":false,"webExceptionStatus":null,"localValidator":"not_run","providerContractVerdict":"not_evaluable","resultKind":"not_run","errorClass":"aborted_preflight","c01":"not_run","c09":"not_run","c10":"not_run","retry":0,"redirect":0,"rawResponseStored":false,"fullUrlStored":false,"planSha256":"35cb9bdeb0d3531a4f0ce63673eca385f384d80804e9e95df8cb93aab32b9c20","scriptSha256":"b1cd46e3972d1aed0e08a006aeaeb97fa927b029d7a25344d5bba788b65e4448","scriptHashBeforeMatch":true,"scriptHashAfterMatch":true,"durationMs":1423,"preflightPlanHashMatch":true,"preflightParentLinksMatch":true,"preflightValidatorLineageMatch":true,"preflightPlanContractMatch":true,"preflightPlanControlsMatch":true,"preflightPlanSecurityMatch":true,"preflightScriptEncodingMatch":true,"preflightBudgetDateMatch":true,"preflightTimezoneMatch":true,"preflightSameUserOwnerSid":false,"preflightSecretOutsideRepo":true,"preflightSecretOutsideOneDrive":true,"preflightSecretNoReparse":true,"preflightKeyRoundTrip":false,"preflightServiceKeyCount":0,"preflightOfflineMatrixPass":true,"preflightPass":false,"nonSecretPreflightPass":true,"c12PreRawRepo":null,"c12PreEncodedRepo":null,"c12PreRawEnv":null,"c12PreEncodedEnv":null,"c12PreScanErrors":null,"c12PostRawRepo":null,"c12PostEncodedRepo":null,"c12PostRawEnv":null,"c12PostEncodedEnv":null,"c12PostScanErrors":null,"c12Pass":false,"secretReferencesCleared":true,"outputAllowlistPass":true,"securityConformance":"fail","planConformance":"fail","runClosed":true,"cumulativeCalls":9}
```

- Run 8 Manifest SHA-256: `dc6c61a2488f97dda6975aec43bfe1b6bfc4f4e08ee20277ab5cddd5938d085f`

#### 6.1.18 Run 9 AirKorea 대기오염 로컬 Sentinel 사전등록

- 재개 근거: Run 8에서 승인된 외부 호출 1건은 Network 0건으로 소비되지 않았다. 로컬 경로 순회 오류만 수정하고 Run 8 Plan·Manifest를 부모로 연결한 새 Plan·Run을 고정한다.
- 수정·보안 재검증: FileInfo와 DirectoryInfo의 부모 순회를 분리하고 Secret Metadata Gate를 Import 전에 시행한다. BSTR ZeroFree 성공, Response·Collection 정리 실패 0건, `$Error` Buffer 제거, 실행 Manifest의 Secret·Full URI·Path·SID 값 기반 검사까지 Security conformance에 포함한다.
- Offline 재검증: 25/25 일치, 미처리 예외 0건, Network 0건. Parser 오류 0건, `GetResponse` 호출 지점 1개·Loop 밖, Retry·Redirect·파일 쓰기·동적 실행 0건.

Run 9 public plan canonical json(UTF-8, 줄바꿈 없음):

```json
{"planId":"contract-smoke-20260810-v9","parentPlanId":"contract-smoke-20260810-v8","parentRunId":"contract-smoke-20260810-r8","parentPlanSha256":"35cb9bdeb0d3531a4f0ce63673eca385f384d80804e9e95df8cb93aab32b9c20","parentManifestSha256":"dc6c61a2488f97dda6975aec43bfe1b6bfc4f4e08ee20277ab5cddd5938d085f","parentOutcome":"preflight_aborted_path_traversal_validator_error_network0","resumptionReason":"run8_preflight_aborted_network0_local_path_traversal_fixed","ownerApproval":"run8_single_call_approval_unconsumed_network0","runId":"contract-smoke-20260810-r9","fixedAt":"2026-08-10T08:43:17+09:00","budgetDate":"2026-08-10","budgetTimezone":"Asia/Seoul","scriptPath":"scripts/validation/airkorea-contract-smoke.ps1","scriptSha256":"5076e413770b501e767145834412b1679fcf28de780721995125b69ffae2b5e5","scriptEncoding":"utf8_no_bom_lf_ascii_compatible","scriptHashMode":"raw_file_bytes","validatorId":"air-measurement-validator-v2-offline","parentValidatorFixtureDescriptorSha256":"fb77f81a621fe77f6bd5672f4366e060781bc6e1fbac869b9c9a870621b4fd13","parentValidatorResultProjectionSha256":"71c0037a02245ecc7cd006eddb01cdefeecd0b042be3a35968efe0ae6e803a09","validatorFixtureCount":25,"validatorFixtureDescriptorSha256":"fb77f81a621fe77f6bd5672f4366e060781bc6e1fbac869b9c9a870621b4fd13","validatorResultProjectionSha256":"71c0037a02245ecc7cd006eddb01cdefeecd0b042be3a35968efe0ae6e803a09","officialContract":{"apiId":"15073861","checkedAt":"2026-08-10T07:55:18+09:00","detailUrl":"https://www.data.go.kr/data/15073861/openapi.do","publishedModifiedDate":"2026-06-30","contractChangedSinceRun7":false,"june30SidoNameChangeApplies":false},"officialNoticeCaveat":{"url":"https://www.airkorea.or.kr/web/board/1/1237/?pMENU_NO=143","windowKst":"2026-08-07T15:00:00+09:00/2026-08-10T15:00:00+09:00","scope":"chungbuk_measurement_data_nonreceipt","targetRegion":"서울 종로구","targetDirectlyAffected":false,"allServiceOrSeoulMaintenanceObserved":false,"noticeAbsenceIsNotHealthEvidence":true},"scheme":"https","host":"apis.data.go.kr","endpointPath":"/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty","method":"GET","requestBody":"none","parameters":[["returnType","json"],["numOfRows","1"],["pageNo","1"],["stationName","종로구"],["dataTerm","DAILY"],["ver","1.3"]],"keyParameter":"serviceKey","queryParameterOrder":["serviceKey","returnType","numOfRows","pageNo","stationName","dataTerm","ver"],"keySource":"windows_current_user_dpapi_external_to_repo","sameUserSidRequired":true,"secretPathOutsideRepoAndOneDriveRequired":true,"secretNoReparseRequired":true,"secretMetadataGateBeforeImport":true,"keyEncoding":"decode_then_EscapeDataString_once","serviceKeyCountRequired":1,"keyRoundTripRequired":true,"transport":"HttpWebRequest","executionMode":"local_sentinel","sentinelCalls":1,"networkCallUpperBound":1,"networkCallSiteUpperBound":1,"retry":0,"parallel":0,"redirect":0,"timeoutSeconds":15,"readWriteTimeoutSeconds":15,"responseLimitBytes":2097152,"automaticDecompression":["GZip","Deflate"],"keepAlive":false,"preCallCount":9,"expectedPostCallCount":10,"hardCap":30,"prePostC12":true,"c12Scope":["tracked","untracked","environment"],"c12Representations":["raw","url_encoded_once"],"c12ScanErrorsMustBeZero":true,"abortOnC12NonZero":true,"runtimeOutputSecretScanRequired":true,"errorBufferClearRequired":true,"zeroFreeBstrRequired":true,"cleanupFailureMustBeFalse":true,"processIsolation":true,"exceptionMaxDepth":5,"exceptionPolicy":"preserve_first_WebException_and_deepest_class","consoleOutput":"single_sanitized_json_allowlist_only","rawResponseStorage":false,"fullUrlStorage":false,"successCriteria":"http200_provider00_json_items_required_schema","requiredSchema":["stationName","dataTime","pm10Value","pm25Value"],"qualityCriteria":{"stationNameMustEqual":"종로구","dataTimeTimezone":"Asia/Seoul","requiredNonMissingValues":["pm10Value","pm25Value"],"missingRepresentations":[null,"","-"],"missingValueImputation":"forbidden","freshMaxAgeMinutes":120,"delayedMaxAgeMinutes":240,"olderThan240Minutes":"stale","unparseableOrFutureDataTime":"not_fresh"},"scopeLimits":["official_grades_not_evaluated","units_not_evaluated","o3_not_evaluated","canary_not_evaluated"],"stopAfterFirstAttempt":true}
```

- Run 9 public plan SHA-256: `d3eb18ad5cd364d1515acd74fd94fe43ba87f3ff012172264290d588d905715b`
- Script SHA-256: `5076e413770b501e767145834412b1679fcf28de780721995125b69ffae2b5e5`
- 호출 전 Plan·Script·부모·Fixture·Budget와 Secret Metadata Gate가 모두 일치해야 한다. 이후 C-12·정확히 1회 Encoding·Output Secret Scan·BSTR ZeroFree·Error Buffer 제거까지 모두 통과해야 Security·Plan conformance를 `pass`로 기록한다.

#### 6.1.19 Run 9 실행 결과와 공식 명세 사후판정

- 실행시각: 2026-08-10 08:47:32 KST
- Plan·Run: `contract-smoke-20260810-v9`, `contract-smoke-20260810-r9`
- 실행 통제: Network 1건, Retry·Redirect 0, Plan·Security conformance `pass`, C-12 사전·사후 원문·1회 Encoding 표현의 Repository·환경 흔적과 Scan 오류 모두 0건, 당일 보수적 누적 10회
- 관찰: HTTP 200, Provider `00`, JSON Header·Body, Item 1개, `dataTime`·`pm10Value`·`pm25Value` Property를 관찰했다. 원 응답·수치·전체 URI는 저장하지 않았다.
- 원본 사전등록 판정: `stationName`이 Item에 없어 `schemaStatus=required_fields_missing`, `c01=fail`, `providerContractVerdict=fail`. 이 판정과 아래 Manifest는 수정하거나 성공으로 덮어쓰지 않는다.

Run 9 Sanitized Manifest Canonical JSON(UTF-8, 줄바꿈 없음):

```json
{"planId":"contract-smoke-20260810-v9","runId":"contract-smoke-20260810-r9","parentRunId":"contract-smoke-20260810-r8","evaluatedAt":"2026-08-10T08:47:32+09:00","phase":"completed","networkCalls":1,"endpointPath":"/getMsrstnAcctoRltmMesureDnsty","httpStatus":200,"providerCode":"00","providerHeaderStatus":"observed_success","jsonHeaderParse":"pass","dataBodyStatus":"observed","schemaStatus":"required_fields_missing","itemCount":1,"missingRequiredFields":["stationName"],"fieldSignature":["dataTime:String","pm10Value:String","pm25Value:String"],"nullFields":[],"missingValueFields":[],"stationMatch":false,"dataTimeParseable":false,"observationAgeMinutes":null,"freshnessStatus":"not_evaluable","qualityStatus":"not_evaluable","responseBytes":576,"sanitizedProjectionSha256":"51b9f2336d29fa3f24a1114cf33f7522396db11b111017b4d67dce0063032198","localValidator":"pass","providerContractVerdict":"fail","resultKind":"partial","errorClass":"required_schema_missing","c01":"fail","c09":"not_run","c10":"not_run","retry":0,"redirect":0,"rawResponseStored":false,"fullUrlStored":false,"planSha256":"d3eb18ad5cd364d1515acd74fd94fe43ba87f3ff012172264290d588d905715b","scriptSha256":"5076e413770b501e767145834412b1679fcf28de780721995125b69ffae2b5e5","scriptHashBeforeMatch":true,"scriptHashAfterMatch":true,"durationMs":2950,"preflightPlanHashMatch":true,"preflightParentLinksMatch":true,"preflightValidatorLineageMatch":true,"preflightPlanContractMatch":true,"preflightPlanControlsMatch":true,"preflightPlanSecurityMatch":true,"preflightScriptEncodingMatch":true,"preflightBudgetDateMatch":true,"preflightTimezoneMatch":true,"preflightSameUserOwnerSid":true,"preflightSecretOutsideRepo":true,"preflightSecretOutsideOneDrive":true,"preflightSecretNoReparse":true,"preflightKeyRoundTrip":true,"preflightServiceKeyCount":1,"preflightOfflineMatrixPass":true,"preflightPass":true,"nonSecretPreflightPass":true,"c12PreRawRepo":0,"c12PreEncodedRepo":0,"c12PreRawEnv":0,"c12PreEncodedEnv":0,"c12PreScanErrors":0,"c12PostRawRepo":0,"c12PostEncodedRepo":0,"c12PostRawEnv":0,"c12PostEncodedEnv":0,"c12PostScanErrors":0,"c12Pass":true,"secretReferencesCleared":true,"bstrZeroFreeSucceeded":true,"errorBufferCleared":true,"cleanupFailure":false,"runtimeSecretScanPass":true,"outputAllowlistPass":true,"securityConformance":"pass","planConformance":"pass","runClosed":true,"cumulativeCalls":10}
```

- Run 9 Manifest SHA-256: `732775583ff2b3917b3d8ce5f7076238475ebc0a2aa46354e458c6ec9985bdf2`
- 공식 명세 사후대조: [API 15073861](https://www.data.go.kr/data/15073861/openapi.do)의 Live `측정소별 실시간 측정정보 조회`에서 `stationName`은 요청 필수 Parameter이고 응답 Item 목록에는 없다. 같은 페이지의 첨부 `한국환경공단 에어코리아 OpenAPI 기술문서_20260630.zip` 안 v1.4 응답 필드표는 반대로 `stationName`·`stationCode`를 필수로 적지만, 바로 뒤 공식 XML Sample에는 두 Field가 없다.
- 사후판정: 원본 Run 9 Plan·Manifest의 C-01 `fail`은 보존한다. HTTP 200·Provider `00`·Item 1개와 `dataTime`·`pm10Value`·`pm25Value` 관찰 형태는 `core_observation_consistent_with_live_portal_response_table_and_official_sample`이지만 전체 응답표를 검증한 것은 아니며, 첨부 필드표 충돌이 남아 전체 Provider 응답 Contract는 `conflicting_official_schema`다. 테스트 Assertion을 단순 오류로 소급 변경하거나 Provider 위반으로 단정하지 않는다.
- 미평가 범위: `stationName` 누락에서 품질 단계를 중단했으므로 측정시각 Age·Freshness·실제 값 유효성은 `not_evaluated`다. Run 6의 504와 Run 7의 로컬 Validator 실패도 유지하며, 안정성·14일 Canary·나머지 Endpoint·오류 Case 통과로 확대하지 않는다.
- 후속 규칙: 다음 Plan에서는 측정소를 사전등록한 요청 Context로 보존하되 응답 Echo를 C-01 필수로 강제하지 않고, 공식 문서 충돌을 별도 `contract_conflict`로 Fail-closed 처리한다. Run 9를 같은 이유로 재호출하지 않는다. Schema 충돌 문의는 2026-08-10 공공데이터포털에서 한국환경공단 대상으로 제출돼 처리상태 `접수`이며, 답변 전에는 중복 제출하지 않는다. 다음 실제 호출은 별도 사용자 결정이 필요하다.

#### 6.1.20 C-09·C-10 Offline Synthetic Client Classifier

기관 답변과 실제 Provider 호출을 기다리는 동안 Client의 Fail-closed 분기만 무호출로 검증했다. 기존 Run 9 Script와 Plan·Manifest는 과거 Evidence이므로 수정하지 않고, 별도 공개 검증 도구를 추가했다.

- 오류 분류기: [`scripts/validation/provider-error-contract-self-test.ps1`](../scripts/validation/provider-error-contract-self-test.ps1)
- 통합 검증기: [`scripts/validation/gate2-offline-verify.ps1`](../scripts/validation/gate2-offline-verify.ps1)
- Fixture 출처: `synthetic_classifier_fixture`; `providerBehaviorVerified=false`
- errorClassifierSha256: `7e22b789df47f699492ab4aa7d4d0771f677ca3175f80b4efa5e7e833f991c24`
- offlineVerifierSha256: `04ff589d2fded19fbae75c9da0457f66924f4670509b73707f1b9cae211f74ce`
- C-09·C-10·모호한 오류 Fail-closed Fixture: 16/16 기대 판정, 미처리 예외 0, Synthetic Marker·URI 출력 0, 두 개의 새 Windows PowerShell 5.1 Process에서 Capture한 원본 stdout이 정확히 일치
- Fixture Descriptor SHA-256: `633ece25bc6ad528db967a2f3d35a86c8402562df5cd8a9eb7d7b62486a050f4`
- Result Projection SHA-256: `0a396ff4d4c68397f9a499a8c207c7649bf54d7fab81cf48b51fbddfa23677b2`
- Frozen Validator stdout SHA-256: `4cf5822012d75bdde6a375af53e61eba93ae42bb1b1f211b39995f1da98012a5`; 오류 Classifier stdout SHA-256: `858cc61cfc80fc0ec0746d1eb5905131cf1f967685dae0875e4d38bca1e65e84`
- 통합 검증기 stdout SHA-256: `49f42ba2e1d9d2657e597b7fbf6509e1fdccab0aa5a639418e8b3e87338d0710`; 고정된 System32 Windows PowerShell `powershell.exe`가 5.1 Desktop인지 별도 Child Probe로 확인했고, 두 개의 새 검증기 Process에서 Exit 0·stderr 0·대소문자를 포함한 원본 stdout Byte가 정확히 일치
- 실행 통제: Network 0, Retry 실행 0, 같은 Run Retry 허용 `false`, Retry 정책 실행 검증 `false`, Sleep 0, Redirect 0. HTTP status·Provider code·WebExceptionStatus를 분리하고, 403·깨지거나 빈 Payload의 원인·잘린 예외 Chain·C-09/C-10 동시 Signal은 추정하지 않고 `*_unclassified`로 닫음. `Retry-After`는 존재 여부만 Synthetic 입력으로 다루며 값 Parse·상한 적용을 검증한 것으로 보지 않음
- 정적 감사: 두 Script 모두 Windows PowerShell 5.1 Parser 오류 0. 새 오류 분류기는 Network Member·DPAPI·파일 쓰기 0이며, Frozen Run 9 Script는 기존 `GetResponse` 호출 지점 정확히 1개·Loop 밖임을 재확인
- Evidence 연결: Run 6~9의 Canonical Plan·Manifest 8개가 모두 한 줄 JSON으로 Parse되고 기록 SHA·부모 연결·Run 9 Script SHA와 일치. Frozen Validator 25/25와 새 오류 Fixture 16/16을 각각 새 Process에서 2회 실행해 동일 결과를 확인

이 결과는 C-09·C-10 **Client 분류기**의 Offline Evidence다. Provider가 실제로 Timeout·Backend·Quota 오류를 어떤 HTTP status·code·body로 반환하는지는 계속 `not_run` 또는 기존 관찰 범위로 유지하며, 실제 Quota 소진이나 Provider Contract 통과로 승격하지 않는다.

#### 6.1.21 Run 10 KMA 초단기예보·단기예보 C-01 실행 결과

- 실행시각: 2026-08-10 13:38:25 KST
- Plan·Run: `contract-smoke-20260810-v10`, `contract-smoke-20260810-r10`
- [Canonical Plan](./validation-plans/kma-forecast-contract-smoke-plan.json) SHA-256: `d1e25d41032427799b6aaa426d7304fd97bcded63a9c1d30dcbdf85c377f86a8`
- Script SHA-256: `c02217f0cfc8bc1e486479640394f965521a8b374870e430519c35d91e2f9ea0`
- Offline Validator: 12/12, Descriptor SHA-256 `9c7d59c33f76ba92cc0800e3582e14e102695cb40eca8fa4c4706eb7bb76db8a`, Result Projection SHA-256 `817429f7be00d2e35c095bae19db0be6a5c38f20c56dc6cbc05d259f29368494`
- 고정 공개 요청: `/getUltraSrtFcst`는 `pageNo=1`, `numOfRows=1000`, `dataType=JSON`, `base_date=20260810`, `base_time=1130`, `nx=60`, `ny=127`; `/getVilageFcst`는 같은 Pagination·Grid에 `base_time=1100`. Credential과 전체 URL은 기록하지 않는다.
- 실행 통제: Network 2건, Endpoint별 1회, Retry·Redirect·Parallel 0, 호출 간 2초, 당일 보수적 누적 12회. C-12 사전·사후 Repository·환경 원문·1회 Encoding 표현과 Scan 오류는 모두 0건이다.
- `/getUltraSrtFcst`: HTTP 200, Provider `00`, Item 66개, 필수 8개 Field와 `PTY`·`RN1`·`T1H`·`REH`·`WSD`, 요청 Grid·발표회차·Pagination·값 Domain 확인, C-01 `pass`.
- `/getVilageFcst`: HTTP 200, Provider `00`, Item 835개, 필수 8개 Field와 `PTY`·`PCP`·`POP`·`TMP`·`REH`·`WSD`, 요청 Grid·발표회차·Pagination·값 Domain 확인, C-01 `pass`.
- 보안·정리: 원 응답·예보값·전체 URL·예외 원문을 저장하지 않았고 Secret 참조 해제, BSTR ZeroFree, Error Buffer 제거, Runtime Secret Scan과 Output Allowlist가 모두 통과했다.
- 판정 범위: `contractVerdict=pass`와 `planConformance=pass`는 이 Run의 **C-01 전용** 판정이다. `c11CaptureComplete=true`는 공개 필드 Capture 완료 Boolean일 뿐 엄격한 C-11 통과가 아니다. Endpoint와 Run 전체의 C-11은 `not_evaluated`, Freshness·Coverage·Canary는 `not_run`으로 유지한다.

Run 10 Sanitized Evidence Summary Canonical JSON(UTF-8, 줄바꿈 없음):

```json
{"schemaVersion":"run10-sanitized-evidence-summary-v1","planId":"contract-smoke-20260810-v10","runId":"contract-smoke-20260810-r10","evaluatedAt":"2026-08-10T13:38:25+09:00","phase":"completed","networkCalls":2,"endpointCount":2,"cumulativeCalls":12,"retry":0,"redirect":0,"parallel":0,"rawResponseStored":false,"fullUrlStored":false,"exceptionTextStored":false,"planSha256":"d1e25d41032427799b6aaa426d7304fd97bcded63a9c1d30dcbdf85c377f86a8","scriptSha256":"c02217f0cfc8bc1e486479640394f965521a8b374870e430519c35d91e2f9ea0","preflightPass":true,"c12Pre":{"rawRepo":0,"encodedRepo":0,"rawEnv":0,"encodedEnv":0,"scanErrors":0},"c12Post":{"rawRepo":0,"encodedRepo":0,"rawEnv":0,"encodedEnv":0,"scanErrors":0},"c12Pass":true,"secretReferencesCleared":true,"bstrZeroFreeSucceeded":true,"errorBufferCleared":true,"cleanupFailure":false,"runtimeSecretScanPass":true,"outputAllowlistPass":true,"securityConformance":"pass","contractVerdictScope":"c01_only","c01Verdict":"pass","c11Verdict":"not_evaluated","contractVerdict":"pass","planConformance":"pass","runClosed":true,"endpoints":[{"endpointId":"getUltraSrtFcst","endpointPath":"/getUltraSrtFcst","fetchedAt":"2026-08-10T13:38:19+09:00","issuedAt":"2026-08-10T11:30:00+09:00","validFrom":"2026-08-10T12:00:00+09:00","validUntil":null,"validUntilNullReason":"official_interval_end_not_provided","httpStatus":200,"providerCode":"00","itemCount":66,"schemaStatus":"required_schema_observed","missingRequiredFields":[],"missingRequiredCategories":[],"fieldSignature":["baseDate:String","baseTime:String","category:String","fcstDate:String","fcstTime:String","fcstValue:String","nx:Integer","ny:Integer"],"grid":{"x":60,"y":127},"gridMatch":true,"baseEchoMatch":true,"baseTimeParseable":true,"forecastTimeParseable":true,"paginationComplete":true,"valueDomainPass":true,"units":["PTY:code","RN1:category_1mm","T1H:degC","REH:percent","WSD:m/s"],"responseBytes":8986,"sanitizedProjectionSha256":"43aa9e0232a276c404ff2e04690abcebdeda22919c1affc937b2b8f1ebabb141","attributionRenderedSha256":"3e763f22411c25898964ba8df60409e09e55b3ad77db81bf6546404ea1b7ea39","c11CaptureComplete":true,"providerContractVerdict":"pass","c01":"pass","c11":"not_evaluated","securityControls":"pass","cleanupPass":true},{"endpointId":"getVilageFcst","endpointPath":"/getVilageFcst","fetchedAt":"2026-08-10T13:38:22+09:00","issuedAt":"2026-08-10T11:00:00+09:00","validFrom":"2026-08-10T12:00:00+09:00","validUntil":null,"validUntilNullReason":"official_interval_end_not_provided","httpStatus":200,"providerCode":"00","itemCount":835,"schemaStatus":"required_schema_observed","missingRequiredFields":[],"missingRequiredCategories":[],"fieldSignature":["baseDate:String","baseTime:String","category:String","fcstDate:String","fcstTime:String","fcstValue:String","nx:Integer","ny:Integer"],"grid":{"x":60,"y":127},"gridMatch":true,"baseEchoMatch":true,"baseTimeParseable":true,"forecastTimeParseable":true,"paginationComplete":true,"valueDomainPass":true,"units":["PTY:code","PCP:category_1mm","POP:percent","TMP:degC","REH:percent","WSD:m/s"],"responseBytes":112392,"sanitizedProjectionSha256":"e69c28effbb3226083810ea36dbd5578c39cfc6fe3e0d7c6b85312043eb0db59","attributionRenderedSha256":"ca663d51aa4e5786971a2a92ca69745e29f8b745f2ba84afba36e99d65fd0eab","c11CaptureComplete":true,"providerContractVerdict":"pass","c01":"pass","c11":"not_evaluated","securityControls":"pass","cleanupPass":true}]}
```

- Run 10 Sanitized Evidence Summary SHA-256: `9c94281f2310d310207a0c4682b0aa1ab18c426345a66e0033866f9d15ea7ce6`

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
| KMA 기상특보 | 계획 Poll과 관찰된 고유 발표 | 발표기관, 발표·발효·해제시각, 대상지역, 원문, 활성·해제·정정 연결, `valid_empty` | 계획 Poll 중 `data` 또는 `valid_empty`인 비율 95% 이상이며 오류는 성공으로 세지 않음. 출처가 확인된 실제 Sanitized 응답 또는 공식 Sample로 활성·해제·정정 Contract가 모두 pass. 실제 발표가 있으면 필수 필드 완전성 100%, 없으면 Live event latency는 `not_observed`이고 제한부 판정만 허용. 비기상 재난 안전으로 오해시키는 변환 0건 |
| AirKorea 측정소 | 두 고정 지역에 수동으로 미리 지정한 공개 측정소 | 측정소 식별자·명칭, 시·도 수준 지역, 공개 좌표 기반 거리 | `stationMaxDistanceKm` 이내 Pair의 Contract 연결 100%, 거리 초과·다른 측정소 보간 0건. 기준 안의 측정소가 없으면 지역 Coverage fail. Gate 2는 수동 연결만 검증하며 자동 측정소 선택 정확도는 Gate 4 범위 |
| AirKorea 관측 | 공개 측정소별 계획 Poll | 관측시각, PM10·PM2.5 원 수치·등급·단위, 측정소와 Fallback 사유 | 계획 Poll 중 `data`이고 PM10·PM2.5 필드가 모두 있으며 관측 Age가 2시간 이내인 사용 가능 표본 비율 90% 이상. 결측을 0으로 변환한 사례 0건 |
| AirKorea 예보 | 대상 지역별 고유 05·11·17·23시 발표 회차 | 발표시각, 유효일·지역, PM10·PM2.5 예보와 Source | 고유 발표 회차 중 최신 `data`가 잠금된 허용 지연 안에 도착하고 모든 예상 Cell과 필수 필드를 갖춘 사용 가능 회차 비율 90% 이상 |
| 공통 Contract·보안 | C-01~C-12의 사전 고정 Case와 전체 계획 호출 | 예상 Verdict, 실제 호출 또는 허용된 Fixture 근거, Source·License·Attribution, Secret Redaction | 아래 필수 Case가 모두 `pass`이고 미해결 `fail` 또는 `not_observed`가 0건. 계획 호출 실행률 95% 이상, Source·License·Attribution 유실·API key·정확 GPS 누출·설명 없는 자동 Provider 전환 각각 0건 |

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

| Provider | Contract Evidence | 오류 Evidence | 14일 Canary Evidence | License Evidence | License Decision | 실호출 Workflow |
| --- | --- | --- | --- | --- | --- | --- |
| KMA 단기예보 | `/getUltraSrtNcst` Run 3, `/getUltraSrtFcst`·`/getVilageFcst` Run 10 C-01 `pass`; Run 10은 C-01 전용 bounded pass, C-11 `not_evaluated` | `observed_http_403_and_401_unclassified`; 계획 오류 Case `not_run` | `not_run` | Source·Terms 정적 Binding `verified`, 엄격한 C-11 `not_evaluated` | `approved_for_dev` | `in_progress` |
| KMA 기상특보 | `/getWthrWrnList` C-01 `pass`; 나머지 `not_run` | `not_run` | `not_run` | `not_verified` | `approved_for_dev` | `in_progress` |
| AirKorea 측정소 | `/getMsrstnList` C-01 `pass`; 근접 측정소 `not_run` | `not_run` | `not_run` | `not_verified` | `conditional_for_production` | `in_progress` |
| AirKorea 대기오염 | Run 5 전송 결과 미관찰, Run 6 HTTP 504, Run 7 Local Validator 실패, Run 8 사전검사 중단·Network 0. Run 9는 HTTP 200·Provider `00`·핵심 Field를 관찰했으나 원본 C-01 `fail`; Live 응답표·공식 Sample과 첨부 필드표가 충돌해 Contract `conflicting_official_schema`, Freshness `not_evaluated`, 나머지 Endpoint `not_run`. 2026-08-10 Schema 문의 `접수` | Sanitized HTTP 504 Envelope·Offline 504 Classifier 각 1건; 계획 C-09·C-10 `not_run`. Local Fixture와 공식 문서 충돌은 Provider 오류 Evidence와 분리 | `not_run` | `not_verified` | `conditional_for_production` | `blocked_pending_official_schema_response_and_next_network_scope_decision` |

결과표는 실제 Evidence가 생긴 항목만 바꾼다. 활용신청이나 키 발급만으로 Contract 또는 Freshness를 통과 처리하지 않는다.

위 표의 Workflow는 Provider 실호출 상태다. 과거 HTTP 403·401과 Run 6의 HTTP 504는 활용신청 승인이나 License 판정을 취소하는 근거가 아니다. Run 9의 원본 C-01 실패와 공식 문서 충돌을 함께 보존한다. Run 10의 KMA C-01 성공도 엄격한 C-11·Freshness·Coverage·Canary 성공으로 소급하지 않는다. AirKorea 서면 답변과 무관한 다음 검증도 범위·Plan·Hash·사용자 결정을 먼저 고정한다.

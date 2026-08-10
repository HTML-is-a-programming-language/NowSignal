# C-11 ProviderEnvelope Evidence 명세

- 기준일: 2026-08-10 (Asia/Seoul)
- 문서 상태: `offline_spec_ready`
- 실제 C-11 실행 상태: KMA 초단기예보·단기예보는 Run 10 Capture-only `not_evaluated`; KMA 실황과 나머지 Provider·Endpoint는 `not_run`; C-11 `pass` 없음
- 실행 Binding 상태: KMA 단기예보 3개 Endpoint의 queryless `sourceUrl`과 제1유형 일반증서 `license.termsUrl`은 `verified`; 공식 `sourceId`는 없음. 나머지 Provider·Endpoint와 Null·단위 Binding은 `not_verified`
- 목적: 실제 Provider 호출 전에 Source·시각·지역·단위·License·Attribution 결합 규칙과 Sanitized Evidence 형식을 고정한다.
- 비범위: Provider API 호출, 원 응답 저장, 제품 코드, Attribution UI 구현, 14일 Canary, 운영계정·Traffic 상향, 추가 기관 문의
- 상위 계약: [공공 데이터 카탈로그의 ProviderEnvelope](./09-public-data-catalog.md), [Product License Register](./product-license-register.md), [Provider 실검증 Runbook](./provider-validation-runbook.md), [Gate 2 Evidence Matrix](./gate-2-evidence-matrix.md)

이 명세는 C-11 실행 준비 Evidence다. 명시적으로 Hash 고정·검증한 KMA Source·Terms 외의 정적 License·공식 Dataset 근거를 Runtime Binding 또는 실제 응답 결합 성공으로 바꾸지 않으며, `offline_spec_ready`나 Capture 완료를 C-11·Contract·Gate 2 `pass`로 해석하지 않는다.

## 1. 상태 축

| 축 | 허용 상태 | 현재 상태 |
| --- | --- | --- |
| 명세 | `draft`, `offline_spec_ready`, `superseded` | `offline_spec_ready` |
| 실제 응답 결합 | `not_run`, `not_evaluated`, `pass`, `fail`, `not_observed` | KMA 예보 2개 Endpoint Capture-only `not_evaluated`; 나머지 `not_run`; `pass` 없음 |
| 정적 License | Product License Register의 Provider별 판정 | KMA `approved_for_dev`; AirKorea 개발 `approved_for_dev`, 운영 `conditional_for_production` |
| Fixture 출처 | `provider_observed_sanitized`, `provider_official_sample`, `synthetic_classifier_fixture` | Run 10 예보 2개는 `provider_observed_sanitized` Summary·Hash가 있으나 엄격한 C-11 평가는 하지 않음 |
| Runtime Binding | Endpoint별 `verified`, `not_verified`, `not_observed` | KMA 단기예보 Source·Terms `verified`; 나머지 Provider·Endpoint와 Null·단위 Binding `not_verified` |
| 제품 구현 | `not_started`, 향후 Gate 승인 상태 | `not_started` |

Schema·License·실행 상태를 합치지 않는다. 정적 License가 `approved_for_dev`여도 응답 결합을 실행하지 않았다면 C-11은 `not_run`이고, 일부 공개 값을 Capture했지만 전체 Assertion을 수행하지 않았다면 `not_evaluated`다.

## 2. 공통 필수 계약

향후 모든 C-11 Case는 다음을 동시에 충족해야 한다.

1. `providerId`와 `endpointPath`가 사전등록 값과 일치한다.
2. `sourceUrl`과 `sourceId` 중 하나 이상이 비어 있지 않다. 둘 다 있으면 서로 같은 공식 Record를 가리켜야 한다. 공식 Dataset 상세 URL·API 번호를 Runtime Binding으로 사용할지는 Endpoint별 새 Plan에서 명시적으로 고정한다.
3. `sourceUrl`은 인증정보·Query·개인정보가 없는 공식 HTTPS 문서 또는 공식 Record URL만 허용한다. API key가 포함된 전체 요청 URL은 저장하지 않으며, Dataset 근거 URL을 실제 Record 원문 링크로 임의 대체하지 않는다.
4. `evaluatedAt`과 실제 호출의 `fetchedAt`을 분리한다. `fetchedAt`을 관측·발표·발효시각으로 대체하지 않는다.
5. Payload 종류에 맞는 `observedAt`, `issuedAt`, `validFrom`, `validUntil`을 보존한다. 공식적으로 적용되지 않는 필드는 명시적 `not_applicable_by_payload_kind`, 관찰하지 못한 필드는 `not_observed`로 구분한다.
6. 정확한 사용자 GPS 대신 공개 격자·특보구역·측정소·시도 수준 Context만 저장하고 `exactGpsStored=false`를 유지한다.
7. 수치 Field는 Provider 원 단위를 Field별로 보존한다. 정규화 단위가 아직 승인되지 않았으면 `normalizedUnit=null`과 `normalizationStatus=not_approved`를 함께 기록한다.
8. 수치가 없는 특보·측정소 Metadata는 Payload 수준 `unitApplicability=not_applicable_by_payload_kind`와 `units=[]`로 기록한다. 임의의 가상 `field`를 만들지 않는다.
9. `license.registerId`, Endpoint·평가 범위에 대해 정확히 고정한 공식 `termsUrl`, License 상태, 검토일과 최상위 `attribution`을 모두 보존한다. 공공누리 일반 안내 URL을 발급 시점 약관 Snapshot으로 대신하지 않는다.
10. Attribution은 Provider·Dataset·공식 Source·관측 또는 발표시각·확인시각을 포함한다. 적용되지 않는 시각은 임의로 채우지 않는다.
11. 원 응답·원 수치·공식 등급·공식 문장과 NowSignal 정규화·거리·Score·설명을 분리한다. 제3유형 자료는 원본 변경을 금지한다.
12. 필수값 하나라도 누락되거나 License 검토가 만료·충돌하면 C-11을 `fail`로 닫는다. 다른 Provider나 오래된 Cache로 조용히 대체하지 않는다.

## 3. Sanitized Evidence 형식

아래 YAML은 공개 가능한 Manifest 형식이다. 실제 값이 없는 현재 상태에서 예시 응답을 만들거나 `pass`로 채우지 않는다.

```yaml
specId: provider-c11-envelope-evidence-v1
specStatus: offline_spec_ready
runId: null
providerId: null
endpointPath: null
evaluatedAt: null
fetchedAt: null
source:
  sourceUrl: null
  sourceId: null
  sourceReferenceStatus: not_observed
  fullRequestUrlStored: false
time:
  observedAt: null
  issuedAt: null
  validFrom: null
  validUntil: null
  nullReasons: {}
location:
  publicContextType: null
  publicContextValue: null
  regionCode: null
  regionLabel: null
  grid:
    x: null
    y: null
  exactGpsStored: false
unitApplicability: null
units: null
license:
  registerId: null
  termsUrl: null
  registerDecision: null
  evaluatedScope: development_validation
  licenseStatus: null
  reviewedAt: null
  termsSnapshotSha256: not_verified
attribution:
  templateId: null
  renderedValue: null
  renderedSha256: null
  renderedPresent: null
  requiredTokensPresent: null
  missingTokens: null
layers:
  immutableOriginalPresent: null
  derivedLayerPresent: null
  layersSeparated: null
evidence:
  sourceClass: null
  sanitizedProjectionSha256: null
  fieldSignature: null
  rawResponseStored: false
  secretRemoved: null
result:
  resultKind: null
  qualityStatus: null
  errorClass: null
review:
  missingRequiredFields: null
  c11Verdict: not_run
  reviewedAt: null
  reviewerRole: null
```

`termsSnapshotSha256`은 원 HTML 전체가 아니라, Dataset 상세 URL·표시 License·상세 수정일·정확한 공식 Terms URL·검토일·허용행위·출처표시 의무·남은 제3자 권리 Caveat를 키 순서까지 고정한 Canonical UTF-8 JSON Projection의 SHA-256이다. Plan은 그 Canonical JSON과 Hash를 함께 보존해야 하며, 현재 파일 Hash나 일반 안내 URL만 Hash해 대신할 수 없다. Runtime `license.termsUrl`은 Dataset에 표시된 공공누리 유형의 공식 일반증서 URL로 고정하되, 로그인 활용신청의 개별 조건이나 제3자 권리 범위를 대표한다고 확대하지 않는다.

### 3.1 ProviderEnvelope → Evidence Manifest Crosswalk

Evidence Manifest는 상위 `ProviderEnvelope`를 대체하는 Schema가 아니라, C-11에서 공개 가능한 값만 보존하는 Sanitized Projection이다. 다음 대응을 바꾸거나 생략하려면 새 Spec ID와 Plan Hash가 필요하다.

실제 실행 시 수치 Payload는 `unitApplicability=field_level`이고 `units[]`의 각 항목이 `field`, `rawUnit`, `normalizedUnit`, `unitStatus`, `normalizationStatus`를 모두 가진다. 비수치 Payload는 `unitApplicability=not_applicable_by_payload_kind`와 `units=[]`를 함께 사용한다. Template의 두 Null은 아직 평가하지 않았다는 뜻이며 빈 배열이나 N/A 판정이 아니다.

| ProviderEnvelope 경로 | Evidence Manifest 경로 | 고정 변환·검증 규칙 | Null·비보존 규칙 |
| --- | --- | --- | --- |
| `provider` | `providerId` | Canonical Provider ID를 byte-for-byte 복사 | 실제 C-11에서는 Null 금지 |
| `sourceUrl`, `sourceId` | `source.sourceUrl`, `source.sourceId` | Query·Credential이 없는 Sanitized 값을 그대로 복사 | 둘 중 하나 이상 필수; 미관찰은 C-11 `fail` |
| `evaluatedAt`, `fetchedAt` | 같은 이름의 최상위 Field | ISO 8601 값을 그대로 복사 | `not_fetched`의 `fetchedAt`만 명시적 Null 허용 |
| `observedAt`, `issuedAt`, `validFrom`, `validUntil` | `time` 아래 같은 이름의 Field | Endpoint Plan에 고정한 Provider Field 또는 허용된 요청 Context를 그대로 복사 | Payload별 Null 분류를 `time.nullReasons`에 함께 기록 |
| `region.label` | `location.regionLabel` | 공개 가능한 지역 Label을 그대로 복사 | `data`·`valid_empty`에서 Null 금지; `unavailable`·`not_fetched`만 명시적 Null 허용 |
| `region.code` | `location.regionCode` | 공식 공개 Code가 있을 때 그대로 복사 | 공식 Code가 없는 Payload만 Null 허용 |
| `region.grid.x`, `region.grid.y` | `location.grid.x`, `location.grid.y` | 공개 KMA 격자처럼 사전등록한 정수 Grid만 복사 | 비격자 Payload는 둘 다 Null; 한쪽만 존재하면 `fail` |
| 공개 요청·응답 Context | `location.publicContextType`, `location.publicContextValue` | `region`의 출처를 설명하는 Evidence-only Metadata로 기록 | `ProviderEnvelope` 값을 보충하거나 덮어쓰지 않음 |
| `unitApplicability` | `unitApplicability` | `field_level` 또는 `not_applicable_by_payload_kind`를 그대로 복사 | 수치 Payload의 N/A와 비수치 Payload의 `field_level`은 `fail` |
| `units[]` | `units[]` | `field`, `rawUnit`, `normalizedUnit`, `unitStatus`, `normalizationStatus`를 Field별로 순서 정규화 후 복사 | 수치 Field 누락은 `fail`; 비수치 Payload는 빈 배열만 허용 |
| `license.id` | `license.registerId` | Product License Register ID를 그대로 복사 | Null 금지 |
| `license.termsUrl` | `license.termsUrl` | 사전 고정한 정확한 공식 Terms URL을 그대로 복사 | `not_verified` 상태에서는 실제 C-11 실행·통과 금지 |
| `licenseStatus` | `license.licenseStatus` | Runtime 평가 결과를 그대로 복사 | `registerDecision`과 별도이며 자동 변환 금지 |
| `attribution` | `attribution.renderedValue`, `renderedSha256`, `renderedPresent` | 렌더 문자열을 그대로 보존하고 UTF-8 SHA-256을 별도 계산 | Token 검증 전 `renderedPresent=true` 금지 |
| `resultKind`, `qualityStatus`, `errorClass` | `result` 아래 같은 이름의 Field | 상태 문자열을 그대로 복사 | 서로 다른 상태 축을 합치지 않음 |
| `data` | `evidence.sanitizedProjectionSha256`, `evidence.fieldSignature` | 원 Payload를 복사하지 않고 Sanitized Projection의 UTF-8 SHA-256과 허용 Field 이름·형식만 기록 | 원 응답·원 Payload·비밀 포함 Hash Input 저장 금지 |

`issuedAt`, `unitApplicability`, Field별 `units[]`는 이 명세에서 새로 발명한 Evidence-only 값이 아니라 상위 ProviderEnvelope 초안에도 같은 의미로 명시한다. Manifest Template의 단위 관련 Null은 `not_run` 상태를 뜻하며, 실제 C-11에서는 Payload 종류에 맞는 상태와 배열로 바꾼다. 반대로 `endpointPath`, `runId`, `sourceReferenceStatus`, `nullReasons`, `publicContextType`, Snapshot Hash, Token 목록과 Review Field는 C-11 검증용 Evidence-only Metadata이며 제품 응답에 자동 추가하지 않는다.

## 4. Provider별 사전등록 매핑

| Provider ID | 대상 Endpoint | Source 후보·고정 전 조건 | 시각 기준 | 공개 지역 Context | 단위 기준 | License | 현재 차단 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `kma-data-go-kr-vilage-fcst` | `/getUltraSrtNcst`, `/getUltraSrtFcst`, `/getVilageFcst` | API `15084084`는 공식 근거. Endpoint별 queryless Runtime `sourceUrl`과 제1유형 일반증서 `termsUrl`은 `verified`; 공식 canonical `sourceId`는 없어 Null 고정 | 실황 관측시각과 예보 발표·유효시각 분리 | KMA 공개 `nx`, `ny` | Category별 원 단위 필수; Field 단위표와 Null 규칙은 Endpoint Plan에서 고정 | `LIC-KMA-001`, 공공누리 제1유형 | 실황 C-11 `not_run`; Run 10 예보 2개 Capture-only `not_evaluated`; Source·Terms Binding `verified`; 엄격한 C-11 `pass` 없음 |
| `kma-data-go-kr-weather-warning` | `/getWthrWrnList`, `/getWthrWrnMsg`, `/getPwnStatus` | API `15000415`는 공식 근거. 공식 특보 ID 또는 발표기관·발표시각·대상구역 Composite의 정확한 규칙은 `not_verified` | 발표·발효·해제시각 분리 | 공식 특보구역 Code·Label | 비수치 Payload이면 `unitApplicability=not_applicable_by_payload_kind`·`units=[]` 후보; Endpoint별 공식 근거 전 `not_verified` | `LIC-KMA-002`, 공공누리 제1유형 | 전문·현황 `not_run`; Source·Terms·Null Binding `not_verified`; 실제 C-11 `not_run` |
| `airkorea-station` | `/getMsrstnList`, `/getNearbyMsrstnList` | API `15073877`은 공식 근거. 안정된 측정소 ID·Code·명칭의 Runtime Binding은 실제 Field 확인 전 `not_verified` | Metadata의 관측·발표·유효시각 Null 허용 규칙은 `not_verified` | 시도·측정소·공개 TM Context | 비수치 Payload이면 `unitApplicability=not_applicable_by_payload_kind`·`units=[]` 후보; Endpoint별 공식 근거 전 `not_verified` | `LIC-AIR-001`, 공공누리 제3유형 | 근접 측정소 `not_run`; Source·Terms·Null Binding `not_verified`; 위치 절차·Cache는 별도 미확인; 실제 C-11 `not_run` |
| `airkorea-air-measurement` | `/getMsrstnAcctoRltmMesureDnsty`, `/getMinuDustFrcstDspth` | API `15073861`은 공식 근거. 관측 측정소 Context 보충은 공식 Schema 분기와 새 Plan 전 `not_verified`이며 응답 Echo를 가정하지 않음 | 관측 `dataTime` 후보; 예보 발표회차·유효일 Mapping은 실제 검증 전 `not_observed` | 측정소 또는 예보 지역 | 오염물질별 원 단위·등급 보존; Field 단위표와 실제 결합은 `not_observed` | `LIC-AIR-001`, 공공누리 제3유형 | Run 9 원본 C-01 `fail`, 공식 Schema 충돌; Source·Terms·Null Binding `not_verified`; 파생·AI·Cache는 별도 미확인; 실제 C-11 `not_run` |

### 4.1 Field provenance·Null 규칙

| Field·Group | Presence 규칙 | 허용 Provenance | 현재 Binding |
| --- | --- | --- | --- |
| `providerId`, `endpointPath`, `evaluatedAt` | 항상 `required_non_null` | Plan·검증기 상수 | Provider ID만 확정, Endpoint별 C-11 Plan은 `not_verified` |
| `fetchedAt` | 실제 호출 결과는 `required_non_null`; License 차단 `not_fetched`만 명시적 Null | 검증기 Clock | Run 10 예보 2개 Capture에서 관찰했으나 엄격한 C-11은 `not_evaluated`; 나머지 `not_run` |
| `sourceUrl`, `sourceId` | 둘 중 하나 이상 `required_non_null` | 공식 Record·응답 식별자·사전등록 Composite | KMA API `15084084`의 queryless `sourceUrl`과 공식 `sourceId=null`은 `verified`; 나머지 Provider는 `not_verified` |
| `observedAt`, `issuedAt`, `validFrom`, `validUntil` | Endpoint별 `required_non_null`, `required_nullable`, `not_applicable_by_payload_kind` 중 하나를 Plan에 고정 | 원 응답 Field 우선; 공식 근거가 있는 요청 Context만 예외 | KMA 예보 2개 Endpoint의 Null 정책은 Run 10 Plan에 사전등록했지만 실제 C-11은 `not_evaluated`; 나머지는 `not_verified` |
| 공개 지역 Context | `data`·`valid_empty`에서 `required_non_null` | 응답 Field 또는 공식 근거로 고정한 공개 요청 Context | Run 10 KMA Grid Capture는 완료됐지만 엄격한 결합은 `not_evaluated`; 나머지 `not_run` |
| `units[].rawUnit` | 수치 Field마다 `required_non_null`; 비수치 Payload에는 항목을 만들지 않음 | 공식 Field·기술문서의 Version 고정 단위표 | KMA 예보 핵심 Category 단위표는 Run 10 Plan에 사전등록했지만 엄격한 C-11 결합은 `not_evaluated`; 나머지는 `not_verified` 또는 `not_observed` |
| `units[].normalizedUnit` | 수치 Field에 승인된 정규화가 없으면 `required_nullable`과 `normalizationStatus=not_approved` | NowSignal 파생층 | 제품 설계 전 `not_approved` |
| `unitApplicability` | 항상 `required_non_null`; `field_level`, `not_applicable_by_payload_kind`만 허용 | Payload 종류 | Run 10 예보 2개 Capture는 `field_level`, 엄격한 결합 `not_evaluated`; 나머지 `not_run` |
| `units[].unitStatus` | 모든 수치 Field 항목 `required_non_null`; `observed`, `not_observed`만 허용 | 원 단위 관찰 여부 | Run 10은 공개 단위 Signature를 Capture했지만 전체 상태 Assertion은 `not_evaluated`; 나머지 `not_run` |
| License Group | Register ID·정확한 terms URL·Snapshot Hash·검토일·평가 범위 상태 모두 `required_non_null` | License Register와 발급 시점 공식 Snapshot | KMA `LIC-KMA-001`·제1유형 일반증서·공개 Evidence Projection은 고정; 평가 범위·실제 C-11 결합은 `not_evaluated`, 나머지는 일부 `not_verified` |
| `attribution` | Placeholder가 모두 실제 검증값으로 채워진 문자열 `required_non_null` | 검증된 Source·시각·Provider Metadata | Run 10은 렌더링 SHA만 Capture했고 엄격한 문자열·Token Assertion은 `not_evaluated`; 나머지 `not_run` |

Provenance는 `response_field`, `request_context`, `registry_constant`, `derived`로 분리한다. `response_field`가 우선이며, `request_context`는 공식 계약이 같은 의미를 보장하고 Plan에 사전등록한 경우에만 사용한다. `registry_constant`는 License ID·Provider ID 같은 정적 값에 한정한다. `derived` 값은 Source·공식 시각·원 단위·License를 보충하거나 덮어쓸 수 없다.

AirKorea 대기오염의 측정소 Context는 공식 Schema 답변 전 `request_context` 보충을 허용하지 않는다. KMA 특보 단위와 AirKorea 측정소 Metadata 시각·단위는 Endpoint별 공식 N/A 근거가 고정되기 전 Null을 성공으로 처리하지 않는다.

### 4.2 KMA 단기예보

- 공식 Dataset 근거 URL (Runtime `sourceUrl` 아님): [공공데이터포털 API 15084084](https://www.data.go.kr/data/15084084/openapi.do)
- 공공누리 해석 참고: [공공누리 공식 이용안내](https://www.kogl.or.kr/info/userGuide.do)
- Runtime `sourceUrl`: `/getUltraSrtNcst`는 `https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst`, `/getUltraSrtFcst`는 `https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst`, `/getVilageFcst`는 `https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst`로 고정. Query·Credential은 붙이지 않음
- Runtime `sourceId`: 공식 canonical Record ID가 없어 `null`. `baseDate`·`baseTime`·Grid·Category 조합을 공식 ID로 부르지 않음
- Runtime `license.termsUrl`: `https://www.kogl.or.kr/info/licenseType1.do`로 `verified`. 이는 Dataset에 표시된 제1유형의 공식 일반증서이며 활용신청 개별 조건·제3자 권리 범위는 별도 Canonical Evidence Projection에 보존
- Attribution template ID: `ATTR-KMA-FCST-001`
- Template: `출처: 기상청 단기예보 조회서비스 · 발표 또는 관측 {sourceTime} KST · 확인 {fetchedAt} · 원문 {sourceReference}`
- `getUltraSrtNcst`는 관측 회차를, 예보 두 Endpoint는 발표 회차와 개별 유효시각을 분리한다.
- Category·원값·원 단위가 같은 Sanitized Projection 안에서 연결되지 않으면 C-11 `fail`이다.
- 상세 페이지의 제3자 권리 포함 표시와 장기 Cache 범위는 아직 별도 Evidence가 필요하다. 정적 제1유형 확인만으로 LLM 입력·장기보관을 허용하지 않는다.

### 4.3 KMA 기상특보

- 공식 Dataset 근거 URL (Runtime `sourceUrl` 아님): [공공데이터포털 API 15000415](https://www.data.go.kr/data/15000415/openapi.do)
- 공공누리 해석 참고: [공공누리 공식 이용안내](https://www.kogl.or.kr/info/userGuide.do)
- Runtime `license.termsUrl`: `not_verified`; 발급 시점 상세·약관 Snapshot과 함께 새 Plan에서 고정
- Attribution template ID: `ATTR-KMA-WARNING-001`
- Template: `출처: 기상청 기상특보 조회서비스 · 발표기관 {office} · 발표 {issuedAt} KST · 확인 {fetchedAt} · 원문 {sourceReference}`
- 공식 원문·기관·발표·발효·해제·대상지역을 NowSignal 설명보다 우선하며 수정하지 않는다.
- 특보가 없는 `valid_empty`도 Source·확인시각·License·Attribution을 유지해야 한다. 이를 전체 재난 안전으로 표시하지 않는다.
- 원문과 정정·해제 연결을 관찰하기 전 C-11과 안전 표시를 통과시키지 않는다.

### 4.4 AirKorea 측정소

- 공식 Dataset 근거 URL (Runtime `sourceUrl` 아님): [공공데이터포털 API 15073877](https://www.data.go.kr/data/15073877/openapi.do)
- 공공누리 해석 참고: [공공누리 공식 이용안내](https://www.kogl.or.kr/info/userGuide.do)
- Runtime `license.termsUrl`: `not_verified`; 발급 시점 상세·약관 Snapshot과 함께 새 Plan에서 고정
- Attribution template ID: `ATTR-AIR-STATION-001`
- Template: `출처: 한국환경공단 AirKorea 측정소정보 · 측정소 {stationNameOrId} · 확인 {fetchedAt} · 원문 {sourceReference}`
- 측정소 ID·Code·명칭 중 실제 공식 응답에서 안정적으로 관찰한 식별자를 `sourceId`에 사용한다. 임의 주소나 사용자 위치로 만들지 않는다.
- 공개 측정소 좌표와 사용자 GPS를 분리한다. Repository Evidence에는 사용자 GPS·이동경로를 저장하지 않는다.
- 제3유형 원본과 거리 계산을 분리하며, 위치 관련 절차와 최소 TTL 범위가 해소되기 전 Production 판정은 유지한다.

### 4.5 AirKorea 대기오염

- 공식 Dataset 근거 URL (Runtime `sourceUrl` 아님): [공공데이터포털 API 15073861](https://www.data.go.kr/data/15073861/openapi.do)
- 공공누리 해석 참고: [공공누리 공식 이용안내](https://www.kogl.or.kr/info/userGuide.do)
- Runtime `license.termsUrl`: `not_verified`; 발급 시점 상세·약관 Snapshot과 함께 새 Plan에서 고정
- Attribution template ID: `ATTR-AIR-MEASUREMENT-001`
- Template: `출처: 한국환경공단 AirKorea · 측정소 또는 지역 {stationOrRegionContext} · 관측 또는 발표 {sourceTime} KST · 확인 {fetchedAt} · 원문 {sourceReference}`
- 관측 Endpoint의 측정소 Context를 요청값과 측정소 Source로 보충하는 규칙은 공식 Schema 답변 또는 일치하는 공식 문서가 허용한 분기에서만 새 Plan에 사전등록한다. 답변 전에는 이 보충으로 C-11을 통과시키지 않고 `stationName` 응답 Echo가 있다고 가정하지 않는다.
- Run 9의 HTTP 200·Provider `00`·Item 1개·핵심 Field 관찰은 C-11을 평가하지 않았으므로 이 명세에서 재사용해 `pass`로 바꾸지 않는다.
- PM10·PM2.5·O3 원 수치·공식 등급·원 단위를 immutable 원본층에 함께 보존한다. 결측을 0으로 채우거나 인접 측정소로 묵시 보간하지 않는다.
- Schema 답변은 응답 필드 충돌만 다룬다. 제3유형 파생·AI·Cache와 위치 관련 조건을 자동 해소하지 않는다.

## 5. Fixture·Assertion 규칙

| Source Class | C-11에서 허용하는 용도 | C-11 실제 `pass` 가능 여부 |
| --- | --- | --- |
| `provider_observed_sanitized` | 실제 응답에서 필수 결합과 Redaction을 검증 | 모든 Assertion과 C-12를 통과한 해당 Provider·Endpoint에 한해 가능 |
| `provider_official_sample` | 공식 Field·단위·Source 후보 매핑의 사전검토 | 단독으로 실제 응답 결합 `pass` 금지 |
| `synthetic_classifier_fixture` | Client의 누락·차단 분기 결정론 검증 | Provider C-11·Schema 근거로 사용 금지 |

향후 검증기는 최소한 다음 Assertion을 독립적으로 기록한다.

| Assertion ID | 통과 조건 | 실패 판정 |
| --- | --- | --- |
| `C11-SOURCE` | 새 Plan에 정확히 고정한 공식 `sourceUrl` 또는 안정된 `sourceId`가 있고 비밀 Query가 없음 | `source_missing_or_unsafe` |
| `C11-TIME` | Payload 종류의 필수 시각이 파싱 가능하고 N/A·미관찰이 구분됨 | `source_time_missing_or_ambiguous` |
| `C11-REGION` | 공개 격자·구역·측정소 Context가 요청·응답 Evidence와 연결됨 | `public_region_context_missing` |
| `C11-UNIT` | 수치 Payload는 `field_level`과 모든 수치 Field의 원 단위를 가지며, 비수치 Payload는 `not_applicable_by_payload_kind`와 빈 `units[]`를 가짐 | `raw_unit_missing_or_applicability_invalid` |
| `C11-LICENSE` | Register ID·정확히 고정한 terms URL·Snapshot Hash·검토일·평가 범위 상태가 모두 유효 | `license_evidence_missing_or_expired` |
| `C11-ATTRIBUTION` | Provider·Dataset·Source·필수 시각·확인시각 Token이 모두 렌더링됨 | `attribution_incomplete` |
| `C11-LAYER` | immutable 원본과 정규화·파생층이 분리됨 | `original_and_derived_layers_mixed` |
| `C11-REDACTION` | Secret·전체 요청 URL·원 응답·정확 GPS 저장 0 | `restricted_artifact_detected` |

한 Assertion이라도 실패하면 해당 Case의 C-11은 `fail`이다. `provider_official_sample`만으로 실제 응답 결합을 통과시키거나, 하나의 Provider 결과를 다른 Provider·Endpoint에 확대하지 않는다.

## 6. 현재 Evidence와 재개 조건

| Provider ID | Offline 명세 | 실제 C-11 | 다음 Evidence | 재개 권한 |
| --- | --- | --- | --- | --- |
| `kma-data-go-kr-vilage-fcst` | `offline_spec_ready` | 실황 `not_run`; Run 10 예보 2개 `not_evaluated`; `pass` 없음 | 엄격한 License scope·단위 상태·Attribution 문자열·원본/파생 Layer Assertion을 새 Plan에서 모두 평가 | `owner_network_decision_required` |
| `kma-data-go-kr-weather-warning` | `offline_spec_ready` | `not_run` | 목록·전문·현황의 원문·정정·해제·Attribution 결합 | `owner_network_decision_required` |
| `airkorea-station` | `offline_spec_ready` | `not_run` | 측정소 식별자·공개 지역 Context·제3유형 Attribution 결합 | `owner_network_decision_required` |
| `airkorea-air-measurement` | `offline_spec_ready` | `not_run` | 공식 Schema 분기 뒤 새 Plan의 측정소 Context·원 단위·제3유형 Attribution 결합 | `owner_network_decision_required` |

실제 C-11 실행은 Endpoint·Fixture·호출 상한·Plan Hash와 사용자 결정을 먼저 고정해야 한다. Attribution UI와 Adapter 구현은 Gate 3·4 승인 전 시작하지 않는다.

## 7. 공개 저장 통제

- API key 원문·일부·Encoded 값과 key가 포함된 전체 URL
- 원 응답·Header·예외 원문·계정 또는 신청 식별정보
- 정확한 사용자 GPS·상세 주소·이동경로
- License terms를 대신한다고 주장하는 비공식 복사본
- 실제로 관찰하지 않은 Source ID·시각·단위·Attribution 성공값

Repository에는 이 명세, Sanitized Projection Hash, 필수값 존재 여부·판정과 검증을 통과한 공개 Attribution 문자열·그 UTF-8 SHA-256만 남길 수 있다. Attribution의 `{sourceReference}`는 Query·Credential이 없는 Runtime `sourceUrl` 또는 안정된 `sourceId`여야 하며, 이를 충족하지 못하면 문자열을 저장하지 않고 C-11을 `fail`로 닫는다.

# Gate 2 Evidence Matrix

- 기준일: 2026-08-10 (Asia/Seoul)
- 문서 상태: `offline_evidence_index_active`
- Gate 상태: `in_progress`
- 목적: Phase 1 네 Provider의 현재 근거, 완료 조건과 재개 권한을 한곳에서 분리해 추적한다.
- 비범위: 제품 코드, 추가 API 호출, 추가 기관 문의, 운영계정 신청, Traffic 상향, 14일 Canary 실행
- 근거 문서: [작업 목록](../TASKS.md), [Provider 실검증 Runbook](./provider-validation-runbook.md), [Gate 1·2 비코드 준비 감사](./gate-1-2-readiness-audit.md), [수동 작업 체크리스트](./manual-action-checklist.md), [공공 데이터 카탈로그](./09-public-data-catalog.md), [Product License Register](./product-license-register.md), [Decision Log](./14-decision-log.md), [AirKorea Schema 문의 기록](./airkorea-schema-inquiry-draft.md)

이 문서는 기존 근거의 색인이지 새로운 실행 Evidence가 아니다. `pass`, `fail`, `not_run`, `not_verified`, `not_evaluated`를 합치지 않으며, 활용신청 승인이나 정상 Header 관찰을 전체 Contract·Freshness·Coverage·License 통과로 확대하지 않는다.

## 1. 재개 권한 표기

| 표기 | 의미 |
| --- | --- |
| `offline_documentation` | 기존 공개 문서와 Sanitized Evidence를 정리하는 비실행 작업. 외부 상태를 바꾸지 않는다. |
| `offline_fixture` | 실제 Provider 동작을 주장하지 않는 `synthetic_classifier_fixture` 설계·검증. 제품 코드가 아니다. |
| `owner_network_decision_required` | 새 Plan·Hash·Run·호출 상한을 먼저 고정하고 사용자가 별도로 실제 호출을 결정해야 한다. 현재 재개 권한 없음. |
| `owner_canary_decision_required` | 실행환경·예산·고정 Target·`canaryPlanId`·Hash를 먼저 고정하고 사용자가 14일 실행을 별도로 승인해야 한다. 현재 재개 권한 없음. |
| `written_response_or_specialist_review_required` | 제공기관의 서면 답변 또는 전문 검토가 있어야 판정을 바꿀 수 있다. 현재 추가 문의 권한 없음. |
| `gate_3_4_approval_required` | 제품 설계·구현·자동 선택·UI 검증 단계의 권한. Gate 2와 Gate 3 승인 전에는 진행하지 않는다. |

## 2. AirKorea 서면 답변 3분기

### 2.1 변경할 수 없는 공통 기준

- 대상은 API `15073861`의 `/getMsrstnAcctoRltmMesureDnsty`다.
- Run 9 원본 Manifest의 `schemaStatus=required_fields_missing`, `missingRequiredFields=["stationName"]`, `providerContractVerdict=fail`, `c01=fail`은 모든 분기에서 그대로 보존한다.
- Run 9에서 관찰한 HTTP 200, Provider `00`, Item 1개와 `dataTime`·`pm10Value`·`pm25Value`는 해당 관찰 범위만 증명한다. 전체 응답표, Freshness, 품질, 다른 Endpoint 또는 Canary 통과를 뜻하지 않는다.
- 현재 공식 자료는 Live 응답표·공식 XML Sample과 첨부 v1.4 응답 필드표가 `stationName`·`stationCode` 포함 여부에서 충돌한다.
- Schema 문의는 2026-08-10 공공데이터포털에서 한국환경공단 대상으로 제출됐고 상태는 `submitted_pending_response`·`접수`다. 답변 전 같은 문의를 중복 제출하지 않는다.

| 분기 | 분기 선택에 필요한 서면 근거 | Run 9 원본 판정 | 답변 반영 후 상태 | 후속 조치 | 남는 차단 조건·재개 권한 |
| --- | --- | --- | --- | --- | --- |
| `request-only` | `stationName`·`stationCode`가 응답 필수가 아니며 요청 Context로 식별해도 된다는 현행 버전·적용 범위가 명확한 답변 또는 서로 일치하도록 개정된 공식 문서 | `c01=fail` 보존. 과거 사전등록 조건을 사후 완화해 `pass`로 바꾸지 않음 | 공식 Schema 충돌은 미래 Contract 설계에서 해소할 수 있으나 Run 9 자체는 실패 이력 | 답변일·답변기관·공식 판정만 공개 기록. 새 Plan에서는 요청 측정소 Context를 보존하고 응답 Echo를 필수 Property에서 제외하되, PM 필드·시각·Source·License와 요청 Context 연결 조건을 새 Hash로 고정 | Freshness·품질·C-02~C-11·다른 Endpoint·Canary는 미완료. 실제 재검증은 `owner_network_decision_required`; 구현은 `gate_3_4_approval_required` |
| `response-required` | 두 Field가 해당 Endpoint·응답 형식·버전에서 필수라는 현행 계약과 적용시점이 명확한 답변 | `c01=fail` 보존. Run 9는 필수 응답 Field 누락 사례 | 해당 Endpoint의 현재 Provider Contract 실패로 차단. 핵심 필드 관찰을 C-01 성공으로 대체하지 않음 | 정정된 Provider 응답 또는 공식 계약 변경 전 같은 요청을 확인 목적으로 반복하지 않음. Provider 유지·대체·대기질 범위 축소는 별도 Decision으로 처리 | 범위 유지 여부는 사용자 결정. 향후 수정 확인 호출은 `owner_network_decision_required`; 범위 축소도 Founder scope·Decision Log 변경 승인 필요 |
| `ambiguous` | 답변이 버전·형식·적용시점·요청 Context 사용 가능 여부를 확정하지 못하거나 기존 공식 자료 충돌이 남음 | `c01=fail` 보존 | `conflicting_official_schema`와 `blocked_pending_official_schema_response_and_next_network_scope_decision` 유지 | 답변을 성공 또는 Provider 위반으로 임의 해석하지 않음. 같은 문의·같은 요청을 중복하지 않고, 문서 개정 대기·전문 검토·범위 축소 중 하나를 별도 결정 | 추가 문의·전문 검토는 `written_response_or_specialist_review_required`와 새 사용자 승인 필요. 다음 호출은 `owner_network_decision_required` |

분기 선택은 서면 답변의 기관, 답변일, 대상 API·Endpoint, 응답 형식, 버전과 적용시점을 확인한 뒤에만 한다. 답변 원문의 개인 식별정보나 Screenshot은 Repository에 저장하지 않는다.

## 3. Phase 1 Provider 범위

| Provider ID | 역할 | 현재 개발·License 판정 | 현재 실검증 요약 |
| --- | --- | --- | --- |
| `kma-data-go-kr-vilage-fcst` | KMA 초단기실황·초단기예보·단기예보 | `approved_for_dev` | `/getUltraSrtNcst` C-01 `pass`; 다른 정상 Endpoint와 계획 오류 Case `not_run` |
| `kma-data-go-kr-weather-warning` | KMA 기상특보 목록·통보문·현황 | `approved_for_dev` | `/getWthrWrnList` C-01 `pass`; 다른 정상 Endpoint와 계획 오류 Case `not_run` |
| `airkorea-station` | AirKorea 측정소 목록·근접 측정소 | 개발 `approved_for_dev`, 운영 `conditional_for_production` | `/getMsrstnList` C-01 `pass`; 근접 측정소 `not_run` |
| `airkorea-air-measurement` | AirKorea 측정소별 관측·대기질 예보 | 개발 `approved_for_dev`, 운영 `conditional_for_production` | Run 9 원본 C-01 `fail`, 공식 Schema `conflicting_official_schema`; 예보 Endpoint `not_run` |

## 4. C-01~C-12 현재 Evidence·완료 조건·재개 권한

| ID | KMA 단기예보 | KMA 기상특보 | AirKorea 측정소 | AirKorea 대기오염 | 완료 조건 | 재개 권한 |
| --- | --- | --- | --- | --- | --- | --- |
| `C-01` | `/getUltraSrtNcst` HTTP 200·Provider `00`·Item 8개·필드 Signature 관찰, `pass`. `/getUltraSrtFcst`, `/getVilageFcst`는 `not_run` | `/getWthrWrnList` HTTP 200·Provider `00`·Item 2개·필드 Signature 관찰, `pass`. `/getWthrWrnMsg`, `/getPwnStatus`는 `not_run` | `/getMsrstnList` HTTP 200·Provider `00`·Item 1개·필드 Signature 관찰, `pass`. `/getNearbyMsrstnList`는 `not_run` | `/getMsrstnAcctoRltmMesureDnsty` Run 9 원본 `fail`; 핵심 필드 3개 관찰과 공식 Schema 충돌을 분리. `/getMinuDustFrcstDspth`는 `not_run` | 최종 Phase 1 범위에 남긴 정상 Endpoint가 HTTP·Provider code·JSON Body·사전등록 필수 Schema를 통과하고 미해결 `fail` 또는 `not_observed`가 없어야 함. AirKorea Run 9 실패는 보존 | 기존 Evidence 정리는 `offline_documentation`. 새 정상 호출은 모두 `owner_network_decision_required`; AirKorea 필수 Schema는 서면 답변 분기 선행 |
| `C-02` | `not_run` | `not_run` | `not_run` | `not_run` | 같은 의미의 XML·JSON 공식 지원 범위를 먼저 고정하고 필드 의미와 Parser 차이를 비교. 한 형식이 공식 미지원일 때만 공식 근거와 함께 `not_applicable` 잠금 | 실제 비교는 `owner_network_decision_required`. 공식 Sample 비교는 `offline_documentation`이지만 Provider 실동작 통과로 표시 금지 |
| `C-03` | `not_run`. 과거 HTTP 403·401은 C-01 시도의 `unclassified` 결과이며 키 누락 Case 근거가 아님 | `not_run` | `not_run` | `not_run` | 키 완전 누락 Case가 `auth_error`, 재시도 0, Secret Log 0으로 판정돼야 함 | `owner_network_decision_required` |
| `C-04` | `not_run`; 과거 403·401은 무효 키 Case로 소급 분류하지 않음 | `not_run` | `not_run` | `not_run` | 실제 키와 무관한 고정 Synthetic invalid key Case가 `auth_error`, 자동 재발급·재시도 0으로 판정돼야 함 | `owner_network_decision_required` |
| `C-05` | `not_run` | `not_run` | `not_run` | `not_run` | 각 Provider ID에서 활용 미승인·권한 거부를 `permission_denied`로 분리하고 사용자 수동 조치로 전환하는 사전등록 Evidence가 필요 | 실행 방법·근거를 먼저 잠가야 하며 외부 동작은 `owner_network_decision_required` |
| `C-06` | `not_run`; 계획 Case는 잘못된 `base_date` | `not_run`; 계획 Case는 잘못된 `pageNo` | `not_run`; 계획 Case는 잘못된 `tmX` | `not_run`; 계획 Case는 `stationName` 누락 | 잘못된 Parameter·형식이 `invalid_request`, 재시도 0으로 분류되고 HTTP·Provider code가 분리 기록돼야 함 | `owner_network_decision_required` |
| `C-07` | `not_run` | `not_run` | `not_run` | `not_run` | 사전등록한 존재하지 않는 Endpoint가 `endpoint_invalid`로 분류되고 다른 Provider로 조용히 전환하지 않아야 함 | `owner_network_decision_required` |
| `C-08` | `not_run`; Endpoint별 적용 여부도 잠금 전 | `not_run`; 날씨 특보 범위의 정상 빈 결과와 장애 구분은 필수 | `not_run`; 적용 여부 잠금 전 | `not_run`; 공식적으로 정상 빈 결과가 가능한 Endpoint 범위 잠금 전 | KMA 특보와 공식적으로 유효 빈 결과가 가능한 Endpoint에서 `valid_empty`와 장애를 구분. 의미가 없는 Endpoint만 공식 근거와 함께 `not_applicable` 가능 | 실제 빈 결과 Evidence는 `owner_network_decision_required` 또는 승인된 Canary 범위. 적용 범위 정리는 `offline_documentation` |
| `C-09` | Provider 행동 `not_run`; 공통 Client Synthetic 분기 `pass` | Provider 행동 `not_run`; 공통 Client Synthetic 분기 `pass` | Provider 행동 `not_run`; 공통 Client Synthetic 분기 `pass` | Run 6 HTTP 504 Sanitized Envelope 1건은 원인 `unclassified`, 원 Manifest `c09=not_run`; 공통 Client Synthetic 분기 `pass` | 별도 오류 분류기 16개 Fixture 중 Timeout·Gateway·AirKorea code `05` 분기가 `unavailable`, 모호한 Payload·403·잘린 Chain은 `not_classified`로 결정론적 분류. Synthetic 결과를 Provider 자체 행동으로 주장하지 않음 | Client 분기 검증 `offline_fixture` 완료. 실제 Provider 행동 재검증은 `owner_network_decision_required` |
| `C-10` | Provider 행동 `not_run`; 공통 Client Synthetic 분기 `pass` | Provider 행동 `not_run`; 공통 Client Synthetic 분기 `pass` | Provider 행동 `not_run`; 공통 Client Synthetic 분기 `pass` | Provider 행동 `not_run`; 공통 Client Synthetic 분기 `pass` | HTTP 429·일일 Cap 사전차단·일반 Quota Signal을 `unavailable`로 닫고 같은 Run Retry 0을 검증. `Retry-After` 값 Parse·정책 실행과 실제 승인량·Reset 시각은 계속 미검증 | Client 분기 검증 `offline_fixture` 완료. 실제 Quota 소진 금지; 사용량 확인·실호출은 별도 사용자 결정 필요 |
| `C-11` | 정적 License는 공공누리 제1유형·`approved_for_dev`; 실제 응답과 Source·License·Attribution 결합은 `not_run` | 정적 License는 공공누리 제1유형·`approved_for_dev`; 원문 우선·정정 연결의 실제 결합은 `not_run` | AirKorea 공공누리 제3유형·운영 `conditional_for_production`; 실제 응답 결합은 `not_run` | 같은 `LIC-AIR-001`; Run 9는 License·Attribution 결합을 평가하지 않음 | [C-11 사전등록 명세](./provider-c11-envelope-evidence-spec.md)는 `offline_spec_ready`. ProviderEnvelope에서 Source·시각·지역·단위·License·Attribution을 모두 추출·보존하고 하나라도 누락되면 fail. 정적 등록부와 실제 Fixture 근거를 분리 | Runtime Source·Terms·Null Binding은 `not_verified`, 실제 C-11은 네 Provider 모두 `not_run`. 실제 응답은 `owner_network_decision_required`; UI·구현은 `gate_3_4_approval_required` |
| `C-12` | Run 3 호출 전후 Repository·환경변수 원문·encoded 흔적 0, `pass` | Run 5 호출 후 공통 검사 0, `pass` | Run 5 호출 후 공통 검사 0, `pass` | Run 9 사전·사후 추적·미추적·환경 원문·encoded와 Scan 오류 모두 0, Security conformance `pass` | 각 새 실행에서도 사전·사후 key 흔적과 Scan 오류가 0이고 Secret·Full URL·원 응답·예외 원문을 저장하지 않아야 함. 과거 pass가 미래 Run을 면제하지 않음 | 로컬 사전검사는 실행 Plan의 필수 조건. 새 외부 실행 자체는 `owner_network_decision_required` |

## 5. Freshness·Coverage·License Matrix

| Provider | 축 | 현재 Evidence | 완료 조건 | 재개 권한·현재 차단 |
| --- | --- | --- | --- | --- |
| KMA 단기예보 | Freshness | C-01 고정시각 호출은 Freshness 근거가 아니며 14일 Canary `not_run` | 두 고정 격자의 계획 Poll에서 관측 Age p50·p95·p99와 발표 도착 지연을 기록. 초단기실황은 관측시각·격자·강수 형태·1시간 강수량·기온·습도·풍속·Source·단위를 갖추고 Age 90분 이내인 사용 가능 표본 95% 이상, 예보는 잠금된 허용 지연 기준을 충족해야 함 | 계획 정리는 `offline_documentation`; 실행은 `owner_canary_decision_required`. 실제 승인량·Reset 시각도 `not_verified` |
| KMA 단기예보 | Coverage | `/getUltraSrtNcst` 한 격자·한 시점 Field 관찰만 있음. 초단기·단기예보 Coverage `not_run` | 두 고정 격자에서 초단기예보 첫 6시간, 단기예보 첫 12시간의 사전등록 `유효시각 × 필수 Category` Cell Coverage가 사용 가능 회차마다 100%이고 사용 가능 표본 비율 95% 이상. 강수 형태·양, 기온·습도·풍속과 단기예보의 강수확률을 포함 | `owner_canary_decision_required`; Category 매핑·Target·분모·허용 지연을 `canaryPlanId`·Hash로 먼저 고정 |
| KMA 단기예보 | License | 공공누리 제1유형, 상업 이용·변경 가능으로 정적 확인. 현재 `approved_for_dev`; 활용신청 시점 조건·C-11·Freshness는 미완료 | 발급 시점 상세·약관 Snapshot, 장기 Cache·제3자 권리 포함 필드 범위, 실제 Fixture의 Source·단위·License·Attribution 결합과 Attribution 표시 검증이 필요 | 문서 정리는 `offline_documentation`; 실제 C-11은 `owner_network_decision_required`, UI는 `gate_3_4_approval_required` |
| KMA 기상특보 | Freshness | 목록 C-01 한 시점 `pass`; 발표·정정·해제 지연과 14일 Canary `not_run` | 14개 연속 달력일의 계획 Poll 95% 이상 실행. 실제 발표가 없으면 `pass_with_live_event_latency_not_observed`만 허용하고 Event 발생 시 재측정 | `owner_canary_decision_required`; 실제 Event 부재를 무제한 pass로 바꾸지 않음 |
| KMA 기상특보 | Coverage | 목록 Item 2개만 관찰. 통보문·현황, 활성·해제·정정 연결과 대상지역 Coverage `not_run` | 계획 Poll 중 `data` 또는 `valid_empty`인 비율 95% 이상, 실제 발표가 있으면 필수 필드 완전성 100%, 공식 날씨 특보 범위와 비기상 재난 범위를 혼동한 변환 0건 | `owner_canary_decision_required`; `/getWthrWrnMsg`·`/getPwnStatus` C-01은 먼저 `owner_network_decision_required` |
| KMA 기상특보 | License | 공공누리 제1유형, `approved_for_dev`. 공식 원문 우선·정정 연결·실제 Attribution 결합은 미검증 | 활용신청 시점 조건 Snapshot, 활성·정정·해제 연결에 필요한 최소 Cache 범위, 원문·기관·발표·발효·해제·지역 보존 Fixture와 Source·Attribution 검증 | 문서 정리는 `offline_documentation`; 실제 C-11은 `owner_network_decision_required`, UI는 `gate_3_4_approval_required` |
| AirKorea 측정소 | Freshness | 목록 한 시점 C-01만 통과했고 독립된 측정소 Metadata Freshness 기준은 현재 Runbook에 고정되지 않음 | Canary Plan에서 측정소 목록 재확인 주기와 관측 연결 시점의 유효성 판단을 명시하기 전 Freshness pass로 표시하지 않음 | 기준 작성은 `offline_documentation`; 실제 측정은 `owner_canary_decision_required` |
| AirKorea 측정소 | Coverage | 서울·종로구 목록 Item 1개 관찰. 근접 측정소·거리·두 지역 Pair는 `not_run` | 수도권 1곳·비수도권 1곳의 사전 지정 공개 측정소가 `stationMaxDistanceKm` 이내로 100% 연결되고 거리 초과·다른 측정소 보간이 0건이어야 함. 자동 선택 정확도는 Gate 4 범위 | 수동 Pair·거리 기준 문서화는 `offline_documentation`; 실제 검증은 `owner_canary_decision_required`; 자동화는 `gate_3_4_approval_required` |
| AirKorea 측정소 | License | `LIC-AIR-001`, 공공누리 제3유형, 개발 `approved_for_dev`, 운영 `conditional_for_production` | Gate 2 최종 통과 전 변경금지 원본과 파생 설명·Cache·AI 입력, 위치 관련 절차 적용 범위를 서면 확인 또는 전문 검토로 해소 | `written_response_or_specialist_review_required`; 현재 추가 문의 권한 없음. 운영계정은 Production 차단 조건이며 현재 범위 밖 |
| AirKorea 대기오염 | Freshness | Run 9는 Schema 단계에서 중단돼 `freshnessStatus=not_evaluable`; 문서 요약상 `not_evaluated`. 14일 Canary `not_run` | 관측은 관측시각·PM10·PM2.5 원 수치·등급·단위·측정소와 Fallback 사유를 갖추고 Age 2시간 이내인 사용 가능 표본 90% 이상. 예보는 05·11·17·23시 고유 회차와 잠금된 허용 지연·유효일·지역·PM10·PM2.5·Source를 갖춘 회차 90% 이상 | 공식 Schema 분기와 새 Contract 범위가 먼저 필요. 실행은 `owner_canary_decision_required` |
| AirKorea 대기오염 | Coverage | 종로구 요청의 Item 1개·핵심 필드 3개 관찰뿐이며 측정소 Echo·다른 지역·예보 Cell은 미평가 | 두 고정 지역 관측의 측정소 Context·Fallback 사유를 보존하고, 예보는 사전등록한 `공식 유효일 × PM10·PM2.5` 예상 Cell을 회차별 100% 충족해야 함. 결측을 0으로 바꾼 사례 0건 | `request-only`, `response-required`, `ambiguous` 분기 후 범위 고정 필요. 실행은 `owner_canary_decision_required` |
| AirKorea 대기오염 | License | `LIC-AIR-001`, 공공누리 제3유형, 개발 `approved_for_dev`, 운영 `conditional_for_production`. Run 9는 C-11을 평가하지 않음 | Gate 2 최종 통과 전 원 응답 변경금지, 파생 설명·Cache·AI 입력과 위치 절차 적용 범위를 서면 확인 또는 전문 검토로 해소하고 Source·License·Attribution 결합 근거를 확보 | `written_response_or_specialist_review_required`; 실제 C-11은 `owner_network_decision_required`; 구현은 `gate_3_4_approval_required` |

## 6. 현재 완료 가능한 범위와 Gate 차단 요약

기관 답변이나 추가 호출 없이 지금 완료할 수 있는 것은 다음뿐이다.

1. 기존 Evidence의 상태·출처·Hash·실행 이력을 정리하는 `offline_documentation`
2. C-09·C-10 Client Fail-closed 분기의 `synthetic_classifier_fixture` 명세와 판정 검증 — 16/16, 미처리 예외 0, 두 새 Process 결과 일치, Network·Retry 0으로 완료. [실행 기록](./provider-validation-runbook.md)
3. 실제 실행 권한이 없는 `draft_not_executable` Canary Plan의 Target·분모·중단 규칙·예산 가정 정리
4. AirKorea 답변 3분기의 판정 기준과 범위 축소 Decision 조건 사전 정리

다음 조건이 남아 있으므로 이 문서 작성만으로 Gate 2, 전체 Contract, Technical provider 또는 Production을 통과 처리하지 않는다.

- AirKorea 공식 Schema 충돌의 서면 답변 분기 미확정
- 네 Provider의 미실행 C-01 Endpoint와 C-02~C-11 필수 Case
- 14일 Freshness·Coverage Canary 미실행
- 실제 승인 Traffic·Reset 시각 `not_verified`
- AirKorea 제3유형 파생·Cache·AI 입력과 위치 관련 적용 범위 미해소
- Gate 3·4 제품 설계·구현 승인 없음

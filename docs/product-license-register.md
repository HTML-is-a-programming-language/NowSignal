# NowSignal AI Product License Register

- 문서 상태: `working_draft_updated_after_run_10`
- 최초 작성일: 2026-08-05
- 최종 확인일: 2026-08-10 (Asia/Seoul)
- Phase 1 호출량 재확인: 2026-08-07 KMA Locale 표시 충돌 기록. 2026-08-09 Live 상세에서 KMA·AirKorea 한·영문 개발 호출량은 일치해 KMA 충돌 해소. AirKorea 영문 운영 승인 표기 내부 충돌은 License 판정과 분리해 Production 차단 조건으로 유지
- Phase 1 실행 근거: 개발 활용신청 4건 승인·활용기간 2026-08-10~2028-08-10. KMA 정상 예보 Endpoint 3개, 기상특보 목록과 AirKorea 측정소 목록 C-01 `pass`; Run 10 C-11 `not_evaluated`; AirKorea 대기오염 Run 9 원본 C-01 `fail`·공식 Schema `conflicting_official_schema`; Freshness·Canary `not_run`
- 적용 범위: 제품이 수집·저장·변환·표시하거나 사용자 추천의 근거로 사용하는 공개 데이터와 외부 표준
- 상세 기술 조사: [09-public-data-catalog.md](./09-public-data-catalog.md)
- Founder scope: [founder-problem-evidence.md](./founder-problem-evidence.md)
- 실제 호출 검증: [provider-validation-runbook.md](./provider-validation-runbook.md)
- C-11 ProviderEnvelope Evidence 명세: [provider-c11-envelope-evidence-spec.md](./provider-c11-envelope-evidence-spec.md)
- Provider·Case별 Evidence와 재개 권한: [gate-2-evidence-matrix.md](./gate-2-evidence-matrix.md)
- 권리·Freshness 차단 정책 초안: [provider-fail-closed-draft.md](./provider-fail-closed-draft.md)
- 주의: 이 문서는 공식 페이지를 바탕으로 한 engineering register이며 법률 자문이 아니다. 실제 활용신청 시 동의한 최신 약관, 데이터셋별 상세 조건, 제공기관의 서면 답변이 우선한다.

## 1. 판정과 운영 규칙

### 판정 상태

- `approved_for_dev`: 개발 활용신청과 공식 문서 기준으로 개발 검증 범위에 사용할 수 있다. 이 상태 자체만으로 개별 Endpoint Contract·Freshness·운영 승인을 통과했다는 뜻은 아니다.
- `conditional_for_production`: 표시된 조건을 충족하고 증거를 보관하기 전에는 production에서 활성화하지 않는다.
- `blocked_for_commercial`: 현재 확인한 조건상 상업 배포에 사용하지 않는다.
- `candidate_not_verified`: 용도·권리·기술 조건 중 하나 이상을 확인하지 못해 기본 경로로 선택하지 않는다.
- `not_product_data`: 통신·표현 표준이며 데이터 재사용 License 판정 대상은 아니지만 구현·서비스 약관은 별도 확인한다.

### 공공누리 유형 해석

[공공누리 공식 이용안내](https://www.kogl.or.kr/info/userGuide.do)에 따라 이 Register에서는 다음과 같이 해석한다.

| 유형 | 상업 이용 | 변경·2차 저작물 | 필수 조건 |
| --- | --- | --- | --- |
| 제1유형 | 가능 | 가능 | 구체적 출처표시 |
| 제3유형 | 가능 | 금지 | 구체적 출처표시, 원 저작물 변경 금지 |
| 제4유형 | 금지 | 금지 | 비상업적 이용에서도 구체적 출처표시, 원 저작물 변경 금지 |

데이터 상세 페이지가 “제3자 권리 포함” 또는 자산별 조건을 표시하면 Dataset 전체의 일반 문구보다 해당 개별 조건을 우선한다. “무료”와 “OpenAPI”는 상업 이용·변경·재배포 허용을 뜻하지 않는다.

### 공통 제품 통제

1. Provider 응답마다 `license.id`, `license.termsUrl`, 최상위 `attribution`을 보존한다.
2. 원문, 정규화 값, NowSignal 파생값, AI 설명을 저장·표시 계층에서 구분한다.
3. 출처표시는 Provider, 데이터셋, 원문 URL 또는 source ID, 관측·발표시각, 확인시각을 포함한다.
4. License가 충돌하면 더 엄격한 조건을 적용하고 `conflicting`으로 차단한다.
5. 활용신청 화면과 발급 시점의 약관·상세 페이지를 날짜와 hash가 있는 evidence snapshot으로 보관한다.
6. License 변경 감시가 실패하거나 마지막 검토일이 정책상 허용된 기간을 넘으면 해당 Provider를 `license_review_expired`로 닫는다.
7. 원 API 데이터의 이용허락이 LLM 입력·요약·파생 추천까지 허용하는지 불명확하면 원문을 모델에 보내지 않는다.

## 2. 등록부 요약

| ID | 데이터·표준 | 현재 판정 | 상업 이용 | 변경 | 저장·Cache | 핵심 미해결 사항 |
| --- | --- | --- | --- | --- | --- | --- |
| LIC-KMA-001 | 기상청 단기예보 | `approved_for_dev` | 가능 | 가능 | 제품 TTL 정책 내 후보 | 정상 Endpoint 3개 C-01 `pass`; Run 10 C-11 `not_evaluated`. Freshness·제3자 권리 포함 필드·장기 Cache 범위 미검증 |
| LIC-KMA-002 | 기상청 기상특보 | `approved_for_dev` | 가능 | 가능하지만 공식 원문 보존 | 활성·해제 추적에 필요한 범위 | `/getWthrWrnList` C-01만 `pass`; 실제 전달 지연·정정 연결·통보문·현황 미검증 |
| LIC-AIR-001 | AirKorea 대기오염정보·측정소정보 | 개발 `approved_for_dev`, 운영 `conditional_for_production` | 가능 | 원문 변경 금지 | immutable 원본과 파생층 분리 | 측정소 C-01 `pass`; 대기오염 Schema 충돌·운영 심의·위치 절차·파생 허용 범위 미해소 |
| LIC-MOIS-001 | 행정안전부 긴급재난문자 | `blocked_for_commercial` | 금지로 판정 | 금지 | 확인 전 금지 | 제3·제4유형 충돌, 현재 coverage·quota, AI 설명 허용 범위 |
| LIC-KTO-001 | TourAPI 국문 관광정보 | `conditional_for_production` | 본문 후보 가능 | 자산별 상이 | record·자산별 권리와 함께 | 이미지별 유형, 당일 운영·취소 신뢰성 |
| LIC-VWORLD-001 | VWorld 지오코더 | `candidate_not_verified` | 메타상 제한 없음 | `not_verified` | 별도 저장·DB 저장 금지 | reverse geocoding 용도와 파생·로그 범위 |
| LIC-JUSO-001 | 도로명주소 검색·좌표 API | `candidate_not_verified` | `not_verified` | `not_verified` | `not_verified` | 상세 License, 좌표 보존, GPS reverse 용도 아님 |
| LIC-SGIS-001 | SGIS reverse geocoding | `candidate_not_verified` | 상용 key 승인 필요 | 약관 재검토 필요 | 약관 재검토 필요 | 입력 CRS, 상용 허용 범위, 결과 보존 |
| STD-PUSH-001 | Push API, Web Push, VAPID | `not_product_data` | 해당 없음 | 해당 없음 | subscription 최소 보존 | Browser/Push Service별 약관·quota·SLA |

### 2.1 Phase 1 연산별 운영 판정

이 표는 법률 결론이 아니라 현재 근거에서 기능을 보수적으로 여닫는 Engineering 통제다. `allow_dev`는 승인된 개발 검증에 적용하고, `allow_dev_for_validation_only`는 Contract Evidence 수집 외 사용을 금지한다. `conditional`은 표시된 Evidence 전까지 Production 기능을 끄며, `deny_pending_evidence`는 서면 확인 또는 전문 검토 전 입력·저장·재배포를 하지 않는다는 뜻이다. `not_applicable`은 그 Provider 정보가 해당 연산의 직접 입력이 아님을 뜻한다. AirKorea Schema 답변은 응답 필드 계약만 다루며 제3유형 파생·AI·Cache 또는 위치 관련 절차를 자동으로 해소하지 않는다.

| Phase 1 Provider | 개발 Fetch | 원문 표시 | 정규화·단위변환 | 활동 Score | LLM 입력 | TTL Cache | 장기보관·재배포 | Owner·다음 검토 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| KMA 단기예보 | `allow_dev` | `conditional` — C-11·Attribution UI | `conditional` — 원값·단위·파생층 분리 | `conditional` — Gate 3·4 기준과 Freshness 통과 | `deny_pending_evidence` — 제3자 권리 포함 필드와 입력 범위 확인 | `conditional` — 원 발표·관측시각 유지, TTL 고정 | `deny_pending_evidence` | NowSignal Data/Privacy · Gate 3 전 또는 2026-09-10 중 빠른 날 |
| KMA 기상특보 | `allow_dev` | `conditional` — 공식 원문·기관·발표·발효·해제 우선 | `conditional` — 공식 필드 불변, 설명 분리 | `conditional` — 날씨 Hard block 범위와 `valid_empty` 의미 승인 | `deny_pending_evidence` — 공식 원문과 생성 설명 분리 기준 확인 | `conditional` — 활성·정정·해제 연결 최소 범위 | `deny_pending_evidence` | NowSignal Safety/Data · Gate 3 전 또는 2026-09-10 중 빠른 날 |
| AirKorea 측정소 | `allow_dev` | `conditional` — 제3유형 출처표시·C-11 | `conditional` — 원 측정소 정보와 거리 계산 분리 | `not_applicable` — 단독 Score 입력 아님 | `deny_pending_evidence` | `conditional` — 관측 연결용 최소 TTL | `deny_pending_evidence` | NowSignal Data/Privacy · Schema 답변 또는 2026-09-10 중 빠른 날 |
| AirKorea 대기오염 | `allow_dev_for_validation_only` | `conditional` — Schema·출처표시·단위 검증 | `deny_pending_evidence` — 제3유형 변경금지 범위 확인 | `deny_pending_evidence` | `deny_pending_evidence` | `deny_pending_evidence` | `deny_pending_evidence` | NowSignal Data/Privacy/Legal · Schema 답변 또는 2026-09-10 중 빠른 날 |

## 3. 상세 등록

### LIC-KMA-001 — 기상청 단기예보 조회서비스

- 제공기관: 기상청
- Product use: 날씨 실황·초단기예보·단기예보의 Phase 1 `WeatherProvider`
- 공식 상세: [공공데이터포털 API 15084084](https://www.data.go.kr/data/15084084/openapi.do)
- 공식 일반증서: [공공누리 제1유형](https://www.kogl.or.kr/info/licenseType1.do). Runtime C-11의 `termsUrl` 역할이며 활용신청 개별 조건·제3자 권리 범위는 별도 Evidence로 유지
- 보조 공식 문서: [기상청 격자 위·경도 API 안내](https://apihub.kma.go.kr/notice.do?seqNotice=39) — 좌표 변환 공식만 참고하며 API허브의 인증·Quota·약관은 공공데이터포털 Provider에 적용하지 않음
- 확인일: 2026-08-10
- 상세 페이지 수정일: 2026-07-09
- License: 무료, 공공누리 제1유형. 상세 페이지에는 제3자 권리 포함 저작권 표시와 공공저작물 출처표시가 함께 기재됨
- 상업 이용: `allowed_by_listed_license`
- 변경·파생: `allowed_by_listed_license`; 원시값과 단위변환·Score를 분리
- 저장·Cache: 명시적 장기 재배포 권리는 이 조사에서 확인하지 않음. 데이터 유효기간과 quota 보호에 필요한 TTL cache만 설계 후보로 두고 활용신청 약관을 재확인
- 출처표시 초안: `출처: 기상청 단기예보 조회서비스 · 발표 {baseDate/baseTime} KST · 확인 {fetchedAt} · 원문 {sourceReference}`
- 금지·통제: 공공데이터포털 key를 client에 노출하지 않음. API허브의 별도 quota·약관을 같은 Provider 계약으로 혼합하지 않음
- 현재 판정: `approved_for_dev`; 개발 활용신청 승인·활용기간 2026-08-10~2028-08-10, `/getUltraSrtNcst`·`/getUltraSrtFcst`·`/getVilageFcst` C-01 `pass`. Run 10 C-11은 `not_evaluated`, 오류 Contract·Freshness는 `not_run`
- Release evidence: 활용신청 시점 상세/약관 snapshot, contract fixture, attribution UI, 14일 freshness canary
- Owner: NowSignal Data/Privacy
- 재검토: Gate 3 진입 전, 상세 페이지 변경 감지 시 또는 2026-09-10 중 빠른 날

### LIC-KMA-002 — 기상청 기상특보 조회서비스

- 제공기관: 기상청
- Product use: 상용 MVP의 날씨 범위 `SafetyAlertProvider`
- 공식 상세: [공공데이터포털 API 15000415](https://www.data.go.kr/data/15000415/openapi.do)
- 확인일: 2026-08-10
- 상세 페이지 수정일: 2026-06-01
- License: 무료, 공공누리 제1유형
- 상업 이용: `allowed_by_listed_license`
- 변경·파생: License상 가능하더라도 안전 원칙상 공식 원문·기관·발표·발효·해제·지역은 변경하지 않음. AI 설명은 별도 영역
- 저장·Cache: 활성 상태·정정·해제 연결에 필요한 최소 범위만 보존하고 원 발표시각을 유지
- 출처표시 초안: `출처: 기상청 기상특보 조회서비스 · 발표기관 {office} · 발표 {issuedAt} KST · 확인 {fetchedAt} · 원문 {sourceReference}`
- 현재 판정: `approved_for_dev`; 개발 활용신청 승인·활용기간 2026-08-10~2028-08-10, `/getWthrWrnList` C-01 `pass`. 통보문·현황·오류 Contract·Freshness는 `not_run`; 비기상 재난을 포괄하는 것처럼 표시 금지
- Release evidence: 원문 보존 fixture, 정정·해제 연결 test, official-alert-first 화면 test, freshness canary
- Owner: NowSignal Safety/Data
- 재검토: Gate 3 진입 전, 상세 페이지 변경 감지 시 또는 2026-09-10 중 빠른 날

### LIC-AIR-001 — AirKorea 대기오염정보·측정소정보

- 제공기관: 한국환경공단
- Product use: 외출·산책·러닝 판단의 PM10·PM2.5, 지역·일 단위 대기질 예보와 측정소 연결을 위한 Phase 1 `AirQualityProvider`. O3는 원값 보존 검증 후보지만 별도 기준 전에는 제품 결론에 사용하지 않음
- 공식 상세: [대기오염정보 API 15073861](https://www.data.go.kr/data/15073861/openapi.do), [측정소정보 API 15073877](https://www.data.go.kr/data/15073877/openapi.do)
- 기술문서: [AirKorea OpenAPI 기술문서](https://apiweb.airkorea.or.kr/common/upload.pdf)
- 확인일: 2026-08-10
- 상세 페이지 수정일: 2026-06-30
- License: 무료, 공공누리 제3유형(출처표시+변경금지)
- 상업 이용: `allowed_by_listed_license`
- 변경·파생: 원 응답, 수치, 등급, 측정소, 공식 문장은 immutable. 단위변환·거리·활동 Score·NowSignal 설명은 별도 파생 레이어에 두되, 이것이 허용되는 “이용”인지 제공기관 확인 전 production에서 원문 요약을 모델에 보내지 않음
- 저장·Cache: 원 관측시각과 License를 유지하는 TTL cache 후보. 장기 archive·학습용 재사용은 승인 범위 확인 전 금지
- 출처표시 초안: [C-11 명세](./provider-c11-envelope-evidence-spec.md)에서 측정소정보와 대기오염을 분리한다. 측정소 Metadata에는 공식 근거 없는 관측시각을 만들지 않으며, 실제 렌더링은 아직 `not_run`
- 추가 조건: 기술문서의 위치 포함 서비스 관련 위치정보사업 절차 안내가 NowSignal에 적용되는지는 `not_verified`
- 현재 판정: 개발 `approved_for_dev`, 운영 `conditional_for_production`. 개발 활용신청 두 건은 2026-08-10~2028-08-10이며 측정소 `/getMsrstnList` C-01 `pass`; 대기오염 Run 9 원본 C-01 `fail`·공식 Schema `conflicting_official_schema`, 문의 `submitted_pending_response`
- Production 해제 조건: Schema 충돌의 공식 판정, 운영계정 승인, 위치 관련 적용 여부의 서면 확인, 변경금지 자료의 파생·AI 입력·Cache 범위 확인, attribution UI·contract test. Schema 답변만으로 나머지 권리 조건을 해소하지 않음
- Owner: NowSignal Data/Privacy/Legal
- 재검토: 제공기관 답변 수령 시, Gate 3 진입 전 또는 2026-09-10 중 빠른 날

### LIC-MOIS-001 — 행정안전부 긴급재난문자

- 제공기관: 행정안전부
- Product use: 비기상 재난·민방공 공식 메시지 후보 `SafetyAlertProvider`
- 공식 상세: [공공데이터포털 API 15134001](https://www.data.go.kr/data/15134001/openapi.do), [재난안전데이터공유플랫폼 상세](https://www.safetydata.go.kr/disaster-data/view?dataSn=228)
- 확인일: 2026-08-05
- License conflict: 공공데이터포털 개별 상세는 공공누리 제4유형, 공유플랫폼 일반 안내는 공공기관 제공 데이터 제3유형으로 표시. 더 엄격한 제4유형을 적용
- 상업 이용: `prohibited_by_current_strict_reading`
- 변경·파생: 금지. 이용이 허용되더라도 원문·기관·발송시각·대상지역·공식 지침을 그대로 보존하고 AI 설명과 완전히 분리
- 저장·Cache: 권리와 보관 범위를 서면 확인하기 전 금지
- 출처표시 초안: 사용 권리 확보 후에만 `출처: 행정안전부 긴급재난문자 · 발송기관 {sender} · 발송 {sentAt} KST · 원문 링크`
- 현재 판정: 상업·광고·유료 구독 제품에서 `blocked_for_commercial`; feature flag 기본 off
- 차단 해제 조건: 권리 담당부서의 상업 이용 가능 여부, 적용 License, 원문 노출·Cache·분리된 AI 설명 허용 범위, 현재 live coverage, 운영 quota에 대한 서면 답변
- 대체 원칙: 구 폐기 API로 fallback하지 않으며 KMA 특보를 “모든 재난문자” 대체로 표현하지 않음
- Owner: Safety/Legal (`unassigned`)
- 재검토: 제공기관 서면 답변 또는 상세 License 변경 시에만. 자동 활성화 금지

### LIC-KTO-001 — 한국관광공사 국문 관광정보 서비스(TourAPI)

- 제공기관: 한국관광공사
- Product use: Phase 3 장소·행사·숙박·반려동물 정보의 `LocalEventProvider`
- 공식 상세: [공공데이터포털 API 15101578](https://www.data.go.kr/data/15101578/openapi.do), [한국관광콘텐츠랩](https://api.visitkorea.or.kr/)
- 확인일: 2026-08-05
- 상세 페이지 수정일: 2026-02-26
- License: Dataset 메타는 이용허락범위 제한 없음. 사진은 개별 공공누리 제1·제3유형이며 피사체의 명예·인격권을 침해하거나 일반 정서에 반하는 사용, 기업 CI/BI 사용을 금지
- 상업 이용: 텍스트 record는 `allowed_by_listed_metadata`; 이미지·개별 자산은 item별 판정 전 `not_verified`
- 변경·파생: 본문과 이미지를 분리. 제3유형 이미지는 crop, filter, 합성, AI 편집 금지. License를 확인할 수 없는 자산은 표시하지 않음
- 저장·Cache: content ID, 수정시각, 원문 URL, record License와 자산별 License를 함께 보존. 동기화·재배포 범위는 활용신청 약관에서 재확인
- 출처표시 초안: `출처: 한국관광공사 TourAPI · contentId {id} · 수정 {modifiedtime} · 원문 링크`; 이미지는 별도 자산 출처와 공공누리 유형 표시
- 현재 판정: `conditional_for_production`, Phase 3 전까지 비활성
- Production 해제 조건: 응답 표본에서 item/image License 추적 가능성 감사, attribution rendering, 미확인 이미지 차단, 운영계정 승인, 당일 운영 여부 별도 상태 표시
- Owner: Product/Data/Legal (`unassigned`)
- 재검토: Phase 3 시작 전, 각 API 변경 공지, production 전, 월 1회

### LIC-VWORLD-001 — VWorld 지오코더 API

- 제공기관: 국토교통부 국가공간정보센터
- Product use: 수동 주소의 일회성 forward geocoding 후보
- 공식 상세: [공공데이터포털 API 15101106](https://www.data.go.kr/data/15101106/openapi.do), [VWorld 지오코더 가이드](https://www.vworld.kr/dev/v4dv_geocoderguide2_s001.do)
- 확인일: 2026-08-05
- License: 공공데이터포털 메타는 이용허락범위 제한 없음
- 상업 이용: `allowed_by_listed_metadata`
- 변경·파생: 상세 조건 `not_verified`
- 저장·Cache: 공식 상세가 실시간 사용만 허용하고 별도 저장장치·DB 저장을 금지하므로 raw 응답, 좌표, 파생 응답의 durable cache 금지. 로그·Trace·Analytics에도 원문을 남기지 않음
- 현재 판정: `candidate_not_verified`; MVP 기본 경로는 local KMA grid 변환과 행정구역 직접 선택
- 해제 조건: 정확한 용도, log/trace 범위, 파생 행정코드 보존 가능 여부를 제공기관 조건에서 확인하고 비저장 자동 test 통과
- Owner: Privacy/Data (`unassigned`)
- 재검토: 외부 geocoding 도입 ADR 전

### LIC-JUSO-001 — 도로명주소 검색·좌표 API

- 제공기관: 행정안전부/도로명주소 개발자센터
- Product use: 사용자가 직접 입력한 지역·주소 검색 보조 후보
- 공식 상세: [주소 검색 API 15057017](https://www.data.go.kr/data/15057017/openapi.do), [주소별 좌표 API 15056663](https://www.data.go.kr/data/15056663/openapi.do)
- 확인일: 2026-08-05
- License·상업·변경·저장: 이 조사 범위에서 product-specific 조건을 충분히 확인하지 못해 모두 `not_verified`
- Traffic evidence: 공식 Q&A에 검색 API 과도 호출 시 IP 차단과 좌표 API 5초당 10건 안내가 있으나 이를 SLA로 해석하지 않음
- 현재 판정: `candidate_not_verified`; GPS reverse geocoding 용도로 사용하지 않음
- 해제 조건: 최신 이용약관·License·보존 조건, 좌표계 변환, 실제 응답 schema 확인
- Owner: Privacy/Data (`unassigned`)
- 재검토: 지역 검색 UX에서 상세 주소가 실제로 필요하다고 검증된 뒤

### LIC-SGIS-001 — SGIS reverse geocoding

- 제공기관: 통계청 SGIS
- Product use: 좌표에서 행정구역을 찾는 조건부 후보
- 공식 상세: [SGIS OpenAPI 소개](https://sgis.mods.go.kr/developer/html/openApi/api/intro.html), [SGIS API 이용약관](https://sgis.mods.go.kr/developer/html/newOpenApi/app/rules.html)
- 확인일: 2026-08-05
- 접근: 공식 소개상 무료, 테스트키 15일, 상용키 승인, 키당 일 50,000회
- License·상업 범위·변경·저장: 상용키 승인과 별개인 product reuse 조건을 release 수준으로 확인하지 못해 `not_verified`
- 기술 제약: reverse endpoint 입력 CRS·좌표변환을 contract fixture로 확인해야 함
- 현재 판정: `candidate_not_verified`; MVP 기본 경로 아님
- Owner: Privacy/Data (`unassigned`)
- 재검토: local 변환과 수동 선택이 검증 결과 불충분할 때 ADR로 검토

### STD-PUSH-001 — Web Push 관련 표준

- Product use: Phase 4 `NotificationProvider`
- 공식 표준: [W3C Push API](https://www.w3.org/TR/push-api/), [WHATWG Notifications](https://notifications.spec.whatwg.org/), [RFC 8030](https://www.rfc-editor.org/rfc/rfc8030.html), [RFC 8291](https://www.rfc-editor.org/rfc/rfc8291.html), [RFC 8292](https://www.rfc-editor.org/rfc/rfc8292.html)
- 확인일: 2026-08-05
- License 판정: `not_product_data`; 표준 구현 가능성이 특정 Browser/Push Service의 무료 사용, quota, SLA, 운영약관을 보장하지 않음
- 저장: endpoint, `p256dh`, `auth`는 최소 보존하고 secret/식별 가능 데이터로 취급. 철회·삭제 제공
- 현재 판정: 표준 기반 구현 후보. 실제 Push Service 조건과 전달률은 `not_verified`
- Owner: Platform/Privacy (`unassigned`)
- 재검토: Gate 8 시작 전과 지원 Browser matrix 변경 시

## 4. Production License Gate

아래 항목을 모두 만족하지 않은 데이터는 production feature flag를 켜지 않는다.

- [ ] 실제 활용신청 또는 key 발급 시점의 상세 페이지와 약관 snapshot·hash·확인일 보관
- [ ] 상업 이용, 변경, 원문 표시, 파생값, LLM 입력, Cache, 재배포 각각에 대한 판정 완료
- [ ] Provider 응답에서 source·License·attribution이 유실되지 않는 contract test
- [ ] Evidence Drawer와 원문 화면의 attribution 접근성 확인
- [ ] License별 원문/파생/AI 설명 분리 test
- [ ] 저장 금지 데이터가 DB, Cache, log, Trace, Analytics에 남지 않는 test
- [ ] 운영계정 심의와 실제 quota 확보
- [ ] 검토 owner와 다음 검토일 지정
- [ ] 조건 충돌·만료 시 fail-closed feature flag test
- [ ] 제4유형 또는 별도 상업 금지 데이터가 상업 build에 포함되지 않는 release check

## 5. 미해결 질문

| 질문 | 상태 | 다음 증거 |
| --- | --- | --- |
| AirKorea 원문에서 단위변환·활동 Score·AI 설명을 만드는 범위가 제3유형과 양립하는가? | `blocking_not_verified` | 한국환경공단 서면 답변 또는 법률 검토 |
| AirKorea 위치 관련 사업 절차가 좌표를 즉시 축소하는 NowSignal에도 적용되는가? | `blocking_not_verified` | 담당기관 서면 답변 |
| 긴급재난문자 개별 데이터에 제3유형과 제4유형 중 무엇이 적용되는가? | `blocking_conflict` | 행정안전부 권리 담당부서 서면 답변 |
| 긴급재난문자를 원문 우선·AI 분리 방식으로 상업 서비스에 제공할 수 있는가? | `blocked` | 별도 이용허락 없이는 사용하지 않음 |
| TourAPI 이미지마다 License·출처가 응답에서 안정적으로 추적되는가? | `not_verified` | API key 기반 표본 감사 |
| VWorld 응답에서 파생한 축소 행정코드도 저장 금지 범위인가? | `not_verified` | 최신 약관 또는 제공기관 답변 |
| 각 Provider의 이용조건 변경을 자동 감지할 수 있는가? | `planned` | URL snapshot/hash monitor와 수동 월간 검토 |

## 6. 외부 오픈소스 Register 경계

현재 외부 오픈소스 package·UI·code를 도입하지 않았다. 따라서 이 파일에는 공개데이터와 웹 표준만 등록한다. 오픈소스 도입 전에는 별도 항목으로 repository, commit/tag, License file, attribution, 상업·변경 허용, transitive dependency, 보안·유지보수 상태, 제거 가능성을 검토하고 승인 전에는 코드나 UI를 복제하지 않는다.

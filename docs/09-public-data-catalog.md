# NowSignal AI 공공 데이터 카탈로그

- 문서 상태: `Gate 2 desk research complete`; 인증키 기반 contract·freshness 검증은 `not_verified`
- 조사 기준일: 2026-08-05 (Asia/Seoul)
- Phase 1 호출량 재확인: 2026-08-07. KMA 한국어·영문 Locale 표시 충돌로 낮은 값과 실제 승인 화면 중 더 낮은 값 적용
- 범위: 날씨, 대기질, 안전 알림, 지역 행사, 지오코딩, Web Push
- 근거 원칙: 제공기관 또는 표준 제정기관의 1차 출처만 확정 근거로 사용한다. 포털의 “실시간”, “최신” 표시는 가용성 SLA가 아니다.
- 라이선스 의무와 상용화 판정: [product-license-register.md](./product-license-register.md)
- 실제 호출 절차와 Evidence 형식: [provider-validation-runbook.md](./provider-validation-runbook.md)
- 장애·오래된 값·충돌 시 출력 제안: [provider-fail-closed-draft.md](./provider-fail-closed-draft.md)

## 1. 결론

| Adapter | 1차 Provider | Gate 2 판정 | 최초 적용 | 핵심 이유와 제한 |
| --- | --- | --- | --- | --- |
| `WeatherProvider` | 기상청 단기예보 조회서비스 | `adopt` | Phase 1 | 전국 5 km 격자, 초단기실황·초단기예보·단기예보, 공공누리 1유형. 개발 10,000회/일 |
| `SafetyAlertProvider` | 기상청 기상특보 | `adopt` | Phase 1 | 상용 이용 가능한 날씨 특보 원문. 비기상 재난까지 포괄하지는 않음 |
| `AirQualityProvider` | AirKorea 대기오염정보 + 측정소정보 | `adopt_for_dev`, `conditional_for_production` | Phase 1 | 개발 500회/일, 공공누리 3유형. 운영 심의와 위치정보사업 관련 안내의 적용 여부 확인 필요 |
| `SafetyAlertProvider` | 행정안전부 긴급재난문자 | `blocked_for_commercial` | 비상용 프로토타입 이후 재심의 | 공공데이터포털은 공공누리 4유형. 플랫폼의 일반 안내와도 불일치하며 현재 범위·할당량이 확인되지 않음 |
| `LocalEventProvider` | 한국관광공사 TourAPI | `conditional_adopt` | Phase 3 | 개발 1,000회/일, 운영 심의. 레코드 메타와 이미지별 라이선스를 분리해야 함 |
| `GeocodingProvider` | 로컬 좌표 변환 + 행정구역 직접 선택 | `adopt` | Phase 1 | 외부 전송과 정확한 GPS 보관을 최소화. 외부 지오코더는 아래 조건부 후보만 사용 |
| `NotificationProvider` | W3C Push API + IETF Web Push/VAPID | `adopt_as_standard`, `delivery_not_guaranteed` | Phase 4 | 별도 공개 데이터가 아니라 브라우저·Push Service 표준. 권한 거부, 만료, TTL, rate limit을 정상 상태로 처리 |

상용 MVP의 안전 알림 범위는 우선 **기상청 기상특보**로 명시한다. 행정안전부 긴급재난문자를 사용할 권리가 확인되기 전까지 “모든 재난 알림 제공”이라고 표현하지 않는다. 대체 데이터는 자동으로 숨겨 바꾸지 않고 Provider 이름과 fallback 사유를 노출한다.

## 2. 검증 수준과 공통 계약

### 2.1 판정 용어

- `verified`: 2026-08-05에 공식 상세 페이지·공식 약관·표준 본문에서 직접 확인했다.
- `not_verified`: 공식 출처에 없거나, 서로 다른 공식 페이지가 충돌하거나, 실제 키로 호출하지 않아 확인할 수 없다.
- `conditional`: 조건을 충족하고 증거를 보관한 뒤에만 채택한다.
- `blocked`: 현재 알려진 조건에서는 해당 배포 형태에 사용하지 않는다.
- `adopt`: 공식 문서상 구현 후보로 선택했다는 설계 판정이다. 인증키 기반 contract test, 실제 freshness, 운영 승인 또는 상용화 적합성이 검증됐다는 뜻이 아니다.
- 이 문서는 법률 자문이 아니다. 실제 API 상세 페이지의 최신 표시, 발급 시 동의한 약관, 제공기관의 서면 답변이 우선한다.

### 2.2 모든 Adapter가 반환할 최소 메타데이터

```ts
type ProviderStatus =
  | "fresh"
  | "delayed"
  | "stale"
  | "partial"
  | "conflicting"
  | "unavailable";

type SourceReference =
  | { sourceUrl: string; sourceId: string | null }
  | { sourceUrl: string | null; sourceId: string };

type ProviderEnvelope<T> = SourceReference & {
  provider: string;
  fetchedAt: string;
  observedAt: string | null;
  validFrom: string | null;
  validUntil: string | null;
  region: { code?: string; label: string; grid?: { x: number; y: number } };
  status: ProviderStatus;
  rawUnit: string | null;
  normalizedUnit: string | null;
  data: T;
  license: { id: string; termsUrl: string };
  attribution: string;
};
```

규칙은 다음과 같다.

1. `fetchedAt`을 관측·발표시각으로 사용하지 않는다. 제공 필드가 없으면 필드를 생략하지 않고 `observedAt: null`로 반환한다. `validFrom`, `validUntil`, 단위도 같은 원칙을 적용한다.
2. `sourceUrl`과 `sourceId` 중 적어도 하나는 반드시 값이 있어야 하며, `attribution`은 License 객체 안에 숨기지 않고 모든 응답의 최상위 필드로 반환한다.
3. `stale`, `conflicting`, `unavailable`이면 확정적인 행동 추천과 점수 계산을 중단한다. `partial`은 빠진 필드와 영향을 명시한다.
4. 원시 응답과 NowSignal 정규화·파생값은 필드와 저장소에서 분리한다. 특히 변경금지 자료는 원문을 수정하지 않는다.
5. 캐시는 마지막 성공 응답의 원래 `observedAt`·`fetchedAt`·Provider를 유지한다. 새 응답처럼 재타임스탬프하지 않는다.
6. fallback 시 `provider`, `reason`, `fallbackAt`을 사용자와 로그에 남긴다. KMA 특보를 행안부 재난문자의 동등한 대체물로 표시하지 않는다.

## 3. 공급사별 카탈로그

### 3.1 기상청 단기예보 조회서비스

| 항목 | 확인 결과 |
| --- | --- |
| 공식 근거 | [공공데이터포털 API 15084084](https://www.data.go.kr/data/15084084/openapi.do), [기상청 격자 위·경도 API 안내](https://apihub.kma.go.kr/notice.do?seqNotice=39) |
| 최종 수정 | `verified`: 2026-07-09 |
| 기능·범위 | `verified`: 전국, 읍·면·동 중심의 5 km 격자. 초단기실황, 향후 6시간 초단기예보, 시간별 단기예보 제공 |
| 접근 | `verified`: 공공데이터포털 키, REST, JSON/XML. 개발·운영 모두 자동 승인 |
| 공식 트래픽 | `verified`: 개발계정 10,000회/일. 운영은 활용사례 등록 후 증량 신청 가능. 증량 승인량과 리셋 시각은 `not_verified` |
| 비용·라이선스 | `verified`: 무료, 공공누리 제1유형(출처표시) |
| 대표 Endpoint | `https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0`; 실황 `/getUltraSrtNcst` |
| 채택 | `adopt` — `WeatherProvider`의 Phase 1 기본 |

신선도는 `baseDate/baseTime`, `fcstDate/fcstTime`을 기준으로 판정한다. 공식 페이지는 시간 범위를 “현재”로 표시하지만 발표 후 몇 분 내 제공되는지와 가용성 SLA는 명시하지 않는다. 따라서 첫 출시 전 14일 canary로 실제 도착 지연의 p50/p95/p99를 측정하고 기준을 확정한다.

2026-08-07 재확인에서 한국어 상세는 개발 10,000회/일, 영문 Locale 상세는 더 큰 값을 표시했다. 실행 예산은 10,000회/일과 실제 승인 화면 중 더 낮은 값을 사용하며, Locale 충돌이 해소되기 전 호출량은 `quota_conflicting_not_verified`다.

초기 운영 규칙은 Provider 보장이 아닌 제품 가정이다.

- 실황: `observedAt`이 90분 이내면 `fresh`, 90분 초과 3시간 이하면 `delayed`, 3시간 초과면 `stale`.
- 예보: 현재 시각을 포함하는 유효 구간이 있고 최신 성공 발행본이면 `fresh`; 새 발행본이 예상됐지만 이전 발행본만 있으면 `delayed`; 유효 구간이 지나면 `stale`.
- 필요한 기상 category 일부가 빠지면 `partial`; 같은 격자·유효시각에 상충하는 새 버전이 공존하면 최신 발표본을 선택하되 원 버전들을 기록하고 `conflicting` 여부를 검토한다.

공식 포털에 열거된 실패는 무효 키(`Unauthorized`), 활용신청 없음(`Forbidden`), 폐기·오타, 기관 backend 연결/응답 실패, 동시 요청 한도, 일일 quota, TLS 검증 실패다. exponential backoff와 jitter, 회로 차단, 요청 병합, 격자·발표본 캐시가 필요하다. quota 초과 때 출처가 다른 날씨 API로 조용히 전환하지 않는다.

#### 기상청 API허브와 혼동 금지

[기상청 API허브](https://apihub.kma.go.kr/apiInfo.do)는 별도 회원·인증키·약관을 쓰는 별도 유통 경로다. 일반회원 20,000회/일·5 GB, 기관회원 30,000회/일·50 GB라는 API허브 정책을 공공데이터포털 API 15084084의 quota로 사용하면 안 된다. [API허브 이용약관](https://apihub.kma.go.kr/policy.do)은 서비스 중단·변경과 품질 비보장을 명시한다. MVP는 공공데이터포털 경로만 사용하고 Provider ID에 유통 경로까지 포함한다.

### 3.2 기상청 기상특보 조회서비스

| 항목 | 확인 결과 |
| --- | --- |
| 공식 근거 | [공공데이터포털 API 15000415](https://www.data.go.kr/data/15000415/openapi.do) |
| 최종 수정 | `verified`: 2026-06-01 |
| 기능·범위 | `verified`: 전국 기상특보 목록·전문·현황. 육상 178개 시·군과 44개 해상구역, 12개 기상현상 설명 |
| 접근·트래픽 | `verified`: REST, 개발·운영 자동 승인, 개발 10,000회/일, 운영 증량 신청 가능 |
| 비용·라이선스 | `verified`: 무료, 공공누리 제1유형 |
| 대표 Endpoint | `https://apis.data.go.kr/1360000/WthrWrnInfoService`; 목록 `/getWthrWrnList` |
| 채택 | `adopt` — 상용 MVP `SafetyAlertProvider`의 날씨 경보 원천 |

특보 발효·해제·발표시각과 대상 구역을 그대로 보존한다. 활성 특보는 앱의 AI 설명보다 먼저, 원문 링크·발표기관·발표시각과 함께 표시한다. 공식 메타데이터의 “실시간”은 전달 지연 보장이 아니다. 5분 polling은 quota 검토 후 적용할 **제품 정책**이며, canary에서 실제 갱신 지연을 확인한다.

2026-08-07 재확인에서 이 API도 한국어 상세의 개발 10,000회/일과 영문 Locale의 더 큰 표시가 충돌했다. 실검증은 낮은 값과 승인 화면 중 더 낮은 호출량으로 계획한다.

일반적인 인증·quota·backend 실패 외에 구역 매핑 누락, 해제 전문 지연, 중복/정정 발표를 처리해야 한다. 기상특보가 없다는 응답을 “모든 재난이 안전함”으로 해석하지 않는다.

### 3.3 AirKorea 대기오염정보·측정소정보

| 항목 | 확인 결과 |
| --- | --- |
| 공식 근거 | [대기오염정보 API 15073861](https://www.data.go.kr/data/15073861/openapi.do), [측정소정보 API 15073877](https://www.data.go.kr/data/15073877/openapi.do), [AirKorea OpenAPI 기술문서](https://apiweb.airkorea.or.kr/common/upload.pdf), [공식 대기질 예보 페이지](https://www.airkorea.or.kr/web/dustForecast?pMENU_NO=113) |
| 최종 수정 | `verified`: 두 API 모두 2026-06-30 |
| 기능·범위 | 측정소별·시도별 실시간 측정정보, 통합대기환경지수, 대기질 예보, 측정소 목록·근접 측정소·TM 기준좌표 |
| 접근 | 개발 자동 승인, 운영 심의 승인. REST JSON/XML |
| 공식 트래픽 | 포털: 개발 500회/일, 운영은 활용사례 등록 후 증량 신청. 기술문서의 운영 신청 기준은 별도로 확인·증빙할 것. 실제 승인량은 `not_verified` |
| 비용·라이선스 | 무료, 공공누리 제3유형(출처표시+변경금지) |
| 대표 Endpoint | `https://apis.data.go.kr/B552584/ArpltnInforInqireSvc`, `https://apis.data.go.kr/B552584/MsrstnInfoInqireSvc` |
| 채택 | 개발 `adopt`; 상용 `conditional` |

예보는 공식 페이지 기준 매일 05·11·17·23시 발표한다. 오존 예보는 4월 1일~10월 31일이며 당일 등급의 세부 발표 조건도 시각별로 다르다. 관측값의 공식 가용성 SLA는 찾지 못했다. 초기 제품 가정은 관측 `observedAt` 2시간 이내 `fresh`, 2~4시간 `delayed`, 4시간 초과 `stale`이고, 14일 canary 후 조정한다. 예보는 공식 발표주기와 유효일을 사용한다.

AirKorea 기술문서는 위치를 포함한 공공데이터 활용 사업자에게 위치정보 서비스 허가 또는 위치기반서비스 신고 증명서를 요구할 수 있다고 안내한다. NowSignal의 좌표 축소 방식과 구체적 서비스가 이 절차에 해당하는지는 `not_verified`다. 운영계정 신청 전 한국환경공단과 담당 규제기관에 적용 여부를 확인하고 답변을 증거로 보관한다.

변경금지 대응은 다음과 같다.

- Provider 원 응답·등급·수치·측정소명·시각은 immutable 원본 레이어에 보존하고 원문 그대로 표시한다.
- 단위 변환, 등급 재계산, 거리 계산, 행동 점수는 `NowSignal 계산`이라는 별도 파생 레이어로 표시한다. 파생 허용 여부가 불명확한 원문 문장에는 변형·요약을 적용하지 않는다.
- 선택 측정소 ID, 위치와의 거리, 측정시각을 표시한다. 가까운 측정소로 fallback하면 사용자에게 알린다.

공식 AirKorea 안내에 따르면 장비 교정·수리·정기점검 및 측정소 이전·교체로 결측 또는 장기 중단이 생길 수 있다. 도시대기 측정소는 모든 동네를 대표하지 않는다. 결측 기호·null을 0으로 바꾸거나 인접소 값으로 묵시 보간하지 않고 `partial` 또는 `unavailable`로 반환한다. 측정소 교체, 관측·예보 불일치, 시간대별 일부 오염물질 누락을 별도 failure reason으로 기록한다.

### 3.4 행정안전부 긴급재난문자

| 항목 | 확인 결과 |
| --- | --- |
| 공식 근거 | [공공데이터포털 API 15134001](https://www.data.go.kr/data/15134001/openapi.do), [재난안전데이터공유플랫폼 상세](https://www.safetydata.go.kr/disaster-data/view?dataSn=228), [구 API 폐기·대체 공지](https://www.data.go.kr/bbs/ntc/selectNotice.do?originId=NOTICE_0000000003756) |
| 기능·범위 | 전국 지진·태풍·화재·민방공 등 사용기관이 발송한 긴급재난문자. 구 재난문자방송 API 2종의 대체 서비스 |
| 접근 | 공유플랫폼 회원가입과 활용신청 필요. REST 기반 JSON/XML 변환 제공; 공공데이터포털은 LINK/JSON로 표기 |
| 공식 트래픽 | 제공기관 정책에 따라 상이. 숫자·증량절차·SLA 모두 `not_verified` |
| 메타데이터 상태 | 포털은 업데이트 주기 “실시간”이나 시간범위는 2023~2025-01로 기재. 2026 현재 실제 live coverage·지연은 `not_verified` |
| 라이선스 | 포털 개별 상세: 공공누리 제4유형. 공유플랫폼 일반문구: 공공기관 제공 데이터 제3유형. `conflicting`; 더 엄격한 제4유형 적용 |
| 채택 | 상용·광고·구독 배포 `blocked`; 비상용 원문 프로토타입도 승인 및 법무 확인 후만 가능 |

구 API는 2024-12-01 이후 폐기 예정으로 공지되었고 기술지원 대상이 아니다. 어떤 경우에도 구 API로 fallback하지 않는다.

상용 차단이 해제되기 위한 최소 증거는 다음과 같다.

1. 행정안전부 재난정보통신과 또는 권리 담당부서의 상업 서비스 이용 가능 여부 서면 답변
2. 개별 데이터에 제3유형과 제4유형 중 무엇이 적용되는지, 원문 노출·캐시·AI 설명의 허용 범위 확인
3. 운영계정 승인량, 현재 레코드 범위, 갱신지연 canary 결과
4. 원문과 NowSignal 설명을 시각·데이터 구조상 분리하는 검수

허용되더라도 문자는 원문 그대로, 출처·발송기관·발송시각·대상지역과 함께 가장 먼저 노출한다. AI는 별도 영역에서 “NowSignal 설명”으로만 제공하며 공식 지시를 바꾸거나 덮어쓰지 않는다. 수정·취소·중복 메시지를 ID와 발송시각으로 연결하고, 파싱 실패 시 전국 또는 임의 지역으로 확대 해석하지 않는다.

### 3.5 한국관광공사 국문 관광정보 서비스(TourAPI)

| 항목 | 확인 결과 |
| --- | --- |
| 공식 근거 | [공공데이터포털 API 15101578](https://www.data.go.kr/data/15101578/openapi.do), [한국관광콘텐츠랩](https://api.visitkorea.or.kr/), [법정동·분류코드 변경 공지](https://api.visitkorea.or.kr/#/cmsNoticeDetail?no=207) |
| 최종 수정 | `verified`: 2026-02-26 |
| 기능·범위 | 약 26만 건, 지역·법정동·분류 코드, 지역/위치/키워드 검색, 행사, 숙박, 공통·소개·반복·이미지·동기화·반려동물 정보 등 15종 |
| 접근 | REST JSON/XML. 개발 자동 승인, 운영 심의 승인 |
| 공식 트래픽 | 개발 1,000회/일. 운영은 활용사례 등록 후 증량 신청; 실제 승인량 `not_verified` |
| 라이선스 | API 메타는 이용허락 제한 없음. 사진은 개별 공공누리 1·3유형이고 별도 금지조건 존재 |
| 대표 Endpoint | `https://apis.data.go.kr/B551011/KorService2` |
| 채택 | `conditional_adopt`, Phase 3 `LocalEventProvider` |

행사 시작·종료일은 당일 실제 운영, 우천 취소, 매진, 영업시간을 보장하지 않는다. “오늘 가능”을 만들려면 레코드 수정시각, 행사 기간, 상세 운영시간, 공식 상세 URL을 함께 평가한다. 당일 운영 확인 필드가 없으면 `unverified_today`를 표시하고 확정 추천에서 제외하거나 사용자 확인 행동을 제시한다. indoor/outdoor, 비용, 접근성, 반려동물 조건이 없으면 추정하지 않는다.

사진은 레코드와 별도 자산으로 취급한다. 응답 또는 콘텐츠 상세에서 각 이미지의 유형·출처를 저장하고, 제3유형 이미지는 crop·필터·합성·AI 편집을 하지 않는다. 유형을 확인할 수 없는 이미지는 표시하지 않는다. 피사체의 명예·인격권을 침해하거나 일반 정서에 반하는 사용과 기업 CI/BI 사용은 금지된다.

공식 포털의 인증 실패, 미신청, API 폐기, backend 실패, 동시 요청 한도, 일일 quota 오류를 처리한다. 동기화 목록과 pagination을 이용해 호출을 병합하되, “최신정보/실시간” 메타를 SLA로 취급하지 않는다. 행사 종료·취소와 상세 필드 지연의 실제 분포는 Phase 3 canary에서 측정한다.

### 3.6 지오코딩 후보

MVP 기본값은 외부 지오코더가 아니다. 브라우저의 일회성 WGS84 좌표를 기기 또는 신뢰 경계에서 KMA 격자와 AirKorea 검색 좌표로 변환하고, 서버에는 축소된 격자/행정구역만 보낸다. 권한 거부 사용자는 시·군·구/동 목록에서 직접 선택한다. 상세 도로명·건물주소 입력은 요구하지 않는다.

| 후보 | 공식 근거와 제한 | 판정 |
| --- | --- | --- |
| VWorld 지오코더 | [API 15101106](https://www.data.go.kr/data/15101106/openapi.do), [VWorld 지오코더 가이드](https://www.vworld.kr/dev/v4dv_geocoderguide2_s001.do). 주소→좌표, 최대 40,000회/일. 응답은 실시간 사용만 가능하며 별도 저장장치·DB 저장 금지 | 수동 주소의 ephemeral forward geocoding만 `conditional`; durable cache 금지. reverse geocoding은 이 근거로 확인되지 않아 `not_verified` |
| 도로명주소 검색 + 좌표 API | [주소 검색 API 15057017](https://www.data.go.kr/data/15057017/openapi.do), [주소별 좌표 API 15056663](https://www.data.go.kr/data/15056663/openapi.do), [공식 트래픽 답변](https://business.juso.go.kr/addrlink/qna/qnaDetail.do?bulletinRefSn=126550&currentPage=49&noticeMgtSn=126550&noticeType=QNA&noticeTypeTmp=QNA). 검색은 고정 한도가 없으나 과도 호출 시 IP 차단, 좌표 API는 5초당 10건. 좌표는 UTM-K GRS80 | 상세주소를 요구하지 않는 보조 검색으로만 `conditional`; 별도 좌표 변환 필요. GPS→행정구역 reverse 용도가 아님 |
| SGIS reverse geocoding | [SGIS OpenAPI 소개](https://sgis.mods.go.kr/developer/html/openApi/api/intro.html), [API 이용약관](https://sgis.mods.go.kr/developer/html/newOpenApi/app/rules.html), [공식 정의서 PDF](https://sgis.kostat.go.kr/developer/upload/doc/SGIS_OpenAPI_%EC%A0%95%EC%9D%98%EC%84%9C.pdf). 무료, 키당 일 50,000회, 테스트키 15일, 상용키 승인. reverse endpoint는 투영 좌표를 요구 | `candidate`, 상용권리와 정확한 입력 CRS·좌표변환을 확인하기 전 `not_verified`; MVP 기본 경로 아님 |

지오코딩 실패는 위치 권한 거부, timeout, 좌표계 오류, 경계점 다중 행정구역, rate limit, 키 만료, 저장 제한 위반으로 나눈다. 경계점은 단일 동을 확정하지 말고 후보를 보여 사용자가 선택하게 한다. 외부 응답 원문과 정확한 좌표를 분석 이벤트에 넣지 않는다.

### 3.7 Web Push / NotificationProvider

| 항목 | 확인 결과 |
| --- | --- |
| 공식 근거 | [W3C Push API](https://www.w3.org/TR/push-api/), [WHATWG Notifications](https://notifications.spec.whatwg.org/), [RFC 8030 Web Push](https://www.rfc-editor.org/rfc/rfc8030.html), [RFC 8291 Message Encryption](https://www.rfc-editor.org/rfc/rfc8291.html), [RFC 8292 VAPID](https://www.rfc-editor.org/rfc/rfc8292.html) |
| 성격 | 공개 데이터 공급사가 아니라 브라우저 User Agent가 고른 Push Service와 통신하는 웹 표준 |
| 접근·비용·quota | 브라우저별 Push Service 조건에 좌우됨. 공통 무료·상한·SLA는 `not_verified` |
| 표준 상태 | W3C Push API 문서는 2025-12-01 Working Draft. RFC 8030/8291/8292는 IETF Standards Track |
| 채택 | `adopt_as_standard`, Phase 4. 전달 성공을 보장하거나 추정하지 않음 |

알림은 사용자가 명시적으로 켤 때만 권한을 요청한다. 거부는 오류가 아니라 정상 제품 상태다. subscription endpoint, `p256dh`, `auth`는 비밀·개인 식별 가능 데이터처럼 취급하고 HTTPS로만 전달하며 로그·분석에 원문을 남기지 않는다. VAPID 서명키와 메시지 암호화 키를 분리한다.

RFC 8030에 따라 TTL 만료 전에도 Push Service가 저장기간을 줄일 수 있고, subscription은 만료될 수 있으며, rate limit은 429로 나타날 수 있다. 404 등 만료 응답은 구독을 비활성화하고 재동의를 유도하며, 429는 backoff한다. 앱 서버의 수락 응답을 사용자 전달·열람으로 기록하지 않는다. 알림마다 추천 유효기간 이하 TTL, 이벤트 ID 기반 dedupe, 구독 해제·삭제 경로가 필요하다.

## 4. Freshness·conflict 초기 정책

아래 값은 공식 SLA가 아니라 구현을 시작하기 위한 `provisional_product_policy`다. 출시 전 canary 데이터로 확정하고 정책 버전을 결과 메타에 기록한다.

| 데이터 | `fresh` | `delayed` | `stale`/차단 | 별도 의미 검증 |
| --- | --- | --- | --- | --- |
| KMA 초단기실황 | 관측 90분 이내 | 90분 초과~3시간 | 3시간 초과 | 필요한 category 누락 시 `partial` |
| KMA 예보 | 현재를 포함하는 최신 유효 구간 | 예상 새 발행본이 없고 이전 유효본만 존재 | 유효구간 만료 | 격자·발표본 ID 일치 |
| KMA 특보 | 최신 발표의 발효 상태 확인 | 새 발표 polling 지연 | 해제/유효 판단 불가 | 취소·대치 전문 연결 |
| AirKorea 관측 | 관측 2시간 이내 | 2~4시간 | 4시간 초과 | 결측·점검·측정소 거리 분리 |
| AirKorea 예보 | 05/11/17/23 최신 발표와 유효일 일치 | 다음 발표 예상 후 이전본 | 유효일 만료 | 오존 계절·시각 조건 적용 |
| 긴급재난문자 | 운영 권리·현재 coverage 확인 전 판정하지 않음 | 동일 | 상용 전체 차단 | 정정·취소·지역 파싱 검증 |
| TourAPI 행사 | 최근 동기화 + 유효 행사기간 | 동기화 지연 | 종료일 경과 | 당일 운영 여부는 별도 `not_verified` 가능 |

상충 데이터는 출처 우선순위로 사실을 지우지 않는다. 같은 현상·지역·시간에 값이 상충하면 양쪽 원본 ID를 보존하고 `conflicting`으로 닫는다. 공식 경보는 추천 점수보다 우선하며, LLM은 freshness나 conflict 상태를 바꿀 수 없다.

## 5. Adapter·실패 매핑

| Adapter | 정상화 핵심 | 명시적 실패 코드 예시 | 허용 fallback |
| --- | --- | --- | --- |
| `WeatherProvider` | KMA 격자, 관측/발표/유효시각, 원 단위 | `AUTH`, `NOT_SUBSCRIBED`, `QUOTA`, `RATE_LIMIT`, `BACKEND`, `MISSING_CATEGORY`, `STALE_ISSUE` | 마지막 성공본만 age 표시 후 제한적으로 노출. 다른 유통 경로 자동 전환 금지 |
| `AirQualityProvider` | 측정소 ID·거리, 관측시각, 오염물질별 raw 값/등급 | `MISSING_MEASUREMENT`, `STATION_MAINTENANCE`, `STATION_TOO_FAR`, `QUOTA`, `STALE_OBSERVATION` | 인접 측정소를 사용자에게 명시하고 선택; 보간 금지 |
| `SafetyAlertProvider` | 원문, 발송/발표기관, 지역, 발효/해제/정정 연결 | `LICENSE_BLOCKED`, `COVERAGE_UNKNOWN`, `REGION_PARSE`, `DUPLICATE`, `CORRECTION`, `SOURCE_UNAVAILABLE` | KMA는 날씨 특보만. 행안부 또는 전 재난 대체라고 표시 금지 |
| `LocalEventProvider` | content ID, 수정시각, 행사기간, 공식 URL, 이미지별 권리 | `TODAY_UNVERIFIED`, `CANCEL_UNKNOWN`, `MISSING_HOURS`, `IMAGE_LICENSE_UNKNOWN`, `QUOTA` | 텍스트 카드만 표시하거나 공식 페이지 확인 유도; 미확인 이미지 숨김 |
| `GeocodingProvider` | 입력 CRS, 결과 CRS, 행정코드, 경계 후보 | `PERMISSION_DENIED`, `BOUNDARY_AMBIGUOUS`, `CRS_INVALID`, `STORAGE_PROHIBITED`, `RATE_LIMIT` | 행정구역 직접 선택 |
| `NotificationProvider` | subscription 상태, TTL, event ID | `PERMISSION_DENIED`, `SUBSCRIPTION_EXPIRED`, `RATE_LIMIT`, `TTL_EXPIRED`, `ACCEPTED_NOT_DELIVERED` | 앱 내 최신 Brief; Push 전달을 성공으로 간주하지 않음 |

## 6. Gate 2 이후 필수 확인 작업

1. 공공데이터포털 개발키를 발급해 KMA·AirKorea 각 endpoint의 schema fixture와 오류 fixture를 보관한다.
2. 14일 canary로 발표/관측시각 대비 수집시각, 결측률, 지역 coverage, quota 사용량을 기록한다. 원 GPS는 기록하지 않는다.
3. AirKorea 운영계정 심의 전에 위치정보 관련 절차의 NowSignal 적용 여부를 서면 확인한다.
4. 행정안전부에 상업 이용, 적용 라이선스, 원문 캐시·AI 분리 설명 허용 여부, 운영 quota와 현재 live coverage를 질의한다. 해소 전 상용 feature flag는 off다.
5. TourAPI Phase 3 전에 레코드별 `modifiedtime`과 이미지별 공공누리 유형이 실제 응답에서 항상 추적 가능한지 표본 감사한다.
6. VWorld는 raw 응답·좌표가 DB와 로그에 남지 않는 자동 테스트를 통과한 경우에만 활성화한다. SGIS는 상용 허용과 입력 CRS를 확인한다.
7. 월 1회 또는 출시 직전 중 더 이른 시점에 상세 페이지·약관·폐기 공지를 재확인하고 스냅샷 hash와 확인일을 라이선스 등록부에 남긴다.

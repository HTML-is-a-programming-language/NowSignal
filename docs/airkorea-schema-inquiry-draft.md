# AirKorea 응답 Schema 확인 문의 초안

- 작성일: 2026-08-10
- 상태: `draft_not_sent`
- 대상: 공공데이터포털 API `15073861` 오류신고·문의 또는 한국환경공단 AirKorea OpenAPI 담당부서
- 비밀정보: 인증키·신청번호·계정정보·전체 요청 URL·원 응답·측정 수치 포함 금지
- 관련 실행 근거: [Phase 1 Provider 실검증 Runbook](./provider-validation-runbook.md) Run 9

## 제목

에어코리아 측정소별 실시간 측정정보의 `stationName`·`stationCode` 응답 명세 확인 요청

## 문의 본문

안녕하세요. 공공데이터포털의 `한국환경공단_에어코리아_대기오염정보` API(ID `15073861`) 중 `측정소별 실시간 측정정보 조회`를 개발 검증하고 있습니다.

2026-08-10 기준 공식 자료에서 다음 차이를 확인했습니다.

1. 공공데이터포털 Live 상세의 요청표는 `stationName`을 필수 요청 Parameter로 표시합니다.
2. 같은 Live 상세의 응답표에는 `stationName`과 `stationCode`가 없습니다.
3. 첨부 `한국환경공단 에어코리아 OpenAPI 기술문서_20260630.zip` 안 대기오염정보 기술문서 v1.4의 응답 필드표는 `stationName`과 `stationCode`를 필수로 표시합니다.
4. 같은 기술문서의 XML 응답 Sample에는 두 Field가 없습니다.
5. 개발계정으로 해당 Endpoint를 1회 확인했을 때 HTTP 200·정상 결과코드와 Item을 받았으며 `dataTime`, `pm10Value`, `pm25Value`는 있었지만 `stationName`은 없었습니다. 인증키·원 응답·측정 수치는 이 문의에 첨부하지 않습니다.

아래 사항을 서면으로 확인 부탁드립니다.

- 현재 JSON·XML 응답에서 `stationName`과 `stationCode`는 공식적으로 제공되는 필수 Field인가요, 아니면 요청 Context로만 사용되나요?
- `ver=1.3` 등 응답 버전에 따라 두 Field의 포함 여부가 달라지나요?
- 소비자는 응답의 측정소 식별을 요청한 `stationName` Context로 보존해도 되나요?
- Live 상세 응답표, 기술문서 응답 필드표와 Sample 중 어떤 자료를 현행 계약 기준으로 사용해야 하나요?
- 문서 오류라면 정정 예정 여부와 적용 예정일을 알려주실 수 있나요?

감사합니다.

## 제출 전 점검

- [ ] 사용자가 외부 문의 제출을 명시적으로 승인함
- [ ] 인증키 원문·일부·길이·Hash가 없음
- [ ] 신청번호·Email·전화번호·계정명 등 식별정보가 없음
- [ ] 전체 요청 URL·Query·Header·원 응답·Exception 원문·Screenshot이 없음
- [ ] API ID·Endpoint 이름·공개 Parameter·Sanitized 상태만 포함함
- [ ] 답변 수신 뒤 원문은 비공개 보관하고 Repository에는 판정·날짜·공식 근거만 기록함

승인 전에는 이 초안을 제출하거나 외부 담당자에게 전송하지 않는다.

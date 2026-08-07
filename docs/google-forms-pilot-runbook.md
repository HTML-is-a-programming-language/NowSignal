# Google Forms Pilot 운영 설계서

- 문서 상태: `paused_until_pilot_recruitment`
- 최초 작성일: 2026-08-05
- 최종 갱신일: 2026-08-07
- 적용 Protocol: `docs/03-user-interviews.md` v1.1
- 실제 Form 생성 상태: `form_a_partial_form_b_deferred`
- 실제 참여자 데이터: 0건

이 문서는 Google Forms를 이용해 NowSignal Pilot Interview의 동의·Screening과 구조화 Note를 운영하는 Build sheet다. 실제 Form URL, 편집 링크, 응답 링크, `researchCode`와 참여자 응답은 이 문서나 공개 저장소에 기록하지 않는다.

## 0. 실행 시점

Google Forms 완성은 NowSignal 제품 정의나 Desk research의 선행조건이 아니다. 실제 참여자를 모집하거나 응답을 수집하기 직전에만 이 Runbook을 재개한다.

- 현재 Form A는 부분 설정 상태로 미게시 유지한다.
- Form B, 계정 보호, 최종 동의 문안, Dry-run과 철회 Email 검증은 `deferred_manual`이다.
- 이 항목들이 검증되기 전에는 실제 참여자 데이터만 수집하지 않는다. 제품 코드는 별도의 Gate 1·2 승인 조건에 따라 계속 보류한다.
- 재개 Trigger와 사용자 작업은 `docs/manual-action-checklist.md`를 따른다.

## 1. 확정한 운영 원칙

- 개인정보 처리 주체: `NowSignal`
- 문의·철회 Email 및 목표 Form 소유 계정: `html.programming.language@gmail.com`
- Interview: 대면 1:1, 40~50분
- 기록: 음성·영상·화면 녹화·자동 전사 없이 연구자가 Google Form에 구조화 Note 직접 입력
- 저장: Google Forms와 해당 Google Drive 파일
- 접근: 소유자 1명, 공동편집자 0명
- 연결키: 이름과 무관한 무작위 `researchCode`
- 로컬 원자료: 파일 생성·Download·Print·Screenshot·Offline·Drive 동기화 금지
- 외부 처리: Google Sheets, Add-on, Apps Script, AppSheet, LLM, Analytics 연동 금지

Browser와 Google이 Cookie·Cache·IP·기기정보를 전혀 처리하지 않는다는 뜻은 아니다. 목표는 연구자가 기기에 지속되는 연구 원자료 파일을 의도적으로 만들지 않는 것이다.

## 2. 만들 Form

### Form A — NowSignal Pilot 동의·Screening

참여자가 작성한다. 공개 검색이나 Community에 Form URL을 게시하지 않고, 후보자가 전용 Gmail 또는 승인된 모집 채널로 연락한 뒤 개별 전달한다.

| 순서 | Section·질문 | 형식 | 필수 | 운영 규칙 |
| ---: | --- | --- | :---: | --- |
| 1 | 참여 안내 | 설명 | — | `docs/03-user-interviews.md` 7.6의 최종 승인 문안 사용 |
| 2 | 연구 수집·이용에 동의합니까? | 객관식 `동의/동의하지 않음` | 예 | 동의하지 않으면 종료 Section으로 이동 |
| 3 | 고지된 Google 국외 처리에 별도로 동의합니까? | 객관식 `동의/동의하지 않음` | 예 | 동의하지 않으면 종료 Section으로 이동 |
| 4 | `researchCode` | 단답형 | 예 | 정규식 `^NS-[A-HJ-NP-Z2-9]{12}$` |
| 5 | 만 18세 이상입니까? | 객관식 `예/아니요` | 예 | 아니요면 부적격 종료 |
| 6 | 최근 14일 안에 날씨·대기질을 보고 활동을 결정한 사례가 있습니까? | 객관식 `예/아니요` | 예 | 아니요면 부적격 종료 |
| 7 | 가장 최근 결정의 활동 | 객관식 + 기타 | 예 | 외출, 운동, 산책, 아이·반려동물 동행, 빨래, 세차, 촬영, 나들이 |
| 8 | 활동 지역 | Dropdown | 예 | 시·도까지만 수집 |
| 9 | 정보를 확인한 방식 | Checkbox | 예 | 날씨, 대기질, 공식 경보, 지도·검색, 주변 사람, 확인하지 않음, 기타 |
| 10 | 위치 권한을 보통 어떻게 설정합니까? | 객관식 | 예 | 허용, 매번 묻기, 거부, 모름 |
| 11 | 가능한 시간대 | Checkbox + 짧은 기타 | 예 | 정확한 주소나 직장명 금지 |
| 12 | 비녹화 화면 관찰에 동의합니까? | 객관식 `동의/동의하지 않음` | 아니요 | 선택 동의이며 거부에 불이익 없음 |
| 13 | 삭제·철회 안내 확인 | Checkbox 1개 | 예 | Code, Email, 보유기간, 제공자 삭제 한계 확인 |

이름, Email, 전화번호, Google 계정명, 상세 주소, 파일 업로드, 건강정보, 직장명은 질문으로 만들지 않는다. Pilot에서는 후속 연구 연락 동의를 받지 않는다.

모든 모집 안내에 처음부터, 신청·일정·철회 대화의 발신주소와 내용이 Gmail을 통해 Google에서 처리된다는 점을 넣는다. 이 사전 고지를 본 후보자만 전용 Gmail로 이동하게 하며, Email을 받은 뒤 처음 고지하는 방식은 사용하지 않는다.

#### Google 국외 처리 고지 검토안

다음 표는 Form A 문안에 옮길 `draft`다. Google이 Forms 응답의 고정 처리 국가를 공개하지 않으므로 실제 참여자에게 사용하기 전 제28조의8 고지 요건 충족 여부를 검토한다.

| 고지 항목 | 검토안 |
| --- | --- |
| 이전되는 정보 | Gmail 발신주소·일정 대화, `researchCode`, Consent 선택·시각, Screening 답변, 구조화 Interview Note |
| 이전받는 자·문의 | Google LLC 및 서비스 운영 계열사, `googlekrsupport@google.com` |
| 이전 국가 | Google이 운영하는 국외 데이터센터 국가 — 고정 국가를 특정할 수 있는지 `blocking_not_verified` |
| 이전 시점·방법 | Gmail 송수신 및 Form 입력·제출 시 정보통신망을 통한 전송 |
| 이용 목적 | Gmail·Google Forms·Drive 제공, 응답 보관, 보안과 서비스 운영 |
| 보유기간 | NowSignal의 자료별 예정 삭제일까지. 삭제 후 Google 정책상 일반적으로 약 2개월, 암호화된 Backup은 최대 6개월이며 보안·법적 요구 같은 제한된 목적에는 더 오래 보관될 수 있음 |
| 거부 방법·효과 | 별도 동의를 거부할 수 있으나 이 Google 기반 Pilot에는 참여할 수 없음. 그 밖의 불이익 없음 |

### Form B — NowSignal Pilot 구조화 Interview Note

연구자만 응답할 수 있게 제한하고 Interview 중 직접 입력한다. Form A 응답에서 필수 동의와 적격 여부를 먼저 확인한 뒤 시작한다.

| Section | 필드 |
| --- | --- |
| 연결·Consent 확인 | `researchCode`, Protocol `v1.1` 확인, Form A 동의·적격 확인, 화면 관찰 선택 |
| 최근 사례 | 시·도, 활동, 결정 마감시각의 범주, 확인한 출처 순서, 실제 결정 변화, 결과 |
| 현재 대안 | 사용 중인 앱·공식 정보·사람·개인 규칙의 범주와 선택 이유 |
| 마찰·반증 | 반복 확인, 정보 충돌, 놓친 변화, 전환하지 않을 이유, 현재 방식 만족 이유 |
| 활동 규칙 | 피하는 조건, 이동 가능한 시간 범위, 대안 활동, 동행 제약 |
| 위치·근거·알림 | 권한 선택 이유, 필요한 출처·Freshness, 유용·불필요 알림 |
| 연구자 Coding | 지지·반증·불명확 가설, 초기 Code, 해석, 후속 질문 |
| Lifecycle | 예정 삭제일, `storage=google_forms`, `linkedSheet=false`, Redaction 검토 |

직접 인용, 정확한 주소·시간표·이동 경로, 진단·복약, 아이 이름, 직장·계정 식별정보와 제3자 개인정보를 필드에 적지 않는다. 불가피하게 민감정보가 들어간 응답은 통째로 삭제하고 최소화한 새 응답을 제출한다.

## 3. `researchCode` 발급

1. 전용 계정의 Password manager 같은 난수 생성기로 `A-HJ-NP-Z`와 `2-9`에서 12자를 생성한다.
2. 형식은 `NS-XXXXXXXXXXXX`로 한다. 이름, 생일, 전화번호, Email 일부를 쓰지 않는다.
3. 후보자에게 Form A 링크와 Code를 전용 Gmail 대화로 전달하고, 보유기간이 끝날 때까지 Code를 본인이 보관하도록 안내한다.
4. 별도 이름-코드 표를 만들지 않는다. 일정 조율이 끝나면 보유기간에 맞춰 Gmail 대화를 영구 삭제한다.
5. Code는 공개 문서, Git commit, Issue, Chat, Calendar 제목에 넣지 않는다.

## 4. Form·Drive 설정

두 Form을 만든 직후, 실제 응답을 받기 전에 아래를 계정 화면에서 확인한다.

### 계정·파일 접근

- [ ] 소유 계정이 `html.programming.language@gmail.com`이다.
- [ ] 2단계 인증 또는 Passkey가 켜져 있고 복구 수단을 확인했다.
- [ ] 공동편집자가 0명이다.
- [ ] Drive의 Form 파일 일반 접근이 `제한됨`이다.
- [ ] Form A의 응답자 일반 접근은 `링크가 있는 모든 사용자`로 설정하되 검색·공개 게시하지 않는다.
- [ ] Form B의 응답자 접근은 소유 계정으로 제한한다.
- [ ] 실제 URL·ID·응답 화면을 공개 저장소의 점검 증거로 남기지 않는다.

### 응답 설정

- [ ] Email 주소 수집: `수집하지 않음`
- [ ] 응답 1회로 제한: `끔`
- [ ] 응답 수정 허용: `끔`
- [ ] 응답자에게 응답 사본 전송: `끔`
- [ ] 응답자에게 결과 요약 표시: `끔`
- [ ] 모든 응답자의 Draft 자동저장 사용 중지: `켬`
- [ ] 새 응답 Email 알림: `끔`
- [ ] Quiz로 만들기: `끔`
- [ ] 파일 업로드 질문: `없음`
- [ ] 미리 채워진 응답 Link: `사용하지 않음`
- [ ] 응답 수집: 모집·Interview 기간에만 `켬`
- [ ] Form A의 거부·부적격 분기: `확인됨`
- [ ] Form B의 구조화 필드와 민감정보 금지 안내: `확인됨`

### 외부 저장·로컬 저장

- [ ] 응답 대상 Google Sheet: `연결하지 않음`
- [ ] Add-on·Apps Script·AppSheet: `없음`
- [ ] Drive for desktop에서 두 Form이 있는 Drive를 동기화하지 않음
- [ ] Google Drive Offline을 사용하지 않음
- [ ] Gmail Offline을 사용하지 않음
- [ ] 전용 Gmail 계정을 Windows Mail·Outlook 같은 로컬 Mail client, IMAP·POP 또는 Mobile Mail app에 추가하지 않음
- [ ] CSV·PDF·Print·Screenshot·Takeout·Clipboard 복사를 하지 않음
- [ ] Interview 중 별도 메모장·Word·YAML 파일을 만들지 않음

## 5. 실제 수집 전 가상 응답 Dry-run

`NS-TESTTESTTEST`처럼 시험용임이 분명하면서 Form 검증식을 통과하는 가상 Code만 사용한다. 실제 사람의 Email, 이름, 발언이나 위치를 넣지 않는다.

1. 다른 Browser session에서 Form A를 열고 거부 분기, 부적격 분기, 적격 제출을 각각 시험한다. 실제 참여자의 동의 거부 응답은 Code가 없으므로 개별 응답의 거부 선택과 제출 시각으로 확인해 즉시 삭제한다.
2. Form A의 개별 응답 보기에서 세 응답이 예상 Section과 값으로 저장됐는지 확인한다.
3. Form B에 가상 구조화 Note 한 건을 제출한다.
4. Drive에서 Form A·B 외에 응답 Sheet가 생성되지 않았는지 확인한다.
5. Form A와 B의 개별 응답 보기에서 가상 Code를 확인하고 해당 응답을 각각 삭제한다.
6. Page를 새로 고친 뒤 가상 Code 응답이 활성 응답에 남지 않았는지 다시 확인한다.
7. 실수로 Sheet를 연결하는 시험은 하지 않는다. Sheet가 이미 존재한다면 Form 연결을 끊고 Sheet 파일과 Drive 휴지통을 삭제한 뒤 원인을 기록한다.
8. 다른 Email 계정에서 철회 전용 주소로 제목 `[TEST] NowSignal 철회`와 가상 Code를 보낸다.
9. 수신, Spam 미분류, 2영업일 접수 회신 Template, 보낸편지함을 확인한다.
10. Test 대화를 받은편지함·보낸편지함·휴지통에서 영구 삭제한다.

공개 저장소에는 다음처럼 식별정보 없는 결과만 기록한다.

| 점검일 | Form A 분기 | Form B 제출 | Sheet 없음 | 개별 삭제·재조회 | 철회 Email | 결과 |
| --- | --- | --- | --- | --- | --- | --- |
| — | `not_verified` | `not_verified` | `not_verified` | `not_verified` | `not_verified` | `not_started` |

## 6. Interview 당일 절차

1. Form A에서 해당 `researchCode` 응답이 정확히 1건인지와 필수 동의·국외 처리 별도 동의·적격 여부를 확인한다. 중복이면 Interview를 시작하지 않고 응답을 정리한 뒤 새 Code를 발급한다.
2. 참여자에게 처리 주체, 철회 Email, Code, 보유기간과 Google 삭제 한계를 다시 알린다.
3. 연구자 개인 Browser Profile 또는 비공개 창에서 Form B만 연다. 공용 기기는 쓰지 않는다.
4. 대면 Interview를 진행하며 구조화 필드에 범주 수준으로 바로 입력한다. 별도 로컬 초안을 만들지 않는다.
5. 화면 관찰은 Form A에서 선택 동의한 경우에만 다시 확인 후 진행한다.
6. 우발 노출은 확장 질문하지 않는다. Form에 들어갔다면 해당 응답을 삭제하고 최소화해 다시 제출한다.
7. 제출 전에 누락·과잉수집·사실과 해석의 구분을 검토한다. 제출 후에는 편집하지 않으며, 오류를 발견하면 기존 응답을 삭제하고 확인 가능한 내용만 다시 제출한다.
8. 제출 성공을 확인하고 Form tab 또는 비공개 창을 닫는다.
9. 참여자에게 Code와 철회 절차, 예정 삭제일을 다시 전달한다.

Network가 끊기면 로컬 메모로 계속 기록하지 않는다. Interview를 잠시 멈추거나 재일정을 잡고, 연결 복구 후 Form B에서 다시 시작한다.

참여자가 Code를 잃고 Gmail 대화도 보유기간에 따라 이미 삭제된 뒤에는 특정 응답을 다시 찾기 어려울 수 있다. 이 한계를 사전에 알리고 Code를 예정 삭제일까지 보관하도록 요청한다.

## 7. 철회·정기 삭제 절차

### 철회 요청

1. 접수 후 2영업일 안에 요청 수신과 처리 예정일을 회신한다.
2. Form A와 Form B의 개별 응답을 차례로 보며 `researchCode`가 일치하는 응답을 찾는다.
3. 일치 응답을 각각 개별 삭제한다.
4. 새로 고친 뒤 두 Form의 활성 응답에서 Code가 사라졌는지 확인한다.
5. 연결 Sheet가 없음을 확인한다. 있다면 Sheet 파일과 Drive 휴지통도 삭제한다.
6. 7일 안에 활성 응답 삭제와 Google 삭제 절차 개시 사실을 참여자에게 알린다.
7. Gmail의 요청·회신 대화를 보유기간 종료 시 받은편지함·보낸편지함·휴지통에서 영구 삭제한다.
8. 공개 운영 Log에는 날짜, 처리 건수, 통과 여부만 남기고 Code·Email을 남기지 않는다.

### 예정 삭제일

- 불적격·미참여 Screening: 선정 통지 또는 모집 종료일 + 7일 이내
- 적격 Consent·Screening·Note: `min(Interview일 + 90일, Gate 1 결정일 + 30일)`
- 일정·철회 Gmail 대화: Interview·보상 또는 철회 처리 완료일 + 14일 이내
- 목적을 더 일찍 달성하면 예정일을 기다리지 않고 삭제

Google은 계정에서 삭제를 시작한 뒤 전체 시스템 삭제에 일반적으로 약 2개월이 걸리고 암호화된 Backup에는 최대 6개월 남을 수 있으며, 보안·사기 방지·법적 요구 같은 제한된 목적에는 일부 정보를 더 오래 보관할 수 있다고 공개한다. 참여자에게는 활성 Form에서 삭제한 날과 이 제공자 측 한계를 함께 알린다.

## 8. 설정 완료 기록

아래 상태는 실제 계정 화면과 가상 응답으로 확인한 뒤에만 바꾼다.

| 항목 | 상태 | 확인일 |
| --- | --- | --- |
| Form A 생성·소유권·분기 | `partial_user_verified` | 2026-08-06 |
| Form B 생성·소유권·접근 제한 | `deferred_manual` | — |
| 계정 2단계 인증 또는 Passkey | `deferred_manual_not_verified` | — |
| 공동편집자 0명·Drive 제한됨 | `form_a_verified_form_b_deferred` | 2026-08-06 |
| Email·파일·결과 요약·수정·Draft 설정 | `partial_recheck_required` | 2026-08-06 |
| Sheet·Add-on·Script·Offline·동기화 없음 | `form_a_sheet_absent_others_not_verified` | 2026-08-06 |
| Google 국외 처리 고지 최종 검토 | `deferred_manual_blocking_before_participants` | — |
| 가상 응답 제출·개별 삭제·재조회 | `deferred_manual` | — |
| 철회 Email 송수신·Spam·영구 삭제 | `deferred_manual` | — |

### 2026-08-06 실행 기록

- Google Drive 연결 프로필을 읽기 전용으로 확인했으나 지정 전용 계정과 일치하지 않았다.
- 연결된 계정의 삭제되지 않은 Google Form은 0개였다.
- 잘못된 소유 계정에 Form을 만들지 않도록 실제 생성·설정은 중단했다.
- 연결된 개인 계정 주소와 프로필 식별자는 공개 저장소에 기록하지 않는다.
- 다음 실행은 `html.programming.language@gmail.com`으로 Google Drive 연결을 전환한 뒤 소유 계정 확인부터 재개한다.

### 2026-08-06 연결 복구 기록

- Google Drive 연결 프로필이 지정 전용 계정과 일치함을 확인했다.
- 지정 계정에서 삭제되지 않은 Google Form이 0개임을 확인했다.
- Google Forms 작성 화면을 열었으며, Form 생성·질문·분기·응답 설정은 아직 검증하지 않았다.
- 계정 2단계 인증, 복구 수단, Offline·동기화·Mail client 상태도 계정 화면 확인 전까지 `not_verified`로 유지한다.

### 2026-08-07 수동 작업 유예 기록

- Form A의 지정 계정 소유, 공동편집자 0명, 편집자 일반 접근 `제한됨`, 응답자 `링크가 있는 모든 사용자`, 미게시, 응답 0건과 Sheet 미연결을 화면에서 확인했다.
- 질문 구조와 동의 거부·국외 처리 거부·미성년·최근 사례 없음·적격 Screening의 다섯 분기 미리보기는 사용자가 정상 동작을 확인했다.
- 설정 화면에서 수정이 필요했던 `다른 응답 제출 Link`와 Draft 자동저장 중지 값은 수정 후 재확인 증거가 없어 `partial_recheck_required`로 둔다.
- Form B, 계정 보호, Offline·동기화·Mail client, 법적 고지, 제출·삭제와 철회 Email 시험은 실제 Pilot 모집을 승인할 때 재개한다.
- Form A는 게시하지 않고 실제 참여자 데이터 0건을 유지한다.

## 9. 공식 참고자료

- [Google Forms 응답 확인·관리](https://support.google.com/docs/answer/139706?hl=ko)
- [Google Forms 게시·공유와 Email 수집](https://support.google.com/docs/answer/2839588?hl=ko)
- [Google Forms 응답 저장 위치와 연결된 Sheet](https://support.google.com/docs/answer/2917686?hl=ko)
- [Google Forms 응답 Draft 자동저장](https://support.google.com/docs/answer/10952360?hl=ko)
- [Google Drive Offline](https://support.google.com/drive/answer/2375012?hl=ko)
- [Google Drive for desktop 동기화 방식](https://support.google.com/drive/answer/13401938?hl=ko)
- [Google 계정 2단계 인증](https://support.google.com/accounts/answer/10956730?hl=ko)
- [Google 개인정보처리방침](https://policies.google.com/privacy?hl=ko&gl=kr)
- [한국 거주자를 위한 Google 개인정보 추가 정보](https://policies.google.com/privacy/additional?hl=ko&gl=kr)
- [Google 데이터 보관·삭제 정책](https://policies.google.com/technologies/retention?hl=ko)
- [개인정보 보호법 제28조의8 — 개인정보의 국외 이전](https://www.law.go.kr/lsLinkCommonInfo.do?chrClsCd=010202&lsJoLnkSeq=1029334953)

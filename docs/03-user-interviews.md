# 사용자 인터뷰 및 모집 계획

- 문서 상태: `planned`
- 최초 작성일: 2026-08-05
- 최종 갱신일: 2026-08-07
- 연구 Protocol: `v1.1` (`method_decided`, `operation_not_verified`)
- 개인정보 공식 근거 확인일: 2026-08-05
- Pilot 실행 상태: `deferred_manual` — 실제 모집을 승인할 때 Google Forms·계정 보호·국외 처리 고지·삭제 모의 실행을 재개하며, 그 전에는 참여자 데이터 수집 금지
- 완료한 Interview: 0건
- 확보한 참여자: 0명
- 실제 직접 인용: 0건
- 연구 결과: `not_verified`

이 문서는 실행 계획과 빈 기록 양식이다. 참여자, 발언, 만족도, 행동 결과를 가상으로 채우지 않는다.

## 1. 연구 목적

이번 Problem Interview의 목적은 Solution 선호도를 묻는 것이 아니라 다음을 확인하는 것이다.

1. 사용자가 최근 실제로 날씨·대기질·주변 상황을 확인해 행동 시각 또는 준비를 바꾼 적이 있는가.
2. 어떤 출처와 개인 규칙을 어떤 순서로 조합하는가.
3. 현재 workflow에서 반복 확인, 상충 정보, 놓친 변화, 대안 탐색이 실제 비용을 만드는가.
4. 위치 권한, 공식 출처, Freshness, 알림에 어떤 기준과 우려가 있는가.
5. 문제 빈도와 심각도가 NowSignal AI를 만들 만큼 충분한가, 아니면 활동·상황을 좁혀야 하는가.

연결 가설은 [02-problem-hypotheses.md](./02-problem-hypotheses.md)의 H-P01~H-P08이다.

## 2. 연구 단계

| 단계 | 목적 | 계획 표본 | 산출물 | 상태 |
| --- | --- | --- | --- | --- |
| Pilot Problem Interview | 질문의 유도성, 시간, 이해도 점검 | 2명 | 수정된 Script와 제외 사유 | `deferred_manual` |
| Main Problem Interview | 최근 행동, 현재 대안, 문제 빈도·심각도 확인 | 8명 진행 후 검토, 필요 시 최대 12명 | 가명처리 Note, Coding matrix, 가설 상태 | `planned` |
| Comparative Prototype Test | Raw Data UI와 Action Brief UI의 결정 과정 비교 | 별도 계획 수립 | 과제 완료, 결정 시간, 이해·오류 관찰 | `not_started` |
| 3주 Beta | 실제 변화·추천·알림의 행동 영향 확인 | Data·Safety Gate 이후 결정 | 실제 사용·오류·알림·피드백 | `not_started` |

계획 표본 수는 연구 운영을 위한 목표값이며 시장 대표성이나 수요를 뜻하지 않는다. Pilot 자료는 Script가 변경될 수 있으므로 Main 표본과 분리한다.

## 3. 참여자 모집 기준

### 포함 기준

- 만 18세 이상이며 연구 목적·기록 방식에 동의할 수 있다.
- 최근 14일 안에 한국 내에서 외출, 운동, 산책, 아이 또는 반려동물과 외출, 빨래 건조, 세차, 야외 촬영, 가까운 나들이 중 하나의 시각·준비·실행 여부를 날씨 또는 대기질을 보고 결정한 구체적 사례가 있다.
- 한국어로 약 40~50분의 Interview에 참여할 수 있다.
- 특정 앱 사용 여부나 위치 권한 허용 여부는 포함 조건이 아니다.

최근 사례가 없는 응답자는 제품 Concept 의견 표본으로 대체하지 않고 Screening 제외로 기록한다. 제외자 수와 이유는 실제 모집 후 보고한다 (`not_verified`).

### 행동 맥락 구성 계획

Main 표본에서 다음 맥락을 겹쳐 포함한다 (`planned`).

- 정해진 시각의 외출·이동을 자주 하는 참여자
- 당일 안에서 운동·산책 시간을 조정할 수 있는 참여자
- 빨래·세차 등 생활 과제를 날씨에 맞춰 정하는 참여자
- 아이·반려동물·동행인과 함께 활동을 정하는 성인 참여자
- 근거리 나들이·야외 촬영 장소와 시간을 함께 찾는 참여자
- Browser location을 자주 허용하는 참여자와 거부하거나 수동 지역 선택을 선호하는 참여자
- 수도권과 비수도권 거주·활동 맥락

각 맥락은 인구집단을 대표하기 위한 Quota가 아니라 서로 다른 의사결정 제약을 발견하기 위한 sampling 기준이다. 연령·성별·직업으로 행동을 추정하지 않는다.

### 제외 또는 별도 분석 기준

- 연구팀·프로젝트 기여자는 일반 사용자 표본과 분리한다.
- 연구자와 직속 평가·고용·거래 관계에 있어 참여 거절이 어렵거나 불이익을 우려할 수 있는 사람은 모집하지 않는다.
- 기상·대기질·재난정보를 직업적으로 해석하는 전문가는 초기 일반 사용자 분석과 분리한다.
- 의료적 판단이나 질환별 안전 조언을 기대하는 참여 요청은 제품 범위 밖임을 안내한다.
- 미성년자는 초기 연구에 직접 모집하지 않는다. 아이와 외출하는 맥락은 성인 보호자만 인터뷰한다.
- Consent를 철회하면 연결 가능한 원자료·가명처리 자료·미공개 인용을 요청 범위에 따라 삭제한다. 연결키를 파기하고 재식별 위험 검토를 마친 집계 결과는 특정 참여자를 찾을 수 없으므로 그 이후의 삭제 한계를 Consent 시점에 알린다.

## 4. 모집 경로와 편향 관리

### 모집 경로

다음 경로는 후보이며 실제 사용 여부는 `not_verified`다.

- 연구자 개인 네트워크의 1차 지인 밖 소개
- 지역 생활·운동·반려동물·육아 Community의 운영자 승인 후 모집 글
- 온라인 사용자 연구 모집 Service
- 기존 참여자의 소개는 한 연결망에 치우치지 않도록 별도 표시

외부 Community 게시, 유료 모집, 보상 지급은 실행 전 프로젝트 책임자의 승인을 받는다. 현재 모집 채널, 예산, 보상 방식은 `not_verified`다.

### 예상 편향과 완화

| 편향 | 위험 | 완화 계획 |
| --- | --- | --- |
| 지인 편향 | 호의적 답변과 유사 생활패턴 | 지인 밖 소개와 공개 모집을 섞고 관계를 기록 |
| 날씨 관심자 편향 | 문제 빈도와 정보 탐색이 과대평가됨 | 활동 기준으로 모집하고 특정 앱·기상 관심을 요구하지 않음 |
| Concept 유도 | 제품 설명에 맞춘 문제 회상 | Interview 전반부에는 제품명·기능을 공개하지 않음 |
| 회상 편향 | 일반론과 실제 행동이 섞임 | 최근 14일의 특정 날짜·활동·결정·결과를 묻고 화면 흐름을 재현 |
| 지역 편향 | Provider Coverage 차이를 놓침 | 수도권·비수도권 맥락을 기록하고 결과를 분리 |
| 디지털 숙련도 편향 | PWA 사용성이 과대평가됨 | 앱 전환·권한 설정 숙련도를 Screening에서 기록하되 배제하지 않음 |

## 5. Screening 문항

모집 시 필요한 최소 정보만 수집한다. 정확한 주소, GPS, 건강정보, 직장명은 요청하지 않는다.

1. 만 18세 이상입니까? (`yes/no`)
2. 최근 14일 안에 날씨나 대기질을 확인하고 외출·활동·생활 과제의 시간이나 준비를 정한 적이 있습니까? (`yes/no`)
3. 가장 최근 결정은 어떤 활동이었습니까? (`single_select + optional_other`)
4. 그 결정을 한 지역은 어느 시·도 수준입니까? (`coarse_region`)
5. 보통 어떤 방식으로 정보를 확인합니까? (`multi_select`: 날씨, 대기질, 공식 경보, 지도·검색, 주변 사람, 확인하지 않음, 기타)
6. Browser 또는 앱의 위치 권한을 보통 어떻게 설정합니까? (`allow`, `ask_each_time`, `deny`, `unsure`)
7. Interview 가능한 방식과 시간대는 무엇입니까? (`availability`)
8. 본인 기기를 직접 조작해 보여주는 화면 관찰은 선택사항이고 거부해도 참여할 수 있습니다. 화면 관찰에 참여할 의향이 있습니까? (`yes/no/unsure`)

연락처는 일정 조율 목적으로만 전용 Gmail 대화에 두고 Google Forms 응답에는 이름·Email을 수집하지 않는다. 참여자에게 전달한 무작위 철회 Code로 동의 응답과 연구 Note를 연결하며, 실제 Form과 계정 보호 설정을 확인하기 전에는 수집하지 않는다 (`method_decided`, `operation_not_verified`).

## 6. 모집 안내문 초안

아래 문구는 `draft`이며 실제 게시 전 채널·보상·연락 방법을 확정해야 한다.

> 최근 날씨나 대기질을 확인해 외출, 운동, 산책, 빨래, 세차 또는 나들이 시간을 정한 경험에 대해 이야기해 주실 성인 참여자를 찾습니다. 약 40~50분 동안 최근 실제 결정 과정과 사용한 정보에 대해 질문합니다. 특정 제품을 판매하거나 사용을 권하는 자리가 아닙니다. 정확한 주소·GPS·건강정보는 요청하지 않습니다. 기록 방식과 보상은 참여 전에 별도로 안내하고 동의를 받습니다.

실제 모집 글에는 전용 Gmail로 신청·문의할 때 발신주소와 대화 내용이 Google 서비스에서 처리될 수 있다는 사전 고지를 함께 넣는다. Google 국외 처리 고지 검토가 끝나기 전에는 Email 주소나 Form Link를 게시하지 않는다.

보상 금액과 지급 수단은 아직 정해지지 않았다 (`not_verified`). 확정되지 않은 보상을 모집 글에 쓰지 않는다.

## 7. Consent와 연구 데이터 처리 Protocol v1.1

이 절은 실제 참여자 데이터를 받기 전 적용할 내부 운영 기준이다. 개인정보 보호법 준수를 확정하거나 법률 검토를 대신하지 않는다. 처리 도구·접근자·Google 정책 또는 국외 처리 조건이 달라지면 다시 검토한다.

Protocol은 동의 시 수집·이용 목적, 항목, 보유기간, 거부 권리와 불이익을 알리고, 목적에 필요한 최소 정보만 수집하며, 목적 달성 또는 보유기간 종료 후 삭제하는 원칙을 사용한다.

- [개인정보 보호법 제15조 — 동의 시 고지 항목](https://law.go.kr/LSW/lsLinkCommonInfo.do?chrClsCd=010202&lsJoLnkSeq=1020398563)
- [개인정보 보호법 제16조 — 최소 수집](https://www.law.go.kr/lsLinkCommonInfo.do?chrClsCd=010202&lsJoLnkSeq=1029335669)
- [개인정보 보호법 제21조 — 파기](https://www.law.go.kr/LSW/lsLinkCommonInfo.do?ancYnChk=&chrClsCd=010202&lsJoLnkSeq=1020398651)
- [개인정보 보호법 제28조의8 — 개인정보의 국외 이전](https://www.law.go.kr/lsLinkCommonInfo.do?chrClsCd=010202&lsJoLnkSeq=1029334953)
- [Google 개인정보처리방침](https://policies.google.com/privacy?hl=ko&gl=kr)
- [Google 데이터 보관·삭제 정책](https://policies.google.com/technologies/retention?hl=ko)

### 7.1 처리 역할과 접근

- 참여자에게 표시할 개인정보 처리 주체는 `NowSignal`이며, 문의·철회 전용 Email은 `html.programming.language@gmail.com`이다 (`user_confirmed`).
- 두 Form의 목표 소유 계정은 위 Gmail 계정이며 원자료 접근자는 소유자 1명으로 제한한다. 공동편집자, Observer, 외부 Coder를 두지 않고 Add-on·Apps Script·AppSheet를 연결하지 않는다.
- 실제 Form URL·ID, 편집 링크, 응답 링크와 철회 Code는 공개 저장소·Issue·Chat에 기록하지 않는다.
- Google Forms의 Email 수집을 끄더라도 Google은 서비스 제공 과정에서 IP, Browser, 기기정보, Cookie와 Cache를 처리할 수 있다. “완전 익명” 또는 “기기에 아무 흔적도 남지 않음”으로 안내하지 않는다.
- 공개 GitHub, OneDrive 작업공간, Analytics, Sentry, PostHog, LLM, 생성형 AI 또는 자동 전사 Service에 연락처·동의 응답·철회 Code·원문 Note를 입력하지 않는다.

### 7.2 Google Forms 저장 구조와 분리

Pilot의 공식 원자료 저장 도구는 다음 두 Google Form과 해당 Google Drive 파일이다 (`method_decided`, `operation_not_verified`).

1. **NowSignal Pilot 동의·Screening Form**
   - 참여자가 작성한다.
   - 수집·이용 동의와 Google을 통한 국외 처리 동의를 분리한다.
   - 무작위 `researchCode`, 성인 여부, 최근 14일 사례, 시·도, 활동, 정보 확인 방식, 위치 권한 성향, 비녹화 화면 관찰 선택 동의만 받는다.
   - 이름·Email·전화번호·Google 계정명·파일은 받지 않는다.
2. **NowSignal Pilot 구조화 Interview Note Form**
   - 연구자만 접근해 대면 Interview 중 직접 작성한다.
   - 같은 `researchCode`와 Section 9의 구조화 필드만 저장한다.
   - 녹음·영상·Screenshot·자동 전사·축어록 파일을 만들지 않는다.

일정 조율 연락처는 전용 Gmail 대화에만 존재하며 Form으로 복사하지 않는다. 참여자에게 무작위 `researchCode`를 전달하고, 별도의 이름-코드 연결표는 만들지 않는다. Pilot에서는 후속 연구 연락처를 별도로 수집하지 않는다.

응답은 Google Forms 안에서만 관리하고 Google Sheets 응답 대상은 연결하지 않는다. CSV·PDF·인쇄·Screenshot·Google Takeout·Clipboard 복사·오프라인 저장을 하지 않으며 Drive for desktop 동기화도 사용하지 않는다. 로컬 YAML·메모 파일을 만든 뒤 Form으로 복사하는 방식도 금지한다.

이 정책의 뜻은 **연구자가 로컬 연구 파일을 의도적으로 생성·다운로드·동기화하지 않는다**는 것이다. Web Browser와 Google이 Cache·Cookie 같은 임시 정보를 전혀 만들지 않는다는 보장은 아니다. C: BitLocker 상태는 더 이상 Pilot 원자료 저장소의 차단 조건이 아니다.

### 7.3 수집 항목과 보유·삭제

| 자료 유형 | 최소 항목·목적 | 활성 서비스에서 삭제하는 시점 |
| --- | --- | --- |
| 동의하지 않은 제출·불적격·미참여 Screening | 동의 선택과, 동의한 경우의 `researchCode`·성인·최근 사례 여부·시·도·활동; 적격 판단 | 즉시 또는 모집 종료 후 7일 이내 |
| 적격 Screening·Consent | Protocol version, 제시 시각, 동의 선택, 예정 삭제일; 참여 근거 | Interview 후 90일 또는 Gate 1 결정 후 30일 중 먼저 도래한 때 |
| 구조화 Interview Note | `researchCode`, 시·도, 활동, 출처 순서, 결정 과정, Theme와 가설 근거 | Interview 후 90일 또는 Gate 1 결정 후 30일 중 먼저 도래한 때 |
| 일정·철회 Gmail 대화 | 발신주소, 일정, `researchCode`, 요청 범위; 조율·권리 요청 처리 | Interview·보상 완료 또는 철회 처리 완료 후 14일 이내 |
| 공개 가능한 종합 결과 | 재식별 위험을 검토한 Theme, 분자·분모, 방법과 한계 | 프로젝트 기록 정책에 따름 |

- 목적을 먼저 달성하면 표의 최대 기간을 기다리지 않고 삭제한다.
- 철회 시 7일 안에 활성 Google Forms에서 해당 Code의 개별 응답을 삭제하고 Google의 삭제 절차를 시작한다. Gmail 대화는 받은편지함·보낸편지함·휴지통에서 영구 삭제한다.
- Form에 Sheet가 실수로 연결됐다면 연결 해제만으로 기존 Sheet 자료가 삭제되지 않는다. Sheet 파일을 별도로 삭제하고 Google Drive 휴지통도 비운다.
- Google은 삭제 절차가 일반적으로 약 2개월 걸리고 암호화된 Backup에는 최대 6개월 남을 수 있으며, 보안·사기 방지·법적 요구 같은 제한된 목적에는 일부 정보를 더 오래 보관할 수 있다고 공개한다. NowSignal은 “7일 내 Google 전체 Backup까지 물리 삭제”를 약속하지 않고, 7일 내 활성 응답 삭제와 제공자 삭제 절차 개시를 약속한다.
- 공개 문서에는 `researchCode`, 참여자별 행, 일정, 상세 시간·지역·활동 조합을 게시하지 않는다. 3명 미만의 희귀 맥락은 별도 소집단으로 표시하지 않는다.

### 7.4 Interview와 우발 수집

- Pilot 2건은 약 40~50분의 **대면 1:1 Interview**로 진행한다. 별도 회의·녹화·전사 Service를 쓰지 않고 연구자가 구조화 Interview Note Form에 온라인으로 직접 입력한다 (`method_decided`).
- Pilot은 음성·영상 녹음 없이 구조화 Note만 작성한다. 녹음 필요성이 확인되면 Main Interview 전에 Decision Log와 Consent를 새로 검토한다.
- 화면 관찰은 별도 선택 동의 후 참여자가 자기 기기를 직접 조작해 보여주는 방식만 허용한다. 기기를 넘겨받지 않으며 녹화, Screenshot, 화면 Capture와 자동 전사를 금지한다.
- 화면 관찰 전 개인 알림, 계정명, 대화, 주소와 제3자 정보를 가리도록 안내한다. 노출되면 즉시 관찰을 중단하고 해당 내용을 Note에 쓰지 않는다.
- 정확한 위치, 이동 경로, 건강정보, 아이 이름, 직장, 계정정보 또는 제3자 개인정보가 우발적으로 Form 응답에 포함되면 기존 응답 전체를 삭제한 뒤 최소화한 새 응답을 제출한다. 별도 수정 파일을 만들지 않는다.
- 연구자는 개인 전용 Browser Profile 또는 비공개 창에서 Form B를 사용하고 제출 확인 후 창을 닫는다. 공용 기기에서는 원자료를 열지 않는다.

### 7.5 철회·삭제 요청

- 철회 채널은 `html.programming.language@gmail.com`이다 (`configured_not_tested`). 모집 전에 다른 계정에서 송수신과 Spam 분류를 확인한다. 공개 Issue나 댓글로 철회를 받지 않는다.
- 필수 동의를 거부해 `researchCode`를 받기 전에 종료된 Form A 응답은 거부 선택과 제출 시각으로 확인해 즉시 삭제한다.
- 참여자에게 `researchCode`와 자료별 예정 삭제일을 제공하고 Code를 그때까지 본인이 보관하도록 안내한다. 철회 Email에는 Code와 삭제 범위만 쓰도록 안내하고 추가 신원정보를 요구하지 않는다. 발신주소는 Gmail에 남으며 위 보유기간에 따라 삭제된다고 알린다.
- 요청 접수는 2영업일 안에 확인하고, 7일 안에 연결 가능한 동의·Screening·Note 응답을 활성 Form에서 삭제하고 Google 삭제 절차를 시작한 뒤 완료 사실을 알린다.
- 연결 Code를 제거하고 공개 전 재식별 검토를 마친 집계는 특정 참여자를 찾을 수 없으므로 이후 개별 삭제가 제한된다. 그 전에는 Pilot 결과나 직접 인용을 공개하지 않는다.
- 참여자는 질문을 건너뛰거나 언제든 중단할 수 있다. 보상이 있다면 화면 관찰 거부, 부정적 의견 또는 중단을 이유로 감액하지 않는다.

### 7.6 참여 동의 안내문 v1.1

아래 문안은 `draft`다. Google의 실제 처리 국가를 특정할 수 있는지와 개인정보 보호법 제28조의8 고지 요건을 충족하는지 검토하고 참여자별 삭제일을 넣기 전에는 사용하지 않는다.

> **NowSignal AI 문제 인터뷰 참여 안내**
>
> 개인정보 처리 주체는 **NowSignal**이며 문의·열람·정정·철회·삭제 요청은 **html.programming.language@gmail.com**으로 받습니다. 이 연구는 최근 날씨·대기질·주변 상황을 확인해 활동 시각이나 준비를 정한 실제 과정을 이해하기 위한 약 40~50분의 대면 Interview입니다. 제품 구매나 긍정적 평가를 요구하지 않습니다.
>
> 일정 조율과 철회 처리를 위해 전용 Gmail에서 발신 Email 주소, 대화 내용, 연구 Code와 가능한 시간대를 처리하며 Interview·보상 또는 철회 처리 완료 후 14일 이내 삭제합니다. Form의 필수 수집 항목은 무작위 연구 Code, 성인·최근 사례 적격 여부, 시·도 수준 지역, 활동 유형, 사용한 정보 출처와 순서, 의사결정 과정, 위치 권한·근거·알림에 대한 의견, 구조화 연구 Note와 동의 기록입니다. 이름·Email·전화번호·정확한 주소·GPS·이동 경로·건강정보·계정 Password는 Form에서 요청하지 않습니다. 필수 수집·이용에 동의하지 않으면 이 Interview에는 참여할 수 없지만 그 밖의 불이익은 없습니다.
>
> 일정·철회 Gmail 대화, 동의·Screening 응답과 연구 Note는 Gmail, Google Forms와 Google Drive에서 처리·보관됩니다. Gmail 송수신과 Form 입력·제출 시 Google LLC 및 서비스 운영 계열사에 전송되며 Google은 전 세계의 Server에서 정보를 처리할 수 있다고 밝힙니다. 이전되는 항목, 국가, 시점·방법, 이전받는 자와 연락처, 목적, 보유기간의 최종 고지는 **[국외 처리 고지 검토 완료값]**으로 제시합니다. 국외 처리에 동의하지 않을 수 있으나 이 Google 기반 연구에는 참여할 수 없고 그 밖의 불이익은 없습니다.
>
> Pilot은 녹음·녹화·자동 전사 없이 진행합니다. 본인 기기를 직접 조작해 보여주는 비녹화 화면 관찰은 선택사항이며 거부해도 참여와 보상에 영향이 없습니다. 연구자는 로컬 연구 파일을 만들거나 내려받거나 동기화하지 않으며, 승인되지 않은 AI·LLM 처리에 응답을 넣지 않습니다.
>
> 적격 Screening·Consent와 연구 Note는 **[참여자별 예정 삭제일]**까지 보관합니다. 철회 시 7일 안에 활성 Google Forms 응답을 삭제하고 Google의 삭제 절차를 시작합니다. Google은 전체 시스템 삭제가 일반적으로 약 2개월 걸리고 암호화된 Backup에는 최대 6개월 남을 수 있으며, 보안·법적 요구 같은 제한된 목적에는 더 오래 보관할 수 있다고 밝힙니다. 연결 Code를 제거하고 재식별 위험 검토를 마친 집계 결과는 특정 참여자를 찾을 수 없어 이후 개별 삭제가 제한됩니다.
>
> 철회 요청에는 안내받은 연구 Code가 필요합니다. 일정 연락 Gmail 대화가 먼저 삭제된 뒤 Code까지 잃으면 특정 응답을 찾기 어려울 수 있으므로 예정 삭제일까지 Code를 보관해 주세요.

동의 확인 항목은 서로 묶지 않는다.

- [필수] 연구 참여와 위 항목의 수집·이용·구조화 Note 작성에 동의한다.
- [필수] 최종 고지된 Google 국외 처리에 별도로 동의한다.
- [선택] 본인 기기를 직접 조작하는 비녹화 화면 관찰에 동의한다.
- [확인] Protocol v1.1, 처리 주체·연락처, Google Forms 사용, 예정 삭제일과 삭제 한계를 안내받았다.

공개 Portfolio 인용은 Interview 후 별도 승인 문서로만 처리한다. Pilot에서는 요청하지 않는다.

### 7.7 실행 전 Privacy Preflight

아래 `blocking_not_verified` 항목을 모두 확인하기 전에는 실제 연락처·Screening 응답·Interview Note를 수집하지 않는다. 상세 절차는 [Google Forms Pilot 운영 설계서](./google-forms-pilot-runbook.md)를 따른다.

| 점검 항목 | 현재 상태 | 통과 증거 |
| --- | --- | --- |
| 개인정보 처리 주체 | `done` | `NowSignal` (`user_confirmed`) |
| 비공개 문의·철회 연락처 | `configured_not_tested` | `html.programming.language@gmail.com` 송수신·Spam 점검 |
| Interview 방식 | `done` | 대면 1:1, 무녹음·무녹화·무전사 |
| 두 Google Form의 실제 생성·소유권 | `blocking_not_verified` | 전용 계정 소유, 공동편집자 0명, Drive 일반 접근 `제한됨` |
| Google 계정 보호 | `blocking_not_verified` | 2단계 인증 또는 Passkey와 복구 수단 확인 |
| Form 수집·공유 설정 | `blocking_not_verified` | Email·파일 수집, 결과 요약, 응답 수정, Draft 자동저장 비활성 |
| 외부 저장·연동 차단 | `blocking_not_verified` | 연결 Sheet·Add-on·Script·Download·Drive·Gmail Offline·Drive 동기화·Mail client 연결 없음 |
| Google 국외 처리 고지·별도 동의 | `blocking_not_verified` | 실제 처리 국가 표현을 포함한 최종 문안 검토 |
| 자료별 예정 삭제일 | `blocking_not_verified` | 가상 참여자의 계산 결과 |
| 제출·철회·삭제 모의 실행 | `blocking_not_verified` | 가상 Code 응답의 검색·개별 삭제·재조회 결과 |
| 원자료 Git·LLM 유입 방지 | `done` | 공개 저장소 제외 원칙과 `.gitignore` 방어 규칙 |

실제 Form URL, 응답 화면이나 Code를 통과 증거로 공개 저장소에 넣지 않는다. 설정명·점검일·통과 여부와 식별정보 없는 건수만 기록한다.

### 7.8 수집 금지

- 정확한 위도·경도와 상세 주소
- 이동 경로
- 주민등록번호, 금융정보, 계정 Password
- 진단명·복약 등 건강정보
- 참여 목적에 불필요한 연락처·직장 식별정보
- 위치나 생활패턴을 광고 Profile로 재사용하는 정보

## 8. Problem Interview Script

### 8.1 도입 — 약 3분

1. 연구 목적, 기록 방식, 철회 권리를 안내하고 Consent를 확인한다.
2. “정답은 없으며 제품을 평가하는 자리가 아니라 최근 실제 행동을 이해하려는 자리”라고 설명한다.
3. Pilot은 녹음하지 않는다는 점을 안내하고, 참여자 기기 화면을 관찰할 때만 선택 동의를 다시 확인한다.

### 8.2 최근 실제 사례 — 약 15분

1. 최근 날씨나 대기질을 보고 시간·준비·실행 여부를 정한 가장 마지막 날을 떠올려 주세요.
2. 무엇을 하려고 했고, 언제까지 결정해야 했습니까?
3. 처음 확인한 것은 무엇이었습니까? 그다음에는 무엇을 했습니까?
4. 가능하다면 사용한 화면이나 기억나는 순서를 보여 주세요. 개인 알림·계정 정보는 가려 주세요.
5. 어떤 수치, 문구 또는 알림이 실제 결정을 바꿨습니까?
6. 최종적으로 시간, 장소, 준비물, 취소 여부를 어떻게 정했습니까?
7. 결정 후 상황은 어땠습니까? 다시 선택한다면 무엇을 다르게 하겠습니까?

“여러 앱을 쓰죠?”, “추천이 있으면 편하겠죠?”처럼 답을 유도하지 않는다.

### 8.3 현재 대안과 문제 강도 — 약 10분

1. 평소 이 결정을 위해 어떤 앱, 웹사이트, 공식 알림, 사람 또는 개인 규칙을 사용합니까?
2. 각 대안을 선택하는 이유와 믿지 않는 상황은 무엇입니까?
3. 정보가 서로 달랐던 마지막 사례가 있습니까? 무엇을 우선했습니까?
4. 다시 확인하는 데 어느 정도의 과정이 필요했습니까? 실제로 놓치거나 늦은 적이 있습니까?
5. 현재 방식에서 유지하고 싶은 점은 무엇입니까?
6. 새로운 도구로 바꾸지 않을 이유는 무엇입니까?

### 8.4 활동별 규칙과 대안 — 약 7분

1. 활동별로 절대 피하는 조건이 있습니까? 그 기준은 어디에서 배웠습니까?
2. 같은 날 다른 시간으로 옮길 수 있는 범위는 어느 정도입니까?
3. 조건이 나빠지면 어떤 대안을 찾습니까?
4. 아이·반려동물·동행인이 있으면 판단이 어떻게 달라집니까?
5. 확실하지 않을 때 활동을 미루거나 취소하는 기준은 무엇입니까?

개인 건강상태를 질문하지 않는다. 참여자가 먼저 건강정보를 말하면 상세 내용을 확장 질문하지 않고 연구 Note에서 최소화한다.

### 8.5 위치·근거·알림 — 약 8분

1. 위치 권한을 허용하거나 거부하는 기준은 무엇입니까?
2. 시·군·구 또는 관심지역 수동 선택은 언제 충분하거나 불충분합니까?
3. 추천을 따르기 전에 확인하고 싶은 출처·시각·근거는 무엇입니까?
4. 공식 재난·안전 메시지와 부가 설명은 어떤 순서로 보여야 합니까?
5. 어떤 변화는 알림으로 받을 가치가 있고, 어떤 알림은 불필요합니까?
6. 알림을 끄거나 위치정보를 삭제할 때 기대하는 동작은 무엇입니까?

### 8.6 종료 — 약 5분

1. 오늘 질문하지 않았지만 중요한 결정 방식이 있습니까?
2. 연구자가 이해한 내용을 짧게 요약하고 잘못 이해한 점을 수정해 달라고 요청한다.
3. 참여자에게 `researchCode`와 예정 삭제일을 다시 확인해 달라고 요청한다.
4. 철회·문의 방법과 예정된 다음 절차를 다시 안내한다. Pilot에서는 후속 연구 연락처를 별도로 받지 않는다.

## 9. Interview Note Schema

각 실제 Interview는 구조화 Interview Note Form에 다음 구조로 기록한다. 아래 YAML은 공개 필드 정의일 뿐 실제 YAML 파일을 만들지 않으며, 빈칸을 추정으로 채우지 않는다.

```yaml
researchCode: null
conductedAt: null
researcherRole: now_signal_owner
consent:
  protocolVersion: v1.1
  presentedAt: null
  method: google_forms
  participationAndNote: false
  audioRecording: false
  participantControlledScreenObservation: false
dataLifecycle:
  storage: google_forms
  linkedSheet: false
  scheduledDeletionAt: null
  redactionReviewedAt: null
participantContext:
  coarseRegion: null
  activityContexts: []
  locationPermissionPattern: null
eligibility:
  recentCaseWithin14Days: false
recentCase:
  activity: null
  decisionDeadline: null
  sourcesInOrder: []
  decisionChanged: null
  outcome: null
currentAlternatives: []
frictions: []
hardBlocks: []
notificationPreferences: []
privacyConcerns: []
hypothesisEvidence:
  supports: []
  contradicts: []
  unclear: []
researcherInterpretation: []
followUpQuestions: []
redactions: []
```

Pilot Note에는 직접 인용 후보를 수집하지 않고 발언을 범주 수준으로 요약한다. 요약을 따옴표 안에 넣지 않는다. Pilot의 `audioRecording`은 항상 `false`이고 `linkedSheet`도 항상 `false`여야 한다.

## 10. Interview 실행 기록

아직 실행한 Interview가 없다.

| 단계 | 완료 건수 | 적격 건수 | 철회·삭제 건수 | 결과 |
| --- | ---: | ---: | ---: | --- |
| Pilot | 0 | 0 | 0 | `not_started` |

공개 문서에는 실제 `researchCode`나 참여자별 행을 넣지 않는다. 실행 전에는 건수를 미리 채워 결과가 있는 것처럼 보이게 만들지 않는다.

## 11. 분석 방법

### Coding 단위

- 최근 사례 하나를 기본 분석 단위로 삼는다.
- 일반적 의견과 실제 행동을 분리한다.
- `source_switch`, `manual_rule`, `conflict`, `recheck`, `decision_change`, `missed_change`, `alternative_search`, `evidence_check`, `location_concern`, `notification_fatigue` code를 초기 Codebook으로 사용한다 (`draft`).
- 새 Theme은 구조화 Note의 관찰 근거와 함께 추가하고 기존 가설에 억지로 맞추지 않는다.

### 합성 절차

1. Interview 종료 직후 Form B를 제출하기 전에 누락·과잉수집·연구자 해석 구분을 검토한다. 기억으로 발언을 만들어내지 않는다.
2. 제출 후 응답은 편집하지 않는다. 명백한 오류나 과잉수집을 발견하면 기존 응답 전체를 삭제하고 확인 가능한 내용만 새 응답으로 제출한다.
3. 가설별 지지·반증·불명확 사례를 분리한다.
4. 실제 표본 수와 분모를 함께 계산한다.
5. Pilot과 Main, 실제 행동과 가상 질문, 수도권과 비수도권 맥락을 혼합하지 않는다.
6. 공동편집자는 두지 않는다. 독립 Coding이 필요해지는 경우 Main Interview 전에 접근·도구·Consent를 다시 설계한다.
7. 예상과 다른 사례, 현재 대안 만족 이유, 전환 비용을 반드시 포함한다.
8. 상태를 `validated` 또는 `rejected`로 바꿀 때 공개 문서에는 집계 건수, 판단 기준과 한계만 기록한다. `researchCode`, Form URL·응답 링크나 참여자별 Note를 기록하지 않는다.

## 12. 판단 및 측정 계획

Problem Interview는 제품 만족도나 시장 규모를 측정하지 않는다. 다음 지표만 탐색적으로 계산한다 (`planned`, 현재 값 `not_verified`).

- `recent_problem_recurrence_rate`
- `multi_source_reconciliation_rate`
- `decision_consequence_rate`
- `unresolved_conflict_rate`
- 현재 workflow를 유지하는 이유와 전환 비용의 Theme 빈도
- 위치 권한 허용·거부·수동 선택 맥락
- 유용한 변화 알림과 불필요한 알림의 사례 유형

초기 8건 후 다음을 검토한다.

- 새 Theme이 계속 발견되는지
- 특정 활동·지역·디지털 숙련도에 표본이 편중됐는지
- 핵심 가설에 지지 사례뿐 아니라 반증 사례가 충분히 수집됐는지
- 최대 12건까지 추가할 이유가 있는지

표본이 작으므로 백분율만으로 일반화하지 않고 분자·분모, 사례 맥락, 직접 근거를 함께 보고한다. “사용자가 좋아했다” 같은 요약은 실제 행동 근거 없이 쓰지 않는다.

## 13. Comparative Prototype Test로 넘길 조건

다음 조건을 충족할 때만 Solution 비교로 진행한다 (`planned_threshold`).

- 제품 Concept를 먼저 보여주지 않은 Main Interview에서 최근 반복 문제와 구체적 결정 비용이 관찰된다.
- 우선 검증할 활동 두세 개와 사용자가 실제로 보는 핵심 정보가 좁혀진다.
- 현재 대안의 유지 이유와 전환 비용이 문서화된다.
- Gate 2에서 해당 정보의 공식 Provider, License, Freshness, Coverage가 검토된다.
- `stale`, `conflicting`, `unavailable`에서 확정 추천을 막는 Prototype이 준비된다.
- Research data의 보관·삭제·접근 통제가 확정된다.

조건을 충족하지 않으면 Prototype으로 문제를 덮지 않고 범위 축소, 추가 Interview 또는 중단을 선택한다.

## 14. 실행 전 미해결 항목

- Pilot 참여자 모집 기준 Privacy·편향 검토: `done`
- 연구 데이터 최소수집·분리·보관·삭제·철회 Protocol v1.1: `done`
- Consent 핵심 문안 v1.1: `draft` — Google 국외 처리 고지 검토 전 사용 금지
- 참여자 표시 프로젝트명 `NowSignal`: `done`
- 대면 1:1·무녹음 Pilot 방식: `done`
- Google Forms 기반 Cloud-only 운영 방식: `done` (`method_decided`)
- 비공개 문의·철회 Email: `configured_not_tested`
- 모집 채널과 게시 승인: `not_verified`
- 참여 보상과 예산: `not_verified`
- Google 계정 2단계 인증·소유권·공동편집자 없음: `blocking_not_verified`
- 두 Form의 수집·공유·연동·로컬 비저장 설정: `blocking_not_verified`
- Google 국외 처리 고지와 별도 동의 문안의 충분성: `blocking_not_verified`
- 자료별 예정 삭제일과 가상 응답 삭제·철회 모의 실행: `blocking_not_verified`
- Pilot 일정: `not_verified`

특히 `blocking_not_verified` 항목을 확정하기 전에는 실제 참여자 데이터를 수집하지 않는다.

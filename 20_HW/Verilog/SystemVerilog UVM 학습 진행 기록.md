# SystemVerilog/UVM 학습 진행 기록

## 2026-10-10 - 화살표 충돌과 상하 간격 재보정

- 사용자 보정 요청: 글씨를 키운 상태에서 화살표와 겹친 글씨, 제목·부제 사이, 아래 오렌지 설명 상자의 제목·본문 간격을 함께 조정한다. 본문 위에 과도한 빈 공간을 두지 않고, 그 공간을 상자 크기와 읽기 간격에 배분한다.
- 편집: 제목·부제 간격을 늘리고 본문 영역을 위로 재배치했다. 아래 오렌지·청록 설명 상자는 한 줄 본문이면 최소 84pt, 두 줄이면 최소 105pt 높이를 확보하고 제목·본문과 본문 줄 사이를 별도로 배치한다.
- 개별 보정: 7쪽 화살표 전용 공간, 36쪽 선과 결과 표시, 47쪽 배지와 본문, 번호가 있는 지도·복습 카드의 높이, 54쪽 역할 카드, 70쪽 scoreboard 폭, 71쪽 도식과 코드 사이, 83쪽 표·하단 설명 상자, 92·94쪽 제목 주변 위치를 조정했다.
- 검수: 전체 100쪽을 재렌더링해 나누어 검토하고, 수정으로 생긴 10·13쪽 헤더 침범을 보정한 뒤 다시 확인했다. 마지막 71쪽 변경 외 나머지 99쪽의 동일성도 확인했다. 문자 누락·페이지 밖 이탈·상자 높이 검사에 문제가 없고, 도식 선 54개와 글씨의 교차 검사 후보는 0개였다. 목차 링크와 책갈피를 유지했다.
- 저장·진도: 기존 파일명으로 작업 폴더와 Obsidian PDF 및 9·10단계 연결 그림을 갱신한다. 다음 학습은 11단계이며, 이론 우선·실습 미실행 상태를 유지한다.

## 2026-10-10 - 태블릿용 가독성과 가운데 정렬 보정

- 사용자 요청: 갤럭시탭에서 읽기 쉽도록 기존 학습 PDF의 글씨를 키우고, 상자 안 설명의 가운데 정렬을 전반적으로 확인했다.
- 편집: 본문 글씨 중앙값을 10.5pt에서 13.5pt로 약 29% 확대했다. 코드는 주로 12pt, 밀도가 높은 표·상자는 최소 12pt를 사용하며 제목도 조정했다. 코드와 계층도는 들여쓰기를 유지한다.
- 정렬: Virtual sequencer의 spi_sqr/uart_sqr handle을 포함해 그림 상자의 제목·설명과 여백을 보정했다. 확대에 따른 줄바꿈, 표 열 너비와 좁은 상자 폭을 조정했다.
- 검수: 전체 100쪽을 이미지로 훑어보고 수정한 페이지를 다시 확인했다. 페이지별 문자 누락·영역 이탈·상자 높이 검사에서 문제가 없고, 10개 단계 책갈피와 목차 링크의 목적지를 확인했다.
- 저장: 작업 폴더와 Obsidian의 학습 PDF를 동기화하고, 9·10단계 MD에서 사용하는 그림도 새 글씨 크기로 갱신했다. 이후 PDF를 확장할 때도 태블릿 가독성 기준을 유지한다.
- 학습 상태 유지: 다음은 11단계 TLM·analysis와 회사 PDF 02.07이다. UVM simulator·FIFO 실습은 미실행이며 이론과 세미나 준비를 우선한다.

## 2026-10-10 - 9·10단계 이론 완료와 다음 채팅 준비

- 개인 학습: 9단계 Sequence·driver handshake, 10단계 config DB·virtual interface 기본 이론과 짧은 코드 해석을 대화로 진행했다. 수준 2(예제 해석) 중심이며 독립 작성·디버깅은 미확인이다.
- 다음 시작점: **11단계 TLM·analysis 기본 이론**, 회사 PDF **02.07 Component communication**. Method 기반 통신이 필요한 이유와 sequencer-driver port/export 연결부터 설명하고 확인 질문은 한 번에 하나씩 한다.
- 사용자 우선순위 변경: 이론을 먼저 진행하고 2026-10-15 세미나 PPT 준비를 우선한다. FIFO 실습은 이론 및 세미나 자료 준비 이후 재개한다. 다음 채팅에서 실습을 먼저 요구하지 않는다.
- 연결한 PDF: 9단계 02.05 Sequences(책 175~189쪽), 10단계 02.06 hierarchy/configuration/resource DB/config DB(책 190~197쪽). 사용자 회사 읽기 범위는 기존 02.05까지·RAL 일부 보고를 유지하며 전체 완독 여부를 추정하지 않는다.
- 9단계 확인: 선언/create/start, body 실행, start_item/finish_item과 get_next_item/item_done, get의 handshake 완료 시점, req/rsp, optional response, sequence/item randomization, randc 객체 유지, arbitration, nested/virtual sequence, sequential start와 fork/join, default_sequence의 phase 실행.
- 9단계 보충 후 확인: sequencer는 한 sequence 내부 순서를 임의 재배열하지 않음; item_done 누락 시 finish_item 대기; DUT 설정 적용과 요청 종료는 다를 수 있음; full 쓰기 거부는 driver 오류와 별개.
- 10단계 확인: 실제/virtual interface, set/get, context와 상대 경로, field_name/type, wildcard, build 우선순위, configuration object, 공유 객체 수정과 새 handle 등록, set 시점, resource DB와 차이, get 성공과 null 검사의 분리.
- 10단계 보충 후 확인: 새 객체 B를 DB에 등록해도 기존 agent handle은 A를 유지; fifo_drv는 인스턴스 이름이고 driver_h가 변수 이름; null은 신호 미도착이 아니라 참조 대상 부재.
- 생성·실행·연결의 남은 항목: 실제 port/export 연결, interface 구동 timing, runtime config trace, 전체 환경 작성·실행. 고급 lock/grab·layering·virtual sequencer 연결·runtime 설정 대기 구현은 보충 범위로 남긴다.
- 세미나 설명: sequence 요청 경로와 interface 참조 전달을 짧게 설명했다. 정확한 API 이름·null 의미를 보정했으며 도움 없이 전체 발표를 구성하는 능력은 별도 확인한다. 02.07~12, Callback·RAL의 이해도는 앞으로 확인한다.
- 핵심 3개: 완료 통지와 응답/정확성은 별개; config 조회에는 경로·이름·타입을 맞춤; 공유 객체 수정과 새 객체 handle 등록은 다름.
- 복습 3문제: item_done 누락 시 어디서 대기하는가? driver_h=create("fifo_drv", this)의 경로 이름은? 새 cfg를 DB에 등록하면 기존 agent cfg가 자동 교체되는가?
- 자료: 상세 MD 9·10단계 추가, 기존 가로 그림 중심 시각 PDF를 **1~10단계 100쪽**으로 확장, 단계 목차·링크·책갈피 갱신. 사용자 확인에 따라 이번 대상은 학습 PDF이며 세미나 PPTX 신규 제작으로 기록하지 않는다.
- 문서 검수: 표지와 추가·목차 27쪽을 이미지로 확인하고 표·설명 상자 간격을 보정했다. 기존 2~73쪽 본문 보존, 전체 100쪽 텍스트 경계 검사, 10개 단계 책갈피와 목차 링크를 확인했다. 이는 자료 검수이며 UVM 실행 검증이 아니다.
- 저장: 현재 작업 폴더와 Obsidian `Study/20_HW/Verilog`의 MD·진행 기록·학습 홈·통합 프롬프트·학습 PDF를 동기화한다.
- 실행 상태: **UVM simulator 미실행 / FIFO 실습 미진행.** 원본 RTL·directed TB는 변경하지 않았다.

## 2026-10-07 - PDF를 그림 중심 복습 형식으로 조정

- 사용자 선호 반영: 기존 PDF의 가로 페이지, 그림·카드와 짧은 설명 형식을 유지한다. 자세한 이론·코드·회사 PDF 보충은 단계별 MD에서 읽는다.
- 최종 학습 PDF: 74쪽. 기존 1~6단계 구성을 보존하며 필요한 문구를 보정하고, handle 전달과 복사의 연결 그림, 7단계 Factory/utility macro, 8단계 phase/objection, 단계별 빠른 목차를 추가했다.
- 검수: 74쪽 전체를 이미지로 확인했다. 텍스트 영역 이탈·핵심 용어 누락 검사에서 문제가 없으며 단계별 책갈피와 목차를 적용했다.
- Obsidian의 학습 PDF와 학습 홈·진행 기록·통합 프롬프트를 갱신했다. 1~8단계 상세 MD 본문은 이번 형식 조정에서 변경하지 않았다.
- 학습 진도는 유지: 8단계 기본 이론·코드 해석까지 진행, 다음은 9단계 sequence 생성과 실행. UVM simulator는 미실행이며 새 보충 항목의 이해도는 확인 전이다.

## 2026-10-07 - 1~8단계 정리와 PDF 보강

- 개인 학습: 1~6단계 기존 노트 보존·보강, 7단계 Factory/utility macro, 8단계 phase/objection 기본 이론·코드 해석 진행.
- 다음 시작점: 9단계 sequence create와 start의 구분. 도입 설명만 했고 확인 문제에는 아직 답하지 않았다.
- 실행 상태: UVM simulator 미실행. 코드 예측을 실행 검증으로 표시하지 않는다.
- 연결 PDF: 1단계 01.03.03/01.03.05, 2단계 01.02.04~06/01.03.01/01.03.06, 3단계 01.03.04/02.04, 4단계 01.03.02/01.03.05, 5·6단계 02.01~04/02.06, 7단계 02.04/02.06, 8단계 02.01/02.02/02.09.
- 읽은 것과 확인된 것: 회사 자료 02.05까지 읽고 RAL 일부를 봤다는 기존 사용자 보고 유지. PDF 전체 완독·새 보충 개념의 숙련도는 확인하지 않았다.
- 7단계 확인: create/new, override 시점·우선순위, field 자동화, scalar copy/compare, 문자열 반환, clone 바깥 객체 독립. REFERENCE/DEEP과 super의 의미는 혼동 후 설명·재확인했다.
- 8단계 확인: task 시간 대기, process 병렬 실행, raise/drop 필요성, wait/if, 완료 조건, drain time, 분산 objection의 가능성과 종료 통지 필요성.
- 생성·실행·연결의 미확인 부분: 실제 instance context override, 직접 do_* 작성, 실제 sequencer/driver 연결, 실행 로그로 종료 확인.
- PDF 추가: parameterized transaction/registry, comparer, method signature 보정, runtime/domain/jump, sequence 자동 objection, source trace. 보충으로 정리했으며 구현·문제 확인 전이다.
- 세미나 설명 준비: 7·8단계 핵심 이유와 동작은 코드 해석으로 확인했으나 도움 없이 전체 흐름을 발표하는 능력은 별도 확인이 필요하다.
- 실습 다음 작업: FIFO README와 기존 RTL/direct TB/C 모델을 읽고 검증 범위·최소 요청 경로부터 시작한다. 검증 환경 코드는 아직 새로 작성하지 않았다.
- 문서 검수 완료: 1~8단계 통합 PDF 94쪽과 단계별 그림 8개. 전체 페이지를 이미지로 확인했고, 텍스트 영역 이탈·주요 내용 누락 검사에서 문제가 없었다. Obsidian 노트와 작업 폴더 사본을 동기화했다.
- 편집 결과: 그림 가운데 정렬, 읽기/코드/표 글씨 크기 구분, 코드 박스의 긴 줄 줄바꿈·페이지 분할, 반복 표 머리글, PDF 목차·책갈피 적용. 새 PDF 보충의 이해도 확인과 UVM 예제 실행은 다음 학습에서 진행한다.

[[SystemVerilog UVM 학습 홈|목차]]

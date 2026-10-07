# SystemVerilog/UVM 학습 진행 기록

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

# SystemVerilog/UVM 학습 홈

갱신: 2026-10-10. 1~12단계 대화 학습 노트와 회사 PDF 보충을 함께 정리했다.

## 학습 노트

- [[SystemVerilog UVM 1단계 - 객체지향 복습]]
- [[SystemVerilog UVM 2단계 - 데이터 구조와 프로세스 통신]]
- [[SystemVerilog UVM 3단계 - Randomization과 Constraint]]
- [[SystemVerilog UVM 4단계 - Interface와 Simulation Timing]]
- [[SystemVerilog UVM 5단계 - UVM 개요와 전체 구조]]
- [[SystemVerilog UVM 6단계 - uvm_object와 uvm_component]]
- [[SystemVerilog UVM 7단계 - Factory와 utility macro]]
- [[SystemVerilog UVM 8단계 - Phase와 objection]]
- [[SystemVerilog UVM 9단계 - Sequence와 driver handshake]]
- [[SystemVerilog UVM 10단계 - config DB와 virtual interface]]
- [[SystemVerilog UVM 11단계 - TLM과 analysis]]
- [[SystemVerilog UVM 12단계 - Monitor와 Scoreboard]]

## 학습 PDF

[[SystemVerilog_UVM_시각학습노트.pdf|1~12단계 시각 학습 PDF · 125쪽]]

기존 가로 페이지의 그림·카드·짧은 설명 형식으로 복습한다. 자세한 이론과 회사 PDF 보충은 위의 단계별 MD에서 읽는다.

갤럭시탭 읽기를 고려해 본문은 주로 13.5pt, 코드는 12pt로 확대하고 그림 상자 안 설명을 가운데 정렬했다. 기존 1~10단계 100쪽을 검수한 형식을 유지하고, 새 표지·11/12단계·목차의 28쪽을 개별 이미지로 검수했다. 큰 글씨에 맞춰 상자 크기·상하 간격·화살표 위치도 재조정했다. 제목 아래의 과도한 여백을 줄이고, 아래 설명 상자의 제목과 본문 사이를 넓혔다.

배포용 최종 보정에서는 제목·본문 묶음과 코드 묶음의 상하좌우 가운데 정렬, 번호 배지, 짧은 문구의 줄바꿈을 확인했다. 기존 100쪽의 개별 검수 기준을 적용하고 2~98쪽 본문 보존을 확인했으며, 한두 글자만 다음 줄로 넘어갈 때는 해당 문구의 글씨 크기를 조금 낮춰 정돈했다.

## 현재 진도

**12단계까지 기본 이론과 코드·상황 해석을 진행했다. 다음 채팅은 13단계 Report·디버깅의 report 종류·verbosity부터 시작하고, 이어서 14단계 Coverage·Assertion을 진행한다.**

11단계는 PDF 99쪽, 12단계는 111쪽부터다. 13단계는 도입만 했으며 확인 질문은 미답변이다.

실제 UVM simulator와 FIFO 실습은 미실행이다. 이론과 2026-10-15 세미나 자료 준비를 우선하고 실습은 이후 재개한다. 남은 순서는 13~14단계 및 추가 Callback·RAL이며 필요하면 RAL/Callback의 순서를 조정한다.

[[SystemVerilog UVM 학습 진행 기록|세부 진도와 보충 범위]] · [[SystemVerilog UVM 학습 Prompt|통합 프롬프트]]

새로운 PDF 보충 항목은 이해도 확인 전이다. 각 노트의 기존 평가, 확인 문제와 미해결 지점을 함께 읽는다.

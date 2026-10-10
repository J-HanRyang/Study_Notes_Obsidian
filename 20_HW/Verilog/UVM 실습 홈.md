# SystemVerilog/UVM 학습·실습 홈

이 폴더는 이론 노트와 작은 SystemVerilog 실습을 보관합니다. `01_Sync_FIFO`의 실제 DUT, UVM 코드, 검증 기록은 별도 `Study` Obsidian Vault의 `20_HW/Design_Verification/01_Sync_FIFO/`에 둡니다.

## 단일 프롬프트

- [[systemverilog_uvm_study_prompt|SystemVerilog/UVM 통합 학습·실습 프롬프트]]

이론, 회사 PDF 복습, 세미나 준비와 실습은 위 프롬프트 하나로 진행합니다. 7단계부터 기존 학습 주제에 대응하는 PDF 설명·예제를 함께 다루며, 15단계 Callback과 16단계 RAL을 이어서 학습합니다.

다른 채팅에서는 `systemverilog_uvm_study_prompt.md`를 읽고 최신 학습 기록의 단계부터 이어가도록 요청합니다. Obsidian 사본은 `Study/20_HW/Verilog/SystemVerilog UVM 학습 Prompt.md`입니다. 세미나는 2026-10-15 발표 약 30분·질문 약 15분 기준이며 페이지 수는 고정하지 않습니다.

## 현재 진행

| 단계 | 학습과 실습 |
|---|---|
| 1~6 | 이론 노트 완료. 필요한 개념만 복습 |
| 7 | Factory, utility macro를 짧은 생성·override 예제로 확인 |
| 8 | Phase, objection을 종료 시점 예측 예제로 확인 |
| 9 | Sequence·driver handshake 기본 이론·코드 해석 완료. FIFO 구현·실행은 이후 재개 |
| 10 | config DB·virtual interface 기본 이론·코드 해석 완료 |
| 11~12 | TLM·analysis, Monitor·Scoreboard 기본 이론·코드/상황 해석 확인. 구현·실행은 이후 |
| 13~14 | Report·디버깅, Coverage·Assertion 기본 이론·상황 해석 확인. 독립 구현·실행 미확인 |
| 15~16 | 다음은 Callback → RAL → 회사 PDF 범위 점검·세미나 자료 작성 |

## 이 폴더의 기초 실습 시작

1. VS Code에서 `practice/00_smoke/hello.sv`를 엽니다.
2. `Ctrl+Shift+B`를 눌러 현재 SystemVerilog 파일을 빌드하고 실행합니다.
3. 명령 팔레트의 `Tasks: Run Task`에서 `학습 기록: 오늘 노트 만들기`를 실행합니다.
4. Obsidian에서 `notes/practice-log`의 오늘 노트를 열고 결과와 배운 점을 기록합니다.

## 학습 자료

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
- [[SystemVerilog UVM 13단계 - Report와 디버깅]]
- [[SystemVerilog UVM 14단계 - Coverage와 Assertion]]

## 실습 목록

- [[practice/00_smoke/hello.sv|00 - 환경 smoke test]]

## 실습 기록

- [[notes/practice-log/README|실습 기록 안내]]

> [!note] 시뮬레이터 범위
> 이 폴더의 자동 실행은 Icarus Verilog 기반의 SystemVerilog 기초 실습용입니다. `01_Sync_FIFO` UVM 실행은 `Study` Vault의 EDA Playground 내보내기 작업과 UVM 지원 시뮬레이터를 사용합니다.

## 최신 학습 기록

[[SystemVerilog UVM 학습 진행 기록]] · [[SystemVerilog UVM 학습 홈|통합 노트 목차]]

2026-10-10: 1~10단계 MD/PDF 정리. 다음 채팅은 11단계 TLM·analysis 이론(PDF 02.07). 이론·세미나 준비 우선, FIFO 실습은 이후 재개. UVM 예제는 미실행.

# Design Verification / UVM 실습 홈

SystemVerilog와 UVM을 이용한 설계 검증 학습 프로젝트입니다.
각 프로젝트 폴더 안에 DUT, Testbench, 검증 문서와 학습 기록을 함께 보관합니다.

## 시작 문서

- [[20_HW/Verilog/SystemVerilog UVM 학습 Prompt|SystemVerilog/UVM 통합 학습·실습 프롬프트]]: 이론과 실습을 함께 진행하는 단일 프롬프트
- [[20_HW/Design_Verification/01_Sync_FIFO/README|01_Sync_FIFO 프로젝트]]: 첫 실습의 상태와 파일
- [[20_HW/Design_Verification/00_Environment/EDA_Playground_연동|EDA Playground 연동]]: UVM 코드 내보내기와 실행

현재는 7단계 factory와 utility macro를 학습 중입니다. 7~8단계에는 작은 코드 예측·실행 실습을 합니다. 9단계에서는 기존 `RTL_Design/01_Sync_FIFO`의 RTL·directed TB·C 모델·결과를 출발 자료로 확인하고, 남은 검증 항목과 최소 UVM 요청 경로를 구성합니다. 기존 directed TB를 새로 만들지 않습니다. 10~12단계에서 virtual interface, monitor, scoreboard를 연결합니다.

## 프로젝트 구성 원칙

```text
프로젝트명/
├─ README.md     # 프로젝트 목표, 구조와 실행 방법
├─ rtl/          # 검증 대상 DUT
├─ tb/           # Testbench 또는 UVM 코드
└─ docs/         # 검증 계획, 디버깅 기록과 회고
```

## 프로젝트

- [[20_HW/Design_Verification/01_Sync_FIFO/README|01 - Sync FIFO 검증]]
- [[20_HW/Design_Verification/02_Async_FIFO/README|02 - Async FIFO 검증]]

## UVM 학습 자료

- [[20_HW/Verilog/SystemVerilog UVM 1단계 - 객체지향 복습|1단계 - 객체지향 복습]]
- [[20_HW/Verilog/SystemVerilog UVM 2단계 - 데이터 구조와 프로세스 통신|2단계 - 데이터 구조와 프로세스 통신]]
- [[20_HW/Verilog/SystemVerilog UVM 3단계 - Randomization과 Constraint|3단계 - Randomization과 Constraint]]
- [[20_HW/Verilog/SystemVerilog UVM 4단계 - Interface와 Simulation Timing|4단계 - Interface와 Simulation Timing]]
- [[20_HW/Verilog/SystemVerilog UVM 5단계 - UVM 개요와 전체 구조|5단계 - UVM 개요와 전체 구조]]
- [[20_HW/Verilog/SystemVerilog UVM 6단계 - uvm_object와 uvm_component|6단계 - uvm_object와 uvm_component]]

## UVM 실행

RTL 문법과 기본 SystemVerilog Testbench는 Icarus Verilog로 확인합니다.
UVM 실습은 EDA Playground의 UVM 지원 시뮬레이터를 사용합니다.

## 사용 방법

1. 프로젝트의 `README.md`에서 검증 목표와 진행 상황을 확인합니다.
2. `rtl/`에 검증 대상 DUT를 보관합니다.
3. `tb/`에 SystemVerilog 또는 UVM 검증 환경을 작성합니다.
4. `docs/`에 검증 계획, 결과와 디버깅 기록을 정리합니다.

> [!note] 시뮬레이터 범위
> Icarus Verilog는 SystemVerilog 기초 문법과 RTL/Testbench 연습에 적합합니다.
> 클래스 기반 UVM 전체 실행은 Questa, VCS 등 UVM 지원 시뮬레이터가 필요합니다.

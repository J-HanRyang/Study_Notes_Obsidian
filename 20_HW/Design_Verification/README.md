# Design Verification / UVM 실습 홈

SystemVerilog와 UVM을 이용한 설계 검증 학습 프로젝트입니다.
각 프로젝트 폴더 안에 DUT, Testbench, 검증 문서와 학습 기록을 함께 보관합니다.

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

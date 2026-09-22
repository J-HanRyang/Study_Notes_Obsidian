# Design Verification / UVM 실습 홈

이 폴더는 Obsidian의 `Study` Vault와 VS Code가 함께 사용하는 검증 실습 공간입니다.
각 프로젝트 폴더 안에 DUT, Testbench, 설명과 실습 기록을 함께 보관합니다.

## 프로젝트 구성 원칙

```text
프로젝트명/
├─ README.md     # 프로젝트 목표, 구조와 실행 방법
├─ rtl/          # 검증 대상 DUT
├─ tb/           # Testbench 또는 UVM 코드
└─ docs/         # 검증 계획, 디버깅 기록과 회고
```

공통 실행 도구인 `.vscode/`와 `scripts/`만 최상위에서 공유합니다.

## 프로젝트

- [[20_HW/Design_Verification/00_Environment/README|00 - 실행 환경 확인]]
- [[20_HW/Design_Verification/01_Sync_FIFO/README|01 - Sync FIFO 검증]]
- [[20_HW/Design_Verification/02_Async_FIFO/README|02 - Async FIFO 검증]]
- [[20_HW/Design_Verification/_Project_Template/README|새 프로젝트 템플릿]]

## UVM 실행

Icarus Verilog는 RTL 및 기본 SystemVerilog 확인에 사용합니다. UVM은 VS Code에서 작성한 뒤 EDA Playground용 파일을 자동 생성해 실행합니다.

- [[20_HW/Design_Verification/00_Environment/EDA_Playground_연동|EDA Playground 연동 방법]]

## 사용 방법

1. VS Code에서 `Design_Verification` 폴더를 엽니다.
2. 연습할 프로젝트 내부의 `.sv` 파일을 엽니다.
3. 실행 버튼 또는 `Ctrl+Shift+B`로 현재 파일을 빌드하고 실행합니다.
4. 프로젝트 내부의 `README.md`와 `docs/`에 설명과 결과를 기록합니다.

> [!note] 시뮬레이터 범위
> 현재 자동 실행은 Icarus Verilog를 사용하므로 SystemVerilog 기초 문법과 RTL/Testbench 연습에 적합합니다.
> 클래스 기반 UVM 전체 실행은 Questa, VCS 등 UVM 지원 시뮬레이터가 필요합니다.

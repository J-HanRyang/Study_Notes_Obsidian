# 01. Sync FIFO 검증

동일한 클럭 도메인에서 동작하는 Sync FIFO를 검증하는 프로젝트입니다.
기존 설계에서 DUT만 복사하고, 검증 문서와 UVM 환경은 이 프로젝트에서 새로 작성합니다.

## 프로젝트 구성

```text
01_Sync_FIFO/
├─ README.md
├─ rtl/
│  └─ sync_fifo.sv
├─ tb/            # 새 SystemVerilog/UVM 검증 코드
└─ docs/          # 새 검증 계획과 학습 기록
```

## 파일

- DUT: [[20_HW/Design_Verification/01_Sync_FIFO/rtl/sync_fifo.sv|sync_fifo.sv]]
- 원본 프로젝트: [[20_HW/RTL_Design/01_Sync_FIFO/README|RTL Design - Sync FIFO]]

## 검증 진행 순서

- [ ] 검증 항목과 경계 조건 정리
- [ ] SystemVerilog Testbench 구조화
- [ ] Assertion 및 Coverage 추가
- [ ] UVM 환경으로 확장

## 원본과의 관계

`RTL_Design`은 과거 설계 학습 기록과 기존 TB를 보존합니다. 이 프로젝트에는 DUT만 복사하며, `tb/`와 `docs/`는 검증 관점에서 새로 작성합니다.

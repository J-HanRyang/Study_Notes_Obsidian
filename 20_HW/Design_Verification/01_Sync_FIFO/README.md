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

- [ ] 9단계: 기존 RTL·directed TB·C 모델·실행 기록에서 확인된 동작과 미검증 동작 구분
- [ ] 9단계: `docs/검증계획.md`에 UVM에서 확인할 입력·기대 결과·관찰 지점 정리
- [ ] 9단계: 최소 UVM 요청 경로(`sequence_item` → sequencer → driver) 구성
- [ ] 10단계: virtual interface/config DB 연결
- [ ] 11단계: monitor와 analysis 통신 연결
- [ ] 12단계: scoreboard/reference model로 데이터 순서와 경계 조건 검사
- [ ] 13~14단계: 디버깅 기록 후 coverage와 assertion 추가

진행 방식은 [[20_HW/Verilog/SystemVerilog UVM 학습 Prompt|통합 학습·실습 프롬프트]]를 따릅니다. 실행하지 않은 항목은 통과로 표시하지 않습니다.

## 원본과의 관계

`RTL_Design/01_Sync_FIFO`에는 이미 RTL, directed TB, C 모델, 기본 write/read 및 full/empty 결과가 있습니다. 기존 TB는 출력 로그를 눈으로 비교한 기록이며 자동 self-checking이나 UVM scoreboard 검증을 대신하지는 않습니다. 원본 파일은 보존하고 이 프로젝트에는 DUT만 복사했습니다. 새 `tb/`와 `docs/`는 기존 결과를 출발점으로 삼아 UVM 검증 관점에서 작성합니다.

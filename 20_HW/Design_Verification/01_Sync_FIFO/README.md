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

## 현재 상태 (2026-10-13)

기초 1~16장의 이론 학습과 교재 정리는 완료했다. 이제 이 프로젝트의 FIFO UVM 실습을 시작한다. UVM 환경 작성·실행·검증은 아직 완료하지 않았다. 회사 SFR 업무는 별도다.

## 검증 진행 순서

- [ ] 기존 RTL·directed TB·C 모델·실행 기록에서 사양과 검증된 범위 확인
- [ ] reset·수락·full/empty·동시 요청·출력 latency를 실제 RTL 기준으로 정리
- [ ] `docs/검증계획.md`에 입력·기대 결과·관찰 시점·통과 기준 작성
- [ ] 기존 환경 안내를 확인하고 UVM smoke test를 실제 실행
- [ ] interface/top과 최소 UVM 요청 경로(sequence_item → sequencer → driver → DUT) 구성
- [ ] virtual interface/config DB, agent/env/test와 port 연결 확인
- [ ] monitor/analysis에서 실제 수락·응답 수집
- [ ] scoreboard/reference model로 순서·경계·동시 요청·reset 검사
- [ ] objection·완료 조건·timeout·미처리 응답 점검
- [ ] 의도적인 오류가 검출되는지 확인한 후 코드 복원
- [ ] coverage·assertion·무작위 자극·seed 재현 추가

단계 번호는 교재 진도와 분리한다. 필요한 이론만 [[20_HW/Verilog/UVM 기초 - 목차|UVM 기초 교재]]에서 찾아본다. 실행하지 않은 항목은 통과로 표시하지 않는다. 다음 작업은 **실제 RTL과 원본 검증 자료 확인**이다.

## 실행과 기록

실행 절차는 [[20_HW/Design_Verification/00_Environment/EDA_Playground_연동|기존 UVM 환경 안내]]를 먼저 확인하고 사용 가능 여부와 설정을 실제 실행으로 점검한다. 기본 SystemVerilog 실행 성공을 UVM 실행 성공으로 기록하지 않는다.

검증 계획과 상세 실행·디버깅 기록은 `docs/`에, 직접 작성하는 UVM 코드는 `tb/`에 둔다. 실행 시 simulator·UVM 버전·test 이름·seed·로그·비교 건수·미처리 응답을 남긴다.

## 원본과의 관계

`RTL_Design/01_Sync_FIFO`에는 이미 RTL, directed TB, C 모델, 기본 write/read 및 full/empty 결과가 있습니다. 기존 TB는 출력 로그를 눈으로 비교한 기록이며 자동 self-checking이나 UVM scoreboard 검증을 대신하지는 않습니다. 원본 파일은 보존하고 이 프로젝트에는 DUT만 복사했습니다. 새 `tb/`와 `docs/`는 기존 결과를 출발점으로 삼아 UVM 검증 관점에서 작성합니다.

# Sync FIFO UVM 실습

32비트 × 깊이 4 Sync FIFO를 독립 queue 모델로 검증하는 학습 프로젝트입니다. 사용자가 작성한 기본 UVM 구조에 scoreboard, 기능 coverage 카운터, assertion과 회귀 시나리오를 연결했습니다. 학습은 완성된 코드의 데이터 흐름과 실제 로그를 읽는 방식으로 진행합니다.

## 실행

Windows VS Code에서 편집하고 Ubuntu 터미널에서 실행합니다.

```bash
cd /mnt/c/Users/Jiyun/Documents/coding_study/Study/20_HW/Design_Verification/01_Sync_FIFO
bash run.sh build
bash run.sh run 1 +SMOKE_ONLY +UVM_VERBOSITY=UVM_HIGH
bash run.sh run 1
bash run.sh regression
```

Verilator 5.052, UVM 2020.3.1과 UVM_NO_DPI를 사용합니다. UVM_HOME 기본값은 ~/tools/uvm-2020.3.1입니다.

## 코드 구성

```text
rtl/sync_fifo.sv                 기존 DUT (보존)
tb/fifo_if.sv                    신호 묶음과 TB 전용 요청 식별자
tb/fifo_seq_item.sv              요청·관찰 transaction
tb/fifo_write_sequence.sv        쓰기 한 번
tb/fifo_read_sequence.sv         읽기 한 번
tb/fifo_sequence.sv              기존 nested 쓰기→읽기
tb/fifo_regression_sequence.sv   경계·동시 요청·wrap·reset·랜덤
tb/fifo_sequencer.sv             item 전달·중재
tb/fifo_driver.sv                클럭에 맞춘 구동과 reset
tb/fifo_monitor.sv               pre/post 관찰·analysis 전송
tb/fifo_agent.sv                 driver/sequencer/monitor 묶음
tb/fifo_scoreboard.sv            독립 queue·데이터·flag 자동 검사
tb/fifo_coverage.sv              상황별 기능 coverage 카운터
tb/fifo_env.sv                   관찰값을 scoreboard/coverage에 연결
tb/fifo_test.sv                  실행·비교 완료 대기·통과 판정
tb/fifo_pkg.sv                   의존 순서대로 클래스 포함
tb/fifo_assertions.sv            reset·포인터·출력 유지 invariant
tb/top.sv                       DUT/interface/config DB/timeout/파형
run.sh                          빌드·실행·회귀와 로그
```

## 읽을 자료

- [코드 해설](docs/코드_해설.md): 각 파일의 역할, sampling, queue 모델, 종료 조건
- [검증 계획](docs/검증계획.md): 자극·예상값·관찰·통과 기준
- [실행 결과](docs/실행결과.md): 실제 빌드·seed·비교 횟수·오류 주입 결과

기능 coverage는 3개 상태 × 4개 요청과 reset 3개 상태, pointer wrap 발생을 세는 카운터입니다. covergroup/UCIS DB와 RTL code coverage 수치는 아닙니다. 임의 비동기 reset pulse, 전송 중 reset 취소, 파라미터 sweep은 후속 범위입니다.

원본 설계 프로젝트 RTL_Design/01_Sync_FIFO는 참고 자료이며 변경하지 않습니다.

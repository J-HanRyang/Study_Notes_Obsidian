# Sync FIFO: 기본 입출력 비교 실습

지금은 사용자가 작성한 driver·monitor·nested sequence 구조를 기준으로, scoreboard와 간단한 coverage만 연결합니다. 확장 버전은 tb_extend/에 보관했습니다.

## 실행

프로젝트 루트의 Ubuntu 터미널에서:

```bash
bash run.sh build
bash run.sh run
```

Verilator 5.052 / UVM 2020.3.1 / UVM_NO_DPI를 사용합니다. 이 실행은 A5 쓰기 한 번, 읽기 한 번뿐입니다. build는 obj_dir의 실행 파일을 현재 기본 버전으로 다시 만듭니다.

## 이번에 볼 코드

- tb/fifo_scoreboard.sv: 쓰기 수락 시 예상 queue에 저장, 읽기 수락 시 꺼내 실제 rdata와 비교
- tb/fifo_coverage.sv: idle/read/write/동시 요청의 관찰 횟수 집계
- tb/fifo_env.sv: agent의 관찰값을 두 컴포넌트로 전달

기존 driver는 요청을 받고 negedge에 구동합니다. 기존 monitor는 posedge의 요청·flag와 다음 negedge의 rdata를 수집합니다. 초기 reset은 원래처럼 top에서 구동합니다.

## 설명·결과

- [기본 코드 해설](docs/코드_해설.md)
- [현재 검증 범위](docs/검증계획.md)
- [실행 결과](docs/실행결과.md)
- [확장 코드 보관](tb_extend/README.md)

현재 기본 버전에는 assertion, 랜덤 회귀, 동작 중 reset, 요청 id, 독립 full/empty 검사가 없습니다. coverage는 첫 단계의 발생 횟수 카운터이며 covergroup은 아직 추가하지 않았습니다. 기본 입출력 비교 흐름을 이해한 뒤 확장합니다.

# 확장 버전 보관

사용자가 기본 driver/monitor 위에서 최소 scoreboard·coverage부터 학습하기로 하여, 2026-10-18 확장 버전을 이 폴더에 보관했습니다.

- 이 폴더의 .sv 17개는 단순화 전 원본과 SHA256 일치를 확인한 사본입니다.
- reset 명령, 요청 id, 독립 flag 검사, 회귀 시나리오, assertion, 확장 coverage가 포함됩니다.
- docs/와 logs/는 확장 버전 설명과 실제 실행 결과입니다.
- run_original.sh와 README_original.md는 보관 당시 원본입니다. 원본 스크립트는 예전 위치를 전제로 하므로 직접 실행하지 않습니다.
- 경로를 조정한 run.sh로 필요할 때 실행할 수 있습니다.

```bash
# 프로젝트 루트에서, 확장 버전을 다시 볼 때만 사용
bash tb_extend/run.sh build
bash tb_extend/run.sh regression
```

확장 빌드는 obj_dir_extend를 사용하며, 현재 기본 실습은 tb/와 루트 run.sh를 사용합니다. 지금은 기본 실습만 학습합니다.

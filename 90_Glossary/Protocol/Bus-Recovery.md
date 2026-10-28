---
aliases: ["버스 복구"]
tags: [glossary, protocol]
---
# Bus Recovery

## 한 줄 정의

중단된 전송으로 신호선이 해제되지 않을 때 정상 통신 상태로 돌아가게 하는 조치.

## 핵심 설명

SDA stuck LOW이고 SCL을 움직일 수 있으면 최대 9개 Clock의 Bus Clear를 시도할 수 있다.

## 예시

Controller Reset 뒤 Target이 데이터 0을 유지하면 Clock을 제공해 바이트·ACK 진행을 유도한다.

## 헷갈리는 개념

9번이면 항상 해결되지는 않는다. SCL stuck LOW에는 같은 방식이 통하지 않으며 Reset·전원 조치가 필요할 수 있다.

## 관련 노트

[[30. Notes/Protocol/I2C#9. 충돌과 Bus Hang을 구분|고정 LOW와 복구]]

## 참고자료

- [규격·제조사 자료](https://www.nxp.com/docs/en/user-guide/UM10204.pdf)


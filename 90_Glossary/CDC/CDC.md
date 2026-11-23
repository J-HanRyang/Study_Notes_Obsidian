# 1. 뜻

- Clock Domain Crossing은 한 클록에서 생성한 신호를 다른 클록에서 샘플링하는 경로다.
- 비동기 클록은 에지 간 위상이 고정되지 않아 송신 신호가 수신 에지 근처에서 바뀔 수 있다.

# 2. 신호에 맞는 전달 방식

- [[90_Glossary/CDC/Metastability|Metastability]]
- [[30. Notes/CDC/Pulse CDC|Pulse CDC]]
- [[30. Notes/CDC/Handshake CDC|Handshake CDC]]
- [[90_Glossary/CDC/Gray Code|Gray Code]]

- 충분히 오래 유지되는 단일 비트 상태는 수신 도메인의 동기화기를 거쳐 사용한다.
- 짧은 이벤트는 폭과 최소 간격을 보고 Pulse CDC나 수신 확인이 있는 Handshake CDC를 선택한다.
- 한 덩어리로 읽어야 하는 데이터는 각 비트가 같은 전송에 속한다는 조건까지 보장해야 한다.
- 연속 데이터의 순서와 임시 저장이 모두 필요하면 비동기 FIFO를 사용한다.

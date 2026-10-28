# 1. 뜻

- SMBus의 전송 바이트 오류 검사용 CRC-8 바이트.

# 2. 동작과 사용

- 주소/RW를 포함한 전송 바이트에 다항식 0x07을 적용한다.
- START/STOP·ACK 비트는 계산에서 제외한다.

# 3. 예

- Read Word에 PEC가 있으면 Hi에도 ACK하고 PEC를 받은 뒤 마지막 NACK한다.

# 4. 헷갈리는 점

- 마지막 Read NACK가 PEC 오류라는 뜻은 아니다.
- Quick Command·Host Notify에는 PEC 형식이 없다.

# 5. 관련 학습 노트

- [[30. Notes/Protocol/SMBus#6. PEC를 붙이면 달라지는 것|PEC 형식과 입력 순서]]

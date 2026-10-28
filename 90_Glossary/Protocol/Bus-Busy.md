# 1. 뜻
- Bus Busy는 버스에서 전송이 진행 중인 상태를 뜻한다.

# 2. 동작과 사용
- I2C에서는 START와 STOP의 이력을 함께 보고 버스 사용 상태를 판단한다.
- 신호선이 순간적으로 HIGH라고 해서 즉시 빈 버스가 되는 것은 아니다.

# 3. 예
- Repeated START 전의 HIGH 구간은 이전 전송이 끝났음을 뜻하지 않는다.

# 4. 헷갈리는 점
- [[90_Glossary/Protocol/tBUF|tBUF]]는 STOP 뒤 다음 START까지의 최소 간격이다.
- SMBus의 Idle 판정 조건은 I2C의 Busy 설명과 구분해서 읽는다.

# 5. 관련 학습 노트
- [[30. Notes/Protocol/I2C#8. Bus Busy와 tBUF|I2C의 Bus Busy]]
- [[30. Notes/Protocol/SMBus#8. CLK LOW를 네 가지로 구분|SMBus의 시간 조건]]

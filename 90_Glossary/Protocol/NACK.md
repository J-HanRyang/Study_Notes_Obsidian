# 1. 뜻
- NACK는 한 바이트를 받은 쪽이 9번째 Clock에서 SDA를 해제해 HIGH로 두는 응답이다.

# 2. 동작과 사용
- 주소·Write 데이터 뒤의 NACK는 응답 대상이나 수용 조건을 확인해야 하는 신호다.
- Read의 마지막 바이트 뒤에는 Controller가 더 읽지 않겠다는 뜻으로 NACK를 보낸다.

# 3. 예
- Controller가 Read의 마지막 데이터 바이트를 받은 뒤 NACK를 보내고 STOP을 만든다.

# 4. 헷갈리는 점
- 모든 NACK를 오류로 분류하지 않는다.
- 앞의 바이트가 주소인지 데이터인지에 따라 의미가 달라진다.

# 5. 관련 학습 노트
- [[90_Glossary/Protocol/ACK|ACK]]
- [[30. Notes/Protocol/I2C#4. ACK는 누가 보내는가?|I2C의 응답 구간]]
- [[30. Notes/Protocol/SMBus#7. ACK/NACK는 구간별로 해석|SMBus의 응답 구간]]

# 1. 뜻
- ACK는 한 바이트를 받은 쪽이 9번째 Clock에서 SDA를 LOW로 당겨 보내는 응답이다.

# 2. 동작과 사용
- 바이트를 보낸 쪽은 응답 구간에서 SDA 구동을 해제한다.
- 주소와 Write 데이터에서는 보통 Target이 ACK를 보낸다.
- Read 데이터에서는 Controller가 다음 바이트를 받겠다는 뜻으로 ACK를 보낸다.

# 3. 예
- Controller가 Target 주소를 보낸 뒤 해당 Target이 응답하면 9번째 Clock의 SDA가 LOW가 된다.

# 4. 헷갈리는 점
- ACK는 해당 구간의 수신 응답이며 명령의 최종 실행 완료를 뜻하지는 않는다.
- [[90_Glossary/Protocol/NACK|NACK]]는 마지막 Read 바이트 뒤의 정상 종료 표시일 수도 있다.

# 5. 관련 학습 노트
- [[30. Notes/Protocol/I2C#4. ACK는 누가 보내는가?|I2C의 ACK 주체]]
- [[30. Notes/Protocol/SMBus#7. ACK/NACK는 구간별로 해석|SMBus의 ACK 해석]]

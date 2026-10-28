# 1. 뜻
- tBUF는 STOP 조건 뒤 다음 START 조건까지 확보해야 하는 최소 버스 자유 시간이다.

# 2. 동작과 사용
- 적용 값은 사용하는 I2C 속도 모드의 규격을 확인한다.
- Standard-mode와 Fast-mode에 같은 최소값을 무조건 적용하지 않는다.

# 3. 예
- Standard-mode의 tBUF 최소는 4.7 µs이고 Fast-mode의 최소는 1.3 µs다.

# 4. 헷갈리는 점
- [[90_Glossary/Protocol/Bus-Busy|Bus Busy]]는 진행 중인 전송 상태이며 tBUF는 STOP 이후의 간격이다.
- 데이터 전송 중 SCL과 SDA가 모두 HIGH인 순간만으로 tBUF를 계산하지 않는다.

# 5. 관련 학습 노트
- [[30. Notes/Protocol/I2C#8. Bus Busy와 tBUF|I2C의 tBUF]]

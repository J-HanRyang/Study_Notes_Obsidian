# 1. 뜻

- 장치가 Clock LOW를 유지해 다음 진행을 늦추는 동작.

# 2. 동작과 사용

- Controller가 SCL을 놓아도 실제 선이 HIGH가 될 때까지는 HIGH 구간이 시작되지 않는다.

# 3. 예

- Slave가 처리 시간을 확보하려고 SMBCLK LOW를 연장한다.

# 4. 헷갈리는 점

- 항상 오류나 stuck 상태는 아니다.
- 지원 여부와 SMBus의 연장·Timeout 조건을 확인한다.

# 5. 관련 학습 노트

- [[30. Notes/Protocol/I2C#6. Clock Stretching과 Clock 동기화|I2C]]
- [[30. Notes/Protocol/SMBus#8. CLK LOW를 네 가지로 구분|SMBus 시간 제한]]

# 1. 뜻

- 동시에 송신하려는 장치가 실제 공유선의 값을 비교해 버스 사용을 결정하는 과정.

# 2. 동작과 사용

- I2C/SMBus의 LOW 우선 구조에서는 1을 의도했는데 0을 읽은 송신자가 패배한다.

# 3. 예

- A=101, B=100이라면 세 번째 비트에서 A가 패배한다.

# 4. 헷갈리는 점

- 전체 0 개수로 승패를 정하지 않는다.
- Busy 중 잘못 끼어드는 동작이나 일반 주소 중복을 정상 중재로 보지 않는다.

# 5. 관련 학습 노트

- [[30. Notes/Protocol/I2C#7. Arbitration: 처음 다른 비트에서 결정|I2C 중재]]
- [[90_Glossary/Protocol/Clock-Synchronization|Clock Synchronization]]

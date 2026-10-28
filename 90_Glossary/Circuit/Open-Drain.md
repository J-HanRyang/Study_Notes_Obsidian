# 1. 뜻

- 출력을 LOW로 끌어내리거나 구동을 해제하는 출력 구조.

# 2. 동작과 사용

- 출력 해제 시 HIGH는 풀업 경로가 만든다.
- 공유선은 누군가 LOW를 구동하면 LOW가 된다.

# 3. 예

- I2C 장치가 데이터 1을 보낼 때 SDA를 놓는다.
- 다른 장치가 0을 보내면 실제 SDA는 LOW다.

# 4. 헷갈리는 점

- HIGH를 능동 구동하는 Push-Pull과 다르다.
- 출력 해제가 항상 핀 HIGH를 뜻하지는 않는다.

# 5. 관련 학습 노트

- [[30. Notes/Circuit/Push-Pull|Push-Pull]]
- [[30. Notes/Protocol/I2C|I2C]]
- [[90_Glossary/Circuit/Pull-Up|Pull-Up]]

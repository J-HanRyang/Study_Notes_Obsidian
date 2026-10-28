# 1. 뜻

- SMBus 장치가 수행할 기능을 선택하는 1바이트 값.

# 2. 동작과 사용

- 프로토콜은 전송 구조를, Command Code는 그 장치에서 수행할 기능을 나타낸다.

# 3. 예

- Read Word에서 주소 다음 Cmd를 보낸 뒤 Sr로 읽기 방향을 시작한다.

# 4. 헷갈리는 점

- Slave Address와 다르며, 반드시 내부 Register의 물리 주소라는 뜻도 아니다.
- Quick/Send/Receive는 형식이 다르다.

# 5. 관련 학습 노트

- [[30. Notes/Protocol/SMBus#4. 대표 전송을 먼저 읽기|SMBus Word 형식]]
- [[90_Glossary/Protocol/Transaction|Transaction]]

# 1. 뜻

- SMBus ARP에서 장치를 식별하는 128-bit 정보.

# 2. 동작과 사용

- 주소를 배정할 대상을 고르는 데 사용하며 7-bit Slave Address와 역할이 다르다.

# 3. 예

- Get UDID 응답으로 장치를 식별하고 Assign Address에 해당 UDID를 넣는다.

# 4. 헷갈리는 점

- 통신 주소나 단순한 장치 모델 번호와 같지 않다.
- 구성 필드와 식별 방식은 규격 및 장치 구현을 확인한다.

# 5. 관련 학습 노트

- [[90_Glossary/Protocol/ARP|ARP]]
- [[30. Notes/Protocol/SMBus#10. ARP, ARA, Host Notify|주소와 장치 식별]]

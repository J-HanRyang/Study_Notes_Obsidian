---
aliases: ["Unique Device Identifier"]
tags: [glossary, protocol]
---
# UDID

## 한 줄 정의

SMBus ARP에서 장치를 식별하는 128-bit 정보.

## 핵심 설명

주소를 배정할 대상을 고르는 데 사용하며 7-bit Slave Address와 역할이 다르다.

## 예시

Get UDID 응답으로 장치를 식별하고 Assign Address에 해당 UDID를 넣는다.

## 헷갈리는 개념

통신 주소나 단순한 장치 모델 번호와 같지 않다. 구성 필드와 식별 방식은 규격 및 장치 구현을 확인한다.

## 관련 노트

[[90_Glossary/Protocol/ARP|ARP]] · [[30. Notes/Protocol/SMBus#9. ARP, ARA, Host Notify|주소와 장치 식별]]

## 참고자료

- [규격·제조사 자료](https://smbus.org/specs/SMBus_3_0_20141220.pdf)


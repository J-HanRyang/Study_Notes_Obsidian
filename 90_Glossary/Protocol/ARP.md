---
aliases: ["Address Resolution Protocol"]
tags: [glossary, protocol]
---
# ARP

## 한 줄 정의

SMBus 지원 장치를 식별하고 주소를 관리하는 프로토콜.

## 핵심 설명

UDID 응답 중재로 장치를 식별한 뒤 UDID를 지정해 주소를 할당한다. ARP 과정에서는 PEC가 필수다.

## 예시

Prepare to ARP → Get UDID → Assign Address를 반복한다.

## 헷갈리는 개념

고정 주소 장치 모두가 지원하는 것은 아니다. Non-ARP 장치의 주소 충돌을 자동 해결하지 못한다.

## 관련 노트

[[30. Notes/Protocol/SMBus#9. ARP, ARA, Host Notify|ARP 흐름]] · [[90_Glossary/Protocol/UDID|UDID]]

## 참고자료

- [규격·제조사 자료](https://smbus.org/specs/SMBus_3_0_20141220.pdf)


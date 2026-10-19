---
aliases: ["명령 코드"]
tags: [glossary, protocol]
created: 2026-10-19
---
# Command Code

## 한 줄 정의

SMBus 장치가 수행할 기능을 선택하는 1바이트 값.

## 핵심 설명

프로토콜은 전송 구조를, Command Code는 그 장치에서 수행할 기능을 나타낸다.

## 예시

Read Word에서 주소 다음 Cmd를 보낸 뒤 Sr로 읽기 방향을 시작한다.

## 헷갈리는 개념

Slave Address와 다르며, 반드시 내부 Register의 물리 주소라는 뜻도 아니다. Quick/Send/Receive는 형식이 다르다.

## 관련 노트

[[30. Notes/Protocol/SMBus#3. 대표 전송을 먼저 읽기|SMBus Word 형식]] · [[90_Glossary/Protocol/Transaction|Transaction]]

## 참고자료

- [규격·제조사 자료](https://smbus.org/specs/SMBus_3_0_20141220.pdf)


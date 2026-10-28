---
aliases: ["트랜잭션"]
tags: [glossary, protocol]
---
# Transaction

## 한 줄 정의

하나의 통신 작업으로 묶어 해석하는 일련의 전송.

## 핵심 설명

SMBus에서는 START부터 결합된 데이터·Repeated START 등을 거쳐 STOP까지의 형식을 읽는다.

## 예시

Read Word는 명령 Write와 데이터 Read를 Sr로 연결한 하나의 결합 작업이다.

## 헷갈리는 개념

바이트 하나나 Clock 한 주기와 같지 않다. 코드 API가 쓰는 Transaction 단위는 정의를 따로 확인한다.

## 관련 노트

[[30. Notes/Protocol/I2C#5. Register 읽기 예시|I2C Read]] · [[30. Notes/Protocol/SMBus#3. 대표 전송을 먼저 읽기|SMBus Read]]

## 참고자료

- [규격·제조사 자료](https://smbus.org/specs/SMBus_3_0_20141220.pdf)


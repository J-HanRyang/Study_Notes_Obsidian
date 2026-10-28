---
aliases: ["응답·비응답"]
tags: [glossary, protocol]
---
# ACK NACK

## 한 줄 정의

한 바이트 뒤 9번째 Clock에서 Receiver가 보내는 수신 응답.

## 핵심 설명

ACK는 LOW, NACK는 해제로 HIGH다. 송신자는 응답 구간에서 데이터선을 놓는다.

## 예시

Read에서는 Target/Slave가 데이터를 보내고 Controller/Master가 ACK한다. 마지막 NACK는 정상 읽기 종료다.

## 헷갈리는 개념

NACK가 항상 오류는 아니다. 주소·Write 데이터·Read 마지막·PEC 구간을 구분한다.

## 관련 노트

[[30. Notes/Protocol/I2C#4. ACK는 누가 보내는가?|I2C 응답 주체]] · [[30. Notes/Protocol/SMBus#6. ACK/NACK는 구간별로 해석|SMBus 응답 규칙]]

## 참고자료

- [규격·제조사 자료](https://smbus.org/specs/SMBus_3_0_20141220.pdf)


---
aliases: ["버스 점유와 버스 프리 시간"]
tags: [glossary, protocol]
---
# Bus Busy and tBUF

## 한 줄 정의

진행 중인 전송 상태와, STOP 뒤 다음 START까지 필요한 최소 간격을 구분하는 개념.

## 핵심 설명

I2C Busy는 START/STOP 이력과 연결되며 tBUF는 STOP 후 간격이다. SMBus에는 tHIGH,max 기반 Idle 판단도 있다.

## 예시

I2C Standard-mode tBUF 최소는 4.7 µs지만 Fast-mode는 1.3 µs다.

## 헷갈리는 개념

데이터 1 구간의 HIGH-HIGH만으로 I2C 버스가 비었다고 판단하지 않는다. 모든 모드에 4.7 µs를 적용하지 않는다.

## 관련 노트

[[30. Notes/Protocol/I2C#8. Bus Busy와 tBUF|I2C 상태 판단]] · [[30. Notes/Protocol/SMBus#7. CLK LOW를 네 가지로 구분|SMBus Idle]]

## 참고자료

- [규격·제조사 자료](https://www.nxp.com/docs/en/user-guide/UM10204.pdf)


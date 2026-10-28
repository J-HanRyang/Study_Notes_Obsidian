---
aliases: ["클럭 스트레칭"]
tags: [glossary, protocol]
---
# Clock Stretching

## 한 줄 정의

장치가 Clock LOW를 유지해 다음 진행을 늦추는 동작.

## 핵심 설명

Controller가 SCL을 놓아도 실제 선이 HIGH가 될 때까지는 HIGH 구간이 시작되지 않는다.

## 예시

Slave가 처리 시간을 확보하려고 SMBCLK LOW를 연장한다.

## 헷갈리는 개념

항상 오류나 stuck 상태는 아니다. 지원 여부와 SMBus의 연장·Timeout 조건을 확인한다.

## 관련 노트

[[30. Notes/Protocol/I2C#6. Clock Stretching과 Clock 동기화|I2C]] · [[30. Notes/Protocol/SMBus#7. CLK LOW를 네 가지로 구분|SMBus 시간 제한]]

## 참고자료

- [규격·제조사 자료](https://smbus.org/specs/SMBus_3_0_20141220.pdf)


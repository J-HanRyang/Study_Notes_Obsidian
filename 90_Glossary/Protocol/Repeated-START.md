---
aliases: ["반복 시작"]
tags: [glossary, protocol]
---
# Repeated START

## 한 줄 정의

STOP으로 버스를 놓지 않고 다시 만드는 START 조건.

## 핵심 설명

버스 점유를 이어가면서 주소나 읽기·쓰기 방향을 다시 지정한다.

## 예시

Register 선택 Write 뒤 Sr, Read 주소를 보내 데이터를 읽는다.

## 헷갈리는 개념

Sr 뒤에도 주소가 필요하다. 데이터 중 HIGH-HIGH를 본 것과 새 START를 검출한 것은 다르다.

## 관련 노트

[[30. Notes/Protocol/I2C#5. Register 읽기 예시|Register Read]] · [[30. Notes/Protocol/SMBus#3. 대표 전송을 먼저 읽기|Read Word]]

## 참고자료

- [규격·제조사 자료](https://www.nxp.com/docs/en/user-guide/UM10204.pdf)


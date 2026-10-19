---
aliases: ["풀업"]
tags: [glossary, circuit]
created: 2026-10-19
---
# Pull Up

## 한 줄 정의

출력들이 해제된 신호선을 전원 쪽으로 끌어올리는 경로.

## 핵심 설명

저항 풀업은 LOW 때의 전류와 HIGH로 상승하는 속도 사이에서 값을 정한다.

## 예시

I2C의 SDA와 SCL에는 각각 풀업 경로가 있다. 보드마다 저항이 있으면 병렬 합성값을 본다.

## 헷갈리는 개념

작을수록 무조건 좋은 저항이 아니다. Sink 전류 한계와 버스 정전용량을 함께 확인한다.

## 관련 노트

[[30. Notes/Protocol/I2C#10. 풀업과 데이터 검사|I2C 풀업 계산]] · [[90_Glossary/Circuit/Open-Drain|Open-Drain]]

## 참고자료

- [규격·제조사 자료](https://www.ti.com/lit/an/slva689/slva689.pdf)


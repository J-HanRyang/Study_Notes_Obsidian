---
aliases: ["오픈드레인"]
tags: [glossary, circuit]
---
# Open Drain

## 한 줄 정의

출력을 LOW로 끌어내리거나 구동을 해제하는 출력 구조.

## 핵심 설명

출력 해제 시 HIGH는 풀업 경로가 만든다. 공유선은 누군가 LOW를 구동하면 LOW가 된다.

## 예시

I2C 장치가 데이터 1을 보낼 때 SDA를 놓는다. 다른 장치가 0을 보내면 실제 SDA는 LOW다.

## 헷갈리는 개념

HIGH를 능동 구동하는 Push-Pull과 다르다. 출력 해제가 항상 핀 HIGH를 뜻하지는 않는다.

## 관련 노트

[[30. Notes/Circuit/Push-Pull|Push-Pull]] · [[30. Notes/Protocol/I2C|I2C]] · [[90_Glossary/Circuit/Pull-Up|Pull-Up]]

## 참고자료

- [규격·제조사 자료](https://www.nxp.com/docs/en/user-guide/UM10204.pdf)


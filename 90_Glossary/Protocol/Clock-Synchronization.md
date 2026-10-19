---
aliases: ["클럭 동기화"]
tags: [glossary, protocol]
created: 2026-10-19
---
# Clock Synchronization

## 한 줄 정의

여러 Controller/Master가 생성하는 Clock을 실제 공유 SCL에 맞추는 과정.

## 핵심 설명

누군가 LOW를 유지하면 SCL은 LOW다. 모두 해제하면 HIGH가 되고, 누군가 다시 LOW로 끌면 HIGH가 끝난다.

## 예시

일반적으로 가장 긴 LOW 시간과 가장 짧은 HIGH 시간이 버스 파형에 반영된다.

## 헷갈리는 개념

Target의 처리 대기를 위한 Stretching과 목적이 다르다. 결과 Duty가 50%일 필요는 없다.

## 관련 노트

[[30. Notes/Protocol/I2C#6. Clock Stretching과 Clock 동기화|동기화 동작]] · [[90_Glossary/Protocol/Clock-Stretching|Clock Stretching]]

## 참고자료

- [규격·제조사 자료](https://www.nxp.com/docs/en/user-guide/UM10204.pdf)


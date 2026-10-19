---
aliases: ["Packet Error Code"]
tags: [glossary, protocol]
created: 2026-10-19
---
# PEC

## 한 줄 정의

SMBus의 전송 바이트 오류 검사용 CRC-8 바이트.

## 핵심 설명

주소/RW를 포함한 전송 바이트에 다항식 0x07을 적용한다. START/STOP·ACK 비트는 계산에서 제외한다.

## 예시

Read Word에 PEC가 있으면 Hi에도 ACK하고 PEC를 받은 뒤 마지막 NACK한다.

## 헷갈리는 개념

마지막 Read NACK가 PEC 오류라는 뜻은 아니다. Quick Command·Host Notify에는 PEC 형식이 없다.

## 관련 노트

[[30. Notes/Protocol/SMBus#5. PEC를 붙이면 달라지는 것|PEC 형식과 입력 순서]]

## 참고자료

- [규격·제조사 자료](https://smbus.org/specs/SMBus_3_0_20141220.pdf)


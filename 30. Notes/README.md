---
tags: [study, index]
---
# Study Notes

원리를 설명하는 학습 노트와 짧은 용어 정의를 연결하는 목차.

## Circuit

| 노트 | 복습할 내용 |
|---|---|
| [[30. Notes/Circuit/Buck-Boost\|Buck / Boost / Buck-Boost]] | 에너지 이동, 스위칭 상태, 듀티비와 출력 관계 |
| [[30. Notes/Circuit/Push-Pull\|Push-Pull]] | HIGH/LOW 구동, Open-Drain과 공유 버스의 차이 |

## Protocol

| 노트 | 복습할 내용 |
|---|---|
| [[30. Notes/Protocol/I2C\|I2C]] | 전기적 구조, ACK 주체, Register 읽기, 동기화·중재·복구 |
| [[30. Notes/Protocol/SMBus\|SMBus 3.0]] | I2C와 차이, 전송 형식, PEC, Timeout, ARP·Alert |
| [[30. Notes/Protocol/PMBus\|PMBus]] | 전력 관리 명령, 전압 설정·측정, Fault·Status, DV 관점 |

## Power / Memory

| 노트 | 복습할 내용 |
|---|---|
| [[30. Notes/Power/PSI-and-FAULT\|PSI와 FAULT]] | Main/Sub PMIC 동기화와 FAULT 신호의 확인 질문 |
| [[30. Notes/Memory/SRAM-DRAM\|SRAM과 DRAM]] | Cell 구조, Read/Write, Collision, DRAM Timing |

## 연결해서 읽기

1. [[30. Notes/Circuit/Push-Pull|출력 구조]] → [[90_Glossary/Circuit/Open-Drain|Open-Drain]] → [[30. Notes/Protocol/I2C|I2C의 신호와 중재]].
2. [[30. Notes/Protocol/I2C|I2C]] → [[30. Notes/Protocol/SMBus|SMBus의 규칙과 관리 기능]].
3. [[30. Notes/Protocol/SMBus|SMBus]] → [[30. Notes/Protocol/PMBus|전력 관리 명령]] → [[30. Notes/Power/PSI-and-FAULT|전원 시퀀스와 FAULT]].
4. [[30. Notes/Circuit/Buck-Boost|전력 변환]] → [[90_Glossary/Circuit/PWM|PWM]] → [[90_Glossary/Circuit/Duty-Cycle|Duty Cycle]].

## 노트 구분

- 학습 노트: 구조와 동작을 순서대로 설명한다. 예외 조건과 근거를 함께 둔다.
- [[90_Glossary/README|Glossary]]: 한 용어의 뜻, 간단한 예시, 혼동하는 개념을 짧게 확인한다.
- 코드와 실습 결과: 기존 `20_HW` 또는 `10_SW`의 해당 프로젝트에서 관리한다.

용어 노트를 추가할 때는 [[_Tempates/Glossary_Template|Glossary Template]]을 사용하고 Glossary 목차에 링크를 추가한다.


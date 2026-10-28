---
aliases: ["PSI", "Power Sequence Interface", "FAULT"]
tags: [study, power, pmic, dv]
---
# PSI와 FAULT

> Main/Sub PMIC의 전원 순서와 이상 상태 신호를 공부하며 생긴 질문을 정리한 노트.

이전 학습 대화에서는 **PSI(Power Sequence Interface)** 라는 이름으로 이야기했다. 사용 중인 장치에서 PSI가 정확히 무엇을 뜻하는지, 신호 구성과 동작 규칙은 해당 제품 명세로 확정해야 한다.

## 먼저 구분할 질문

| 질문 | 확인할 자료 |
|---|---|
| Main PMIC와 Sub PMIC가 어떤 이벤트에 맞춰 동기화되는가? | 전원 시퀀스 그림, 상태 전이, 타이밍 표 |
| PSI가 SPMI 패킷으로 전달되는가, 별도 핀/선으로 전달되는가? | 블록도, 핀 목록, 인터페이스 설명 |
| FAULT를 어느 장치가 언제 주장하고 누가 해제하는가? | FAULT 신호 정의, Fault 처리 절 |
| FAULT가 Open-Drain이라면 풀업과 공유 조건은 무엇인가? | 전기적 특성, 연결도 |
| FAULT가 발생하면 전원 레일과 통신 상태가 어떻게 변하는가? | 보호·복구 시퀀스 |

**PSI라는 이름만으로 SPMI와 같은 선이라고 판단하지 않는다.** 또 FAULT 출력이 Open-Drain이라는 전기적 특성만으로 Fault의 의미나 복구 순서를 결정할 수 없다. 신호의 물리적 연결, 주장 조건, 상태 전이를 각각 확인한다.

## DV 관점에서 정리할 항목

1. 입력 이벤트와 Main/Sub PMIC의 기대 상태를 표로 만든다.
2. FAULT 주장·해제 조건과 극성, Reset 시 초기 상태를 확인한다.
3. 두 장치가 동시에 공유선을 구동할 수 있다면 실제 선 값을 어떻게 관찰할지 정한다.
4. 정상 시작, 중간 Fault, 복구, 반복 Fault를 시나리오로 나눈다.
5. 검증 가능한 디지털 신호와 아날로그 전원 결과의 경계를 명시한다.

## 연결

[[90_Glossary/Circuit/Open-Drain|Open-Drain]] · [[30. Notes/Protocol/PMBus|PMBus의 Fault·Status]]

## 근거와 확인 필요

- [출퇴근 학습 대화](https://chatgpt.com/c/6adb58f7-9a6c-83e8-a909-3d718b3d1e20)에서 Main/Sub 동기화, SPMI와 PSI의 관계, Open-Drain FAULT를 질문했다.
- 이 대화에는 대상 PMIC의 회로도·규격 원문이 없으므로 구체적인 핀 구성이나 Fault 타이밍은 적지 않았다.

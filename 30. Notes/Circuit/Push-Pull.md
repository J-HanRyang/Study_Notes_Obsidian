---
aliases: ["푸시풀", "푸시풀 출력"]
tags: [study, circuit, digital]
---
# Push-Pull

> HIGH와 LOW를 모두 능동적으로 구동하는 출력 구조.

이 노트는 **디지털 신호의 출력단**을 다룬다.
같은 이름을 사용하는 변압기 기반 Push-Pull 전력 컨버터와는 구분한다.

## 1. 출력이 HIGH라는 의미

핀의 논리값은 결국 외부 핀 전압으로 나타난다.
Push-Pull 출력은 전원 쪽과 GND 쪽 구동 경로를 선택해 전압을 만든다.

```text
       VDD
        │
   상단 구동 소자
        │
        ├──── OUT ──── 수신 입력
        │
   하단 구동 소자
        │
       GND
```

| 출력 | 상단 경로 | 하단 경로 | 의미 |
|---|---|---|---|
| HIGH | ON | OFF | 출력에서 부하로 전류 공급: Source |
| LOW | OFF | ON | 출력으로 들어온 전류를 GND로 흘림: Sink |
| High-Z | 둘 다 OFF | 둘 다 OFF | 출력 허용 제어가 있는 구조에서 핀 구동 해제 |

**모든 Push-Pull 출력에 High-Z 제어가 있는 것은 아니다.**
일반적인 CMOS 출력단은 상단 PMOS와 하단 NMOS로 구현할 수 있다.
[출력단 기본 설명](https://www.ti.com/lit/an/slca006/slca006.pdf)

## 2. Open-Drain과 비교

| 항목 | Push-Pull | [[90_Glossary/Circuit/Open-Drain\|Open-Drain]] |
|---|---|---|
| LOW | 직접 구동 | 직접 구동 |
| HIGH | 직접 구동 | 출력 해제 후 풀업으로 상승 |
| 풀업 저항 | HIGH 생성 목적으로는 보통 불필요 | 저항 또는 규격에 맞는 풀업 경로 필요 |
| 상승 속도 | 구동 능력과 부하에 좌우 | 풀업·버스 정전용량에 크게 좌우 |
| 여러 출력 공유 | 서로 다른 값 구동 시 충돌 | 적합한 전기 조건에서 LOW 우선 |
| 대표 연결 | GPIO, SPI 신호 등 | I2C, SMBus, 공유 인터럽트 등 |

High-Z는 논리 1과 동일하지 않다.
다른 구동 경로나 풀업이 없다면 외부 핀 전압이 정해지지 않을 수 있다.
[I2C 물리 계층](https://www.ti.com/lit/an/sbaa565/sbaa565.pdf)

## 3. 두 출력을 묶으면

```text
출력 A: HIGH ───┐
                ├── 공유선
출력 B: LOW  ───┘
```

Push-Pull에서는 A의 전원 경로와 B의 GND 경로 사이로 큰 전류가 흐를 수 있다.
충돌 시 전압도 올바른 논리값이라고 보장할 수 없다.

반면 Open-Drain에서 HIGH를 보낸다는 것은 선을 놓는 동작이다.
다른 장치가 LOW를 구동하면 버스는 LOW가 되고, 풀업 저항이 전류를 제한한다.
이 성질이 [[30. Notes/Protocol/I2C|I2C]]와 [[30. Notes/Protocol/SMBus|SMBus]]의 중재를 가능하게 한다.

## 4. 왜 무조건 Push-Pull을 쓰지 않는가?

빠르게 HIGH와 LOW를 만드는 데는 유리하지만 공유선에서는 구동 주체를 관리해야 한다.
반이중 버스에서 3-state 출력들을 공유한다면 동시에 하나만 활성화되도록 별도 제어가 필요하다.

I2C의 기본 공유 버스 구조는 선을 놓는 것과 LOW 구동을 조합한다.
이를 단순한 Push-Pull GPIO HIGH/LOW 출력으로 바꾸면 ACK, 중재, Clock Stretching에서 충돌할 수 있다.

## 5. 실제 출력에서 볼 것

- 데이터시트의 $V_{OH}/V_{OL}$은 특정 출력 전류 조건에서 보장된다.
- 핀 하나의 전류 한계와 포트·칩 전체 전류 한계를 구분한다.
- 부하 정전용량이 크면 전환 시간이 길어지고 동적 전류가 늘어난다.
- 전압이 다른 장치를 연결할 때는 입력 허용 전압과 논리 임계값을 확인한다.
- 한 출력단 내부의 순간적인 상·하단 동시 도통과, 외부 출력끼리의 충돌은 구분한다.

## 6. 복습

1. HIGH 구동과 출력 해제는 어떻게 다른가?
2. Push-Pull 두 개가 서로 다른 값을 내면 전류가 어디로 흐르는가?
3. Open-Drain에서는 여러 장치가 같은 선을 사용할 수 있는 이유가 무엇인가?

## 관련 노트

[[90_Glossary/Circuit/Open-Drain|Open-Drain]] · [[90_Glossary/Circuit/High-Impedance|High-Z]] · [[90_Glossary/Circuit/Pull-Up|Pull-Up]] · [[90_Glossary/Protocol/Arbitration|Arbitration]]

## 참고자료

- [TI — Comparator Output Types](https://www.ti.com/lit/an/slca006/slca006.pdf)
- [TI — A Basic Guide to I2C: 공유선의 전기적 동작](https://www.ti.com/lit/an/sbaa565/sbaa565.pdf)


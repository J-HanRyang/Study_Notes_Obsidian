---
aliases: ["System Management Bus", "SMBus 3.0"]
tags: [study, protocol, smbus]
specification: "SMBus 3.0, 2014-12-20"
---
# SMBus 3.0

> 시스템 관리 장치가 공통 전송 형식과 시간·오류 처리 규칙으로 통신하는 버스.

이 노트의 기준은 **SMBus Specification 3.0**이다.
후속 버전의 변경 사항을 섞지 않는다.
[[30. Notes/Protocol/I2C|I2C]]의 Open-Drain, 비트·바이트 전송, 중재를 먼저 이해하면 읽기 쉽다.

## 1. I2C와 무엇이 다른가?

| 항목 | I2C 기본 전송 | SMBus 3.0 |
|---|---|---|
| 목적 | 범용 장치 간 통신 | 시스템 관리 |
| 전기 조건 | I2C 모드별 조건 | SMBus Low/High Power DC 조건 |
| 속도 | Standard/Fast/Fm+ 등 | 100 kHz / 400 kHz / 1 MHz Class |
| 전송 형식 | 장치별 상위 프로토콜 | Byte·Word·Block 등 공통 형식 |
| 무결성 | 기본 공통 CRC 없음 | PEC 형식 정의 |
| 지연 처리 | 기본 규격에 공통 SMBus형 Timeout 없음 | Clock LOW Timeout·연장 제한 정의 |
| 주소 응답 | 상황에 따라 NACK 가능 | 자기 주소 ACK 요구 |
| 추가 관리 | 장치·상위 프로토콜에 의존 | ARP, Alert Response, Host Notify 등 |

**Timeout만 더한 I2C라고 보면 빠지는 규칙이 많다.**
같은 배선 방식이어도 전압·전류, 타이밍, 지원 기능을 확인해야 혼용 가능 여부를 판단할 수 있다.

## 2. 역할과 표기

- **Master:** Transaction을 시작하고 Clock을 생성한다.
- **Slave:** 주소로 선택되어 응답한다.
- **Host:** 시스템 관리를 담당하는 논리적 역할. 항상 현재 Master라는 뜻은 아니다.
- **Command Code:** 장치가 수행할 명령을 고르는 1바이트 값.
- **Word:** 2바이트. Word 프로토콜은 Low Byte부터 전송하지만, **각 바이트의 비트는 MSB부터** 보낸다.

전송 그림의 표기는 다음과 같다.

| 표기 | 의미 |
|---|---|
| S / Sr / P | START / Repeated START / STOP |
| AddrW / AddrR | 7-bit 주소에 W=0 또는 R=1을 붙인 주소 바이트 |
| A_S / A_M | Slave의 ACK / Master의 ACK |
| N_M | Master의 마지막 NACK |
| Cmd / Lo / Hi | Command Code / Low Byte / High Byte |

그림은 정상적으로 ACK되는 경우를 표현한다.
오류·미지원·길이 조건에서는 규격과 장치 정의에 따른 처리가 필요하다.

## 3. 대표 전송을 먼저 읽기

### Write Word

```text
S | AddrW | A_S | Cmd | A_S | Lo | A_S | Hi | A_S | P
```

Master가 주소, 명령, 두 데이터 바이트를 보낸다.
각 바이트의 수신자는 Slave이므로 ACK도 Slave가 보낸다.

### Read Word

```text
S | AddrW | A_S | Cmd | A_S | Sr | AddrR | A_S | Lo | A_M | Hi | N_M | P
```

Master가 읽을 명령을 지정한 뒤 STOP 없이 방향을 바꾼다.
Slave가 Lo/Hi를 보내고, Master가 Lo에 ACK, 마지막 Hi에 NACK한다.
Sr 뒤 주소 바이트가 다시 필요한 이유는 새 방향과 수신 대상을 명시하기 위해서다.

### 값으로 읽기

주소 `0x2A`, 명령 `0x10`, 반환 Word `0x1234`를 가정한다.

```text
S | 0x54 | A_S | 0x10 | A_S | Sr | 0x55 | A_S | 0x34 | A_M | 0x12 | N_M | P
```

주소 자체는 7-bit `0x2A`다.
`0x54/0x55`는 주소와 R/W를 합친 전송 바이트다.
명령 `0x10`의 실제 뜻은 장치 데이터시트에서 정한다.

## 4. 15개 기본 Command Protocol 지도

| Protocol | 데이터와 용도 |
|---|---|
| Quick Command | 데이터 바이트 없이 주소의 R/W 비트로 명령 의미 전달 |
| Send Byte | Command 필드 구분 없이 1바이트 송신 |
| Receive Byte | Command를 먼저 쓰지 않고 1바이트 수신 |
| Write Byte | Cmd 뒤 데이터 1바이트 송신 |
| Read Byte | Cmd 지정 후 Sr로 1바이트 수신 |
| Write Word | Cmd 뒤 2바이트 송신 |
| Read Word | Cmd 지정 후 2바이트 수신 |
| Process Call | Cmd와 Word 송신 후 같은 Transaction에서 Word 응답 |
| Block Write | Cmd, Count, 가변 데이터 송신 |
| Block Read | Cmd 지정 후 Count와 가변 데이터 수신 |
| Block Write–Block Read Process Call | 송신 Block 뒤 Sr로 응답 Block 수신 |
| Write 32 | Cmd 뒤 4바이트 송신 |
| Read 32 | Cmd 지정 후 4바이트 수신 |
| Write 64 | Cmd 뒤 8바이트 송신 |
| Read 64 | Cmd 지정 후 8바이트 수신 |

이 노트의 기준인 3.0 공개 규격 §6.5.7은 Block Read/Write의 Count 0과 최대 255 데이터 바이트를 허용한다.
Block Write–Block Read Process Call은 송신 M, 수신 N에 대해 M ≥ 0, N ≥ 0, M + N ≤ 255다.
2.0 규격이나 특정 드라이버·장치의 32바이트 제한과 섞지 않고 실제 지원 길이를 확인한다.
장치가 이 형식을 모두 지원할 필요는 없다.

### 나머지 형식의 공통 골격

```text
Quick      : S | Addr(R/W) | A_S | P
Send Byte  : S | AddrW | A_S | Byte | A_S | P
Receive    : S | AddrR | A_S | Byte | N_M | P
Write Byte : S | AddrW | A_S | Cmd | A_S | Data | A_S | P
Read Byte  : S | AddrW | A_S | Cmd | A_S | Sr | AddrR | A_S | Data | N_M | P
Process    : S | AddrW | A_S | Cmd | A_S | WLo | A_S | WHi | A_S | Sr | AddrR | A_S | RLo | A_M | RHi | N_M | P
Block Write: S | AddrW | A_S | Cmd | A_S | Count | A_S | D1 | A_S | ... | Dn | A_S | P
Block Read : S | AddrW | A_S | Cmd | A_S | Sr | AddrR | A_S | Count | A_M | D1 | A_M | ... | Dn | N_M | P
```

여기서 `...`은 반복되는 데이터와 응답 구간을 줄여 쓴 것이다.
Block 그림은 데이터가 1바이트 이상인 경우이며, Count 0의 전송은 별도 경계 조건으로 다룬다.
Read 32/64는 Read Byte의 데이터 구간을 각각 4/8바이트로 확장해 이해한다.
중간 바이트에는 Master ACK, 마지막 바이트에는 Master NACK가 온다.
숫자의 바이트 배열과 Command 의미는 규격 및 장치 정의를 함께 확인한다.

## 5. PEC를 붙이면 달라지는 것

[[90_Glossary/Protocol/PEC|PEC]]는 CRC-8 기반 오류 검사용 바이트다.

- 다항식: $x^8+x^2+x+1$ (`0x07`).
- 주소 + R/W를 포함한 **전송 바이트**가 계산에 들어간다.
- START/STOP과 ACK/NACK 자체는 바이트가 아니므로 계산에 넣지 않는다.
- Sr가 있어도 하나의 결합 Transaction 안에서 CRC를 이어 계산한다.
- PEC 바이트 자체는 자신을 만들기 위한 입력에 넣지 않는다.
- 기본적으로 선택 기능이지만 **ARP 과정에서는 필수**다.
- **Quick Command와 Host Notify에는 PEC 형식이 없다.**

```text
Write Word + PEC:
S | AddrW | A_S | Cmd | A_S | Lo | A_S | Hi | A_S | PEC | A_S | P

Read Word + PEC:
S | AddrW | A_S | Cmd | A_S | Sr | AddrR | A_S | Lo | A_M | Hi | A_M | PEC | N_M | P
```

Read에서는 마지막 데이터 Hi 뒤에도 PEC를 더 받아야 하므로 Hi에 ACK한다.
**NACK가 Hi에서 PEC 뒤로 이동**하는 것이 핵심이다.
Read 마지막 PEC의 NACK는 정상 종료이며 PEC 오류 신호 자체가 아니다.
수신 측이 PEC를 계산·비교해야 오류 여부를 알 수 있다.

예시 Read Word의 PEC 입력 순서는 `54 10 55 34 12`다.
초깃값 0, MSB-first, 반사 없음, 최종 XOR 0으로 CRC-8을 계산하면 PEC는 `0x25`이다.

## 6. ACK/NACK는 구간별로 해석

| 상황 | 해석 |
|---|---|
| 자기 주소 수신 | SMBus 장치는 자기 주소에 ACK해야 함 |
| 주소 외 바이트에서 Busy·데이터 준비 안 됨 | 규격의 NACK 또는 허용 시간 내 Clock 연장 조건 확인 |
| 잘못된 명령·데이터 | 규격에 따른 NACK·종료·재시도 처리 |
| Read 마지막 바이트의 Master NACK | 정상적인 읽기 종료 |
| Write PEC 뒤 NACK | 수신 측이 감지한 오류 가능성. PEC 외 원인도 확인 |

주소 ACK만으로 데이터 준비나 명령 실행 완료를 의미하지 않는다.
I2C 장치의 ACK Polling 관행을 SMBus의 주소 응답 규칙에 그대로 옮기지 않는다.

## 7. CLK LOW를 네 가지로 구분

| 종류 | 의미 |
|---|---|
| 정상 Clock LOW | 한 비트의 원래 LOW 구간 |
| Slave Extension | Slave가 처리 시간을 위해 LOW를 연장 |
| Master Extension | Master가 자신의 처리·전송을 위해 LOW를 연장 |
| 동기화 / stuck | 여러 Master의 조합인지, 비정상 고정인지 판별 |

SMBus 3.0의 시간 제약을 구분한다.

| 항목 | 값 | 무엇을 재는가 |
|---|---|---|
| $t_{TIMEOUT}$ | 25~35 ms | 한 번의 연속 Clock LOW에 대한 Timeout 감지 범위 |
| $t_{LOW:SEXT}$ | 최대 25 ms | 한 메시지에서 Slave의 누적 LOW 연장 |
| $t_{LOW:MEXT}$ | 최대 10 ms | 규격이 정의한 각 바이트 구간의 Master 누적 LOW 연장 |
| $t_{HIGH,max}$ | 50 µs | 전송 중 Clock HIGH 최대 시간, Idle 식별과 연결 |

Timeout을 단순한 '전체 Transaction 제한 35 ms'로 해석하지 않는다.
검출 후 통신 상태를 초기화하고 새 START를 수용하는 조건도 포함된다.
주기적인 Stretching의 최소 주파수 조건과 비주기적 처리 지연은 규격 주석을 함께 읽는다.

### Bus Idle

STOP을 관찰한 경우 tBUF 조건으로, 중간 합류 등으로 이전 상태를 모르는 경우에는 규격의 $t_{HIGH,max}$ 조건으로 Idle을 판단할 수 있다.
따라서 I2C와 SMBus의 Idle 판단을 완전히 동일하게 설명하지 않는다.

## 8. 멀티 Master와 같은 주소의 Slave

- 동시 시작한 Master는 실제 CLK으로 동기화하고 DAT의 첫 차이에서 중재한다.
- 같은 주소·같은 데이터라면 뒤 구간까지 중재가 이어질 수 있다.
- Read 데이터는 Slave가 보내므로 Controller 간 차이가 즉시 드러나지 않을 수 있다.
- ACK/NACK나 STOP/Sr가 달라지는 경계는 규격의 중재 범위와 구현 대응을 확인한다.
- 같은 주소의 일반 Slave 여러 개는 ACK만으로 개수를 판별할 수 없다.
- ARP·ARA의 규정된 응답 중재와 일반적인 주소 중복은 서로 다르다.

기본 전기적 설명은 [[30. Notes/Protocol/I2C#7. Arbitration: 처음 다른 비트에서 결정|I2C 중재]]와 연결된다.

## 9. ARP, ARA, Host Notify

| 기능 | 시작 주체·방식 | 목적 |
|---|---|---|
| [[90_Glossary/Protocol/ARP\|ARP]] | ARP Master가 UDID 조회·주소 할당 | 지원 장치 식별과 주소 관리 |
| Alert Response | SMBALERT# 후 Host가 ARA를 Read | 알림을 요청한 장치 식별 |
| Host Notify | 알릴 장치가 Master가 되어 Host에 Write | 자기 주소와 상태 Word 통보 |

### ARP의 큰 흐름

```mermaid
flowchart LR
    A["Prepare to ARP"] --> B["Get UDID"]
    B --> C["응답 중재로 장치 하나 식별"]
    C --> D["UDID를 지정해 Assign Address"]
    D --> B
```

[[90_Glossary/Protocol/UDID|UDID]]는 장치를 식별하는 128-bit 정보이고, 7-bit 통신 주소와 다르다.
지원 장치가 응답 중재를 거쳐 식별된다.
ARP가 지원되지 않는 고정 주소 충돌까지 자동 해결하는 것은 아니다.

### 주요 주소: 모두 7-bit 기준

| 주소 | 용도 |
|---|---|
| 0x08 | SMBus Host |
| 0x0C | Alert Response Address |
| 0x61 | SMBus Device Default Address, ARP |

예약·사전 할당 주소 전체는 규격 Appendix C를 확인한다.
주소를 임의로 배정하기 전에 예약 범위를 확인한다.

### SMBSUS#

선택적인 시스템 Suspend/Resume 관련 신호다.
CLK/DAT의 한 비트가 아니며, 보드의 Suspend 동작·통신 재개 순서는 Appendix B와 시스템 정의를 함께 따른다.

## 10. 복습

1. Read Word에서 주소·명령·데이터마다 송신자와 ACK 주체를 표시한다.
2. PEC 사용 시 마지막 NACK 위치가 바뀌는 이유를 설명한다.
3. 한 번의 긴 Clock LOW와 누적 연장 시간을 구분한다.
4. 같은 주소의 두 Slave와 ARP 응답 중재를 구분한다.
5. Host가 항상 현재 Master는 아닌 이유를 Host Notify로 설명한다.

## 관련 용어

[[90_Glossary/Protocol/Command-Code|Command Code]] · [[90_Glossary/Protocol/Transaction|Transaction]] · [[90_Glossary/Protocol/PEC|PEC]] · [[90_Glossary/Protocol/ARP|ARP]] · [[90_Glossary/Protocol/UDID|UDID]]

## 참고자료

- [SMIF — SMBus 3.0 Specification](https://smbus.org/specs/SMBus_3_0_20141220.pdf): §4.2 시간 조건, §5 ACK·Clock·중재, §6.4 PEC, §6.5 Protocol, §6.6 ARP, Appendix A/B/C.
- [SMBus — 공개 규격 목록](https://www.smbus.org/specs/): 버전 확인용.


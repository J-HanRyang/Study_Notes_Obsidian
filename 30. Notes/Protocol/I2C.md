---
aliases: ["I²C", "아이투씨"]
tags: [study, protocol, i2c]
created: 2026-10-19
---
# I2C

> 두 신호선을 여러 장치가 공유하며, 실제 버스 전압을 관찰해 데이터를 주고받는다.

## 1. 전체 구조

- **SCL:** Clock. Controller가 전송을 시작하고 기본 Clock을 생성한다.
- **SDA:** Address, Data, ACK/NACK가 시간 순서대로 흐르는 선.
- **Controller / Target:** 기존 문서의 Master / Slave에 대응하는 용어.
- **Transmitter / Receiver:** 현재 바이트를 보내는 쪽 / 받는 쪽. Controller가 항상 송신자는 아니다.

이 노트는 기본적인 **7-bit 주소, Standard/Fast/Fast-mode Plus 공유 버스**를 중심으로 다룬다.
10-bit 주소와 Hs/UFm의 세부 동작은 별도 범위다.

```text
VDD ── Rp_SCL ── SCL ── Controller / Target들의 SCL 핀
VDD ── Rp_SDA ── SDA ── Controller / Target들의 SDA 핀

SCL/SDA 각각 풀업 1개가 기본 개념이며,
보드 여러 개의 풀업이 병렬 연결되면 합성 저항을 계산한다.
```

## 2. Open-Drain이 핵심인 이유

[[90_Glossary/Circuit/Open-Drain|Open-Drain]]은 LOW를 직접 만들고, HIGH는 출력을 해제해 풀업에 맡긴다.

| 장치 A | 장치 B | 실제 선 |
|---|---|---|
| 해제 | 해제 | 풀업으로 HIGH |
| LOW | 해제 | LOW |
| 해제 | LOW | LOW |
| LOW | LOW | LOW |

**내가 1을 보내려고 선을 놓아도 실제 버스는 0일 수 있다.**
각 장치는 출력 의도와 별도로 핀의 실제 전압을 관찰한다.
출력 해제와 입력 경로의 활성화가 반드시 번갈아 전환되는 것은 아니다.

[[30. Notes/Circuit/Push-Pull|Push-Pull]]처럼 서로 다른 HIGH/LOW를 강제로 구동하지 않아 공유가 가능하다.
[전기적 구조](https://www.ti.com/lit/an/sbaa565/sbaa565.pdf)

## 3. START, STOP, 데이터

| 조건 | SCL | SDA 변화 |
|---|---|---|
| START: S | HIGH | HIGH → LOW |
| STOP: P | HIGH | LOW → HIGH |
| Repeated START: Sr | HIGH | STOP 없이 다시 START 조건 생성 |
| 일반 데이터 비트 | HIGH인 동안 안정 | LOW 구간에서 다음 비트 준비 |

```text
START            데이터 비트              STOP
SCL: ─────       __/‾‾‾\__               ─────
SDA: ‾‾\__       ---안정---               __/‾‾
```

한 바이트는 MSB부터 8비트이고, 뒤에 9번째 ACK/NACK Clock이 붙는다.
SCL HIGH에서 데이터가 유효하다는 규칙과 내부 수신기가 어느 순간 샘플링하는지는 구분한다.
Setup/Hold와 HIGH/LOW 최소 시간은 모두 만족해야 한다.
[기본 조건과 바이트 형식](https://www.nxp.com/docs/en/user-guide/UM10204.pdf)

## 4. ACK는 누가 보내는가?

**방금 바이트를 받은 Receiver가 9번째 Clock에서 응답한다.**
송신자는 그 Clock에서 SDA를 놓는다.

| 구간 | 바이트 송신 | ACK/NACK 송신 |
|---|---|---|
| 주소 + R/W | Controller | 해당 Target |
| Write 데이터 | Controller | Target |
| Read 데이터 | Target | Controller |

- **ACK:** Receiver가 SDA를 LOW로 구동.
- **NACK:** Receiver가 SDA를 놓아 HIGH로 유지.
- **Read 마지막 NACK:** 더 읽지 않겠다는 정상 종료 표시.
- 주소·Write 데이터의 NACK는 주소 불일치, 준비 상태, 명령·데이터 수용 여부 등을 구분해 해석한다.

ACK는 바이트 수신에 대한 응답이다.
내부 레지스터 갱신 완료나 데이터 전체의 무결성을 모두 보장하지 않는다.
[[90_Glossary/Protocol/ACK-NACK|ACK / NACK]]

## 5. Register 읽기 예시

7-bit 주소 `0x50`, 내부 Register 주소 `0x10`을 선택하고 한 바이트를 읽는 장치를 가정한다.
**Register 주소의 길이와 동작은 장치가 정의하며 I2C 공통 규칙은 아니다.**

```text
S | 0xA0 | A_T | 0x10 | A_T | Sr | 0xA1 | A_T | DATA | N_C | P
    C→T          C→T              C→T          T→C
```

- `0xA0 = (0x50 << 1) | 0`: Write 주소 바이트.
- `0xA1 = (0x50 << 1) | 1`: Read 주소 바이트.
- `A_T`: Target의 ACK, `N_C`: Controller의 NACK.
- 먼저 Write 방향으로 Register를 선택하고 Sr 후 Read 방향으로 바꾼다.
- Sr 뒤에도 주소를 다시 보내 Target과 방향을 지정한다.
- STOP이 없으므로 두 단계 사이에 버스를 놓지 않는다.

마지막 NACK는 STOP 자체가 아니다.
Target이 SDA를 놓은 뒤 Controller는 적절한 LOW 구간을 거쳐 STOP 조건을 만든다.

## 6. Clock Stretching과 Clock 동기화

### Target이 기다리게 하는 경우

Controller가 SCL을 놓았는데 Target이 계속 LOW를 유지하면 실제 SCL은 아직 LOW다.
Controller는 실제 SCL이 HIGH가 된 것을 확인하고 진행해야 한다.
모든 장치·Controller가 Stretching을 지원하는 것은 아니므로 조합을 확인한다.

### 여러 Controller가 동시에 Clock을 만드는 경우

```text
LOW 시작 → 각자 LOW 시간 계산 → 준비된 Controller부터 SCL 해제
         → 모두 해제하면 실제 SCL HIGH
         → 가장 먼저 HIGH 시간을 끝낸 Controller가 다시 LOW
```

결과적으로 LOW는 가장 긴 LOW 시간, HIGH는 가장 짧은 HIGH 시간의 영향을 받는다.
Duty가 50%일 필요는 없지만 타이밍 조건은 지켜야 한다.

[[90_Glossary/Protocol/Clock-Stretching|Stretching]]은 대기 연장이고,
[[90_Glossary/Protocol/Clock-Synchronization|Synchronization]]은 여러 Clock의 정렬이다.
[동기화와 Stretching 설명](https://www.ti.com/video/6243124608001)

## 7. Arbitration: 처음 다른 비트에서 결정

동시에 시작한 Controller들은 SCL이 HIGH일 때 자신이 보낸 비트와 실제 SDA를 비교한다.
**1을 의도했는데 0을 읽은 Controller가 중재에서 패배한다.**

```text
비트 위치       1  2  3  4
Controller A    1  0  1  0
Controller B    1  0  0  1
실제 SDA        1  0  0  ...
                      ↑ A가 패배하고 SDA 구동 중단
```

전체 0의 개수나 단순한 Clock 속도로 승자를 정하지 않는다.
주소가 같으면 데이터 쪽까지 비교가 이어질 수 있다.
같은 내용이 계속되면 해당 구간만으로는 둘을 구분하지 못한다.

패배한 Controller는 승자의 전송을 망치는 STOP을 생성하면 안 된다.
Target 역할도 지원하면 수신 주소에 맞춰 Target으로 응답해야 할 수도 있다.
승자 전송이 끝난 뒤 버스 상태와 tBUF 조건을 만족하면 재시도를 계획한다.
재시도 정책이나 랜덤 Backoff는 상위 구현에서 정한다.

### 동시에 같은 Read를 하면?

데이터 구간에서는 Target이 SDA를 구동한다.
두 Controller의 수신 사실만으로 선에서 차이가 생기지는 않는다.
읽기를 계속할지 결정하는 ACK/NACK 구간이나 다음 제어 동작에서 차이가 생길 수 있다.
STOP·Repeated START와 데이터 비트가 겹치는 조합 등은 정상 중재가 보장하는 범위를 벗어날 수 있다.
**정상 동시 시작 중재와, Busy 중 잘못 끼어드는 동작을 구분한다.**
[[90_Glossary/Protocol/Arbitration|중재의 정의와 예시]]

## 8. Bus Busy와 tBUF

I2C의 기본 상태 판단은 START와 STOP의 이력을 사용한다.
데이터 1을 보내는 도중에도 SCL/SDA가 모두 HIGH일 수 있으므로, HIGH-HIGH만 보고 전송을 시작하지 않는다.

tBUF는 **STOP 뒤 다음 START까지의 최소 Bus Free 시간**이다.

| 모드 | 최대 속도 | tBUF 최솟값 |
|---|---|---|
| Standard | 100 kbit/s | 4.7 µs |
| Fast | 400 kbit/s | 1.3 µs |
| Fast-mode Plus | 1 Mbit/s | 0.5 µs |

4.7 µs를 모든 모드의 Idle 판정 시간으로 일반화하지 않는다.
전원 투입이나 중간 합류로 과거 START를 놓친 경우에는 별도의 초기화·복구 정책도 필요하다.
[[90_Glossary/Protocol/Bus-Busy-and-tBUF|Bus Busy / tBUF]]

## 9. 충돌과 Bus Hang을 구분

| 상황 | 버스에서 보이는 것 | 대응 방향 |
|---|---|---|
| 정상 Arbitration | 송신 의도 1, 실제 0 | 패배자는 구동 중단, 승자 계속 |
| 같은 주소의 Target 여러 개 | ACK만으로 개수 구분 불가 | 주소 변경·Mux 등으로 분리 |
| 여러 Target의 Read 데이터 | 서로 다른 데이터가 LOW 우선으로 섞일 수 있음 | 일반 주소 중복을 자동 중재라고 해석하지 않음 |
| SDA stuck LOW | 데이터 전송 중단 후 SDA 유지 | SCL이 움직일 수 있으면 Bus Clear 시도 |
| SCL stuck LOW | Clock 자체가 상승하지 못함 | 원인 장치 Reset·전원·배선 등을 점검 |
| 비정상 START/STOP | 진행 중인 프레임 구조 손상 | 장치별 오류 처리·상위 재시도 정책 확인 |

SDA stuck LOW에서는 최대 9개의 Clock 펄스로 수신 장치가 바이트·ACK를 빠져나오게 하는 복구를 시도할 수 있다.
각 Clock의 실제 HIGH를 확인하고, 선이 해제되면 STOP 및 정상 상태 복귀를 확인한다.
**9번이면 항상 해결된다는 보장은 없다.**
[[90_Glossary/Protocol/Bus-Recovery|Bus Recovery]]

## 10. 풀업과 데이터 검사

풀업 저항이 작으면 LOW일 때 Sink 전류가 커지고, 크면 상승이 느려진다.
버스 정전용량 $C_b$와 상승 시간 제한을 함께 본다.

$$R_{p,min}=\frac{V_{DD}-V_{OL,max}}{I_{OL}}$$
$$R_{p,max}\approx\frac{t_{r,max}}{0.8473C_b}$$

단순 RC 모델에서 30%→70% 상승 시간을 사용하는 근사다.
병렬 풀업의 합성 저항과 장치별 전류·전압 조건을 확인한다.
[풀업 계산 근거](https://www.ti.com/lit/an/slva689/slva689.pdf)

I2C 기본 바이트 전송에는 공통 CRC가 붙지 않는다.
필요한 데이터 검사는 장치 프로토콜이나 상위 계층에서 추가한다.
[[30. Notes/Protocol/SMBus|SMBus]]는 PEC 같은 관리 규칙을 별도로 정의한다.

## 11. 파형 복습 순서

1. START/STOP과 주소 + R/W를 구분한다.
2. 8비트와 9번째 응답을 나누고 구동 주체를 표시한다.
3. Read 마지막 NACK와 오류 NACK를 구분한다.
4. 긴 LOW가 정상 Clock, Stretching, 동기화, stuck 중 무엇인지 판단한다.
5. 동시 접근 시 최초로 다른 비트와 패배자의 동작을 확인한다.

## 참고자료

- [NXP — UM10204, I2C-bus specification: §3.1, §6](https://www.nxp.com/docs/en/user-guide/UM10204.pdf)
- [TI — A Basic Guide to I2C](https://www.ti.com/lit/an/sbaa565/sbaa565.pdf)
- [TI — Introduction to I2C: Advanced Topics](https://www.ti.com/video/6243124608001)
- [TI — I2C Bus Pull-Up Resistor Calculation](https://www.ti.com/lit/an/slva689/slva689.pdf)


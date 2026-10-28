---
aliases: ["SRAM과 DRAM", "Memory Collision"]
tags: [study, memory, rtl, dv]
---
# SRAM과 DRAM: 구조에서 검증까지

> 메모리 Cell의 차이를 이해한 뒤, 실제 Interface와 Controller 검증으로 연결한다.

## 구조의 차이

| 항목 | SRAM | DRAM |
|---|---|---|
| 대표 Cell | 교차 연결된 인버터와 접근 트랜지스터를 이용한 6T 구조 | 트랜지스터와 커패시터를 이용한 1T1C 구조 |
| 데이터 유지 | 전원이 있는 동안 내부 상태 유지 | 전하가 새므로 Refresh 필요 |
| 일반적 용도 | Cache, SoC 내부 버퍼 등 | 주기억장치 등 |
| 검증 연결 | Read/Write 타이밍, Byte Enable, 같은 주소 동시 접근 | 명령 순서, 타이밍 제약, Refresh |

SRAM의 “Static”은 전원이 없어도 데이터가 남는다는 뜻이 아니다.

## SRAM Interface를 볼 때

`CLK`, `EN/CS`, `WE`, `ADDR`, `WDATA`, `RDATA`가 어떤 Clock Edge에 샘플링되고 언제 결과가 유효한지 확인한다. **Read latency**, Write 반영 시점, Byte Enable 동작은 Memory Macro 또는 RTL 명세에 따라 달라진다.

주소도 반드시 Byte 단위는 아니다. CPU의 Byte Address가 내부 Word Address로 변환되는 경우에는 주소 변환과 Byte Enable을 함께 검증한다.

### Read-During-Write Collision

같은 주소에 Read와 Write가 겹칠 때의 결과는 구현 정책을 먼저 확인한다.

| 흔한 정책 | 읽기 결과 |
|---|---|
| Read-first | 쓰기 전의 값 |
| Write-first | 새로 쓰는 값 |
| No-change | 출력 유지 |

이 표는 가능한 정책의 예다. 실제 DUT가 어느 정책을 지원하는지 확정하지 않은 채 Scoreboard 기대값을 만들지 않는다. 같은 주소/다른 주소, 포트 조합, Byte Enable 조합, 연속 접근을 나눠 본다.

## DRAM Controller를 볼 때

DRAM에서는 Row를 열고(ACTIVATE), 데이터를 읽거나 쓴 뒤, 다음 Row 접근을 위해 PRECHARGE하는 흐름을 이해한다. Controller는 명령 순서와 타이밍 조건을 지켜야 하고, 데이터 유지를 위한 Refresh도 관리한다.

| 용어 | 복습할 뜻 |
|---|---|
| `tRCD` | ACTIVATE에서 READ/WRITE까지 필요한 간격 |
| `tRP` | PRECHARGE에서 다음 ACTIVATE까지 필요한 간격 |
| Refresh | 전하 손실을 보완하기 위한 주기적 동작 |

검증에서는 **너무 빠른 명령을 허용하지 않는지**와 **필요한 명령을 지나치게 늦추지 않는지**를 함께 본다. 정확한 수치와 예외는 사용하는 DRAM 규격과 Controller 명세를 따른다.

## 복습 질문

1. SRAM의 Read 결과는 요청과 몇 Cycle 떨어져 유효한가?
2. 같은 주소에 동시에 Read/Write하면 기대값은 무엇인가?
3. Byte Address와 Word Address를 어떻게 변환하는가?
4. DRAM에서 Refresh가 필요한 이유는 무엇인가?
5. Controller가 타이밍 위반을 어떻게 막는가?

## 학습 출처

- [반도체 데일리 학습 · 오전](https://chatgpt.com/c/6adfccad-0600-83ee-8534-170186c8f541): SRAM/DRAM 구조, DRAM Read·Refresh, SRAM Interface와 DRAM Timing.
- [반도체 데일리 학습 · 오후](https://chatgpt.com/c/6adfe5be-8c04-83e8-bdf1-9082fd2ede8f): Read-During-Write Collision과 UVM Scoreboard 관점.

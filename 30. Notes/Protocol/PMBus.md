---
aliases: ["Power Management Bus", "PMBus 1.5"]
tags: [study, protocol, pmbus, power]
---
# PMBus

> 전력 장치와 데이터를 주고받는 방법에 더해, 명령과 데이터가 전원 제어에서 뜻하는 바를 정의하는 규격.

[[30. Notes/Protocol/I2C|I2C]]의 신호·전송 원리와 [[30. Notes/Protocol/SMBus|SMBus]]의 트랜잭션·오류 처리 규칙을 알고 읽으면 연결하기 쉽다. PMBus Part I은 전송과 인터페이스, Part II는 명령 언어·데이터 형식·Fault 처리를 다룬다. AVSBus는 별도 학습 주제로 둔다.

## 학습 범위

현재 공부한 범위를 찾기 위한 지도다. 아래의 명령별 지원 여부, 데이터 형식, 초기값, 예외 처리는 **사용 중인 PMBus 원문과 대상 장치 명세**로 확인한다.

| 구간 | 공부한 주제 | 이해할 질문 |
|---|---|---|
| Part I | 기본 요구사항, 선택 기능, Group Command, Extended Command, Zone Read/Write/Config/Active | 여러 전력 장치를 어떤 형식과 범위로 제어하는가? |
| Part II 전반 | 메모리 모델, STORE/RESTORE, 수치 데이터 형식 | 받은 값을 어떻게 보관하고 해석하는가? |
| Part II 전압 | 출력 전압 설정과 측정, OPERATION, ON_OFF_CONFIG | 목표 전압과 실제 측정값은 어떻게 구별하는가? |
| Part II 이상 상태 | Warning/Fault, Status Register Map, 전압·전류 Fault, Retry/Delay, CML | 이상을 어떻게 기록·보고하고, 이후 동작을 어떻게 정하는가? |
| Part II 대상 선택 | PAGE/PHASE, CAPABILITY/QUERY | 어느 출력에 명령을 적용하고, 장치 지원 범위를 어떻게 확인하는가? |

Part II의 개별 명령을 모두 외우기보다 **명령 수신 → 값 해석 → 대상 출력에 적용 → 상태 확인**의 흐름으로 연결한다.

## SMBus와 PMBus의 역할

```text
버스에서 비트와 바이트를 전달
    ↓
SMBus 형식에 맞춰 명령 코드와 데이터를 주고받음
    ↓
PMBus 명령 언어로 그 데이터의 전력 관리 의미를 해석
    ↓
대상 장치가 지원하는 기능을 수행하거나 상태를 보고
```

SMBus의 Read Word 형식만으로는 읽은 값이 전압인지 전류인지 정해지지 않는다. PMBus 명령과 장치 명세를 함께 봐야 한다. 
또한 PMBus 명령 코드는 DUT 내부 SFR 주소와 같은 개념이 아니다.

## 전압 명령을 한 흐름으로 읽기

| 항목 | 복습할 역할 |
|---|---|
| `PAGE` | 다중 출력 장치에서 명령의 적용 대상을 선택할 때 사용 |
| `VOUT_MODE` | 출력 전압 관련 데이터의 해석 형식을 확인 |
| `VOUT_COMMAND` | 목표 출력 전압을 설정하는 대표 명령 |
| `OPERATION` / `ON_OFF_CONFIG` | 켜짐·꺼짐 동작과 제어 조건을 이해할 때 연결 |
| `READ_VOUT` | 장치가 보고하는 출력 전압을 읽음 |
| Status 계열 | Warning/Fault 등 이상 상태를 확인 |

예를 들어 `VOUT_COMMAND`를 썼다는 사실만으로 실제 전압이 그 값에 도달했다고 판단하지 않는다. 명령이 수용되었는지, 선택된 PAGE에 반영되었는지, 보고값과 Fault 상태가 어떤지, 실제 출력이 어떻게 바뀌는지를 **검증 단계와 DUT 범위**에 맞춰 구분한다.

## Warning, Fault, Status

- **Warning:** 허용 범위에 가까워지는 등의 상태를 알리는 조건. 구체적인 임계값과 후속 동작은 해당 명령과 장치 명세를 확인한다.
- **Fault:** 보호 동작이나 재시도 정책으로 이어질 수 있는 이상 조건. 원인, 상태 비트, 알림, 출력 동작을 따로 본다.
- **Status:** 발생한 조건을 호스트가 읽을 수 있도록 보고하는 정보. 어떤 비트가 세트되고 언제 해제되는지는 규격과 장치 정의에 따른다.
- **CML:** 통신·명령·데이터 처리 관련 이상을 볼 때 확인하는 상태 영역.

복습 순서: **조건 발생 → Warning/Fault 판정 → Status 기록·알림 → 출력 동작 → Clear/Retry**. `STATUS_WORD` 같은 상위 상태와 세부 상태 레지스터의 관계를 같이 확인한다.

## DV에서 무엇을 검증할까?

PMBus를 받는 디지털 로직이 DUT라면, UVM 환경에서 명령을 보내고 다음을 확인할 수 있다.

1. 트랜잭션과 명령 코드가 올바르게 해석되는가?
2. `PAGE` 등으로 지정한 대상의 설정값이 바뀌는가?
3. Readback 값과 Status가 명세에 맞는가?
4. 잘못된 값이나 미지원 명령을 명세대로 처리하는가?
5. 디지털 전압 제어 요청이 내부 인터페이스로 올바르게 전달되는가?

아날로그 전력단이 RTL에 없으면 모델이나 디지털 인터페이스로 **검증 가능한 부분**을 정한다. 실제 칩에서 출력 전압·과도 응답까지 측정하는 Silicon Validation과 확인 대상이 다르다. VIP가 트랜잭션을 만들고 관찰할 수 있어도, 기대 결과는 **DUT의 설계·레지스터 명세**에서 가져와야 한다.

## 남은 확인 사항

- 현재 읽는 PMBus 원문의 정확한 개정판과 Part별 절 번호.
- `VOUT_COMMAND`와 내부 SFR의 연결, Readback 경로, 아날로그 모델의 경계.
- PAGE/PHASE 적용 범위와 각 명령의 지원·접근 속성.
- Warning/Fault 후 상태 유지, Clear, Retry/Delay의 대상 장치별 동작.
- AVSBus는 공부한 뒤 별도 노트로 정리한다.

## 관련 노트

[[30. Notes/Protocol/SMBus|SMBus]] · [[30. Notes/Protocol/I2C|I2C]] · [[30. Notes/Power/PSI-and-FAULT|PSI와 FAULT]]

## 참고자료

- [PMBus 공식 FAQ](https://pmbus.org/resources/faq/): Part별 역할, 전송과 명령의 구분, 대표 명령의 목적.
- [PMBus 공식 규격 안내](https://pmbus.org/current-specifications/): 개정판과 원문 확보 방법. 이 노트는 비공개 원문의 명령별 세부 규칙을 검증한 자료가 아니다.
- [PMBus 학습 대화 1](https://chatgpt.com/c/6ad8734a-1928-83e8-b793-e5d82f073a13), [PMBus 학습 대화 2](https://chatgpt.com/c/6ae1a233-f894-83ee-b051-c78e566aa359): 실제 공부 범위와 DV 질문.

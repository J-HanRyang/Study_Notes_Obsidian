# Sync FIFO

동일 클럭 도메인에서 생산자/소비자 간 속도 차이를 완충하는 동기 FIFO 설계 및 검증.

---

## 개념

### 왜 필요한가

- 생산자와 소비자가 같은 클럭을 쓰더라도 매 사이클마다 읽고 쓰는 게 보장되지 않는다.
- 이 속도 차이를 완충하는 버퍼가 Sync FIFO다.
- 클럭 도메인이 다른 경우는 Async FIFO가 담당한다.

### 내부 구조

| 요소 | 역할 |
|------|------|
| 메모리 배열 | 실제 데이터 저장 (depth x width) |
| wr_ptr | 다음에 쓸 위치 |
| rd_ptr | 다음에 읽을 위치 |

### **Full / Empty 판별:** Extra bit 방식

- 포인터를 주소 비트보다 1비트 넓게 선언한다. (depth=4면 주소 2비트, 포인터 3비트)

| 조건 | 상태 |
|------|------|
| MSB 다르고 나머지 같음 | Full |
| 전체 비트 같음 | Empty |

- 1칸 낭비 방식과 달리 선언한 depth를 전부 사용할 수 있다. depth=2처럼 작은 FIFO에서 특히 유리하다.

### 동시 읽기/쓰기

| 상태 | 처리 |
|------|------|
| Empty | 쓰기만 실행 |
| Full | 읽기만 실행 |
| 그 외 | 둘 다 실행, wr_ptr/rd_ptr 동시 증가, 용량 변화 없음 |

---

## 설계 결정

**Registered Read**
- rdata를 always_ff에서 드라이브한다. 조합 경로를 차단해 타이밍 여유를 확보하는 대신 1사이클 레이턴시가 발생한다.

**localparam PTR_WIDTH**
- PTR_WIDTH는 FIFO_DEPTH로부터 내부적으로 계산되는 값이므로 외부 오버라이드를 막기 위해 localparam으로 선언한다.

**assign으로 full/empty**
- Icarus Verilog에서 always_comb 내 비트 슬라이싱 미지원 문제로 assign을 사용한다. 동작은 동일하다.

---

## 검증 결과

C 레퍼런스 모델 출력과 RTL TB 출력 완전 일치.

```
WRITE: data=10, wr_ptr=1, rd_ptr=0, full=0, empty=0
WRITE: data=20, wr_ptr=2, rd_ptr=0, full=0, empty=0
WRITE: data=30, wr_ptr=3, rd_ptr=0, full=0, empty=0
WRITE: data=40, wr_ptr=4, rd_ptr=0, full=1, empty=0
WRITE FAIL (full): data=50
READ:  data=10, wr_ptr=4, rd_ptr=1, full=0, empty=0
READ:  data=20, wr_ptr=4, rd_ptr=2, full=0, empty=0
READ:  data=30, wr_ptr=4, rd_ptr=3, full=0, empty=0
READ:  data=40, wr_ptr=4, rd_ptr=4, full=0, empty=1
READ FAIL (empty)
```

---

## 개선 예정

- C 모델 랜덤 입력 + stimulus.txt 자동 생성
- TB에서 stimulus.txt 읽어 RTL 구동
- golden_output.txt vs rtl_output.txt 자동 비교 (PASS/FAIL)

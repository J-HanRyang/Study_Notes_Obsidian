# 목차
- [[#Step 1: 개념 | Step 1: 개념]]
- [[#Step 2: RTL | Step 2: RTL]]
- [[#Step 3: C모델| Step 3: C모델 ]]
- [[#Step 4 TB| Step 4: TB]]
- [[#관련 문서| 관련 문서]]

---

# Step 1: 개념

## 개념 핵심 요약

- **왜 필요한가**:
	- 생산자와 소비자가 서로 다른 클럭 도메인을 사용할 때 데이터를 안전하게 전달해야 한다.
	- 클럭이 다른 도메인 간에 신호를 그냥 넘기면 메타스태빌리티가 발생할 수 있다.
	- 이를 해결하기 위해 쓰기/읽기가 각자의 클럭으로 독립 동작하는 Async FIFO가 필요하다.
- **Sync FIFO와의 차이**:
	- 클럭이 1개(공통) vs 2개(wr_clk, rd_clk).
	- 포인터도 바이너리 그대로 쓰는 대신 그레이 코드로 변환해서 클럭 도메인을 넘긴다.

## 내부 구조

1. **메모리 배열**: 실제 데이터를 저장하는 레지스터 (depth × width), wr_clk 도메인에서 쓰기
2. **wr_ptr**: wr_clk 도메인의 바이너리 쓰기 포인터
3. **rd_ptr**: rd_clk 도메인의 바이너리 읽기 포인터
4. **그레이 코드 변환기**: 포인터를 도메인 경계에서 안전하게 넘기기 위해 binary → gray 변환
5. **2-stage FF synchronizer**: 다른 클럭 도메인의 그레이 포인터를 동기화

## 메타스태빌리티와 2-stage Synchronizer

- 클럭 도메인이 다른 신호를 그냥 샘플링하면 플립플롭이 0도 1도 아닌 불안정한 전압 상태로 빠질 수 있다. 이를 메타스태빌리티라고 한다.

- 2-stage FF synchronizer는 메타스태빌리티를 **완전히 제거하지 않는다.**
- 첫 번째 FF에서 해소될 시간을 한 클럭 더 줘서 두 번째 FF에 도달할 때 안정된 값이 될 확률을 극적으로 높이는 것이다. 
- MTBF(Mean Time Between Failures)를 시스템 수명보다 충분히 길게 만드는 방식으로 안전성을 확보한다.

## 왜 그레이 코드를 쓰는가

#### 바이너리 포인터는 값이 바뀔 때 **여러 비트가 동시**에 변한다.

```
3 = 011
4 = 100  ← 3비트 동시 변화
```

- 클럭 도메인 경계에서 3비트가 동시에 샘플링된다는 보장이 없다.
- 중간 깨진 값이 잠깐 보일 수 있다.

#### 그레이 코드는 인접한 값 사이에 **1비트만** 바뀐다.

```
3 = 010
4 = 110  ← 1비트만 변화
```

- 1비트만 바뀌기 때문에 샘플링 타이밍이 조금 어긋나도 이전 값 아니면 다음 값만 보인다.
- 중간에 깨진 값이 생기지 않는다.

## Full / Empty 판별

- 포인터는 extra bit 방식 유지 (depth=4면 주소 2비트, 포인터 3비트).
- 단, 비교는 **그레이 코드 포인터**로 수행한다.

| 판별 | 조건 | 비교 도메인 |
|------|------|------------|
| Empty | wr_ptr_gray_sync == rd_ptr_gray | rd_clk |
| Full | 상위 2비트 반전, 나머지 일치 | wr_clk |

- **Empty가 전체 비트 일치인 이유**: 그레이 코드도 포인터가 완전히 같으면 같은 위치이므로 Sync FIFO와 동일한 논리가 성립한다.
- **Full이 상위 2비트 반전인 이유**: 바이너리에서 MSB 1비트 반전이 "절반 바퀴 차이"를 의미한다. 그레이 코드로 변환하면 그 절반 바퀴 차이가 상위 2비트 반전 + 나머지 비트 일치로 대응된다. 직접 4비트 그레이 코드를 나열해보면 확인할 수 있다.

```
0000  1100
0001  1101
0011  1111
0010  1110
0110  1010
0111  1011
0101  1001
0100  1000
```

## 동기화 흐름 요약

```
wr_clk 도메인                            rd_clk 도메인
─────────────────────                    ─────────────────────
wr_ptr (binary)                          rd_ptr (binary)
    │ binary→gray                            │ binary→gray
    ▼                                        ▼
wr_ptr_gray ──→ [2-stage sync] ──────→ wr_ptr_gray_sync
                                             │
                                         empty 판별
                                         (wr_ptr_gray_sync == rd_ptr_gray)

rd_ptr_gray ←── [2-stage sync] ←──── rd_ptr_gray
    │
full 판별
(상위 2비트 반전, 나머지 일치)
```

## 설계 결정 포인트

**Q. 왜 그레이 코드 포인터를 도메인 경계에서 넘기는가?**
- 바이너리는 여러 비트가 동시에 바뀌어 중간 깨진 값이 생긴다.
- 그레이 코드는 1비트만 바뀌어 샘플링 타이밍이 어긋나도 이전/다음 값만 보인다.

**Q. Full 판별을 wr_clk 도메인에서 하는 이유는?**
- Full이 되면 wr_en을 막아야 하는 주체가 쓰기 쪽이기 때문이다.
- rd_ptr_gray를 wr_clk 도메인으로 동기화해서 wr_ptr_gray와 비교한다.

**Q. Empty 판별을 rd_clk 도메인에서 하는 이유는?**
- Empty이면 rd_en을 막아야 하는 주체가 읽기 쪽이기 때문이다.
- wr_ptr_gray를 rd_clk 도메인으로 동기화해서 rd_ptr_gray와 비교한다.

**Q. 동기화된 포인터는 실제보다 약간 오래된 값이다. 문제없는가?**
- **Full 판별:** 
	- rd_ptr_gray_sync가 실제보다 오래됐다면 실제로는 공간이 있는데 full로 판단할 수 있다.
	- 데이터 유실 없이 쓰기를 잠깐 막는 것이므로 안전하다.
- **Empty 판별:**
	- wr_ptr_gray_sync가 오래됐다면 실제로는 데이터가 있는데 empty로 판단할 수 있다.
	- 읽기를 잠깐 막는 것이므로 안전하다.

---

# Step 2: RTL

## 설계 결정 사항

- **바이너리 포인터 별도 유지**:
	- 메모리 주소 접근은 바이너리 포인터로, 도메인 경계를 넘길 때만 그레이 코드로 변환.
	- 그레이 코드는 순서가 보장되지 않아 주소로 직접 쓸 수 없다.
- **gray = binary ^ (binary >> 1)**:
	- 표준 바이너리 -> 그레이 변환 공식.
	- 다음 포인터 값에 바로 적용해서 1사이클 안에 갱신.
- **2-stage synchronizer**:
	- 각 도메인에 상대 포인터를 2단 FF로 동기화.
	- 메타스태빌리티 해소 시간 확보.
- **Full/Empty를 assign으로**:
	- 조합 논리이므로 assign 사용.
	- Icarus 호환성 문제도 회피.
- **리셋 분리**:
	- wr_clk/rd_clk 도메인이 독립적이므로 rst_n_wr, rst_n_rd를 각각 별도로 사용.
- **Combinational Read :
	- registered read는 레이턴시 1사이클 발생.
	- assign으로 바꾸면 rd_ptr 기준으로 즉시 출력되어 TB 타이밍 문제도 사라진다.

## 구현 코드

- [[async_fifo.sv]]

### 2-stagg Synchronizer 추가

``` systemverilog
    always_ff @(posedge clk_rd, negedge rst_n_rd) begin
        if (!rst_n_rd) begin
            wr_ptr_gray_sync_0 <= 0;
            wr_ptr_gray_sync_1 <= 0;
        end else begin
            wr_ptr_gray_sync_0 <= wr_ptr_gray;
            wr_ptr_gray_sync_1 <= wr_ptr_gray_sync_0;
        end
    end

    always_ff @(posedge clk_wr, negedge rst_n_wr) begin
        if (!rst_n_wr) begin
            rd_ptr_gray_sync_0 <= 0;
            rd_ptr_gray_sync_1 <= 0;
        end else begin
            rd_ptr_gray_sync_0 <= rd_ptr_gray;
            rd_ptr_gray_sync_1 <= rd_ptr_gray_sync_0;
        end
    end
```

---

# Step 3: C모델

## 설계 결정 사항

- **struct에서 sync 신호 제외**:
	- C 모델에는 클럭 도메인이 없으므로 2-stage sync 지연을 모델링할 수 없다.
	- 그레이 포인터를 바로 비교하는 것으로 충분하다.
- **포인터 마스크**:
	- Extra bit 포함 유지 -> & ((1 << (PTR_WIDTH + 1)) - 1)
- **full 판별 마스크**:
	- 상위 2비트 반전 -> ^ (3 << (PTR_WIDTH - 1))
- **prev_full로 WAIT 삽입**:
	- full 상태에서 read 후 write가 바로 들어오면 RTL은 sync 지연 때문에 full이 아직 안 꺼진 상태.
	- prev_full && !cur_full 조건으로 full 해제 직후를 감지해서 WAIT를 stimulus에 삽입한다.
- **WAIT는 full 전환 시에만 삽입**:
	- empty 상태에서 read가 들어와도 데이터 유실은 없으므로 WAIT 불필요.
	- full일 때 write가 들어오면 데이터를 덮어씌우는 문제가 생기므로 full 해제 후 write 전에만 WAIT를 넣는다.

### 구현 코드

- [[async_fifo.c]]

```c
int prev_full = 0;

// 반복문 내부
	// Full감지 -> READ이후 WAIT
	int cur_full = fifo_full(&fifo);

	if ((prev_full && !cur_full))
	{
		fprintf(fp, "WAIT\n");
	}

	prev_full = fifo_full(&fifo);
```

---

# Step 4: TB
## 설계 결정 사항 (Why 포함)

- **검증 범위**:
	- full/empty 신호는 2-stage sync 지연 때문에 C 모델과 1:1 타이밍 일치가 불가능하다.
	- 검증 대상은 **READ 데이터 무결성과 순서**로 한정한다.
- **FAIL 라인 비교 제외**:
	- empty일 때 read, full일 때 write는 FAIL을 출력하지만 비교에서 제외한다.
	- empty read는 데이터 문제가 없고, full write는 WAIT로 사전에 막는다.
- **out-of-order 허용 안 함**:
	- full 상태에서 write가 들어오면 뒤로 미루지 않고 그 자리에서 FAIL 처리.
	- 순서를 바꾸면 실제 시스템 동작과 달라지기 때문이다.
- **WAIT 처리**:
	- TB에서 WAIT 커맨드를 만나면 negedge full까지 대기 후 clk_wr 한 사이클 여유를 준다.
	- full 해제를 RTL 타이밍 기준으로 기다리는 것이다.
- **타임스탬프 기록**:
	- dut_output.txt에 @ 타임스탬프를 함께 저장해서 FAIL 발생 시 GTKWave에서 해당 시점을 바로 찾을 수 있다.

## 구현 코드

- [[tb_async_fifo.sv]]

```systemverilog
while (!$feof(
	fd_in
)) begin
	// 파일에서 한 줄 읽기
	$fscanf(fd_in, "%s %d\n", cmd, data);

	if (cmd == "WRITE") begin
		// Task를 활용하여 clk_wr 도메인으로 안전하게 인가
		fifo_write(data);
	end else if (cmd == "READ") begin
		// Task를 활용하여 clk_rd 도메인으로 안전하게 인가
		fifo_read();
	end else if (cmd == "WAIT") begin
		@(negedge full);
		@(posedge clk_wr);
	end
end
```

## 검증 결과

C 모델 golden과 RTL dut 출력 READ 데이터 완전 일치.

![[Full 수정 후 waveform.png|800]]

![[Full 수정 후 scoreboard.png|500]]

---

# 관련 문서

- [[async_fifo.sv]]
- [[async_fifo.c]]
- [[tb_async_fifo.sv]]
- [[compare.c]]
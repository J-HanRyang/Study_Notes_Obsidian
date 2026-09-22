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
	- 같은 클럭을 쓰더라도 생산자(Producer)와 소비자(Consumer)의 처리 속도가 다를 수 있다.
	- 매 사이클마다 쓰고 읽는 게 보장되지 않을 때, 데이터를 잠깐 쌓아두는 버퍼가 필요하다.
	- 이게 Sync FIFO다. (※ 클럭이 다른 도메인 간 통신은 Async FIFO)
- **Sync의 의미**: 
	- 읽기/쓰기가 동일한 클럭 도메인에서 동작한다.

## 내부 구조

1. **메모리 배열**: 실제 데이터를 저장하는 레지스터 (depth × width)
2. **wr_ptr (write pointer)**: 다음에 쓸 위치를 가리킴
3. **rd_ptr (read pointer)**: 다음에 읽을 위치를 가리킴

## Full / Empty 판별 — Extra bit 방식

- 포인터를 실제 주소 비트보다 1비트 더 넓게 선언한다.
- 예: depth=8이면 주소는 3비트, 포인터는 4비트

| 조건                  | 상태        |
| ------------------- | --------- |
| MSB가 다르고 나머지 비트가 같다 | **Full**  |
| 전체 비트가 모두 같다        | **Empty** |
→ depth 전체를 낭비 없이 사용할 수 있다. (1칸 낭비 방식과의 차이)

## 설계 결정 포인트

**Q. 왜 Extra bit 방식을 선택하는가?**
- 1칸 낭비 방식은 depth=2처럼 작은 FIFO에서 실제 용량이 절반이 되는 문제가 있다.
- Extra bit 방식은 선언한 depth를 전부 사용할 수 있고, Full/Empty 판별 로직도 명확하다.
- 포인터가 1비트 넓어지는 비용은 감수할 만하다.

**Q. 쓰기/읽기는 언제 실제로 실행되는가?**

| 신호        | 실행 조건                  |
| --------- | ---------------------- |
| **wr_en** | **full == 0** 일 때만 유효  |
| **rd_en** | **empty == 0** 일 때만 유효 |

**Q. 동시에 wr_en + rd_en이 들어오면?**

| FIFO 상태   | 처리                                       |
| --------- | ---------------------------------------- |
| **empty** | 쓰기만 실행 (읽기 무효)                           |
| **full**  | 읽기만 실행 (쓰기 무효)                           |
| 그 외       | 둘 다 실행 → wr_ptr, rd_ptr 동시 증가 → 용량 변화 없음 |

---

# Step 2: RTL

## 설계 결정 사항

- **Registered Read 선택**: 
	- **rdata**를 **always_ff**에서 드라이브
	- 조합 경로 노출을 막아 타이밍 여유 확보
	- 대신 1사이클 레이턴시 발생
- **Extra bit 방식**:
	- depth 전체 사용 가능
	- Full/Empty 판별 명확
- **localparam vs parameter :**
	- **PTR_WIDTH**는 외부에서 오버라이드 불가해야 하므로 localparam 사용.
- **logic 통일**: 
	- SV에서 **reg/wire** 구분 없이 **logic으로 통일**
	- 합성 결과 동일, 의도 명확.
- **assign으로 full/empty:** 
	- Icarus에서 **always_comb** 비트 슬라이싱 미지원 문제로 assign 사용. 동작 동일.

## 구현 코드

- [[sync_fifo.sv]]

```systemverilog
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            rdata  <= 0;
        end else begin
            if (wr_en && !full) begin
                fifo_mem[wr_ptr[PTR_WIDTH-1:0]] <= wdata;
                wr_ptr <= wr_ptr + 1;
            end
            if (rd_en && !empty) begin
                rdata  <= fifo_mem[rd_ptr[PTR_WIDTH-1:0]];
                rd_ptr <= rd_ptr + 1;
            end
        end
    end

    assign empty = (wr_ptr == rd_ptr);
    assign full  = (wr_ptr == {~rd_ptr[PTR_WIDTH], rd_ptr[PTR_WIDTH-1:0]});

endmodule
```

---

# Step 3: C모델

## 설계 결정 사항

- **struct로 내부 상태 묶기**:
	- **fifo_mem**, **wr_ptr**, rd_ptr을 하나의 **sync_fifo_t**로 관리
	- RTL 내부 신호와 1:1 대응
- **포인터로 struct 전달**: 
	- 함수에서 원본 수정이 필요하므로 sync_fifo_t \*f로 전달
- **full/empty는 struct에 저장 안 함**: RTL처럼 포인터 비교로 그때그때 계산.
- **포인터 마스크**: 
	- Extra bit 포함 유지 ->  ((1 << (PTR_WIDTH + 1)) - 1)

## 구현 코드

- [[sync_fifo.c]]

```c
typedef struct {
    uint32_t mem[FIFO_DEPTH];
    uint32_t wr_ptr;
    uint32_t rd_ptr;
} sync_fifo_t;

int fifo_full(sync_fifo_t *f) {
    return (f->wr_ptr == (f->rd_ptr ^ (1 << PTR_WIDTH)));
}

int fifo_empty(sync_fifo_t *f) {
    return (f->wr_ptr == f->rd_ptr);
}

void fifo_write(sync_fifo_t *f, uint32_t wdata) {
    if (!fifo_full(f)) {
        f->mem[f->wr_ptr & (FIFO_DEPTH - 1)] = wdata;
        f->wr_ptr = (f->wr_ptr + 1) & ((1 << (PTR_WIDTH + 1)) - 1);
        printf("WRITE: data=%u, wr_ptr=%u, rd_ptr=%u, full=%d, empty=%d\n",
               wdata, f->wr_ptr, f->rd_ptr, fifo_full(f), fifo_empty(f));
    } else {
        printf("WRITE FAIL (full): data=%u\n", wdata);
    }
}

void fifo_read(sync_fifo_t *f) {
    if (!fifo_empty(f)) {
        uint32_t rdata = f->mem[f->rd_ptr & (FIFO_DEPTH - 1)];
        printf("READ: data=%u, wr_ptr=%u, rd_ptr=%u, full=%d, empty=%d\n",
               rdata, f->wr_ptr, f->rd_ptr, fifo_full(f), fifo_empty(f));
        f->rd_ptr = (f->rd_ptr + 1) & ((1 << (PTR_WIDTH + 1)) - 1);
    } else {
        printf("READ FAIL (empty)\n");
    }
}
```

---

# Step 4: TB

## ## 구현 코드
- [[tb_sync_fifo.sv]]

## 검증 결과

- C 모델 출력과 RTL TB 출력 일치 
- golden 비교는 현재 눈으로 확인 (자동화는 추후 개선 예정)

```
WRITE: data=10, wr_ptr=1, rd_ptr=0, full=0, empty=0
WRITE: data=20, wr_ptr=2, rd_ptr=0, full=0, empty=0
WRITE: data=30, wr_ptr=3, rd_ptr=0, full=0, empty=0
WRITE: data=40, wr_ptr=4, rd_ptr=0, full=1, empty=0
WRITE FAIL (full): data=50
READ: data=10, wr_ptr=4, rd_ptr=1, full=0, empty=0
READ: data=20, wr_ptr=4, rd_ptr=2, full=0, empty=0
READ: data=30, wr_ptr=4, rd_ptr=3, full=0, empty=0
READ: data=40, wr_ptr=4, rd_ptr=4, full=0, empty=1
READ FAIL (empty)
```

## 발견한 버그

- task 안에 full/empty 조건 없으면 FAIL 케이스도 정상 동작처럼 출력됨 -> task 안에 조건 추가로 해결

## 개선 예정

- C 모델에서 랜덤 입력 + stimulus.txt 생성
- TB에서 stimulus.txt 읽어 RTL 구동
- rtl_output.txt vs golden_output.txt 자동 비교 → PASS/FAIL 출력

---

# 관련 문서

- [[sync_fifo.sv]]
- [[sync_fifo.c]]
- [[tb_sync_fifo.sv]]
# AXI4-Lite Slave 설계 세션 정리

> **목표**: AXI4-Lite Slave 블록의 마이크로 아키텍처 설계 → FSM 구현 → RTL 코드 완성  
> **레벨**: Level 1 (Scaffolding 모드)  
> **날짜**: 2026-04-13

---

## 1. Block Interface

### 1-1. 채널 구조 개요

| 트랜잭션 | 관여 채널 | 방향 |
|---|---|---|
| **Write** | AW (주소) + W (데이터) + B (응답) | Master → Slave → Master |
| **Read** | AR (주소) + R (데이터+응답) | Master → Slave → Master |

> ⚠️ Write는 AW와 W가 **독립 채널**이라 순서가 보장되지 않음  
> ⚠️ Read는 AR 하나만 받으면 되므로 Write보다 구조가 단순함

---

### 1-2. 포트 목록 (전체)

| Channel | 신호 | 방향 | 구동 주체 | 비고 |
|---|---|---|---|---|
| AW | `AWADDR` | →Slave | Master | Write 목적지 주소 |
| AW | `AWVALID` | →Slave | Master | 주소 유효 |
| AW | `AWREADY` | Slave→ | **Slave** | 주소 수락 준비 |
| W | `WDATA` | →Slave | Master | Write 데이터 |
| W | `WSTRB` | →Slave | Master | Byte enable |
| W | `WVALID` | →Slave | Master | 데이터 유효 |
| W | `WREADY` | Slave→ | **Slave** | 데이터 수락 준비 |
| B | `BRESP` | Slave→ | **Slave** | Write 응답 코드 |
| B | `BVALID` | Slave→ | **Slave** | 응답 유효 |
| B | `BREADY` | →Slave | Master | 응답 수락 준비 |
| AR | `ARADDR` | →Slave | Master | Read 목적지 주소 |
| AR | `ARVALID` | →Slave | Master | 주소 유효 |
| AR | `ARREADY` | Slave→ | **Slave** | 주소 수락 준비 |
| R | `RDATA` | Slave→ | **Slave** | Read 데이터 |
| R | `RRESP` | Slave→ | **Slave** | Read 응답 코드 |
| R | `RVALID` | Slave→ | **Slave** | 데이터 유효 |
| R | `RREADY` | →Slave | Master | 데이터 수락 준비 |

---

### 1-3. 응답 코드 (BRESP / RRESP)

| 값 | 이름 | 의미 |
|---|---|---|
| `2'b00` | OKAY | 정상 완료 |
| `2'b01` | EXOKAY | Exclusive 접근 성공 |
| `2'b10` | SLVERR | Slave 에러 (예: 없는 주소 접근) |
| `2'b11` | DECERR | 주소 디코딩 에러 |

---

## 2. AXI4 핸드쉐이크 핵심 규칙

```
핸드쉐이크 완료 = VALID & READY 가 동시에 1인 사이클
```

- `VALID`는 **송신측**이 올림 (Master 또는 Slave)
- `READY`는 **수신측**이 올림
- 둘 중 하나라도 0이면 핸드쉐이크 미완료 → 데이터 전송 안 됨

---

## 3. FSM 구조

### 3-1. Write FSM

```
              ┌─(AW+W 동시)────────────────────────────┐
              │                                         ↓
WR_IDLE ──(awvalid & awready)──→ WR_AW               WR_RESP ──(bvalid & bready)──→ WR_IDLE
        ──(wvalid  & wready) ──→ WR_W  ──(aw_done & w_done)──↗
```

| State | 역할 | 주요 Output |
|---|---|---|
| `WR_IDLE` | 초기 대기, 새 트랜잭션 수락 준비 | `awready=1`, `wready=1` |
| `WR_AW` | AW 수신 완료, W 대기 중 | `wready=1` |
| `WR_W` | W 수신 완료, AW 대기 중 | `awready=1` |
| `WR_RESP` | Write 실행 + B채널 응답 | `bvalid=1`, `bresp=2'b00` |

| Transition | 조건 |
|---|---|
| `WR_IDLE → WR_AW` | `awvalid & awready` (W는 아직) |
| `WR_IDLE → WR_W` | `wvalid & wready` (AW는 아직) |
| `WR_IDLE → WR_RESP` | `awvalid & awready && wvalid & wready` (동시) |
| `WR_AW → WR_RESP` | `aw_done & w_done` |
| `WR_W → WR_RESP` | `aw_done & w_done` |
| `WR_RESP → WR_IDLE` | `bvalid & bready` |

**내부 플래그**

| 플래그 | 의미 | Set 조건 | Clear 조건 |
|---|---|---|---|
| `aw_done` | AWADDR 수신 완료 | AW 핸드쉐이크 완료 시 | `WR_RESP → WR_IDLE` 시 |
| `w_done` | WDATA 수신 완료 | W 핸드쉐이크 완료 시 | `WR_RESP → WR_IDLE` 시 |

---

### 3-2. Read FSM

```
RD_IDLE ──(arvalid & arready)──→ RD_DATA_FETCH ──(1사이클)──→ RD_RESP ──(rvalid & rready)──→ RD_IDLE
```

| State | 역할 | 주요 Output |
|---|---|---|
| `RD_IDLE` | 초기 대기, AR 수락 준비 | `arready=1` |
| `RD_DATA_FETCH` | 레지스터에서 데이터 읽기 (1사이클 대기) | 없음 |
| `RD_RESP` | R채널로 데이터+응답 전송 | `rvalid=1`, `rdata`, `rresp=2'b00` |

| Transition | 조건 |
|---|---|
| `RD_IDLE → RD_DATA_FETCH` | `arvalid & arready` |
| `RD_DATA_FETCH → RD_RESP` | 무조건 (1사이클 후) |
| `RD_RESP → RD_IDLE` | `rvalid & rready` |

> 💡 `RD_DATA_FETCH` 가 필요한 이유: 레지스터/메모리에서 데이터를 읽는 데 **Read Latency**가 존재하기 때문. 이 State 없이 바로 RESP로 가면 쓰레기값이 전송될 수 있음.

---

## 4. 최종 RTL 코드 (SystemVerilog)

```systemverilog
module axi4_lite_slave #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    input  logic                    clk,
    input  logic                    rst_n,

    // AW Channel
    input  logic [ADDR_WIDTH-1:0]   awaddr,
    input  logic                    awvalid,
    output logic                    awready,

    // W Channel
    input  logic [DATA_WIDTH-1:0]   wdata,
    input  logic [DATA_WIDTH/8-1:0] wstrb,
    input  logic                    wvalid,
    output logic                    wready,

    // B Channel
    output logic [1:0]              bresp,
    output logic                    bvalid,
    input  logic                    bready,

    // AR Channel
    input  logic [ADDR_WIDTH-1:0]   araddr,
    input  logic                    arvalid,
    output logic                    arready,

    // R Channel
    output logic [DATA_WIDTH-1:0]   rdata,
    output logic [1:0]              rresp,
    output logic                    rvalid,
    input  logic                    rready
);

// ================================
// State 선언
// ================================
typedef enum logic [1:0] {
    WR_IDLE = 2'b00,
    WR_AW   = 2'b01,
    WR_W    = 2'b10,
    WR_RESP = 2'b11
} wr_state_t;

typedef enum logic [1:0] {
    RD_IDLE       = 2'b00,
    RD_DATA_FETCH = 2'b01,
    RD_RESP       = 2'b10
} rd_state_t;

wr_state_t wr_state;
rd_state_t rd_state;

logic aw_done, w_done;
logic [DATA_WIDTH-1:0] reg_file [0:3];

// ================================
// Write FSM (State 전이)
// ================================
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wr_state <= WR_IDLE;
        aw_done  <= 1'b0;
        w_done   <= 1'b0;
    end else begin
        case (wr_state)
            WR_IDLE: begin
                if (awvalid & awready && wvalid & wready) begin
                    // AW + W 동시 진입 → 바로 RESP
                    wr_state <= WR_RESP;
                    aw_done  <= 1'b1;
                    w_done   <= 1'b1;
                end else if (awvalid & awready) begin
                    wr_state <= WR_AW;
                    aw_done  <= 1'b1;
                end else if (wvalid & wready) begin
                    wr_state <= WR_W;
                    w_done   <= 1'b1;
                end
            end
            WR_AW: begin
                if (wvalid & wready)  w_done  <= 1'b1;
                if (aw_done & w_done) wr_state <= WR_RESP;
            end
            WR_W: begin
                if (awvalid & awready) aw_done <= 1'b1;
                if (aw_done & w_done)  wr_state <= WR_RESP;
            end
            WR_RESP: begin
                if (bvalid & bready) begin
                    wr_state <= WR_IDLE;
                    aw_done  <= 1'b0;
                    w_done   <= 1'b0;
                end
            end
        endcase
    end
end

// ================================
// Read FSM (State 전이)
// ================================
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rd_state <= RD_IDLE;
    end else begin
        case (rd_state)
            RD_IDLE:       if (arvalid & arready) rd_state <= RD_DATA_FETCH;
            RD_DATA_FETCH: rd_state <= RD_RESP;
            RD_RESP:       if (rvalid & rready)   rd_state <= RD_IDLE;
        endcase
    end
end

// ================================
// Output 로직 (always_comb)
// ================================
always_comb begin
    // 기본값 (Default) - 모든 출력 비활성화
    awready = 1'b0;
    wready  = 1'b0;
    bvalid  = 1'b0;
    bresp   = 2'b00;
    arready = 1'b0;
    rvalid  = 1'b0;
    rdata   = '0;
    rresp   = 2'b00;

    // Write Output
    case (wr_state)
        WR_IDLE: begin
            awready = 1'b1;
            wready  = 1'b1;
        end
        WR_AW:  wready  = 1'b1;
        WR_W:   awready = 1'b1;
        WR_RESP: begin
            bvalid = 1'b1;
            bresp  = 2'b00;
        end
    endcase

    // Read Output
    case (rd_state)
        RD_IDLE: arready = 1'b1;
        RD_RESP: begin
            rvalid = 1'b1;
            rdata  = reg_file[araddr[3:2]];
            rresp  = 2'b00;
        end
    endcase
end

// ================================
// Write 실행 로직 (레지스터 업데이트)
// ================================
always_ff @(posedge clk) begin
    if (wr_state == WR_RESP && (bvalid & bready)) begin
        reg_file[awaddr[3:2]] <= wdata;
    end
end

endmodule
```

---

## 5. 검증 엣지 케이스

### Write 관련

| Case | 시나리오 | 확인 포인트 |
|---|---|---|
| Case 1 | `WVALID`가 `AWVALID`보다 먼저 오는 경우 | `w_done=1` 후 AW 대기, 올바른 State 전이 |
| Case 2 | `AWVALID`와 `WVALID` 동시 진입 | `aw_done & w_done` 동시 set → 즉시 `WR_RESP` 진입 |
| Case 3 | Master가 `BREADY`를 N사이클 늦게 올리는 경우 | `WR_RESP` 유지하며 `BVALID` 계속 Assert |
| Case 4 | `BVALID & BREADY` 완료 직후 바로 다음 `AWVALID` | `WR_IDLE` 복귀 후 다음 트랜잭션 정상 처리 |

### Read 관련

| Case | 시나리오 | 확인 포인트 |
|---|---|---|
| Case 5 | 존재하지 않는 주소로 Read 요청 | `RRESP = 2'b10 (SLVERR)` 반환 여부 |
| Case 6 | `RREADY`를 N사이클 늦게 올리는 경우 | `RD_RESP` 유지하며 `RVALID` 계속 Assert |

### Write + Read 동시

| Case | 시나리오 | 확인 포인트 |
|---|---|---|
| Case 7 | Write와 Read 트랜잭션이 동시에 들어오는 경우 | Write FSM / Read FSM 각각 독립 동작 확인 |

---

## 6. 핵심 설계 포인트 요약

- **always_ff** : State 전이 및 플래그(레지스터) 업데이트 전용
- **always_comb** : 현재 State에 따른 출력값 결정 전용 (플래그 건드리면 안 됨)
- **Default 값 설정** : `always_comb` 시작 시 모든 출력에 기본값을 먼저 설정 → 래치(Latch) 생성 방지
- **enum prefix 통일** : `WR_`, `RD_` prefix로 포트 신호명과 충돌 방지
- **AW/W 독립 FSM 구조** : 두 채널의 도착 순서가 보장되지 않으므로 각각 독립적으로 처리 후 `aw_done & w_done` 조건으로 합류

---

## 7. 다음 세션 선택지

- **Option A**: 오늘 코드의 Testbench 작성 → 검증 케이스 직접 시뮬레이션
- **Option B**: PCIe/CXL 하위 블록 설계로 레벨업

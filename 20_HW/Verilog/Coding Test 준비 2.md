> 10~15분 분량, 설계 감각 & 코딩 구조 확인용 문제 문법 암기가 아니라 "여러 개념을 하나의 모듈로 조립하는 능력"을 보는 문제들입니다. 
> 시작하기 전에 상태 다이어그램이나 블록 구조를 먼저 그려보는 걸 추천합니다.

---

## 1. Synchronous FIFO Controller — depth 8 (12~15분) - 7분

포인터 기반 FIFO의 컨트롤 로직만 설계하세요 (데이터 저장 배열은 이미 있다고 가정, `wptr`/`rptr`/`full`/`empty`만 구현).

**스펙**

- depth 8 → 3-bit 포인터
- `wr_en=1`이고 `full=0`일 때만 write pointer 증가
- `rd_en=1`이고 `empty=0`일 때만 read pointer 증가
- `full`, `empty` 판정 로직을 스스로 설계 (포인터 몇 비트를 어떻게 쓸지가 설계 포인트)

```verilog
module fifo_ctrl (
    input  logic       clk,
    input  logic       rst_n,
    input  logic        wr_en,
    input  logic        rd_en,
    output logic [2:0]  wptr,
    output logic [2:0]  rptr,
    output logic        full,
    output logic        empty
); 

	logic [3:0] r_wptr, r_rptr;
	
	always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			r_wptr <= 0;
		end else if (wr_en && !full) begin
			r_wptr <= r_wptr + 1;
		end
	end

	always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			r_rptr <= 0;
		end else if (rd_en && !empty) begin
			r_rptr <= r_rptr + 1;
		end
	end
		
	assign wptr  = r_wptr[2:0];
	assign rptr  = r_rptr[2:0];
	assign full  = (r_wptr == {~r_rptr[3], r_rptr[2:0]});
	assign empty = (r_wptr == r_rptr);
	
endmodule
```

---

## 2. UART Transmitter — start + 8 data + stop (13~15분) - 11분 (다시 생각해볼 것)
`tick`(baud rate enable pulse, 1클럭 폭)이 1일 때만 상태가 진행되는 간단 UART TX를 설계하세요.

**스펙**

- `tx_start=1`이면 전송 시작 (idle 상태에서만 유효)
- 순서: START bit(0) → data[0]~data[7] (LSB first) → STOP bit(1) → IDLE
- `tick`이 1인 클럭에서만 한 비트씩 진행 (그 외에는 상태 유지)
- 전송 중엔 `tx_busy=1`

```verilog
module uart_tx (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        tick,
    input  logic        tx_start,
    input  logic [7:0]  tx_data,
    output logic        tx_out,
    output logic        tx_busy
);

	parameter p_IDLE  = 2'd0;
	parameter p_START = 2'd1;
	parameter p_DATA  = 2'd2;
	parameter p_STOP  = 2'd3;

	logic [1:0] p_state, n_state;
	logic [2:0] counter;
	
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			p_state <= p_IDLE;
		end else begin
			p_state <= n_state;
		end
	end
	
	always_comb @(*) begin
		n_state = p_state;
		
		case (p_state)
			p_IDLE  : n_state = (tx_start == 1) ? p_START : p_IDLE;
			p_START : n_state = p_DATA;
			p_DATA  : n_state = (counter == 3'd7) ? p_STOP : p_DATA;
			p_STOP  : n_state = p_IDLE;
		endcase
	end
	
	always_comb @(*) begin
		case (p_state)
			P_IDLE  : begin
				tx_bysu = 0;
			end
			p_START : begin
				tx_out  = 0;	
				tx_busy = 1;
			end
			
			p_DATA  : begin
				if (counter != 3'd7) begin
					counter          = counter + 1;
					tx_out[counter]  = tx_data[counter]
				end else begin
					counter = 'b0;
				end
			end
				
			p_STOP : begin
				tx_out = 1;
			end
		endcase
	end
	
endmodule
```

### 답안 1

```verilog
module uart_tx (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        tick,
    input  logic        tx_start,
    input  logic [7:0]  tx_data,
    output logic        tx_out,
    output logic        tx_busy
);

	parameter p_IDLE = 0;
	parameter P_BUSY = 1;
	
	logic p_state, n_state;
	logic [9:0] tx_shift_data;
	logic [3:0] counter;
	
	always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        p_state       <= p_IDLE;
        counter       <= 0;
        tx_shift_data <= 10'b0;
    end else if (tick) begin
        p_state <= n_state;
        case (p_state)
            p_IDLE: begin
                counter       <= 0;
                tx_shift_data <= {1'b1, tx_data, 1'b0};  // stop, data(MSB first), start
            end
            
            p_BUSY: begin
                counter       <= counter + 1;
                tx_shift_data <= tx_shift_data >> 1;
            end
        endcase
    end

	assign tx_out  = tx_shift_data[0];
	assign tx_busy = (p_state == p_BUSY);
	
endmodule
```

 ### 답안 2
 
 ```verilog
	// Block 1: state + counter + shift register 모두 여기서만 업데이트 (순차)
	always_ff @(posedge clk or negedge rst_n) begin
	    if (!rst_n) begin
	        p_state       <= p_IDLE;
	        counter       <= 0;
	        tx_shift_data <= 10'b0;
	    end else if (tick) begin
	        p_state       <= n_state;
	        counter       <= n_counter;
	        tx_shift_data <= n_shift;
	    end
	end
	
	// Block 2: next-state / next-counter / next-shift 계산 (조합)
	always_comb begin
	    n_state   = p_state;
	    n_counter = counter;
	    n_shift   = tx_shift_data;
	
	    case (p_state)
	        p_IDLE: begin
	            n_state   = tx_start ? p_BUSY : p_IDLE;
	            n_counter = 0;
	            n_shift   = {1'b1, tx_data, 1'b0};
	        end
	        p_BUSY: begin
	            n_state   = (counter == 4'd9) ? p_IDLE : p_BUSY;
	            n_counter = counter + 1;
	            n_shift   = tx_shift_data >> 1;
	        end
	    endcase
	end
	
	// Block 3: output (조합)
	always_comb begin
	    tx_out  = tx_shift_data[0];
	    tx_busy = (p_state == p_BUSY);
	end
 ```

---

## 3. Push Button Debounce + Toggle (10~12분)

버튼 입력을 디바운스한 뒤, 눌릴 때마다(한 번의 유효한 press당 한 번만) 출력을 토글하세요.

**스펙**

- `btn_in`을 N클럭(예: 4클럭) 동안 연속으로 같은 값이어야 안정된 값으로 인정 (간단화된 debounce — 카운터 기반)
- 디바운스된 신호의 rising edge에서만 `led_out` 토글
- 여러 개념(카운터, 엣지 검출, 토글 FF)을 하나로 조립하는 게 핵심

```verilog
module btn_debounce_toggle (
    input  logic clk,
    input  logic rst_n,
    input  logic btn_in,
    output logic led_out
);

endmodule
```

---

## 4. 4-bit Shift-Add Multiplier (13~15분)

Multi-cycle 방식의 4bit × 4bit 곱셈기를 FSM + 데이터패스로 설계하세요.

**스펙**

- `start=1`이면 `a`, `b` 값을 로드하고 연산 시작
- 매 사이클: `b`의 LSB가 1이면 `product += (a << shift_count)`, 이후 오른쪽으로 shift
- 4번 반복 후 `done=1`, `result`에 8bit 결과 출력
- FSM 상태 최소 3개 이상(LOAD, COMPUTE, DONE) 필요 — 상태 수와 전이 조건을 스스로 설계하는 게 핵심

```verilog
module mult_shift_add (
    input  logic       clk,
    input  logic       rst_n,
    input  logic        start,
    input  logic [3:0]  a, b,
    output logic [7:0]  result,
    output logic        done
);

endmodule
```

---

## 5. Register File w/ Address Decode — APB-lite 스타일 (10~12분)

4개의 8bit 레지스터(주소 0~3)에 대한 단일 사이클 read/write 컨트롤러를 설계하세요.

**스펙**

- `wr_en=1`이면 해당 클럭에 `addr`이 가리키는 레지스터에 `wdata` 기록
- `wr_en=0`이면 `addr`이 가리키는 레지스터 값을 `rdata`로 조합 출력 (read는 비동기, write만 동기)
- 잘못된 주소(4 이상)는 없다고 가정해도 됨
- 지윤님 AES-128 SoC의 APB 인터페이스 경험과 가장 결이 비슷한 문제입니다

```verilog
module regfile_4x8 (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        wr_en,
    input  logic [1:0]  addr,
    input  logic [7:0]  wdata,
    output logic [7:0]  rdata
);

endmodule
```
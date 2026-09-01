> 10~15분 분량, 설계 감각 & 코딩 구조 확인용 문제 문법 암기가 아니라 "여러 개념을 하나의 모듈로 조립하는 능력"을 보는 문제들입니다. 
> 시작하기 전에 상태 다이어그램이나 블록 구조를 먼저 그려보는 걸 추천합니다.

---

# Part 4 심화
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

## 3. Push Button Debounce + Toggle (10~12분) - 10분

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

	logic [1:0] counter;
	logic stable, stable_d;
	logic pulse;
	
	// stable
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			counter <= 0;
			stable  <= 0;
		end else if (btn_in == stable) begin
			counter <= 'b0;
		end else if (counter == 2'd3) begin
			counter <= 'b0;
			stable  <= btn_in;
		end else begin
			counter <= counter + 1;
		end
	end
	
	// pulse
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			stable_d <= 0;
		end else begin
			stable_d <= stable;
		end
	end
	
	assign pulse = (~stable_d & stable);
	
	// led
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			led_out <= 0;
		end else if (pulse) begin
			led_out <= ~led_out;
		end
	end
	
endmodule
```

---

## 4. 4-bit Shift-Add Multiplier (13~15분) - 14분

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

	parameter IDLE    = 2'd0;
	parameter LOAD    = 2'd1;
	parameter COMPUTE = 2'd2;
	parameter DONE    = 2'd3;
	
	logic [1:0] p_state, n_state;
	logic [7:0] p_product, n_product;
	logic [3:0] p_bshift, n_bshift;
	logic [1:0] p_shiftcnt, n_shiftcnt;
	
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			p_state    <= IDLE;
			p_product  <= 'b0;
			p_bshift   <= 'b0;
			p_shiftcnt <= 'b0;
		end else begin
			p_state    <= n_state;
			p_product  <= n_product;
			p_bshift   <= n_bshift;
			p_shiftcnt <= n_shiftcnt;
		end
	end
	
	always_comb @(*) begin
		n_state    = p_state;
		n_product  = p_product;
		n_bshift   = p_bshift;
		n_shiftcnt = p_shiftcnt;
		
		case (p_state)
			IDLE    : begin
				n_state    = start ? LOAD : IDLE;
				n_shiftcnt = 'b0;
			end
			
			LOAD    : begin
				n_bshift   = b;
				n_product  = 'b0;
				n_shiftcnt = 'b0;
				n_state    = COMPUTE;
			end
			
			COMPUTE : begin
			    if (p_bshift[0]) begin
			        n_product = p_product + (a << p_shiftcnt);
				end
			
			    if (p_shiftcnt == 2'd3) begin
			        n_state = DONE;
				end
			        
			    n_bshift   = p_bshift >> 1;
			    n_shiftcnt = p_shiftcnt + 1;
			end
			
			DONE    : begin
				n_state = IDLE;
			end
		endcase
	end
	
	assign done   = (p_state == DONE);
	assign result = p_product;

endmodule
```

---

## 5. Register File w/ Address Decode — APB-lite 스타일 (10~12분) - 4분

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

	logic [7:0] register [0:3];
	
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			register[0] <= 'b0;
			register[1] <= 'b0;
			register[2] <= 'b0;
			register[3] <= 'b0;
		end else if (wr_en) begin
			register[addr] <= wdata;
		end
	end
	
	assign rdata =  register[addr];
endmodule
```

---

## 6. PWM Generator (10~12분) - 4분

8bit 카운터와 duty cycle 비교를 이용한 PWM 신호를 생성하세요.

**스펙**

- `duty` (0~255)만큼 매 주기(0~255 카운트) 동안 `pwm_out=1`, 나머지 구간은 0
- 카운터는 255에서 0으로 자동 롤오버하며 계속 반복
- `duty=0`이면 항상 0, `duty=255`이면 항상 1 (edge case 스스로 확인)

```verilog
module pwm_gen (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [7:0] duty,
    output logic        pwm_out
);

	logic [7:0] count;
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			pwm_out <= 0;
		end else begin
			if (count == 8'd255) begin
				count <= 'b0;
			end else begin
				count <= count + 1;
			end
			
			pwm_out <= (duty == 8'd255) ? 1'b1 : (count < duty);
		end
	end
	
endmodule
```

---

## 7. SPI Master — single byte transfer, CPOL=0/CPHA=0 (13~15분) - 14분

`sclk_tick`(SPI 클럭 생성용 enable pulse, UART의 tick과 같은 역할)이 1일 때만 동작하는 8bit SPI Master를 설계하세요.

**스펙**

- `start=1`이면 `tx_data`를 로드하고 전송 시작 (idle 상태에서만 유효)
- 매 `sclk_tick`마다 MOSI로 `tx_data`의 MSB부터 1비트씩 내보내고, 동시에 MISO로 들어오는 비트를 `rx_data`에 채워 넣음 (shift 방향 주의)
- 8비트 다 주고받으면 `done=1`, 그 다음 사이클엔 idle로 복귀
- 전송 중엔 `busy=1`

```verilog
module spi_master (
    input  logic       clk,
    input  logic       rst_n,
    input  logic        sclk_tick,
    input  logic        start,
    input  logic [7:0]  tx_data,
    input  logic        miso,
    output logic        mosi,
    output logic [7:0]  rx_data,
    output logic        busy,
    output logic        done
);

	parameter p_IDLE  = 2'd0;
	parameter p_START = 2'd1;
	parameter p_DATA  = 2'd2;
	parameter p_DONE  = 2'd3;
	
	logic [1:0] p_state, n_state;
	logic [7:0] p_wdata, n_wdata;
	logic [7:0] p_rdata, n_rdata;
	logic [2:0] p_count, n_count;

	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			p_state <= p_IDLE;
			p_wdata <= 'b0;
			p_rdata <= 'b0;
			p_count <= 'b0;
		end else if (sclk_tick) begin
			p_state <= n_state;
			p_wdata <= n_wdata;
			p_rdata <= n_rdata;
			p_count <= n_count;
		end
	end
	
	always_comb @(*) begin
		n_state = p_state;
		n_wdata = p_wdata;
		n_rdata = p_rdata;
		n_count = p_count;
		
		case (p_state)
			p_IDLE  : n_state = start ? p_START : p_IDLE;
			
			p_START : begin
				n_wdata = tx_data;
				n_count = 'd0;
				n_state = p_DATA;
			end
			
			p_DATA  : begin
				n_wdata = p_wdata << 1;
				n_rdata = {p_rdata[6:0], miso};
				n_count = p_count + 1;
				n_state = (p_count == 3'd7) ? p_DONE : p_DATA;
			end
			
			p_DONE  : n_state = p_IDLE;
		endcase
	end

	assign mosi    = (p_state == p_DATA) ? p_wdata[7] : 0;
	assign rx_data = p_rdata;
	assign busy    = (p_state == p_START) || (p_state == p_DATA);
	assign done    = (p_state == p_DONE);
	
endmodule
```

---

## 8. 신호등 + 횡단보도 버튼 (Moore, 13~15분) - 13분 30초초

14번 신호등 문제의 확장판입니다. 평소엔 기존 RED→GREEN→YELLOW 순환을 돌되, 보행자가 버튼을 누르면 **다음 RED 구간을 평소보다 길게** 유지하세요.

**스펙**

- 기본 순환: RED(2clk) → GREEN(3clk) → YELLOW(1clk) → RED...
- `ped_req=1`(버튼 눌림, 1클럭 폭 pulse)이 들어오면 이후 진입하는 RED 구간은 2클럭이 아니라 **5클럭**으로 연장
- `ped_req`는 아무 상태에서나(GREEN 도중이든 YELLOW 도중이든) 들어올 수 있음 — 그 요청을 어딘가에 "기억"해뒀다가 RED 진입 시점에 반영해야 함 (설계 포인트)
- 한 번의 요청은 한 번의 연장에만 반영 (연장 끝나면 요청 플래그 클리어)

```verilog
module traffic_light_ped (
    input  logic       clk,
    input  logic       rst_n,
    input  logic        ped_req,
    output logic [1:0]  light  // 00=RED, 01=GREEN, 10=YELLOW
);

	parameter RED    = 2'd0;
	parameter GREEN  = 2'd1;
	parameter YELLOW = 2'd2;
	
	logic [1:0] p_state, n_state;
	logic [2:0] p_count, n_count;
	logic p_pending, n_pending;
	logic p_extend, n_extend;
	
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			p_state  <= RED;
			p_count  <= 'b0;
			p_pending <= 0;
			p_extend  <= 0;
		end else begin		
			p_state   <= n_state;
			p_count   <= n_count;
			p_pending <= n_pending;
			p_extend  <= n_extend;
		end
	end
	
	always_comb @(*) begin
		n_state   = p_state;
		n_count   = p_count;
		n_pending = (ped_req) ? 1 : p_pending;
		n_extend  = p_extend;
		
		case (p_state)
			RED    : begin
				if ((p_extend && p_count == 3'd4) || (!p_extend && p_count == 3'd1)) begin
					n_state = GREEN;
					n_count = 'd0;
				end else begin
					n_count = p_count + 1;
				end
			end
			
			GREEN  : begin
				if (p_count == 3'd2) begin
					n_state = YELLOW;
					n_count = 'd0;
				end else begin
					n_count = p_count + 1;
				end
			end
			
			YELLOW : begin
				n_state   = RED;
				n_count   = 'd0;
				n_extend  = p_pending;
				n_pending = 0;
			end
		endcase
	end
	
	assign light = p_state;
	
endmodule
```

---


# 오답노트 및 재연습

> 오늘 반복됐던 실수 패턴을 하나씩 정면으로 찌르는 문제들입니다. 각 문제 위에 "이게 어떤 실수를 다시 짚는지" 적어뒀으니, 풀기 전에 한 번 읽고 시작하세요.

---

## 1. 8-bit Running Parity Counter (10분) - 7분

**짚는 포인트**: "무조건 할 일 vs 조건부로 할 일" 분리 — 27번 곱셈기, 6번 PWM에서 반복됐던 실수.

**스펙**

- `valid=1`일 때마다 `din` 1비트를 받아서 running XOR parity를 갱신 (`parity <= parity ^ din`) — 이건 조건부(valid일 때만)
- 동시에 `valid=1`일 때마다 받은 비트 수를 세는 `count`도 갱신 — 이것도 valid에 종속
- `count`가 8에 도달하면 `parity_done=1`을 1클럭 띄우고, `count`와 `parity`를 0으로 리셋 후 다음 8비트 카운트를 새로 시작
- 힌트: "갱신"과 "카운트"는 항상 같이 움직이지만, "8개 다 찼을 때 리셋"은 그 이후에 별도로 판단해야 함 — 어디까지가 하나의 조건이고 어디부터 별개의 조건인지 스스로 나눠보는 게 핵심

```verilog
module parity_counter (
    input  logic       clk,
    input  logic       rst_n,
    input  logic        valid,
    input  logic        din,
    output logic        parity_done,
    output logic        parity_out
);
	
	logic parity;
	logic [2:0] count;

	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			count       <= 'd0;
			parity      <= 0;
			parity_done <= 0;
			parity_out  <= 0;
		end else begin
			parity_done <= 1'b0;

	        if (valid) begin
	            parity <= parity ^ din;
	            if (count == 3'd7) begin
	                count       <= 3'd0;
	                parity_done <= 1'b1;
	                parity_out  <= parity ^ din;
	            end else begin
	                count <= count + 1;
	            end
	        end
	    end
	end
	
endmodule
```

---

## 2. "110" Overlap 시퀀스 디텍터 (10분) - 6분

**짚는 포인트**: 부분 매칭 실패 시 올바른 fallback state로 가는 것 — 15, 21, 23번에서 반복됐던 그 실수.

**스펙**

- 입력 비트스트림에서 "110" 패턴이 끝나는 순간 `detect=1` (Moore)
- Overlap 허용 — 예를 들어 "1101101"이면 두 번 검출되어야 함
- 그리기 힌트: 상태를 "지금까지 매칭된 접두사"로 이름 붙이고, 각 상태에서 din=0/din=1일 때 "지금까지 문자열 + 그 비트"의 접미사가 패턴의 접두사와 어디까지 겹치는지 손으로 먼저 표로 그려보세요.

```verilog
module seq_detect_110 (
    input  logic clk,
    input  logic rst_n,
    input  logic din,
    output logic detect
);

	parameter p_IDLE = 2'd0;
	parameter p_D1   = 2'd1;
	parameter p_D2   = 2'd2;
	parameter p_D3   = 2'd3;
	
	logic [1:0] p_state, n_state;
	
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
			p_IDLE : n_state = (din == 1) ? p_D1 : p_IDLE;
			p_D1   : n_state = (din == 1) ? p_D2 : p_IDLE;
			p_D2   : n_state = (din == 0) ? p_D3 : p_D2;
			p_D3   : n_state = (din == 1) ? p_D1 : p_IDLE;
		endcase
	end
	
	assign detect = (p_state == p_D3);
	
endmodule
```

---

## 3. Pulse Crossing Synchronizer — Toggle 방식 (12~15분) - 6분

**짚는 포인트**: CDC 개념의 응용. 2-FF sync(11번)는 "레벨 신호"를 옮기는 거였는데, 이번엔 "폭이 1클럭인 pulse"를 다른 클럭 도메인으로 안전하게 옮기는 문제 — 왜 pulse를 2-FF sync에 그냥 넣으면 안 되는지가 핵심.

**스펙**

- `clk_a` 도메인에서 `pulse_in`(폭 1클럭)이 뜨면, `clk_b` 도메인에서 `pulse_out`이 (정확히 한 번만) 떠야 함
- 힌트: `pulse_in`을 그대로 2-FF sync에 넣으면, `clk_b`가 `clk_a`보다 느릴 경우 그 1클럭짜리 pulse를 아예 샘플링을 못 하고 놓칠 수 있음. 그래서 실무에서는 **toggle 방식**을 씀: `clk_a` 쪽에서 pulse가 뜰 때마다 레벨 신호를 토글시키고(`toggle_a <= ~toggle_a`), 그 "레벨"을 `clk_b`로 2-FF sync 시킨 뒤, `clk_b` 쪽에서 그 동기화된 신호의 edge를 검출하면 그게 곧 pulse_out.
- 즉 이 문제는 "10번(edge detect) + 11번(2-FF sync) + toggle FF"를 순서대로 조립하는 문제입니다.

```verilog
module pulse_cross (
    input  logic clk_a,
    input  logic rst_n_a,
    input  logic pulse_in,     // clk_a 도메인

    input  logic clk_b,
    input  logic rst_n_b,
    output logic pulse_out     // clk_b 도메인
);

	logic toggle_a;
	logic sync_b1, sync_b2;
	logic edge_b;
	
	always_ff @(posedge clk_a, negedge rst_n_a) begin
		if (!rst_n_a) begin
			toggle_a <= 0;
		end else if (pulse_in) begin
			toggle_a <= ~toggle_a;
		end
	end
	
	always_ff @(posedge clk_b, negedge rst_n_b) begin
		if (!rst_n_b) begin
			sync_b1 <= 0;
			sync_b2 <= 0;
			edge_b  <= 0;
		end else begin
			sync_b1 <= toggle_a;
			sync_b2 <= sync_b1;
			edge_b  <= sync_b1;
		end
	end

	assign pulse_out = (~sync_b & edge_b);
	
endmodule
```

---

## 4. 인터럽트 우선순위 컨트롤러 — Latch 방지 집중 (10분)

**짚는 포인트**: `always_comb`에서 모든 출력에 기본값을 먼저 깔아두는 패턴 — 25번 UART, 28번 SPI에서 래치 위험이 나왔던 그 지점을 의도적으로 다시 연습.

**스펙**

- 4개의 인터럽트 입력(`irq[3:0]`) 중 가장 우선순위 높은 것(번호가 클수록 우선순위 높음, `irq[3]`이 최우선) 하나만 골라서 `grant`(2bit, 어느 irq인지)와 `irq_valid`(뭐라도 떴는지)를 출력
- 추가로 `ack`(1bit, 이번 사이클에 처리 중이라는 표시)도 같이 만들어야 함 — 총 3개 출력을 하나의 `always_comb`에서 관리
- 목표: case문이든 if-else든, **시작하자마자 모든 출력에 기본값부터 깔고** 그 다음에 조건별로 필요한 것만 덮어쓰는 스타일을 의식적으로 연습하는 것

```verilog
module irq_ctrl (
    input  logic [3:0] irq,
    output logic [1:0] grant,
    output logic       irq_valid,
    output logic       ack
);

endmodule
```

---

## 5. 간단 자판기 FSM — 동전 누적 (13~15분)

**짚는 포인트**: "나중에 쓸 값을 지금 기억해뒀다가 특정 시점에 반영" — 오늘 마지막 문제(신호등+버튼)에서 제대로 짚어내신 그 패턴을 완전히 새로운 문제에 다시 적용해보는 것. 오답이 아니라 "잘했던 걸 다른 문제에서도 재현할 수 있는지" 확인용입니다.

**스펙**

- `coin_5=1`이면 5원 투입, `coin_10=1`이면 10원 투입 (동시에 안 들어옴, 한 클럭에 최대 하나)
- 누적 금액이 **15원 이상**이 되면 그 다음 클럭에 `dispense=1`을 1클럭 띄우고 누적 금액을 초기화 (거스름돈 로직은 무시해도 됨)
- 누적 금액이 15원 미만인 동안은 계속 값을 쌓아가야 함 (즉 "투입될 때마다 더하고, 15 넘었는지는 그 이후에 판단"이라는 구조 — 1번 문제와 원리가 같음)
- `amount`(누적 금액, 5bit 정도)를 출력으로 노출해서 중간 확인 가능하게 하세요

```verilog
module vending_machine (
    input  logic       clk,
    input  logic       rst_n,
    input  logic        coin_5,
    input  logic        coin_10,
    output logic [4:0]  amount,
    output logic        dispense
);

endmodule
```

---

## 오늘 전체 복기 체크리스트

- [ ] FSM 짜기 전에 상태 다이어그램(원+화살표)을 먼저 그렸는가
- [ ] "조건부로 해야 할 일"과 "무조건 매 사이클 해야 할 일"을 분리했는가 (특히 counter 증가, shift)
- [ ] `always_comb`에서 모든 출력에 기본값을 먼저 깔았는가 (case가 일부만 커버해도 래치 안 생기게)
- [ ] 선언한 변수명과 실제 사용한 변수명이 끝까지 일치하는가 (제출 전 한 번 스캔)
- [ ] 종료 조건(off-by-one)을 "먼저 연산, 그다음 판단" 순서로 짰는가
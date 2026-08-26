# Part 1. 기본기 워밍업 (TSN Lab 스타일)

## 1. Inverter (3분) - 15초

```verilog
module inv(
    input  logic [3:0] a,
    output logic [3:0] y
);
    // inverter
    assign y = ~a;

endmodule
```

## 2. Logic Gates — AND, OR, XOR, NAND, NOR (3분) - 45초

```verilog
module gates(
    input  logic [3:0] a, b,
    output logic [3:0] y1, y2, y3, y4, y5
);
    // y1 = AND
    // y2 = OR
    // y3 = XOR
    // y4 = NAND
    // y5 = NOR
    
    assign y1 = a & b;
    assign y2 = a | b;
    assign y3 = a ^ b;
    assign y4 = a ~& b;
    assign y5 = a ~| b;

endmodule
```

## 3. Multiplexer (3분) - 25초

```verilog
module mux2(
    input  logic [3:0] d0, d1,
    input  logic       s,
    output logic [3:0] y
);
    // 2:1 multiplexer
	assign y = s ? d1 : d0;
	
endmodule
```

## 4. Register (5분) - 30초

```verilog
module flop(
    input  logic       clk,
    input  logic [3:0] d,
    output logic [3:0] q
);
    // D flip-flop
    always @(posedge clk) begin
	    q <= d;
	end

endmodule
```

## 5. 3:8 Decoder (5분) - 2분분

```verilog
module decoder3_8(
    input  logic [2:0] a,
    output logic [7:0] y
);
    // 3:8 decoder
    assign y = 8'b1 << a;
        
endmodule
```

---

# Part 2. 조합논리 추가

## 6. 4-bit 크기 비교기 (3분) - 1분

a > b, a == b, a < b 세 가지 출력을 만드세요.

```verilog
module comparator4(
    input  logic [3:0] a, b,
    output logic gt, eq, lt
);

	assign gt = (a > b)  ? 1'b1 : 1'b0;
	assign eq = (a == b) ? 1'b1 : 1'b0;
	assign lt = (a < b)  ? 1'b1 : 1'b0;
	
endmodule
```

## 7. 4:1 Priority Encoder (4분) - 2분 25초

입력 중 가장 높은 비트 위치의 인덱스를 출력하세요 (입력이 모두 0이면 valid=0).

```verilog
module priority_enc4(
    input  logic [3:0] in,
    output logic [1:0] idx,
    output logic       valid
);

	assign idx   =  (in[3] == 1) ? 2'b11 :
					(in[2] == 1) ? 2'b10 :
					(in[1] == 1) ? 2'b01 : 2'b00;
					
	assign valid =  (in == 'b0) ? 0 : 1;
	// assign valid = |in;
	
endmodule
```

---

# Part 3. 순차논리

## 8. 동기 리셋 + Enable D-FF (4분) - 1분 10초

```verilog
module flop_en_rst(
    input  logic       clk,
    input  logic       rst_n,   // active-low sync reset
    input  logic       en,
    input  logic [3:0] d,
    output logic [3:0] q
);

	always @(posedge clk) begin
		if (!rst_n) begin
			q <= 'b0;
		end else if (en) begin
			q <= d;
		end
	end

endmodule
```

## 9. 4-bit SIPO Shift Register (5분) 1분 40초 - shift 확인 잘해라

매 클럭 `sin`을 LSB로 밀어넣는 시프트 레지스터.

```verilog
module sipo4(
    input  logic       clk,
    input  logic       rst_n,
    input  logic       sin,
    output logic [3:0] q
);

	always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			q <= 'b0;
		end else begin
			q <= {q[2:0], sin};
			// q    <= q << 1;
			// q[0] <= sin;     --- 순서상 맞지만, 에러가 뜰 수 있음 주의
		end
	end

endmodule
```

## 10. Rising Edge Detector (4분) - 2분 5초 (다시 풀어볼 것)

1클럭짜리 펄스를 입력 신호의 상승 엣지에서 출력하세요.

```verilog
module edge_detect(
    input  logic clk,
    input  logic rst_n,
    input  logic sig_in,
    output logic pulse
);

	// 수정
	logic sig_d;

	always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			sig_d <= 'b0;
		end else begin
			sig_d <= sig_in;
		end
	end
	
	assign pulse = sin_in & !sin_d;

endmodule
```

## 11. 2-FF Synchronizer (CDC) (4분) - 1분 10초초

비동기 입력 `async_in`을 `clk` 도메인으로 동기화하세요.

```verilog
module sync2ff(
    input  logic clk,
    input  logic rst_n,
    input  logic async_in,
    output logic sync_out
);

	// 2-state임
	logic meta;

	always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			meta     <= 'b0;
			sync_out <= 'b0;
		end else begin
			meta     <= async_in;
			sync_out <= meta;
		end
	end
	
endmodule
```

---

# Part 4. Counter

## 12. Mod-6 Up Counter (5분) - 1분 30초

0~5까지 카운트하고 6이 되면 0으로 롤오버.

```verilog
module counter_mod6(
    input  logic       clk,
    input  logic       rst_n,
    output logic [2:0] cnt
);
	
	always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			cnt <= 'b0;
		end else if (cnt == 3'd5) begin
			cnt <= 'b0;
		end else begin
			cnt <= cnt + 1;
		end
	end
	
endmodule
```

## 13. Up/Down Counter (5분) - 1분 20초

`updown = 1`이면 증가, `0`이면 감소.

```verilog
module updown_counter(
    input  logic       clk,
    input  logic       rst_n,
    input  logic       updown,
    output logic [3:0] cnt
);

	always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			cnt <= 'b0;
		end else if (updown) begin
			cnt <= cnt + 1;
		end else begin
			cnt <= cnt - 1;
		end
	end

endmodule
```

---

# Part 5. FSM

## 14. 신호등 컨트롤러 (Moore, 6~7분) - 10분분

RED(2clk) → GREEN(3clk) → YELLOW(1clk) → RED 순환.

```verilog
module traffic_light(
    input  logic       clk,
    input  logic       rst_n,
    output logic [1:0] light  // 00=RED, 01=GREEN, 10=YELLOW
);

	parameter p_RED    = 3'b000;
	parameter p_r1clk  = 3'b001;
	parameter p_GREEN  = 3'b010;
	parameter p_g1clk  = 3'b011;
	parameter p_g2clk  = 3'b100;
	parameter p_YELLOW = 3'b101;
	
	logic p_state, n_state;
	logic color_state;

	always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			p_state <= p_RED;
			color_state
		end else begin
			p_state <= n_state;
		end
	end
	
	always @(*) begin
		n_state = p_state;
		
		case (p_state)
			p_RED    : n_state = p_r1clk;
			p_r1clk  : n_state = p_GREEN;
			p_GREEN  : n_state = p_g1clk;
			p_g1clk  : n_state = p_g2clk;
			p_g2clk  : n_state = p_YELLOW;
			p_YELLOW : n_state = p_RED;
		endcase
	end
	
	always @(*) begin
		light = 'b0;
		
		case (p_state)
			p_RED    : light = 2'b00;
			p_r1clk  : light = 2'b00;
			p_GREEN  : light = 2'b01;
			p_g1clk  : light = 2'b01;
			p_g2clk  : light = 2'b01;
			p_YELLOW : light = 2'b10;
		endcase
	end

endmodule
```

## 15. "1011" 시퀀스 디텍터 — overlap 허용 (Moore, 7분)

입력 비트스트림에서 "1011" 패턴이 끝나는 순간 `detect=1`.

```verilog
module seq_detect_1011(
    input  logic clk,
    input  logic rst_n,
    input  logic din,
    output logic detect
);

	parateter p_

endmodule
```

## 16. Req/Ack 핸드셰이크 FSM (6분)

IDLE → (req=1) → WAIT → (ack=1) → DONE → IDLE, 3-state FSM.

```verilog
module handshake_fsm(
    input  logic clk,
    input  logic rst_n,
    input  logic req,
    output logic ack,
    output logic done
);

endmodule
```

---

# 연습 진행 팁

- 문제마다 타이머를 실제로 켜고 시간 내에 끝내는 걸 목표로 하세요.
- 다 쓴 뒤 소리 내어 "왜 이렇게 설계했는지" 30초 설명하는 연습도 같이 하면 좋습니다 (마이크 켜는 방식 대비).
- 막히면 다음 문제로 넘어갔다가 나중에 다시 — 실전에서도 같은 전략이 유효합니다.
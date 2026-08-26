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

## 14. 신호등 컨트롤러 (Moore, 6~7분) - 10분 (이렇게 풀어도됨, State 많아질 것 같으면 내부 카운트트)

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
	
	logic [2:0] p_state, n_state;

	always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			p_state <= p_RED;
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

## 15. "1011" 시퀀스 디텍터 — overlap 허용 (Moore, 7분) - 5분 (Overlap 허용 확인)

입력 비트스트림에서 "1011" 패턴이 끝나는 순간 `detect=1`.

```verilog
module seq_detect_1011(
    input  logic clk,
    input  logic rst_n,
    input  logic din,
    output logic detect
);

	parameter p_IDLE = 3'd0;
	parameter p_State1 = 3'd1;
	parameter p_State2 = 3'd2;
	parameter p_State3 = 3'd3;
	parameter p_State4 = 3'd4;
	
	logic [2:0] p_state, n_state;
	
	always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			p_state <= p_IDLE;
		end else begin
			p_state <= n_state;
		end
	end
	
	always @(*) begin
		n_state = p_state;
		
		case (p_state)
			p_IDLE   : n_state = (din == 1) ? p_State1 : p_IDLE;
			// p_State1 : n_state = (din == 0) ? p_State2 : p_IDLE;
			p_State1 : n_state = (din == 0) ? p_State2 : p_State1; // 11이면 유지 111011 일 수 있음
			p_State2 : n_state = (din == 1) ? p_State3 : p_IDLE;
			// p_State3 : n_state = (din == 1) ? p_State4 : p_IDLE;
			p_State3 : n_state = (din == 1) ? p_State4 : p_State2; // 101이면 유지 1101011 일 수 있음
			//p_State4 : n_state = p_IDLE;
			p_State4 : n_state = (din == 1) ? p_State1 : p_State2; // 1011011이어도 작동해야함
		endcase
	end	

	assign detect = (p_state == p_State4) ? 1 : 0;
	
endmodule
```

## 16. Req/Ack 핸드셰이크 FSM (6분) - 4분

IDLE → (req=1) → WAIT → (ack=1) → DONE → IDLE, 3-state FSM.

```verilog
module handshake_fsm(
    input  logic clk,
    input  logic rst_n,
    input  logic req,
    output logic ack,
    output logic done
);

	parameter p_IDLE = 2'd0;
	parameter p_WAIT = 2'd1;
	parameter p_DONE = 2'd2;
	
	logic [1:0] p_state, n_state;
	
	always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			p_state <= p_IDLE;
		end else begin
			p_state <= n_state;
		end
	end
	
	always @(*) begin
		n_state = p_state;
		
		case (p_state)
			p_IDLE : n_state = req ? p_WAIT : p_IDLE;
			p_WAIT : n_state = p_DONE;
			p_DONE : n_state = p_IDLE;
		endcase
	end
	
	assign ack  = (p_state == p_WAIT) ? 1 : 0;
	assign done = (p_state == p_DONE) ? 1 : 0;

endmodule
```

---

# 연습 진행 팁

- 문제마다 타이머를 실제로 켜고 시간 내에 끝내는 걸 목표로 하세요.
- 다 쓴 뒤 소리 내어 "왜 이렇게 설계했는지" 30초 설명하는 연습도 같이 하면 좋습니다 (마이크 켜는 방식 대비).
- 막히면 다음 문제로 넘어갔다가 나중에 다시 — 실전에서도 같은 전략이 유효합니다.

--- 

# 오답노트 1 — Edge Detector (10번)

**핵심 개념**: 엣지 검출은 "지금 값"만 봐서는 절대 안 됨. 반드시 **1클럭 전 값을 레지스터에 저장**해서 현재값과 비교해야 전이(transition) 순간을 알 수 있음.

```verilog
logic sig_d;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) sig_d <= 1'b0;
    else        sig_d <= sig_in;
end
assign pulse = sig_in & ~sig_d;  // rising: 0→1
```

## 17. Falling Edge Detector (4분) 1→0으로 떨어지는 순간에 1클럭 펄스를 출력하세요. - 1분 10초

```verilog
module falling_edge_detect(
    input  logic clk,
    input  logic rst_n,
    input  logic sig_in,
    output logic pulse
);

	logic sig_d;
	
	always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			sig_d <= 0;
		end else begin
			sig_d <= sig_in;
		end
	end
	
	assign pulse = (!sig_in & sig_d) ? 1 : 0;

endmodule
```

## 18. Both Edge Detector (4분) rising이든 falling이든, 값이 바뀌는 순간마다 1클럭 펄스를 출력하세요. - 1분

```verilog
module both_edge_detect(
    input  logic clk,
    input  logic rst_n,
    input  logic sig_in,
    output logic pulse
);

	logic sig_d;
	
	always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			sig_d <= 0;
		end else begin
			sig_d <= sig_in;
		end
	end
	
	assign pulse = (sig_in != sig_d);
	
endmodule
```

---

# 오답노트 2 — 2-FF Synchronizer (11번)

**핵심 개념**: FF 1단만 쓰면 메타스테이블이 그대로 다음 로직에 전파될 위험이 있음. 중간에 흡수용 stage를 하나 더 둬서, 메타스테이블이 안정화될 시간(1clk)을 벌어준 뒤 2단째 출력을 실제로 사용. "왜 2단이냐"는 질문에 이 이유를 말로 설명할 수 있어야 함.

```verilog
logic meta;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        meta     <= 1'b0;
        sync_out <= 1'b0;
    end else begin
        meta     <= async_in;
        sync_out <= meta;
    end
end
```

## 19. 3-FF Synchronizer (4분) 2단 대신 3단으로 확장해서 안정성을 더 높인 버전을 짜세요. (메타스테이블 확률을 더 낮추고 싶을 때 씀) - 1분 20초

```verilog
module sync3ff(
    input  logic clk,
    input  logic rst_n,
    input  logic async_in,
    output logic sync_out
);

	logic meta1, meta2;
	
	always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			meta1    <= 0;
			meta2    <= 0;
			sync_out <= 0;
		end else begin
			meta1    <= async_in;
			meat2    <= meta1;
			sync_out <= meta2;
		end
	end

endmodule
```

## 20. Synchronized Pulse Detector (5분) 비동기 입력을 2-FF로 동기화한 뒤, 그 동기화된 신호의 rising edge에서 1클럭 펄스를 출력하세요. (11번 + 10번 결합 응용)

```verilog
module sync_pulse_detect(
    input  logic clk,
    input  logic rst_n,
    input  logic async_in,
    output logic pulse
);

	logic meta;
	logic sig_d;
	
	always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			meta  <= 0;
			sig_d <= 0;
		end else begin
			meta  <= async_in;
			sig_d <= 
		end
	end

endmodule
```

---

# 오답노트 3 — "1011" Overlap 시퀀스 디텍터 (15번)

**핵심 개념**: overlap 허용 FSM은 매 상태에서 "지금까지 매칭된 접미사(suffix) 중 패턴의 접두사(prefix)와 가장 길게 겹치는 지점"으로 돌아가야 함. 매칭 실패/성공 시 무조건 IDLE로 안 돌아가고, 방금 본 입력이 다음 매칭의 시작이 될 수 있는지부터 체크.

```verilog
case (p_state)
    p_IDLE   : n_state = (din == 1) ? p_State1 : p_IDLE;
    p_State1 : n_state = (din == 1) ? p_State1 : p_State2;   // 1 유지
    p_State2 : n_state = (din == 1) ? p_State3 : p_IDLE;
    p_State3 : n_state = (din == 1) ? p_State4 : p_State2;   // overlap
    p_State4 : n_state = (din == 1) ? p_State1 : p_State2;   // detect 후에도 이어서
endcase
```

## 21. "1011" Non-overlap 버전 (5분) 같은 패턴이지만 이번엔 overlap 미허용 — 패턴이 매치되면 무조건 IDLE로 리셋하고 처음부터 다시 찾으세요. (15번 원래 코드가 사실 이 스펙이었다면 정답이었음 — 조건 차이를 몸으로 느껴보는 문제)

```verilog
module seq_detect_1011_nooverlap(
    input  logic clk,
    input  logic rst_n,
    input  logic din,
    output logic detect
);

endmodule
```

## 22. "101" Overlap 시퀀스 디텍터 (5분) 패턴을 "101"로 바꿔서 overlap 허용 버전을 다시 설계하세요. (힌트: "10101"처럼 겹치는 입력에서 두 번 검출돼야 함)

```verilog
module seq_detect_101(
    input  logic clk,
    input  logic rst_n,
    input  logic din,
    output logic detect
);

endmodule
```

## 23. "1011" Mealy 버전 (6분) 15번을 Moore가 아닌 Mealy로 다시 설계하세요 (output이 state뿐 아니라 현재 input에도 즉시 반응 — 보통 1클럭 더 빨리 detect가 뜸). Moore와 Mealy의 타이밍 차이를 직접 비교해보는 게 목적입니다.

```verilog
module seq_detect_1011_mealy(
    input  logic clk,
    input  logic rst_n,
    input  logic din,
    output logic detect
);

endmodule
```**19. 3-FF Synchronizer (4분)** 2단 대신 3단으로 확장해서 안정성을 더 높인 버전을 짜세요. (메타스테이블 확률을 더 낮추고 싶을 때 씀)

```verilog
module sync3ff(
    input  logic clk,
    input  logic rst_n,
    input  logic async_in,
    output logic sync_out
);

endmodule
```
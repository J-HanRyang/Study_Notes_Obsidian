# Part 1. 기본기 워밍업 (TSN Lab 스타일)

## 1. Inverter (3분)

```verilog
module inv(
    input  logic [3:0] a,
    output logic [3:0] y
);
    // inverter

endmodule
```

## 2. Logic Gates — AND, OR, XOR, NAND, NOR (3분)

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

endmodule
```

## 3. Multiplexer (3분)

```verilog
module mux2(
    input  logic [3:0] d0, d1,
    input  logic       s,
    output logic [3:0] y
);
    // 2:1 multiplexer

endmodule
```

## 4. Register (5분)

```verilog
module flop(
    input  logic       clk,
    input  logic [3:0] d,
    output logic [3:0] q
);
    // D flip-flop

endmodule
```

## 5. 3:8 Decoder (5분)

```verilog
module decoder3_8(
    input  logic [2:0] a,
    output logic [7:0] y
);
    // 3:8 decoder

endmodule
```

---

# Part 2. 조합논리 추가

## 6. 4-bit 크기 비교기 (3분)

a > b, a == b, a < b 세 가지 출력을 만드세요.

```verilog
module comparator4(
    input  logic [3:0] a, b,
    output logic gt, eq, lt
);

endmodule
```

## 7. 4:1 Priority Encoder (4분)

입력 중 가장 높은 비트 위치의 인덱스를 출력하세요 (입력이 모두 0이면 valid=0).

```verilog
module priority_enc4(
    input  logic [3:0] in,
    output logic [1:0] idx,
    output logic       valid
);

endmodule
```

---

# Part 3. 순차논리

## 8. 동기 리셋 + Enable D-FF (4분)

```verilog
module flop_en_rst(
    input  logic       clk,
    input  logic       rst_n,   // active-low sync reset
    input  logic       en,
    input  logic [3:0] d,
    output logic [3:0] q
);

endmodule
```

## 9. 4-bit SIPO Shift Register (5분)

매 클럭 `sin`을 LSB로 밀어넣는 시프트 레지스터.

```verilog
module sipo4(
    input  logic       clk,
    input  logic       rst_n,
    input  logic       sin,
    output logic [3:0] q
);

endmodule
```

## 10. Rising Edge Detector (4분)

1클럭짜리 펄스를 입력 신호의 상승 엣지에서 출력하세요.

```verilog
module edge_detect(
    input  logic clk,
    input  logic rst_n,
    input  logic sig_in,
    output logic pulse
);

endmodule
```

## 11. 2-FF Synchronizer (CDC) (4분)

비동기 입력 `async_in`을 `clk` 도메인으로 동기화하세요.

```verilog
module sync2ff(
    input  logic clk,
    input  logic rst_n,
    input  logic async_in,
    output logic sync_out
);

endmodule
```

---

# Part 4. Counter

## 12. Mod-6 Up Counter (5분)

0~5까지 카운트하고 6이 되면 0으로 롤오버.

```verilog
module counter_mod6(
    input  logic       clk,
    input  logic       rst_n,
    output logic [2:0] cnt
);

endmodule
```

## 13. Up/Down Counter (5분)

`updown = 1`이면 증가, `0`이면 감소.

```verilog
module updown_counter(
    input  logic       clk,
    input  logic       rst_n,
    input  logic       updown,
    output logic [3:0] cnt
);

endmodule
```

---

# Part 5. FSM

## 14. 신호등 컨트롤러 (Moore, 6~7분)

RED(2clk) → GREEN(3clk) → YELLOW(1clk) → RED 순환.

```verilog
module traffic_light(
    input  logic       clk,
    input  logic       rst_n,
    output logic [1:0] light  // 00=RED, 01=GREEN, 10=YELLOW
);

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
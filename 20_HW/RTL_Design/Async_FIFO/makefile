# 컴파일러 설정
CC      = gcc
IV      = iverilog
GTK 	= gtkwave
VVP     = vvp

# 파라미터 설정
DATA_WIDTH = 32
FIFO_DEPTH = 4
PTR_WIDTH  = 2
LOOP_COUNT = 100

# 경로 설정
MODEL   = model/async_fifo.c
TB      = tb/tb_async_fifo.sv
RTL     = rtl/async_fifo.sv
CMP     = sim/compare.c
FILES   = files.f
SIM_OUT = sim/sim.out

.PHONY: all model sim compare clean

all: model sim compare

# C 모델 실행
model:
	$(CC) -DDATA_WIDTH=$(DATA_WIDTH) \
	      -DFIFO_DEPTH=$(FIFO_DEPTH) \
	      -DPTR_WIDTH=$(PTR_WIDTH) \
	      -DLOOP_COUNT=$(LOOP_COUNT) \
		  -o model/async_fifo.exe $(MODEL)
	./model/async_fifo.exe

# iverilog 컴파일 -> vvp 실행
sim:
	$(IV) -g2012 -s tb_async_fifo -o $(SIM_OUT) \
		-DDATA_WIDTH_DEF=$(DATA_WIDTH) \
		-DFIFO_DEPTH_DEF=$(FIFO_DEPTH) \
		-f $(FILES)
	$(VVP) $(SIM_OUT)

# wave.vcd 파일을 GTKWave로 열기
wave:
	$(GTK) ./sim/wave.vcd &
	
# compare 실행
compare:
	$(CC) -DTOTAL_COUNT=$(LOOP_COUNT) \
		-o model/compare.exe $(CMP)
		./model/compare.exe

clean:
	rm -f $(SIM_OUT) \
	      model/async_fifo.exe \
	      model/compare.exe \
	      sim/stimulus.txt \
	      sim/golden_output.txt \
	      sim/dut_output.txt \
	      sim/async_fifo.vcd \
	      sim/compare.exe \
	      sim/wave.vcd
# 컴파일러 설정
CC      = gcc
IV      = iverilog
VVP     = vvp

# 파라미터 설정
DATA_WIDTH = 32
FIFO_DEPTH = 4

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
	$(CC) -o model/async_fifo.exe $(MODEL)
	./model/async_fifo.exe

# iverilog 컴파일 -> vvp 실행
sim:
	$(IV) -g2012 -s tb_async_fifo -o $(SIM_OUT) \
		-P tb_async_fifo.DATA_WIDTH=$(DATA_WIDTH) \
		-P tb_async_fifo.FIFO_DEPTH=$(FIFO_DEPTH) \
		-f $(FILES)
	$(VVP) $(SIM_OUT)

# compare 실행
compare:
	$(CC) -o model/compare.exe $(CMP)
	./model/compare.exe

clean:
	rm -f $(SIM_OUT) model/async_fifo.exe model/compare.exe
	rm -f sim/stimulus.txt sim/golden_output.txt sim/dut_output.txt sim/async_fifo.vcd
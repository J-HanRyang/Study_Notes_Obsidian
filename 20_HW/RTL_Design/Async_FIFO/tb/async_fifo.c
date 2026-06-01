#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#define DATA_WIDTH 32
#define FIFO_DEPTH 4
#define PTR_WIDTH 2

typedef struct
{
	uint32_t fifo_mem[FIFO_DEPTH]; // fifo memory
	uint32_t wr_ptr;			   // write pointer
	uint32_t rd_ptr;			   // read pointer
	uint32_t wr_ptr_gray;		   // write pointer in gray code
	uint32_t rd_ptr_gray;		   // read pointer in gray code
} async_fifo_t;

int fifo_full(async_fifo_t *f);					  // always_comb - full 판별
int fifo_empty(async_fifo_t *f);				  // always_comb - empty 판별
void fifo_write(async_fifo_t *f, uint32_t wdata); // wr_en 처리
void fifo_read(async_fifo_t *f);				  // rd_en 처리

int main()
{
	async_fifo_t fifo = {0}; // fifo 초기화

	FILE *fp = fopen("stimulus.txt", "w");
	srand(42);

	for (int i=0; i<20; i++) {
		int cmd = rand() % 2; // 0: write, 1: read
		int data = rand() % 100; // random data

		FILE *input_fp = fopen("input.txt", "a");

		if (cmd == 0) {
			fprintf(fp, "WRITE %d\n", data);
		} else {
			fprintf(fp, "READ\n");
		}
	}
	


	// 데이터 쓰기
	fifo_write(&fifo, 10);
	fifo_write(&fifo, 20);
	fifo_write(&fifo, 30);
	fifo_write(&fifo, 40);
	fifo_write(&fifo, 50);

	// 데이터 읽기
	fifo_read(&fifo);
	fifo_read(&fifo);
	fifo_read(&fifo);
	fifo_read(&fifo);
	fifo_read(&fifo);

	return 0;
}

int fifo_full(async_fifo_t *f)
{
	if (f->wr_ptr_gray == (f->rd_ptr_gray ^ (3 << (PTR_WIDTH - 1))))
		return 1; // fifo full
	else
		return 0; // fifo not full
}

int fifo_empty(async_fifo_t *f)
{
	if (f->wr_ptr_gray == f->rd_ptr_gray)
		return 1; // fifo empty
	else
		return 0; // fifo not empty
}

void fifo_write(async_fifo_t *f, uint32_t wdata)
{
	if (!fifo_full(f))
	{
		f->fifo_mem[f->wr_ptr & (FIFO_DEPTH - 1)] = wdata;
		f->wr_ptr = (f->wr_ptr + 1) & ((1 << (PTR_WIDTH + 1)) - 1);
		f->wr_ptr_gray = f->wr_ptr ^ (f->wr_ptr >> 1);
		printf("WRITE: data=%u, wr_ptr=%u, rd_ptr=%u, full=%d, empty=%d\n",
			   wdata, f->wr_ptr, f->rd_ptr, fifo_full(f), fifo_empty(f));
	}
	else
		printf("FIFO is full. Cannot write data=%u\n", wdata);
}

void fifo_read(async_fifo_t *f)
{
	if (!fifo_empty(f))
	{
		uint32_t rdata = f->fifo_mem[f->rd_ptr & (FIFO_DEPTH - 1)];
		printf("READ: data=%u, wr_ptr=%u, rd_ptr=%u, full=%d, empty=%d\n",
			   rdata, f->wr_ptr, f->rd_ptr, fifo_full(f), fifo_empty(f));
		f->rd_ptr = (f->rd_ptr + 1) & ((1 << (PTR_WIDTH + 1)) - 1);
		f->rd_ptr_gray = f->rd_ptr ^ (f->rd_ptr >> 1);
	}
	else
		printf("FIFO is empty. Cannot read data\n");
}
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#ifndef DATA_WIDTH
#define DATA_WIDTH 32
#endif

#ifndef FIFO_DEPTH
#define FIFO_DEPTH 4
#endif

#ifndef PTR_WIDTH
#define PTR_WIDTH 2
#endif

#ifndef LOOP_COUNT
#define LOOP_COUNT 20
#endif

typedef struct
{
	uint32_t fifo_mem[FIFO_DEPTH]; // fifo memory
	uint32_t wr_ptr;			   // write pointer
	uint32_t rd_ptr;			   // read pointer
	uint32_t wr_ptr_gray;		   // write pointer in gray code
	uint32_t rd_ptr_gray;		   // read pointer in gray code
} async_fifo_t;

int fifo_full(async_fifo_t *f);					 // always_comb - full 판별
int fifo_empty(async_fifo_t *f);				 // always_comb - empty 판별
int fifo_write(async_fifo_t *f, uint32_t wdata); // wr_en 처리
int fifo_read(async_fifo_t *f, uint32_t *rdata); // rd_en 처리

int main()
{
	async_fifo_t fifo = {0}; // fifo 초기화

	FILE *fp = fopen("./sim/stimulus.txt", "w");			 // tb input stimulus 파일
	FILE *output_fp = fopen("./sim/golden_output.txt", "w"); // tb output과 비교할 golden output 파일

	srand(42);

	int prev_full = 0;
	int prev_empty = 0;

	for (int i = 0; i < LOOP_COUNT; i++)
	{
		uint32_t cmd = rand() % 2;	  // 0: write, 1: read
		uint32_t data = rand() % 100; // random data

		if (cmd == 0) // WRITE
		{
			fprintf(fp, "WRITE %u\n", data);

			if (fifo_write(&fifo, data))
			{
				fprintf(output_fp, "WRITE: data=%u\n", data);
			}
			else
			{
				fprintf(output_fp, "WRITE FAIL (full): data=%u\n", data);
			}
		}
		else // READ
		{
			fprintf(fp, "READ\n");
			uint32_t rdata = 0;

			if (fifo_read(&fifo, &rdata))
			{
				fprintf(output_fp, "READ : data=%u\n", rdata);
			}
			else
			{
				fprintf(output_fp, "READ FAIL (empty)\n");
			}
		}

		// Full감지 -> READ이후 WAIT
		int cur_full = fifo_full(&fifo);

		if ((prev_full && !cur_full))
		{
			fprintf(fp, "WR_WAIT\n");
		}

		// Empty감지 -> WRITE이후 WAIT
		int cur_empty = fifo_empty(&fifo);

		if ((prev_empty && !cur_empty))
		{
			fprintf(fp, "RD_WAIT\n");
		}

		prev_full = fifo_full(&fifo);
		prev_empty = fifo_empty(&fifo);
	}

	fclose(fp);
	fclose(output_fp);

	printf("stimulus.txt 생성 완료!\n");
	printf("golden_output.txt 생성 완료!\n");

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

int fifo_write(async_fifo_t *f, uint32_t wdata)
{
	if (!fifo_full(f))
	{
		f->fifo_mem[f->wr_ptr & (FIFO_DEPTH - 1)] = wdata;
		f->wr_ptr = (f->wr_ptr + 1) & ((1 << (PTR_WIDTH + 1)) - 1);
		f->wr_ptr_gray = f->wr_ptr ^ (f->wr_ptr >> 1);
		return 1;
	}
	else
		return 0;
}

int fifo_read(async_fifo_t *f, uint32_t *rdata)
{
	if (!fifo_empty(f))
	{
		*rdata = f->fifo_mem[f->rd_ptr & (FIFO_DEPTH - 1)];
		f->rd_ptr = (f->rd_ptr + 1) & ((1 << (PTR_WIDTH + 1)) - 1);
		f->rd_ptr_gray = f->rd_ptr ^ (f->rd_ptr >> 1);
		return 1;
	}
	else
		return 0;
}
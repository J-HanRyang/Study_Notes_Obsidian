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

int fifo_full(async_fifo_t *f){
	
}
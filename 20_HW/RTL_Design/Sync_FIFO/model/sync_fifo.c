#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#define DATA_WIDTH 32
#define FIFO_DEPTH 4
#define PTR_WIDTH log2(FIFO_DEPTH);

typedef struct
{
    uint32_t mem[FIFO_DEPTH]; // fifo memory
    uint32_t wr_ptr;          // write pointer
    uint32_t rd_ptr;          // read pointer
} sync_fifo_t;

int fifo_full(sync_fifo_t *f);                   // always_comb - full 판별
int fifo_empty(sync_fifo_t *f);                  // always_comb - empty 판별
void fifo_write(sync_fifo_t *f, uint32_t wdata); // wr_en 처리
void fifo_read(sync_fifo_t *f);                  // rd_en 처리

int fifo_full(sync_fifo_t *f)
{
    if (f->wr_ptr == (f->rd_ptr ^ (1 << PTR_WIDTH)))
        return 1; // fifo full
    else
        return 0; // fifo not full
}

int fifo_empty(sync_fifo_t *f)
{
    if (f->wr_ptr == f->rd_ptr)
        return 1; // fifo empty
    else
        return 0; // fifo not empty
}
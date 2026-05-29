#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#define DATA_WIDTH 32
#define FIFO_DEPTH 4
#define PTR_WIDTH 2

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

int main()
{
    sync_fifo_t fifo = {0}; // fifo 초기화

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

// fifo full 판별
int fifo_full(sync_fifo_t *f)
{
    if (f->wr_ptr == (f->rd_ptr ^ (1 << PTR_WIDTH)))
        return 1; // fifo full
    else
        return 0; // fifo not full
}

// fifo empty 판별
int fifo_empty(sync_fifo_t *f)
{
    if (f->wr_ptr == f->rd_ptr)
        return 1; // fifo empty
    else
        return 0; // fifo not empty
}

// wr_en 처리
void fifo_write(sync_fifo_t *f, uint32_t wdata)
{
    if (!fifo_full(f))
    {
        f->mem[f->wr_ptr & (FIFO_DEPTH - 1)] = wdata;
        f->wr_ptr = (f->wr_ptr + 1) & ((1 << (PTR_WIDTH + 1)) - 1);
        printf("WRITE: data=%u, wr_ptr=%u, rd_ptr=%u, full=%d, empty=%d\n",
               wdata, f->wr_ptr, f->rd_ptr, fifo_full(f), fifo_empty(f));
    }
    else
    {
        printf("WRITE FAIL (full): data=%u\n", wdata);
    }
}

// rd_en 처리
void fifo_read(sync_fifo_t *f)
{
    if (!fifo_empty(f))
    {
        uint32_t rdata = f->mem[f->rd_ptr & (FIFO_DEPTH - 1)];
        printf("READ: data=%u, wr_ptr=%u, rd_ptr=%u, full=%d, empty=%d\n",
               rdata, f->wr_ptr, f->rd_ptr, fifo_full(f), fifo_empty(f));
        f->rd_ptr = (f->rd_ptr + 1) & ((1 << (PTR_WIDTH + 1)) - 1);
    }
    else
    {
        printf("READ FAIL (empty)\n");
    }
}
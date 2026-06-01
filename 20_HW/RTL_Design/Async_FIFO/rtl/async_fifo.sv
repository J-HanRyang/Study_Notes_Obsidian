module async_fifo #(
    parameter DATA_WIDTH = 32,
    parameter FIFO_DEPTH = 4
) (
    input  logic                  clk_wr,
    input  logic                  rst_n_wr,
    input  logic                  wr_en,
    input  logic [DATA_WIDTH-1:0] wr_data,
    input  logic                  clk_rd,
    input  logic                  rst_n_rd,
    input  logic                  rd_en,
    output logic [DATA_WIDTH-1:0] rd_data,
    output logic                  full,
    output logic                  empty
);

    localparam PTR_WIDTH = $clog2(FIFO_DEPTH);

    logic [DATA_WIDTH-1:0] fifo_mem[0:FIFO_DEPTH-1];
    // Write and Read pointers
    logic [   PTR_WIDTH:0] wr_ptr;
    logic [   PTR_WIDTH:0] rd_ptr;
    // Gray code pointers
    logic [   PTR_WIDTH:0] wr_ptr_gray;
    logic [   PTR_WIDTH:0] rd_ptr_gray;
    // rd_clk domain pointers
    logic [   PTR_WIDTH:0] wr_ptr_gray_sync_0;
    logic [   PTR_WIDTH:0] wr_ptr_gray_sync_1;
    // wr_clk domain pointers
    logic [   PTR_WIDTH:0] rd_ptr_gray_sync_0;
    logic [   PTR_WIDTH:0] rd_ptr_gray_sync_1;

    // Write operation
    always_ff @(posedge clk_wr, negedge rst_n_wr) begin
        if (!rst_n_wr) begin
            wr_ptr <= 0;
            wr_ptr_gray <= 0;
        end else if (wr_en && !full) begin
            fifo_mem[wr_ptr[PTR_WIDTH-1:0]] <= wr_data;
            wr_ptr <= wr_ptr + 1;
            wr_ptr_gray <= (wr_ptr + 1) ^ ((wr_ptr + 1) >> 1); // Convert to Gray code
        end
    end

    // Read operation
    always_ff @(posedge clk_rd, negedge rst_n_rd) begin
        if (!rst_n_rd) begin
            rd_ptr <= 0;
            rd_ptr_gray <= 0;
        end else if (rd_en && !empty) begin
            rd_data <= fifo_mem[rd_ptr[PTR_WIDTH-1:0]];
            rd_ptr <= rd_ptr + 1;
            rd_ptr_gray <= (rd_ptr + 1) ^ ((rd_ptr + 1) >> 1); // Convert to Gray code
        end
    end

    // 2-stage Synchronizer
    always_ff @(posedge clk_rd, negedge rst_n_rd) begin
        if (!rst_n_rd) begin
            wr_ptr_gray_sync_0 <= 0;
            wr_ptr_gray_sync_1 <= 0;
        end else begin
            wr_ptr_gray_sync_0 <= wr_ptr_gray;
            wr_ptr_gray_sync_1 <= wr_ptr_gray_sync_0;
        end
    end

    always_ff @(posedge clk_wr, negedge rst_n_wr) begin
        if (!rst_n_wr) begin
            rd_ptr_gray_sync_0 <= 0;
            rd_ptr_gray_sync_1 <= 0;
        end else begin
            rd_ptr_gray_sync_0 <= rd_ptr_gray;
            rd_ptr_gray_sync_1 <= rd_ptr_gray_sync_0;
        end
    end

    // full and empty flags
    assign empty = (wr_ptr_gray_sync_1 == rd_ptr_gray);
    assign full  = (wr_ptr_gray == {~rd_ptr_gray_sync_1[PTR_WIDTH:PTR_WIDTH-1], rd_ptr_gray_sync_1[PTR_WIDTH-2:0]});

endmodule

module tb_async_fifo;
    // Parameters & Signals
    localparam DATA_WIDTH = 32;
    localparam FIFO_DEPTH = 4;

    logic clk;
    logic rst_n;
    logic wr_en;
    logic rd_en;
    logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH-1:0] rdata;
    logic full;
    logic empty;

    // DUT Instance
    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) dut (
        .clk  (clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .wdata(wdata),
        .rdata(rdata),
        .full (full),
        .empty(empty)
    );

endmodule
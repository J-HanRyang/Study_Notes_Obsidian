module tb_async_fifo;
    // Parameters & Signals
    localparam DATA_WIDTH = 32;
    localparam FIFO_DEPTH = 4;

    logic                  clk_wr;
    logic                  rst_n_wr;
    logic                  wr_en;
    logic [DATA_WIDTH-1:0] wr_data;
    logic                  clk_rd;
    logic                  rst_n_rd;
    logic                  rd_en;
    logic [DATA_WIDTH-1:0] rd_data;
    logic                  full;
    logic                  empty;

    // DUT Instance
    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) dut (
        .clk_wr  (clk_wr),
        .rst_n_wr(rst_n_wr),
        .wr_en   (wr_en),
        .wr_data (wr_data),
        .clk_rd  (clk_rd),
        .rst_n_rd(rst_n_rd),
        .rd_en   (rd_en),
        .rd_data (rd_data),
        .full    (full),
        .empty   (empty)
    );

    // Clock Generation
    initial begin
        clk_wr = 0;
        clk_rd = 0;
        forever #5 clk_wr = ~clk_wr;  // 100MHz clock
        forever #10 clk_rd = ~clk_rd;  // 200MHz clock
    end
endmodule

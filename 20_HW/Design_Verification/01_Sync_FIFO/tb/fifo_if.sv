interface fifo_if #(
    parameter DATA_WIDTH = 32,
    parameter FIFO_DEPTH = 4
) (
    input logic clk
);

    logic                  rst_n;
    logic                  wr_en;
    logic                  rd_en;
    logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH-1:0] rdata;
    logic                  full;
    logic                  empty;

endinterface  //fifo_if

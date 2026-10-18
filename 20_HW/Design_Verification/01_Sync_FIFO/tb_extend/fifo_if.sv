interface fifo_if #(
    parameter DATA_WIDTH = 32,
    parameter FIFO_DEPTH = 4
) (input logic clk);
    logic rst_n;
    logic wr_en, rd_en;
    logic [DATA_WIDTH-1:0] wdata, rdata;
    logic full, empty;

    // TB-only tag: completion tracking; never connected to DUT.
    int unsigned request_id = 0;
endinterface : fifo_if

module sync_fifo #(
    parameter DATA_WIDTH = 32,
    parameter FIFO_DEPTH = 4
) (
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  wr_en,
    input  wire                  rd_en,
    input  wire [DATA_WIDTH-1:0] data_sin,
    output reg  [DATA_WIDTH-1:0] data_out,
    output reg                   full,
    output reg                   empty
);

endmodule

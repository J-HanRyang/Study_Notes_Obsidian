// Protocol/storage invariants. Scoreboard separately checks all actual data.
module fifo_assertions #(
    parameter int DATA_WIDTH = 32,
    parameter int FIFO_DEPTH = 4,
    parameter int PTR_BITS = $clog2(FIFO_DEPTH) + 1
) (
    input logic clk, rst_n, wr_en, rd_en, full, empty,
    input logic [DATA_WIDTH-1:0] rdata,
    input logic [PTR_BITS-1:0] wr_ptr, rd_ptr
);
    timeunit 1ns;
    timeprecision 1ps;
    logic sampled_reset;
    logic [PTR_BITS-1:0] wr_before, rd_before;
    logic [DATA_WIDTH-1:0] data_before;
    bit aw, ar;

    assert property (@(posedge clk) disable iff (!rst_n) !(full && empty))
        else $fatal(1, "ASSERT: full and empty asserted together");

    initial forever begin
        @(posedge clk);
        sampled_reset = rst_n;
        wr_before = wr_ptr;
        rd_before = rd_ptr;
        data_before = rdata;
        aw = wr_en && !full;
        ar = rd_en && !empty;
        @(negedge clk);
        if (!sampled_reset) begin
            assert (wr_ptr == 0 && rd_ptr == 0 && rdata == 0 && empty && !full)
                else $fatal(1, "ASSERT: reset state incorrect");
        end else if (rst_n) begin
            assert (wr_ptr == wr_before + PTR_BITS'(aw))
                else $fatal(1, "ASSERT: write pointer step incorrect");
            assert (rd_ptr == rd_before + PTR_BITS'(ar))
                else $fatal(1, "ASSERT: read pointer step incorrect");
            if (!ar) assert (rdata == data_before)
                else $fatal(1, "ASSERT: rdata changed without an accepted read");
        end
    end
endmodule : fifo_assertions

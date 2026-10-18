module top;
    timeunit 1ns;
    timeprecision 1ps;
    import uvm_pkg::*;
    import fifo_pkg::*;

    logic clk = 0;
    always #5 clk = ~clk;
    fifo_if #(.DATA_WIDTH(32), .FIFO_DEPTH(FIFO_DEPTH)) vif(clk);

    sync_fifo #(.DATA_WIDTH(32), .FIFO_DEPTH(FIFO_DEPTH)) dut (
        .clk(clk), .rst_n(vif.rst_n),
        .wr_en(vif.wr_en), .rd_en(vif.rd_en), .wdata(vif.wdata),
        .rdata(vif.rdata), .full(vif.full), .empty(vif.empty)
    );

    fifo_assertions #(.FIFO_DEPTH(FIFO_DEPTH)) checks (
        .clk(clk), .rst_n(vif.rst_n),
        .wr_en(vif.wr_en), .rd_en(vif.rd_en),
        .full(vif.full), .empty(vif.empty), .rdata(vif.rdata),
        .wr_ptr(dut.wr_ptr), .rd_ptr(dut.rd_ptr)
    );

    // Reset is now owned exclusively by driver, for repeatable reset scenarios.
    initial begin
        uvm_config_db#(virtual fifo_if)::set(
            null, "uvm_test_top.env.agt.*", "vif", vif);
        run_test("fifo_test");
    end

    initial begin
        if ($test$plusargs("WAVES")) begin
            $dumpfile("fifo.vcd");
            $dumpvars(0, top);
        end
    end

    initial begin
        #100us;
        $fatal(1, "Simulation timeout: request or completion path is stuck");
    end
endmodule : top

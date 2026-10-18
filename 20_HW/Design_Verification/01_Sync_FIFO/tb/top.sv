module top;
    timeunit 1ns;
    timeprecision 1ps;
    import uvm_pkg::*;
    import fifo_pkg::*;

    logic clk = 0;
    always #5 clk = ~clk;
    fifo_if vif(clk);

    sync_fifo #(.DATA_WIDTH(32), .FIFO_DEPTH(4)) dut (
        .clk(clk), .rst_n(vif.rst_n),
        .wr_en(vif.wr_en), .rd_en(vif.rd_en), .wdata(vif.wdata),
        .rdata(vif.rdata), .full(vif.full), .empty(vif.empty)
    );

    initial begin
        vif.rst_n = 0;
        repeat (3) @(negedge clk);
        vif.rst_n <= 1;
    end

    initial begin
        uvm_config_db#(virtual fifo_if)::set(
            null, "uvm_test_top.env.agt.*", "vif", vif);
        run_test("fifo_test");
    end

    initial begin
        #10us;
        $fatal(1, "Simulation timeout");
    end
endmodule : top

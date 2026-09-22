module tb_sync_fifo;
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
    sync_fifo #(
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

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock
    end

    // Test Sequence
    initial begin
        // Reset
        rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        wdata = 0;

        @(posedge clk);
        @(posedge clk);
        #1;  // Setup Time 
        rst_n = 1;

        // write
        fifo_write(10);
        fifo_write(20);
        fifo_write(30);
        fifo_write(40);
        fifo_write(50);

        // read
        fifo_read();
        fifo_read();
        fifo_read();
        fifo_read();
        fifo_read();

        $finish;
    end

    task fifo_write(input logic [DATA_WIDTH-1:0] data);
        if (!full) begin
            @(posedge clk);
            #1;
            wdata = data;
            wr_en = 1;
            @(posedge clk);
            #1;
            wr_en = 0;
            $display(
                "WRITE: data=%0d, wr_ptr=%0d, rd_ptr=%0d, full=%0b, empty=%0b",
                data, dut.wr_ptr, dut.rd_ptr, full, empty);
        end else begin
            $display("WRITE FAIL (full): data=%0d", data);
        end
    endtask

    task fifo_read();
        if (!empty) begin
            @(posedge clk);
            #1;
            rd_en = 1;
            @(posedge clk);
            #1;
            rd_en = 0;
            $display(
                "READ: data=%0d, wr_ptr=%0d, rd_ptr=%0d, full=%0b, empty=%0b",
                rdata, dut.wr_ptr, dut.rd_ptr, full, empty);
            @(posedge clk);
        end else begin
            $display("READ FAIL (empty)");
        end
    endtask
endmodule

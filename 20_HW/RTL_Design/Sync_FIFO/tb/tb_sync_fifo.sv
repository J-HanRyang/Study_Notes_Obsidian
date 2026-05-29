module tb_sync_fifo;
    logic clk;
    logic rst_n;
    logic wr_en;
    logic rd_en;
    logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH-1:0] rdata;
    logic full;
    logic empty;

    // Parameters
    localparam DATA_WIDTH = 32;
    localparam FIFO_DEPTH = 4;

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
    end

    task fifo_write(input logic [DATA_WIDTH-1:0] data);
        if (!fifo_full) begin
			wdata = data;
			wr_en = 1;
		end
    endtask

    task fifo_read();
        if (!fifo_empty)
    endtask
endmodule

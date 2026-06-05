`timescale 1ns / 1ps

module tb_async_fifo;
    // Parameters & Signals
`ifdef DATA_WIDTH_DEF
    localparam DATA_WIDTH = `DATA_WIDTH_DEF;
`else
    localparam DATA_WIDTH = 32;
`endif

`ifdef FIFO_DEPTH_DEF
    localparam FIFO_DEPTH = `FIFO_DEPTH_DEF;
`else
    localparam FIFO_DEPTH = 4;
`endif

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

    // 200MHZ WriteClock Generation
    initial begin
        clk_wr = 0;
        forever #2.5 clk_wr = ~clk_wr;
    end

    // 100MHz ReadClock Generation
    initial begin
        clk_rd = 0;
        forever #5 clk_rd = ~clk_rd;
    end

    integer fd_in;  // stimulus inputs
    integer fd_out;  // DUT outputs (for debugging)
    string cmd;
    logic [DATA_WIDTH-1:0] data;

    // Test Sequence
    initial begin
        // Dumpfile
        $dumpfile("./sim/wave.vcd");
        $dumpvars(0, tb_async_fifo);

        // Reset
        rst_n_wr = 0;
        rst_n_rd = 0;
        wr_en = 0;
        rd_en = 0;
        wr_data = 0;

        // Reset timeng 맞추기 위해 fork-join 사용
        fork
            // Write Clock Reset
            begin
                @(posedge clk_wr);
                #1;
                rst_n_wr = 1;
            end
            // Read Clock Reset
            begin
                @(posedge clk_rd);
                #1;
                rst_n_rd = 1;
            end
        join

        // Open stimulus file
        fd_in  = $fopen("./sim/stimulus.txt", "r");
        fd_out = $fopen("./sim/dut_output.txt", "w");

        if (fd_in == 0 || fd_out == 0) begin
            $display("Failed to open files.");
            $finish;
        end

        while (!$feof(
            fd_in
        )) begin
            // 파일에서 한 줄 읽기
            $fscanf(fd_in, "%s %d\n", cmd, data);

            if (cmd == "WRITE") begin
                // Task를 활용하여 clk_wr 도메인으로 안전하게 인가
                fifo_write(data);
            end else if (cmd == "READ") begin
                // Task를 활용하여 clk_rd 도메인으로 안전하게 인가
                fifo_read();
            end else if (cmd == "WR_WAIT") begin
                @(negedge full);
                @(posedge clk_wr);
            end else if (cmd == "RD_WAIT") begin
                @(negedge empty);
                @(posedge clk_rd);
            end
        end

        $fclose(fd_in);
        $fclose(fd_out);
        #100;  // wait
        $display("Test Completed.");
        $display("dut_output.txt generated.");

        $finish;
    end

    // Write Monitor
    always @(posedge clk_wr) begin
        if (rst_n_wr && wr_en && !full) begin
            $fdisplay(fd_out, "WRITE: data=%0d @ %0t", wr_data, $time);
        end else if (rst_n_wr && wr_en && full) begin
            $fdisplay(fd_out, "WRITE FAIL (full): data=%0d @ %0t", wr_data,
                      $time);
        end
    end

    // Read Monitor
    always @(posedge clk_rd) begin
        if (rst_n_rd && rd_en && !empty) begin
            $fdisplay(fd_out, "READ : data=%0d @ %0t", rd_data, $time);
        end else if (rst_n_rd && rd_en && empty) begin
            $fdisplay(fd_out, "READ FAIL (empty) @ %0t", $time);
        end
    end

    // Verification Tasks
    task fifo_write(input logic [DATA_WIDTH-1:0] data);
        begin
            @(posedge clk_wr);
            #1;  // Setup Time
            wr_en   = 1;
            wr_data = data;
            @(posedge clk_wr);
            #1;  // Hold Time
            wr_en = 0;
        end
    endtask

    task fifo_read();
        begin
            @(posedge clk_rd);
            #1;  // Setup Time
            rd_en = 1;
            @(posedge clk_rd);
            #1;  // Hold Time
            rd_en = 0;
        end
    endtask

endmodule

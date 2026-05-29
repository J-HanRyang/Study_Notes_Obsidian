module sync_fifo #(
    parameter DATA_WIDTH = 32,
    parameter FIFO_DEPTH = 4
) (
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  wr_en,
    input  logic                  rd_en,
    input  logic [DATA_WIDTH-1:0] wdata,
    output logic [DATA_WIDTH-1:0] rdata,
    output logic                  full,
    output logic                  empty
);

    localparam PTR_WIDTH = $clog2(FIFO_DEPTH);

    logic [DATA_WIDTH-1:0] fifo_mem[0:FIFO_DEPTH-1];
    logic [   PTR_WIDTH:0] wr_ptr;
    logic [   PTR_WIDTH:0] rd_ptr;

    // Write and Read operations
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            rdata  <= 0;
        end else begin
            // Write operation
            if (wr_en && !full) begin
                fifo_mem[wr_ptr[PTR_WIDTH-1:0]] <= wdata;
                wr_ptr <= wr_ptr + 1;
            end

            // Read operation
            if (rd_en && !empty) begin
                rdata  <= fifo_mem[rd_ptr[PTR_WIDTH-1:0]];
                rd_ptr <= rd_ptr + 1;
            end
        end
    end

    // full and empty flags
    always_comb begin
        empty = (wr_ptr == rd_ptr);
        full  = (wr_ptr == {~rd_ptr[PTR_WIDTH], rd_ptr[PTR_WIDTH-1:0]});
    end

endmodule
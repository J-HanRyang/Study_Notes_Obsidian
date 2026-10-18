class fifo_seq_item extends uvm_sequence_item;
    `uvm_object_utils(fifo_seq_item)

    // Driver request: one FIFO clock, or a reset command.
    rand bit wr_en;
    rand bit rd_en;
    rand bit [31:0] wdata;
    bit do_reset = 0;

    // Monitor snapshot. full/empty are BEFORE the accepting edge.
    logic rst_n;
    logic [31:0] rdata;
    logic full, empty;
    logic full_after, empty_after;
    int unsigned request_id;

    function new(string name = "fifo_seq_item");
        super.new(name);
    endfunction
endclass : fifo_seq_item

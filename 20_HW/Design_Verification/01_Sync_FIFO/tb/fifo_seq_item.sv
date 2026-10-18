class fifo_seq_item extends uvm_sequence_item;
    `uvm_object_utils(fifo_seq_item)

    rand bit wr_en;
    rand bit rd_en;
    rand bit [31:0] wdata;

    logic [31:0] rdata;
    logic full;
    logic empty;

    function new(string name = "fifo_seq_item");
        super.new(name);
    endfunction
endclass : fifo_seq_item

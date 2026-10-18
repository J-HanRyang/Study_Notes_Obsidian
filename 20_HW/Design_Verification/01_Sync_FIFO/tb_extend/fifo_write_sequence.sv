class fifo_write_sequence extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_write_sequence)

    bit [31:0] data = 32'hA5;

    function new(string name = "fifo_write_sequence");
        super.new(name);
    endfunction

    virtual task body();
        fifo_seq_item fifo_item;
        fifo_item = fifo_seq_item::type_id::create("write_item");

        start_item(fifo_item);
        fifo_item.wr_en = 1;
        fifo_item.rd_en = 0;
        fifo_item.wdata = data;
        finish_item(fifo_item);
    endtask

endclass : fifo_write_sequence

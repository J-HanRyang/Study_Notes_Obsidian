class fifo_read_sequence extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_read_sequence)

    function new(string name = "fifo_read_sequence");
        super.new(name);
    endfunction

    virtual task body();
        fifo_seq_item fifo_item;
        fifo_item = fifo_seq_item::type_id::create("read_item");

        start_item(fifo_item);
        fifo_item.wr_en = 0;
        fifo_item.rd_en = 1;
        fifo_item.wdata = 0;
        finish_item(fifo_item);
    endtask

endclass : fifo_read_sequence

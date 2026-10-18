class fifo_regression_sequence extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_regression_sequence)
    function new(string name = "fifo_regression_sequence");
        super.new(name);
    endfunction

    task send(bit wr, bit rd, bit [31:0] data = 0);
        fifo_seq_item item = fifo_seq_item::type_id::create("directed_item");
        start_item(item);
        item.wr_en = wr;
        item.rd_en = rd;
        item.wdata = data;
        finish_item(item);
    endtask

    task reset_fifo();
        fifo_seq_item item = fifo_seq_item::type_id::create("reset_item");
        start_item(item);
        item.do_reset = 1;
        finish_item(item);
    endtask

    task fill_fifo(bit [31:0] base_data);
        for (int i = 0; i < FIFO_DEPTH; i++) send(1, 0, base_data + 32'(i));
    endtask

    task drain_fifo();
        repeat (FIFO_DEPTH) send(0, 1);
    endtask

    virtual task body();
        fifo_sequence smoke_seq;
        fifo_seq_item random_item;
        // Reuse the nested A5 write/read sequence the user wrote.
        smoke_seq = fifo_sequence::type_id::create("nested_smoke");
        smoke_seq.start(m_sequencer, this);

        `uvm_info("SCENARIO", "empty/full boundaries and simultaneous requests", UVM_LOW)
        send(0, 0);
        send(0, 1);                  // empty read rejected
        send(1, 1, 32'h11);          // empty: write only, no fall-through
        send(0, 1);
        fill_fifo(32'h100);
        send(0, 0);                  // full idle
        send(1, 0, 32'hdead);        // full write rejected
        send(1, 1, 32'hbeef);        // full: read only, write rejected
        send(1, 0, 32'h104);
        drain_fifo();

        send(1, 0, 32'h21);
        send(0, 0);                  // middle idle
        send(1, 1, 32'h22);          // middle: both accepted
        send(1, 0, 32'h23);
        send(0, 1);
        send(0, 1);

        `uvm_info("SCENARIO", "multiple pointer wraps", UVM_LOW)
        repeat (3) begin
            fill_fifo(32'h200);
            drain_fifo();
        end

        `uvm_info("SCENARIO", "reset while partially full, full, and empty", UVM_LOW)
        send(1, 0, 32'h31);
        send(1, 0, 32'h32);
        reset_fifo();
        fill_fifo(32'h300);
        reset_fifo();
        reset_fifo();
        send(1, 0, 32'hA5);
        send(0, 1);

        `uvm_info("SCENARIO", "200 random requests and final drain", UVM_LOW)
        repeat (200) begin
            random_item = fifo_seq_item::type_id::create("random_item");
            start_item(random_item);
            if (random_item.randomize() == 0)
                `uvm_fatal("RANDOMIZE", "Request randomization failed")
            finish_item(random_item);
        end
        drain_fifo();
        send(0, 0);
    endtask
endclass : fifo_regression_sequence

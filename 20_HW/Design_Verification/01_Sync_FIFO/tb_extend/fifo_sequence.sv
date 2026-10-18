class fifo_sequence extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_sequence)

    function new(string name = "fifo_sequence");
        super.new(name);
    endfunction

    virtual task body();
        fifo_write_sequence write_seq;
        fifo_read_sequence  read_seq;

        write_seq = fifo_write_sequence::type_id::create("write_seq");
        read_seq = fifo_read_sequence::type_id::create("read_seq");

        write_seq.data = 32'hA5;
        write_seq.start(m_sequencer, this);
        read_seq.start(m_sequencer, this);
    endtask

endclass : fifo_sequence

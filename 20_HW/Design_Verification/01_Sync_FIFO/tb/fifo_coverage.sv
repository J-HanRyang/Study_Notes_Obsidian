// First step: count which requests occurred. No covergroup or pass threshold yet.
class fifo_coverage extends uvm_subscriber #(fifo_seq_item);
    `uvm_component_utils(fifo_coverage)
    int unsigned request_count[4];

    function new(string name = "fifo_coverage", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void write(fifo_seq_item fifo_item);
        // 00=idle, 01=read, 10=write, 11=simultaneous requests.
        request_count[{fifo_item.wr_en, fifo_item.rd_en}]++;
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("COV", $sformatf("idle=%0d read=%0d write=%0d simultaneous=%0d",
            request_count[0], request_count[1], request_count[2], request_count[3]), UVM_LOW)
    endfunction
endclass : fifo_coverage

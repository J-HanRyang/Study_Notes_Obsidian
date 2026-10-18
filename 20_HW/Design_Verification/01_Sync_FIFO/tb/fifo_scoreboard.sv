class fifo_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(fifo_scoreboard)

    uvm_analysis_imp #(fifo_seq_item, fifo_scoreboard) mon_imp;
    bit [31:0] expected_q[$];
    int unsigned write_count = 0;
    int unsigned compare_count = 0;

    function new(string name = "fifo_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        mon_imp = new("mon_imp", this);
    endfunction

    virtual function void write(fifo_seq_item fifo_item);
        bit [31:0] expected_data;
        // full/empty were sampled BEFORE the DUT processed this request.
        if (fifo_item.rd_en && !fifo_item.empty) begin
            if (expected_q.size() == 0) begin
                `uvm_error("SCB", "Read accepted but expected queue is empty")
            end else begin
                expected_data = expected_q.pop_front();
                compare_count++;
                if (fifo_item.rdata !== expected_data)
                    `uvm_error("SCB", $sformatf("expected=%08h actual=%08h",
                        expected_data, fifo_item.rdata))
                else
                    `uvm_info("SCB", $sformatf("MATCH expected=%08h actual=%08h",
                        expected_data, fifo_item.rdata), UVM_LOW)
            end
        end

        if (fifo_item.wr_en && !fifo_item.full) begin
            expected_q.push_back(fifo_item.wdata);
            write_count++;
            `uvm_info("SCB", $sformatf("PUSH data=%08h queue_size=%0d",
                fifo_item.wdata, expected_q.size()), UVM_LOW)
        end
    endfunction

    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if (compare_count == 0)
            `uvm_error("SCB", "No read data was compared")
        if (expected_q.size() != 0)
            `uvm_error("SCB", "Unread expected data remains at end of test")
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCB", $sformatf("writes=%0d comparisons=%0d remaining=%0d",
            write_count, compare_count, expected_q.size()), UVM_LOW)
    endfunction
endclass : fifo_scoreboard

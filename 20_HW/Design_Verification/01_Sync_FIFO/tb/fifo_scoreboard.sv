class fifo_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(fifo_scoreboard)
    uvm_analysis_imp #(fifo_seq_item, fifo_scoreboard) mon_imp;
    bit [31:0] expected_q[$];
    bit [31:0] expected_rdata = 0;
    int unsigned observations, writes, comparisons, holds, reset_events;
    int unsigned discarded_by_reset, last_processed_id;
    bit in_reset = 0;
    bit injected = 0;

    function new(string name = "fifo_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        mon_imp = new("mon_imp", this);
    endfunction

    // Called synchronously by monitor's analysis_port.write(). No time waits.
    virtual function void write(fifo_seq_item item);
        bit accept_write, accept_read;
        bit [31:0] comparison_value;
        int before_level;
        observations++;
        before_level = expected_q.size();

        if (item.rst_n !== 1'b1) begin
            if (!in_reset) begin
                reset_events++;
                discarded_by_reset += before_level;
            end
            in_reset = 1;
            expected_q.delete();
            expected_rdata = 0;
        end else begin
            in_reset = 0;
            // Acceptance comes from the INDEPENDENT model, not DUT flags.
            if (item.full !== (before_level == FIFO_DEPTH))
                `uvm_error("FLAG_PRE", $sformatf("id=%0d full=%b model_level=%0d",
                    item.request_id, item.full, before_level))
            if (item.empty !== (before_level == 0))
                `uvm_error("FLAG_PRE", $sformatf("id=%0d empty=%b model_level=%0d",
                    item.request_id, item.empty, before_level))

            accept_write = item.wr_en && (before_level < FIFO_DEPTH);
            accept_read = item.rd_en && (before_level > 0);
            // Both decisions use pre-edge occupancy. No boundary bypass.
            if (accept_read) expected_rdata = expected_q.pop_front();
            if (accept_write) begin
                expected_q.push_back(item.wdata);
                writes++;
            end
            if (accept_read) comparisons++;
            else holds++;
        end

        comparison_value = expected_rdata;
        // Reversible checker self-test: no DUT/source mutation needed.
        if ($test$plusargs("INJECT_MISMATCH") && !injected &&
            item.rst_n === 1'b1 && item.rd_en && before_level > 0) begin
            comparison_value ^= 32'h1;
            injected = 1;
        end
        if (item.rdata !== comparison_value)
            `uvm_error("DATA", $sformatf("id=%0d expected=%08h actual=%08h",
                item.request_id, comparison_value, item.rdata))
        else if (item.rst_n === 1'b1 && item.rd_en && before_level > 0)
            `uvm_info("MATCH", $sformatf("id=%0d expected=%08h actual=%08h",
                item.request_id, expected_rdata, item.rdata), UVM_MEDIUM)

        if (item.full_after !== (expected_q.size() == FIFO_DEPTH))
            `uvm_error("FLAG_POST", "full does not match updated queue size")
        if (item.empty_after !== (expected_q.size() == 0))
            `uvm_error("FLAG_POST", "empty does not match updated queue size")
        // Publish completion only after every check on this snapshot.
        last_processed_id = item.request_id;
    endfunction

    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if (comparisons == 0) `uvm_error("NO_COMPARE", "No accepted read was compared")
        if (expected_q.size() != 0)
            `uvm_error("PENDING", $sformatf("%0d unread entries remain", expected_q.size()))
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCOREBOARD", $sformatf(
            "observations=%0d writes=%0d comparisons=%0d holds=%0d resets=%0d reset_discarded=%0d pending=%0d last_id=%0d",
            observations, writes, comparisons, holds, reset_events,
            discarded_by_reset, expected_q.size(), last_processed_id), UVM_LOW)
    endfunction
endclass : fifo_scoreboard

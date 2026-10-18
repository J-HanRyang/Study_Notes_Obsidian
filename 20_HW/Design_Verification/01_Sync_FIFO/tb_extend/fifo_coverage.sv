// Portable functional-coverage counters. These are not code-coverage percentages.
class fifo_coverage extends uvm_subscriber #(fifo_seq_item);
    `uvm_component_utils(fifo_coverage)
    int unsigned cross_hits[3][4]; // empty/middle/full X idle/read/write/both
    int unsigned reset_hits[3];
    int level = 0;
    int unsigned epoch_writes, epoch_reads;
    bit saw_write_wrap, saw_read_wrap, in_reset;

    function new(string name = "fifo_coverage", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void write(fifo_seq_item item);
        int state_bin, operation;
        bit aw, ar;
        if (item.rst_n !== 1'b1) begin
            if (!in_reset) begin
                state_bin = (level == 0) ? 0 : ((level == FIFO_DEPTH) ? 2 : 1);
                reset_hits[state_bin]++;
            end
            level = 0;
            epoch_writes = 0;
            epoch_reads = 0;
            in_reset = 1;
            return;
        end
        in_reset = 0;
        state_bin = item.empty ? 0 : (item.full ? 2 : 1);
        operation = int'({item.wr_en, item.rd_en});
        cross_hits[state_bin][operation]++;
        aw = item.wr_en && !item.full;
        ar = item.rd_en && !item.empty;
        if (aw) epoch_writes++;
        if (ar) epoch_reads++;
        if (epoch_writes > FIFO_DEPTH) saw_write_wrap = 1;
        if (epoch_reads > FIFO_DEPTH) saw_read_wrap = 1;
        level += int'(aw) - int'(ar);
    endfunction

    function int hit_count();
        int result = 0;
        foreach (cross_hits[s,o]) if (cross_hits[s][o] != 0) result++;
        return result;
    endfunction

    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if (!$test$plusargs("SMOKE_ONLY")) begin
            foreach (cross_hits[s,o])
                if (cross_hits[s][o] == 0)
                    `uvm_error("COVERAGE_HOLE", $sformatf("state=%0d operation=%0d not hit", s,o))
            foreach (reset_hits[s])
                if (reset_hits[s] == 0)
                    `uvm_error("RESET_HOLE", $sformatf("reset state=%0d not hit", s))
            if (!saw_write_wrap || !saw_read_wrap)
                `uvm_error("WRAP_HOLE", "Both pointer wrap scenarios must occur")
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("COVERAGE", $sformatf(
            "request/state bins=%0d/12 reset bins=%0d/3 write_wrap=%b read_wrap=%b",
            hit_count(), int'(reset_hits[0]>0)+int'(reset_hits[1]>0)+int'(reset_hits[2]>0),
            saw_write_wrap, saw_read_wrap), UVM_LOW)
    endfunction
endclass : fifo_coverage

class fifo_test extends uvm_test;
    `uvm_component_utils(fifo_test)
    fifo_env env;

    function new(string name = "fifo_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = fifo_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        fifo_sequence smoke_seq;
        fifo_regression_sequence regression_seq;
        phase.raise_objection(this);
        if ($test$plusargs("SMOKE_ONLY")) begin
            smoke_seq = fifo_sequence::type_id::create("smoke_seq");
            smoke_seq.start(env.agt.sqr);
        end else begin
            regression_seq = fifo_regression_sequence::type_id::create("regression_seq");
            regression_seq.start(env.agt.sqr);
        end
        // item_done alone does not guarantee monitor/scoreboard have finished.
        wait (env.sb.last_processed_id >= env.agt.drv.completed_count);
        #1ps;
        `uvm_info("COMPLETE", $sformatf("driver=%0d scoreboard_last_id=%0d",
            env.agt.drv.completed_count, env.sb.last_processed_id), UVM_LOW)
        phase.drop_objection(this);
    endtask

    virtual function void report_phase(uvm_phase phase);
        uvm_report_server server;
        super.report_phase(phase);
        server = uvm_report_server::get_server();
        if (server.get_severity_count(UVM_ERROR) != 0 ||
            server.get_severity_count(UVM_FATAL) != 0) begin
            `uvm_fatal("RESULT", "FIFO verification FAILED; see earlier errors")
            return; // Some backends schedule finish rather than stopping immediately.
        end
        `uvm_info("RESULT", "FIFO verification PASS", UVM_LOW)
    endfunction
endclass : fifo_test

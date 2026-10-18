class fifo_test extends uvm_test;
    `uvm_component_utils(fifo_test)

    fifo_env env;

    function new(string name = "fifo_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = fifo_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        fifo_sequence seq;
        phase.raise_objection(this);
        seq = fifo_sequence::type_id::create("seq", this);
        seq.start(env.agt.sqr);

        // Let the final negedge monitor.write finish before ending the test.
        @(posedge env.agt.drv.vif.clk);
        phase.drop_objection(this);
    endtask
endclass : fifo_test
